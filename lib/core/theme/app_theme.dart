import 'package:flutter/material.dart';

/// Adjust these to match your actual sangha-* Tailwind values from the
/// web app so both platforms feel like the same product.
class AppColors {
  static const primary = Color(0xFF7A5230); // sangha-primary (placeholder)
  static const dark = Color(0xFF3E2A1B); // sangha-dark
  static const cream = Color(0xFFF3E9DD); // sangha-cream
  static const light = Color(0xFFFBF6EF); // sangha-light
}

ThemeData buildAppTheme() {
  final colorScheme = ColorScheme.fromSeed(
    seedColor: AppColors.primary,
    primary: AppColors.primary,
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: AppColors.light,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.light,
      foregroundColor: AppColors.dark,
      elevation: 0,
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppColors.cream),
      ),
    ),
    inputDecorationTheme: const InputDecorationTheme(
      border: OutlineInputBorder(),
    ),
  );
}
