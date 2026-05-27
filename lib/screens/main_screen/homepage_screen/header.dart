import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:rive/rive.dart';
import 'package:sizer/sizer.dart';

import '../../../providers/user_settings.dart';
import '../../../utility/mindblooming_color_scheme.dart';
import '../../../utility/mindblooming_text_style.dart';

class Header extends StatelessWidget {
  const Header({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(
            top: 20,
            left: 30,
            right: 30,
          ),
          child: Text("Bentornata/o!", style: MindBloomingTextStyle.header1),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text.rich(
                      TextSpan(
                        children: [
                          WidgetSpan(
                            alignment: PlaceholderAlignment.aboveBaseline,
                            baseline: TextBaseline.alphabetic,
                            child: Transform.translate(
                              offset: const Offset(0, -20),
                              child: SvgPicture.asset(
                                'assets/quote.svg',
                                width: 12,
                                height: 12,
                              ),
                            ),
                          ),
                          const WidgetSpan(child: SizedBox(width: 4)),
                          TextSpan(
                            text:
                                "Un viaggio di mille miglia comincia sempre con un primo passo.",
                            style: MindBloomingTextStyle.quoteHomePage,
                          ),
                          const WidgetSpan(child: SizedBox(width: 4)),
                          WidgetSpan(
                            alignment: PlaceholderAlignment.belowBaseline,
                            baseline: TextBaseline.alphabetic,
                            child: SvgPicture.asset(
                              'assets/quote-close.svg',
                              width: 12,
                              height: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              const HeaderPlant(),
            ],
          ),
        ),
      ],
    );
  }
}

class HeaderPlant extends StatefulWidget {
  const HeaderPlant({super.key});

  @override
  State<HeaderPlant> createState() => _HeaderPlantState();
}

class _HeaderPlantState extends State<HeaderPlant> {
  List<SMIInput<bool>?> smi = [];
  List<Artboard> artboards = [];

  Future<void> initArtboard() async {
    final sProvider = Provider.of<UserSettings>(context, listen: false);

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
        final int index = smi.indexOf(input);
        smi[index]!.value = "$index" == sProvider.selectedPlant;

        artboards.add(artboard);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final sProvider = Provider.of<UserSettings>(context);
    final index = int.parse(sProvider.selectedPlant);

    return SizedBox(
      height: 30.w,
      width: 30.w,
      child: FutureBuilder(
        future: initArtboard(),
        builder: (context, snapshot) =>
            snapshot.connectionState == ConnectionState.done
                ? Rive(
                    artboard: artboards[index],
                    fit: BoxFit.fill,
                  )
                : const Padding(
                    padding: EdgeInsets.symmetric(vertical: 75),
                    child: CircularProgressIndicator(
                      color: MindBloomingColorScheme.tertiary,
                    ),
                  ),
      ),
    );
  }
}
