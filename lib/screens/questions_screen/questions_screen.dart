import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../utility.dart';
import '../../widgets/mindblooming_button.dart';
import '../../providers/validation.dart';
import '../../providers/questions.dart';
import '../../providers/answers.dart';
import '../../providers/progress.dart';
import '../../utility/mindblooming_color_scheme.dart';
import '../../utility/mindblooming_text_style.dart';
import '../../utility/error_alert.dart';
import './questions_appbar.dart';

class QuestionsScreen extends StatefulWidget {
  const QuestionsScreen({
    super.key,
    required this.surveyName,
    required this.blockName,
    required this.onDone,
    this.buttonText,
    this.title,
    this.subtitle = '',
    this.disabled = false,
  });

  final String surveyName;
  final String blockName;
  final Function onDone;
  final bool disabled;
  final String? buttonText;
  final String? title;
  final String? subtitle;

  @override
  _QuestionsScreenState createState() => _QuestionsScreenState();
}

class _QuestionsScreenState extends State<QuestionsScreen> {
  Map<String, dynamic> _indexData = {};
  late bool skip;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    _indexData = {"index": 0, "direction": "next"};

    final qProvider = Provider.of<Questions>(context, listen: false);
    final aProvider = Provider.of<Answers>(context, listen: false);
    final surveyID = qProvider.surveyID(widget.surveyName);
    final length =
        qProvider.questions(widget.surveyName, widget.blockName).length;

    final Map<String, dynamic> questions =
        qProvider.questions(widget.surveyName, widget.blockName);

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

    final length = qp.questions(widget.surveyName, widget.blockName).length;
    final surveyID = qp.surveyID(widget.surveyName);
    final question = _indexData['index'] == length
        ? {}
        : qp
            .questions(widget.surveyName, widget.blockName)
            .values
            .elementAt(_indexData['index']);

    void onPdf() {
      final url = Uri.parse("$baseFileUrl${question['Files']}");
      launchUrl(
        url,
        mode: LaunchMode.externalApplication,
      );
    }

    final notDisplayCongratsScreen = [
      // "MM_baseline_assessment_week1",
      "MM_SP_segnalidiavvertimento",
      "MM_SP_strategiedicopinginterne",
      "MM_SP_strategiedicopingesterne",
      "MM_SP_contattipersonali",
      "MM_SP_contattiprofessionali",
      "MM_SP_ambientesicuro",
      "MM_SP_ragionidivita",
      "MM_lista_attivita_piacevoli",
      "MM_testimonianze",
    ];

    // final bool end = (widget.surveyName == "MM_baseline_assessment_week1" &&
    //         _indexData['index'] == length - 1) ||
    //     _indexData['index'] == length;

