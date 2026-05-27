import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../providers/answers.dart';
//import '../general_optional_text_entry.dart';
import '../../../utility/mindblooming_color_scheme.dart';
import '../../../utility/mindblooming_text_style.dart';
import '../question_text.dart';
import '../general_optional_text_entry.dart';

class SideBySide extends StatefulWidget {
  final String questionText;
  final Map<String, dynamic> choices;
  final Map<String, dynamic> additonalQuestions;
  final String surveyID;
  final String blockID;
  final String questionID;
  final bool disabled;

  SideBySide({
    required this.questionText,
    required this.choices,
    required this.additonalQuestions,
    required this.surveyID,
    required this.blockID,
    required this.questionID,
    required this.disabled,
  }) : super(key: Key(questionID));

  @override
  _SideBySideState createState() => _SideBySideState();
}

class _SideBySideState extends State<SideBySide> {
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
        ...widget.choices.entries.map(
          (choice) => Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 30,
              vertical: 10,
            ),
            child: AdditionalQuestions(
              choice,
              widget.additonalQuestions,
              widget.surveyID,
              widget.disabled,
            ),
          ),
        ),
        const Padding(
          padding: const EdgeInsets.only(bottom: 10),
        ),
      ],
    );
  }
}

class AdditionalQuestions extends StatefulWidget {
  final MapEntry<String, dynamic> choice;
  final Map<String, dynamic> additionalQuestions;
  final String surveyID;
  final bool disabled;

  AdditionalQuestions(
    this.choice,
    this.additionalQuestions,
    this.surveyID,
    this.disabled,
  );

  @override
  _AdditionalQuestionsState createState() => _AdditionalQuestionsState();
}

class _AdditionalQuestionsState extends State<AdditionalQuestions> {
  bool expanded = false;

  @override
  Widget build(BuildContext context) {
    final value = widget.choice.value;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: MindBloomingColorScheme.primary1shadow,
        border: Border.all(
          color: MindBloomingColorScheme.primary3shadow,
          width: 0.5,
        ),
      ),
      child: Column(
        children: [
          Container(
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(10),
                topRight: Radius.circular(10),
              ),
              color: MindBloomingColorScheme.primary2shadow,
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: CustomHtmlWidget(
                              questionText: value['Display'],
                            ),
                          ),
                        ],
                      ),
                      if (value.containsKey('Image')) ...{
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.network(
                              'https://psicologiaunimib.qualtrics.com/CP/Graphic.php?IM=' +
                                  value['Image']['ImageLocation'],
                              loadingBuilder:
                                  (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;

                                return Center(
                                  child: CircularProgressIndicator(
                                    value: loadingProgress.expectedTotalBytes !=
                                            null
                                        ? loadingProgress
                                                .cumulativeBytesLoaded /
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
                        if (value['TextEntry'] == 'true') ...{
                          GeneralOptionalTextEntry(
                            surveyID: widget.surveyID,
                            disabled: widget.disabled,
                            choice: widget.choice,
                            questionID: '',
                            padding: const EdgeInsets.only(
                              top: 8,
                            ),
                          ),
                        },
                      },
                    ],
                  ),
                ),
                const Divider(
                  thickness: 1,
                  height: 1,
                ),
              ],
            ),
          ),
          ...widget.additionalQuestions.values.map(
            (question) {
              Widget _response = const SizedBox();

              if (question['Selector'] == 'Likert') {
                if (question['SubSelector'] == 'SingleAnswer') {
                  _response = SingleAnswer(
                    question: Map<String, dynamic>.from(question),
                    choiceID: widget.choice.key,
                    surveyID: widget.surveyID,
                    disabled: widget.disabled,
                  );
                } else if (question['SubSelector'] == 'MultipleAnswer') {
                  _response = MultipleAnswer(
                    question: Map<String, dynamic>.from(question),
                    choiceID: widget.choice.key,
                    surveyID: widget.surveyID,
                    disabled: widget.disabled,
                  );
                } else if (question['SubSelector'] == 'DL') {
                  _response = DropdownAnswer(
                    question: Map<String, dynamic>.from(question),
                    choiceID: widget.choice.key,
                    surveyID: widget.surveyID,
                    disabled: widget.disabled,
                  );
                }
              } else if (question['Selector'] == 'TE') {
                _response = TextEntryAnswer(
                  question: Map<String, dynamic>.from(question),
                  choiceID: widget.choice.key,
                  surveyID: widget.surveyID,
                  disabled: widget.disabled,
                );
              }

              return Column(
                children: [
                  _response,
                  if (question != widget.additionalQuestions.values.last)
                    const Divider(height: 1, thickness: 1),
                ],
              );
            },
          ),
          const Padding(
            padding: const EdgeInsets.only(
              bottom: 10,
            ),
          ),
        ],
      ),
    );
  }
}

