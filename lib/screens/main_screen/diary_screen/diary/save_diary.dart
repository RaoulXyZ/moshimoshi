import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../../../../login/widget/toast.dart';
import '../../../../models/exercise.dart';
import '../../../../providers/moduli.dart';
import '../../../../utility/local_user.dart';
import '../../../../utility/mindblooming_text_style.dart';
import '../../../../widgets/mindblooming_button.dart';

class SaveDiary extends StatelessWidget {
  SaveDiary({
    super.key,
    required this.exercise,
    required this.personal,
  });

  final Exercise exercise;
  final bool personal;

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  final String? userId = LocalUser.currentUid();

  @override
  Widget build(BuildContext context) {
    final mp = Provider.of<Moduli>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Nuova Nota', style: MindBloomingTextStyle.header2),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 1,
      ),
      body: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          children: [
            TextFormField(
              controller: _titleController,
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
                controller: _contentController,
                keyboardType: TextInputType.multiline,
                maxLength: 3000,
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
                final diaryType = personal
                    ? "Diario Personale"
                    : mp.prettyName[exercise.modulo] ?? exercise.modulo;
                final box = Hive.box('diary');
                final diaryId = const Uuid().v4();
                await box.put(diaryId, {
                  "title": title,
                  "content": content,
                  "date": DateTime.now(),
                  "userId": userId,
                  "diaryId": diaryId,
                  "diaryType": diaryType,
                });
                showToast(message: "Nota salvata con successo.");
                if (context.mounted) Navigator.pop(context);
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
