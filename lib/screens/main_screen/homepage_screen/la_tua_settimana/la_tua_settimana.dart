import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../../models/weekly_screening.dart';
import '../../../../providers/moduli.dart';
import '../../../../providers/questions.dart';
import '../../../../providers/user_settings.dart';
import '../../../../utility/compute_progress.dart';
import '../../../../utility/date_key_custom_week_ext.dart';
import '../../../../utility/mindblooming_text_style.dart';
import '../../../../providers/calendar.dart';
import '../../../../providers/progress.dart';
import '../../../../utility/mindblooming_color_scheme.dart';
import '../../../questions_screen/questions_screen.dart';

class LaTuaSettimana extends StatelessWidget {
  const LaTuaSettimana({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final pp = Provider.of<Progress>(context);
    final cp = Provider.of<Calendar>(context);

    final day = cp.focusedDay;
    final keys = pp.weeklyScreenings.keys;

    final weeklyEntry =
        pp.weeklyScreenings.firstListWeek(start: pp.start, today: day);
    final List<WeeklyScreening> weeklyScreening =
        weeklyEntry?.value ?? <WeeklyScreening>[];

    // compute unlockDate from the weeklyEntry key if present
    // DateTime? unlockDate;
    // if (weeklyEntry?.key != null) {
    //   final parsed = DateTime.tryParse(weeklyEntry!.key);
    //   if (parsed != null) {
    //     // normalize to start of day
    //     unlockDate = DateTime(parsed.year, parsed.month, parsed.day);
    //   }
    // }

    // determine last available weekly date (week start + 6 days)
    DateTime? lastWeeklyEnd;
    if (keys.isNotEmpty) {
      final sortedWeekStarts = keys
          .map(DateTime.tryParse)
          .where((d) => d != null)
          .map((d) => DateTime(d!.year, d.month, d.day))
          .toList()
        ..sort();
      if (sortedWeekStarts.isNotEmpty) {
        final lastStart = sortedWeekStarts.last;
        lastWeeklyEnd = lastStart.add(const Duration(days: 6));
      }
    }

    final bool beyondLastWeekly = lastWeeklyEnd != null
        ? DateTime(day.year, day.month, day.day).isAfter(lastWeeklyEnd)
        : false;

    if (beyondLastWeekly) {
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
                  "Hai terminato tutte le domande settimanali previste per il tuo percorso!",
                  style: MindBloomingTextStyle.normal,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // debug flag read where needed via Provider in children if necessary
    final debug = Provider.of<UserSettings>(context).debug;

    // safe firstKey: try to take the key from the weeklyEntry (earliest in week)
    final String? firstKey =
        weeklyEntry?.key ?? (keys.isNotEmpty ? keys.first : null);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Text(
            "Domande settimanali",
            style: MindBloomingTextStyle.header3,
          ),
        ),
        const SizedBox(height: 10),
        if (weeklyScreening.isNotEmpty) ...[
          for (WeeklyScreening ws in weeklyScreening) ...[
            WeeklyIndicator(
              ws: ws,
              unlockDate: DateTime.parse(weeklyEntry!.key),
            ),
            if (weeklyScreening.last != ws) const SizedBox(height: 10),
          ],
        ] else
          // if we don't have an entry for the current week, show the (safe) fallback.
          // fallback: when week not matched, iterate the firstKey list and pass its parsed date
          for (var ws
              in pp.weeklyScreenings[firstKey] ?? <WeeklyScreening>[]) ...[
            Container(
              margin: const EdgeInsets.symmetric(
                horizontal: 30,
                vertical: 5,
              ),
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
                        "Disponibile dal ${DateFormat('dd-MM-yyyy').format(DateTime.parse(firstKey!))}${debug ? "\n${ws.surveyName}" : ""}",
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
      ],
    );
  }
}

class WeeklyIndicator extends StatelessWidget {
  const WeeklyIndicator({
    super.key,
    required this.ws,
    required this.unlockDate,
  });

  final WeeklyScreening ws;
  final DateTime unlockDate;

