import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

import '../../../../providers/calendar.dart';
import '../../../../providers/progress.dart';
import '../../../../providers/user_settings.dart';
import '../../../../utility.dart';
import '../../../../utility/mindblooming_text_style.dart';
import '../../../../utility/mindblooming_color_scheme.dart';

class AlertEserciziSettimanali extends StatelessWidget {
  const AlertEserciziSettimanali({
    super.key,
    required this.toExercises,
  });

  final void Function() toExercises;

  @override
  Widget build(BuildContext context) {
    final cp = Provider.of<Calendar>(context);
    final pp = Provider.of<Progress>(context);
    final sp = Provider.of<UserSettings>(context);
    final week = (daysDiff(cp.focusedDay, pp.start) / 7).floor();
    final day = (daysDiff(cp.focusedDay, pp.start) % 7) + 1;
    final pindex = int.parse(sp.selectedPlant) + 1;

    bool done = false;
    final bool urgent = day >= 5;
    final ex = week >= 0 && week < pp.weeklyExercises.values.length
        ? pp.weeklyExercises.values.elementAt(week)
        : [];

    if (ex.isNotEmpty && ex.first.done && ex.last.done) {
      done = true;
    }
    // final bool undone = pp.undoneEx(week);

    final text = done
        ? "Complimenti! Hai completato tutte le attività di questa settimana!"
        : "Hai ancora delle attività da completare!";

    return week > 6
        ? const SizedBox.shrink()
        : Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Attività settimanali",
                  style: MindBloomingTextStyle.header3,
                ),
                const SizedBox(height: 20),
                Container(
                  height: 160,
                  decoration: BoxDecoration(
                    color: done
                        ? MindBloomingColorScheme.secondary2shadow
                        : MindBloomingColorScheme.tertiary2shadow,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: done
                          ? MindBloomingColorScheme.secondary4shadow
                          : MindBloomingColorScheme.tertiary,
                      width: 0.5,
                    ),
                  ),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(20),
                          bottomLeft: Radius.circular(20),
                        ),
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth: 25.w,
                          ),
                          child: SvgPicture.asset(
                            "assets/plant_$pindex.svg",
                            height: 16.w,
                            fit: BoxFit.cover,
                            alignment: Alignment.bottomRight,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(height: 16),
                            Padding(
                              padding: const EdgeInsets.only(right: 30),
                              child: Text(
                                text,
                                style: MindBloomingTextStyle.alertEsercizi,
                              ),
                            ),
                            if (done) const SizedBox(height: 16),
                            if (!done)
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(16),
                                      splashColor: done
                                          ? MindBloomingColorScheme
                                              .secondary4shadow
                                          : MindBloomingColorScheme
                                              .tertiary3shadow,
                                      highlightColor: Colors.transparent,
                                      onTap: toExercises,
                                      child: Padding(
                                        padding: const EdgeInsets.all(8),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              "Vai alle attività!",
                                              style: MindBloomingTextStyle
                                                  .alertEserciziButton,
                                            ),
                                            const SizedBox(width: 20),
                                            SvgPicture.asset(
                                              "assets/icon_right_arrow.svg",
                                            ),
                                            const SizedBox(width: 12),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
  }
}
