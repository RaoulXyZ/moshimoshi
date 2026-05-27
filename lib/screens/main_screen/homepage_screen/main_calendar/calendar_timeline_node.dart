import 'package:basics/basics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:timelines_plus/timelines_plus.dart';

import '../../../../providers/progress.dart';
import '../../../../providers/user_settings.dart';
import '../../../../utility/date_key_custom_week_ext.dart';
import '../../../../utility/mindblooming_color_scheme.dart';

class CalendarTimelineNode extends StatelessWidget {
  const CalendarTimelineNode({
    super.key,
    required this.day,
  });

  final DateTime day;

  @override
  Widget build(BuildContext context) {
    final pp = Provider.of<Progress>(context);
    final debug = Provider.of<UserSettings>(context).debug;

    // helpers
    DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

    final DateTime dayDate = _dateOnly(day);

    // timeline window (start .. start + 174 days)
    final DateTime timelineStart = _dateOnly(pp.start);
    final DateTime timelineEnd = _dateOnly(pp.start.addCalendarDays(174));

    final bool first = isSameDay(dayDate, timelineStart);
    final bool last = isSameDay(dayDate, timelineEnd);

    final DateTime now = DateTime.now();

    final size = MediaQuery.of(context).size;
    final bool isDesktop = size.width > 600;
    final double iconSize = isDesktop ? 20.0 : 16.0;
    final double connectorWidth = isDesktop ? 8.w : 5.w;

    // assessment anchor days (relative to pp.start)
    final DateTime a1 = _dateOnly(pp.start.addCalendarDays(56));
    final DateTime a2 = _dateOnly(pp.start.addCalendarDays(84));
    final DateTime a3 = _dateOnly(pp.start.addCalendarDays(168));

    bool _inAssessmentWindow(DateTime d) {
      final DateTime dd = _dateOnly(d);
      bool inWindow(DateTime startDay) {
        final endDay = startDay.add(const Duration(days: 6));

        return !dd.isBefore(startDay) && !dd.isAfter(endDay);
      }

      return inWindow(a1) || inWindow(a2) || inWindow(a3);
    }

    // helper: locked check
    bool _isLockedFor(DateTime d) => d.isAfter(now);

    // helper: connector color based on completion/lock
    Color _connectorColor({
      required bool fromDone,
      required bool toDone,
      required bool toLocked,
    }) {
      if (toLocked) return MindBloomingColorScheme.primary2shadow;
      if (fromDone && toDone) return MindBloomingColorScheme.secondary2shadow;

      return MindBloomingColorScheme.tertiary2shadow;
    }

    // helper: determine if all relevant items for the day are done
    bool _isDoneFor(DateTime d) {
      final key = DateFormat('yyyy-MM-dd').format(d);
      final dlist = pp.dailyScreenings[key] ?? [];
      final dDone = dlist.isNotEmpty ? dlist.first.done : true;

      final aList =
          pp.weeklyExercises[key]?.where((ex) => ex.assessment).toList() ?? [];
      final aDone = aList.isEmpty ? true : aList.every((ex) => ex.done);

      final w = pp.weeklyScreenings.firstListWeek(start: pp.start, today: d);
      final w1 =
          w == null ? true : (w.value.isNotEmpty ? w.value[0].done : true);
      final w2 =
          w == null ? true : (w.value.length > 1 ? w.value[1].done : true);

      return dDone && aDone && w1 && w2;
    }

    // keys & raw data for this date
    final String dayKey = DateFormat('yyyy-MM-dd').format(dayDate);
    final daily = pp.dailyScreenings[dayKey] ?? [];
    final bool hasDaily = daily.isNotEmpty;
    final bool dailyDone = hasDaily ? (daily.first.done) : false;

    final assessmentExercises =
        pp.weeklyExercises[dayKey]?.where((ex) => ex.assessment).toList() ?? [];
    final bool hasAssessmentExercises = assessmentExercises.isNotEmpty;
    final bool assessmentAllDone = hasAssessmentExercises
        ? assessmentExercises.every((e) => e.done)
        : false;

    // If the day is inside an assessment window, reuse `firstListWeek` on
    // `weeklyExercises` to find the anchor entry for that week and use its
    // assessment exercises to compute the window status.
    final assessmentEntry =
        pp.weeklyExercises.firstListWeek(start: pp.start, today: dayDate);
    final anchorAssessmentExercises = assessmentEntry != null
        ? assessmentEntry.value.where((ex) => ex.assessment).toList()
        : <dynamic>[];
    final bool assessmentWindowAllDone = anchorAssessmentExercises.isNotEmpty
        ? anchorAssessmentExercises.every((e) => e.done)
        : false;

    // Effective assessment status: prefer anchor-window status when inside assessment window
    final bool effectiveAssessmentDone =
        assessmentEntry != null ? assessmentWindowAllDone : assessmentAllDone;

    final weeklyObj =
        pp.weeklyScreenings.firstListWeek(start: pp.start, today: dayDate);
    final bool hasWeekly = weeklyObj != null && weeklyObj.value.isNotEmpty;

    // safer weekly checks: handle case where value may contain 1 or 2 elements
    int weeklyTotal = 0;
    int weeklyDoneCount = 0;
    if (weeklyObj != null) {
      weeklyTotal = weeklyObj.value.length;
      weeklyDoneCount = weeklyObj.value.where((v) => v.done).length;
    }
    final bool weeklyAllDone =
        weeklyTotal > 0 && weeklyDoneCount == weeklyTotal;
    final bool weeklyAnyDone = weeklyTotal > 0 && weeklyDoneCount > 0;

    final bool hasExerciseWindow =
        pp.weeklyExercises.firstListWeek(start: pp.start, today: dayDate) !=
            null;
    final bool isAssessment = _inAssessmentWindow(dayDate);

    final bool hasActivity = hasDaily ||
        hasWeekly ||
        hasExerciseWindow ||
        isAssessment ||
        hasAssessmentExercises;

    // ICONS: constants (change once if asset names differ)
    const String ICON_CURRENT = 'assets/icon_current.svg';
    const String ICON_LOCKED = 'assets/icon_locked.svg';
    const String ICON_DONE = 'assets/icon_done.svg';
    const String ICON_DOUBLE = 'assets/icon_double_check.svg';

    String pic = ICON_CURRENT; // default

    // Treat locked days only when not in debug. In DEBUG mode we still want to
    // compute the correct icons (done/double/current) when activities are present.
    if (_isLockedFor(dayDate) && !debug) {
      // Normal use & future day: locked (only when NOT in debug)
      pic = ICON_LOCKED;
    } else {
      // Normal use (or debug mode): compute icons normally (debug no longer forces icon_current)

      // If there's a daily and it's done -> show DONE (unless weekly also present and all done -> DOUBLE)
      if (hasDaily) {
        if (hasWeekly) {
          // Cases when both daily and weekly exist:
          // - if daily && all weekly done -> double
          // - if all weekly done but daily NOT done -> show progress (current)
          // - otherwise: if daily done OR some weekly done -> done
          if (dailyDone && weeklyAllDone) {
            pic = ICON_DOUBLE;
          } else if (weeklyAllDone && !dailyDone) {
            // weekly fully completed but today's daily not done -> show progress
            pic = ICON_CURRENT;
          } else if (dailyDone || weeklyAnyDone) {
            // daily done OR at least one weekly done -> done
            pic = ICON_DONE;
          } else {
            pic = ICON_CURRENT;
          }
        } else {
          // only daily present
          pic = dailyDone ? ICON_DONE : ICON_CURRENT;
        }
      }
      // No daily but weekly exists
      else if (hasWeekly) {
        if (weeklyAllDone) {
          pic = ICON_DOUBLE;
        } else if (weeklyAnyDone) {
          pic = ICON_DONE;
        } else {
          pic = ICON_CURRENT;
        }
      }
      // Only assessment exercises assigned to this date
      else if (hasAssessmentExercises) {
        pic = assessmentAllDone ? ICON_DONE : ICON_CURRENT;
      } else if (isAssessment) {
        // assessment window (no explicit exercise objects present)
        pic = assessmentWindowAllDone ? ICON_DONE : ICON_CURRENT;
      } else {
        pic = ICON_CURRENT;
      }
    }

    // adjacent states for connectors
    final prevDay = dayDate.subtract(const Duration(days: 1));
    final nextDay = dayDate.add(const Duration(days: 1));

    final prevDone = _isDoneFor(prevDay);
    final nextDone = _isDoneFor(nextDay);
    final nextLocked = _isLockedFor(nextDay);

    // adjacency detail checks removed; connectors are unconditional

    // prev/next activity detail checks removed; connectors drawn unconditionally

    // build indicator
    final Widget indicatorContent = Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2.5),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (hasActivity)
            SvgPicture.asset(
              pic,
              width: iconSize,
              height: iconSize,
            )
          else
            SvgPicture.asset(
              'assets/relax.svg',
              width: iconSize,
              height: iconSize,
            ),
          const SizedBox(height: 4),
          Text(
            DateFormat('dd-MM-yyyy').format(dayDate),
            style: TextStyle(
              fontSize: isDesktop ? 10.0 : 8.0,
              color: MindBloomingColorScheme.primary3shadow,
            ),
          ),
          if (debug) ...[
            Column(
              children: [
                Text(
                  'daily: ${dailyDone ? '✓' : '✗'}  weekly: ${weeklyAllDone ? '✓' : (weeklyAnyDone ? '~' : '✗')} assessment: ${effectiveAssessmentDone ? '✓' : (assessmentEntry != null ? '✗' : (hasAssessmentExercises ? '✗' : '-'))}',
                  style: TextStyle(
                    fontSize: isDesktop ? 9.0 : 7.0,
                    color: MindBloomingColorScheme.primary3shadow,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );

    if (!dayDate.isBefore(timelineStart) && !dayDate.isAfter(timelineEnd)) {
      return SizedBox(
        height: 64,
        child: TimelineTile(
          direction: Axis.horizontal,
          node: TimelineNode(
            indicator: indicatorContent,
            startConnector: (!first)
                ? SizedBox(
                    width: connectorWidth,
                    child: DashedLineConnector(
                      direction: Axis.horizontal,
                      dash: 5,
                      gap: 1,
                      color: _connectorColor(
                        fromDone: prevDone,
                        toDone: _isDoneFor(dayDate),
                        toLocked: _isLockedFor(dayDate),
                      ),
                    ),
                  )
                : null,
            endConnector: (!last)
                ? SizedBox(
                    width: connectorWidth,
                    child: DashedLineConnector(
                      direction: Axis.horizontal,
                      dash: 5,
                      gap: 1,
                      color: _connectorColor(
                        fromDone: _isDoneFor(dayDate),
                        toDone: nextDone,
                        toLocked: nextLocked,
                      ),
                    ),
                  )
                : null,
          ),
        ),
      );
    }

    return const SizedBox();
  }
}
