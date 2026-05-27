import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../widgets/mindblooming_button.dart';
import '../../providers/moduli.dart';
import '../../utility/mindblooming_color_scheme.dart';
import '../../utility/mindblooming_text_style.dart';

class FixedDialog extends StatelessWidget {
  const FixedDialog({
    super.key,
    required this.patologia,
  });

  final String patologia;

  @override
  Widget build(BuildContext context) {
    final mProvider = Provider.of<Moduli>(context);

    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
      child: AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        backgroundColor: MindBloomingColorScheme.tertiary1shadow,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              mProvider.prettyName[patologia] ?? '',
              style: MindBloomingTextStyle.header3,
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RichText(
              text: TextSpan(
                style: MindBloomingTextStyle.normal,
                children: [
                  const TextSpan(
                    text:
                        "Questo modulo è obbligatorio, non può essere rimosso.",
                  ),
                ],
              ),
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
