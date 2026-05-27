import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/answers.dart';
import '../providers/questions.dart';
import 'progress.dart';

Progress computeProgress(
  BuildContext context,
  String surveyName,
  Map<String, dynamic> blocks,
) {
  final qp = Provider.of<Questions>(context);
  final ap = Provider.of<Answers>(context);
  final String surveyID = qp.surveyID(surveyName);

  int totalVisible = 0;
  int answeredQuestions = 0;

  for (var blockEntry in blocks.entries) {
    final Map<String, dynamic> questionMap =
        Map<String, dynamic>.from(blockEntry.value['questions']);

    final visibleKeys = questionMap.entries
        .where((e) => qp.isSkip(
              Map<String, dynamic>.from(e.value),
              context,
              surveyID,
            ))
        .map((e) => e.key)
        .toList();

    totalVisible += visibleKeys.length;
    answeredQuestions += ap.getAnswerCountKeys(surveyID, visibleKeys);
  }

  return Progress(answeredQuestions, totalVisible);
}
