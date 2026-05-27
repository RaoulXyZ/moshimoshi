import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../providers/answers.dart';
import '../../../utility/mindblooming_color_scheme.dart';
import '../../../utility/mindblooming_text_style.dart';
import '../question_text.dart';

class FormEntries extends StatelessWidget {
  final String questionText;
  final String questionID;
  final String surveyID;
  final String blockID;
  final Map<String, dynamic> choices;
  final bool disabled;

  FormEntries({
    required this.questionText,
    required this.questionID,
    required this.surveyID,
    required this.blockID,
    required this.choices,
    required this.disabled,
  }) : super(key: Key(questionID));

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        QuestionText(
          questionText: questionText,
          surveyID: surveyID,
          blockID: blockID,
          questionID: questionID,
        ),
        for (var choice in choices.entries)
          FormTextFieldWidget(
            questionText: questionText,
            questionID: "$questionID",
            label: choice.value['Display'],
            surveyID: surveyID,
            disabled: disabled,
            choiceID: choice.key,
          ),
      ],
    );
  }
}

class FormTextFieldWidget extends StatefulWidget {
  final String questionText;
  final String questionID;
  final String? label;
  final String surveyID;
  final String choiceID;
  final bool disabled;

  FormTextFieldWidget({
    required this.questionText,
    required this.questionID,
    required this.surveyID,
    required this.choiceID,
    required this.disabled,
    this.label,
  });

  @override
  _FormTextFieldWidget createState() => _FormTextFieldWidget();
}

class _FormTextFieldWidget extends State<FormTextFieldWidget> {
  final textController = TextEditingController();

  @override
  void initState() {
    super.initState();

    final answers = Provider.of<Answers>(context, listen: false);
    textController.text = answers.getAnswer(
          widget.surveyID,
          "${widget.questionID}_${widget.choiceID}",
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
    final answers = Provider.of<Answers>(context);

    return Container(
      margin: const EdgeInsets.only(
        bottom: 20.0,
        left: 30,
        right: 30,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: MindBloomingColorScheme.primary1shadow,
        border: Border.all(
          color: MindBloomingColorScheme.primary3shadow,
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: const EdgeInsets.only(
                  left: 20,
                  top: 21.5,
                ),
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: answers.hasAnswerChoice(
                    widget.surveyID,
                    widget.questionID,
                    widget.choiceID,
                  )
                      ? MindBloomingColorScheme.secondary
                      : MindBloomingColorScheme.tertiary,
                  borderRadius: BorderRadius.circular(100),
                ),
              ),
              if (widget.label != null)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(
                      top: 16,
                      left: 10,
                      right: 20,
                      bottom: 16,
                    ),
                    child: CustomHtmlWidget(
                      questionText: widget.label!,
                    ),
                  ),
                ),
            ],
          ),
          Container(
            margin: const EdgeInsets.only(bottom: 16, left: 16, right: 16),
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
                decoration: InputDecoration(
                  hintText: "Inserisci la risposta...",
                  hintStyle: MindBloomingTextStyle.normal.copyWith(
                    color: MindBloomingColorScheme.textColorDark1shadow,
                  ),
                  border: InputBorder.none,
                ),
                onChanged: (value) {
                  if (value != "") {
                    answers.addAnswer(
                      widget.surveyID,
                      "${widget.questionID}_${widget.choiceID}",
                      value,
                    );
                  } else {
                    answers.removeAnswer(
                      widget.surveyID,
                      "${widget.questionID}_${widget.choiceID}",
                    );
                  }
                },
                controller: textController,
                maxLines: null,
                minLines: 1,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
