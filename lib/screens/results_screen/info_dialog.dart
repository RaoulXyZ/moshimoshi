import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

import '../../providers/moduli.dart';
import '../../utility/mindblooming_color_scheme.dart';
import '../../utility/mindblooming_text_style.dart';

class InfoDialog extends StatelessWidget {
  const InfoDialog({
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
              style: MindBloomingTextStyle.subtitle,
            ),
            InkWell(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: SvgPicture.asset(
                  "assets/icon_close.svg",
                  height: 3.sp,
                ),
              ),
              onTap: () => Navigator.of(context).pop(),
              customBorder: const CircleBorder(),
            ),
          ],
        ),
        content: Builder(
          builder: (context) {
            final desc =
                mProvider.descrizioni[patologia] as Map<String, dynamic>;

            return RichText(
              text: TextSpan(
                style:
                    MindBloomingTextStyle.small.copyWith(color: Colors.black),
                children: [
                  if (desc["intro"] != null)
                    TextSpan(text: desc["intro"] + "\n\n"),
                  if (desc["percorso"] != null)
                    TextSpan(
                      text: desc["percorso"] + "\n",
                      style: MindBloomingTextStyle.small
                          .copyWith(fontWeight: FontWeight.bold),
                    ),
                  if (desc["desc_percorso"] != null)
                    TextSpan(text: desc["desc_percorso"] + "\n\n"),
                  if (desc["settimane"] != null)
                    ...List.generate(
                      desc["settimane"].length,
                      (i) => [
                        TextSpan(
                          text: desc["settimane"][i]["titolo"] + "\n",
                          style: MindBloomingTextStyle.small.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextSpan(
                          text: desc["settimane"][i]["testo"] + "\n\n",
                        ),
                      ],
                    ).expand((x) => x),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
