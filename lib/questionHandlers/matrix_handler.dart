import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/validation.dart';
import '../widgets/questions/matrices/matrix_single.dart';
import '../widgets/questions/matrices/matrix_multiple.dart';
import '../widgets/questions/matrices/matrix_bipolar.dart';
import '../widgets/questions/matrices/matrix_maxdiff.dart';
import '../widgets/questions/matrices/matrix_dropdown.dart';
import '../widgets/questions/matrices/matrix_profile_single.dart';
import '../widgets/questions/matrices/matrix_profile_multiple.dart';
import '../widgets/questions/matrices/matrix_profile_dropdown.dart';
import '../widgets/questions/matrices/matrix_text_entry.dart';
import '../widgets/questions/matrices/matrix_constant_sum.dart';
import '../widgets/questions/matrices/matrix_rank_order.dart';

Widget matrixHandler(
  Map<String, dynamic> _element,
  BuildContext ctx,
  String surveyID,
  String blockID,
  bool disabled,
) {
  final String _selector = _element['Selector'];
  final String _subSelector = _element['SubSelector'] ?? '';
  final List<String> _labels = [];
  Map<String, dynamic> _answers = {};
  final Map<String, dynamic> _localChoices = _getChoices(_element);
  final String _questionText = _element['QuestionText'];
  final String _questionID = _element['QuestionID'];
  Widget _ret = const SizedBox();

  final _validation = Provider.of<Validation>(ctx, listen: false);
  final _validationSettings = _element['Validation'];

  if (_validationSettings['Settings']['Type'] != 'None') {
    _getValidation(surveyID, _element, _questionID, _validation);
  }

  if (_validationSettings['Settings']['ForceResponse'] == "ON") {
    _validation.addMustAnswer(surveyID, _questionID);
  }

  if (_element.containsKey('ColumnLabels')) {
    for (int k = 0; k < _element['ColumnLabels'].length; k++) {
      final String _label = _element['ColumnLabels'][k]['Display'];

      _labels.add(_label);
    }
  }

  if (_selector == 'Likert') {
    _answers = _getSimpleMatrixAnswers(_element);

    if (_subSelector == 'MultipleAnswer') {
      _ret = MatrixMultiple(
        answers: _answers,
        choices: _localChoices,
        questionText: _questionText,
        surveyID: surveyID,
        blockID: blockID,
        questionID: _questionID,
        disabled: disabled,
      );
    } else if (_subSelector == 'SingleAnswer' ||
        _subSelector == 'SACV' ||
        _subSelector == 'DND') {
      _ret = MatrixSingle(
        answers: _answers,
        choices: _localChoices,
        questionText: _questionText,
        surveyID: surveyID,
        blockID: blockID,
        questionID: _questionID,
        disabled: disabled,
      );
    } else if (_subSelector == 'DL') {
      _ret = MatrixDropdown(
        answers: _answers,
        choices: _localChoices,
        questionText: _questionText,
        surveyID: surveyID,
        blockID: blockID,
        questionID: _questionID,
        disabled: disabled,
      );
    }
  } else if (_selector == 'Bipolar') {
    _answers = _getSimpleMatrixAnswers(_element);

    _ret = MatrixBipolar(
      questionText: _questionText,
      choices: _localChoices,
      answers: _answers,
      labels: _labels,
      surveyID: surveyID,
      blockID: blockID,
      questionID: _questionID,
      disabled: disabled,
    );
  } else if (_selector == 'MaxDiff') {
    _answers = _getSimpleMatrixAnswers(_element);

    _ret = MatrixMaxDiff(
      questionText: _questionText,
      choices: _localChoices,
      answers: _answers,
      surveyID: surveyID,
      blockID: blockID,
      questionID: _questionID,
      disabled: disabled,
    );
  } else if (_selector == 'TE' || _selector == 'RO') {
    _answers = _getSimpleMatrixAnswers(_element);
    final String _textEntrySize =
        _selector == 'TE' ? _element['SubSelector'] : 'Short';

    _ret = _selector == 'TE'
        ? MatrixTextEntry(
            questionText: _questionText,
            choices: _localChoices,
            answers: _answers,
            textEntrySize: _textEntrySize,
            surveyID: surveyID,
            blockID: blockID,
            questionID: _questionID,
            disabled: disabled,
          )
        : MatrixRankOrder(
            questionText: _questionText,
            choices: _localChoices,
            answers: _answers,
            surveyID: surveyID,
            blockID: blockID,
            questionID: _questionID,
            disabled: disabled,
          );
  } else if (_selector == 'CS') {
    _answers = _getSimpleMatrixAnswers(_element);

    _ret = MatrixConstantSum(
      questionText: _questionText,
      choices: _localChoices,
      answers: _answers,
      surveyID: surveyID,
      blockID: blockID,
      questionID: _questionID,
      disabled: disabled,
    );
  } else if (_selector == 'Profile') {
    for (int k = 0; k < _element['Answers'].length; k++) {
      final String _outerKey = '${k + 1}';

      _answers.putIfAbsent(_outerKey, () => _element['Answers'][_outerKey]);
    }

    if (_subSelector == 'SingleAnswer') {
      _ret = MatrixProfileSingle(
        questionText: _questionText,
        choices: _localChoices,
        answers: _answers,
        surveyID: surveyID,
        blockID: blockID,
        questionID: _questionID,
        disabled: disabled,
      );
    } else if (_subSelector == 'MultipleAnswer') {
      _ret = MatrixProfileMultiple(
        questionText: _questionText,
        choices: _localChoices,
        answers: _answers,
        surveyID: surveyID,
        blockID: blockID,
        questionID: _questionID,
        disabled: disabled,
      );
    } else if (_subSelector == 'DL') {
      _ret = MatrixProfileDropdown(
        questionText: _questionText,
        choices: _localChoices,
        answers: _answers,
        surveyID: surveyID,
        blockID: blockID,
        questionID: _questionID,
        disabled: disabled,
      );
    }
  }

  return _ret;
}

