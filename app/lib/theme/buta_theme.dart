import 'package:flutter/material.dart';

class ButaColors {
  // Backgrounds
  static const Color background = Color(0xFF0B0D14);
  static const Color surface = Color(0xFF121622);
  static const Color surfaceLight = Color(0xFF1B2032);
  static const Color surfaceBorder = Color(0xFF262C44);

  // Accents & Brand
  static const Color primary = Color(0xFF6366F1); // Electric Indigo
  static const Color primaryGlow = Color(0x336366F1);
  static const Color secondary = Color(0xFF38BDF8); // Cyan
  static const Color accent = Color(0xFFA855F7); // Violet

  // Specialist Roles
  static const Color ceo = Color(0xFFA855F7); // Purple
  static const Color architect = Color(0xFF38BDF8); // Cyan
  static const Color developer = Color(0xFF10B981); // Emerald
  static const Color reviewer = Color(0xFFF97316); // Amber / Orange
  static const Color qa = Color(0xFFEC4899); // Rose / Pink
  static const Color user = Color(0xFF6366F1); // Indigo

  // Status
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color textMuted = Color(0xFF94A3B8);
  static const Color textBright = Color(0xFFF8FAFC);
}

class ButaTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: ButaColors.background,
      primaryColor: ButaColors.primary,
      fontFamily: 'Inter',
      colorScheme: const ColorScheme.dark(
        primary: ButaColors.primary,
        secondary: ButaColors.secondary,
        surface: ButaColors.surface,
        error: ButaColors.error,
      ),
      cardTheme: CardThemeData(
        color: ButaColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: ButaColors.surfaceBorder, width: 1),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: ButaColors.surfaceBorder,
        thickness: 1,
        space: 1,
      ),
    );
  }
}
