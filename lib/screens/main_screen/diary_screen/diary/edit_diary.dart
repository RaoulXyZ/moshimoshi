import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';

import '../../../../login/widget/toast.dart';
import '../../../../utility/mindblooming_text_style.dart';
import '../../../../widgets/mindblooming_button.dart';

class EditDiary extends StatefulWidget {
  const EditDiary({Key? key}) : super(key: key);

  @override
  State<EditDiary> createState() => _EditDiary();
}

class _EditDiary extends State<EditDiary> {
  TextEditingController _titleController = TextEditingController();
  TextEditingController _contentController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Modifica Nota', style: MindBloomingTextStyle.header2),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 1,
      ),
      body: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          children: [
            TextFormField(
              controller: _titleController
                ..text = "${Get.arguments['title'].toString()}",
              maxLength: 50,
              decoration: InputDecoration(
                hintText: 'Titolo...',
                labelText: 'Titolo',
                prefixIcon: const Icon(Icons.title),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: TextFormField(
                maxLength: 3000,
                controller: _contentController
                  ..text = "${Get.arguments['content']?.toString() ?? ''}",
                keyboardType: TextInputType.multiline,
                maxLines: null,
                textAlign: TextAlign.start,
                decoration: InputDecoration(
                  hintText: 'Inizia a scrivere qui...',
                  hintStyle: MindBloomingTextStyle.normal,
                  labelText: 'Inizia a scrivere qui',
                  labelStyle: MindBloomingTextStyle.normal,
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomSheet: Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        child: MindBloomingButton(
          onPressed: () async {
            final title = _titleController.text.trim();
            final content = _contentController.text.trim();

            if (title.isNotEmpty && content.isNotEmpty) {
              try {
                final diaryId = Get.arguments['diaryId'].toString();
                final box = Hive.box('diary');
                final existing = box.get(diaryId);
                final existingMap = existing is Map
                    ? Map<String, dynamic>.from(existing)
                    : <String, dynamic>{};
                await box.put(diaryId, {
                  ...existingMap,
                  "title": title,
                  "content": content,
                  "date": DateTime.now(),
                });
                showToast(message: "Nota modificata con successo.");
              } catch (e) {
                // ignore: avoid_print
                print(e.toString());
              }
            } else {
              showToast(message: "Errore\nCompila tutti i campi.");
            }
          },
          child: const Text('SALVA'),
        ),
      ),
    );
  }
}
