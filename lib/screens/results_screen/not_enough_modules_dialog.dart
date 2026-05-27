import 'dart:ui';

import 'package:flutter/material.dart';

import '../../utility/mindblooming_color_scheme.dart';
import '../../utility/mindblooming_text_style.dart';
import '../../widgets/mindblooming_button.dart';

class NotEnoughModulesDialog extends StatelessWidget {
  const NotEnoughModulesDialog({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
      child: AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        backgroundColor: MindBloomingColorScheme.tertiary1shadow,
        title: Row(
          children: [
            Text(
              "Attenzione!",
              style: MindBloomingTextStyle.header3,
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Per poter proseguire devi aver selezionato il modulo personalizzato",
              style: MindBloomingTextStyle.normal,
            ),
            const SizedBox(height: 20),
            MindBloomingButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text("OK", style: MindBloomingTextStyle.button),
            ),
          ],
        ),
      ),
    );
  }
}
