import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import '../../../providers/safety_planning.dart';
import '../../../utility/mindblooming_color_scheme.dart';
import '../../../utility/mindblooming_text_style.dart';
import 'reasons_of_life.dart';
import 'safety_planning_type_screen.dart';

class SafetyPlanningCardType extends StatelessWidget {
  const SafetyPlanningCardType({
    super.key,
    required this.safetyPlanningType,
  });

  final String safetyPlanningType;

  @override
  Widget build(BuildContext context) {
    final spProvider = Provider.of<SafetyPlanning>(context);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 40),
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
        // Use a Builder to create a new context that is properly attached
        child: Builder(
          builder: (context) => InkWell(
            onTap: () => _onTap(
              context,
            ), //  "MM_SP_$safetyPlanningType", newContext
            borderRadius: BorderRadius.circular(20),
            highlightColor: Colors.transparent,
            splashColor: MindBloomingColorScheme.primary3shadow,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              child: Row(
                children: [
                  // Icon on the left
                  SvgPicture.asset(
                    "assets/safety_plan/${safetyPlanningType}.svg",
                    width: 50,
                    height: 50,
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title row with arrow icon on the right
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Text(
                                spProvider.prettyName[safetyPlanningType] ??
                                    'Titolo',
                                style: MindBloomingTextStyle.header3,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                softWrap: true,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 5,
                              ),
                              child: SvgPicture.asset(
                                "assets/icon_right_arrow.svg",
                              ),
                            ),
                            //   ),
                            // ),
                          ],
                        ),
                        const SizedBox(height: 5),
                        // Subtitle / description: mostra tutto il testo, senza truncation
                        Text(
                          spProvider.descrizioni[safetyPlanningType] ??
                              'Descrizione',
                          style: MindBloomingTextStyle.normal,
                          softWrap: true,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _onTap(
    // String surveyName,
    BuildContext context,
  ) {
    // Use the provided context from the Builder to ensure it is attached
    // final pp = Provider.of<Progress>(context, listen: false);
    // final qp = Provider.of<Questions>(context, listen: false);
    // final blocks = qp.blocks(surveyName);

    // Navigator.of(context).push(
    //   MaterialPageRoute(
    //     builder: (context) => QuestionsScreen(
    //       // The third parameter, context, is used in screening
    //       onDone: (surveyName, blockName, _) {
    //         pp.addDoneBlock(
    //           surveyName,
    //           blockName,
    //         );
    //       },
    //       surveyName: surveyName,
    //       blockName: blocks.entries.first.key,
    //       // buttonText: "Indietro",
    //       // title: qp.getBlockPrettyName(
    //       //   surveyName,
    //       //   "survey_root_name",
    //       // ),
    //       // subtitle: qp.getBlockPrettyName(
    //       //   surveyName,
    //       //   blocks.entries.first.key,
    //       // ),
    //     ),
    //   ),
    // );

    // The commented-out code can be used or removed as needed.
    // For example:
    // final up = Provider.of<UserSettings>(context, listen: false);
    // if (up.demo) {
    //   Navigator.of(context).push(
    //     MaterialPageRoute(
    //       builder: (context) => BlocksScreen(
    //         exercise: exercise,
    //         tappa: tappa,
    //       ),
    //     ),
    //   );
    // } else {
    //   final mProvider = Provider.of<Moduli>(context, listen: false);
    //   showDialog(
    //     context: context,
    //     builder: (context) => MindBloomingGeneralDialog(
    //       title: mProvider.prettyName[exercise.modulo] ?? '',
    //       content:
    //           "Per favore, completa gli esercizi precedenti prima di procedere.",
    //     ),
    //   );
    // }

    // print(safetyPlanningType);

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => safetyPlanningType == "ragionidivita"
            ? const ReasonsOfLife()
            : SafetyPlanningTypeScreen(
                safetyPlanningType: safetyPlanningType,
              ),
      ),
    );
  }
}
