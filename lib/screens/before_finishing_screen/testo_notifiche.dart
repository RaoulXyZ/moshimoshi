import 'package:flutter/material.dart';

import '../../utility/mindblooming_text_style.dart';

List<Widget> get testoNotifiche => [
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Text(
            "Notifiche",
            style: MindBloomingTextStyle.header3,
          ),
        ),
      ),
      const SliverPadding(
        padding: EdgeInsets.only(top: 15),
      ),
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: RichText(
            text: TextSpan(
              style: MindBloomingTextStyle.normal,
              children: [
                TextSpan(
                  text:
                      "Scegli un orario in cui ricevere una notifica che ti ricordi di dedicarti a questo percorso, in modo da stabilire un momento della giornata fisso in cui sai di avere il tempo e le energie per farlo.",
                  style: MindBloomingTextStyle.normal,
                ),
              ],
            ),
          ),
        ),
      ),
    ];
