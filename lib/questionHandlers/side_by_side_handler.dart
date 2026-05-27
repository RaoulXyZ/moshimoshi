import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:provider/provider.dart';

import '../providers/validation.dart';
import '../widgets/questions/side_by_side/side_by_side.dart';
import '../utility.dart';

Widget sideBySideHandler(
  Map<String, dynamic> _element,
  BuildContext ctx,
  String surveyID,
  String blockID,
  bool disabled,
) {
  final Map<String, dynamic> _localChoices = getChoices(_element);
  Map<String, dynamic> _additionalQuestions = {};
  final String _questionText = _element['QuestionText'];
  final String _questionID = _element['QuestionID'];

  final _validation = Provider.of<Validation>(ctx, listen: false);
  final _validationSettings = _element['Validation'];

  if (_validationSettings['Settings']['Type'] != 'None') {
    _getValidation(surveyID, _element, _questionID, _validation);
  }

  if (_validationSettings['Settings']['ForceResponse'] == "ON") {
    _validation.addMustAnswer(surveyID, _questionID);
  }

  _additionalQuestions =
      Map<String, dynamic>.from(_element['AdditionalQuestions']);

  for (int k = 0; k < _additionalQuestions.length; k++) {
    _additionalQuestions['${k + 1}']['QuestionText'] = utf8.decode(
      _additionalQuestions['${k + 1}']['QuestionText'].runes.toList(),
    );

    for (int l = 0;
        l < _additionalQuestions['${k + 1}']['Answers'].length;
        l++) {
      _additionalQuestions['${k + 1}']['Answers']['${l + 1}']['Display'] =
          _additionalQuestions['${k + 1}']['Answers']['${l + 1}']['Display'];
    }
  }

  return SideBySide(
    questionText: _questionText,
    choices: _localChoices,
    additonalQuestions: _additionalQuestions,
    surveyID: surveyID,
    blockID: blockID,
    questionID: _questionID,
    disabled: disabled,
  );
}

