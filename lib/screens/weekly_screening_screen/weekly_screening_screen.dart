import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

import '../../models/weekly_screening.dart';
import '../../utility/error_alert.dart';
import '../../utility/mindblooming_color_scheme.dart';
import '../../utility/mindblooming_text_style.dart';
import '../../widgets/mindblooming_button.dart';
import '../../providers/answers.dart';
import '../../providers/moduli.dart';
import '../../providers/progress.dart';
import '../../providers/questions.dart';

class WeeklyScreeningScreen extends StatelessWidget {
  const WeeklyScreeningScreen({super.key, required this.ws});
  final WeeklyScreening ws;

  @override
  Widget build(BuildContext context) {
    final qProvider = Provider.of<Questions>(context);
    final mProvider = Provider.of<Moduli>(context);
    final pProvider = Provider.of<Progress>(context);
    final aProvider = Provider.of<Answers>(context);

    final String surveyID = qProvider.surveyID(ws.surveyName);
    final Map<String, dynamic> blocks = qProvider.blocks(ws.surveyName);
    final block = Map<String, dynamic>.from(blocks[ws.blockName]);
    final Map<String, dynamic> questions = Map<String, dynamic>.from(
      block['questions'],
    );

    return Scaffold(
      backgroundColor: MindBloomingColorScheme.secondary2shadow,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Stack(
              children: [
                Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: MindBloomingColorScheme.primary,
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
                        child: SvgPicture.asset(
                          "assets/pic_${ws.modulo}.svg",
                          height: 25.h,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
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
                                "Torna alla Home",
                                style: MindBloomingTextStyle.pretitle,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30),
                      child: Text(
                        mProvider.prettyName[ws.modulo]!,
                        style: MindBloomingTextStyle.header1,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SliverToBoxAdapter(
            child: Column(
              children: [
                ...questions.entries.map((q) {
                  final int index = questions.keys.toList().indexOf(q.key);

                  return Column(
                    children: [
                      qProvider.buildQuestion(
                        surveyName: ws.surveyName,
                        blockName: ws.blockName,
                        ctx: context,
                        indexData: {
                          "index": index,
                          "direction": "next",
                        },
                        dontSkip: true,
                        disabled: ws.done,
                      ),
                    ],
                  );
                }),
              ],
            ),
          ),
          SliverFillRemaining(
            fillOverscroll: true,
            hasScrollBody: false,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 30,
                  vertical: 20,
                ),
                child: MindBloomingButton(
                  onPressed: ws.done
                      ? null
                      : () async {
                          pProvider.setWeeklyDone(ws);
                          pProvider.addDoneBlock(ws.surveyName, ws.blockName);

                          bool done = true;

                          qProvider
                              .blocks(ws.surveyName)
                              .keys
                              .forEach((element) {
                            if (!pProvider.isDoneBlock(
                              ws.surveyName,
                              element,
                            )) {
                              done = false;
                            }
                          });

                          if (done) {
                            final String sent = await aProvider.sendAnswers(
                              surveyID,
                              context,
                            );

                            if (sent == "OK") {
                              pProvider.addDoneSurvey(ws.surveyName);
                              if (context.mounted) {
                                Navigator.of(context).pop();
                              }
                            } else {
                              pProvider.removeBlock(
                                ws.surveyName,
                                ws.blockName,
                              );

                              if (context.mounted) {
                                errorAlert(context, sent);
                              }
                            }
                          } else {
                            Navigator.of(context).pop();
                          }
                        },
                  child: Text(
                    "FINE",
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
