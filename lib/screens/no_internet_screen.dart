import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../main.dart';
import '../utility/mindblooming_color_scheme.dart';
import '../utility/mindblooming_text_style.dart';
import '../widgets/mindblooming_button.dart';

class NoInternetScreen extends StatelessWidget {
  const NoInternetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 60.w,
                        height: 30.h,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: MindBloomingColorScheme.secondary,
                        ),
                        child: const Icon(
                          Icons.cloud_off,
                          size: 200,
                          color: MindBloomingColorScheme.secondary3shadow,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  children: [
                    Text(
                      "Whoops",
                      style: MindBloomingTextStyle.header1.copyWith(
                        color: MindBloomingColorScheme.shadow,
                      ),
                    ),
                    Text(
                      "Sembra che tu non sia connesso a Internet",
                      style: MindBloomingTextStyle.subtitle,
                      textAlign: TextAlign.center,
                    ),
                    Text(
                      "Per favore controlla la tua connessione e riprova.",
                      style: MindBloomingTextStyle.subtitle,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ],
            ),
            MindBloomingButton(
              onPressed: () {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                    builder: (context) => const Main(),
                  ),
                  (route) => false,
                );
              },
              child: Text(
                "RIPROVA",
                style: MindBloomingTextStyle.button,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
