import 'dart:developer';

import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../questionHandlers/constant_sum_handler.dart';
import '../questionHandlers/export_handlers.dart';
import '../screens/congratulation_screen.dart';
import './answers.dart';
import './user_settings.dart';

class Questions with ChangeNotifier {
  Map<String, dynamic> _questions = {};
  Map<String, dynamic> names = {};
  Map<String, dynamic> images = {};
  String profileAbout = "";
  String profileCredits = "";

  String getBlockPrettyName(String surveyName, blockName) {
    if (names.containsKey(surveyName)) {
      if (names[surveyName].containsKey(blockName)) {
        return names[surveyName][blockName];
      }

      return 'Name not found';
    }

    return 'SurveyID not found in names';
  }

  List<String> getSurveys() {
    return _questions.keys.toList();
  }

  Future<bool> areQuestionsSaved() async {
    final box = await Hive.openBox('MoshiMoshi');

    return box.containsKey("questions");
  }

  bool hasBlock(String surveyName, String blockID) {
    if (!_questions.containsKey(surveyName)) return false;

    // Prendo la mappa raw e la converto
    final rawBlocks = _questions[surveyName]['blocks'];
    if (rawBlocks is! Map) return false;
    final blocksMap = Map<String, dynamic>.from(
      rawBlocks.map((key, value) => MapEntry(key.toString(), value)),
    );

    // Cerco un blocco il cui campo 'id' corrisponda a blockID
    return blocksMap.values.any((blk) {
      if (blk is Map) {
        final id = blk['id'];

        return id == blockID;
      }

      return false;
    });
  }

  bool hasQuestion(String surveyName, String questionID) {
    if (!_questions.containsKey(surveyName)) return false;

    final rawBlocks = _questions[surveyName]['blocks'];
    if (rawBlocks is! Map) return false;
    final blocksMap = Map<String, dynamic>.from(
      rawBlocks.map((key, value) => MapEntry(key.toString(), value)),
    );

    for (var blk in blocksMap.values) {
      if (blk is Map && blk['questions'] is Map) {
        final rawQs = blk['questions'] as Map;
        final qsMap = Map<String, dynamic>.from(
          rawQs.map((key, value) => MapEntry(key.toString(), value)),
        );
        if (qsMap.containsKey(questionID)) return true;
      }
    }

    return false;
  }

  Future<void> readFromLocal() async {
    final box = await Hive.openBox('MoshiMoshi');
    _questions = Map<String, dynamic>.from(box.get("questions"));
    names = Map<String, dynamic>.from(box.get("names"));
    images = Map<String, dynamic>.from(box.get("images"));
    profileAbout = box.get("profileAbout");
    profileCredits = box.get("profileCredits");
  }

  Future<void> removeSurvey(String surveyID) async {
    final box = await Hive.openBox('MoshiMoshi');
    _questions = Map<String, dynamic>.from(box.get("questions"));

    _questions.remove(surveyID);
  }

  Future<void> writeToLocal() async {
    final box = await Hive.openBox('MoshiMoshi');
    await box.put("questions", _questions);
    await box.put("names", names);
    await box.put("images", images);
    await box.put("profileAbout", profileAbout);
    await box.put("profileCredits", profileCredits);
  }

  Future<void> removeFromLocal() async {
    final box = await Hive.openBox('MoshiMoshi');
    await box.delete("questions");
    await box.delete("names");
    await box.delete("images");
    await box.delete("profileAbout");
    await box.delete("profileCredits");
  }

  void addSurvey(String surveyID, String name) {
    _questions.putIfAbsent(
      name,
      () => {
        "id": surveyID,
        "blocks": {},
      },
    );
  }

  void addBlock(String surveyName, String blockID, String name) {
    _questions[surveyName]['blocks'].putIfAbsent(
      name,
      () => {
        "id": blockID,
        "questions": {},
      },
    );
  }

  void addQuestion(
    String surveyID,
    String blockID,
    String questionID,
    Map<String, dynamic> settings,
  ) {
    //_questions[surveyID][blockID] = Map<String, dynamic>.from(_questions[surveyID][blockID]);

    _questions[surveyID]['blocks'][blockID]['questions']
        .putIfAbsent(questionID, () => settings);
    notifyListeners();
  }

