import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:sizer/sizer.dart';

import '../../../../utility/mindblooming_color_scheme.dart';
import '../../../../utility/mindblooming_text_style.dart';
import '../../../../widgets/mindblooming_button.dart';
import '../../../on_board.dart';

class Tutorial extends StatelessWidget {
  const Tutorial({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width > 600;
    // Calcola dimensioni fisse per mobile (no scroll)
    final imageHeight = isDesktop ? 35.h : 25.h;
    final topTextHeight = isDesktop ? null : size.height * 0.2;

    return Scaffold(
      backgroundColor: MindBloomingColorScheme.primary,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Back button
            Padding(
              padding: const EdgeInsets.only(top: 10, left: 20),
              child: InkWell(
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                onTap: () => Navigator.of(context).pop(),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
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
            const SizedBox(height: 20),
            // Titolo e descrizione
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Text(
                "Tutorial",
                style: MindBloomingTextStyle.header1,
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: SizedBox(
                height: topTextHeight,
                child: Text(
                  "Ti sei persa/o qualche passaggio? Non preoccuparti! Riguarda il tutorial iniziale per toglierti ogni dubbio ed avere sempre bene a mente quali saranno gli step del nostro percorso insieme.",
                  style: MindBloomingTextStyle.subtitle,
                ),
              ),
            ),
            const Spacer(),
            // Immagine
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: SvgPicture.asset(
                  "assets/plant_curious.svg",
                  height: imageHeight,
                ),
              ),
            ),
            const Spacer(),
            // Pulsante INIZIA
            Padding(
              padding: const EdgeInsets.all(30),
              child: MindBloomingButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const OnBoard(
                        fromSettings: true,
                      ),
                    ),
                  );
                },
                child: Text(
                  "INIZIA",
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
