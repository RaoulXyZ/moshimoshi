import 'package:flutter/material.dart';

import '../widgets/questions/constant_sum/constant_sum.dart';

Widget constantSumHandler(
  Map<String, dynamic> _element,
  String surveyID,
  String blockID,
  bool disabled,
) {
  final Map<String, dynamic> _localChoices = _getChoices(_element);

  return ConstantSum(
    surveyID: surveyID,
    blockID: blockID,
    disabled: disabled,
    questionID: _element['QuestionID'],
    questionText: _element['QuestionText'],
    choices: _localChoices,
  );
}

Map<String, dynamic> _getChoices(Map<String, dynamic> _element) {
  final Map<String, dynamic> _localChoices = {};
  for (int k = 0; k < _element['Choices'].length; k++) {
    final String _key = _element['ChoiceOrder'][k].toString();

    _localChoices.putIfAbsent(_key, () => _element['Choices'][_key]);
    _localChoices[_key]['Display'] = _localChoices[_key]['Display'];
  }

  return _localChoices;
}
