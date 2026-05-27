import 'package:flutter/material.dart';

import '../../utility/mindblooming_color_scheme.dart';
import '../bottom_navbar/exercises_icon.dart';
import '../bottom_navbar/home_icon.dart';
import '../bottom_navbar/settings_icon.dart';
import '../bottom_navbar/diary_icon.dart';
import 'safety_planning_icon.dart';

class BottomNavbar extends StatelessWidget {
  const BottomNavbar({
    super.key,
    required this.selectedIndex,
    required this.onTap,
  });

  final int selectedIndex;
  final Function onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 75,
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(10),
          topLeft: Radius.circular(10),
        ),
        boxShadow: [
          BoxShadow(
            color: Color.fromARGB(64, 9, 23, 18),
            spreadRadius: 0,
            blurRadius: 0,
            offset: Offset(0, 0.5),
          ),
          BoxShadow(
            color: MindBloomingColorScheme.primary1shadow,
            spreadRadius: -0.1,
            blurRadius: 0,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          HomeIcon(
            active: selectedIndex == 0,
            onTap: () => onTap(0),
          ),
          ExercisesIcon(
            active: selectedIndex == 1,
            onTap: () => onTap(1),
          ),
          SafetyPlanningIcon(
            active: selectedIndex == 2,
            onTap: () => onTap(2),
          ),
          DiaryIcon(
            active: selectedIndex == 3,
            onTap: () => onTap(3),
          ),
          SettingsIcon(
            active: selectedIndex == 4,
            onTap: () => onTap(4),
          ),
        ],
      ),
    );
  }
}

// class BottomNavbar extends StatefulWidget {
//   static const routeName = '/bottom-navbar';
//   @override
//   _BottomNavbarState createState() => _BottomNavbarState();
// }

// class _BottomNavbarState extends State<BottomNavbar> {
//   late List<Map<String, dynamic>> _pages;
//   int _selectedPageIndex = 0;

//   @override
//   void initState() {
//     _pages = [
//       {
//         'page': DashboardScreen(),
//         'appBar': DashboardScreen.appBar,
//       },
//       {
//         'page': ExcercisesHomeScreen(),
//         'appBar': ExcercisesHomeScreen.appBar,
//       },
//       {
//         'page': ProfileScreen(),
//         'appBar': ProfileScreen.appBar,
//       },
//     ];
//     super.initState();
//   }

//   void _selectPage(int index) {
//     setState(() {
//       _selectedPageIndex = index;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     final mProvider = Provider.of<Moduli>(context);
//     final pProvider = Provider.of<Progress>(context);
//     final doneSurveys = pProvider.doneSurveys;
//     final toDo = pProvider.toDo;

//     mProvider.getExercises(toDo, doneSurveys);
//     mProvider.getWeekly();
//     mProvider.getDaily();

//     return Scaffold(
//       appBar: _pages[_selectedPageIndex]['appBar'],
//       body: _pages[_selectedPageIndex]['page'],
//       backgroundColor: MindBloomingColorScheme.primary,
//       bottomNavigationBar: ClipRRect(
//         borderRadius: BorderRadius.only(
//           topLeft: Radius.circular(30.0),
//           topRight: Radius.circular(30.0),
//         ),
//         child: Container(
//           decoration: BoxDecoration(
//             borderRadius: BorderRadius.only(
//               topRight: Radius.circular(30),
//               topLeft: Radius.circular(30),
//             ),
//             boxShadow: [BoxShadow()],
//             color: MindBloomingColorScheme.primary3shadow,
//           ),
//           child: BottomNavigationBar(
//             onTap: _selectPage,
//             showUnselectedLabels: true,
//             unselectedItemColor: MindBloomingColorScheme.textColorDark1shadow,
//             selectedItemColor: Theme.of(context).primaryColor,
//             currentIndex: _selectedPageIndex,
//             type: BottomNavigationBarType.fixed,
//             selectedLabelStyle: MindBloomingTextStyle.normal,
//             unselectedLabelStyle: MindBloomingTextStyle.normal,
//             backgroundColor: MindBloomingColorScheme.primary1shadow,
//             useLegacyColorScheme: false,
//             items: [
//               BottomNavigationBarItem(
//                 activeIcon: SvgPicture.asset(
//                   'assets/navbar_home_active.svg',
//                   height: 45,
//                 ),
//                 icon: SvgPicture.asset(
//                   'assets/navbar_home.svg',
//                 ),
//                 label: 'Home',
//               ),
//               BottomNavigationBarItem(
//                 activeIcon: SvgPicture.asset(
//                   'assets/navbar_exercises_active.svg',
//                 ),
//                 icon: SvgPicture.asset(
//                   'assets/navbar_exercises.svg',
//                 ),
//                 label: 'Esercizi',
//               ),
//               BottomNavigationBarItem(
//                 activeIcon: SvgPicture.asset(
//                   'assets/navbar_settings_active.svg',
//                 ),
//                 icon: SvgPicture.asset(
//                   'assets/navbar_settings.svg',
//                 ),
//                 label: 'Impostazioni',
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
