import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFFEC4913);
  static const Color backgroundLight = Color(0xFFF8F6F6);
  static const Color backgroundDark = Color(0xFF221510);
}

class AppTheme {
  static ThemeData get light {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        primary: AppColors.primary,
        surface: Colors.white,
      ),
      scaffoldBackgroundColor: AppColors.backgroundLight,
      useMaterial3: true,
      fontFamily: 'PlusJakartaSans',
      appBarTheme: const AppBarTheme(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
    );
  }
}

