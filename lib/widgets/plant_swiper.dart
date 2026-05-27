import 'package:card_swiper/card_swiper.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rive/rive.dart';
import 'package:sizer/sizer.dart';

import '../providers/user_settings.dart';
import '../utility/mindblooming_color_scheme.dart';
import '../utility/mindblooming_text_style.dart';

class PlantSwiper extends StatefulWidget {
  const PlantSwiper({super.key});

  @override
  State<PlantSwiper> createState() => _PlantSwiperState();
}

class _PlantSwiperState extends State<PlantSwiper> {
  final controller = SwiperController();

  List<SMIInput<bool>?> smi = [];
  List<Artboard> artboards = [];

  Future<void> initArtboard() async {
    final file = await RiveFile.asset("assets/plants.riv");

    for (var artboard in file.artboards) {
      SMIInput<bool>? input;

      final controller = StateMachineController.fromArtboard(
        artboard,
        "SM",
      );

      if (controller != null) {
        artboard.addController(controller);
        input = controller.findInput<bool>("selected");
        smi.add(input);

        artboards.add(artboard);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final sProvider = Provider.of<UserSettings>(context, listen: false);

    return Column(
      children: [
        ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: 16.h,
            maxWidth: double.infinity,
          ),
          child: FutureBuilder(
            future: initArtboard(),
            builder: (context, snapshot) =>
                snapshot.connectionState == ConnectionState.done
                    ? Swiper(
                        controller: controller,
                        index: int.parse(sProvider.selectedPlant),
                        loop: true,
                        viewportFraction: 0.4,
                        scale: 0.3,
                        itemCount: 4,
                        itemBuilder: (context, index) {
                          if (smi[index] != null) {
                            smi[index]!.value =
                                sProvider.selectedPlant == "$index";
                          }

                          return Rive(
                            artboard: artboards[index],
                            fit: BoxFit.contain,
                          );
                        },
                        onIndexChanged: (value) {
                          sProvider.setPlant("$value");
                        },
                        onTap: (index) {
                          final int saved = int.parse(sProvider.selectedPlant);
                          if (index != saved) {
                            if (index == (saved - 1) % 4) {
                              controller.previous();
                            } else {
                              controller.next();
                            }
                          }
                        },
                      )
                    : const Padding(
                        padding: EdgeInsets.symmetric(vertical: 75),
                        child: CircularProgressIndicator(
                          color: MindBloomingColorScheme.tertiary,
                        ),
                      ),
          ),
        ),
        const SizedBox(
          height: 10,
        ),
        Text(
          "Luis",
          style: MindBloomingTextStyle.header3,
        ),
      ],
    );
  }
}
