import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

import '../../../providers/answers.dart';
import '../../../providers/progress.dart';
import '../../../providers/questions.dart';
import '../../../providers/safety_planning.dart';
import '../../../providers/validation.dart';
import '../../../questionHandlers/file_uploader_handler.dart';
import '../../../utility/error_alert.dart';
import '../../../utility/mindblooming_color_scheme.dart';
import '../../../utility/mindblooming_text_style.dart';
import '../../../widgets/mindblooming_button.dart';
import '../../questions_screen/questions_appbar.dart';

class ReasonsOfLife extends StatefulWidget {
  const ReasonsOfLife({super.key});

  @override
  State<ReasonsOfLife> createState() => _ReasonsOfLifeState();
}

class _ReasonsOfLifeState extends State<ReasonsOfLife> {
  Map<String, dynamic> _indexData = {};
  late bool skip;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    _indexData = {"index": 0, "direction": "next"};

    final qProvider = Provider.of<Questions>(context, listen: false);
    final aProvider = Provider.of<Answers>(context, listen: false);
    final surveyID = qProvider.surveyID("MM_SP_ragionidivita");

    final blocks = qProvider.blocks("MM_SP_ragionidivita");

    final length = qProvider
        .questions("MM_SP_ragionidivita", blocks.entries.first.key)
        .length;

    final Map<String, dynamic> questions =
        qProvider.questions("MM_SP_ragionidivita", blocks.entries.first.key);

    for (int i = 0; i < questions.keys.toList().length; i++) {
      final String currKey = questions.keys.toList()[i];
      skip = qProvider.isSkip(
        Map<String, dynamic>.from(questions[currKey]),
        context,
        surveyID,
      );

      if (aProvider.hasAnswer(surveyID, questions[currKey]['QuestionID']) ||
          !skip) {
        _indexData["index"] = _indexData["index"] + 1;
      } else {
        break;
      }
    }

