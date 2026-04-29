import 'package:flutter/material.dart';

class AppColors {
  // 🥬 Fresh Produce Primary Palette
  static const Color primary = Color(0xFF1B4332); // Forest Green (dominant)
  static const Color primaryLight = Color(0xFF40916C); // Sage Green
  static const Color primaryDark = Color(0xFF081C15); // Deep Forest

  // 🍅 Sharp Accent Colors
  static const Color accent = Color(0xFFE63946); // Tomato Red (CTA)
  static const Color accentWarm = Color(0xFFFF9F1C); // Mango Orange
  static const Color accentGold = Color(0xFFF4D35E); // Lemon Yellow

  // 📝 Text Colors
  static const Color textDark = Color(0xFF1A1A2E); // Rich Black
  static const Color textMuted = Color(0xFF4A5568); // Warm Gray
  static const Color textLight = Color(0xFFF7FAFC); // Off White

  // 🎨 Background Colors
  static const Color background = Color(0xFFEDF5F0); // Cool Sage
  static const Color surface = Color(0xFFFFFFFF); // Pure White
  static const Color surfaceAlt = Color(0xFFF6FBF8); // Lighter Sage

  // 🌙 Dark Mode
  static const Color backgroundDark = Color(0xFF0B1A13); // Deep forest night
  static const Color surfaceDark = Color(0xFF1F4231); // Leaf card surface
  static const Color cardDark = Color(0xFF2A5740); // Elevated card
  static const Color surfaceAltDark =
      Color(0xFF2A5740); // Alt surface (same as card for elevation)
  static const Color borderDark = Color(0xFF538A72); // Visible dark border
  static const Color textMutedDark =
      Color(0xFFB0BEC0); // Lighter muted text for readability

  // ⚡ Utility Colors
  static const Color success = Color(0xFF22C55E); // Fresh Green
  static const Color warning = Color(0xFFF59E0B); // Amber
  static const Color error = Color(0xFFEF4444); // Red
  static const Color border = Color(0xFFE2E8F0); // Light Gray

  // Legacy aliases for backward compatibility
  static const Color secondary = textMuted;

  // 🌤️ Weather & Gradient Colors
  static const Color weatherSunnyStart = Color(0xFFFF9F1C);
  static const Color weatherSunnyEnd = Color(0xFFF4D35E);
  static const Color weatherCloudyStart = Color(0xFF78909C);
  static const Color weatherCloudyEnd = Color(0xFFB0BEC5);
  static const Color weatherRainyStart = Color(0xFF5C6BC0);
  static const Color weatherRainyEnd = Color(0xFF7986CB);
  static const Color weatherSnowyStart = Color(0xFF80DEEA);
  static const Color weatherSnowyEnd = Color(0xFFB2EBF2);
  static const Color weatherNightStart = Color(0xFF37474F);
  static const Color weatherNightEnd = Color(0xFF546E7A);

  // 🏷️ Category Colors
  static const Color categoryVegetables = Color(0xFF22C55E);
  static const Color categoryFruits = Color(0xFFE63946);
  static const Color categoryDairy = Color(0xFF3B82F6);
  static const Color categoryBakery = Color(0xFFA3584E);
  static const Color categoryTeaCoffee = Color(0xFF6D4C41);
  static const Color categoryBgLight = Color(0xFFF1F2F4);
  static const Color categoryBorderLight = Color(0xFFD8DADF);

  // 🧩 Misc UI Colors
  static const Color darkBg = Color(0xFF1A1A2E);
  static const Color flashDark = Color(0xFF252837);
  static const Color waveDarkEnd = Color(0xFF0D2818);
  static const Color waveLightEnd = Color(0xFFD8F3DC);
  static const Color bgMintWhisper = Color(0xFFF0FDF4);
  static const Color bgPeachCream = Color(0xFFFEF3E2);
}

/// Context-aware color extension. Use these instead of hardcoded AppColors
/// so dark mode works automatically.
extension AppColorsX on BuildContext {
  bool get _isDark => Theme.of(this).brightness == Brightness.dark;

  // Backgrounds
  Color get backgroundColor =>
      _isDark ? AppColors.backgroundDark : AppColors.background;
  Color get surfaceColor => _isDark ? AppColors.surfaceDark : AppColors.surface;
  Color get surfaceAltColor =>
      _isDark ? AppColors.surfaceAltDark : AppColors.surfaceAlt;
  Color get cardColor => _isDark ? AppColors.cardDark : AppColors.surface;

  // Text
  Color get textPrimary => _isDark ? AppColors.textLight : AppColors.textDark;
  Color get textSecondary =>
      _isDark ? AppColors.textMutedDark : AppColors.textMuted;

  // Borders
  Color get borderColor => _isDark ? AppColors.borderDark : AppColors.border;
}
