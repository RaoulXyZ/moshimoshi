import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../question_text.dart';
import '../../../providers/answers.dart';

class DBTextBox extends StatefulWidget {
  final String questionText;
  final String surveyID;
  final String blockID;
  final String questionID;

  DBTextBox({
    required this.questionText,
    required this.surveyID,
    required this.blockID,
    required this.questionID,
  }) : super(key: Key(questionID));

  @override
  _DBTextBoxState createState() => _DBTextBoxState();
}

class _DBTextBoxState extends State<DBTextBox> {
  @override
  void initState() {
    final answers = Provider.of<Answers>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      answers.addAnswer(widget.surveyID, widget.questionID, '');
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          QuestionText(
            questionText: widget.questionText,
            surveyID: widget.surveyID,
            blockID: widget.blockID,
            questionID: widget.questionID,
          ),
        ],
      ),
    );
  }
}
