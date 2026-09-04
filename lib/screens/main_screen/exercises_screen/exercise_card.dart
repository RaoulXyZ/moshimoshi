import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get_utils/src/platform/platform.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

import '../../../models/exercise.dart';
import '../../../providers/moduli.dart';
import '../../../providers/questions.dart';
import '../../../providers/user_settings.dart';
import '../../../utility/compute_progress.dart';
import '../../../utility/mindblooming_color_scheme.dart';
import '../../../utility/mindblooming_text_style.dart';
import '../../blocks_screen/blocks_screen.dart';

class ExerciseCard extends StatelessWidget {
  const ExerciseCard({
    super.key,
    required this.exercise,
    required this.date,
    required this.tappa,
  });

  final Exercise exercise;
  final String date;
  final String tappa;

  @override
  Widget build(BuildContext context) {
    final mp = Provider.of<Moduli>(context);
    final qp = Provider.of<Questions>(context);

    final userSettings = Provider.of<UserSettings>(context);
    final debug = userSettings.debug;
    final bool isFavorite = userSettings.isFavorite(exercise.surveyName);

    final String displayModulo =
        mp.prettyName[exercise.modulo] ?? exercise.modulo;

    final progress = computeProgress(
      context,
      exercise.surveyName,
      qp.blocks(exercise.surveyName),
    );
    final ansVisible = progress.answered;
    final totVisible = progress.total;
    final percent = totVisible > 0 ? ansVisible / totVisible : 1.0;

    // final isScreening = tappa.contains('screening');
    final DateTime dateTime = DateTime.parse(date);
    final bool unlocked = DateTime.now().isAfter(dateTime);
    // final bool unlocked = isScreening
    //     ? dateTime.isBefore(DateTime.now())
    //     : dateTime.isBefore(
    //         DateTime.now().addCalendarDays(7),
    //       );

    return (unlocked || debug)
        ? Container(
            margin: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
            decoration: BoxDecoration(
              color: exercise.done
                  ? MindBloomingColorScheme.secondary2shadow
                  : MindBloomingColorScheme.tertiary1shadow,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: exercise.done
                    ? MindBloomingColorScheme.secondary
                    : MindBloomingColorScheme.tertiary,
                width: 0.5,
              ),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => _onTap(
                  context,
                  exercise,
                  tappa,
                ),
                borderRadius: BorderRadius.circular(20),
                highlightColor: Colors.transparent,
                splashColor: exercise.done
                    ? MindBloomingColorScheme.secondary
                    : MindBloomingColorScheme.tertiary,
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: SizedBox(
                        width: 100,
                        height: 110,
                        child: Stack(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: exercise.done
                                    ? MindBloomingColorScheme.secondary4shadow
                                    : MindBloomingColorScheme.tertiary2shadow,
                                borderRadius: const BorderRadius.only(
                                  topRight: Radius.elliptical(75, 100),
                                  bottomRight: Radius.elliptical(75, 100),
                                ),
                              ),
                            ),
                            Align(
                              alignment: Alignment.bottomCenter,
                              child: SvgPicture.asset(
                                "assets/cards/${exercise.modulo}.svg",
                                fit: BoxFit.fitHeight,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 40),
                    Expanded(
                      child: Column(
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(top: 3),
                                child: Align(
                                  alignment: Alignment.center,
                                  child: SvgPicture.asset(
                                    exercise.done
                                        ? "assets/icon_done.svg"
                                        : "assets/icon_current.svg",
                                  ),
                                ),
                              ),
                              const SizedBox(width: 5),
                              Expanded(
                                child: Text(
                                  "$displayModulo${debug ? "\nDate: ${date}\n${exercise.surveyName}\n$ansVisible/$totVisible" : ""}",
                                  style:
                                      MindBloomingTextStyle.subtitle.copyWith(
                                    fontSize: GetPlatform.isMobile
                                        ? 10.sp
                                        : (GetPlatform.isDesktop
                                            ? 5.8.sp
                                            : 8.5.sp),
                                  ),
                                ),
                              ),
                              Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () => userSettings.toggleFavorite(
                                    exercise.surveyName,
                                  ),
                                  highlightColor: Colors.transparent,
                                  splashColor: MindBloomingColorScheme.tertiary,
                                  borderRadius: BorderRadius.circular(20),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 5,
                                    ),
                                    child: Icon(
                                      isFavorite
                                          ? Icons.favorite
                                          : Icons.favorite_border,
                                      size: 20,
                                      color: isFavorite
                                          ? MindBloomingColorScheme.secondary
                                          : MindBloomingColorScheme
                                              .textColorDark1shadow,
                                    ),
                                  ),
                                ),
                              ),
                              Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () => _onTap(
                                    context,
                                    exercise,
                                    tappa,
                                  ),
                                  highlightColor: Colors.transparent,
                                  splashColor: exercise.done
                                      ? MindBloomingColorScheme.secondary
                                      : const Color.fromARGB(255, 172, 122, 69),
                                  borderRadius: BorderRadius.circular(20),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 5,
                                    ),
                                    child: Align(
                                      alignment: Alignment.center,
                                      child: SvgPicture.asset(
                                        "assets/icon_right_arrow.svg",
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 5),
                            ],
                          ),
                          const SizedBox(height: 14),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Completamento: ${(percent * 100).toInt()}%",
                                style: MindBloomingTextStyle.small,
                              ),
                              Padding(
                                padding: const EdgeInsets.only(right: 20),
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
                                      minHeight: 5,
                                      color: exercise.done
                                          ? MindBloomingColorScheme.secondary
                                          : MindBloomingColorScheme.tertiary,
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
            ),
          )
        : Container(
            margin: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
            decoration: BoxDecoration(
              color: MindBloomingColorScheme.primary1shadow,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: MindBloomingColorScheme.primary3shadow,
                width: 0.5,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 25),
              child: Row(
                children: [
                  const SizedBox(width: 20),
                  Text(
                    "${mp.prettyName[exercise.modulo] ?? exercise.modulo}${debug ? "\nDate: ${date}" : ""}",
                    style: MindBloomingTextStyle.normal,
                  ),
                  const Spacer(),
                  SvgPicture.asset("assets/icon_locked.svg"),
                  const SizedBox(width: 20),
                ],
              ),
            ),
          );
  }

  void _onTap(
    BuildContext context,
    Exercise exercise,
    String tappa,
  ) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => BlocksScreen(
          exercise: exercise,
          tappa: tappa,
        ),
      ),
    );
  }
}
