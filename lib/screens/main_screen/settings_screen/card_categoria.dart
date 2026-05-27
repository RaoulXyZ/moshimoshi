import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../utility/mindblooming_color_scheme.dart';
import '../../../utility/mindblooming_text_style.dart';

class CardCategoria extends StatelessWidget {
  const CardCategoria({
    super.key,
    required this.title,
    required this.onTap,
    this.subtitle,
  });

  final String title;
  final String? subtitle;
  final void Function() onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 30),
      width: double.infinity,
      decoration: BoxDecoration(
        color: MindBloomingColorScheme.primary1shadow,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: MindBloomingColorScheme.primary3shadow,
          width: 0.5,
        ),
      ),

      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          splashColor: MindBloomingColorScheme.primary3shadow,
          highlightColor: Colors.transparent,
          borderRadius: BorderRadius.circular(20),

          child: Row(
            children: [
              const SizedBox(width: 15),
              
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: subtitle == null ? 22 : 13),
                  Text(
                    title,
                    style: MindBloomingTextStyle.subtitle,
                  ),
                  if (subtitle != null) ...{
                    const SizedBox(height: 4),
                    Text(
                      subtitle!,
                      style: MindBloomingTextStyle.small,
                    ),
                  },
                  SizedBox(height: subtitle == null ? 22 : 13),
                ],
              ),
              const Spacer(),
              Material(
                shape: const CircleBorder(),
                color: Colors.transparent,
                child: InkWell(
                  onTap: onTap,
                  borderRadius: BorderRadius.circular(200),
                  splashColor: MindBloomingColorScheme.primary3shadow,
                  highlightColor: Colors.transparent,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    child: SvgPicture.asset("assets/icon_right_arrow.svg"),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
