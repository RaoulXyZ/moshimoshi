import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/validation.dart';
import '../widgets/questions/text_entry/text_entry.dart';
import '../widgets/questions/text_entry/form_entries.dart';

Widget textEntryHandler(
  Map<String, dynamic> _element,
  BuildContext ctx,
  String surveyID,
  String blockID,
  bool disabled,
) {
  final String _questionText = _element['QuestionText'];
  final String _questionID = _element['QuestionID'];

  final _validation = Provider.of<Validation>(ctx, listen: false);
  final _validationSettings = _element['Validation'];

  if (_validationSettings['Settings']['Type'] != 'None') {
    _getValidation(surveyID, _validationSettings, _questionID, _validation);
  }

  if (_validationSettings['Settings']['ForceResponse'] == "ON") {
    _validation.addMustAnswer(surveyID, _questionID);
  }

  switch (_element['Selector']) {
    case 'FORM':
      return FormEntries(
        questionText: _questionText,
        questionID: _questionID,
        surveyID: surveyID,
        blockID: blockID,
        choices: _element['Choices'].isNotEmpty
            ? Map<String, dynamic>.from(_element['Choices'])
            : {},
        disabled: disabled,
      );

    case 'SL':
    default:
      return TextEntry(
        questionText: _questionText,
        questionID: _questionID,
        surveyID: surveyID,
        blockID: blockID,
        disabled: disabled,
      );
  }
}

void _getValidation(
  surveyID,
  _validationSettings,
  _questionID,
  Validation _validation,
) {
  int _pos = 0;

  if (_validationSettings['Settings']['Type'] == 'CustomValidation') {
    final _logic = _validationSettings['Settings']['CustomValidation']['Logic'];

    for (int i = 0; i < _logic['0'].length - 1; i++) {
      final _el = _logic['0']['$i'];
      final _choiceLocator = _el['ChoiceLocator'].split("q://$_questionID/")[1];
      final rightOperand = _el['RightOperand'];

      final bool ignoreCase =
          _el.containsKey('IgnoreCase') && _el['IgnoreCase'] == 1;

      if (_el.containsKey('Conjuction')) {
        if (_el['Conjuction'] == 'Or') {
          _pos++;
        }
      }

      if (_choiceLocator.contains('ChoiceTextEntryValue')) {
        if (_el['Operator'] == 'EqualTo' && ignoreCase) {
          _validation.addEqualIgnore(
            surveyID: surveyID,
            questionID: _questionID,
            rightOperand: rightOperand,
            accessKey: "${_questionID}_TEXT",
            pos: _pos,
          );
        } else if (_el['Operator'] == 'EqualTo') {
          _validation.addEqual(
            surveyID: surveyID,
            questionID: _questionID,
            rightOperand: rightOperand,
            accessKey: "${_questionID}_TEXT",
            pos: _pos,
          );
        } else if (_el['Operator'] == 'NotEqualTo' && ignoreCase) {
          _validation.addNotEqualIgnore(
            surveyID: surveyID,
            questionID: _questionID,
            rightOperand: rightOperand,
            accessKey: "${_questionID}_TEXT",
            pos: _pos,
          );
        } else if (_el['Operator'] == 'NotEqualTo') {
          _validation.addNotEqual(
            surveyID: surveyID,
            questionID: _questionID,
            rightOperand: rightOperand,
            accessKey: "${_questionID}_TEXT",
            pos: _pos,
          );
        } else if (_el['Operator'] == 'GreaterThan') {
          _validation.addGT(
            surveyID: surveyID,
            questionID: _questionID,
            rightOperand: rightOperand,
            accessKey: "${_questionID}_TEXT",
            pos: _pos,
          );
        } else if (_el['Operator'] == 'GreaterThanOrEqual') {
          _validation.addGTE(
            surveyID: surveyID,
            questionID: _questionID,
            rightOperand: rightOperand,
            accessKey: "${_questionID}_TEXT",
            pos: _pos,
          );
        } else if (_el['Operator'] == 'LessThan') {
          _validation.addLT(
            surveyID: surveyID,
            questionID: _questionID,
            rightOperand: rightOperand,
            accessKey: "${_questionID}_TEXT",
            pos: _pos,
          );
        } else if (_el['Operator'] == 'LessThanOrEqual') {
          _validation.addLTE(
            surveyID: surveyID,
            questionID: _questionID,
            rightOperand: rightOperand,
            accessKey: "${_questionID}_TEXT",
            pos: _pos,
          );
        } else if (_el['Operator'] == 'Empty') {
          _validation.addEmpty(
            surveyID: surveyID,
            questionID: _questionID,
            accessKey: "${_questionID}_TEXT",
            pos: _pos,
          );
        } else if (_el['Operator'] == 'NotEmpty') {
          _validation.addNotEmpty(
            surveyID: surveyID,
            questionID: _questionID,
            accessKey: "${_questionID}_TEXT",
            pos: _pos,
          );
        } else if (_el['Operator'] == 'Contains' && ignoreCase) {
          _validation.addContainsIgnore(
            surveyID: surveyID,
            questionID: _questionID,
            rightOperand: rightOperand,
            accessKey: "${_questionID}_TEXT",
            pos: _pos,
          );
        } else if (_el['Operator'] == 'Contains') {
          _validation.addContains(
            surveyID: surveyID,
            questionID: _questionID,
            rightOperand: rightOperand,
            accessKey: "${_questionID}_TEXT",
            pos: _pos,
          );
        } else if (_el['Operator'] == 'DoesNotContain' && ignoreCase) {
          _validation.addNotContainsIgnore(
            surveyID: surveyID,
            questionID: _questionID,
            rightOperand: rightOperand,
            accessKey: "${_questionID}_TEXT",
            pos: _pos,
          );
        } else if (_el['Operator'] == 'DoesNotContain') {
          _validation.addNotContains(
            surveyID: surveyID,
            questionID: _questionID,
            rightOperand: rightOperand,
            accessKey: "${_questionID}_TEXT",
            pos: _pos,
          );
        } else if (_el['Operator'] == 'MatchesRegex') {
          _validation.addRegex(
            surveyID: surveyID,
            questionID: _questionID,
            rightOperand: rightOperand,
            accessKey: "${_questionID}_TEXT",
            pos: _pos,
          );
        }
      }
    }
  } else if (_validationSettings['Settings']['Type'] == 'MinChar') {
    final minChar = _validationSettings['Settings']['MinChars'];
    _validation.addMinChar(
      surveyID: surveyID,
      questionID: _questionID,
      minChar: int.parse(minChar),
      accessKey: "${_questionID}_TEXT",
      pos: 0,
    );
  } else if (_validationSettings['Settings']['Type'] == 'TotalChar') {
    final totalChar = _validationSettings['Settings']['TotalChars'];
    _validation.addTotalChar(
      surveyID: surveyID,
      questionID: _questionID,
      totalChar: int.parse(totalChar),
      accessKey: "${_questionID}_TEXT",
      pos: 0,
    );
  } else if (_validationSettings['Settings']['Type'] == 'CharRange') {
    final totalChar = _validationSettings['Settings']['TotalChars'];
    final minChar = _validationSettings['Settings']['MinChars'];

    _validation.addMinChar(
      surveyID: surveyID,
      questionID: _questionID,
      minChar: int.parse(minChar),
      accessKey: "${_questionID}_TEXT",
      pos: 0,
    );

    _validation.addTotalChar(
      surveyID: surveyID,
      questionID: _questionID,
      totalChar: int.parse(totalChar),
      accessKey: "${_questionID}_TEXT",
      pos: 0,
    );
  }
}
