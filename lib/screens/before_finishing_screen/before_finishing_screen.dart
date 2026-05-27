import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../main_screen/main_screen.dart';
import '../../utility/mindblooming_color_scheme.dart';
import '../../utility/mindblooming_text_style.dart';
import '../../widgets/mindblooming_button.dart';
import '../../widgets/plant_swiper.dart';
import './testo_compagno.dart';

class BeforeFinishingScreen extends StatelessWidget {
  const BeforeFinishingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MindBloomingColorScheme.primary,
      body: CustomScrollView(
        slivers: [
          const SliverPadding(
            padding: const EdgeInsets.only(top: 20),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 30,
              ),
              child: TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  minimumSize: Size.zero,
                ),
                child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 10.0),
                      child: SvgPicture.asset(
                        "assets/icon_left_arrow.svg",
                        colorFilter: const ColorFilter.mode(
                          MindBloomingColorScheme.textColorDark,
                          BlendMode.srcATop,
                        ),
                      ),
                    ),
                    Text(
                      "Indietro",
                      style: MindBloomingTextStyle.pretitle.copyWith(
                        color: MindBloomingColorScheme.textColorDark,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SliverPadding(
            padding: const EdgeInsets.only(top: 20),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 30,
              ),
              child: Text(
                "Prima di iniziare...",
                style: MindBloomingTextStyle.header1,
              ),
            ),
          ),
          const SliverPadding(
            padding: const EdgeInsets.only(top: 15),
          ),
          // ...testoNotifiche,
          // const SliverPadding(
          //   padding: const EdgeInsets.only(top: 25),
          // ),
          // const SliverToBoxAdapter(
          //   child: Row(
          //     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          //     children: [
          //       const CustomTimePicker(),
          //     ],
          //   ),
          // ),
          const SliverPadding(
            padding: const EdgeInsets.only(top: 30),
          ),
          ...testoCompagno,
          const SliverPadding(
            padding: const EdgeInsets.only(top: 20),
          ),
          const SliverToBoxAdapter(
            child: PlantSwiper(),
          ),
          const SliverPadding(
            padding: const EdgeInsets.only(top: 10),
          ),
          SliverFillRemaining(
            hasScrollBody: false,
            fillOverscroll: true,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(
                  bottom: 20,
                  left: 30,
                  right: 30,
                ),
                child: MindBloomingButton(
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (ctx) => const MainScreen()),
                      (route) => false,
                    );
                  },
                  child: Text(
                    "CONFERMA",
                    style: MindBloomingTextStyle.button,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
