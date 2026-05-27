import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/validation.dart';
import '../widgets/questions/sliders/slider_question.dart';
import '../utility.dart';

Widget sliderHandler(
  Map<String, dynamic> _element,
  BuildContext ctx,
  String surveyID,
  String blockID,
  bool disabled,
) {
  final Map<String, dynamic> _localChoices = getChoices(_element);
  final int _minValue = _element['Configuration']['CSSliderMin'];
  final int _maxValue = _element['Configuration']['CSSliderMax'];
  final List<String> _labels = [];
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

  final Map<String, dynamic> _startPosition =
      _element['Configuration']['CustomStart']
          ? Map<String, dynamic>.from(
              _element['Configuration']['SliderStartPositions'],
            )
          : {};

  final int _divisions = (_element['Configuration'].containsKey('SnapToGrid') &&
          _element['Configuration']['SnapToGrid'])
      ? _element['Configuration']['GridLines']
      : (_maxValue - _minValue);

  if (_element.containsKey('Labels')) {
    for (int k = 0; k < _element['Labels'].length; k++) {
      final String _label = _element['Labels'].values.toList()[k]['Display'];
      _labels.add(_label);
    }
  }

  return SliderQuestion(
    choices: _localChoices,
    questionText: _questionText,
    maxValue: _maxValue,
    minValue: _minValue,
    startPostion: _startPosition,
    divisions: _divisions,
    labels: _labels,
    surveyID: surveyID,
    blockID: blockID,
    questionID: _questionID,
    disabled: disabled,
  );
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

      if (_el.containsKey('Conjuction')) {
        if (_el['Conjuction'] == 'Or') {
          _pos++;
        }
      }

      if (_choiceLocator.contains('SelectableChoice')) {
        if (_el['Operator'] == 'Selected') {
          final _choiceID = _el['ChoiceLocator'].split("SelectableChoice/")[1];

          _validation.addToWhitelist(
            surveyID: surveyID,
            questionID: _questionID,
            choiceID: _choiceID,
            accessKey: _questionID,
            pos: _pos,
          );
        } else if (_el['Operator'] == 'NotSelected') {
          final _choiceID = _el['ChoiceLocator'].split("SelectableChoice/")[1];
          _validation.addToBlacklist(
            surveyID: surveyID,
            questionID: _questionID,
            choiceID: _choiceID,
            accessKey: _questionID,
            pos: _pos,
          );
        }
      } else if (_choiceLocator.contains('SelectedChoicesCount')) {
        if (_el['Operator'] == 'EqualTo') {
          _validation.addEqualLength(
            surveyID: surveyID,
            questionID: _questionID,
            nChoices: int.parse(rightOperand),
            accessKey: _questionID,
            pos: _pos,
          );
        } else if (_el['Operator'] == 'NotEqualTo') {
          _validation.addNotEqualLength(
            surveyID: surveyID,
            questionID: _questionID,
            nChoices: int.parse(rightOperand),
            accessKey: _questionID,
            pos: _pos,
          );
        } else if (_el['Operator'] == 'GreaterThan') {
          _validation.addGTLength(
            surveyID: surveyID,
            questionID: _questionID,
            nChoices: int.parse(rightOperand),
            accessKey: _questionID,
            pos: _pos,
          );
        } else if (_el['Operator'] == 'GreaterThanOrEqual') {
          _validation.addGTELength(
            surveyID: surveyID,
            questionID: _questionID,
            nChoices: int.parse(rightOperand),
            accessKey: _questionID,
            pos: _pos,
          );
        } else if (_el['Operator'] == 'LessThan') {
          _validation.addLTLength(
            surveyID: surveyID,
            questionID: _questionID,
            nChoices: int.parse(rightOperand),
            accessKey: _questionID,
            pos: _pos,
          );
        } else if (_el['Operator'] == 'LessThanOrEqual') {
          _validation.addLTELength(
            surveyID: surveyID,
            questionID: _questionID,
            nChoices: int.parse(rightOperand),
            accessKey: _questionID,
            pos: _pos,
          );
        }
      } else if (_choiceLocator.contains('ChoiceNumericEntryValue')) {
        final _choiceID =
            _el['ChoiceLocator'].split("ChoiceNumericEntryValue/")[1];

        if (_el['Operator'] == 'EqualTo') {
          _validation.addEqual(
            surveyID: surveyID,
            questionID: _questionID,
            rightOperand: rightOperand,
            accessKey: "${_questionID}_$_choiceID",
            pos: _pos,
          );
        } else if (_el['Operator'] == 'NotEqualTo') {
          _validation.addNotEqual(
            surveyID: surveyID,
            questionID: _questionID,
            rightOperand: rightOperand,
            accessKey: "${_questionID}_$_choiceID",
            pos: _pos,
          );
        } else if (_el['Operator'] == 'GreaterThan') {
          _validation.addGT(
            surveyID: surveyID,
            questionID: _questionID,
            rightOperand: rightOperand,
            accessKey: "${_questionID}_$_choiceID",
            pos: _pos,
          );
        } else if (_el['Operator'] == 'GreaterThanOrEqual') {
          _validation.addGTE(
            surveyID: surveyID,
            questionID: _questionID,
            rightOperand: rightOperand,
            accessKey: "${_questionID}_$_choiceID",
            pos: _pos,
          );
        } else if (_el['Operator'] == 'LessThan') {
          _validation.addLT(
            surveyID: surveyID,
            questionID: _questionID,
            rightOperand: rightOperand,
            accessKey: "${_questionID}_$_choiceID",
            pos: _pos,
          );
        } else if (_el['Operator'] == 'LessThanOrEqual') {
          _validation.addLTE(
            surveyID: surveyID,
            questionID: _questionID,
            rightOperand: rightOperand,
            accessKey: "${_questionID}_$_choiceID",
            pos: _pos,
          );
        } else if (_el['Operator'] == 'Empty') {
          _validation.addEmpty(
            surveyID: surveyID,
            questionID: _questionID,
            accessKey: "${_questionID}_$_choiceID",
            pos: _pos,
          );
        } else if (_el['Operator'] == 'NotEmpty') {
          _validation.addNotEmpty(
            surveyID: surveyID,
            questionID: _questionID,
            accessKey: "${_questionID}_$_choiceID",
            pos: _pos,
          );
        } else if (_el['Operator'] == 'Contains' &&
            _el.containsKey('IgnoreCase') &&
            _el['IgnoreCase'] == 1) {
          _validation.addContainsIgnore(
            surveyID: surveyID,
            questionID: _questionID,
            rightOperand: rightOperand,
            accessKey: "${_questionID}_$_choiceID",
            pos: _pos,
          );
        } else if (_el['Operator'] == 'Contains') {
          _validation.addContains(
            surveyID: surveyID,
            questionID: _questionID,
            rightOperand: rightOperand,
            accessKey: "${_questionID}_$_choiceID",
            pos: _pos,
          );
        } else if (_el['Operator'] == 'DoesNotContain' &&
            _el.containsKey('IgnoreCase') &&
            _el['IgnoreCase'] == 1) {
          _validation.addNotContainsIgnore(
            surveyID: surveyID,
            questionID: _questionID,
            rightOperand: rightOperand,
            accessKey: "${_questionID}_$_choiceID",
            pos: _pos,
          );
        } else if (_el['Operator'] == 'DoesNotContain') {
          _validation.addNotContains(
            surveyID: surveyID,
            questionID: _questionID,
            rightOperand: rightOperand,
            accessKey: "${_questionID}_$_choiceID",
            pos: _pos,
          );
        } else if (_el['Operator'] == 'MatchesRegex') {
          _validation.addRegex(
            surveyID: surveyID,
            questionID: _questionID,
            rightOperand: rightOperand,
            accessKey: "${_questionID}_$_choiceID",
            pos: _pos,
          );
        }
      } else if (_choiceLocator.contains('ChoiceTextEntryValue')) {
        final _choiceID =
            _el['ChoiceLocator'].split("ChoiceTextEntryValue/")[1];

        final ignoreCase =
            _el.containsKey('IgnoreCase') && _el['IgnoreCase'] == 1;

        if (_el['Operator'] == 'EqualTo' && ignoreCase) {
          _validation.addEqualIgnore(
            surveyID: surveyID,
            questionID: _questionID,
            rightOperand: rightOperand,
            accessKey: "${_questionID}_${_choiceID}_TEXT",
            pos: _pos,
          );
        } else if (_el['Operator'] == 'EqualTo') {
          _validation.addEqual(
            surveyID: surveyID,
            questionID: _questionID,
            rightOperand: rightOperand,
            accessKey: "${_questionID}_${_choiceID}_TEXT",
            pos: _pos,
          );
        } else if (_el['Operator'] == 'NotEqualTo' && ignoreCase) {
          _validation.addNotEqualIgnore(
            surveyID: surveyID,
            questionID: _questionID,
            rightOperand: rightOperand,
            accessKey: "${_questionID}_${_choiceID}_TEXT",
            pos: _pos,
          );
        } else if (_el['Operator'] == 'NotEqualTo') {
          _validation.addNotEqual(
            surveyID: surveyID,
            questionID: _questionID,
            rightOperand: rightOperand,
            accessKey: "${_questionID}_${_choiceID}_TEXT",
            pos: _pos,
          );
        } else if (_el['Operator'] == 'GreaterThan') {
          _validation.addGT(
            surveyID: surveyID,
            questionID: _questionID,
            rightOperand: rightOperand,
            accessKey: "${_questionID}_${_choiceID}_TEXT",
            pos: _pos,
          );
        } else if (_el['Operator'] == 'GreaterThanOrEqual') {
          _validation.addGTE(
            surveyID: surveyID,
            questionID: _questionID,
            rightOperand: rightOperand,
            accessKey: "${_questionID}_${_choiceID}_TEXT",
            pos: _pos,
          );
        } else if (_el['Operator'] == 'LessThan') {
          _validation.addLT(
            surveyID: surveyID,
            questionID: _questionID,
            rightOperand: rightOperand,
            accessKey: "${_questionID}_${_choiceID}_TEXT",
            pos: _pos,
          );
        } else if (_el['Operator'] == 'LessThanOrEqual') {
          _validation.addLTE(
            surveyID: surveyID,
            questionID: _questionID,
            rightOperand: rightOperand,
            accessKey: "${_questionID}_${_choiceID}_TEXT",
            pos: _pos,
          );
        } else if (_el['Operator'] == 'Empty') {
          _validation.addEmpty(
            surveyID: surveyID,
            questionID: _questionID,
            accessKey: "${_questionID}_${_choiceID}_TEXT",
            pos: _pos,
          );
        } else if (_el['Operator'] == 'NotEmpty') {
          _validation.addNotEmpty(
            surveyID: surveyID,
            questionID: _questionID,
            accessKey: "${_questionID}_${_choiceID}_TEXT",
            pos: _pos,
          );
        } else if (_el['Operator'] == 'Contains' && ignoreCase) {
          _validation.addContainsIgnore(
            surveyID: surveyID,
            questionID: _questionID,
            rightOperand: rightOperand,
            accessKey: "${_questionID}_${_choiceID}_TEXT",
            pos: _pos,
          );
        } else if (_el['Operator'] == 'Contains') {
          _validation.addContains(
            surveyID: surveyID,
            questionID: _questionID,
            rightOperand: rightOperand,
            accessKey: "${_questionID}_${_choiceID}_TEXT",
            pos: _pos,
          );
        } else if (_el['Operator'] == 'DoesNotContain' && ignoreCase) {
          _validation.addNotContainsIgnore(
            surveyID: surveyID,
            questionID: _questionID,
            rightOperand: rightOperand,
            accessKey: "${_questionID}_${_choiceID}_TEXT",
            pos: _pos,
          );
        } else if (_el['Operator'] == 'DoesNotContain') {
          _validation.addNotContains(
            surveyID: surveyID,
            questionID: _questionID,
            rightOperand: rightOperand,
            accessKey: "${_questionID}_${_choiceID}_TEXT",
            pos: _pos,
          );
        } else if (_el['Operator'] == 'MatchesRegex') {
          _validation.addRegex(
            surveyID: surveyID,
            questionID: _questionID,
            rightOperand: rightOperand,
            accessKey: "${_questionID}_${_choiceID}_TEXT",
            pos: _pos,
          );
        }
      }
    }
  } else if (_validationSettings['Settings']['Type'] == 'MinChoices') {
    final minChoices = _validationSettings['Settings']['MinChoices'];
    _validation.addMinChoices(
      surveyID: surveyID,
      questionID: _questionID,
      minChoices: int.parse(minChoices),
      accessKey: _questionID,
      pos: 0,
    );
  } else if (_validationSettings['Settings']['Type'] == 'ChoiceRange') {
    final minChoices = _validationSettings['Settings']['MinChoices'];
    final maxChoices = _validationSettings['Settings']['MaxChoices'];
    _validation.addMinChoices(
      surveyID: surveyID,
      questionID: _questionID,
      minChoices: int.parse(minChoices),
      accessKey: _questionID,
      pos: 0,
    );
    _validation.addMaxChoices(
      surveyID: surveyID,
      questionID: _questionID,
      maxChoices: int.parse(maxChoices),
      accessKey: _questionID,
      pos: 0,
    );
  }
}
