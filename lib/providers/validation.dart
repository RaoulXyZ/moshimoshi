import 'dart:developer';

import 'package:flutter/foundation.dart';

class Validation with ChangeNotifier {
  Map<String, Map<String, Map<int, Map<String, dynamic>>>> _validation = {};
  Map<String, List<String>> mustAnswer = {};

  dynamic getRules() {
    return _validation;
  }

  void addMustAnswer(String surveyID, String questionID) {
    mustAnswer.update(
      surveyID,
      (value) {
        if (!value.contains(questionID)) value.add(questionID);

        return List<String>.from(value);
      },
      ifAbsent: () => [questionID],
    );

    //if (!mustAnswer.contains(questionID)) mustAnswer.add(questionID);
  }

  bool skippable(String surveyID, String questionID) {
    if (!mustAnswer.containsKey(surveyID)) {
      return true;
    }

    if (mustAnswer[surveyID] == null ||
        !mustAnswer[surveyID]!.contains(questionID)) {
      return true;
    }

    return false;
  }

  void addToWhitelist({
    required String surveyID,
    required String questionID,
    required String choiceID,
    required String accessKey,
    required int pos,
  }) {
    _init(surveyID, questionID, pos);

    _validation[surveyID]![questionID]![pos]!.update(
      'whitelist',
      (value) {
        if (!value['rightOperand'].contains(choiceID)) {
          value['rightOperand'].add(choiceID);
        }

        final List<String> newValue = List.from(value['rightOperand']);

        return {'access': accessKey, 'rightOperand': newValue};
      },
      ifAbsent: () {
        return {
          'access': accessKey,
          'rightOperand': [choiceID],
        };
      },
    );
  }

  void addMatrixWhitelist({
    required String surveyID,
    required String questionID,
    required String choiceID,
    required String accessKey,
    required int pos,
    required int choiceCount,
  }) {
    _init(surveyID, questionID, pos);

    _validation[surveyID]![questionID]![pos]!.update(
      'matrixWhitelist',
      (value) {
        if (!value['rightOperand'].contains(choiceID)) {
          value['rightOperand'].add(choiceID);
        }

        final List<String> newValue = List.from(value['rightOperand']);

        return {
          'access': accessKey,
          'rightOperand': newValue,
          'length': value['length'],
        };
      },
      ifAbsent: () {
        return {
          'access': accessKey,
          'rightOperand': [choiceID],
          'length': choiceCount,
        };
      },
    );
  }

  void addToBlacklist({
    required String surveyID,
    required String questionID,
    required String choiceID,
    required String accessKey,
    required int pos,
  }) {
    _init(surveyID, questionID, pos);

    _validation[surveyID]![questionID]![pos]!.update(
      'blacklist',
      (value) {
        if (!value['rightOperand'].contains(choiceID)) {
          value['rightOperand'].add(choiceID);
        }

        final List<String> newValue = List.from(value['rightOperand']);

        return {'access': accessKey, 'rightOperand': newValue};
      },
      ifAbsent: () {
        return {
          'access': accessKey,
          'rightOperand': [choiceID],
        };
      },
    );
  }

  void addMatrixBlacklist({
    required String surveyID,
    required String questionID,
    required String choiceID,
    required String accessKey,
    required int pos,
    required int choiceCount,
  }) {
    _init(surveyID, questionID, pos);

    _validation[surveyID]![questionID]![pos]!.update(
      'matrixBlacklist',
      (value) {
        if (!value['rightOperand'].contains(choiceID)) {
          value['rightOperand'].add(choiceID);
        }

        final List<String> newValue = List.from(value['rightOperand']);

        return {
          'access': accessKey,
          'rightOperand': newValue,
          'length': value['length'],
        };
      },
      ifAbsent: () {
        return {
          'access': accessKey,
          'rightOperand': [choiceID],
          'length': choiceCount,
        };
      },
    );
  }

