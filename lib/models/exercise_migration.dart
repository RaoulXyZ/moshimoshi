import 'package:hive/hive.dart';

import 'exercise.dart';

Future<void> migrateWeeklyExercises(Box box, String key) async {
  try {
    if (!box.containsKey(key)) return;

    final dynamic raw = box.get(key);
    if (raw == null) return;

    // ci aspettiamo una Map<String, List<Exercise>> ma Hive può restituire tipi dinamici
    if (raw is! Map) return;

    final Map<String, dynamic> map = Map<String, dynamic>.from(raw);
    bool changed = false;

    final Map<String, List<Exercise>> migrated = {};

    for (final entry in map.entries) {
      final dateKey = entry.key;
      final dynamic value = entry.value;

      if (value is List) {
        final List<Exercise> newList = [];
        for (final item in value) {
          if (item is Exercise) {
            // assicurati che assessment/tappa abbiano valori coerenti
            bool assessment = item.assessment;
            String? tappa = item.tappa;

            if (!assessment && item.modulo == 'baseline_assessment') {
              // se modulo baseline ma assessment false -> prova a inferire dalla surveyName
              final name = item.surveyName.toLowerCase();
              if (name.contains('_8')) {
                assessment = true;
                tappa = 'first';
              } else if (name.contains('_12')) {
                assessment = true;
                tappa = 'second';
              } else if (name.contains('_24')) {
                assessment = true;
                tappa = 'third';
              }
            }

            // crea nuova istanza per normalizzare eventuali default
            final fixed = Exercise(
              surveyName: item.surveyName,
              modulo: item.modulo,
              done: item.done,
              assessment: assessment,
              tappa: tappa,
            );

            // verifica se c'è differenza per decidere di salvare poi
            if (fixed.assessment != item.assessment ||
                fixed.tappa != item.tappa) {
              changed = true;
            }

            newList.add(fixed);
          } else {
            // elemento non è Exercise (vecchio formato?) -> ignoralo o converti se necessario
          }
        }
        migrated[dateKey] = newList;
      } else {
        // valore non è una lista -> lo saltiamo
      }
    }

    if (changed) {
      await box.put(key, migrated);
    }
  } catch (e, st) {
    // logga ma non crashare
    // usa print/log a seconda del setup
    print('Errore migration weeklyExercises: $e\n$st');
  }
}
