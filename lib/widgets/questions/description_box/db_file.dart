import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../providers/answers.dart';
import '../../../utility.dart';
import '../question_text.dart';

class DBFile extends StatefulWidget {
  final String fileID;
  final String filesDescription;
  final String surveyID;
  final String blockID;
  final String questionID;

  DBFile({
    required this.fileID,
    required this.filesDescription,
    required this.surveyID,
    required this.blockID,
    required this.questionID,
  }) : super(key: Key(questionID));

  @override
  _DBFileState createState() => _DBFileState();
}

class _DBFileState extends State<DBFile> {
  @override
  void initState() {
    super.initState();
    final answers = Provider.of<Answers>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      answers.addAnswer(widget.surveyID, widget.questionID, '');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          QuestionText(
            questionText:
                "<a href=\"$baseFileUrl${widget.fileID}\" > ${widget.filesDescription} </a>",
            surveyID: widget.surveyID,
            blockID: widget.blockID,
            questionID: widget.questionID,
          ),
        ],
      ),
    );
  }
}
