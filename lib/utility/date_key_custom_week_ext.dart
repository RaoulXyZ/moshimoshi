// extension DateKeyCustomWeekExt<T> on Map<String, List<T>> {
//   MapEntry<String, List<T>>? firstListWeek({
//     required DateTime start,
//     DateTime? today,
//   }) {
//     final s = DateTime(start.year, start.month, start.day);
//     final now = today ?? DateTime.now();
//     final date = DateTime(now.year, now.month, now.day);

//     // se today è prima di start -> niente
//     final diffDays = date.difference(s).inDays;
//     if (diffDays < 0) return null;

//     // indice del blocco di 7 giorni contenente today
//     final weekIndex = diffDays ~/ 7;
//     final weekStart = s.add(Duration(days: weekIndex * 7));
//     final weekEnd = weekStart.add(const Duration(days: 6));

//     DateTime? earliest;
//     String? earliestKey;
//     List<T>? earliestValue;

//     for (final e in entries) {
//       final parsed = DateTime.tryParse(e.key);
//       if (parsed == null) continue; // ignora chiavi non-parsabili
//       final k = DateTime(parsed.year, parsed.month, parsed.day);
//       // controlla inclusività su entrambe le estremità
//       if (k.isBefore(weekStart) || k.isAfter(weekEnd)) continue;
//       if (earliest == null || k.isBefore(earliest)) {
//         earliest = k;
//         earliestKey = e.key;
//         earliestValue = e.value;
//       }
//     }

//     return earliestKey == null ? null : MapEntry(earliestKey, earliestValue!);
//   }
// }

extension DateKeyCustomWeekExt<T> on Map<String, List<T>> {
  MapEntry<String, List<T>>? firstListWeek({
    required DateTime start,
    DateTime? today,
  }) {
    // normalizziamo tutto in UTC (solo date, senza orario)
    final s = DateTime.utc(start.year, start.month, start.day);
    final now = today ?? DateTime.now();
    final date = DateTime.utc(now.year, now.month, now.day);

    // se today è prima di start -> niente
    final diffDays = date.difference(s).inDays;
    if (diffDays < 0) return null;

    // indice del blocco di 7 giorni contenente today
    final weekIndex = diffDays ~/ 7;
    final weekStart = s.add(Duration(days: weekIndex * 7));
    final weekEnd = weekStart.add(const Duration(days: 6));

    DateTime? earliest;
    String? earliestKey;
    List<T>? earliestValue;

    for (final e in entries) {
      final parsed = DateTime.tryParse(e.key);
      if (parsed == null) continue; // ignora chiavi non-parsabili

      // normalizziamo la chiave anche in UTC (solo data)
      final k = DateTime.utc(parsed.year, parsed.month, parsed.day);

      // controlla inclusività su entrambe le estremità
      if (k.isBefore(weekStart) || k.isAfter(weekEnd)) continue;
      if (earliest == null || k.isBefore(earliest)) {
        earliest = k;
        earliestKey = e.key;
        earliestValue = e.value;
      }
    }

    return earliestKey == null ? null : MapEntry(earliestKey, earliestValue!);
  }
}
