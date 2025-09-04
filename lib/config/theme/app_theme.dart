import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF1a6f8b);
  static const Color secondary = Color(0xFF4caf50);
  static const Color light = Color(0xFFF8F9FA);
  static const Color dark = Color(0xFF343A40);
  static const Color text = Color(0xFF495057);
  static const Color border = Color(0xfff3f3f3);
}

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: AppColors.primary,
    scaffoldBackgroundColor: AppColors.light,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: AppColors.text),
      bodyMedium: TextStyle(color: AppColors.text),
    ),
    colorScheme: const ColorScheme.light(
      primary: AppColors.primary,
      secondary: AppColors.secondary,
      surface: AppColors.light,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: AppColors.text,
      onPrimaryContainer: AppColors.border
    ),
  );

  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: AppColors.primary,
    scaffoldBackgroundColor: AppColors.dark,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.dark,
      foregroundColor: Colors.white,
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: AppColors.light),
      bodyMedium: TextStyle(color: AppColors.light),
    ),
    colorScheme: const ColorScheme.dark(
      primary: AppColors.primary,
      secondary: AppColors.secondary,
      surface: AppColors.dark,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: AppColors.light,
      onPrimaryContainer: AppColors.border,
    ),
  );
}