  Map<String, dynamic> questions(String surveyName, String blockName) {
    return _questions[surveyName]['blocks'].containsKey(blockName)
        ? _questions[surveyName]['blocks'][blockName].containsKey('questions')
            ? Map<String, dynamic>.from(
                _questions[surveyName]['blocks'][blockName]['questions'],
              )
            : {}
        : {};
  }

  Map<String, dynamic> blocks(String surveyName) {
    return Map<String, dynamic>.from(_questions[surveyName]['blocks']);
  }

  String surveyID(String surveyName) {
    return _questions[surveyName]['id'];
  }

  String surveyName(String surveyID) {
    return _questions.entries
        .firstWhere((element) => element.value['id'] == surveyID)
        .key;
  }

  Widget buildQuestion({
    required String surveyName,
    required String blockName,
    required var indexData,
    required BuildContext ctx,
    bool disabled = false,
    bool dontSkip = false,
  }) {
    final Map<String, dynamic> _questions = questions(surveyName, blockName);
    final _surveyID = surveyID(surveyName);

    final notDisplayCongratsScreen = [
      // "MM_baseline_assessment_week1",
      "MM_SP_segnalidiavvertimento",
      "MM_SP_strategiedicopinginterne",
      "MM_SP_strategiedicopingesterne",
      "MM_SP_contattipersonali",
      "MM_SP_contattiprofessionali",
      "MM_SP_ambientesicuro",
      "MM_SP_ragionidivita",
      "MM_lista_attivita_piacevoli",
      "MM_testimonianze",
    ];

    if (!notDisplayCongratsScreen.contains(surveyName) &&
        indexData['index'] == _questions.length) {
      return CongratulationScreen(
        surveyName: getBlockPrettyName(surveyName, "survey_root_name"),
        blockName: getBlockPrettyName(surveyName, blockName),
      );
      // }
    }

    final String questionID = _questions.keys.elementAt(indexData['index']);
    final String _qt = _questions[questionID]['QuestionType'];
    final Map<String, dynamic> value =
        Map<String, dynamic>.from(_questions[questionID]);
    Widget _ret = const SizedBox();

    final bool skip = isSkip(value, ctx, _surveyID) || dontSkip;

    if (!skip) {
      if (indexData['direction'] == 'next') {
        indexData['index'] = indexData['index'] + 1;
      } else {
        indexData['index'] = indexData['index'] - 1;
      }

      return buildQuestion(
        surveyName: surveyName,
        blockName: blockName,
        indexData: indexData,
        ctx: ctx,
      );
    }

    log(_qt);

    switch (_qt) {
      case 'MC':
        _ret = multichoiceHandler(value, ctx, _surveyID, blockName, disabled);
        break;
      case 'TE':
        _ret = textEntryHandler(value, ctx, _surveyID, blockName, disabled);
        break;
      case 'DB':
        _ret = descriptionBoxHandler(value, _surveyID, blockName);
        break;
      case 'Matrix':
        _ret = matrixHandler(value, ctx, _surveyID, blockName, disabled);
        break;
      case 'Slider':
        _ret = sliderHandler(value, ctx, _surveyID, blockName, disabled);
        break;
      case 'RO':
        _ret = rankOrderHandler(value, ctx, _surveyID, blockName, disabled);
        break;
      case 'SBS':
        _ret = sideBySideHandler(value, ctx, _surveyID, blockName, disabled);
        break;
      case 'PGR':
        _ret = pickGroupRankHandler(value, ctx, _surveyID, blockName, disabled);
        break;
      case 'CS':
        _ret = constantSumHandler(value, _surveyID, blockName, disabled);
        break;
      case 'FileUpload':
        _ret = fileUploaderHandler(value, _surveyID, blockName);
        break;
    }

    return _ret;
  }

