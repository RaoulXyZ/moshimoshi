import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../widgets/questions/rank_order/rank_order.dart';
import '../utility.dart';
import '../providers/validation.dart';

Widget rankOrderHandler(
  Map<String, dynamic> _element,
  BuildContext ctx,
  String surveyID,
  String blockID,
  bool disabled,
) {
  final Map<String, dynamic> _localChoices = getChoices(_element);
  final String _questionText = _element['QuestionText'];
  final String _questionID = _element['QuestionID'];

  final _validation = Provider.of<Validation>(ctx, listen: false);
  final _validationSettings = _element['Validation'];

  if (_validationSettings['Settings']['ForceResponse'] == "ON") {
    _validation.addMustAnswer(surveyID, _questionID);
  }

  return RankOrder(
    questionText: _questionText,
    choices: _localChoices,
    surveyID: surveyID,
    blockID: blockID,
    questionID: _questionID,
    disabled: disabled,
  );
}
