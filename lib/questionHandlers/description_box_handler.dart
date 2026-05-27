import 'package:flutter/material.dart';

import '../widgets/questions/description_box/db_text_box.dart';
import '../widgets/questions/description_box/db_graphics_box.dart';
import '../widgets/questions/description_box/db_file.dart';

Widget descriptionBoxHandler(
  Map<String, dynamic> _element,
  String surveyID,
  String blockID,
) {
  final String _questionText = _element['QuestionText'];
  Widget _ret = const SizedBox();

  if (_element['Selector'] == 'TB') {
    _ret = DBTextBox(
      questionText: _questionText,
      surveyID: surveyID,
      blockID: blockID,
      questionID: _element['QuestionID'],
    );
  } else if (_element['Selector'] == 'GRB') {
    _ret = DBGraphicsBox(
      element: _element,
      surveyID: surveyID,
      blockID: blockID,
      questionID: _element['QuestionID'],
    );
  } else if (_element['Selector'] == 'FLB') {
    // TODO Gestire se c'è più di un file
    _ret = DBFile(
      fileID: _element['Files'],
      filesDescription: _element['FilesDescription'],
      surveyID: surveyID,
      blockID: blockID,
      questionID: _element['QuestionID'],
    );
  }

  return _ret;
}