  bool isSkip(
    Map<String, dynamic> question,
    BuildContext ctx,
    String surveyID,
    {bool logLogic = false, String? logOnlyQuestionId}
  ) {
    final String questionId = (question['QuestionID'] ?? '').toString();
    final bool shouldLog = (logLogic || _debugEnabled(ctx)) &&
        (logOnlyQuestionId == null || logOnlyQuestionId == questionId);

    final bool hasDisplayLogic = question.containsKey('DisplayLogic');
    final bool hasInPageDisplayLogic =
        question.containsKey('InPageDisplayLogic');

    // No logic => always display.
    if (!hasDisplayLogic && !hasInPageDisplayLogic) {
      if (shouldLog) {
        log(
          '[DisplayLogic] q=$questionId -> no logic => DISPLAY',
          name: 'DisplayLogic',
        );
      }
      return true;
    }

    final rawLogicDynamic =
        hasDisplayLogic ? question['DisplayLogic'] : question['InPageDisplayLogic'];
    if (rawLogicDynamic is! Map) {
      if (shouldLog) {
        log(
          '[DisplayLogic] q=$questionId -> logic is not a Map (${rawLogicDynamic.runtimeType}) => DISPLAY',
          name: 'DisplayLogic',
        );
      }
      return true;
    }

    final rawLogic = Map<String, dynamic>.from(rawLogicDynamic);

    final answers = Provider.of<Answers>(ctx, listen: false);

    // DisplayLogic has OR between groups (0,1,2...), AND/OR within group.
    bool shouldDisplay = false;
    final groups = rawLogic.entries
        .where((e) => e.key != 'Type')
        .toList()
      ..sort((a, b) {
        final ai = int.tryParse(a.key) ?? 1 << 30;
        final bi = int.tryParse(b.key) ?? 1 << 30;
        return ai.compareTo(bi);
      });

    for (final groupEntry in groups) {
      final group = groupEntry.value;
      if (group is! Map) continue;
      final Map<String, dynamic> logicGroup =
          Map<String, dynamic>.from(group).cast<String, dynamic>();
      logicGroup.removeWhere((key, value) => key == 'Type');

      bool? groupResult;
      final rules = logicGroup.entries.toList()
        ..sort((a, b) {
          final ai = int.tryParse(a.key) ?? 1 << 30;
          final bi = int.tryParse(b.key) ?? 1 << 30;
          return ai.compareTo(bi);
        });

      for (final ruleEntry in rules) {
        final rule = ruleEntry.value;
        if (rule is! Map) continue;
        final bool ruleResult = _checkSkip(
          rule,
          answers,
          surveyID,
          logLogic: shouldLog,
          trace: 'q=$questionId group=${groupEntry.key} rule=${ruleEntry.key}',
        );
        final String conj =
            (rule['Conjuction'] ?? rule['Conjunction'] ?? 'And').toString();

        if (groupResult == null) {
          groupResult = ruleResult;
        } else if (conj == 'Or') {
          groupResult = groupResult || ruleResult;
        } else {
          groupResult = groupResult && ruleResult;
        }
      }

      if (groupResult ?? false) {
        shouldDisplay = true;
        break;
      }
    }

    if (shouldLog) {
      log(
        '[DisplayLogic] q=$questionId -> ${shouldDisplay ? "DISPLAY" : "HIDE"}',
        name: 'DisplayLogic',
      );
    }

    return shouldDisplay;
  }

