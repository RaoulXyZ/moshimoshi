import 'package:flutter/material.dart';

import '../../utility/mindblooming_color_scheme.dart';
import '../../widgets/bottom_navbar/bottom_navbar.dart';
import 'exercises_screen/exercises_screen.dart';
import './homepage_screen/homepage_screen.dart';
import './settings_screen/settings_screen.dart';
import './diary_screen/diary_screen.dart';
import 'safety_planning_screen/safety_planning_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MindBloomingColorScheme.primary,
      body: _selectedIndex == 0
          ? HomepageScreen(
              toExercises: () {
                setState(() {
                  _selectedIndex = 1;
                });
              },
            )
          : _selectedIndex == 1
              ? const ExercisesScreen()
              : _selectedIndex == 2
                  ? const SafetyPlanningScreen()
                  : _selectedIndex == 3
                      ? const DiaryScreen()
                      : const SettingsScreen(),
      bottomNavigationBar: BottomNavbar(
        selectedIndex: _selectedIndex,
        // hideLabels: GetPlatform.isMobile,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }
}
