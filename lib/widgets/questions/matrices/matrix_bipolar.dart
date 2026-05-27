import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:provider/provider.dart';

import '../../../utility/mindblooming_text_style.dart';
import '../../../providers/answers.dart';
import '../../../utility/mindblooming_color_scheme.dart';
import '../question_text.dart';

class MatrixBipolar extends StatefulWidget {
  final String questionText;
  final Map<String, dynamic> choices;
  final Map<String, dynamic> answers;
  final List<String> labels;
  final String surveyID;
  final String blockID;
  final String questionID;
  final bool disabled;

  MatrixBipolar({
    required this.questionText,
    required this.choices,
    required this.answers,
    required this.labels,
    required this.surveyID,
    required this.blockID,
    required this.questionID,
    required this.disabled,
  }) : super(key: Key(questionID));

  @override
  _MatrixBipolarState createState() => _MatrixBipolarState();
}

class _MatrixBipolarState extends State<MatrixBipolar> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final answers = Provider.of<Answers>(context);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        color: answers.isWrong(widget.questionID)
            ? Colors.red.shade100
            : Colors.white.withValues(alpha: 0),
      ),
      child: Column(
        children: [
          QuestionText(
            questionText: widget.questionText,
            surveyID: widget.surveyID,
            blockID: widget.blockID,
            questionID: widget.questionID,
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 30.0),
            padding: const EdgeInsets.all(16),
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
                if (widget.labels.isNotEmpty)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width * 0.15,
                      ),
                      ...widget.labels.map(
                        (label) => Flexible(
                          child: HtmlWidget(
                            '<div style="text-align:center">' +
                                label +
                                '</div>',
                            textStyle: MindBloomingTextStyle.small.copyWith(
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width * 0.15,
                      ),
                    ],
                  ),
                ...widget.choices.entries.map(
                  (choice) => Column(
                    children: [
                      CustomRadio(
                        answers: widget.answers,
                        choice: choice,
                        questionID: widget.questionID,
                        surveyID: widget.surveyID,
                        disabled: widget.disabled,
                      ),
                      if (choice.key != widget.choices.entries.last.key)
                        const Divider(),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Padding(padding: const EdgeInsets.only(bottom: 20.0)),
        ],
      ),
    );
  }
}

class CustomRadio extends StatefulWidget {
  final Map<String, dynamic> answers;
  final MapEntry<String, dynamic> choice;
  final String questionID;
  final String surveyID;
  final bool disabled;

  CustomRadio({
    required this.answers,
    required this.choice,
    required this.questionID,
    required this.surveyID,
    required this.disabled,
  });

  @override
  _CustomRadioState createState() => _CustomRadioState();
}

class _CustomRadioState extends State<CustomRadio> {
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

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: MediaQuery.of(context).size.width * 0.15,
            alignment: Alignment.centerLeft,
            child: CustomHtmlWidget(
              questionText: widget.choice.value['Display']
                  .split(RegExp(r"(?<!\\):"))[0]
                  .replaceAll(RegExp(r"\\"), ''),
            ),
          ),
          ...widget.answers.entries.map(
            (answer) => Expanded(
              child: TextButton(
                child: Container(
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
                      color: _selectedChoice == answer.key
                          ? MindBloomingColorScheme.secondary
                          : Colors.transparent,
                    ),
                  ),
                ),
                onPressed: widget.disabled
                    ? null
                    : () {
                        _selectedChoice = answer.key;
                        answers.addAnswer(
                          widget.surveyID,
                          "${widget.questionID}_${widget.choice.key}",
                          int.parse(answer.key),
                        );
                      },
              ),
            ),
          ),
          Container(
            width: MediaQuery.of(context).size.width * 0.15,
            alignment: Alignment.centerRight,
            child: CustomHtmlWidget(
              questionText: widget.choice.value['Display']
                  .split(RegExp(r"(?<!\\):"))[1]
                  .replaceAll(RegExp(r"\\"), ''),
            ),
          ),
        ],
      ),
    );
  }
}
