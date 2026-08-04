import 'package:flutter/material.dart';

class ThemeProvider with ChangeNotifier {
  bool _isDark = false;
  bool get isDark => _isDark;

  // Custom Color Palette Hex Codes
  static const Color hexF0F3FA = Color(0xFFF0F3FA); // Light theme background
  static const Color hexD5DEEF = Color(0xFFD5DEEF); // Light surface/card
  static const Color hexB1C9EF = Color(0xFFB1C9EF); // Secondary accent
  static const Color hex8AAEE0 = Color(0xFF8AAEE0); // Medium accent
  static const Color hex638ECB = Color(0xFF638ECB); // Primary color
  static const Color hex395886 = Color(0xFF395886); // Dark theme background

  // Light Theme
  final ThemeData _lightTheme = ThemeData(
    brightness: Brightness.light,
    useMaterial3: true,
    primaryColor: hex638ECB,
    scaffoldBackgroundColor: hexF0F3FA,
    colorScheme: const ColorScheme.light(
      primary: hex638ECB,
      secondary: hex8AAEE0,
      surface: hexD5DEEF,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: hex638ECB,
      foregroundColor: Colors.white,
    ),
    cardTheme: const CardThemeData(
      color: hexD5DEEF,
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: hexF0F3FA,
      selectedItemColor: hex638ECB,
      unselectedItemColor: hex8AAEE0,
    ),
  );

  // Dark Theme
  final ThemeData _darkTheme = ThemeData(
    brightness: Brightness.dark,
    useMaterial3: true,
    primaryColor: hex8AAEE0,
    scaffoldBackgroundColor: hex395886,
    colorScheme: const ColorScheme.dark(
      primary: hex8AAEE0,
      secondary: hexB1C9EF,
      surface: Color(0xFF2C456B),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: hex395886,
      foregroundColor: Colors.white,
    ),
    cardTheme: const CardThemeData(
      color: Color(0xFF2C456B),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: hex395886,
      selectedItemColor: hexB1C9EF,
      unselectedItemColor: hex8AAEE0,
    ),
  );

  ThemeData get lightTheme => _lightTheme;
  ThemeData get darkTheme => _darkTheme;

  void toggleTheme() {
    _isDark = !_isDark;
    notifyListeners();
  }
}

typedef ThemeModel = ThemeProvider;
