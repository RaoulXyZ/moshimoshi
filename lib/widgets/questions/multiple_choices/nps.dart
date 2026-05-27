import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:provider/provider.dart';

import '../../../utility/mindblooming_text_style.dart';
import '../../../utility/mindblooming_color_scheme.dart';
import '../../../providers/answers.dart';
import '../question_text.dart';

class NPS extends StatefulWidget {
  final String questionText;
  final Map<String, dynamic> choices;
  final List<String> labels;
  final String questionID;
  final String surveyID;
  final String blockID;
  final bool disabled;

  NPS({
    required this.questionText,
    required this.choices,
    required this.labels,
    required this.surveyID,
    required this.blockID,
    required this.questionID,
    required this.disabled,
  }) : super(key: Key(questionID));

  @override
  _NPSState createState() => _NPSState();
}

class _NPSState extends State<NPS> {
  late String _selected;

  @override
  void initState() {
    super.initState();

    final answers = Provider.of<Answers>(context, listen: false);
    final answer = answers.getAnswer(widget.surveyID, "${widget.questionID}");

    if (answer != null) {
      _selected = answer.toString();
    } else {
      _selected = "5";
      answers.addAnswerSilently(widget.surveyID, widget.questionID, 5);
    }
  }

  @override
  Widget build(BuildContext context) {
    final answers = Provider.of<Answers>(context);

    return Column(
      children: [
        QuestionText(
          questionText: widget.questionText,
          surveyID: widget.surveyID,
          blockID: widget.blockID,
          questionID: widget.questionID,
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 30.0),
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
                Padding(
                  padding: const EdgeInsets.only(
                    left: 16.0,
                    right: 16.0,
                    top: 8.0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ...widget.labels.map(
                        (label) => Flexible(
                          child: HtmlWidget(
                            label,
                            textStyle: MindBloomingTextStyle.small.copyWith(
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              Padding(
                padding: const EdgeInsets.only(
                  right: 16.0,
                  left: 16.0,
                  bottom: 16,
                  top: 8.0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ...widget.choices.entries.map(
                      (choice) => GestureDetector(
                        onTap: widget.disabled
                            ? null
                            : () {
                                _selected = choice.key;
                                answers.addAnswer(
                                  widget.surveyID,
                                  widget.questionID,
                                  int.parse(_selected),
                                );
                              },
                        child: CircleAvatar(
                          backgroundColor: _selected == choice.key
                              ? MindBloomingColorScheme.secondary4shadow
                              : Colors.grey.shade200,
                          child: Container(
                            alignment: Alignment.center,
                            child: Text(
                              choice.value['Display'],
                              textAlign: TextAlign.center,
                              style: MindBloomingTextStyle.normal.copyWith(
                                color: _selected == choice.key
                                    ? MindBloomingColorScheme.textColorLight
                                    : MindBloomingColorScheme.textColorDark,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