    return Scaffold(
      backgroundColor: MindBloomingColorScheme.primary,
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          QuestionsAppBar(
            indexData: _indexData,
            length: length,
            buttonText: widget.buttonText!,
            title: widget.title!,
            subtitle: widget.subtitle!,
            pdf: question['Selector'] == "FLB",
            onPdf: onPdf,
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
                surveyName: widget.surveyName,
                blockName: widget.blockName,
                disabled: widget.disabled,
              ),
            ),
          ),
          notDisplayCongratsScreen.contains(widget.surveyName)
              // widget.surveyName == "MM_baseline_assessment_week1"
              ? SliverFillRemaining(
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
                                : () {
                                    setState(() {
                                      _indexData['index'] =
                                          _indexData['index'] - 1;
                                      _indexData['direction'] = 'prev';
                                    });

                                    _scrollController.animateTo(
                                      0,
                                      duration:
                                          const Duration(milliseconds: 500),
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
                              if (_indexData['index'] < length - 1) {
                                final qid = qp
                                    .questions(
                                      widget.surveyName,
                                      widget.blockName,
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
                                        _indexData['index'] =
                                            _indexData['index'] + 1;
                                        _indexData['direction'] = 'next';
                                      });
                                    }

                                    _scrollController.animateTo(
                                      0,
                                      duration:
                                          const Duration(milliseconds: 500),
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
                              } else {
                                widget.onDone(
                                  widget.surveyName,
                                  widget.blockName,
                                  context,
                                );

                                bool done = true;

                                qp
                                    .blocks(widget.surveyName)
                                    .keys
                                    .forEach((element) {
                                  if (!pp.isDoneBlock(
                                    widget.surveyName,
                                    element,
                                  )) {
                                    done = false;
                                  }
                                });

                                if (done) {
                                  setState(() {
                                    disableButton = true;
                                  });
                                  final String sent = await ap.sendAnswers(
                                    surveyID,
                                    context,
                                  );
                                  if (sent == "OK") {
                                    pp.addDoneSurvey(widget.surveyName);

                                    if (context.mounted) {
                                      Navigator.of(context).pop();
                                    }
                                  } else {
                                    pp.removeBlock(
                                      widget.surveyName,
                                      widget.blockName,
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
                              }
                            },
                            child: Text(
                              _indexData['index'] == length - 1
                                  ? "FINE"
                                  : "AVANTI",
                              style: MindBloomingTextStyle.button,
                            ),
                            width: 37.w,
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              : _indexData['index'] == length
                  ? SliverFillRemaining(
                      hasScrollBody: false,
                      fillOverscroll: true,
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: Padding(
                          padding: const EdgeInsets.only(
                            left: 30.0,
                            right: 30,
                            bottom: 20,
                          ),
                          child: MindBloomingButton(
                            child: Text(
                              'FINE',
                              style: MindBloomingTextStyle.button,
                            ),
                            onPressed: disableButton
                                ? null
                                : () async {
                                    widget.onDone(
                                      widget.surveyName,
                                      widget.blockName,
                                      context,
                                    );

                                    bool done = true;

                                    qp
                                        .blocks(widget.surveyName)
                                        .keys
                                        .forEach((element) {
                                      if (!pp.isDoneBlock(
                                        widget.surveyName,
                                        element,
                                      )) {
                                        done = false;
                                      }
                                    });

                                    if (done) {
                                      setState(() {
                                        disableButton = true;
                                      });
                                      final String sent = await ap.sendAnswers(
                                        surveyID,
                                        context,
                                      );
                                      if (sent == "OK") {
                                        pp.addDoneSurvey(widget.surveyName);

                                        if (context.mounted) {
                                          Navigator.of(context).pop();
                                        }
                                      } else {
                                        pp.removeBlock(
                                          widget.surveyName,
                                          widget.blockName,
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
                                  },
                          ),
                        ),
                      ),
                    )
                  : SliverFillRemaining(
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
                                    : () {
                                        setState(() {
                                          _indexData['index'] =
                                              _indexData['index'] - 1;
                                          _indexData['direction'] = 'prev';
                                        });

                                        _scrollController.animateTo(
                                          0,
                                          duration:
                                              const Duration(milliseconds: 500),
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
                                onPressed: () {
                                  final qid = qp
                                      .questions(
                                        widget.surveyName,
                                        widget.blockName,
                                      )
                                      .keys
                                      .elementAt(_indexData['index']);

                                  // final answers = ap.answers[surveyID];

                                  // Se è domanda a risposta multipla (risposte sotto forma di lista) e l'opzione "Altro" è selezionata
                                  // if (answers is List<String>) {
                                  //   final otherSelected =
                                  //       answers.contains("Altro");

                                  //   print("Other selected: $otherSelected");
                                  // final otherText =
                                  //     ap.getOtherText(surveyID, qid)?.trim();
                                  // if (otherSelected &&
                                  //     (otherText == null ||
                                  //         otherText.isEmpty)) {
                                  //   ScaffoldMessenger.of(context)
                                  //       .showSnackBar(
                                  //     const SnackBar(
                                  //       content: Text(
                                  //         "Selezionata l'opzione 'Altro', per favore compila il campo di testo.",
                                  //       ),
                                  //     ),
                                  //   );
                                  //   return; // Blocca l'avanzamento
                                  // }
                                  // }

                                  if (vp.skippable(surveyID, qid) ||
                                      ap.hasAnswer(surveyID, qid)) {
                                    if (vp.isValid(
                                      questionID: qid,
                                      surveyID: surveyID,
                                      answers: ap.answers,
                                    )) {
                                      if (_indexData['index'] < length) {
                                        setState(() {
                                          _indexData['index'] =
                                              _indexData['index'] + 1;
                                          _indexData['direction'] = 'next';
                                        });
                                      }

                                      _scrollController.animateTo(
                                        0,
                                        duration:
                                            const Duration(milliseconds: 500),
                                        curve: Curves.easeOut,
                                      );
                                    } else {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
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
                                },
                                child: Text(
                                  "AVANTI",
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

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${this.substring(1)}";
  }
}
