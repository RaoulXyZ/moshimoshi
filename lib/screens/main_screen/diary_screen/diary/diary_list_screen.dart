import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';

import '../../../../login/widget/toast.dart';
import '../../../../providers/moduli.dart';
import '../../../../utility/local_user.dart';
import '../../../../utility/mindblooming_color_scheme.dart';
import '../../../../utility/mindblooming_text_style.dart';
import '../../../../models/exercise.dart';
import 'edit_diary.dart';
import 'save_diary.dart';

class DiaryListScreen extends StatelessWidget {
  DiaryListScreen({
    super.key,
    required this.exercise,
    required this.personal,
  });

  final Exercise exercise;
  final bool personal;

  void showAlert(QuickAlertType quickAlertType) {
    QuickAlert.show(
      context: Get.context!,
      type: quickAlertType,
    );
  }

  final searchName = "";
  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final mp = Provider.of<Moduli>(context);
    final diaryType = personal
        ? "Diario Personale"
        : mp.prettyName[exercise.modulo] ?? exercise.modulo;
    final currentUid = LocalUser.currentUid();

    return Scaffold(
      appBar: AppBar(
        title: Column(
          children: [
            Text(
              personal
                  ? 'Diario Personale'
                  : 'Diario ' + mp.prettyName[exercise.modulo]!,
              style: MindBloomingTextStyle.header2,
            ),
          ],
        ),
        backgroundColor: Colors.white,
        centerTitle: true,
        elevation: 1,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 25, top: 25, right: 25),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                (context as Element).markNeedsBuild();
              },
              decoration: const InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: 'Cerca il Titolo di una Nota...',
                border: const OutlineInputBorder(
                  borderRadius:
                      const BorderRadius.all(const Radius.circular(20)),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 10,
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: 25,
                vertical: 20,
              ),
              decoration: BoxDecoration(
                color: MindBloomingColorScheme.tertiary,
                borderRadius: BorderRadius.circular(20),
              ),
              child: ValueListenableBuilder<Box>(
                valueListenable: Hive.box('diary').listenable(),
                builder: (context, box, _) {
                  final search = _searchController.text;
                  final notes = box.keys.map((k) {
                    final raw = box.get(k);
                    if (raw is! Map) return null;

                    return Map<String, dynamic>.from(raw);
                  }).whereType<Map<String, dynamic>>().where((n) {
                    if (n['userId'] != currentUid) return false;
                    if (n['diaryType'] != diaryType) return false;
                    if (search.isEmpty) return true;
                    final title = (n['title'] ?? '').toString();

                    return title.compareTo(search) >= 0 &&
                        title.compareTo(search + 'z') < 0;
                  }).toList()
                    ..sort((a, b) => (b['title'] ?? '')
                        .toString()
                        .compareTo((a['title'] ?? '').toString()));

                  if (notes.isEmpty) {
                    return Center(
                      child: Text(
                        'Nessuna Nota presente nel Diario.',
                        style: MindBloomingTextStyle.header3,
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: notes.length,
                    itemBuilder: (context, index) {
                      final note = notes[index];
                      final title = note['title'] ?? 'Senza titolo';
                      final content = note['content'] ?? 'Nessun contenuto';
                      final userId = note['userId'];
                      final diaryId = note['diaryId']?.toString() ?? '';
                      final rawDate = note['date'];
                      final date = rawDate is DateTime
                          ? rawDate
                          : DateTime.now();

                      return Padding(
                        padding:
                            const EdgeInsets.only(left: 25, top: 25, right: 25),
                        child: Card(
                          child: ListTile(
                            leading: Column(
                              children: [
                                Text(
                                  DateFormat('MMMd').format(date).toUpperCase(),
                                  style: MindBloomingTextStyle.dateFont,
                                ),
                                Text(
                                  DateFormat('y').format(date),
                                  style: MindBloomingTextStyle.dateFont,
                                ),
                              ],
                            ),
                            title: Text(
                              title,
                              maxLines: 1,
                              style: MindBloomingTextStyle.header3,
                            ),
                            subtitle: Text(
                              content,
                              maxLines: 2,
                              style: MindBloomingTextStyle.normal,
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    try {
                                      Get.to(
                                        () => const EditDiary(),
                                        arguments: {
                                          'title': title,
                                          'content': content,
                                          'userId': userId,
                                          'diaryId': diaryId,
                                        },
                                      );
                                    } catch (e) {
                                      if (kDebugMode) {
                                        print(e);
                                      }
                                    }
                                  },
                                  child: const Icon(Icons.edit),
                                ),
                                const SizedBox(width: 10),
                                GestureDetector(
                                  onTap: () {
                                    QuickAlert.show(
                                      context: context,
                                      type: QuickAlertType.error,
                                      showCancelBtn: true,
                                      title: 'Elimina Nota',
                                      text:
                                          'Sei sicuro di voler eliminare questa nota?',
                                      confirmBtnText: 'Elimina',
                                      confirmBtnColor: Colors.red,
                                      cancelBtnText: 'Annulla',
                                      onConfirmBtnTap: () {
                                        Hive.box('diary').delete(diaryId);
                                        Navigator.pop(context);
                                        showToast(
                                          message:
                                              "Nota eliminata con successo.",
                                        );
                                      },
                                    );
                                  },
                                  child: const Icon(Icons.delete),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: MindBloomingColorScheme.secondary,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => SaveDiary(
                exercise: exercise,
                personal: personal,
              ),
            ),
          );
        },
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
    );
  }
}

class DiaryModel {
  final String? title;
  final String? userId;
  final String? diaryId;
  final String? diaryType;

  DiaryModel({
    this.userId,
    this.diaryType,
    this.diaryId,
    this.title,
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'userId': userId,
      'diaryId': diaryId,
      'diaryType': diaryType,
    };
  }
}
