import 'package:flutter/material.dart';

class AppThemes {
  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF7B1FA2), // Vibrant purple
      brightness: Brightness.light,
      primary: const Color(0xFF7B1FA2), // Vivid purple for highlights
      onPrimary: Colors.white,
      primaryContainer: Colors.purple.shade100, // Light purple for containers
      onPrimaryContainer: Colors.black87,
      secondary: Colors.green.shade600, // Complementary green for secondary actions
      onSecondary: Colors.white,
      surface: Colors.grey.shade50, // Light background
      onSurface: Colors.black87, // Dark text for contrast
      error: Colors.red.shade700,
      onError: Colors.white,
      shadow: Colors.black,
    ),
    scaffoldBackgroundColor: Colors.grey.shade50,
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.grey.shade50,
      surfaceTintColor: Colors.transparent,
      titleTextStyle: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: Colors.black87,
      ),
    ),
    textTheme: _textTheme,
    inputDecorationTheme: _inputDecorationTheme,
    filledButtonTheme: _filledButtonTheme,
  );

  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF7B1FA2), // Vibrant purple
      brightness: Brightness.dark,
      primary: const Color(0xFF7B1FA2), // Vivid purple for highlights
      onPrimary: Colors.white,
      primaryContainer: Colors.purple.shade800, // Darker purple for containers
      onPrimaryContainer: Colors.grey.shade100,
      secondary: Colors.greenAccent.shade400, // Bright green for secondary actions
      onSecondary: Colors.black87,
      surface: Colors.grey.shade900, // Dark background
      onSurface: Colors.grey.shade100, // Light text for contrast
      error: Colors.redAccent.shade400,
      onError: Colors.black,
      shadow: Colors.black,
    ),
    scaffoldBackgroundColor: Colors.grey.shade900,
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.grey.shade900,
      surfaceTintColor: Colors.transparent,
      titleTextStyle: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: Colors.grey.shade100,
      ),
    ),
    textTheme: _textTheme.apply(
      bodyColor: Colors.grey.shade100,
      displayColor: Colors.grey.shade100,
    ),
    inputDecorationTheme: _inputDecorationTheme,
    filledButtonTheme: _filledButtonTheme,
  );

  static const TextTheme _textTheme = TextTheme(
    titleLarge: TextStyle(
      fontSize: 28,
      fontWeight: FontWeight.w800,
      letterSpacing: -0.5,
    ),
    headlineSmall: TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.bold,
    ),
    labelLarge: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w600,
    ),
    bodyMedium: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      height: 1.5,
    ),
  );

  static final InputDecorationTheme _inputDecorationTheme = InputDecorationTheme(
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    filled: true,
    fillColor: Colors.transparent, // Let colorScheme.surface handle fill
  );

  static final FilledButtonThemeData _filledButtonTheme = FilledButtonThemeData(
    style: FilledButton.styleFrom(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      textStyle: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
    ),
  );
}