  void addMinChoices({
    required String surveyID,
    required String questionID,
    required int minChoices,
    required String accessKey,
    required int pos,
  }) {
    _init(surveyID, questionID, pos);

    _validation[surveyID]![questionID]![pos]!.putIfAbsent(
      'minChoices',
      () => {
        'access': accessKey,
        'rightOperand': minChoices,
      },
    );
  }

  void addMinChar({
    required String surveyID,
    required String questionID,
    required int minChar,
    required String accessKey,
    required int pos,
  }) {
    _init(surveyID, questionID, pos);

    _validation[surveyID]![questionID]![pos]!.putIfAbsent(
      'minChar',
      () => {
        'access': accessKey,
        'rightOperand': minChar,
      },
    );
  }

  void addMaxChoices({
    required String surveyID,
    required String questionID,
    required int maxChoices,
    required String accessKey,
    required int pos,
  }) {
    _init(surveyID, questionID, pos);

    _validation[surveyID]![questionID]![pos]!.putIfAbsent(
      'maxChoices',
      () => {
        'access': accessKey,
        'rightOperand': maxChoices,
      },
    );
  }

  void addTotalChar({
    required String surveyID,
    required String questionID,
    required int totalChar,
    required String accessKey,
    required int pos,
  }) {
    _init(surveyID, questionID, pos);

    _validation[surveyID]![questionID]![pos]!.putIfAbsent(
      'totalChar',
      () => {
        'access': accessKey,
        'rightOperand': totalChar,
      },
    );
  }

  void addEqualLength({
    required String surveyID,
    required String questionID,
    required int nChoices,
    required String accessKey,
    required int pos,
  }) {
    _init(surveyID, questionID, pos);

    _validation[surveyID]![questionID]![pos]!.putIfAbsent(
      'equalLength',
      () => {
        'access': accessKey,
        'rightOperand': nChoices,
      },
    );
  }

  void addEqualLengthMatrix({
    required String surveyID,
    required String questionID,
    required int nChoices,
    required String accessKey,
    required int pos,
    required int choiceID,
  }) {
    _init(surveyID, questionID, pos);

    _validation[surveyID]![questionID]![pos]!.putIfAbsent(
      'equalLengthMatrix',
      () => {
        'access': accessKey,
        'rightOperand': nChoices,
        'choiceID': choiceID,
      },
    );
  }

  void addEqual({
    required String surveyID,
    required String questionID,
    required String rightOperand,
    required String accessKey,
    required int pos,
  }) {
    _init(surveyID, questionID, pos);

    _validation[surveyID]![questionID]![pos]!.putIfAbsent(
      'equal',
      () => {
        'access': accessKey,
        'rightOperand': rightOperand,
      },
    );
  }

  void addEqualIgnore({
    required String surveyID,
    required String questionID,
    required String rightOperand,
    required String accessKey,
    required int pos,
  }) {
    _init(surveyID, questionID, pos);

    _validation[surveyID]![questionID]![pos]!.putIfAbsent(
      'equalIgnore',
      () => {
        'access': accessKey,
        'rightOperand': rightOperand,
      },
    );
  }

  void addNotEqualLength({
    required String surveyID,
    required String questionID,
    required int nChoices,
    required String accessKey,
    required int pos,
  }) {
    _init(surveyID, questionID, pos);

    _validation[surveyID]![questionID]![pos]!.putIfAbsent(
      'notEqualLength',
      () => {
        'access': accessKey,
        'rightOperand': nChoices,
      },
    );
  }

  void addNotEqualLengthMatrix({
    required surveyID,
    required String questionID,
    required int nChoices,
    required String accessKey,
    required int pos,
    required int choiceID,
  }) {
    _init(surveyID, questionID, pos);

    _validation[surveyID]![questionID]![pos]!.putIfAbsent(
      'notEqualLengthMatrix',
      () => {
        'access': accessKey,
        'rightOperand': nChoices,
        'choiceID': choiceID,
      },
    );
  }

