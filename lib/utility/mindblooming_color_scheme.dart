import 'package:flutter/material.dart';

class MindBloomingColorScheme {
  static const Color primary = Color(0xFFFFFCF8);
  static const Color primary1shadow = Color(0xFFF6F6F6);
  static const Color primary2shadow = Color(0xFFEDEDED);
  static const Color primary3shadow = Color(0xFFCECECE);

  static const Color secondary = Color(0xFF44B48F);
  static const Color secondary1shadow = Color(0xFFDAFFE6);
  static const Color secondary2shadow = Color(0xFFCCE8DA);
  static const Color secondary3shadow = Color(0xFFA7ECC9);
  static const Color secondary4shadow = Color(0xFF55CFA5);
  static const Color secondary5shadow = Color(0xFF419277);

  static const Color tertiary = Color(0xFFFFC484);
  static const Color tertiary1shadow = Color(0xFFFEF4EB);
  static const Color tertiary2shadow = Color(0xFFFFD7AA);
  static const Color tertiary3shadow = Color(0xFFFFB96D);

  static const Color textColorDark = Color(0xFF091712);
  static const Color textColorDark1shadow = Color(0xFF909694);

  static const Color textColorLight = Color(0xFFF7FFFC);

  static Color dialogBg =
      const Color.fromARGB(255, 144, 150, 148).withValues(alpha: 0.3);
  static Color shadow =
      const Color.fromARGB(255, 9, 23, 18).withValues(alpha: 0.4);
}

ColorScheme colorScheme = ColorScheme(
  primary: createMaterialColor(const Color(0xFF44B48F)),
  secondary: createMaterialColor(const Color(0xFFFFFCF8)),
  tertiary: createMaterialColor(const Color(0xFFFFC484)),
  // surface: const Color(0xFFFFFCF8),
  surface: const Color(0xFFFFFCF8),
  error: Colors.red,
  onPrimary: const Color(0xFF091712),
  onSecondary: const Color(0xFF091712),
  onSurface: const Color(0xFF091712),
  // onBackground: const Color(0xFF091712),
  onError: Colors.white,
  brightness: Brightness.light,
);

MaterialColor createMaterialColor(Color color) {
  final List strengths = <double>[.05];
  final Map<int, Color> swatch = <int, Color>{};
  final int r = color.red, g = color.green, b = color.blue;

  for (int i = 1; i < 10; i++) {
    strengths.add(0.1 * i);
  }
  strengths.forEach((strength) {
    final double ds = 0.5 - strength;
    swatch[(strength * 1000).round()] = Color.fromRGBO(
      r + ((ds < 0 ? r : (255 - r)) * ds).round(),
      g + ((ds < 0 ? g : (255 - g)) * ds).round(),
      b + ((ds < 0 ? b : (255 - b)) * ds).round(),
      1,
    );
  });

  return MaterialColor(color.value, swatch);
}
