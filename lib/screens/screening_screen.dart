import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:timelines_plus/timelines_plus.dart';

import '../utility/local_user.dart';
import '../providers/user_settings.dart';
import 'questions_screen/questions_screen.dart';
import './results_screen/results_screen.dart';
import '../providers/questions.dart';
import '../providers/screening.dart';
import '../providers/progress.dart';
import '../providers/answers.dart';
import '../widgets/mindblooming_button.dart';
// import '../providers/user_settings.dart';
import '../utility/mindblooming_color_scheme.dart';
import '../utility/mindblooming_text_style.dart';

class ScreeningScreen extends StatelessWidget {
  final surveyName = "MM_baseline_assessment_week1";

  @override
  Widget build(BuildContext context) {
    final sp = Provider.of<Screening>(context);
    final pp = Provider.of<Progress>(context);
    final ap = Provider.of<Answers>(context);
    final qp = Provider.of<Questions>(context);
    final debug = Provider.of<UserSettings>(context).debug;

    // Se l'utente è quello speciale, marca lo screening come completato
    const List<String> allowedUids = [
      "MKPJicfBKqMMtQwAZ6T6yLcZhg62",
      "DpxGXzuvewVRbOiRjQJwJuvR7Eh2",
      "XnWN4DWq7zbOZMxFCLRuLuaUlmQ2",
      "vbsIj9UvKlbEfxyr1wOKuwL749s2",
      "WAOpmXtss0Ple8yxj9jYuIC6jV82",
      "4QCeNP4DeFSHMDG4B8s6btd6Zmi1",
      "RK8TPUjyzegqRSA17CFPNifnleq2",
      "tbGs34NLZEbqTFQ4uXhCmJdelpk1",
      "UDgBWHcMueVdw2vQiDNks9osh3o1",
      "uc5k6rgd57ft1GOik5w0sXvbjGW2",
      "IV8Xf0tK0afuTOpjMvJIHgRC8733",
      "h07jMIkaKlhOwUKgBDlLHhsiJnu1",
      "VjYp6bPhMaN91RndsmlfXaNbAaL2",
      "2EL1gaaGCoceWHmCyO71AJv50Or2",
    ];

    final String? uid = LocalUser.currentUid();
    if (uid != null &&
        allowedUids.contains(uid) &&
        !pp.doneSurveys.contains(surveyName)) {
      pp.addDoneSurvey(surveyName);
    }

    final blocks = qp.blocks(surveyName);
    final doneBlocksScreen =
        pp.doneBlocks['MM_baseline_assessment_week1'] ?? [];

    for (var doneBlock in doneBlocksScreen) {
      sp.updateDone(doneBlock);
    }

    final size = MindBloomingTextStyle.returnMobile()
        ? 20.sp
        : (MindBloomingTextStyle.returnDesktop() ? 11.sp : 14.sp);

    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 22.0, left: 30, top: 20),
                child: Text("Screening", style: MindBloomingTextStyle.header1),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 40.0),
                child: Column(
                  children: [
                    // FOR EVERY BLOCK IN THE SCREENING
                    ...blocks.entries.map((block) {
                      // COMPUTE VARIABLES

                      final int idx = blocks.keys.toList().indexOf(block.key);
                      final String name = qp.getBlockPrettyName(
                        "MM_baseline_assessment_week1",
                        block.key,
                      );

                      final String surveyID =
                          qp.surveyID('MM_baseline_assessment_week1');
                      final bool done = sp.isDone(block.key);

                      final bool current =
                          idx == 0 || sp.isDone(blocks.keys.elementAt(idx - 1));
                      final bool beforeCurrent = idx < blocks.length - 1 &&
                          done &&
                          !sp.isDone(blocks.keys.elementAt(idx + 1));

                      String pic;
                      Color color;
                      Color bcolor;

                      final question = block.value['questions'];
                      final List<String> keys = List<String>.from(
                        block.value['questions'].keys.toList(),
                      );
                      int tot = question.length;
                      final int ans = ap.getAnswerCountKeys(surveyID, keys);

                      for (var key in keys) {
                        final bool skip = qp.isSkip(
                          Map<String, dynamic>.from(qp.questions(
                            surveyName,
                            block.key,
                          )[key]),
                          context,
                          surveyID,
                        );

                        if (!skip) {
                          tot--;
                        }
                      }

                      if (done) {
                        pic = 'assets/icon_done.svg';
                        color = MindBloomingColorScheme.secondary2shadow;
                        bcolor = MindBloomingColorScheme.secondary4shadow;
                      } else if (idx == 0) {
                        pic = 'assets/icon_current.svg';
                        color = MindBloomingColorScheme.tertiary1shadow;
                        bcolor = MindBloomingColorScheme.tertiary;
                      } else if (current) {
                        pic = 'assets/icon_current.svg';
                        color = MindBloomingColorScheme.tertiary1shadow;
                        bcolor = MindBloomingColorScheme.tertiary;
                      } else {
                        pic = 'assets/icon_locked.svg';
                        color = MindBloomingColorScheme.primary2shadow;
                        bcolor = MindBloomingColorScheme.primary3shadow;
                      }

                      // RENDER
                      return TimelineTile(
                        nodeAlign: TimelineNodeAlign.start,
                        contents: Padding(
                          padding: const EdgeInsets.only(
                            left: 30,
                            bottom: 10,
                            right: 40,
                            top: 10,
                          ),
                          child: InkWell(
                            child: Ink(
                              decoration: BoxDecoration(
                                color: color,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: bcolor,
                                  width: 0.5,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 15,
                                        vertical: 12,
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            name,
                                            style: MindBloomingTextStyle
                                                .subtitleScreening,
                                          ),
                                          Padding(
                                            padding:
                                                const EdgeInsets.only(top: 5.0),
                                            child: Row(
                                              children: [
                                                Text(
                                                  '${question.length}',
                                                  style: MindBloomingTextStyle
                                                      .pretitleScreening,
                                                ),
                                                idx == 0
                                                    ? Text(
                                                        ' contenuti',
                                                        style: MindBloomingTextStyle
                                                            .pretitleScreening,
                                                      )
                                                    : question.length == 1
                                                        ? Text(
                                                            ' domanda',
                                                            style: MindBloomingTextStyle
                                                                .pretitleScreening,
                                                          )
                                                        : Text(
                                                            ' domande',
                                                            style: MindBloomingTextStyle
                                                                .pretitleScreening,
                                                          ),
                                              ],
                                            ),
                                          ),
                                          Padding(
                                            padding:
                                                const EdgeInsets.only(top: 5.0),
                                            child: (done || current)
                                                ? ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                      50,
                                                    ),
                                                    child: Container(
                                                      decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(50),
                                                        border: Border.all(
                                                          color:
                                                              MindBloomingColorScheme
                                                                  .dialogBg,
                                                          width: 0.5,
                                                        ),
                                                      ),
                                                      child:
                                                          LinearProgressIndicator(
                                                        value: ans / tot,
                                                        color: done
                                                            ? MindBloomingColorScheme
                                                                .secondary
                                                            : MindBloomingColorScheme
                                                                .tertiary,
                                                        minHeight: 5,
                                                      ),
                                                    ),
                                                  )
                                                : null,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(right: 20),
                                    child: (done || current)
                                        ? Padding(
                                            padding: const EdgeInsets.only(
                                              left: 4.0,
                                            ),
                                            child: SvgPicture.asset(
                                              'assets/icon_right_arrow.svg',
                                            ),
                                          )
                                        : null,
                                  ),
                                ],
                              ),
                            ),
                            borderRadius: BorderRadius.circular(20),
                            splashColor: done
                                ? MindBloomingColorScheme.secondary4shadow
                                : MindBloomingColorScheme.tertiary,
                            highlightColor: Colors.transparent,
                            onTap: (done || current || debug)
                                ? () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) => QuestionsScreen(
                                          onDone: (surveyName, blockName, ctx) {
                                            sp.addDone(
                                              blockName,
                                              ctx,
                                            );
                                            pp.addDoneBlock(
                                              surveyName,
                                              blockName,
                                            );
                                          },
                                          surveyName: surveyName,
                                          blockName: block.key,
                                          buttonText: "Torna allo Screening",
                                          title: qp.getBlockPrettyName(
                                            surveyName,
                                            "survey_root_name",
                                          ),
                                          subtitle: qp.getBlockPrettyName(
                                            surveyName,
                                            block.key,
                                          ),
                                        ),
                                      ),
                                    );
                                  }
                                : null,
                          ),
                        ),
                        node: TimelineNode(
                          indicator: Container(
                            width: size,
                            height: size,
                            alignment: Alignment.center,
                            child: SvgPicture.asset(
                              pic,
                              width: size,
                              height: size,
                              fit: BoxFit.contain,
                            ),
                          ),
                          startConnector: idx != 0
                              ? DashedLineConnector(
                                  dash: 4,
                                  gap: 2,
                                  color: done
                                      ? MindBloomingColorScheme.secondary2shadow
                                      : current
                                          ? MindBloomingColorScheme
                                              .tertiary2shadow
                                          : MindBloomingColorScheme
                                              .primary2shadow,
                                )
                              : null,
                          endConnector: idx != blocks.length - 1
                              ? DashedLineConnector(
                                  dash: 4,
                                  gap: 2,
                                  color: beforeCurrent
                                      ? MindBloomingColorScheme.tertiary2shadow
                                      : done
                                          ? MindBloomingColorScheme
                                              .secondary2shadow
                                          : MindBloomingColorScheme
                                              .primary2shadow,
                                )
                              : null,
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 32.0, vertical: 16),
                child: MindBloomingButton(
                  onPressed: () {
                    sp.doneScreening();
                    sp.check();

                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => ResultsScreen(
                          scelte: sp.scelte,
                          daScegliere: sp.daScegliere,
                        ),
                      ),
                    );
                  },
                  child: Text(
                    'CONTINUA',
                    style: MindBloomingTextStyle.button,
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
