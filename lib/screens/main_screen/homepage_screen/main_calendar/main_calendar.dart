import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../providers/calendar.dart';
import '../../../../providers/progress.dart';
import '../../../../utility.dart';
import '../../../../utility/mindblooming_text_style.dart';
import './week_calendar.dart';

class MainCalendar extends StatelessWidget {
  const MainCalendar({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final pp = Provider.of<Progress>(context);
    final cp = Provider.of<Calendar>(context);
    final day = (daysDiff(cp.focusedDay, pp.start) % 7) + 1;
    final week = (daysDiff(cp.focusedDay, pp.start) / 7).floor() + 1;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
          child: Text(
            week == 1
                ? "Settimana introduttiva, giorno $day"
                : "Settimana ${week - 1}, giorno $day",
            style: MindBloomingTextStyle.header3,
          ),
        ),
        // const SizedBox(height: 20),
        const WeekCalendar(),
      ],
    );
  }
}
