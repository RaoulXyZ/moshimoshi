import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../providers/answers.dart';
import '../../../utility/mindblooming_color_scheme.dart';
import '../question_text.dart';
import '../general_optional_text_entry.dart';

class MatrixProfileSingle extends StatefulWidget {
  final String questionText;
  final Map<String, dynamic> choices;
  final Map<String, dynamic> answers;
  final String surveyID;
  final String blockID;
  final String questionID;
  final bool disabled;

  MatrixProfileSingle({
    required this.questionText,
    required this.choices,
    required this.answers,
    required this.surveyID,
    required this.blockID,
    required this.questionID,
    required this.disabled,
  }) : super(key: Key(questionID));

  @override
  _MatrixProfileSingleState createState() => _MatrixProfileSingleState();
}

class _MatrixProfileSingleState extends State<MatrixProfileSingle> {
  @override
  void initState() {
    super.initState();
  }

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
                    Map<String, dynamic>.from(widget.answers[choice.key]),
                    widget.questionID,
                    widget.surveyID,
                    widget.disabled,
                  ),
                ),
              ),
            ],
          ),
        ),
        const Padding(padding: const EdgeInsets.only(bottom: 10.0)),
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
  bool expanded = false;
  late String _selectedChoice;

  @override
  void initState() {
    super.initState();
    final answers = Provider.of<Answers>(context, listen: false);
    final qid = widget.questionID;
    final cid = widget.choice.key;
    _selectedChoice =
        "${answers.getAnswer(widget.surveyID, "${qid}_$cid") ?? ''}";
  }

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
                    padding: const EdgeInsets.all(8.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(
                        'https://psicologiaunimib.qualtrics.com/CP/Graphic.php?IM=' +
                            value['Image']['ImageLocation'],
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;

                          return Center(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: CircularProgressIndicator(
                                value: loadingProgress.expectedTotalBytes !=
                                        null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
                                    : null,
                              ),
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
                    padding: const EdgeInsets.only(
                      top: 8,
                    ),
                    surveyID: widget.surveyID,
                    disabled: widget.disabled,
                  ),
                },
              ],
            ),
          ),
          Column(
            children: [
              ...widget.answers.entries.map(
                (answer) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 4.0,
                    ),
                    child: TextButton(
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        minimumSize: Size.zero,
                        foregroundColor: MindBloomingColorScheme.secondary,
                      ),
                      onPressed: widget.disabled
                          ? null
                          : () {
                              if (_selectedChoice == answer.key) {
                                _selectedChoice = '';
                                answers.removeAnswer(
                                  widget.surveyID,
                                  "${widget.questionID}_${widget.choice.key}",
                                );
                              } else {
                                _selectedChoice = answer.key;
                                answers.addAnswer(
                                  widget.surveyID,
                                  "${widget.questionID}_${widget.choice.key}",
                                  int.parse(_selectedChoice),
                                );
                              }
                            },
                      child: Ink(
                        decoration: BoxDecoration(
                          color: _selectedChoice == answer.key
                              ? MindBloomingColorScheme.secondary2shadow
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 4,
                            horizontal: 16,
                          ),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Container(
                                    height: 20,
                                    width: 20,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(100),
                                      border: Border.all(
                                        color: MindBloomingColorScheme
                                            .textColorDark1shadow,
                                        width: 1,
                                      ),
                                    ),
                                    child: Container(
                                      margin: const EdgeInsets.all(3),
                                      decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(100),
                                        color: _selectedChoice == answer.key
                                            ? MindBloomingColorScheme.secondary
                                            : Colors.transparent,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                        left: 10.0,
                                        right: 8,
                                      ),
                                      child: CustomHtmlWidget(
                                        questionText: answer.value['Display'],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              if (answer.value.containsKey('Image')) ...{
                                Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Image.network(
                                      'https://psicologiaunimib.qualtrics.com/CP/Graphic.php?IM=' +
                                          answer.value['Image']
                                              ['ImageLocation'],
                                      loadingBuilder:
                                          (context, child, loadingProgress) {
                                        if (loadingProgress == null) {
                                          return child;
                                        }

                                        return Center(
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: CircularProgressIndicator(
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
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
