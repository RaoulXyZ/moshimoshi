import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../../../utility/mindblooming_color_scheme.dart';
import '../../../../utility/mindblooming_text_style.dart';
import '../../../../widgets/plant_swiper.dart';

class Generali extends StatelessWidget {
  const Generali({super.key});

  @override
  Widget build(BuildContext context) {
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
                "Generali",
                style: MindBloomingTextStyle.header1,
              ),
            ),
            const SizedBox(height: 30),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                "Compagno di viaggio",
                style: MindBloomingTextStyle.header3,
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                "Seleziona il compagno di viaggio che preferisci avere al tuo fianco in questo percorso!",
                style: MindBloomingTextStyle.normal,
              ),
            ),
            const SizedBox(height: 30),
            const PlantSwiper(),
          ],
        ),
      ),
    );
  }
}
