import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  bool _isDynamicColorEnabled = false;

  ThemeMode get themeMode => _themeMode;
  bool get isDynamicColorEnabled => _isDynamicColorEnabled;

  ThemeProvider() {
    _loadFromPrefs();
  }

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final modeString = prefs.getString('themeMode') ?? 'system';
    _isDynamicColorEnabled = prefs.getBool('useMaterialYou') ?? false;

    if (modeString == 'light') {
      _themeMode = ThemeMode.light;
    } else if (modeString == 'dark') {
      _themeMode = ThemeMode.dark;
    } else {
      _themeMode = ThemeMode.system;
    }
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    final prefs = await SharedPreferences.getInstance();
    String modeString = 'system';
    if (mode == ThemeMode.light) modeString = 'light';
    if (mode == ThemeMode.dark) modeString = 'dark';
    await prefs.setString('themeMode', modeString);
    notifyListeners();
  }

  Future<void> toggleDynamicColor(bool value) async {
    _isDynamicColorEnabled = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('useMaterialYou', value);
    notifyListeners();
  }
}
