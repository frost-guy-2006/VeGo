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
  static const Color background = Color(0xFFFFFBF5); // Warm Paper
  static const Color surface = Color(0xFFFFFFFF); // Pure White
  static const Color surfaceAlt = Color(0xFFF0FDF4); // Mint Whisper

  // 🌙 Dark Mode
  static const Color backgroundDark = Color(0xFF0D1F17); // Forest Night
  static const Color surfaceDark = Color(0xFF1A3328); // Dark Leaf
  static const Color cardDark = Color(0xFF234E3B); // Evergreen

  // ⚡ Utility Colors
  static const Color success = Color(0xFF22C55E); // Fresh Green
  static const Color warning = Color(0xFFF59E0B); // Amber
  static const Color error = Color(0xFFEF4444); // Red
  static const Color border = Color(0xFFE2E8F0); // Light Gray

  // Legacy aliases for backward compatibility
  static const Color secondary = textMuted;
}
