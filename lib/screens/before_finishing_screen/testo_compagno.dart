import 'package:flutter/material.dart';

import '../../utility/mindblooming_text_style.dart';

List<Widget> get testoCompagno => [
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Text(
            "Compagno di viaggio",
            style: MindBloomingTextStyle.header3,
          ),
        ),
      ),
      const SliverPadding(
        padding: const EdgeInsets.only(top: 15),
      ),
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Text(
            "Seleziona il compagno di viaggio che preferisci avere al tuo fianco in questo percorso!",
            style: MindBloomingTextStyle.normal,
          ),
        ),
      ),
    ];
