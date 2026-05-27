import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../widgets/questions/pick_group_rank/pick_group_rank.dart';
import '../utility.dart';
import '../providers/validation.dart';

Widget pickGroupRankHandler(
  Map<String, dynamic> _element,
  BuildContext ctx,
  String surveyID,
  String blockID,
  bool disabled,
) {
  final Map<String, dynamic> _localChoices = getChoices(_element);
  final List<String> _groups = [];
  final String _questionText = _element['QuestionText'];
  final String _questionID = _element['QuestionID'];

  final _validation = Provider.of<Validation>(ctx, listen: false);
  final _validationSettings = _element['Validation'];

  if (_validationSettings['Settings']['ForceResponse'] == "ON") {
    _validation.addMustAnswer(surveyID, _questionID);
  }

  for (int k = 0; k < _element['Groups'].length; k++) {
    _groups.add(_element['Groups'][k]);
  }

  return PickGroupRank(
    questionText: _questionText,
    choices: _localChoices,
    groups: _groups,
    surveyID: surveyID,
    blockID: blockID,
    questionID: _questionID,
    disabled: disabled,
  );
}