    if (_indexData["index"] == length) {
      _indexData["index"] = int.parse('0');
    }
  }

  @override
  void dispose() {
    super.dispose();
    _scrollController.dispose();
  }

  bool disableButton = false;

  @override
  Widget build(BuildContext context) {
    final ap = Provider.of<Answers>(context);
    final pp = Provider.of<Progress>(context);
    final qp = Provider.of<Questions>(context);
    final vp = Provider.of<Validation>(context);
    final sp = Provider.of<SafetyPlanning>(context);

    final blocks = qp.blocks("MM_SP_ragionidivita");

    final length =
        qp.questions("MM_SP_ragionidivita", blocks.entries.first.key).length;
    final surveyID = qp.surveyID("MM_SP_ragionidivita");

    return Scaffold(
      backgroundColor: MindBloomingColorScheme.primary,
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          QuestionsAppBar(
            indexData: _indexData,
            length: length,
            buttonText: "Indietro",
            title: sp.prettyName["ragionidivita"]!,
            subtitle: '',
            pdf: false,
            onPdf: null,
          ),
          const SliverToBoxAdapter(
            child: SizedBox(
              height: 30,
            ),
          ),
          SliverToBoxAdapter(
            child: AnimatedSwitcher(
              layoutBuilder: (currentChild, previousChildren) {
                return Stack(
                  children: [
                    ...previousChildren,
                    if (currentChild != null) currentChild,
                  ],
                  fit: StackFit.passthrough,
                );
              },
              transitionBuilder: (child, animation) {
                double start;
                start = _indexData['direction'] == "next" ? 1 : -1;

                final offsetAnimation = Tween(
                  begin: Offset(start, 0.0),
                  end: Offset.zero,
                ).animate(animation);

                return ClipRect(
                  child: SlideTransition(
                    position: offsetAnimation,
                    child: child,
                  ),
                );
              },
              switchOutCurve: Curves.easeInExpo,
              switchInCurve: Curves.easeOutExpo,
              duration: const Duration(milliseconds: 500),
              child: qp.buildQuestion(
                indexData: _indexData,
                ctx: context,
                surveyName: "MM_SP_ragionidivita",
                blockName: blocks.entries.first.key,
                disabled: false,
              ),
            ),
          ),
          // _indexData['index'] == length - 1
          //     ? SliverFillRemaining(
          //         hasScrollBody: false,
          //         fillOverscroll: true,
          //         child: Align(
          //           alignment: Alignment.bottomCenter,
          //           child: Padding(
          //             padding: const EdgeInsets.only(
          //               left: 30.0,
          //               right: 30,
          //               bottom: 20,
          //             ),
          //             child: MindBloomingButton(
          //               child: Text(
          //                 'FINE',
          //                 style: MindBloomingTextStyle.button,
          //               ),
          //               onPressed: disableButton
          //                   ? null
          //                   : () async {
          //                       // widget.onDone(
          //                       // "MM_SP_ragionidivita",
          //                       // blocks.entries.first.key,
          //                       //   context,
          //                       // );

          //                     },
          //             ),
          //           ),
          //         ),
          //       )
          //     :

          SliverFillRemaining(
            hasScrollBody: false,
            fillOverscroll: true,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(
                  left: 30.0,
                  right: 30.0,
                  bottom: 20.0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    MindBloomingButton(
                      onPressed: _indexData['index'] == 0
                          ? null
                          : () async {
                              final box = Hive.box('moshimoshi');
                              final raw = box.get(
                                'ragionidivita',
                                defaultValue: <dynamic>[],
                              );

                              // 1. Ricostruisco gli StoredImage
                              final List<StoredImage> images = (raw as List)
                                  .map((e) => StoredImage.fromJson(
                                        Map<String, dynamic>.from(e),
                                      ))
                                  .toList();

                              // 2. Processo la lista:
                              //    - rimuovo (filter out) tutte le immagini non salvate (saved == false)
                              //    - resetto deleted a false per le altre
                              final List<StoredImage> cleaned =
                                  images.where((img) {
                                return img.saved;
                              }).map((img) {
                                if (img.deleted) {
                                  img.deleted = false;
                                }

                                return img;
                              }).toList();

                              // 3. Salvo di nuovo in Hive la lista "pulita"
                              await box.put(
                                'ragionidivita',
                                cleaned.map((e) => e.toJson()).toList(),
                              );

                              setState(() {
                                _indexData['index'] = _indexData['index'] - 1;
                                _indexData['direction'] = 'prev';
                              });

                              _scrollController.animateTo(
                                0,
                                duration: const Duration(milliseconds: 500),
                                curve: Curves.easeInOut,
                              );
                            },
                      child: Text(
                        "INDIETRO",
                        style: MindBloomingTextStyle.button,
                      ),
                      width: 37.w,
                    ),
                    MindBloomingButton(
                      onPressed: () async {
                        if (_indexData['index'] == length - 1) {
                          pp.addDoneBlock(
                            "MM_SP_ragionidivita",
                            blocks.entries.first.key,
                          );

                          bool done = true;

                          qp
                              .blocks("MM_SP_ragionidivita")
                              .keys
                              .forEach((element) {
                            if (!pp.isDoneBlock(
                              "MM_SP_ragionidivita",
                              element,
                            )) {
                              done = false;
                            }
                          });

                          if (done) {
                            setState(() {
                              disableButton = true;
                            });
                            final String sent =
                                await ap.sendAnswersWithAttachment(
                              surveyID,
                              context,
                            );
                            if (sent == "OK") {
                              pp.addDoneSurvey("MM_SP_ragionidivita");

                              if (context.mounted) {
                                Navigator.of(context).pop();
                              }
                            } else {
                              pp.removeBlock(
                                "MM_SP_ragionidivita",
                                blocks.entries.first.key,
                              );

                              if (context.mounted) {
                                errorAlert(context, sent);
                              }
                            }
                            setState(() {
                              disableButton = false;
                            });
                          } else {
                            Navigator.of(context).pop();
                          }
                        } else {
                          final qid = qp
                              .questions(
                                "MM_SP_ragionidivita",
                                blocks.entries.first.key,
                              )
                              .keys
                              .elementAt(_indexData['index']);

                          if (vp.skippable(surveyID, qid) ||
                              ap.hasAnswer(surveyID, qid)) {
                            if (vp.isValid(
                              questionID: qid,
                              surveyID: surveyID,
                              answers: ap.answers,
                            )) {
                              if (_indexData['index'] < length) {
                                setState(() {
                                  _indexData['index'] = _indexData['index'] + 1;
                                  _indexData['direction'] = 'next';
                                });
                              }

                              _scrollController.animateTo(
                                0,
                                duration: const Duration(milliseconds: 500),
                                curve: Curves.easeOut,
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    "La risposta fornita è sbagliata, per favore riprova",
                                  ),
                                ),
                              );
                            }
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  "Per favore rispondi alla domanda prima di procedere",
                                ),
                              ),
                            );
                          }
                        }
                      },
                      child: Text(
                        _indexData['index'] == length - 1 ? "FINE" : "AVANTI",
                        style: MindBloomingTextStyle.button,
                      ),
                      width: 37.w,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
