import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

import '../../models/exercise.dart';
import '../../providers/moduli.dart';
import '../../utility/mindblooming_color_scheme.dart';
import '../../utility/mindblooming_text_style.dart';

class Header extends StatelessWidget {
  const Header({
    super.key,
    required this.exercise,
  });

  final Exercise exercise;

  @override
  Widget build(BuildContext context) {
    final mProvider = Provider.of<Moduli>(context);

    return Stack(
      children: [
        Container(
          width: double.infinity,
          decoration: const BoxDecoration(
            color: MindBloomingColorScheme.secondary1shadow,
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(30),
              bottomRight: Radius.circular(30),
            ),
          ),
          height: 30.h,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Align(
                alignment: Alignment.bottomRight,
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    bottomRight: Radius.circular(30),
                  ),
                  child: SvgPicture.asset(
                    "assets/pic_${exercise.modulo}.svg",
                    height: 25.h,
                  ),
                ),
              ),
            ],
          ),
        ),
        Container(
          height: 30.h,
          width: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              stops: const [0, 0.6, 1],
              colors: [
                Colors.transparent,
                const Color.fromRGBO(11, 50, 44, 0.25),
                const Color.fromRGBO(11, 50, 44, 0.8),
              ],
            ),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(30),
              bottomRight: Radius.circular(30),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              InkWell(
                onTap: () {
                  Navigator.of(context).pop();
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(width: 20),
                    Row(
                      children: [
                        SvgPicture.asset(
                          "assets/icon_left_arrow.svg",
                          colorFilter: const ColorFilter.mode(
                            MindBloomingColorScheme.textColorDark,
                            BlendMode.srcATop,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          "Torna al Percorso",
                          style: MindBloomingTextStyle.pretitle,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Text(
                  mProvider.prettyName[exercise.modulo] ??
                      "Modulo ${exercise.modulo}",
                  style: MindBloomingTextStyle.header1.copyWith(
                    color: MindBloomingColorScheme.textColorLight,
                  ),
                ),
              ),
              const SizedBox(height: 15),
            ],
          ),
        ),
      ],
    );
  }
}
