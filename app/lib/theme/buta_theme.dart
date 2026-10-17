import 'package:flutter/material.dart';

class ButaColors {
  // Clean Light Premium Surfaces
  static const Color background = Color(0xFFF8FAFC); // Airy porcelain
  static const Color sidebar = Color(0xFFFFFFFF); // Crisp frosted white
  static const Color sidebarBorder = Color(0xFFE2E8F0); // Delicate border
  static const Color surface = Color(0xFFFFFFFF); // Clean white card
  static const Color surfaceLight = Color(0xFFF1F5F9); // Soft slate chip
  static const Color surfaceBorder = Color(0xFFE2E8F0); // Crisp border
  static const Color borderLight = Color(0xFFE2E8F0); // Delicate border alias
  static const Color subtleBorder = Color(0xFFF1F5F9); // Hairline

  // Primary & Brand Glow
  static const Color primary = Color(0xFF4F46E5); // Modern Indigo
  static const Color primaryLight = Color(0xFFEEF2FF); // Soft indigo tint
  static const Color primaryGlow = Color(0x224F46E5);
  static const Color secondary = Color(0xFF0284C7); // Sky
  static const Color accent = Color(0xFF8B5CF6); // Purple
  static const Color warmAccent = Color(0xFFF59E0B); // Amber

  // ButaAI Engineering Specialist Accents
  static const Color ceo = Color(0xFF6366F1); // Executive Indigo (CEO)
  static const Color productArchitect = Color(0xFF0284C7); // Cyan / Sky Blue (PRD)
  static const Color systemArchitect = Color(0xFF0D9488); // Teal (Architecture)
  static const Color frontendLead = Color(0xFFD97706); // Amber Gold (UI / Flutter)
  static const Color backendLead = Color(0xFF2563EB); // Electric Blue (Data / APIs)
  static const Color qaLead = Color(0xFF059669); // Emerald Green (Security & Tests)
  static const Color user = Color(0xFF4F46E5); // Modern Indigo (Product Creator)

  // Legacy aliases
  static const Color gelly = Color(0xFF6366F1);
  static const Color bloop = Color(0xFF0284C7);
  static const Color pip = Color(0xFF0D9488);
  static const Color mochi = Color(0xFFD97706);
  static const Color spark = Color(0xFF059669);
  static const Color reviewer = Color(0xFF059669);
  static const Color developer = Color(0xFF2563EB);

  // Status & Badges
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);

  // Modern Typography (Deep Slate Palette)
  static const Color textBright = Color(0xFF0F172A); // Slate 900
  static const Color textPrimary = Color(0xFF0F172A); // Slate 900 alias
  static const Color textNormal = Color(0xFF334155); // Slate 700
  static const Color textSecondary = Color(0xFF64748B); // Slate 500
  static const Color textMuted = Color(0xFF94A3B8); // Slate 400
  static const Color sidebarBg = Color(0xFFFFFFFF);

  // Assistant Dialogue Bubbles
  static const Color bubbleAgent = Color(0xFFFFFFFF);
  static const Color bubbleUser = Color(0xFF4F46E5);
  static const Color thinkingBg = Color(0xFFF8FAFC);
  static const Color thinkingBorder = Color(0xFFE2E8F0);
}

class ButaTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: ButaColors.background,
      primaryColor: ButaColors.primary,
      fontFamily: 'Inter',
      colorScheme: const ColorScheme.light(
        primary: ButaColors.primary,
        secondary: ButaColors.secondary,
        surface: ButaColors.surface,
        error: ButaColors.error,
      ),
      cardTheme: CardThemeData(
        color: ButaColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
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

  // Keep darkTheme alias for compatibility
  static ThemeData get darkTheme => lightTheme;
}
