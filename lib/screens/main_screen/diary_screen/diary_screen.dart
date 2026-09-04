import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../providers/questions.dart';
import '../../../utility/local_user.dart';
import '../../../utility/mindblooming_color_scheme.dart';
import '../../../utility/mindblooming_text_style.dart';
import '../../../utility/notification_api.dart';

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

  final ScrollController _scrollController = ScrollController();

  /// Timestamp della nota appena aggiunta ai preferiti: usato per animarne
  /// la risalita in cima alla lista una sola volta.
  String? _justStarredTimestamp;

  @override
  void initState() {
    super.initState();
    _openDiaryBox();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  int _reminderNotifId(String timestamp) =>
      100000 + timestamp.hashCode.abs() % 800000;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_diaryContentFuture == null) {
      final surveyID = Provider.of<Questions>(context, listen: false)
          .surveyID("MM_diariopersonale");
      _diaryContentFuture = _fetchDiaryContent(surveyID);

      _diaryContentFuture!.then(
        (fetchedEntries) {
          if (!mounted) return;
          if (fetchedEntries.isNotEmpty) {
            setState(() {
              _diaryEntries = fetchedEntries;
            });
            // (opzionale) salva anche in Hive, così hai sempre l’ultima versione
            _diaryBox.put('diario', _diaryEntries);
          }
        },
        // L'errore viene già mostrato dal FutureBuilder (modalità offline):
        // qui lo intercettiamo solo per non lasciare la future non gestita.
        onError: (Object error) {
          log("Errore nel caricamento del diario: $error");
        },
      );

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
        final existing = _diaryEntries[index];
        _diaryEntries[index] = {
          "timestamp": DateTime.now().toIso8601String(),
          "content": content,
          if (existing["starred"] == "true") "starred": "true",
          if (existing["reminder"] != null) "reminder": existing["reminder"]!,
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
    if (idx < 0 || idx >= _diaryEntries.length) {
      return;
    }

    final removed = _diaryEntries[idx];
    if (removed["reminder"] != null) {
      await NotificationAPI.cancelNotification(
        _reminderNotifId(removed["timestamp"] ?? ''),
      );
    }

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

  Future<void> _toggleStar(
    int idx,
    BuildContext context,
  ) async {
    if (idx < 0 || idx >= _diaryEntries.length) {
      return;
    }

    final entry = _diaryEntries[idx];
    final willBeStarred = entry["starred"] != "true";

    setState(() {
      _diaryEntries[idx] = {
        ...entry,
        "starred": willBeStarred.toString(),
      };
      _justStarredTimestamp = willBeStarred ? entry["timestamp"] : null;
    });

    if (willBeStarred) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            0,
            duration: const Duration(milliseconds: 350),
            curve: Curves.easeOut,
          );
        }
      });
    }

    _diaryBox.put('diario', _diaryEntries);

    final res = await _sendNoteToQualtrics(_diaryEntries);
    if (!res) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Errore: impossibile aggiornare la nota'),
          ),
        );
      }
    }
  }

  Future<void> _showReminderDialog(
    int idx,
    BuildContext context,
  ) async {
    if (idx < 0 || idx >= _diaryEntries.length) {
      return;
    }

    final raw = _diaryEntries[idx]["reminder"];
    final parsed = raw == null ? null : DateTime.tryParse(raw);
    final DateTime? current =
        (parsed != null && parsed.isAfter(DateTime.now())) ? parsed : null;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            'Promemoria nota',
            style: MindBloomingTextStyle.header3,
          ),
          content: Text(
            current != null
                ? "Promemoria impostato per il ${DateFormat("dd MMM yyyy 'alle' HH:mm").format(current)}."
                : "Scegli quando vuoi ricevere una notifica per ricordarti questa nota.",
            style: MindBloomingTextStyle.pretitle,
          ),
          actions: [
            if (current != null)
              TextButton(
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                  _clearReminder(idx, context);
                },
                child: Text(
                  "Rimuovi",
                  style: MindBloomingTextStyle.pretitle.copyWith(
                    color: Colors.red,
                  ),
                ),
              ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(
                "Annulla",
                style: MindBloomingTextStyle.pretitle,
              ),
            ),
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
                Navigator.of(dialogContext).pop();
                _pickAndSetReminder(idx, context);
              },
              child: Text(
                current != null ? "Modifica" : "Scegli",
                style: MindBloomingTextStyle.button,
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _pickAndSetReminder(
    int idx,
    BuildContext context,
  ) async {
    final now = DateTime.now();
    final suggestion = now.add(const Duration(hours: 1));

    final date = await showDatePicker(
      context: context,
      initialDate: suggestion,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );
    if (date == null || !context.mounted) {
      return;
    }

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(suggestion),
    );
    if (time == null || !context.mounted) {
      return;
    }

    final when = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );
    if (!when.isAfter(DateTime.now())) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Scegli un momento futuro per il promemoria.'),
        ),
      );

      return;
    }

    await _setReminder(idx, when, context);
  }

  Future<void> _setReminder(
    int idx,
    DateTime when,
    BuildContext context,
  ) async {
    if (idx < 0 || idx >= _diaryEntries.length) {
      return;
    }

    final permission = await NotificationAPI.requestPermissions();
    if (permission != NotifPermissionResult.granted) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Permessi notifiche negati.'),
            action: permission == NotifPermissionResult.permanentlyDenied
                ? const SnackBarAction(
                    label: 'IMPOSTAZIONI',
                    onPressed: NotificationAPI.openSystemSettings,
                  )
                : null,
          ),
        );
      }

      return;
    }

    final note = _diaryEntries[idx];
    final id = _reminderNotifId(note["timestamp"] ?? '');
    await NotificationAPI.cancelNotification(id);
    await NotificationAPI.scheduleOnce(
      id: id,
      title: 'Promemoria diario',
      body: (note["content"]?.isNotEmpty ?? false)
          ? note["content"]!
          : 'Hai una nota del diario da rivedere.',
      when: when,
      channel: NotificationChannel.diary,
    );

    setState(() {
      _diaryEntries[idx] = {
        ...note,
        "reminder": when.toIso8601String(),
      };
    });

    _diaryBox.put('diario', _diaryEntries);
    await _sendNoteToQualtrics(_diaryEntries);

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Promemoria impostato per il ${DateFormat("dd MMM yyyy 'alle' HH:mm").format(when)}.",
          ),
        ),
      );
    }
  }

  Future<void> _clearReminder(
    int idx,
    BuildContext context,
  ) async {
    if (idx < 0 || idx >= _diaryEntries.length) {
      return;
    }

    final note = _diaryEntries[idx];
    await NotificationAPI.cancelNotification(
      _reminderNotifId(note["timestamp"] ?? ''),
    );

    setState(() {
      final updated = {...note}..remove("reminder");
      _diaryEntries[idx] = updated;
    });

    _diaryBox.put('diario', _diaryEntries);
    await _sendNoteToQualtrics(_diaryEntries);

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Promemoria rimosso.'),
        ),
      );
    }
  }

  /// Apre Google Calendar (web/app) sulla pagina di creazione evento gia'
  /// precompilata con il promemoria della nota. Nessun account/API: e' solo
  /// un link "TEMPLATE" di Google Calendar.
  Future<void> _addToGoogleCalendar(
    int idx,
    BuildContext context,
  ) async {
    if (idx < 0 || idx >= _diaryEntries.length) {
      return;
    }

    final note = _diaryEntries[idx];
    final raw = note["reminder"];
    final when = raw == null ? null : DateTime.tryParse(raw);
    if (when == null || !when.isAfter(DateTime.now())) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Imposta prima un promemoria con il campanello.'),
        ),
      );

      return;
    }

    final content = note["content"] ?? '';
    final firstLine = content.split('\n').first.trim();
    final title = firstLine.isEmpty
        ? 'Nota diario'
        : (firstLine.length > 60
            ? '${firstLine.substring(0, 60)}…'
            : firstLine);

    final fmt = DateFormat("yyyyMMdd'T'HHmmss'Z'");
    final start = fmt.format(when.toUtc());
    final end = fmt.format(when.toUtc().add(const Duration(hours: 1)));

    final uri = Uri.https('calendar.google.com', '/calendar/render', {
      'action': 'TEMPLATE',
      'text': title,
      'dates': '$start/$end',
      'details': content,
    });

    final launched = await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );
    if (!launched && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Impossibile aprire Google Calendar.'),
        ),
      );
    }
  }

  Widget _buildNoteCard(
    int idx,
    String isoTimestamp,
    String noteText,
    bool starred,
    bool hasReminder,
  ) {
    final dateTime = DateTime.parse(isoTimestamp);
    final formattedDate = DateFormat('dd MMM yyyy').format(dateTime);

    final card = Padding(
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
                      Wrap(
                        alignment: WrapAlignment.end,
                        spacing: 8,
                        runSpacing: 8,
                        children: _noteActionButtons(
                          idx: idx,
                          noteText: noteText,
                          starred: starred,
                          hasReminder: hasReminder,
                          context: context,
                        ),
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
                      Wrap(
                        alignment: WrapAlignment.end,
                        spacing: 8,
                        runSpacing: 8,
                        children: _noteActionButtons(
                          idx: idx,
                          noteText: noteText,
                          starred: starred,
                          hasReminder: hasReminder,
                          context: context,
                        ),
                      ),
                    ],
                  ),
          );
        },
      ),
    );

    if (_justStarredTimestamp != isoTimestamp) {
      return KeyedSubtree(
        key: ValueKey('note-$isoTimestamp'),
        child: card,
      );
    }

    return KeyedSubtree(
      key: ValueKey('note-$isoTimestamp'),
      child: TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: 0, end: 1),
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeOutCubic,
        onEnd: () {
          if (mounted && _justStarredTimestamp == isoTimestamp) {
            setState(() => _justStarredTimestamp = null);
          }
        },
        builder: (context, t, child) {
          return Opacity(
            opacity: (0.2 + 0.8 * t).clamp(0.0, 1.0),
            child: Transform.translate(
              offset: Offset(0, (1 - t) * 24),
              child: child,
            ),
          );
        },
        child: card,
      ),
    );
  }

  List<Widget> _noteActionButtons({
    required int idx,
    required String noteText,
    required bool starred,
    required bool hasReminder,
    required BuildContext context,
  }) {
    return [
      _buildActionButton(
        icon: starred ? Icons.star : Icons.star_border,
        color: Colors.amber.shade700,
        onPressed: () => _toggleStar(idx, context),
      ),
      _buildActionButton(
        icon: hasReminder
            ? Icons.notifications_active
            : Icons.notifications_none,
        color: hasReminder
            ? MindBloomingColorScheme.secondary
            : Colors.grey.shade600,
        onPressed: () => _showReminderDialog(idx, context),
      ),
      _buildActionButton(
        icon: Icons.event,
        color: hasReminder ? Colors.teal.shade600 : Colors.grey.shade600,
        onPressed: () => _addToGoogleCalendar(idx, context),
      ),
      _buildActionButton(
        icon: Icons.edit,
        color: Colors.blue,
        onPressed: () => _showNoteDialog(
          false,
          initialText: noteText,
          editIndex: idx,
        ),
      ),
      _buildActionButton(
        icon: Icons.delete,
        color: Colors.red,
        onPressed: () => _deleteNote(idx, context),
      ),
    ];
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

  Widget _buildNotesList(
    List<Map<String, String>> entries, {
    bool offline = false,
  }) {
    final sortedEntries = entries.asMap().entries.toList()
      ..sort((a, b) {
        final aStar = a.value["starred"] == "true" ? 1 : 0;
        final bStar = b.value["starred"] == "true" ? 1 : 0;
        if (aStar != bStar) {
          return bStar - aStar;
        }

        return b.value["timestamp"]!.compareTo(a.value["timestamp"]!);
      });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (offline) _buildOfflineBanner(),
        if (sortedEntries.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Text(
              offline
                  ? "Non ci sono note salvate sul dispositivo."
                  : "Non ci sono note. Aggiungi la tua prima nota!",
              style: MindBloomingTextStyle.pretitle,
            ),
          )
        else
          ...sortedEntries.map((entry) {
            final rawReminder = entry.value["reminder"];
            final parsedReminder =
                rawReminder == null ? null : DateTime.tryParse(rawReminder);
            final hasReminder = parsedReminder != null &&
                parsedReminder.isAfter(DateTime.now());

            return _buildNoteCard(
              entry.key, // indice originale
              entry.value["timestamp"]!,
              entry.value["content"]!,
              entry.value["starred"] == "true",
              hasReminder,
            );
          }),
      ],
    );
  }

  Widget _buildOfflineBanner() {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.fromLTRB(15, 10, 5, 10),
      decoration: BoxDecoration(
        color: MindBloomingColorScheme.primary1shadow,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: MindBloomingColorScheme.primary3shadow,
          width: 0.5,
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.cloud_off,
            size: 20,
            color: MindBloomingColorScheme.textColorDark1shadow,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              "Nessuna connessione: stai vedendo le note salvate sul "
              "dispositivo. Le modifiche restano in locale finché non torni "
              "online.",
              style: MindBloomingTextStyle.small,
            ),
          ),
          TextButton(
            onPressed: _retryFetch,
            child: Text(
              "Riprova",
              style: MindBloomingTextStyle.pretitle,
            ),
          ),
        ],
      ),
    );
  }

  void _retryFetch() {
    final surveyID = Provider.of<Questions>(context, listen: false)
        .surveyID("MM_diariopersonale");

    setState(() {
      _diaryContentFuture = _fetchDiaryContent(surveyID);
    });

    _diaryContentFuture!.then(
      (fetchedEntries) {
        if (!mounted) return;
        if (fetchedEntries.isNotEmpty) {
          setState(() {
            _diaryEntries = fetchedEntries;
          });
          _diaryBox.put('diario', _diaryEntries);
        }
      },
      onError: (Object error) {
        log("Errore nel caricamento del diario: $error");
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        controller: _scrollController,
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
                  }

                  // Se Qualtrics non è raggiungibile (rete assente, DNS, ecc.)
                  // mostriamo comunque le note salvate localmente su Hive:
                  // il diario resta consultabile e modificabile offline.
                  if (snapshot.hasError) {
                    return _buildNotesList(_diaryEntries, offline: true);
                  }

                  // Usa i dati restituiti da Qualtrics (o, in caso di risposta vuota, i dati locali)
                  final List<Map<String, String>> displayEntries =
                      (snapshot.data is List &&
                              (snapshot.data as List).isNotEmpty)
                          ? List<Map<String, String>>.from(snapshot.data)
                          : _diaryEntries;

                  return _buildNotesList(displayEntries);
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
