import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import '../../../utility/mindblooming_color_scheme.dart';
import '../../../utility/mindblooming_text_style.dart';
import 'safety_planning_list_screen.dart';

class SafetyPlanningCard extends StatelessWidget {
  const SafetyPlanningCard({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 30),
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
          onTap: () => _onTap(
            context,
          ),
          borderRadius: BorderRadius.circular(20),
          highlightColor: Colors.transparent,
          splashColor: MindBloomingColorScheme.primary3shadow,
          child: Row(
            children: [
              const SizedBox(width: 20),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 5),
                  Text(
                    "Safety Plan",
                    style: MindBloomingTextStyle.header2,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Clicca per vedere il Safety Plan",
                    style: MindBloomingTextStyle.normal,
                  ),
                  const SizedBox(height: 13),
                ],
              ),
              const Spacer(),
              Material(
                shape: const CircleBorder(),
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => _onTap(
                    context,
                  ),
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

  void _onTap(
    BuildContext context,
  ) {
    // COME IN ESERCIZI
    //   final up = Provider.of<UserSettings>(context, listen: false);

    //   if (up.demo) {
    //     Navigator.of(context).push(
    //       MaterialPageRoute(
    //         builder: (context) => BlocksScreen(
    //           exercise: exercise,
    //           tappa: tappa,
    //         ),
    //       ),
    //     );
    //   } else {
    //     final mProvider = Provider.of<Moduli>(context, listen: false);
    //     showDialog(
    //       context: context,
    //       builder: (context) => MindBloomingGeneralDialog(
    //         title: mProvider.prettyName[exercise.modulo] ?? '',
    //         content:
    //             "Per favore, completa gli esercizi precedenti prima di procedere.",
    //       ),
    //     );
    //   }
    // }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const SafetyPlanningListScreen(),
      ),
    );
  }
}
