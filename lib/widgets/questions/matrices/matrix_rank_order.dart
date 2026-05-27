import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../providers/answers.dart';
import '../../../utility/mindblooming_color_scheme.dart';
import '../../../utility/mindblooming_text_style.dart';
import '../general_optional_text_entry.dart';
import '../question_text.dart';

class MatrixRankOrder extends StatefulWidget {
  final String questionText;
  final Map<String, dynamic> choices;
  final Map<String, dynamic> answers;
  final String surveyID;
  final String blockID;
  final String questionID;
  final bool disabled;

  MatrixRankOrder({
    required this.questionText,
    required this.choices,
    required this.answers,
    required this.surveyID,
    required this.blockID,
    required this.questionID,
    required this.disabled,
  }) : super(key: Key(questionID));

  @override
  _MatrixRankOrderState createState() => _MatrixRankOrderState();
}

class _MatrixRankOrderState extends State<MatrixRankOrder> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        QuestionText(
          questionText: widget.questionText,
          surveyID: widget.surveyID,
          blockID: widget.blockID,
          questionID: widget.questionID,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30.0),
          child: Column(
            children: [
              ...widget.choices.entries.map(
                (choice) => Container(
                  margin: const EdgeInsets.symmetric(vertical: 10.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: MindBloomingColorScheme.primary1shadow,
                    border: Border.all(
                      color: MindBloomingColorScheme.primary3shadow,
                      width: 0.5,
                    ),
                  ),
                  child: Risposte(
                    choice,
                    widget.answers,
                    widget.questionID,
                    widget.surveyID,
                    widget.disabled,
                  ),
                ),
              ),
            ],
          ),
        ),
        const Padding(padding: EdgeInsets.only(bottom: 8.0)),
      ],
    );
  }
}

class Risposte extends StatefulWidget {
  final MapEntry<String, dynamic> choice;
  final Map<String, dynamic> answers;
  final String questionID;
  final String surveyID;
  final bool disabled;

  Risposte(
    this.choice,
    this.answers,
    this.questionID,
    this.surveyID,
    this.disabled,
  );
  @override
  _RisposteState createState() => _RisposteState();
}

class _RisposteState extends State<Risposte> {
  @override
  Widget build(BuildContext context) {
    final answers = Provider.of<Answers>(context);
    final value = widget.choice.value;

    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 4.0,
        horizontal: 20,
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(
              top: 10.0,
              bottom: 16,
            ),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(
                        right: 10,
                        top: 5.5,
                      ),
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: answers.hasAnswerChoice(
                          widget.surveyID,
                          widget.questionID,
                          widget.choice.key,
                          hasAnswer: true,
                        )
                            ? MindBloomingColorScheme.secondary
                            : MindBloomingColorScheme.tertiary,
                        borderRadius: BorderRadius.circular(100),
                      ),
                    ),
                    Expanded(
                      child: CustomHtmlWidget(
                        questionText: value['Display'],
                      ),
                    ),
                  ],
                ),
                if (value.containsKey('Image')) ...{
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(
                        'https://psicologiaunimib.qualtrics.com/CP/Graphic.php?IM=' +
                            value['Image']['ImageLocation'],
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;

                          return Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                  : null,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                },
                if (value.containsKey('TextEntry')) ...{
                  GeneralOptionalTextEntry(
                    choice: widget.choice,
                    questionID: widget.questionID,
                    padding: const EdgeInsets.all(8),
                    surveyID: widget.surveyID,
                    disabled: widget.disabled,
                  ),
                },
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 4.0),
            child: Column(
              children: [
                ...widget.answers.entries.map(
                  (answer) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 4.0,
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              SizedBox(
                                width: MediaQuery.of(context).size.width * 0.5,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 8.0,
                                      ),
                                      child: CustomHtmlWidget(
                                        questionText: answer.value['Display'],
                                      ),
                                    ),
                                    if (answer.value.containsKey('Image')) ...{
                                      Padding(
                                        padding: const EdgeInsets.only(top: 8),
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          child: Image.network(
                                            'https://psicologiaunimib.qualtrics.com/CP/Graphic.php?IM=' +
                                                answer.value['Image']
                                                    ['ImageLocation'],
                                            loadingBuilder: (
                                              context,
                                              child,
                                              loadingProgress,
                                            ) {
                                              if (loadingProgress == null) {
                                                return child;
                                              }

                                              return Center(
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child:
                                                      CircularProgressIndicator(
                                                    value: loadingProgress
                                                                .expectedTotalBytes !=
                                                            null
                                                        ? loadingProgress
                                                                .cumulativeBytesLoaded /
                                                            loadingProgress
                                                                .expectedTotalBytes!
                                                        : null,
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                      ),
                                    },
                                  ],
                                ),
                              ),
                              SizedBox(
                                width: MediaQuery.of(context).size.width * 0.20,
                                child: RankOrderMatrixEntry(
                                  questionID: widget.questionID,
                                  choiceID: widget.choice.key,
                                  answerID: answer.key,
                                  surveyID: widget.surveyID,
                                  disabled: widget.disabled,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class RankOrderMatrixEntry extends StatefulWidget {
  final String questionID;
  final String choiceID;
  final String answerID;
  final String surveyID;
  final bool disabled;

  const RankOrderMatrixEntry({
    super.key,
    required this.choiceID,
    required this.questionID,
    required this.answerID,
    required this.surveyID,
    required this.disabled,
  });

  @override
  _RankOrderMatrixEntryState createState() => _RankOrderMatrixEntryState();
}

class _RankOrderMatrixEntryState extends State<RankOrderMatrixEntry> {
  final textController = TextEditingController();

  @override
  void initState() {
    final answers = Provider.of<Answers>(context, listen: false);
    final answer = answers.getAnswer(
          widget.surveyID,
          "${widget.questionID}_${widget.choiceID}_${widget.answerID}",
        ) ??
        '';
    textController.text = answer.toString();
    super.initState();
  }

  @override
  void dispose() {
    textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final answers = Provider.of<Answers>(context);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        boxShadow: [
          const BoxShadow(
            color: Color.fromARGB(64, 9, 23, 18),
          ),
          const BoxShadow(
            color: Color.fromARGB(64, 9, 23, 18),
            spreadRadius: -0.1,
            blurStyle: BlurStyle.inner,
            blurRadius: 2,
            offset: Offset(1, 1),
          ),
          const BoxShadow(
            color: MindBloomingColorScheme.primary,
            spreadRadius: -0.1,
            blurRadius: 2,
            offset: Offset(1, 1),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5.0),
        child: TextField(
          enabled: !widget.disabled,
          minLines: 1,
          maxLines: 1,
          keyboardType: TextInputType.number,
          style: MindBloomingTextStyle.normal,
          decoration: InputDecoration(
            hintText: "...",
            hintStyle: MindBloomingTextStyle.normal.copyWith(
              color: MindBloomingColorScheme.textColorDark1shadow,
            ),
            border: InputBorder.none,
          ),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
          ],
          onChanged: (value) {
            if (value != '') {
              answers.addAnswer(
                widget.surveyID,
                "${widget.questionID}_${widget.choiceID}_${widget.answerID}",
                double.parse(value).toInt(),
              );
            } else {
              answers.removeAnswer(
                widget.surveyID,
                "${widget.questionID}_${widget.choiceID}_${widget.answerID}",
              );
            }
          },
          controller: textController,
        ),
      ),
    );
  }
}
