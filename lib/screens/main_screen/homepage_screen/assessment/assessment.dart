import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../../../models/exercise.dart';
import '../../../../providers/calendar.dart';
import '../../../../providers/moduli.dart';
import '../../../../providers/progress.dart';
import '../../../../providers/questions.dart';
import '../../../../providers/user_settings.dart';
import '../../../../utility/compute_progress.dart';
import '../../../../utility/date_key_custom_week_ext.dart';
import '../../../../utility/mindblooming_color_scheme.dart';
import '../../../../utility/mindblooming_text_style.dart';
import '../../../blocks_screen/blocks_screen.dart';

class Assessment extends StatelessWidget {
  const Assessment({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final pp = Provider.of<Progress>(context);
    final cp = Provider.of<Calendar>(context);

    final day = cp.focusedDay;
    // final String key = DateFormat('yyyy-MM-dd').format(day);

    final Map<String, List<Exercise>> screenings = Map.fromEntries(
      pp.weeklyExercises.entries
          .map(
            (e) => MapEntry(
              e.key,
              e.value.where((ex) => ex.assessment).toList(),
            ),
          )
          .where(
            (entry) => entry.value.isNotEmpty,
          ),
    );

    final exerciseEntry = screenings.firstListWeek(start: pp.start, today: day);
    final Exercise? screening = exerciseEntry?.value.first;

    // final Exercise? screening = screenings[key]?.first;

    // final screeningEntry =
    //     screenings.firstListWeek(start: pp.start, today: day);
    // final List<WeeklyScreening> weeklyScreening =
    //     weeklyEntry?.value ?? <WeeklyScreening>[];

    return screening == null
        ? const SizedBox.shrink()
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Text(
                  "Screening",
                  style: MindBloomingTextStyle.header3,
                ),
              ),
              const SizedBox(height: 10),
              ScreeningIndicator(
                screening: screening,
                tappa: screening.tappa! == "first"
                    ? "Primo screening"
                    : screening.tappa! == "second"
                        ? "Secondo screening"
                        : "Terzo screening",
              ),
            ],
          );
  }
}

class ScreeningIndicator extends StatelessWidget {
  const ScreeningIndicator({
    super.key,
    required this.tappa,
    required this.screening,
  });

  final String tappa;
  final Exercise screening;

  @override
  Widget build(BuildContext context) {
    final qP = Provider.of<Questions>(context);
    final mp = Provider.of<Moduli>(context);
    final cp = Provider.of<Calendar>(context);
    final debug = Provider.of<UserSettings>(context).debug;

    // final String surveyID = qP.surveyID(ds.surveyName);
    final String displayModulo =
        mp.prettyName[screening.modulo] ?? screening.modulo;

    final bool done = screening.done;
    final String surveyName = screening.surveyName;

    final progress = computeProgress(
      context,
      surveyName,
      qP.blocks(surveyName),
    );
    final ansVisible = progress.answered;
    final totVisible = progress.total;
    final percent = totVisible == 0 ? 0.0 : ansVisible / totVisible;
    // previous-day checks removed: not needed for this UI

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 30),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: done
            ? MindBloomingColorScheme.primary1shadow
            : MindBloomingColorScheme.tertiary1shadow,
        border: Border.all(
          color: done
              ? MindBloomingColorScheme.primary3shadow
              : MindBloomingColorScheme.tertiary,
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          // confronta solo il giorno (ora inclusa causava problemi): usa isSameDay
          onTap:
              (done || (!debug && (!isSameDay(cp.focusedDay, DateTime.now()))))
                  ? null
                  : () => {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => BlocksScreen(
                              exercise: screening,
                              tappa: tappa,
                            ),
                          ),
                        ),
                      },
          splashColor: done
              ? MindBloomingColorScheme.secondary4shadow
              : MindBloomingColorScheme.tertiary2shadow,
          borderRadius: BorderRadius.circular(20),
          highlightColor: Colors.transparent,
          child: Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    const SizedBox(height: 15),
                    Row(
                      children: [
                        const SizedBox(width: 20),
                        if (!done)
                          SvgPicture.asset(
                            "assets/icon_current.svg",
                            width: 20,
                            height: 20,
                          ),
                        const SizedBox(width: 10),
                        Text(
                          "$displayModulo${debug ? "\n${surveyName}\n$ansVisible/$totVisible" : ""}",
                          style: MindBloomingTextStyle.normal,
                        ),
                      ],
                    ),
                    if (done) const SizedBox(height: 15),
                    if (!done)
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 15,
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(50),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(50),
                              border: Border.all(
                                color: MindBloomingColorScheme.dialogBg,
                                width: 0.5,
                              ),
                            ),
                            child: LinearProgressIndicator(
                              value: percent,
                              color: done
                                  ? MindBloomingColorScheme.secondary
                                  : MindBloomingColorScheme.tertiary,
                              minHeight: 5,
                            ),
                          ),
                        ),
                      ),
                    // const SizedBox(height: 15),
                  ],
                ),
              ),
              Material(
                shape: const CircleBorder(),
                color: Colors.transparent,
                child: InkWell(
                  // In debug saltiamo il vincolo "solo oggi" per poter aprire
                  // subito lo screening, coerentemente con la card sopra.
                  onTap: (done ||
                          (!debug &&
                              (!isSameDay(cp.focusedDay, DateTime.now()))))
                      ? null
                      : () => {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => BlocksScreen(
                                  exercise: screening,
                                  tappa: tappa,
                                ),
                              ),
                            ),
                          },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 12,
                    ),
                    child: done
                        ? SvgPicture.asset("assets/icon_done.svg")
                        : SvgPicture.asset("assets/icon_right_arrow.svg"),
                  ),
                  borderRadius: BorderRadius.circular(200),
                  splashColor: MindBloomingColorScheme.tertiary2shadow,
                  highlightColor: Colors.transparent,
                ),
              ),
              const SizedBox(width: 8),
            ],
          ),
        ),
      ),
    );
  }
}
