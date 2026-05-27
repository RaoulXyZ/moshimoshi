import 'package:basics/basics.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../../../providers/calendar.dart';
import '../../../../providers/progress.dart';
import '../../../../providers/user_settings.dart';
import '../../../../utility/mindblooming_color_scheme.dart';
import '../../../../utility/mindblooming_text_style.dart';
import './calendar_timeline_node.dart';

class WeekCalendar extends StatefulWidget {
  const WeekCalendar({
    super.key,
  });

  @override
  State<WeekCalendar> createState() => _WeekCalendarState();
}

class _WeekCalendarState extends State<WeekCalendar> {
  @override
  void initState() {
    super.initState();
    final cProvider = Provider.of<Calendar>(context, listen: false);
    cProvider.setFocusedDay(DateTime.now(), notify: false);
  }

  @override
  Widget build(BuildContext context) {
    final pProvider = Provider.of<Progress>(context);
    final cProvider = Provider.of<Calendar>(context);
    final debug = Provider.of<UserSettings>(context).debug;

    return TableCalendar(
      focusedDay: cProvider.focusedDay,
      selectedDayPredicate: (day) => isSameDay(day, cProvider.focusedDay),
      firstDay: pProvider.start,
      lastDay: pProvider.start.addCalendarDays(175),
      availableCalendarFormats: const {
        CalendarFormat.week: 'Week',
      },
      calendarFormat: CalendarFormat.week,
      headerVisible: false,
      rowHeight: 220,
      calendarStyle: CalendarStyle(
        selectedDecoration: const BoxDecoration(
          color: MindBloomingColorScheme.secondary4shadow,
        ),
        todayDecoration: const BoxDecoration(
          color: MindBloomingColorScheme.secondary4shadow,
          shape: BoxShape.circle,
        ),
        defaultTextStyle: MindBloomingTextStyle.subtitle,
        holidayTextStyle: MindBloomingTextStyle.subtitle,
        outsideTextStyle: MindBloomingTextStyle.subtitle,
        weekendTextStyle: MindBloomingTextStyle.subtitle,
      ),
      onDaySelected: (selectedDay, focusedDay) {
        // Se debug è attivo permetti la selezione di giorni futuri, altrimenti solo oggi o passato
        if (debug ||
            selectedDay.isBefore(DateTime.now()) ||
            isSameDay(selectedDay, DateTime.now())) {
          cProvider.setFocusedDay(selectedDay);
        }
      },
      calendarBuilders: CalendarBuilders(
        dowBuilder: (context, day) {
          final text = DateFormat.E().format(day);

          return Center(
            child: Text(
              overflow: TextOverflow.visible,
              text.toUpperCase().substring(0, 1),
              style: MindBloomingTextStyle.calendarText2,
            ),
          );
        },
        todayBuilder: (context, day, focusedDay) {
          return Column(
            children: [
              const SizedBox(height: 15),
              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: MindBloomingColorScheme.secondary2shadow,
                ),
                child: Center(
                  child: Text(
                    day.day.toString(),
                    style: MindBloomingTextStyle.calendarText.copyWith(
                      color: MindBloomingColorScheme.primary,
                    ),
                  ),
                ),
              ),
              CalendarTimelineNode(day: day),
            ],
          );
        },
        selectedBuilder: (context, day, focusedDay) {
          return Column(
            children: [
              const SizedBox(height: 15),
              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: MindBloomingColorScheme.secondary4shadow,
                ),
                child: Center(
                  child: Text(
                    day.day.toString(),
                    style: MindBloomingTextStyle.calendarText.copyWith(
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              CalendarTimelineNode(day: day),
            ],
          );
        },
        defaultBuilder: (context, day, focusedDay) {
          return Column(
            children: [
              const SizedBox(height: 15),
              SizedBox(
                width: 40,
                height: 40,
                child: Center(
                  child: Text(
                    day.day.toString(),
                    style: MindBloomingTextStyle.calendarText,
                  ),
                ),
              ),
              CalendarTimelineNode(day: day),
            ],
          );
        },
        outsideBuilder: (context, day, focusedDay) {
          return Column(
            children: [
              const SizedBox(height: 15),
              SizedBox(
                width: 40,
                height: 40,
                child: Center(
                  child: Text(
                    day.day.toString(),
                    style: MindBloomingTextStyle.calendarText,
                  ),
                ),
              ),
              CalendarTimelineNode(day: day),
            ],
          );
        },
        disabledBuilder: (context, day, focusedDay) {
          return Column(
            children: [
              const SizedBox(height: 15),
              SizedBox(
                width: 40,
                height: 40,
                child: Center(
                  child: Text(
                    day.day.toString(),
                    style: MindBloomingTextStyle.calendarText,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
