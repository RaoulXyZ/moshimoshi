import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../providers/answers.dart';
import '../question_text.dart';
import './text_field_widget.dart';

class TextEntry extends StatelessWidget {
  final String questionText;
  final String questionID;
  final String surveyID;
  final String blockID;
  final bool disabled;

  TextEntry({
    required this.questionText,
    required this.questionID,
    required this.surveyID,
    required this.blockID,
    required this.disabled,
  }) : super(key: Key(questionID));

  @override
  Widget build(BuildContext context) {
    final answers = Provider.of<Answers>(context);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        color: answers.isWrong(questionID)
            ? Colors.red.shade100
            : Colors.white.withValues(alpha: 0),
      ),
      child: Column(
        children: [
          QuestionText(
            questionText: questionText,
            surveyID: surveyID,
            blockID: blockID,
            questionID: questionID,
          ),
          TextFieldWidget(
            questionText: questionText,
            questionID: questionID,
            surveyID: surveyID,
            disabled: disabled,
          ),
        ],
      ),
    );
  }
}
