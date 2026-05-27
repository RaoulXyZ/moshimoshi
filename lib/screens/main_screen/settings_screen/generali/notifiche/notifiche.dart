import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../../../../utility/mindblooming_color_scheme.dart';
import '../../../../../utility/mindblooming_text_style.dart';
import 'notifiche_giornaliere.dart';
import 'notifiche_lezioni.dart';
import 'notifiche_settimanali.dart';

class Notifiche extends StatefulWidget {
  const Notifiche({super.key});

  @override
  State<Notifiche> createState() => _NotificheState();
}

class _NotificheState extends State<Notifiche> {
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
                "Notifiche",
                style: MindBloomingTextStyle.header1,
              ),
            ),
            const SizedBox(height: 30),
            const NotificheGiornaliere(),
            const SizedBox(height: 40),
            const NotificheSettimanali(),
            const SizedBox(height: 40),
            const NotificheLezioni(),
          ],
        ),
      ),
    );
  }
}