class SingleAnswer extends StatefulWidget {
  final Map<String, dynamic> question;
  final String choiceID;
  final String surveyID;
  final bool disabled;

  const SingleAnswer({
    super.key,
    required this.question,
    required this.choiceID,
    required this.surveyID,
    required this.disabled,
  });

  @override
  _SingleAnswerState createState() => _SingleAnswerState();
}

class _SingleAnswerState extends State<SingleAnswer> {
  late String selected;

  @override
  void initState() {
    super.initState();

    final answers = Provider.of<Answers>(context, listen: false);
    selected = "${answers.getAnswer(
          widget.surveyID,
          "${widget.question['QuestionID']}_${widget.choiceID}",
        ) ?? ''}";
  }

  @override
  Widget build(BuildContext context) {
    final answers = Provider.of<Answers>(context);

    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: const EdgeInsets.only(
                left: 20,
                top: 21,
              ),
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: answers.hasAnswerChoice(
                  widget.surveyID,
                  widget.question['QuestionID'],
                  widget.choiceID,
                )
                    ? MindBloomingColorScheme.secondary
                    : MindBloomingColorScheme.tertiary,
                borderRadius: BorderRadius.circular(100),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(
                  top: 16,
                  bottom: 16,
                  right: 20,
                  left: 10,
                ),
                child: CustomHtmlWidget(
                  questionText: widget.question['QuestionText'],
                ),
              ),
            ),
          ],
        ),
        if (widget.question.containsKey('ImageLocation')) ...{
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.network(
              'https://psicologiaunimib.qualtrics.com/CP/Graphic.php?IM=' +
                  widget.question['ImageLocation'],
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;

                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                          : null,
                    ),
                  ),
                );
              },
            ),
          ),
        },
        ...widget.question['Answers'].entries.map(
          (answer) => Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 4.0,
              horizontal: 20,
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
                      if (selected == answer.key) {
                        selected = '';
                        answers.removeAnswer(
                          widget.surveyID,
                          "${widget.question['QuestionID']}_${widget.choiceID}",
                        );
                      } else {
                        selected = answer.key;
                        answers.addAnswer(
                          widget.surveyID,
                          "${widget.question['QuestionID']}_${widget.choiceID}",
                          int.parse(selected),
                        );
                      }
                    },
              child: Ink(
                decoration: BoxDecoration(
                  color: selected == answer.key
                      ? MindBloomingColorScheme.secondary2shadow
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 4,
                  ),
                  child: Row(
                    children: [
                      Container(
                        height: 20,
                        width: 20,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(100),
                          border: Border.all(
                            color: MindBloomingColorScheme.textColorDark1shadow,
                            width: 1,
                          ),
                        ),
                        child: Container(
                          margin: const EdgeInsets.all(3),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(100),
                            color: selected == answer.key
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
                ),
              ),
            ),
          ),
        ),
        const Padding(padding: const EdgeInsets.only(bottom: 16.0)),
      ],
    );
  }
}

class MultipleAnswer extends StatefulWidget {
  final Map<String, dynamic> question;
  final String choiceID;
  final String surveyID;
  final bool disabled;

  const MultipleAnswer({
    super.key,
    required this.question,
    required this.choiceID,
    required this.surveyID,
    required this.disabled,
  });

  @override
  _MultipleAnswerState createState() => _MultipleAnswerState();
}

class _MultipleAnswerState extends State<MultipleAnswer> {
  List<String> selected = [];

  @override
  void initState() {
    super.initState();

    final answers = Provider.of<Answers>(context, listen: false);
    selected = answers.getAnswer(
          widget.surveyID,
          "${widget.question['QuestionID']}_${widget.choiceID}",
        ) ??
        [];
  }

