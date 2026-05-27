import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../widgets/questions/multiple_choices/mc_single.dart';
import '../widgets/questions/multiple_choices/mc_multiple.dart';
import '../widgets/questions/multiple_choices/nps.dart';
import '../widgets/questions/multiple_choices/mc_dropdown.dart';
import '../utility.dart';
import '../providers/validation.dart';

Widget multichoiceHandler(
  Map<String, dynamic> _element,
  BuildContext ctx,
  String surveyID,
  String blockID,
  bool disabled,
) {
  final String _selector = _element['Selector'];
  Map<String, dynamic> _localChoices;
  final String _questionText = _element['QuestionText'];
  final String _questionID = _element['QuestionID'];
  Widget _ret = const SizedBox();

  final _validation = Provider.of<Validation>(ctx, listen: false);
  final _validationSettings = _element['Validation'];

  if (_validationSettings['Settings']['Type'] != 'None') {
    _getValidation(surveyID, _validationSettings, _questionID, _validation);
  }

  if (_validationSettings['Settings']['ForceResponse'] == "ON") {
    _validation.addMustAnswer(surveyID, _questionID);
  }

  if (_selector == 'NPS') {
    _localChoices = {};
    final List<String> _labels = [];

    if (_element.containsKey('ColumnLabels')) {
      for (int k = 0; k < _element['ColumnLabels'].length; k++) {
        final String _label = _element['ColumnLabels'][k]['Display'];

        _labels.add(_label);
      }
    }

    for (int k = 0; k < _element['Choices'].length; k++) {
      _localChoices.putIfAbsent(
        _element['ChoiceOrder'][k],
        () => _element['Choices'][int.parse(_element['ChoiceOrder'][k])],
      );
    }

    _ret = NPS(
      questionText: _questionText,
      choices: _localChoices,
      labels: _labels,
      surveyID: surveyID,
      blockID: blockID,
      questionID: _questionID,
      disabled: disabled,
    );
  } else {
    _localChoices = getChoices(_element);
    log('Selector: $_selector');

    if (_selector == 'MAVR' ||
        _selector == 'MSB' ||
        _selector == 'MAHR' ||
        _selector == 'MACOL') {
      _ret = MCMultiple(
        questionText: _questionText,
        choices: _localChoices,
        surveyID: surveyID,
        blockID: blockID,
        questionID: _questionID,
        disabled: disabled,
      );
    } else if (_selector == 'SAVR' ||
        _selector == 'SB' ||
        _selector == 'SAHR' ||
        _selector == 'SACOL') {
      _ret = MCSingle(
        questionText: _questionText,
        choices: _localChoices,
        surveyID: surveyID,
        blockID: blockID,
        questionID: _questionID,
        disabled: disabled,
        recodeValues: _element['RecodeValues'] ?? {},
      );
    } else if (_selector == 'DL') {
      _ret = MCDropdown(
        questionText: _questionText,
        choices: _localChoices,
        surveyID: surveyID,
        blockID: blockID,
        questionID: _questionID,
        disabled: disabled,
      );
    }
  }

  return _ret;
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
      } else if (_choiceLocator.contains('ChoiceTextEntryValue')) {
        final _choiceID =
            _el['ChoiceLocator'].split("ChoiceTextEntryValue/")[1];

        if (_el['Operator'] == 'EqualTo') {
          _validation.addEqual(
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
        } else if (_el['Operator'] == 'Contains' &&
            _el.containsKey('IgnoreCase') &&
            _el['IgnoreCase'] == 1) {
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
        } else if (_el['Operator'] == 'DoesNotContain' &&
            _el.containsKey('IgnoreCase') &&
            _el['IgnoreCase'] == 1) {
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
