import 'dart:developer';

import 'package:basics/basics.dart';
import 'package:flutter/cupertino.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';

import '../models/daily_screening.dart';
import '../models/weekly_screening.dart';
import '../models/exercise.dart';

class Progress with ChangeNotifier {
  late Box hive;
  late DateTime start;

  late Map<String, List<String>> doneBlocks;
  late Map<String, List<DailyScreening>> dailyScreenings;
  late Map<String, List<WeeklyScreening>> weeklyScreenings;
  late Map<String, List<Exercise>> weeklyExercises;

  late List<String> doneSurveys;

  late List<double> dailym1;
  late List<double> dailym2;
  late List<double> dailyDiffRel;

  void init() async {
    await Hive.openBox("MoshiMoshi").then((value) => hive = value);
    doneBlocks = Map<String, List<String>>.from(
      hive.get("doneBlocks", defaultValue: {}),
    );
    doneSurveys = List<String>.from(hive.get("doneSurveys", defaultValue: []));
    // Initialize `start` once, normalized to midnight, and persist it if missing.
    final dynamic storedStart = hive.get("start");
    if (storedStart is DateTime) {
      // Normalize to date-only to avoid time drift issues in comparisons/keys
      start = DateTime(storedStart.year, storedStart.month, storedStart.day);
    } else {
      final now = DateTime.now();
      start = DateTime(now.year, now.month, now.day);
      hive.put("start", start);
    }

    final Map<String, List<dynamic>> ds = Map<String, List<dynamic>>.from(
      hive.get("dailyScreenings", defaultValue: {}),
    );
    dailyScreenings = Map<String, List<DailyScreening>>.from(ds
        .map((key, value) => MapEntry(key, List<DailyScreening>.from(value))));

    final Map<String, List<dynamic>> ws = Map<String, List<dynamic>>.from(
      hive.get("weeklyScreenings", defaultValue: {}),
    );
    weeklyScreenings = Map<String, List<WeeklyScreening>>.from(ws
        .map((key, value) => MapEntry(key, List<WeeklyScreening>.from(value))));

    final Map<String, List<dynamic>> we = Map<String, List<dynamic>>.from(
      hive.get("weeklyExercises", defaultValue: {}),
    );
    weeklyExercises = Map<String, List<Exercise>>.from(
      we.map((key, value) => MapEntry(key, List<Exercise>.from(value))),
    );

    dailym1 = List<double>.from(
      hive.get(
        "dailym1",
        defaultValue: List.generate(
          49,
          (index) => -10.0,
        ),
      ),
    );
    dailym2 = List<double>.from(
      hive.get(
        "dailym2",
        defaultValue: List.generate(
          49,
          (index) => -10.0,
        ),
      ),
    );
    dailyDiffRel = List<double>.from(
      hive.get(
        "dailyDiffRel",
        defaultValue: List.generate(
          49,
          (index) => -10.0,
        ),
      ),
    );
  }

  void initEvents(String modulo1, String modulo2) {
    addDailyScreenings(modulo1, modulo2);
    addWeeklyScreeings(modulo1, modulo2);
    addExercises(modulo1, modulo2);
  }

  void addDailyScreenings(String modulo1, String modulo2) {
    for (int i = 0; i < 49; i++) {
      final week = (i ~/ 7) + 1;
      final day = (i % 7) + 1;

      final DateTime keyDate = start.addCalendarDays(i);
      final String key = DateFormat('yyyy-MM-dd').format(keyDate);

      log("MM_${modulo1}_${modulo2}_daily_w${week}_d${day}");

      dailyScreenings.putIfAbsent(
        key,
        () => [
          DailyScreening(
            blockName: "domande_daily",
            surveyName: "MM_${modulo1}_${modulo2}_daily_w${week}_d${day}",
            modulo: "Rispondi oggi",
            index: 0,
            done: false,
          ),
        ],
      );
    }

    hive.put("dailyScreenings", dailyScreenings);
    notifyListeners();
  }

  void addWeeklyScreeings(String modulo1, modulo2) {
    for (int i = 2; i <= 7; i++) {
      // , j = -1
      final DateTime dayKey = start.addCalendarDays(7 * (i - 1));
      final String key = DateFormat('yyyy-MM-dd').format(dayKey);

      log(key);
      log("MM_${modulo1}_weekly_w$i");
      log("MM_${modulo2}_weekly_w$i");
      log("------------------------------------------------");

      weeklyScreenings.putIfAbsent(
        key,
        () => [
          WeeklyScreening(
            blockName: "${modulo1}_domande",
            surveyName: "MM_${modulo1}_weekly_w$i",
            modulo: modulo1,
            // blockIndex: i,
            done: false,
          ),
          WeeklyScreening(
            blockName: "${modulo2}_domande",
            surveyName: "MM_${modulo2}_weekly_w$i",
            modulo: modulo2,
            // blockIndex: i,
            done: false,
          ),
        ],
      );
      // }
    }

    hive.put("weeklyScreenings", weeklyScreenings);
    notifyListeners();
  }

