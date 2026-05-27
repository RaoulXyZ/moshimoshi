import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../chiamate.dart';
import '../../providers/progress.dart';
import '../../screens/main_screen/main_screen.dart';
import '../../screens/no_internet_screen.dart';
import '../../screens/on_board.dart';
import '../../screens/screening_screen.dart';
import '../../utility/local_user.dart';
import '../../widgets/splashscreen.dart';

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({Key? key}) : super(key: key);

  @override
  _LoadingScreenState createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  String? nextScreen;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    LocalUser.ensureUid();

    final result = await initQuestions(context, false, true);

    if (!mounted) return;

    if (result == "Home") {
      nextScreen = "home";
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MainScreen()),
      );
    } else if (result == "Screening") {
      nextScreen = "screening";
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => Provider.of<Progress>(context, listen: false)
                  .doneBlocks
                  .containsKey("MM_baseline_assessment_week1")
              ? ScreeningScreen()
              : const OnBoard(),
        ),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const NoInternetScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SplashScreen(
      Image.asset(
        'assets/logo.jpg',
        width: 130,
        height: 130,
      ),
    );
  }
}
