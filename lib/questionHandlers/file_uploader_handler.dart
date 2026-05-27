import 'dart:async';
import 'dart:developer';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';

import '../providers/answers.dart';
import '../utility/mindblooming_color_scheme.dart';
import '../widgets/questions/question_text.dart';

Widget fileUploaderHandler(
  Map<String, dynamic> _element,
  String surveyID,
  String blockID,
) {
  final String _questionText = _element['QuestionText'];

  return UploadFile(
    questionText: _questionText,
    surveyID: surveyID,
    blockID: blockID,
    questionID: _element['QuestionID'],
  );
}

class UploadFile extends StatefulWidget {
  final String surveyID;
  final String blockID;
  final String questionID;
  final String questionText;

  UploadFile({
    required this.questionText,
    required this.surveyID,
    required this.blockID,
    required this.questionID,
  }) : super(key: Key(questionID));

  @override
  _UploadFileState createState() => _UploadFileState();
}

class _UploadFileState extends State<UploadFile> {
  PlatformFile? _file;
  late final Box _box;
  List<StoredImage> _images = [];

  @override
  void initState() {
    super.initState();
    _box = Hive.box('moshimoshi');
    final stored = _box.get('ragionidivita', defaultValue: <dynamic>[]);
    if (stored is List) {
      _images = stored
          .map((e) => StoredImage.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }
    // Log count of non-deleted images
    log('Loaded ${_images.length} images from Hive');
    log('Loaded ${_images.where((img) => !img.deleted).length} active images from Hive');
  }

  Future<void> _removeImage(int index) async {
    final img = _images[index];

    if (!img.saved) {
      // Se non è mai stata salvata, la rimuovo dalla lista
      _images.removeAt(index);
    } else {
      // Se invece era già salvata, faccio solo soft-delete
      img.saved = false;
      img.deleted = true;
    }

    // Riscrivo la lista aggiornata in Hive
    await _box.put(
      'ragionidivita',
      _images.map((e) => e.toJson()).toList(),
    );

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final answers = Provider.of<Answers>(context, listen: false);

    // Filter out deleted images for display
    final activeImages = _images.where((img) => !img.deleted).toList();

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          QuestionText(
            questionText: widget.questionText,
            surveyID: widget.surveyID,
            blockID: widget.blockID,
            questionID: widget.questionID,
          ),
          InkWell(
            onTap: () async {
              final result = await FilePicker.platform.pickFiles(
                type: FileType.custom,
                withData: true,
                allowMultiple: false,
                allowedExtensions: ['jpg', 'jpeg', 'png'],
              );

              if (result != null && result.files.isNotEmpty) {
                final picked = result.files.first;
                final alreadyExists = _images.any(
                  (img) => img.name == picked.name && img.deleted == false,
                );

                if (alreadyExists) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: Colors.redAccent,
                      content: Text(
                        'Errore: file "${picked.name}" già caricato',
                      ),
                    ),
                  );

                  return;
                }

                setState(() {
                  _file = result.files.first;
                });

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('File selezionato: ${_file!.name}'),
                  ),
                );

                // Add to provider
                answers.addAnswer(
                  widget.surveyID,
                  widget.questionID,
                  {_file!.name: _file!.bytes},
                );

                // Add to local list with saved=false, deleted=false
                final newImg = StoredImage(
                  name: _file!.name,
                  bytes: _file!.bytes!,
                );

                _images.add(newImg);

                // Persist updated list
                await _box.put(
                  'ragionidivita',
                  _images.map((e) => e.toJson()).toList(),
                );

                setState(() {});
              }
            },
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
              decoration: BoxDecoration(
                color: MindBloomingColorScheme.secondary5shadow,
                border:
                    Border.all(color: MindBloomingColorScheme.secondary5shadow),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.upload_file, color: Colors.white),
                  SizedBox(width: 8),
                  Text(
                    'Carica immagine',
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
          if (activeImages.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(20),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  int crossAxisCount = 2;
                  final width = constraints.maxWidth;
                  if (width > 800) {
                    crossAxisCount = 4;
                  } else if (width > 600) {
                    crossAxisCount = 3;
                  }

                  return GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                    ),
                    itemCount: activeImages.length,
                    itemBuilder: (context, idx) {
                      final item = activeImages[idx];

                      return Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              color: Colors.grey.shade200,
                              child: Image.memory(
                                item.bytes,
                                fit: BoxFit.contain,
                                width: double.infinity,
                                height: double.infinity,
                              ),
                            ),
                          ),
                          Positioned(
                            top: 4,
                            right: 4,
                            child: InkWell(
                              onTap: () => _removeImage(_images
                                  .indexWhere((img) => img.name == item.name)),
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: Colors.black45,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.delete,
                                  size: 20,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

/// Model for stored image data
class StoredImage {
  final String name;
  final Uint8List bytes;
  bool saved;
  bool deleted;

  StoredImage({
    required this.name,
    required this.bytes,
    this.saved = false,
    this.deleted = false,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'bytes': bytes,
        'saved': saved,
        'deleted': deleted,
      };

  factory StoredImage.fromJson(Map<dynamic, dynamic> json) {
    return StoredImage(
      name: json['name'] as String,
      bytes: json['bytes'] as Uint8List,
      saved: json['saved'] as bool? ?? false,
      deleted: json['deleted'] as bool? ?? false,
    );
  }
}
