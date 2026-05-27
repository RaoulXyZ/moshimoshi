import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../providers/questions.dart';
import '../../../utility/local_user.dart';
import '../../../utility/mindblooming_color_scheme.dart';
import '../../../utility/mindblooming_text_style.dart';

final String mainUrl = dotenv.env['QUALTRICS_URL']!;
final String token = dotenv.env['QUALTRICS_TOKEN']!;

class DiaryScreen extends StatefulWidget {
  const DiaryScreen({Key? key}) : super(key: key);

  @override
  _DiaryScreenState createState() => _DiaryScreenState();
}

class _DiaryScreenState extends State<DiaryScreen> {
  List<Map<String, String>> _diaryEntries = [];
  Future<dynamic>? _diaryContentFuture;
  late Box _diaryBox;

  @override
  void initState() {
    super.initState();
    _openDiaryBox();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_diaryContentFuture == null) {
      final surveyID = Provider.of<Questions>(context, listen: false)
          .surveyID("MM_diariopersonale");
      _diaryContentFuture = _fetchDiaryContent(surveyID);

      _diaryContentFuture!.then((fetchedEntries) {
        if (fetchedEntries.isNotEmpty) {
          setState(() {
            _diaryEntries = fetchedEntries;
          });
          // (opzionale) salva anche in Hive, così hai sempre l’ultima versione
          _diaryBox.put('diario', _diaryEntries);
        }
      });

      log("Diary content future initiated");
    }
  }

  Future<List<Map<String, String>>> _fetchDiaryContent(String surveyID) async {
    final String? uuid = LocalUser.currentUid();
    if (uuid == null) {
      throw Exception("Utente non autenticato");
    }

    // Avvia l'export da Qualtrics
    final exportUri =
        Uri.https(mainUrl, "/API/v3/surveys/$surveyID/export-responses");
    final exportResponse = await http.post(
      exportUri,
      headers: {
        'X-API-TOKEN': token,
        'Content-Type': 'application/json',
      },
      body: jsonEncode({"format": "json", "compress": false}),
    );
    if (exportResponse.statusCode != 200) {
      throw Exception(
        "Errore nell'avvio dell'export: ${exportResponse.statusCode}",
      );
    }

    final exportResult = jsonDecode(exportResponse.body)['result'];
    final progressId = exportResult?['progressId'];
    if (progressId == null) {
      throw Exception("ProgressId non trovato nella risposta di export.");
    }

    // Polling per verificare il completamento dell'export
    final progressUri = Uri.https(
      mainUrl,
      "/API/v3/surveys/$surveyID/export-responses/$progressId",
    );
    bool exportComplete = false;
    int attempts = 0;
    const int maxAttempts = 60;
    Map<String, dynamic> progressResult = {};

    while (!exportComplete && attempts < maxAttempts) {
      final progressResponse = await http.get(
        progressUri,
        headers: {'X-API-TOKEN': token},
      );
      if (progressResponse.statusCode != 200) {
        throw Exception(
          "Errore nel recupero del progresso: ${progressResponse.statusCode}",
        );
      }
      progressResult = jsonDecode(progressResponse.body)['result'];
      final num percentComplete =
          (progressResult['percentComplete'] as num?) ?? 0;
      if (percentComplete >= 100) {
        exportComplete = true;
        break;
      }
      await Future.delayed(const Duration(seconds: 1));
      attempts++;
    }
    if (!exportComplete) {
      throw Exception("Timeout: l'export non è stato completato in tempo.");
    }

    final fileId = progressResult['fileId'];
    if (fileId == null) {
      throw Exception(
        "FileId non trovato. L'export potrebbe non essere completato.",
      );
    }

    // Recupera il file esportato da Qualtrics
    final fileUri = Uri.https(
      mainUrl,
      "/API/v3/surveys/$surveyID/export-responses/$fileId/file",
    );
    final fileResponse = await http.get(
      fileUri,
      headers: {'X-API-TOKEN': token},
    );
    if (fileResponse.statusCode != 200) {
      throw Exception(
        "Errore nel recupero del file: ${fileResponse.statusCode}",
      );
    }

    final jsonData = jsonDecode(fileResponse.body);
    log("Exported file data: ${fileResponse.body}");

    final responses = (jsonData['responses'] as List<dynamic>?) ?? [];
    final userResponses =
        responses.where((res) => res['values']['QID6_TEXT'] == uuid).toList();

    if (userResponses.isEmpty) return [];

    userResponses.sort((a, b) {
      final ta = DateTime.parse(a['values']['recordedDate']!);
      final tb = DateTime.parse(b['values']['recordedDate']!);

      return tb.compareTo(ta);
    });

    final latest = userResponses.first;
    // Estraggo la stringa JSON con le note
    final String rawEntries = latest['values']['QID5_TEXT'] as String? ?? '[]';
    // Decodifico in lista dinamica
    final List<dynamic> decoded = jsonDecode(rawEntries) as List<dynamic>;
    // Converto ogni entry in Map<String, String>

    return decoded.map((e) {
      final m = e as Map<String, dynamic>;

      return m.map((k, v) => MapEntry(k.toString(), v.toString()));
    }).toList();
  }

  Future<void> _openDiaryBox() async {
    _diaryBox = await Hive.openBox('moshimoshi');
    final stored = _diaryBox.get('diario');

    if (stored != null && stored is List) {
      final loaded = stored.map<Map<String, String>>((e) {
        if (e is Map) {
          return e.map((k, v) => MapEntry(k.toString(), v.toString()));
        }

        return <String, String>{};
      }).toList();

      setState(() {
        _diaryEntries = loaded;
      });
    }
    // else: first launch, leave _diaryEntries as [] until the user adds their first note
  }

  Future<bool> _sendNoteToQualtrics(
    List<Map<String, String>> entries,
  ) async {
    final questions = Provider.of<Questions>(context, listen: false);
    final surveyID = questions.surveyID("MM_diariopersonale");
    final String? uuid = LocalUser.currentUid();

    try {
      final payload = jsonEncode({
        "values": {
          "QID5_TEXT": jsonEncode(entries),
          "QID6_TEXT": uuid,
        },
      });

      final res = await http.post(
        Uri.https(mainUrl, "/API/v3/surveys/$surveyID/responses"),
        headers: {
          'X-API-TOKEN': token,
          'Content-Type': 'application/json',
        },
        body: payload,
      );

      if (res.statusCode >= 200 && res.statusCode < 300) {
        return true;
      }

      return true;
    } catch (e) {
      log("Errore durante l'aggiornamento: $e");

      return false;
    }
  }

  Future<void> _addNewNote(
    String content,
    bool isNew,
    int? index,
    BuildContext context,
  ) async {
    final newNote = {
      "timestamp": DateTime.now().toIso8601String(),
      "content": content,
    };

    if (isNew) {
      setState(() {
        _diaryEntries.add(newNote);
      });
    } else if (index != null) {
      setState(() {
        _diaryEntries[index] = {
          "timestamp": DateTime.now().toIso8601String(),
          "content": content,
        };
      });
    }

    _diaryBox.put('diario', _diaryEntries);

    final res = await _sendNoteToQualtrics(_diaryEntries);
    if (!res) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Errore: impossibile salvare la nota'),
          ),
        );
      }
    }
  }

  Future<void> _deleteNote(
    int idx,
    BuildContext context,
  ) async {
    setState(() {
      _diaryEntries.removeAt(idx);
    });

    _diaryBox.put('diario', _diaryEntries);

    // Chiamata al metodo per inviare i dati su qualtrics
    final res = await _sendNoteToQualtrics(_diaryEntries);
    if (!res) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Errore: impossibile eliminare la nota'),
          ),
        );
      }
    }
  }

  Widget _buildNoteCard(int idx, String isoTimestamp, String noteText) {
    final dateTime = DateTime.parse(isoTimestamp);
    final formattedDate = DateFormat('dd MMM yyyy').format(dateTime);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 600;

          return Container(
            decoration: BoxDecoration(
              color: Colors.orange.shade100,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.orange,
                width: 0.5,
              ),
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 15,
            ),
            child: isMobile
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        formattedDate,
                        style: MindBloomingTextStyle.subtitle,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        noteText,
                        style: MindBloomingTextStyle.pretitle,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          _buildActionButton(
                            icon: Icons.edit,
                            color: Colors.blue,
                            onPressed: () => _showNoteDialog(
                              false,
                              initialText: noteText,
                              editIndex: idx,
                            ),
                          ),
                          const SizedBox(width: 8),
                          _buildActionButton(
                            icon: Icons.delete,
                            color: Colors.red,
                            onPressed: () => _deleteNote(idx, context),
                          ),
                        ],
                      ),
                    ],
                  )
                : Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Text(
                              formattedDate,
                              style: MindBloomingTextStyle.subtitle,
                            ),
                            const SizedBox(width: 30),
                            Expanded(
                              child: Text(
                                noteText,
                                style: MindBloomingTextStyle.pretitle,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildActionButton(
                            icon: Icons.edit,
                            color: Colors.blue,
                            onPressed: () => _showNoteDialog(
                              false,
                              initialText: noteText,
                              editIndex: idx,
                            ),
                          ),
                          const SizedBox(width: 8),
                          _buildActionButton(
                            icon: Icons.delete,
                            color: Colors.red,
                            onPressed: () => _deleteNote(idx, context),
                          ),
                        ],
                      ),
                    ],
                  ),
          );
        },
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return CircleAvatar(
      radius: 20,
      backgroundColor: color.withValues(alpha: 0.1),
      child: IconButton(
        icon: Icon(icon, color: color, size: 18),
        onPressed: onPressed,
      ),
    );
  }

  void _showNoteDialog(
    bool newNote, {
    String initialText = '',
    int? editIndex,
  }) {
    final controller = TextEditingController(text: initialText);
    showDialog(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${newNote ? "Aggiungi" : "Modifica"} Nota',
                  style: MindBloomingTextStyle.header3,
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: controller,
                  decoration: InputDecoration(
                    labelText: "Inserisci il contenuto della nota",
                    labelStyle: MindBloomingTextStyle.pretitle,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(
                        color: MindBloomingColorScheme.secondary,
                        width: 2,
                      ),
                    ),
                  ),
                  keyboardType: TextInputType.multiline,
                  maxLines: null,
                  minLines: 1,
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(dialogContext).pop(),
                      child: Text(
                        "Annulla",
                        style: MindBloomingTextStyle.pretitle,
                      ),
                    ),
                    const SizedBox(width: 10),
                    TextButton(
                      style: TextButton.styleFrom(
                        foregroundColor: MindBloomingColorScheme.primary,
                        backgroundColor: MindBloomingColorScheme.tertiary,
                        side: const BorderSide(
                          color: MindBloomingColorScheme.tertiary3shadow,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      onPressed: () {
                        final text = controller.text;
                        if (text.isNotEmpty) {
                          _addNewNote(text, newNote, editIndex, dialogContext);
                          Navigator.of(dialogContext).pop();
                        }
                      },
                      child: Text(
                        newNote ? "Conferma" : "Aggiorna",
                        style: MindBloomingTextStyle.button,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Diario", style: MindBloomingTextStyle.header1),
              const SizedBox(height: 20),
              FutureBuilder<dynamic>(
                future: _diaryContentFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return SizedBox(
                      height: MediaQuery.of(context).size.height * 0.6,
                      child: const Center(child: CircularProgressIndicator()),
                    );
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        "Errore nel caricamento dei dati: ${snapshot.error}",
                      ),
                    );
                  } else {
                    // Usa i dati restituiti da Qualtrics (o, in caso di risposta vuota, i dati locali)
                    final List<Map<String, String>> displayEntries =
                        (snapshot.data is List &&
                                (snapshot.data as List).isNotEmpty)
                            ? List<Map<String, String>>.from(snapshot.data)
                            : _diaryEntries;
                    final sortedEntries =
                        displayEntries.asMap().entries.toList()
                          ..sort(
                            (a, b) => b.value["timestamp"]!
                                .compareTo(a.value["timestamp"]!),
                          );

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: sortedEntries.isEmpty
                          ? [
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 20),
                                child: Text(
                                  "Non ci sono note. Aggiungi la tua prima nota!",
                                  style: MindBloomingTextStyle.pretitle,
                                ),
                              ),
                            ]
                          : sortedEntries
                              .map(
                                (entry) => _buildNoteCard(
                                  entry.key, // indice originale
                                  entry.value["timestamp"]!,
                                  entry.value["content"]!,
                                ),
                              )
                              .toList(),
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showNoteDialog(true),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
