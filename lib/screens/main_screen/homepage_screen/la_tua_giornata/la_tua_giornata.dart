import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../../models/daily_screening.dart';
import '../../../../providers/moduli.dart';
import '../../../../providers/questions.dart';
import '../../../../utility/compute_progress.dart';
import '../../../../utility/mindblooming_text_style.dart';
import '../../../../providers/calendar.dart';
import '../../../../providers/progress.dart';
import '../../../../providers/user_settings.dart';
import '../../../../utility/mindblooming_color_scheme.dart';
import '../../../questions_screen/questions_screen.dart';

class LaTuaGiornata extends StatelessWidget {
  const LaTuaGiornata({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final pp = Provider.of<Progress>(context);
    final cp = Provider.of<Calendar>(context);
    final debug = Provider.of<UserSettings>(context).debug;

    final day = cp.focusedDay;
    final String key = DateFormat('yyyy-MM-dd').format(day);

    final List<DailyScreening> dailyScreening = pp.dailyScreenings[key] ?? [];

    DateTime? lastDailyDate;
    if (pp.dailyScreenings.keys.isNotEmpty) {
      // take the last key when sorted by date
      final sortedKeys = pp.dailyScreenings.keys
          .map(DateTime.tryParse)
          .where((d) => d != null)
          .map((d) => DateTime(d!.year, d.month, d.day))
          .toList()
        ..sort();
      if (sortedKeys.isNotEmpty) lastDailyDate = sortedKeys.last;
    }

    final bool beyondLastDaily = lastDailyDate != null
        ? DateTime(day.year, day.month, day.day).isAfter(lastDailyDate)
        : false;

    // If we're beyond the last available daily, show a simple finished message
    if (beyondLastDaily) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 30),
        decoration: BoxDecoration(
          color: MindBloomingColorScheme.primary1shadow,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: MindBloomingColorScheme.primary3shadow,
            width: 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 25),
          child: Row(
            children: [
              const SizedBox(width: 20),
              Expanded(
                child: Text(
                  "Hai terminato tutte le domande giornaliere previste per il tuo percorso!",
                  style: MindBloomingTextStyle.normal,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Text(
            "Domande giornaliere",
            style: MindBloomingTextStyle.header3,
          ),
        ),
        const SizedBox(height: 10),
        if (dailyScreening.isNotEmpty) ...[
          for (DailyScreening ds in dailyScreening) ...[
            DailyIndicator(ds: ds),
            if (dailyScreening.last != ds) const SizedBox(height: 10),
          ],
        ] else
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 30),
            decoration: BoxDecoration(
              color: MindBloomingColorScheme.primary1shadow,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: MindBloomingColorScheme.primary3shadow,
                width: 1,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 25),
              child: Row(
                children: [
                  const SizedBox(width: 20),
                  Expanded(
                    child: Text(
                      "Disponibile dal ${pp.dailyScreenings.keys.first}${debug ? "\n${pp.dailyScreenings.values.first.first.surveyName}" : ""}",
                      style: MindBloomingTextStyle.normal,
                    ),
                  ),
                  SvgPicture.asset("assets/icon_locked.svg"),
                  const SizedBox(width: 20),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class DailyIndicator extends StatelessWidget {
  const DailyIndicator({
    super.key,
    required this.ds,
  });

  final DailyScreening ds;

  @override
  Widget build(BuildContext context) {
    final qP = Provider.of<Questions>(context);
    // final ap = Provider.of<Answers>(context);
    final mp = Provider.of<Moduli>(context);
    final cp = Provider.of<Calendar>(context);
    final debug = Provider.of<UserSettings>(context).debug;

    // final String surveyID = qP.surveyID(ds.surveyName);

    // previous-day checks removed: not needed for this UI

    final String displayModulo = mp.prettyName[ds.modulo] ?? ds.modulo;

    final progress = computeProgress(
      context,
      ds.surveyName,
      qP.blocks(ds.surveyName),
    );
    final ansVisible = progress.answered;
    final totVisible = progress.total;
    final percent = totVisible == 0 ? 0.0 : ansVisible / totVisible;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 30),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: ds.done
            ? MindBloomingColorScheme.primary1shadow
            : MindBloomingColorScheme.tertiary1shadow,
        border: Border.all(
          color: ds.done
              ? MindBloomingColorScheme.primary3shadow
              : MindBloomingColorScheme.tertiary,
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          // confronta solo il giorno (ora inclusa causava problemi): usa isSameDay
          onTap: (ds.done ||
                  (!debug && (!isSameDay(cp.focusedDay, DateTime.now()))))
              ? null
              : () => _onTap(context),
          splashColor: ds.done
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
                        if (!ds.done)
                          SvgPicture.asset(
                            "assets/icon_current.svg",
                            width: 20,
                            height: 20,
                          ),
                        const SizedBox(width: 10),
                        Text(
                          "$displayModulo${debug ? "\n${ds.surveyName}\n$ansVisible/$totVisible" : ""}",
                          style: MindBloomingTextStyle.normal,
                        ),
                      ],
                    ),
                    if (ds.done) const SizedBox(height: 15),
                    if (!ds.done)
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
                              color: ds.done
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
                  // disabilita anche il tasto circolare quando non è tappabile.
                  // In debug saltiamo il vincolo "solo oggi" così da poter
                  // rispondere subito a qualsiasi giornaliero, come la card sopra.
                  onTap: (ds.done ||
                          (!debug &&
                              (!isSameDay(cp.focusedDay, DateTime.now()))))
                      ? null
                      : () => _onTap(context),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 12,
                    ),
                    child: ds.done
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

  void _onTap(BuildContext context) {
    final pp = Provider.of<Progress>(context, listen: false);

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => QuestionsScreen(
          onDone: (surveyName, blockName, ctx) {
            pp.setDailyDone(ds);
            pp.addDoneBlock(
              ds.surveyName,
              ds.blockName,
            );
          },
          surveyName: ds.surveyName,
          blockName: ds.blockName,
          buttonText: "Torna alla Home",
          title: ds.modulo,
          subtitle: "",
        ),
      ),
    );
  }
}