void _getValidation(surveyID, _element, _questionID, Validation _validation) {
  int _pos = 0;
  final _validationSettings = _element['Validation'];

  if (_validationSettings['Settings']['Type'] == 'CustomValidation') {
    final _logic = _validationSettings['Settings']['CustomValidation']['Logic'];

    for (int i = 0; i < _logic['0'].length - 1; i++) {
      final _el = _logic['0']['$i'];
      final _choiceLocator = _el['ChoiceLocator'];
      final rightOperand = _el['RightOperand'];

      if (_el.containsKey('Conjuction')) {
        if (_el['Conjuction'] == 'Or') {
          _pos++;
        }
      }

      if (_choiceLocator.contains('SelectableAnswer')) {
        if (_el['Operator'] == 'Selected') {
          final _choiceID = _el['ChoiceLocator'].split("SelectableAnswer/")[1];
          final _choiceCount = _element['Choices'].length;

          _validation.addMatrixWhitelist(
            surveyID: surveyID,
            questionID: _questionID,
            choiceID: _choiceID,
            accessKey: _el['QuestionIDFromLocator'],
            pos: _pos,
            choiceCount: _choiceCount,
          );
        } else if (_el['Operator'] == 'NotSelected') {
          final _choiceID = _el['ChoiceLocator'].split("SelectableAnswer/")[1];
          final _choiceCount = _element['Choices'].length;

          _validation.addMatrixBlacklist(
            surveyID: surveyID,
            questionID: _questionID,
            choiceID: _choiceID,
            accessKey: _el['QuestionIDFromLocator'],
            pos: _pos,
            choiceCount: _choiceCount,
          );
        }
      } else if (_choiceLocator.contains('SelectableChoice')) {
        if (_el['Operator'] == 'Selected') {
          final _locator = _el['ChoiceLocator'].split("SelectableChoice/")[1];
          final split = _locator.split("/");
          final _answerID = split[1];
          final _choiceID = split[0];

          _validation.addToWhitelist(
            surveyID: surveyID,
            questionID: _questionID,
            choiceID: _answerID,
            accessKey: "${_el['QuestionIDFromLocator']}_$_choiceID",
            pos: _pos,
          );
        } else if (_el['Operator'] == 'NotSelected') {
          final _locator = _el['ChoiceLocator'].split("SelectableChoice/")[1];
          final _choiceID = _locator.split("/")[0];
          final _answerID = _locator.split("/")[1];

          _validation.addToBlacklist(
            surveyID: surveyID,
            questionID: _questionID,
            choiceID: _answerID,
            accessKey: "${_el['QuestionIDFromLocator']}_$_choiceID",
            pos: _pos,
          );
        }
      } else if (_choiceLocator.contains('SelectedAnswerCount')) {
        final _choiceID = _el['ChoiceLocator'].split("SelectedAnswerCount/")[1];

        if (_el['Operator'] == 'EqualTo') {
          _validation.addEqualLengthMatrix(
            surveyID: surveyID,
            questionID: _questionID,
            nChoices: int.parse(rightOperand),
            accessKey: _el['QuestionIDFromLocator'],
            pos: _pos,
            choiceID: int.parse(_choiceID),
          );
        } else if (_el['Operator'] == 'NotEqualTo') {
          _validation.addNotEqualLengthMatrix(
            surveyID: surveyID,
            questionID: _questionID,
            nChoices: int.parse(rightOperand),
            accessKey: _el['QuestionIDFromLocator'],
            pos: _pos,
            choiceID: int.parse(_choiceID),
          );
        } else if (_el['Operator'] == 'GreaterThan') {
          _validation.addGTLengthMatrix(
            surveyID: surveyID,
            questionID: _questionID,
            nChoices: int.parse(rightOperand),
            accessKey: _el['QuestionIDFromLocator'],
            pos: _pos,
            choiceID: int.parse(_choiceID),
          );
        } else if (_el['Operator'] == 'GreaterThanOrEqual') {
          _validation.addGTELengthMatrix(
            surveyID: surveyID,
            questionID: _questionID,
            nChoices: int.parse(rightOperand),
            accessKey: _el['QuestionIDFromLocator'],
            pos: _pos,
            choiceID: int.parse(_choiceID),
          );
        } else if (_el['Operator'] == 'LessThan') {
          _validation.addLTLengthMatrix(
            surveyID: surveyID,
            questionID: _questionID,
            nChoices: int.parse(rightOperand),
            accessKey: _el['QuestionIDFromLocator'],
            pos: _pos,
            choiceID: int.parse(_choiceID),
          );
        } else if (_el['Operator'] == 'LessThanOrEqual') {
          _validation.addLTELengthMatrix(
            surveyID: surveyID,
            questionID: _questionID,
            nChoices: int.parse(rightOperand),
            accessKey: _el['QuestionIDFromLocator'],
            pos: _pos,
            choiceID: int.parse(_choiceID),
          );
        }
      } else if (_choiceLocator.contains('ChoiceTextEntryValue')) {
        final String _choiceID = _el['ChoiceLocator']
            .split("ChoiceTextEntryValue/")[1]
            .replaceAll('/', '_');
        final bool ignoreCase =
            _el.containsKey('IgnoreCase') && _el['IgnoreCase'] == 1;

        if (_el['Operator'] == 'EqualTo' && ignoreCase) {
          _validation.addEqualIgnore(
            surveyID: surveyID,
            questionID: _questionID,
            rightOperand: rightOperand,
            accessKey: "${_el['QuestionIDFromLocator']}_$_choiceID",
            pos: _pos,
          );
        } else if (_el['Operator'] == 'EqualTo') {
          _validation.addEqual(
            surveyID: surveyID,
            questionID: _questionID,
            rightOperand: rightOperand,
            accessKey: "${_el['QuestionIDFromLocator']}_$_choiceID",
            pos: _pos,
          );
        } else if (_el['Operator'] == 'NotEqualTo' && ignoreCase) {
          _validation.addNotEqualIgnore(
            surveyID: surveyID,
            questionID: _questionID,
            rightOperand: rightOperand,
            accessKey: "${_el['QuestionIDFromLocator']}_$_choiceID",
            pos: _pos,
          );
        } else if (_el['Operator'] == 'NotEqualTo') {
          _validation.addNotEqual(
            surveyID: surveyID,
            questionID: _questionID,
            rightOperand: rightOperand,
            accessKey: "${_el['QuestionIDFromLocator']}_$_choiceID",
            pos: _pos,
          );
        } else if (_el['Operator'] == 'GreaterThan') {
          _validation.addGT(
            surveyID: surveyID,
            questionID: _questionID,
            rightOperand: rightOperand,
            accessKey: "${_el['QuestionIDFromLocator']}_$_choiceID",
            pos: _pos,
          );
        } else if (_el['Operator'] == 'GreaterThanOrEqual') {
          _validation.addGTE(
            surveyID: surveyID,
            questionID: _questionID,
            rightOperand: rightOperand,
            accessKey: "${_el['QuestionIDFromLocator']}_$_choiceID",
            pos: _pos,
          );
        } else if (_el['Operator'] == 'LessThan') {
          _validation.addLT(
            surveyID: surveyID,
            questionID: _questionID,
            rightOperand: rightOperand,
            accessKey: "${_el['QuestionIDFromLocator']}_$_choiceID",
            pos: _pos,
          );
        } else if (_el['Operator'] == 'LessThanOrEqual') {
          _validation.addLTE(
            surveyID: surveyID,
            questionID: _questionID,
            rightOperand: rightOperand,
            accessKey: "${_el['QuestionIDFromLocator']}_$_choiceID",
            pos: _pos,
          );
        } else if (_el['Operator'] == 'Empty') {
          _validation.addEmpty(
            surveyID: surveyID,
            questionID: _questionID,
            accessKey: "${_el['QuestionIDFromLocator']}_$_choiceID",
            pos: _pos,
          );
        } else if (_el['Operator'] == 'NotEmpty') {
          _validation.addNotEmpty(
            surveyID: surveyID,
            questionID: _questionID,
            accessKey: "${_el['QuestionIDFromLocator']}_$_choiceID",
            pos: _pos,
          );
        } else if (_el['Operator'] == 'Contains' && ignoreCase) {
          _validation.addContainsIgnore(
            surveyID: surveyID,
            questionID: _questionID,
            rightOperand: rightOperand,
            accessKey: "${_el['QuestionIDFromLocator']}_$_choiceID",
            pos: _pos,
          );
        } else if (_el['Operator'] == 'Contains') {
          _validation.addContains(
            surveyID: surveyID,
            questionID: _questionID,
            rightOperand: rightOperand,
            accessKey: "${_el['QuestionIDFromLocator']}_$_choiceID",
            pos: _pos,
          );
        } else if (_el['Operator'] == 'DoesNotContain' && ignoreCase) {
          _validation.addNotContainsIgnore(
            surveyID: surveyID,
            questionID: _questionID,
            rightOperand: rightOperand,
            accessKey: "${_el['QuestionIDFromLocator']}_$_choiceID",
            pos: _pos,
          );
        } else if (_el['Operator'] == 'DoesNotContain') {
          _validation.addNotContains(
            surveyID: surveyID,
            questionID: _questionID,
            rightOperand: rightOperand,
            accessKey: "${_el['QuestionIDFromLocator']}_$_choiceID",
            pos: _pos,
          );
        } else if (_el['Operator'] == 'MatchesRegex') {
          _validation.addRegex(
            surveyID: surveyID,
            questionID: _questionID,
            rightOperand: rightOperand,
            accessKey: "${_el['QuestionIDFromLocator']}_$_choiceID",
            pos: _pos,
          );
        }
      }
    }
  }
}