  void addExercises(String modulo1, String modulo2) {
    final dateFmt = DateFormat('yyyy-MM-dd');
    for (int i = 0; i < 6; i++) {
      final DateTime dayKey = start.addCalendarDays(7 * i);
      final String key = dateFmt.format(dayKey);
      final int blockIndex = i + 1;

      weeklyExercises.putIfAbsent(
        key,
        () => [
          Exercise(
            surveyName: "MM_${modulo1}_week$blockIndex",
            modulo: modulo1,
            done: false,
            assessment: false,
            tappa: null,
          ),
          Exercise(
            surveyName: "MM_${modulo2}_week$blockIndex",
            modulo: modulo2,
            done: false,
            assessment: false,
            tappa: null,
          ),
        ],
      );
      // }
    }

    DateTime dayKey = start.addCalendarDays(56);
    String key = dateFmt.format(dayKey);

    weeklyExercises.putIfAbsent(
      key,
      () => [
        Exercise(
          surveyName: "MM_baseline_assessment_8",
          modulo: "baseline_assessment",
          done: false,
          assessment: true,
          tappa: "first",
        ),
      ],
    );

    dayKey = start.addCalendarDays(84);
    key = dateFmt.format(dayKey);

    weeklyExercises.putIfAbsent(
      key,
      () => [
        Exercise(
          surveyName: "MM_baseline_assessment_12",
          modulo: "baseline_assessment",
          done: false,
          assessment: true,
          tappa: "second",
        ),
      ],
    );

    dayKey = start.addCalendarDays(168);
    key = dateFmt.format(dayKey);

    weeklyExercises.putIfAbsent(
      key,
      () => [
        Exercise(
          surveyName: "MM_baseline_assessment_24",
          modulo: "baseline_assessment",
          done: false,
          assessment: true,
          tappa: "third",
        ),
      ],
    );

    hive.put("weeklyExercises", weeklyExercises);
    notifyListeners();
  }

  void setStart(DateTime day) {
    start = DateTime(day.year, day.month, day.day);
    hive.put("start", start);
    notifyListeners();
  }

  void addToM1(double value, int index, {bool notify = true}) {
    dailym1[index] = value;
    hive.put("dailym1", dailym1);

    if (notify) {
      notifyListeners();
    }
  }

  void addToM2(double value, int index, {bool notify = true}) {
    dailym2[index] = value;
    hive.put("dailym2", dailym2);
    if (notify) {
      notifyListeners();
    }
  }

  void addToMDiffRel(double value, int index) {
    dailyDiffRel[index] = value;
    hive.put("dailyDiffRel", dailyDiffRel);
    notifyListeners();
  }

  bool isPanoramicaEmpty() {
    for (double m in dailym1) {
      if (m != -10.0) {
        return false;
      }
    }

    for (double m in dailym2) {
      if (m != -10.0) {
        return false;
      }
    }

    return true;
  }

  List<Exercise> getFirstUndoneEx() {
    for (MapEntry<String, List<Exercise>> entry in weeklyExercises.entries) {
      if (entry.value.any((element) => !element.done)) {
        return List<Exercise>.from(entry.value);
      }
    }

    return [];
  }

  bool undoneEx(int week) {
    for (int i = 0; i < week; i++) {
      final ex = weeklyExercises.values.elementAt(i);
      if (ex.any((element) => !element.done)) {
        return true;
      }
    }

    return false;
  }

  void addDoneBlock(String surveyName, String blockName) {
    if (!doneBlocks.containsKey(surveyName)) {
      doneBlocks.putIfAbsent(surveyName, () => [blockName]);
    } else {
      doneBlocks.update(surveyName, (value) {
        if (!value.contains(blockName)) value.add(blockName);

        return List<String>.from(value);
      });
    }

    hive.put("doneBlocks", doneBlocks);
    notifyListeners();
  }

  void removeBlock(String surveyName, String blockName) {
    if (doneBlocks.containsKey(surveyName) &&
        doneBlocks[surveyName]!.contains(blockName)) {
      doneBlocks[surveyName]!.remove(blockName);
      hive.put("doneBlocks", doneBlocks);
      notifyListeners();
    }
  }

  bool isDoneBlock(String surveyName, String blockName) {
    if (doneBlocks.containsKey(surveyName) && doneBlocks[surveyName] != null) {
      if (doneBlocks[surveyName]!.contains(blockName)) {
        return true;
      }
    }

    return false;
  }

  void addDoneSurvey(String surveyName) {
    if (!doneSurveys.contains(surveyName)) {
      doneSurveys.add(surveyName);
      hive.put("doneSurveys", doneSurveys);
      notifyListeners();
    }
  }

  void setExerciseDone(Exercise exercise) {
    // Trova la chiave (data) che contiene quell’istanza di Exercise
    String? foundKey;
    for (final entry in weeklyExercises.entries) {
      if (entry.value.contains(exercise)) {
        foundKey = entry.key;
        break;
      }
    }
    if (foundKey == null) return; // non trovato, esci

    // Marca done
    exercise.setDone();

    // Persiste l’intera mappa aggiornata
    hive.put("weeklyExercises", weeklyExercises);

    // Notifica i listener per far rebuildare la UI
    notifyListeners();
  }

  bool isReadyForWeek6() {
    int done = 0;

    for (String survey in doneSurveys) {
      if (survey.contains("week5")) done++;
    }

    return done == 2;
  }

  void setDailyDone(DailyScreening ds) {
    ds.setDone();
    hive.put("dailyScreenings", dailyScreenings);
    notifyListeners();
  }

  void setWeeklyDone(WeeklyScreening ws) {
    ws.setDone();
    hive.put("weeklyScreenings", weeklyScreenings);
    notifyListeners();
  }
}
