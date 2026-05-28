import 'dart:async';
import 'package:feedback/feedback.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:sizer/sizer.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import './login/pages/loading_screen.dart';
import './providers/answers.dart';
import './providers/questions.dart';
import './providers/validation.dart';
import './providers/screening.dart';
import './providers/moduli.dart';
import './providers/progress.dart' as Progress;
import './providers/calendar.dart';
import './providers/user_settings.dart';
import './providers/safety_planning.dart';
import './models/daily_screening.dart';
import './models/weekly_screening.dart';
import './utility/github_feedback.dart';
import './utility/local_user.dart';
import './utility/mindblooming_color_scheme.dart';
import './utility/notification_api.dart';
import 'models/exercise_migration.dart';
import 'models/exercise_safe_adapter.dart';
import 'widgets/custom_feedback_form.dart';

const bool demo = false;
const bool canSend = true;

Future main() async {
  await dotenv.load(fileName: '.env');
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();

  Hive.registerAdapter(ExerciseSafeAdapter());

  Hive.registerAdapter(DailyScreeningAdapter());
  Hive.registerAdapter(WeeklyScreeningAdapter());

  Intl.defaultLocale = 'it_IT';
  await initializeDateFormatting();

  final box = await Hive.openBox('moshimoshi');
  await migrateWeeklyExercises(box, 'weeklyExercises');
  await Hive.openBox('diary');

  LocalUser.ensureUid();

  await NotificationAPI.init();

  runApp(
    BetterFeedback(
      feedbackBuilder: (context, onSubmit, scrollController) =>
          CustomFeedbackForm(
        onSubmit: onSubmit,
      ),
      theme: FeedbackThemeData(
        background: Colors.grey,
        feedbackSheetColor: Colors.grey[50]!,
        drawColors: [
          Colors.red,
          Colors.green,
          Colors.blue,
          Colors.yellow,
        ],
      ),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      localeOverride: const Locale('it'),
      mode: FeedbackMode.draw,
      pixelRatio: 1,
      child: Sizer(
        builder: (context, orientation, deviceType) => const Main(),
      ),
    ),
  );
}

class Main extends StatelessWidget {
  const Main({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => Answers()),
        ChangeNotifierProvider(create: (_) => Questions()),
        ChangeNotifierProvider(create: (_) => Validation()),
        ChangeNotifierProvider(create: (_) => Screening()),
        ChangeNotifierProvider(create: (_) => Moduli()),
        ChangeNotifierProvider(create: (_) => Progress.Progress()),
        ChangeNotifierProvider(create: (_) => UserSettings()),
        ChangeNotifierProvider(create: (_) => Calendar()),
        ChangeNotifierProvider(create: (_) => SafetyPlanning()),
      ],
      child: Stack(
        children: [
          GetMaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Moshi Moshi',
            theme: ThemeData(colorScheme: colorScheme),
            home: const LoadingScreen(),
          ),
          Positioned(
            top: 16,
            right: 16,
            child: FloatingActionButton(
              backgroundColor: MindBloomingColorScheme.secondary,
              onPressed: () {
                BetterFeedback.of(context).show((feedback) async {
                  await uploadFeedbackToGitHub(
                    feedback,
                    owner: dotenv.env['GITHUB_REPO_OWNER']!,
                    repo: dotenv.env['GITHUB_REPO_NAME']!,
                    token: dotenv.env['GITHUB_API_TOKEN']!,
                  );
                });
              },
              child: const Icon(
                Icons.feedback,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