  void addNotEqual({
    required String surveyID,
    required String questionID,
    required String rightOperand,
    required String accessKey,
    required int pos,
  }) {
    _init(surveyID, questionID, pos);

    _validation[surveyID]![questionID]![pos]!.putIfAbsent(
      'notEqual',
      () => {
        'access': accessKey,
        'rightOperand': rightOperand,
      },
    );
  }

  void addNotEqualIgnore({
    required String surveyID,
    required String questionID,
    required String rightOperand,
    required String accessKey,
    required int pos,
  }) {
    _init(surveyID, questionID, pos);

    _validation[surveyID]![questionID]![pos]!.putIfAbsent(
      'notEqualIgnore',
      () => {
        'access': accessKey,
        'rightOperand': rightOperand,
      },
    );
  }

  void addGTLength({
    required String surveyID,
    required String questionID,
    required int nChoices,
    required String accessKey,
    required int pos,
  }) {
    _init(surveyID, questionID, pos);

    _validation[surveyID]![questionID]![pos]!.putIfAbsent(
      'greaterThanLength',
      () => {
        'access': accessKey,
        'rightOperand': nChoices,
      },
    );
  }

  void addGTLengthMatrix({
    required String surveyID,
    required String questionID,
    required int nChoices,
    required String accessKey,
    required int pos,
    required int choiceID,
  }) {
    _init(surveyID, questionID, pos);

    _validation[surveyID]![questionID]![pos]!.putIfAbsent(
      'greaterThanLengthMatrix',
      () => {
        'access': accessKey,
        'rightOperand': nChoices,
        'choiceID': choiceID,
      },
    );
  }

  void addGT({
    required String surveyID,
    required String questionID,
    required String rightOperand,
    required String accessKey,
    required int pos,
  }) {
    _init(surveyID, questionID, pos);

    _validation[surveyID]![questionID]![pos]!.putIfAbsent(
      'greaterThan',
      () => {
        'access': accessKey,
        'rightOperand': rightOperand,
      },
    );
  }

  void addGTELength({
    required String surveyID,
    required String questionID,
    required int nChoices,
    required String accessKey,
    required int pos,
  }) {
    _init(surveyID, questionID, pos);

    _validation[surveyID]![questionID]![pos]!.putIfAbsent(
      'greaterThanEqualLength',
      () => {
        'access': accessKey,
        'rightOperand': nChoices,
      },
    );
  }

  void addGTELengthMatrix({
    required String surveyID,
    required String questionID,
    required int nChoices,
    required String accessKey,
    required int pos,
    required int choiceID,
  }) {
    _init(surveyID, questionID, pos);

    _validation[surveyID]![questionID]![pos]!.putIfAbsent(
      'greaterThanEqualLengthMatrix',
      () => {
        'access': accessKey,
        'rightOperand': nChoices,
        'choiceID': choiceID,
      },
    );
  }

  void addGTE({
    required String surveyID,
    required String questionID,
    required String rightOperand,
    required String accessKey,
    required int pos,
  }) {
    _init(surveyID, questionID, pos);

    _validation[surveyID]![questionID]![pos]!.putIfAbsent(
      'greaterThanEqual',
      () => {
        'access': accessKey,
        'rightOperand': rightOperand,
      },
    );
  }

  void addLTLength({
    required String surveyID,
    required String questionID,
    required int nChoices,
    required String accessKey,
    required int pos,
  }) {
    _init(surveyID, questionID, pos);

    _validation[surveyID]![questionID]![pos]!.putIfAbsent(
      'lessThanLength',
      () => {
        'access': accessKey,
        'rightOperand': nChoices,
      },
    );
  }

  void addLTLengthMatrix({
    required String questionID,
    required String surveyID,
    required int nChoices,
    required String accessKey,
    required int pos,
    required int choiceID,
  }) {
    _init(surveyID, questionID, pos);

    _validation[surveyID]![questionID]![pos]!.putIfAbsent(
      'lessThanLengthMatrix',
      () => {
        'access': accessKey,
        'rightOperand': nChoices,
        'choiceID': choiceID,
      },
    );
  }

