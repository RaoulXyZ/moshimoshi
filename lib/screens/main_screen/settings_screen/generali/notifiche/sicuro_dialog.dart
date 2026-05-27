import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sizer/sizer.dart';

import '../../../../../widgets/mindblooming_button.dart';
import '../../../../../utility/mindblooming_color_scheme.dart';
import '../../../../../utility/mindblooming_text_style.dart';

class SicuroDialog extends StatelessWidget {
  const SicuroDialog({
    super.key,
    required this.conferma,
  });

  final Function conferma;

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
      child: SimpleDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        backgroundColor: MindBloomingColorScheme.tertiary1shadow,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Sei sicuro?",
                style: MindBloomingTextStyle.header2,
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 10),
                Center(child: SvgPicture.asset("assets/plant_sad.svg")),
                const SizedBox(height: 10),
                Text(
                  "Le notifiche sono molto importanti affinché tu possa completare il percorso.\nPer noi è fondamentale ricordarti ogni giorno che siamo al tuo fianco!",
                  style: MindBloomingTextStyle.pretitle,
                ),
                Text(
                  "Vuoi ancora disattivarle?",
                  style: MindBloomingTextStyle.pretitle.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      width: 30.w,
                      child: MindBloomingButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text("ANNULLA"),
                      ),
                    ),
                    SizedBox(
                      width: 30.w,
                      child: MindBloomingButton(
                        onPressed: () {
                          conferma();
                          Navigator.of(context).pop();
                        },
                        child: const Text("CONFERMA"),
                        backgroundColor: MindBloomingColorScheme.primary3shadow,
                        borderColor: MindBloomingColorScheme.dialogBg,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
