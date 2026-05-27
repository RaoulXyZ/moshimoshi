import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';

import '../../../models/exercise.dart';
import '../../../providers/moduli.dart';
import '../../../providers/progress.dart';
import '../../../providers/questions.dart';
import '../../../utility/mindblooming_color_scheme.dart';
import '../../../utility/mindblooming_text_style.dart';
import 'diary/diary_list_screen.dart';

class DiaryCard extends StatelessWidget {
  const DiaryCard({
    super.key,
    required this.exercise,
    required this.tappa,
    required this.personal,
    required this.date,
  });

  final Exercise exercise;
  final String tappa;
  final bool personal;
  final String date;

  @override
  Widget build(BuildContext context) {
    final mp = Provider.of<Moduli>(context);
    final qp = Provider.of<Questions>(context);
    // final ap = Provider.of<Answers>(context);
    final pp = Provider.of<Progress>(context);

    bool doneExercise = true;

    // int tot = 0;
    // int ans = 0;

    // final surveyID = qp.surveyID(exercise.surveyName);
    final blocks = qp.blocks(exercise.surveyName);

    for (var block in blocks.entries) {
      // tot += block.value['questions'].length as int;

      // final List<String> keys = List<String>.from(
      //   block.value['questions'].keys.toList(),
      // );
      // ans += ap.getAnswerCountKeys(surveyID, keys);

      if (!pp.isDoneBlock(exercise.surveyName, block.key)) {
        doneExercise = false;
      }
    }

    // final isScreening = tappa.contains('screening');

    if (doneExercise) {
      exercise.setDone();
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 40),
      decoration: BoxDecoration(
        color: MindBloomingColorScheme.tertiary1shadow,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: MindBloomingColorScheme.tertiary,
          width: 0.5,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _onTap(
            context,
            exercise,
            // tappa,
          ),
          borderRadius: BorderRadius.circular(20),
          highlightColor: Colors.transparent,
          splashColor: MindBloomingColorScheme.tertiary,
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: SizedBox(
                  width: 100,
                  height: 110,
                  child: Stack(
                    children: [
                      Container(
                        decoration: const BoxDecoration(
                          color: MindBloomingColorScheme.tertiary2shadow,
                          borderRadius: BorderRadius.only(
                            topRight: Radius.elliptical(75, 100),
                            bottomRight: Radius.elliptical(75, 100),
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: SvgPicture.asset(
                          personal
                              ? "assets/cards/baseline_assessment.svg"
                              : "assets/cards/${exercise.modulo}.svg",
                          fit: BoxFit.fitHeight,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 40),
              Expanded(
                child: Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(width: 5),
                        Expanded(
                          child: Text(
                            personal
                                ? "Diario Personale"
                                : mp.prettyName[exercise.modulo] ??
                                    exercise.modulo,
                            style: MindBloomingTextStyle.subtitle,
                          ),
                        ),
                        const SizedBox(width: 5),
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () => _onTap(
                              context,
                              exercise,
                              // tappa,
                            ),
                            highlightColor: Colors.transparent,
                            splashColor: MindBloomingColorScheme.tertiary,
                            borderRadius: BorderRadius.circular(20),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 5,
                              ),
                              child: Align(
                                alignment: Alignment.center,
                                child: SvgPicture.asset(
                                  "assets/icon_right_arrow.svg",
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 5),
                      ],
                    ),
                  ],
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
    Exercise exercise,
    // String tappa,
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
        builder: (context) => DiaryListScreen(
          exercise: exercise,
          personal: personal,
        ),
      ),
    );
  }
}