  bool _checkSkip(
    rule,
    Answers answers,
    String surveyID, {
    bool logLogic = false,
    String? trace,
  }) {
    if (rule == null) return false;

    final Map<String, dynamic> ruleMap =
        Map<String, dynamic>.from(rule).cast<String, dynamic>();

    final locatorRaw = ruleMap['ChoiceLocator'];
    if (locatorRaw is! String || locatorRaw.isEmpty) {
      if (logLogic) {
        log(
          '[DisplayLogic] ${trace ?? ""} -> invalid ChoiceLocator (${locatorRaw.runtimeType}) => false',
          name: 'DisplayLogic',
        );
      }
      return false;
    }

    final String referencedQuestionID =
        _extractReferencedQuestionID(ruleMap, locatorRaw);
    final String locator = _extractLocatorTail(locatorRaw);

    final String operator = (ruleMap['Operator'] ?? 'Selected').toString();
    final dynamic rightOperand = ruleMap['RightOperand'];
    final bool ignoreCase =
        ruleMap.containsKey('IgnoreCase') && ruleMap['IgnoreCase'] == 1;

    if (locator.contains('SelectableChoice')) {
      final String after = locator.split('SelectableChoice/').length > 1
          ? locator.split('SelectableChoice/')[1]
          : '';
      final parts = after.split('/');
      final String? altExpected =
          _recodeValueFor(surveyID, referencedQuestionID, parts.isNotEmpty ? parts.last : '');

      // Simple choice selection (MC/Slider style): q://QID/SelectableChoice/<choiceId>
      if (parts.length <= 1) {
        final choiceId = after;
        final stored = answers.getAnswer(surveyID, referencedQuestionID);
        final match = _matchesSelected(stored, choiceId, altExpected: altExpected);
        if (logLogic) {
          log(
            '[DisplayLogic] ${trace ?? ""} SelectableChoice key=$referencedQuestionID op=$operator expected=$choiceId alt=$altExpected stored=${_short(stored)} -> $match',
            name: 'DisplayLogic',
          );
        }
        if (operator == 'Selected') return match;
        if (operator == 'NotSelected') return !match;

        return false;
      }

      // Matrix / SideBySide: q://QID/SelectableChoice/<choiceId>/<answerId>
      final choiceId = parts[0];
      final answerId = parts[1];
      final stored = answers.getAnswer(surveyID, "${referencedQuestionID}_$choiceId");
      final match = _matchesSelected(stored, answerId, altExpected: altExpected);
      if (logLogic) {
        log(
          '[DisplayLogic] ${trace ?? ""} SelectableChoice key=${referencedQuestionID}_$choiceId op=$operator expected=$answerId alt=$altExpected stored=${_short(stored)} -> $match',
          name: 'DisplayLogic',
        );
      }
      if (operator == 'Selected') return match;
      if (operator == 'NotSelected') return !match;

      return false;
    }

    if (locator.contains('SelectableAnswer')) {
      final String answerId = locator.split('SelectableAnswer/').length > 1
          ? locator.split('SelectableAnswer/')[1]
          : '';
      final String? altExpected = _recodeValueFor(surveyID, referencedQuestionID, answerId);

      bool anyMatch = false;
      final direct = answers.getAnswer(surveyID, referencedQuestionID);
      if (direct != null) {
        anyMatch = _matchesSelected(direct, answerId, altExpected: altExpected);
      } else {
        anyMatch = _anyCompositeMatch(
          answers: answers,
          surveyID: surveyID,
          questionIDPrefix: referencedQuestionID,
          expected: answerId,
          altExpected: altExpected,
        );
      }

      if (logLogic) {
        log(
          '[DisplayLogic] ${trace ?? ""} SelectableAnswer key=$referencedQuestionID op=$operator expected=$answerId alt=$altExpected direct=${_short(direct)} -> $anyMatch',
          name: 'DisplayLogic',
        );
      }

      if (operator == 'Selected') return anyMatch;
      if (operator == 'NotSelected') return !anyMatch;

      return false;
    }

    if (locator.contains('SelectedChoicesCount')) {
      final dynamic stored = answers.getAnswer(surveyID, referencedQuestionID);
      final int count = _countSelections(stored);
      final int rightValue = int.tryParse('$rightOperand') ?? 0;
      if (logLogic) {
        log(
          '[DisplayLogic] ${trace ?? ""} SelectedChoicesCount key=$referencedQuestionID op=$operator right=$rightValue count=$count stored=${_short(stored)}',
          name: 'DisplayLogic',
        );
      }
      return _compareNumeric(count, operator, rightValue);
    }

    if (locator.contains('SelectedAnswerCount')) {
      final String after = locator.split('SelectedAnswerCount/').length > 1
          ? locator.split('SelectedAnswerCount/')[1]
          : '';
      final String choiceId = after.isEmpty ? '' : after.split('/').first;

      final dynamic stored = choiceId.isEmpty
          ? answers.getAnswer(surveyID, referencedQuestionID)
          : (answers.getAnswer(surveyID, "${referencedQuestionID}_$choiceId") ??
              answers.getAnswer(surveyID, referencedQuestionID));

      final int count = _countSelections(stored);
      final int rightValue = int.tryParse('$rightOperand') ?? 0;
      if (logLogic) {
        log(
          '[DisplayLogic] ${trace ?? ""} SelectedAnswerCount key=${choiceId.isEmpty ? referencedQuestionID : "${referencedQuestionID}_$choiceId"} op=$operator right=$rightValue count=$count stored=${_short(stored)}',
          name: 'DisplayLogic',
        );
      }
      return _compareNumeric(count, operator, rightValue);
    }

    if (locator.contains('ChoiceTextEntryValue')) {
      final String after = locator.split('ChoiceTextEntryValue/').length > 1
          ? locator.split('ChoiceTextEntryValue/')[1]
          : '';
      final String keyPart = after.replaceAll('/', '_');

      final dynamic stored = answers.getAnswer(
            surveyID,
            "${referencedQuestionID}_${keyPart}_TEXT",
          ) ??
          answers.getAnswer(surveyID, "${referencedQuestionID}_TEXT") ??
          answers.getAnswer(surveyID, "${referencedQuestionID}_$keyPart");

      if (logLogic) {
        log(
          '[DisplayLogic] ${trace ?? ""} ChoiceTextEntryValue keyPart=$keyPart op=$operator right=${_short(rightOperand)} stored=${_short(stored)} ignoreCase=$ignoreCase',
          name: 'DisplayLogic',
        );
      }
      return _compareText(
        stored?.toString(),
        operator,
        rightOperand?.toString(),
        ignoreCase: ignoreCase,
      );
    }

    if (locator.contains('ChoiceNumericEntryValue')) {
      final String after = locator.split('ChoiceNumericEntryValue/').length > 1
          ? locator.split('ChoiceNumericEntryValue/')[1]
          : '';
      final String keyPart = after.replaceAll('/', '_');

      final dynamic stored =
          answers.getAnswer(surveyID, "${referencedQuestionID}_$keyPart") ??
              answers.getAnswer(surveyID, referencedQuestionID);

      final double? left = _toDouble(stored);
      final double? right = _toDouble(rightOperand);
      if (left == null || right == null) return false;

      if (logLogic) {
        log(
          '[DisplayLogic] ${trace ?? ""} ChoiceNumericEntryValue keyPart=$keyPart op=$operator left=$left right=$right stored=${_short(stored)}',
          name: 'DisplayLogic',
        );
      }
      return _compareNumeric(left, operator, right);
    }

    if (logLogic) {
      log(
        '[DisplayLogic] ${trace ?? ""} Unsupported locator="$locator" operator="$operator" => false',
        name: 'DisplayLogic',
      );
    }
    return false;
  }