  @override
  Widget build(BuildContext context) {
    final answers = Provider.of<Answers>(context);

    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: const EdgeInsets.only(
                left: 20,
                top: 21,
              ),
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: answers.hasAnswerChoice(
                  widget.surveyID,
                  widget.question['QuestionID'],
                  widget.choiceID,
                )
                    ? MindBloomingColorScheme.secondary
                    : MindBloomingColorScheme.tertiary,
                borderRadius: BorderRadius.circular(100),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(
                  top: 16,
                  bottom: 16,
                  right: 20,
                  left: 10,
                ),
                child: CustomHtmlWidget(
                  questionText: widget.question['QuestionText'],
                ),
              ),
            ),
          ],
        ),
        if (widget.question.containsKey('ImageLocation')) ...{
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.network(
              'https://psicologiaunimib.qualtrics.com/CP/Graphic.php?IM=' +
                  widget.question['ImageLocation'],
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;

                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                          : null,
                    ),
                  ),
                );
              },
            ),
          ),
        },
        ...widget.question['Answers'].entries.map(
          (answer) => Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 4.0,
              horizontal: 20,
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
                      if (selected.contains(answer.key)) {
                        selected.remove(answer.key);
                      } else {
                        selected.add(answer.key);
                      }

                      if (selected.isEmpty) {
                        answers.removeAnswer(
                          widget.surveyID,
                          "${widget.question['QuestionID']}_${widget.choiceID}",
                        );
                      } else {
                        answers.addAnswer(
                          widget.surveyID,
                          "${widget.question['QuestionID']}_${widget.choiceID}",
                          selected,
                        );
                      }
                    },
              child: Ink(
                decoration: BoxDecoration(
                  color: selected.contains(answer.key)
                      ? MindBloomingColorScheme.secondary2shadow
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 4,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 20,
                        width: 20,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          border: Border.all(
                            color: MindBloomingColorScheme.textColorDark1shadow,
                            width: 1,
                          ),
                        ),
                        child: Container(
                          margin: const EdgeInsets.all(3),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(2.5),
                            color: selected.contains(answer.key)
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
                ),
              ),
            ),
          ),
        ),
        const Padding(padding: const EdgeInsets.only(bottom: 16.0)),
      ],
    );
  }
}

class DropdownAnswer extends StatefulWidget {
  final Map<String, dynamic> question;
  final String choiceID;
  final String surveyID;
  final bool disabled;

  const DropdownAnswer({
    super.key,
    required this.question,
    required this.choiceID,
    required this.surveyID,
    required this.disabled,
  });

  @override
  _DropdownAnswerState createState() => _DropdownAnswerState();
}

class _DropdownAnswerState extends State<DropdownAnswer> {
  String? _value;

  @override
  void initState() {
    super.initState();

    final answers = Provider.of<Answers>(context, listen: false);
    final savedValue = answers.getAnswer(
      widget.surveyID,
      "${widget.question['QuestionID']}_${widget.choiceID}",
    );

    _value = savedValue != null ? savedValue.toString() : null;
  }

  @override
  Widget build(BuildContext context) {
    final answers = Provider.of<Answers>(context);
    final questionAnswers =
        Map<String, dynamic>.from(widget.question['Answers']);

    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: const EdgeInsets.only(
                left: 20,
                top: 21,
              ),
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: answers.hasAnswerChoice(
                  widget.surveyID,
                  widget.question['QuestionID'],
                  widget.choiceID,
                )
                    ? MindBloomingColorScheme.secondary
                    : MindBloomingColorScheme.tertiary,
                borderRadius: BorderRadius.circular(100),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(
                  top: 16,
                  bottom: 16,
                  right: 20,
                  left: 10,
                ),
                child: CustomHtmlWidget(
                  questionText: widget.question['QuestionText'],
                ),
              ),
            ),
          ],
        ),
        if (widget.question.containsKey('ImageLocation')) ...{
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.network(
              'https://psicologiaunimib.qualtrics.com/CP/Graphic.php?IM=' +
                  widget.question['ImageLocation'],
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;

                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                          : null,
                    ),
                  ),
                );
              },
            ),
          ),
        },
        Container(
          margin: const EdgeInsets.symmetric(
            vertical: 4.0,
            horizontal: 20,
          ),
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
          child: SizedBox(
            height: _textSize(
                  _value != null ? questionAnswers[_value]['Display'] : " ",
                  context,
                  170,
                ).height +
                28,
            child: DropdownButtonHideUnderline(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5.0),
                child: DropdownButton2(
                  isDense: true,
                  style: MindBloomingTextStyle.normal,
                  menuItemStyleData: MenuItemStyleData(
                    customHeights: [
                      for (var i = 0; i < questionAnswers.length; i++)
                        _textSize(
                              questionAnswers.entries
                                  .elementAt(i)
                                  .value['Display'],
                              context,
                              140,
                            ).height +
                            20,
                    ],
                  ),
                  items: questionAnswers.entries
                      .map(
                        (e) => DropdownMenuItem(
                          value: e.key,
                          child: Text(
                            e.value['Display'],
                            style: MindBloomingTextStyle.normal,
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: widget.disabled
                      ? null
                      : (String? val) {
                          if (val != null) {
                            _value = val;
                            answers.addAnswer(
                              widget.surveyID,
                              "${widget.question['QuestionID']}_${widget.choiceID}",
                              int.parse(val),
                            );
                          }
                        },
                  value: _value,
                  iconStyleData: const IconStyleData(
                    icon: Icon(
                      Icons.expand_more,
                    ),
                  ),
                  isExpanded: true,
                ),
              ),
            ),
          ),
        ),
        const Padding(padding: EdgeInsets.only(bottom: 16.0)),
      ],
    );
  }
}

