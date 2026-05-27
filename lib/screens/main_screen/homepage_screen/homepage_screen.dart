import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../providers/calendar.dart';
import '../../../providers/progress.dart';
import '../../../utility.dart';
import './la_tua_settimana/la_tua_settimana.dart';
import './header.dart';
import './main_calendar/main_calendar.dart';
import './la_tua_giornata/la_tua_giornata.dart';
import './il_tuo_percorso.dart';
import './alert_esercizi_settimanali/alert_esercizi_settimanali.dart';
import 'assessment/assessment.dart';
import 'testimonianze.dart';

class HomepageScreen extends StatelessWidget {
  const HomepageScreen({
    super.key,
    required this.toExercises,
  });

  final void Function() toExercises;

  @override
  Widget build(BuildContext context) {
    final cp = Provider.of<Calendar>(context);
    final pp = Provider.of<Progress>(context);
    final day = (daysDiff(cp.focusedDay, pp.start) % 7) + 1;
    final week = (daysDiff(cp.focusedDay, pp.start) / 7).floor();
    bool done = false;

    final ex = week >= 0 && week < pp.weeklyExercises.values.length
        ? pp.weeklyExercises.values.elementAt(week)
        : [];
    if (ex.isNotEmpty && ex.first.done && ex.last.done) {
      done = true;
    }
    final bool urgent = ((day >= 5) && !done) || pp.undoneEx(week);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Header(),
          const SizedBox(height: 15),
          const MainCalendar(),
          const SizedBox(height: 15),
          const IlTuoPercorso(),
          const SizedBox(height: 15),
          if (urgent) ...[
            AlertEserciziSettimanali(toExercises: toExercises),
            const SizedBox(height: 15),
          ],
          const LaTuaGiornata(),
          const SizedBox(height: 15),
          const LaTuaSettimana(),
          const SizedBox(height: 15),
          const Assessment(),
          const SizedBox(height: 15),
          if (!urgent) ...[
            AlertEserciziSettimanali(toExercises: toExercises),
            const SizedBox(height: 20),
          ],
          const SizedBox(height: 15),
          const Testimonianze(),
          const SizedBox(height: 15),
        ],
      ),
    );
  }
}
