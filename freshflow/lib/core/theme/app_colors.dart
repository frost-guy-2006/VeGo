import 'package:flutter/material.dart';

class AppColors {
  // 🥬 Fresh Produce Primary Palette
  static const Color primary = Color(0xFF22C55E); // Fresh Leaf Green
  static const Color primaryDark = Color(0xFF16A34A); // Emerald Accent
  static const Color primaryLight = Color(0xFF86EFAC); // Mint Glow
  static const Color neonMint = Color(0xFF4ADE80); // JetBrains Mono Price Glow

  // 🍅 Sharp Accent Colors
  static const Color accent = Color(0xFFFF5A5F); // Electric Coral (CTA)
  static const Color accentWarm = Color(0xFFFF9F1C); // Mango Orange
  static const Color accentGold = Color(0xFFFBBF24); // Warm Gold

  // 📝 Text Colors
  static const Color textDark = Color(0xFF0F172A); // Deep Slate (High contrast)
  static const Color textMuted = Color(0xFF475569); // Slate Gray (WCAG AA 6.2:1)
  static const Color textLight = Color(0xFFFFFFFF); // Pure White

  // 🎨 Background Colors (Light Mode)
  static const Color background = Color(0xFFF4F7F5); // Airy Morning Mist
  static const Color surface = Color(0xFFFFFFFF); // Pure White
  static const Color surfaceAlt = Color(0xFFEAEFEA); // Soft Sage Mist

  // 🌙 Dark Mode (Obsidian Crystal Palette - No Muddy Green)
  static const Color backgroundDark = Color(0xFF090D0B); // Deep Obsidian Black
  static const Color surfaceDark = Color(0xFF101C15); // Glass surface base
  static const Color cardDark = Color(0xFF16261D); // Elevated glass card
  static const Color surfaceAltDark = Color(0xFF1C3125); // Alt glass chip
  static const Color borderDark = Color(0x33FFFFFF); // Specular bevel rim
  static const Color textMutedDark = Color(0xFF94A3B8); // High contrast text (5.8:1)

  // ⚡ Utility Colors
  static const Color success = Color(0xFF22C55E); // Fresh Green
  static const Color warning = Color(0xFFF59E0B); // Amber
  static const Color error = Color(0xFFEF4444); // Red
  static const Color border = Color(0xFFE2E8F0); // Light Gray

  // Legacy aliases for backward compatibility
  static const Color secondary = textMuted;

  // 🏷️ Category Colors
  static const Color categoryVegetables = Color(0xFF22C55E);
  static const Color categoryFruits = Color(0xFFFF5A5F);
  static const Color categoryDairy = Color(0xFF38BDF8);
  static const Color categoryBakery = Color(0xFFF59E0B);
  static const Color categoryTeaCoffee = Color(0xFFA16207);
  static const Color categoryBgLight = Color(0xFFEDF2EE);
  static const Color categoryBorderLight = Color(0xFFD1DBD2);

  // 🧩 Misc UI Colors
  static const Color darkBg = Color(0xFF090D0B);
  static const Color flashDark = Color(0xFF142219);
  static const Color waveDarkEnd = Color(0xFF0A130E);
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