  bool _debugEnabled(BuildContext ctx) {
    try {
      return Provider.of<UserSettings>(ctx, listen: false).debug;
    } catch (_) {
      return false;
    }
  }

  String _short(dynamic value) {
    if (value == null) return 'null';
    if (value is List) return 'List(len=${value.length})';
    if (value is Map) return 'Map(len=${value.length})';
    final s = value.toString();
    if (s.length <= 60) return s;
    return '${s.substring(0, 60)}…';
  }

  String _extractReferencedQuestionID(
    Map<String, dynamic> rule,
    String locatorRaw,
  ) {
    final fromLocator = rule['QuestionIDFromLocator'];
    if (fromLocator is String && fromLocator.isNotEmpty) {
      return fromLocator;
    }

    final qid = rule['QuestionID'];
    if (qid is String && qid.isNotEmpty) {
      return qid;
    }

    final match = RegExp(r"q://([^/]+)/").firstMatch(locatorRaw);
    if (match != null) return match.group(1)!;

    return qid?.toString() ?? '';
  }

  String _extractLocatorTail(String locatorRaw) {
    final match = RegExp(r"q://[^/]+/(.*)$").firstMatch(locatorRaw);
    return match?.group(1) ?? locatorRaw;
  }

  bool _matchesSelected(
    dynamic stored,
    String expected, {
    String? altExpected,
  }) {
    if (expected.isEmpty && (altExpected == null || altExpected.isEmpty)) {
      return false;
    }
    if (stored == null) return false;

    if (stored is num) {
      return stored.toString() == expected ||
          (altExpected != null && stored.toString() == altExpected);
    }
    if (stored is String) return stored == expected || stored == altExpected;
    if (stored is List) {
      final list = stored.map((e) => e.toString()).toList();
      return list.contains(expected) ||
          (altExpected != null && list.contains(altExpected));
    }

    return false;
  }