Map<String, dynamic> _getSimpleMatrixAnswers(Map<String, dynamic> _element) {
  final Map<String, dynamic> _answers = {};
  final _recodeValues = _element['RecodeValues'] ?? {};

  for (int k = 0; k < _element['Answers'].length; k++) {
    final String _key = _element['AnswerOrder'][k].toString();

    if (_recodeValues.isNotEmpty &&
        _recodeValues.keys.length == _element['Answers'].length) {
      _answers.putIfAbsent(
        _recodeValues[_key].toString(),
        () => _element['Answers'][_key],
      );

      _answers[_recodeValues[_key].toString()]['Display'] =
          _answers[_recodeValues[_key].toString()]['Display'];
    } else {
      _answers.putIfAbsent(_key, () => _element['Answers'][_key]);
      _answers[_key]['Display'] = _answers[_key]['Display'];
    }
  }

  return _answers;
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

void _getValidation(surveyID, _element, _questionID, Validation _validation) {
  int _pos = 0;
  final _validationSettings = _element['Validation'];

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

      if (_choiceLocator.contains('SelectableAnswer')) {
        if (_el['Operator'] == 'Selected') {
          final _choiceID = _el['ChoiceLocator'].split("SelectableAnswer/")[1];
          final _choiceCount = _element['Choices'].length;

          _validation.addMatrixWhitelist(
            surveyID: surveyID,
            questionID: _questionID,
            choiceID: _choiceID,
            accessKey: _questionID,
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
            accessKey: _questionID,
            pos: _pos,
            choiceCount: _choiceCount,
          );
        }
      } else if (_choiceLocator.contains('SelectableChoice')) {
        if (_el['Operator'] == 'Selected') {
          final _locator = _el['ChoiceLocator'].split("SelectableChoice/")[1];
          final split = _locator.split("/");
          final _choiceID = split[0];
          final _answerID = split[1];

          _validation.addToWhitelist(
            surveyID: surveyID,
            questionID: _questionID,
            choiceID: _answerID,
            accessKey: "${_questionID}_$_choiceID",
            pos: _pos,
          );
        } else if (_el['Operator'] == 'NotSelected') {
          final _locator = _el['ChoiceLocator'].split("SelectableChoice/")[1];
          final split = _locator.split("/");
          final _choiceID = split[0];
          final _answerID = split("/")[1];

          _validation.addToBlacklist(
            surveyID: surveyID,
            questionID: _questionID,
            choiceID: _answerID,
            accessKey: "${_questionID}_$_choiceID",
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
            accessKey: _questionID,
            pos: _pos,
            choiceID: int.parse(_choiceID),
          );
        } else if (_el['Operator'] == 'NotEqualTo') {
          _validation.addNotEqualLengthMatrix(
            surveyID: surveyID,
            questionID: _questionID,
            nChoices: int.parse(rightOperand),
            accessKey: _questionID,
            pos: _pos,
            choiceID: int.parse(_choiceID),
          );
        } else if (_el['Operator'] == 'GreaterThan') {
          _validation.addGTLengthMatrix(
            surveyID: surveyID,
            questionID: _questionID,
            nChoices: int.parse(rightOperand),
            accessKey: _questionID,
            pos: _pos,
            choiceID: int.parse(_choiceID),
          );
        } else if (_el['Operator'] == 'GreaterThanOrEqual') {
          _validation.addGTELengthMatrix(
            surveyID: surveyID,
            questionID: _questionID,
            nChoices: int.parse(rightOperand),
            accessKey: _questionID,
            pos: _pos,
            choiceID: int.parse(_choiceID),
          );
        } else if (_el['Operator'] == 'LessThan') {
          _validation.addLTLengthMatrix(
            surveyID: surveyID,
            questionID: _questionID,
            nChoices: int.parse(rightOperand),
            accessKey: _questionID,
            pos: _pos,
            choiceID: int.parse(_choiceID),
          );
        } else if (_el['Operator'] == 'LessThanOrEqual') {
          _validation.addLTELengthMatrix(
            surveyID: surveyID,
            questionID: _questionID,
            nChoices: int.parse(rightOperand),
            accessKey: _questionID,
            pos: _pos,
            choiceID: int.parse(_choiceID),
          );
        }
      } else if (_choiceLocator.contains('ChoiceTextEntryValue')) {
        final _choiceID =
            _el['ChoiceLocator'].split("ChoiceTextEntryValue/")[1];
        final bool equalTo = _el['Operator'] == 'EqualTo';
        final bool ignoreCase =
            _el.containsKey('IgnoreCase') && _el['IgnoreCase'] == 1;

        if (equalTo && ignoreCase) {
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
      } else if (_choiceLocator.contains('ChoiceNumericEntryValue')) {
        final _locator =
            _el['ChoiceLocator'].split("ChoiceNumericEntryValue/")[1];
        final _choiceID = _locator.split("/")[0];
        final _answerID = _locator.split("/")[1];

        if (_el['Operator'] == 'EqualTo') {
          _validation.addEqual(
            surveyID: surveyID,
            questionID: _questionID,
            rightOperand: rightOperand,
            accessKey: "${_questionID}_${_choiceID}_$_answerID",
            pos: _pos,
          );
        } else if (_el['Operator'] == 'NotEqualTo') {
          _validation.addNotEqual(
            surveyID: surveyID,
            questionID: _questionID,
            rightOperand: rightOperand,
            accessKey: "${_questionID}_${_choiceID}_$_answerID",
            pos: _pos,
          );
        } else if (_el['Operator'] == 'GreaterThan') {
          _validation.addGT(
            surveyID: surveyID,
            questionID: _questionID,
            rightOperand: rightOperand,
            accessKey: "${_questionID}_${_choiceID}_$_answerID",
            pos: _pos,
          );
        } else if (_el['Operator'] == 'GreaterThanOrEqual') {
          _validation.addGTE(
            surveyID: surveyID,
            questionID: _questionID,
            rightOperand: rightOperand,
            accessKey: "${_questionID}_${_choiceID}_$_answerID",
            pos: _pos,
          );
        } else if (_el['Operator'] == 'LessThan') {
          _validation.addLT(
            surveyID: surveyID,
            questionID: _questionID,
            rightOperand: rightOperand,
            accessKey: "${_questionID}_${_choiceID}_$_answerID",
            pos: _pos,
          );
        } else if (_el['Operator'] == 'LessThanOrEqual') {
          _validation.addLTE(
            surveyID: surveyID,
            questionID: _questionID,
            rightOperand: rightOperand,
            accessKey: "${_questionID}_${_choiceID}_$_answerID",
            pos: _pos,
          );
        } else if (_el['Operator'] == 'Empty') {
          _validation.addEmpty(
            surveyID: surveyID,
            questionID: _questionID,
            accessKey: "${_questionID}_${_choiceID}_$_answerID",
            pos: _pos,
          );
        } else if (_el['Operator'] == 'NotEmpty') {
          _validation.addNotEmpty(
            surveyID: surveyID,
            questionID: _questionID,
            accessKey: "${_questionID}_${_choiceID}_$_answerID",
            pos: _pos,
          );
        } else if (_el['Operator'] == 'Contains' &&
            _el.containsKey('IgnoreCase') &&
            _el['IgnoreCase'] == 1) {
          _validation.addContainsIgnore(
            surveyID: surveyID,
            questionID: _questionID,
            rightOperand: rightOperand,
            accessKey: "${_questionID}_${_choiceID}_$_answerID",
            pos: _pos,
          );
        } else if (_el['Operator'] == 'Contains') {
          _validation.addContains(
            surveyID: surveyID,
            questionID: _questionID,
            rightOperand: rightOperand,
            accessKey: "${_questionID}_${_choiceID}_$_answerID",
            pos: _pos,
          );
        } else if (_el['Operator'] == 'DoesNotContain' &&
            _el.containsKey('IgnoreCase') &&
            _el['IgnoreCase'] == 1) {
          _validation.addNotContainsIgnore(
            surveyID: surveyID,
            questionID: _questionID,
            rightOperand: rightOperand,
            accessKey: "${_questionID}_${_choiceID}_$_answerID",
            pos: _pos,
          );
        } else if (_el['Operator'] == 'DoesNotContain') {
          _validation.addNotContains(
            surveyID: surveyID,
            questionID: _questionID,
            rightOperand: rightOperand,
            accessKey: "${_questionID}_${_choiceID}_$_answerID",
            pos: _pos,
          );
        } else if (_el['Operator'] == 'MatchesRegex') {
          _validation.addRegex(
            surveyID: surveyID,
            questionID: _questionID,
            rightOperand: rightOperand,
            accessKey: "${_questionID}_${_choiceID}_$_answerID",
            pos: _pos,
          );
        }
      }
    }
  }
}
