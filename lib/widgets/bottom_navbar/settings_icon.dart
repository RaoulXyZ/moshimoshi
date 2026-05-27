import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:sizer/sizer.dart';

import '../../utility/mindblooming_color_scheme.dart';
import '../../utility/mindblooming_text_style.dart';

class SettingsIcon extends StatelessWidget {
  const SettingsIcon({super.key, required this.active, required this.onTap});

  final bool active;
  final void Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 20.w,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Material(
            color: Colors.transparent,
            shape: const CircleBorder(),
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(50),
              splashColor: MindBloomingColorScheme.secondary
                ..withValues(alpha: 0.5),
              overlayColor: WidgetStateProperty.all(
                MindBloomingColorScheme.secondary.withValues(alpha: 0.25),
              ),
              child: SvgPicture.asset(
                // active
                //     ? "assets/navbar_settings_active.svg"
                //     :
                "assets/navbar_settings.svg",
                width: 40,
                colorFilter: ColorFilter.mode(
                  active
                      ? MindBloomingColorScheme.secondary
                      : MindBloomingColorScheme.textColorDark1shadow,
                  BlendMode.srcIn,
                ),
              ),
            ),
          ),
          Text(
            "Impostazioni",
            style: MindBloomingTextStyle.bottomNavbar.copyWith(
              color: active
                  ? MindBloomingColorScheme.secondary
                  : MindBloomingColorScheme.textColorDark1shadow,
            ),
          ),
        ],
      ),
    );
  }
}