  void addLT({
    required String surveyID,
    required String questionID,
    required String rightOperand,
    required String accessKey,
    required int pos,
  }) {
    _init(surveyID, questionID, pos);

    _validation[surveyID]![questionID]![pos]!.putIfAbsent(
      'lessThan',
      () => {
        'access': accessKey,
        'rightOperand': rightOperand,
      },
    );
  }

  void addLTELength({
    required String surveyID,
    required String questionID,
    required int nChoices,
    required String accessKey,
    required int pos,
  }) {
    _init(surveyID, questionID, pos);

    _validation[surveyID]![questionID]![pos]!.putIfAbsent(
      'lessThanEqualLength',
      () => {
        'access': accessKey,
        'rightOperand': nChoices,
      },
    );
  }

  void addLTELengthMatrix({
    required String surveyID,
    required String questionID,
    required int nChoices,
    required String accessKey,
    required int pos,
    required int choiceID,
  }) {
    _init(surveyID, questionID, pos);

    _validation[surveyID]![questionID]![pos]!.putIfAbsent(
      'lessThanEqualLengthMatrix',
      () => {
        'access': accessKey,
        'rightOperand': nChoices,
        'choiceID': choiceID,
      },
    );
  }

  void addLTE({
    required String surveyID,
    required String questionID,
    required String rightOperand,
    required String accessKey,
    required int pos,
  }) {
    _init(surveyID, questionID, pos);

    _validation[surveyID]![questionID]![pos]!.putIfAbsent(
      'lessThanEqual',
      () => {
        'access': accessKey,
        'rightOperand': rightOperand,
      },
    );
  }

  void addContains({
    required String surveyID,
    required String questionID,
    required String rightOperand,
    required String accessKey,
    required int pos,
  }) {
    _init(surveyID, questionID, pos);

    _validation[surveyID]![questionID]![pos]!.putIfAbsent(
      'contains',
      () => {
        'access': accessKey,
        'rightOperand': rightOperand,
      },
    );
  }

  void addContainsIgnore({
    required String surveyID,
    required String questionID,
    required String rightOperand,
    required String accessKey,
    required int pos,
  }) {
    _init(surveyID, questionID, pos);

    _validation[surveyID]![questionID]![pos]!.putIfAbsent(
      'containsIgnore',
      () => {
        'access': accessKey,
        'rightOperand': rightOperand,
      },
    );
  }

  void addNotContains({
    required String surveyID,
    required String questionID,
    required String rightOperand,
    required String accessKey,
    required int pos,
  }) {
    _init(surveyID, questionID, pos);

    _validation[surveyID]![questionID]![pos]!.putIfAbsent(
      'notContains',
      () => {
        'access': accessKey,
        'rightOperand': rightOperand,
      },
    );
  }

  void addNotContainsIgnore({
    required String surveyID,
    required String questionID,
    required String rightOperand,
    required String accessKey,
    required int pos,
  }) {
    _init(surveyID, questionID, pos);

    _validation[surveyID]![questionID]![pos]!.putIfAbsent(
      'notContainsIgnore',
      () => {
        'access': accessKey,
        'rightOperand': rightOperand,
      },
    );
  }

  void addRegex({
    required String surveyID,
    required String questionID,
    required String rightOperand,
    required String accessKey,
    required int pos,
  }) {
    _init(surveyID, questionID, pos);

    _validation[surveyID]![questionID]![pos]!.putIfAbsent(
      'regex',
      () => {
        'access': accessKey,
        'rightOperand': rightOperand,
      },
    );
  }

  void addEmpty({
    required String surveyID,
    required String questionID,
    required String accessKey,
    required int pos,
  }) {
    _init(surveyID, questionID, pos);

    _validation[surveyID]![questionID]![pos]!.putIfAbsent(
      'empty',
      () => {
        'access': accessKey,
      },
    );
  }

