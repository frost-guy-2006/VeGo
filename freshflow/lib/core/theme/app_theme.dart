import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData createTheme({
    required ColorScheme? dynamicColorScheme,
    required Brightness brightness,
  }) {
    // Base Colors
    final defaultColorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: brightness,
      primary: AppColors.primary,
      secondary: AppColors.secondary,
      surface: brightness == Brightness.light
          ? Colors.white
          : const Color(0xFF121212),
    );

    final scheme = dynamicColorScheme ?? defaultColorScheme;
    final isDark = brightness == Brightness.dark;

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      scaffoldBackgroundColor:
          isDark ? const Color(0xFF121212) : AppColors.background,
      colorScheme: scheme,
      appBarTheme: AppBarTheme(
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: isDark ? Colors.white : Colors.black),
        titleTextStyle: GoogleFonts.plusJakartaSans(
          color: isDark ? Colors.white : AppColors.textDark,
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
      ),
      textTheme: GoogleFonts.plusJakartaSansTextTheme().apply(
        bodyColor: isDark ? Colors.white : AppColors.textDark,
        displayColor: isDark ? Colors.white : AppColors.textDark,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: scheme.primary,
          foregroundColor: scheme.onPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      cardTheme: CardTheme(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  // Fallbacks
  static ThemeData get lightTheme =>
      createTheme(dynamicColorScheme: null, brightness: Brightness.light);
  static ThemeData get darkTheme =>
      createTheme(dynamicColorScheme: null, brightness: Brightness.dark);
}