  @override
  Widget build(BuildContext context) {
    final qP = Provider.of<Questions>(context);
    // final ap = Provider.of<Answers>(context);
    final mp = Provider.of<Moduli>(context);
    final cp = Provider.of<Calendar>(context);
    final debug = Provider.of<UserSettings>(context).debug;
    // Rendi i valori nullable e gestiscili in modo sicuro
    // final String surveyID = qP.surveyID(ws.surveyName);

    // fallback per il nome del modulo nel caso non esista in prettyName
    final String displayModulo = mp.prettyName[ws.modulo] ?? ws.modulo;

    // int totVisible = 0;
    // int ansVisible = 0;

    // get blocks in a safe way (could be empty map)
    // final blocks = qP.blocks(ws.surveyName);

    // for (var blockEntry in blocks.entries) {
    //   final dynamic rawQuestions = blockEntry.value?['questions'];
    //   if (rawQuestions == null || rawQuestions is! Map) continue;
    //   final Map<String, dynamic> questionMap =
    //       Map<String, dynamic>.from(rawQuestions);

    //   final visibleKeys = questionMap.entries
    //       .where((e) =>
    //           !qP.isSkip(Map<String, dynamic>.from(e.value), context, surveyID))
    //       .map((e) => e.key)
    //       .toList();

    //   totVisible += visibleKeys.length;
    //   ansVisible += ap.getAnswerCountKeys(surveyID, visibleKeys);
    // }

    // final double percent =
    //     totVisible > 0 ? (ansVisible.toDouble() / totVisible.toDouble()) : 0.0;
    // final double percentClamped = percent.isFinite
    //     ? (percent < 0 ? 0.0 : (percent > 1 ? 1.0 : percent))
    //     : 0.0;

    final progress = computeProgress(
      context,
      ws.surveyName,
      qP.blocks(ws.surveyName),
    );
    final ansVisible = progress.answered;
    final totVisible = progress.total;
    final percent = totVisible == 0 ? 0.0 : ansVisible / totVisible;

    // --- LOGICA 48h basata sulla unlockDate derivata dalla chiave ---
    // final now = DateTime.now();
    final DateTime expireAt = unlockDate.add(const Duration(hours: 48));
    final bool isExpired = debug
        ? cp.focusedDay.isAfter(expireAt)
        : DateTime.now().isAfter(expireAt);

    // // final DateTime? normalizedUnlock = unlockDate != null
    // //     ? DateTime(unlockDate!.year, unlockDate!.month, unlockDate!.day)
    // //     : null;

    // final bool isExpired = normalizedUnlock != null &&
    //

    // tappable solo se non fatto, non scaduto e focusedDay è oggi
    final bool isTappable = !isExpired &&
        !ws.done; // && !isExpired && isSameDay(cp.focusedDay, DateTime.now());

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 30),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: ws.done
            ? MindBloomingColorScheme.primary1shadow
            : MindBloomingColorScheme.tertiary1shadow,
        border: Border.all(
          color: ws.done
              ? MindBloomingColorScheme.primary3shadow
              : MindBloomingColorScheme.tertiary,
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          // confronta solo il giorno (ora inclusa causava problemi): usa isSameDay
          onTap: isTappable ? () => _onTap(context) : null,
          splashColor: ws.done
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
                        if (!ws.done)
                          SvgPicture.asset(
                            "assets/icon_current.svg",
                            width: 20,
                            height: 20,
                          ),
                        const SizedBox(width: 10),
                        Text(
                          "$displayModulo${debug ? "\n${ws.surveyName}\n$ansVisible/$totVisible\nUNLOCK: ${unlockDate}\nEXPIRES AT: ${expireAt}\nIS EXPIRED: $isExpired" : ''}",
                          style: MindBloomingTextStyle.normal,
                        ),
                      ],
                    ),
                    if (ws.done) const SizedBox(height: 15),
                    if (!ws.done)
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
                              color: ws.done
                                  ? MindBloomingColorScheme.secondary
                                  : MindBloomingColorScheme.tertiary,
                              minHeight: 5,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              Material(
                shape: const CircleBorder(),
                color: Colors.transparent,
                child: InkWell(
                  // disabilita anche il tasto circolare quando non è tappabile
                  onTap: isTappable ? () => _onTap(context) : null,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 12,
                    ),
                    child: ws.done
                        ? SvgPicture.asset("assets/icon_done.svg")
                        : isExpired
                            ? SvgPicture.asset("assets/icon_locked.svg")
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
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => QuestionsScreen(
          onDone: (surveyName, blockName, ctx) {
            final pp = Provider.of<Progress>(context, listen: false);
            pp.setWeeklyDone(ws);
            pp.addDoneBlock(
              ws.surveyName,
              ws.blockName,
            );
          },
          surveyName: ws.surveyName,
          blockName: ws.blockName,
          buttonText: "Torna alla Home",
          title: ws.modulo,
          subtitle: "",
        ),
      ),
    );
  }
}