  void addNotEmpty({
    required String surveyID,
    required String questionID,
    required String accessKey,
    required int pos,
  }) {
    _init(surveyID, questionID, pos);

    _validation[surveyID]![questionID]![pos]!.putIfAbsent(
      'notEmpty',
      () => {
        'access': accessKey,
      },
    );
  }

  void _init(surveyID, questionID, pos) {
    if (!_validation.containsKey(surveyID)) {
      _validation.putIfAbsent(surveyID, () => {});
    }

    if (!_validation[surveyID]!.containsKey(questionID)) {
      _validation[surveyID]!.putIfAbsent(questionID, () => {});
    }

    if (!_validation[surveyID]![questionID]!.containsKey(pos)) {
      _validation[surveyID]![questionID]!.putIfAbsent(pos, () => {});
    }
  }

  bool isValid({
    required String questionID,
    required Map<String, dynamic> answers,
    required String surveyID,
  }) {
    bool valid = true;
    bool contains;

    final Map<String, dynamic> answer =
        Map<String, dynamic>.from(answers[surveyID] ?? {});

    //Nessuna regola
    if (!_validation.containsKey(surveyID)) return true;
    if (!_validation[surveyID]!.containsKey(questionID)) {
      return true;
    }

    for (int i = 0; i < _validation[surveyID]![questionID]!.length; i++) {
      valid = true;
      final rules = _validation[surveyID]![questionID]![i];

      rules!.forEach(
        (key, value) {
          if (key == 'whitelist') {
            contains = true;

            if (answer[value['access']] == null) {
              answer[value['access']] = [];
            } else if (answer[value['access']].runtimeType == int) {
              answer[value['access']] = [answer[value['access']].toString()];
            }

            for (int k = 0; k < value['rightOperand'].length && contains; k++) {
              if (!answer[value['access']].contains(value['rightOperand'][k])) {
                contains = false;
              }
            }

            if (!contains) valid = false;
          } else if (key == 'matrixWhitelist') {
            contains = false;

            for (int i = 0; i < value['length']; i++) {
              if (answer["${value['access']}_${i + 1}"] == null) {
                answer["${value['access']}_${i + 1}"] = [];
              } else if (answer["${value['access']}_${i + 1}"].runtimeType ==
                  int) {
                answer["${value['access']}_${i + 1}"] = [
                  answer["${value['access']}_${i + 1}"].toString(),
                ];
              }

              for (int k = 0;
                  k < value['rightOperand'].length && !contains;
                  k++) {
                if (answer["${value['access']}_${i + 1}"]
                    .contains(value['rightOperand'][k])) {
                  contains = true;
                }
              }
            }

            if (!contains) valid = false;
          } else if (key == 'blacklist') {
            contains = false;

            if (answer[value['access']] == null) {
              answer[value['access']] = [];
            } else if (answer[value['access']].runtimeType == int) {
              answer[value['access']] = [answer[value['access']].toString()];
            }

            for (int k = 0;
                k < value['rightOperand'].length && !contains;
                k++) {
              if (answer[value['access']].contains(value['rightOperand'][k])) {
                contains = true;
              }
            }

            if (contains) valid = false;
          } else if (key == 'matrixBlacklist') {
            contains = false;

            for (int i = 0; i < value['length']; i++) {
              if (answer["${value['access']}_${i + 1}"] == null) {
                answer["${value['access']}_${i + 1}"] = [];
              } else if (answer["${value['access']}_${i + 1}"].runtimeType ==
                  int) {
                answer["${value['access']}_${i + 1}"] = [
                  answer["${value['access']}_${i + 1}"].toString(),
                ];
              }

              for (int k = 0;
                  k < value['rightOperand'].length && !contains;
                  k++) {
                if (answer["${value['access']}_${i + 1}"]
                    .contains(value['rightOperand'][k])) {
                  contains = true;
                }
              }
            }

            if (contains) valid = false;
          } else if (key == 'minChoices') {
            if (answer[value['access']].length < value['rightOperand']) {
              valid = false;
            }
          } else if (key == 'minChar') {
            if (answer[value['access']] == null) {
              valid = false;
            } else if (answer[value['access']].length < value['rightOperand']) {
              valid = false;
            }
          } else if (key == 'maxChoices') {
            if (answer[value['access']].length > value['rightOperand']) {
              valid = false;
            }
          } else if (key == 'totalChar') {
            if (answer[value['access']] == null) {
              valid = true;
            } else if (answer[value['access']].length > value['rightOperand']) {
              valid = false;
            }
          } else if (key == 'notEqualLength') {
            if (answer[value['access']] == null) {
              answer[value['access']] = [];
            }
            if (answer[value['access']].runtimeType == int) {
              answer[value['access']] = [answer[value['access'].toString()]];
            }

            if (answer[value['access']].length == value['rightOperand']) {
              valid = false;
            }
          } else if (key == 'notEqualLengthMatrix') {
            final int _choices = answer.values
                .where((el) =>
                    el == value['choiceID'] ||
                    el is List<String> && el.contains('${value['choiceID']}'))
                .length;

            if (_choices == value['rightOperand']) {
              valid = false;
            }
          } else if (key == 'notEqual') {
            if (answer[value['access']].toString() == value['rightOperand']) {
              valid = false;
            }
          } else if (key == 'notEqualIgnore') {
            if (answer[value['access']].toString().toLowerCase() ==
                value['rightOperand'].toLowerCase()) {
              valid = false;
            }
          } else if (key == 'equalLength') {
            if (answer[value['access']] == null) {
              answer[value['access']] = [];
            }
            if (answer[value['access']].runtimeType == int) {
              answer[value['access']] = [answer[value['access'].toString()]];
            }

            if (answer[value['access']].length != value['rightOperand']) {
              valid = false;
            }
          } else if (key == 'equalLengthMatrix') {
            final int _choices = answer.values
                .where((el) =>
                    el == value['choiceID'] ||
                    el is List<String> && el.contains('${value['choiceID']}'))
                .length;

            if (_choices != value['rightOperand']) {
              valid = false;
            }
          } else if (key == 'equal') {
            log("ACCESS KEY: " + value['access']);
            log(answer.entries
                .where((element) =>
                    element.key.contains(value['access'].substring(0, 6)))
                .toString());
            if (answer[value['access']] == null ||
                answer[value['access']].toString() != value['rightOperand']) {
              valid = false;
            }
          } else if (key == 'equalIgnore') {
            if (answer[value['access']] == null ||
                answer[value['access']].toString().toLowerCase() !=
                    value['rightOperand'].toLowerCase()) {
              valid = false;
            }
          } else if (key == 'greaterThanLength') {
            if (answer[value['access']] == null) {
              answer[value['access']] = [];
            }
            if (answer[value['access']].runtimeType == int) {
              answer[value['access']] = [answer[value['access'].toString()]];
            }

            if (answer[value['access']].length <= value['rightOperand']) {
              valid = false;
            }
          } else if (key == 'greaterThanLengthMatrix') {
            final int _choices = answer.entries
                .where((el) =>
                    el.key.contains(value['access']) &&
                    (el.value == value['choiceID'] ||
                        el.value is List<String> &&
                            el.value.contains('${value['choiceID']}')))
                .length;

            if (_choices <= value['rightOperand']) {
              valid = false;
            }
          } else if (key == 'greaterThan') {
            try {
              if (int.parse(answer[value['access']].toString()) <=
                  int.parse(value['rightOperand'])) {
                valid = false;
              }
            } catch (_) {
              valid = false;
            }
          } else if (key == 'greaterThanEqualLength') {
            if (answer[value['access']] == null) {
              answer[value['access']] = [];
            }
            if (answer[value['access']].runtimeType == int) {
              answer[value['access']] = [answer[value['access'].toString()]];
            }

            if (answer[value['access']].length < value['rightOperand']) {
              valid = false;
            }
          } else if (key == 'greaterThanEqualLengthMatrix') {
            final int _choices = answer.entries
                .where((el) =>
                    el.key.contains(value['access']) &&
                    (el.value == value['choiceID'] ||
                        el.value is List<String> &&
                            el.value.contains('${value['choiceID']}')))
                .length;

            if (_choices < value['rightOperand']) {
              valid = false;
            }
          } else if (key == 'greaterThanEqual') {
            try {
              if (int.parse(answer[value['access']].toString()) <
                  int.parse(value['rightOperand'])) {
                valid = false;
              }
            } catch (_) {
              valid = false;
            }
          } else if (key == 'lessThanLength') {
            if (answer[value['access']] == null) {
              answer[value['access']] = [];
            }
            if (answer[value['access']].runtimeType == int) {
              answer[value['access']] = [answer[value['access'].toString()]];
            }

            if (answer[value['access']].length >= value['rightOperand']) {
              valid = false;
            }
          } else if (key == 'lessThanLengthMatrix') {
            final int _choices = answer.entries
                .where((el) =>
                    el.key.contains(value['access']) &&
                    (el.value == value['choiceID'] ||
                        el.value is List<String> &&
                            el.value.contains('${value['choiceID']}')))
                .length;

            if (_choices >= value['rightOperand']) {
              valid = false;
            }
          } else if (key == 'lessThan') {
            try {
              if (int.parse(answer[value['access']].toString()) >=
                  int.parse(value['rightOperand'])) {
                valid = false;
              }
            } catch (_) {
              valid = false;
            }
          } else if (key == 'lessThanEqualLength') {
            if (answer[value['access']] == null) {
              answer[value['access']] = [];
            }
            if (answer[value['access']].runtimeType == int) {
              answer[value['access']] = [answer[value['access'].toString()]];
            }

            if (answer[value['access']].length > value['rightOperand']) {
              valid = false;
            }
          } else if (key == 'lessThanEqualLengthMatrix') {
            final int _choices = answer.entries
                .where((el) =>
                    el.key.contains(value['access']) &&
                    (el.value == value['choiceID'] ||
                        el.value is List<String> &&
                            el.value.contains('${value['choiceID']}')))
                .length;

            if (_choices > value['rightOperand']) {
              valid = false;
            }
          } else if (key == 'lessThanEqual') {
            try {
              if (int.parse(answer[value['access']].toString()) >
                  int.parse(value['rightOperand'])) {
                valid = false;
              }
            } catch (_) {
              valid = false;
            }
          } else if (key == 'empty') {
            if (answer[value['access']] != null &&
                answer[value['access']].toString().length != 0) {
              valid = false;
            }
          } else if (key == 'notEmpty') {
            if (answer[value['access']] == null ||
                answer[value['access']].toString().length == 0) {
              valid = false;
            }
          } else if (key == 'contains') {
            if (answer[value['access']] == null ||
                !answer[value['access']]
                    .toString()
                    .contains(value['rightOperand'])) {
              valid = false;
            }
          } else if (key == 'containsIgnore') {
            if (answer[value['access']] == null ||
                !answer[value['access']]
                    .toString()
                    .toLowerCase()
                    .contains(value['rightOperand'].toLowerCase())) {
              valid = false;
            }
          } else if (key == 'notContains') {
            if (answer[value['access']] != null) {
              if (answer[value['access']]
                  .toString()
                  .contains(value['rightOperand'])) {
                valid = false;
              }
            }
          } else if (key == 'notContainsIgnore') {
            if (answer[value['access']] != null) {
              if (answer[value['access']]
                  .toString()
                  .toLowerCase()
                  .contains(value['rightOperand'].toLowerCase())) {
                valid = false;
              }
            }
          } else if (key == 'regex') {
            final RegExp exp = RegExp(value['rightOperand']);
            if (!exp.hasMatch(answer[value['access']] ?? '')) valid = false;
          }
        },
      );
      if (valid) return true;
    }

    if (valid) {
      log(questionID + " passed!");
    } else {
      log(questionID + " did not pass!");
    }

    return valid;
  }
}
