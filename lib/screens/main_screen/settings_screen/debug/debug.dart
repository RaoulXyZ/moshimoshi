import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import '../../../../providers/answers.dart';
import '../../../../providers/questions.dart';
import '../../../../utility/mindblooming_color_scheme.dart';
import '../../../../utility/mindblooming_text_style.dart';
import '../../../../widgets/mindblooming_button.dart';

class Debug extends StatelessWidget {
  const Debug({super.key});

  @override
  Widget build(BuildContext context) {
    final qProvider = Provider.of<Questions>(context);
    final aProvider = Provider.of<Answers>(context);

    return Scaffold(
      backgroundColor: MindBloomingColorScheme.primary,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            Row(
              children: [
                const SizedBox(width: 20),
                InkWell(
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  onTap: () => Navigator.of(context).pop(),
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Row(
                      children: [
                        SvgPicture.asset(
                          'assets/icon_left_arrow.svg',
                          colorFilter: const ColorFilter.mode(
                            MindBloomingColorScheme.textColorDark,
                            BlendMode.srcATop,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          "Indietro",
                          style: MindBloomingTextStyle.pretitle,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Text(
                "Debug",
                style: MindBloomingTextStyle.header1,
              ),
            ),
            const SizedBox(height: 30),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Text(
                "Esporta risposte",
                style: MindBloomingTextStyle.header3,
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Text(
                "Esporta le tue risposte in un file JSON locale nella cartella Downloads.",
                style: MindBloomingTextStyle.normal,
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: MindBloomingButton(
                onPressed: () async {
                  await Permission.storage.request();
                  final Map<String, dynamic> ans = aProvider.answers;
                  final Directory? dir = Platform.isAndroid
                      ? await getExternalStorageDirectory()
                      : await getApplicationDocumentsDirectory();
                  if (dir == null) return;
                  final file = File('${dir.path}/Risposte.json');
                  await file.writeAsString(json.encode(ans));
                },
                child: Text(
                  "ESPORTA RISPOSTE",
                  style: MindBloomingTextStyle.button,
                ),
              ),
            ),
            const SizedBox(height: 50),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Text(
                "Reset domande",
                style: MindBloomingTextStyle.header3,
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Text(
                "Cancella le domande salvate localmente, forzando l'applicazione a scaricarle nuovamente al prossimo avvio. Le rispsote NON verranno cancellate.",
                style: MindBloomingTextStyle.normal,
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: MindBloomingButton(
                onPressed: () async {
                  await qProvider.removeFromLocal();
                  SystemNavigator.pop();
                },
                child: Text(
                  "RESET DOMANDE",
                  style: MindBloomingTextStyle.button,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
