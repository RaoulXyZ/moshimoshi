import 'package:flutter/material.dart';
import '../../../utility/mindblooming_text_style.dart';

class IlTuoPercorso extends StatelessWidget {
  const IlTuoPercorso({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Row(
        children: [
          Expanded(
            child: Text(
              "Il tuo percorso",
              style: MindBloomingTextStyle.header2,
            ),
          ),
        ],
      ),
    );
  }
}