class TextEntryAnswer extends StatefulWidget {
  final Map<String, dynamic> question;
  final String choiceID;
  final String surveyID;
  final bool disabled;

  TextEntryAnswer({
    required this.question,
    required this.choiceID,
    required this.surveyID,
    required this.disabled,
  });

  @override
  _TextEntryAnswerState createState() => _TextEntryAnswerState();
}

class _TextEntryAnswerState extends State<TextEntryAnswer> {
  @override
  Widget build(BuildContext context) {
    final answers = Provider.of<Answers>(context);

    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: const EdgeInsets.only(
                left: 20,
                top: 21,
              ),
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: answers.hasAnswerChoice(
                  widget.surveyID,
                  widget.question['QuestionID'],
                  widget.choiceID,
                  hasAnswer: true,
                )
                    ? MindBloomingColorScheme.secondary
                    : MindBloomingColorScheme.tertiary,
                borderRadius: BorderRadius.circular(100),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(
                  top: 16,
                  bottom: 16,
                  right: 20,
                  left: 10,
                ),
                child: CustomHtmlWidget(
                  questionText: widget.question['QuestionText'],
                ),
              ),
            ),
          ],
        ),
        if (widget.question.containsKey('ImageLocation')) ...{
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.network(
              'https://psicologiaunimib.qualtrics.com/CP/Graphic.php?IM=' +
                  widget.question['ImageLocation'],
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;

                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                          : null,
                    ),
                  ),
                );
              },
            ),
          ),
        },
        ...widget.question['Answers'].entries.map(
          (answer) => SBSAnswerTextEntry(
            answer: answer,
            choiceID: widget.choiceID,
            questionID: widget.question['QuestionID'],
            surveyID: widget.surveyID,
            disabled: widget.disabled,
          ),
        ),
      ],
    );
  }
}

class SBSAnswerTextEntry extends StatefulWidget {
  const SBSAnswerTextEntry({
    super.key,
    required this.answer,
    required this.choiceID,
    required this.questionID,
    required this.surveyID,
    required this.disabled,
  });

  final MapEntry<dynamic, dynamic> answer;
  final String questionID;
  final String choiceID;
  final String surveyID;
  final bool disabled;

  @override
  _SBSAnswerTextEntryState createState() => _SBSAnswerTextEntryState();
}

class _SBSAnswerTextEntryState extends State<SBSAnswerTextEntry> {
  final textController = TextEditingController();

  @override
  void initState() {
    super.initState();

    final answers = Provider.of<Answers>(context, listen: false);
    textController.text = answers.getAnswer(
          widget.surveyID,
          "${widget.questionID}_${widget.choiceID}_${widget.answer.key}",
        ) ??
        '';
  }

  @override
  void dispose() {
    textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final answers = Provider.of<Answers>(context, listen: false);

    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 8.0,
        horizontal: 20,
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Row(
              children: [
                Expanded(
                  child: CustomHtmlWidget(
                    questionText: widget.answer.value['Display'],
                  ),
                ),
              ],
            ),
          ),
          Container(
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
                maxLines: null,
                minLines: 1,
                decoration: InputDecoration(
                  hintText: "Inserisci la risposta...",
                  hintStyle: MindBloomingTextStyle.normal.copyWith(
                    color: MindBloomingColorScheme.textColorDark1shadow,
                  ),
                  border: InputBorder.none,
                ),
                onChanged: (value) {
                  if (value.isNotEmpty) {
                    answers.addAnswer(
                      widget.surveyID,
                      "${widget.questionID}_${widget.choiceID}_${widget.answer.key}",
                      value,
                    );
                  } else {
                    answers.removeAnswer(
                      widget.surveyID,
                      "${widget.questionID}_${widget.choiceID}_${widget.answer.key}",
                    );
                  }
                },
                controller: textController,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Size _textSize(String text, context, int offset) {
  return (TextPainter(
    text: TextSpan(text: text, style: MindBloomingTextStyle.normal),
    textScaler: MediaQuery.of(context).textScaler,
    textDirection: TextDirection.ltr,
  )..layout(maxWidth: MediaQuery.of(context).size.width - offset))
      .size;
}