  int _countSelections(dynamic stored) {
    if (stored == null) return 0;
    if (stored is List) return stored.length;
    if (stored is Map) {
      return stored.values.where((v) => v != null && v.toString().isNotEmpty).length;
    }

    return 0;
  }

  bool _anyCompositeMatch({
    required Answers answers,
    required String surveyID,
    required String questionIDPrefix,
    required String expected,
    String? altExpected,
  }) {
    final surveyAnswers = answers.answers[surveyID];
    if (surveyAnswers is! Map) return false;

    for (final entry in surveyAnswers.entries) {
      final key = entry.key?.toString() ?? '';
      if (!key.startsWith("${questionIDPrefix}_")) continue;
      if (_matchesSelected(entry.value, expected, altExpected: altExpected)) {
        return true;
      }
    }

    return false;
  }

  String? _recodeValueFor(String surveyID, String questionID, String id) {
    if (id.isEmpty) return null;

    String survey;
    try {
      survey = surveyName(surveyID);
    } catch (_) {
      return null;
    }

    final question = _getQuestionDefinition(survey, questionID);
    if (question == null) return null;

    final rawRecode = question['RecodeValues'];
    if (rawRecode is! Map) return null;

    final recode = rawRecode.map(
      (k, v) => MapEntry(k.toString(), v),
    );

    final val = recode[id];
    if (val == null) return null;

    return val.toString();
  }

  Map<String, dynamic>? _getQuestionDefinition(
    String surveyName,
    String questionID,
  ) {
    if (!_questions.containsKey(surveyName)) return null;

    final rawBlocks = _questions[surveyName]['blocks'];
    if (rawBlocks is! Map) return null;
    final blocksMap = Map<String, dynamic>.from(
      rawBlocks.map((key, value) => MapEntry(key.toString(), value)),
    );

    for (final blk in blocksMap.values) {
      if (blk is! Map || blk['questions'] is! Map) continue;
      final rawQs = blk['questions'] as Map;
      final qsMap = Map<String, dynamic>.from(
        rawQs.map((key, value) => MapEntry(key.toString(), value)),
      );
      if (qsMap.containsKey(questionID) && qsMap[questionID] is Map) {
        return Map<String, dynamic>.from(qsMap[questionID]);
      }
    }

    return null;
  }

  bool _compareNumeric(num left, String operator, num right) {
    switch (operator) {
      case 'EqualTo':
        return left == right;
      case 'NotEqualTo':
        return left != right;
      case 'GreaterThan':
        return left > right;
      case 'GreaterThanOrEqual':
        return left >= right;
      case 'LessThan':
        return left < right;
      case 'LessThanOrEqual':
        return left <= right;
      default:
        return false;
    }
  }

  bool _compareText(
    String? left,
    String operator,
    String? right, {
    bool ignoreCase = false,
  }) {
    final String? l = ignoreCase ? left?.toLowerCase() : left;
    final String? r = ignoreCase ? right?.toLowerCase() : right;

    switch (operator) {
      case 'EqualTo':
        return l == r;
      case 'NotEqualTo':
        return l != r;
      case 'Contains':
        return l != null && r != null && l.contains(r);
      case 'NotContains':
      case 'DoesNotContain':
        return l != null && r != null && !l.contains(r);
      case 'StartsWith':
        return l != null && r != null && l.startsWith(r);
      case 'EndsWith':
        return l != null && r != null && l.endsWith(r);
      case 'Empty':
        return l == null || l.isEmpty;
      case 'NotEmpty':
        return l != null && l.isNotEmpty;
      case 'MatchesRegex':
        if (l == null || r == null) return false;
        try {
          return RegExp(r).hasMatch(l);
        } catch (_) {
          return false;
        }
      default:
        return false;
    }
  }

  double? _toDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();

    return double.tryParse(value.toString());
  }
}

class RadiantGradientMask extends StatelessWidget {
  RadiantGradientMask({
    required this.child,
    required this.from,
    required this.to,
  });
  final Widget child;
  final Color from;
  final Color to;

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (bounds) => RadialGradient(
        center: Alignment.center,
        radius: 0.5,
        colors: [from, to],
        tileMode: TileMode.mirror,
      ).createShader(bounds),
      child: child,
    );
  }
}
