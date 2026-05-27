import 'package:flutter/material.dart';
import 'package:chart_sparkline/chart_sparkline.dart';

import '../../../../providers/moduli.dart';
import '../../../../providers/progress.dart';
import '../../../../utility/mindblooming_color_scheme.dart';
import '../../../../utility/mindblooming_text_style.dart';

class Grafico extends StatelessWidget {
  const Grafico({
    super.key,
    required this.pp,
    required this.mp,
  });

  final Progress pp;
  final Moduli mp;

  @override
  Widget build(BuildContext context) {
    final txtStl = MindBloomingTextStyle.small.copyWith(
      color: MindBloomingColorScheme.textColorDark1shadow,
    );
    final moduli = mp.moduli.keys;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Text(
            "Il grafico mostra, sulla base del tuo percorso svolto insieme a noi, i tuoi livelli di ansia e depressione giornalieri.",
            style: MindBloomingTextStyle.small,
          ),
        ),
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  Row(
                    children: [
                      RotatedBox(
                        quarterTurns: -1,
                        child: Text(
                          "Scala",
                          style: txtStl,
                        ),
                      ),
                      SizedBox(
                        height: 140,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 8.0,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "10",
                                style: txtStl,
                              ),
                              Text(
                                "5",
                                style: txtStl,
                              ),
                              Text(
                                "1",
                                style: txtStl,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(width: 5),
              Expanded(
                child: Column(
                  children: [
                    ClipRRect(
                      child: Container(
                        decoration: BoxDecoration(
                          color: MindBloomingColorScheme.primary,
                          borderRadius: BorderRadius.circular(5),
                          border: Border.all(
                            color: MindBloomingColorScheme.textColorDark1shadow,
                            width: 1,
                          ),
                        ),
                        height: 140,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Stack(
                            children: [
                              Sparkline(
                                data: pp.dailym1
                                    .map((e) => e.toDouble())
                                    .toList(),
                                pointsMode: PointsMode.all,
                                lineWidth: 0,
                                pointSize: 4.0, // Dimensione del pallino
                                pointColor: MindBloomingColorScheme.secondary,
                                lineColor: Colors.transparent,
                                max: 10,
                                min: 0.7,
                              ),
                              Sparkline(
                                data: pp.dailym2
                                    .map((e) => e.toDouble())
                                    .toList(),
                                pointsMode: PointsMode.all,
                                lineColor: Colors.transparent,
                                lineWidth: 0,

                                pointSize: 4.0, // Dimensione del pallino
                                pointColor: MindBloomingColorScheme.tertiary,
                                max: 10,
                                min: 0.7,
                              ),
                              // Sparkline(
                              //   data: pp.dailyDiffRel
                              //       .map((e) => e.toDouble())
                              //       .toList(),
                              //   lineWidth: 3,
                              //   lineColor: const Color(0xFF4469b4),
                              //   max: 10,
                              //   min: 0.7,
                              // ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8.0,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          for (int i = 0; i <= 7; i++) ...{
                            Text(
                              "$i",
                              style: txtStl,
                            ),
                          },
                        ],
                      ),
                    ),
                    Text(
                      "Settimana",
                      style: txtStl,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          runSpacing: 10,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  height: 10,
                  width: 10,
                  decoration: BoxDecoration(
                    color: MindBloomingColorScheme.tertiary,
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                const SizedBox(width: 5),
                Text(
                  mp.getPrettyName(moduli.last),
                  style: MindBloomingTextStyle.small,
                ),
                const SizedBox(width: 20),
              ],
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  height: 10,
                  width: 10,
                  decoration: BoxDecoration(
                    color: MindBloomingColorScheme.secondary,
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                const SizedBox(width: 5),
                Text(
                  mp.getPrettyName(moduli.first),
                  style: MindBloomingTextStyle.small,
                ),
                const SizedBox(width: 20),
              ],
            ),
            // Row(
            //   mainAxisSize: MainAxisSize.min,
            //   children: [
            //     Container(
            //       height: 10,
            //       width: 10,
            //       decoration: BoxDecoration(
            //         color: const Color(0xFF4469b4),
            //         borderRadius: BorderRadius.circular(20),
            //       ),
            //     ),
            //     const SizedBox(width: 5),
            //     Text(
            //       mp.getPrettyName("difficoltarelazionali"),
            //       style: MindBloomingTextStyle.small,
            //     ),
            //   ],
            // ),
          ],
        ),
        const SizedBox(
          height: 20,
        ),
      ],
    );
  }
}
