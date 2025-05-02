import 'package:flutter/material.dart';

class AppThemes {
  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme(
      brightness: Brightness.light,
      primary: const Color(0xFF3F51B5), // Azul moderno
      onPrimary: Colors.white,
      primaryContainer: const Color(0xFFC5CAE9), // Azul claro
      onPrimaryContainer: const Color(0xFF303F9F),
      secondary: const Color(0xFF4CAF50), // Verde fresco
      onSecondary: Colors.white,
      secondaryContainer: const Color(0xFFC8E6C9), // Verde claro
      onSecondaryContainer: const Color(0xFF388E3C),
      background: const Color(0xFFF5F5F5), // Neutro e suave
      onBackground: const Color(0xFF212121),
      surface: Colors.white,
      onSurface: const Color(0xFF212121),
      surfaceVariant: const Color(0xFFECEFF1), // Leve contraste
      onSurfaceVariant: const Color(0xFF616161),
      error: const Color(0xFFD32F2F), // Vermelho suave
      onError: Colors.white,
      outline: const Color(0xFFBDBDBD),
    ),
    scaffoldBackgroundColor: const Color(0xFFF5F5F5),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      titleTextStyle: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: const Color(0xFF212121),
      ),
    ),
    textTheme: _textTheme,
    inputDecorationTheme: _inputDecorationTheme,
    filledButtonTheme: _filledButtonTheme,
  );

  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF3F51B5), // Azul para manter consistência
      brightness: Brightness.dark,
      primary: const Color(0xFF3F51B5),
      onPrimary: Colors.white,
      primaryContainer: Colors.blue.shade800, // Azul mais escuro
      onPrimaryContainer: Colors.grey.shade100,
      secondary: const Color(0xFF4CAF50),
      onSecondary: Colors.white,
      secondaryContainer: const Color(0xFF81C784),
      onSecondaryContainer: const Color(0xFF388E3C),
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
    fillColor: Colors.transparent,
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
