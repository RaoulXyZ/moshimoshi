import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../providers/answers.dart';
import '../question_text.dart';

class DBGraphicsBox extends StatefulWidget {
  final Map<String, dynamic> element;
  final String surveyID;
  final String blockID;
  final String questionID;

  DBGraphicsBox({
    required this.element,
    required this.surveyID,
    required this.blockID,
    required this.questionID,
  }) : super(key: Key(questionID));

  @override
  _DBGraphicsBoxState createState() => _DBGraphicsBoxState();
}

class _DBGraphicsBoxState extends State<DBGraphicsBox> {
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
          if (widget.element['SubSelector'] == 'WTXB')
            QuestionText(
              questionText: widget.element['QuestionText'],
              surveyID: widget.surveyID,
              blockID: widget.blockID,
              questionID: widget.questionID,
            ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Image.network(
              'https://psicologiaunimib.qualtrics.com/CP/Graphic.php?IM=' +
                  widget.element['Graphics'],
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
        ],
      ),
    );
  }
}
