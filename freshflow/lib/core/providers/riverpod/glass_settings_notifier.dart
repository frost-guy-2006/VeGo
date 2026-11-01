import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Immutable state holding the user's Liquid Glass preferences.
class GlassSettingsState {
  /// Normalized transparency value from 0.0 (Pure Crystal Glass) to 1.0 (Dense Frosted Glass).
  final double transparency;

  const GlassSettingsState({this.transparency = 0.50});

  GlassSettingsState copyWith({double? transparency}) {
    return GlassSettingsState(
      transparency: transparency ?? this.transparency,
    );
  }
}

/// StateNotifier controlling the Liquid Glass opacity and blur dynamics.
class GlassSettingsNotifier extends StateNotifier<GlassSettingsState> {
  static const String _prefKey = 'liquid_glass_transparency';

  GlassSettingsNotifier() : super(const GlassSettingsState()) {
    _loadFromPreferences();
  }

  Future<void> _loadFromPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedValue = prefs.getDouble(_prefKey);
      if (savedValue != null) {
        state = state.copyWith(transparency: savedValue.clamp(0.0, 1.0));
      }
    } catch (_) {
      // Fallback to default
    }
  }

  Future<void> setTransparency(double value) async {
    final clamped = value.clamp(0.0, 1.0);
    state = state.copyWith(transparency: clamped);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble(_prefKey, clamped);
    } catch (_) {}
  }

  void setPureGlass() => setTransparency(0.0);
  void setBalanced() => setTransparency(0.50);
  void setFrosted() => setTransparency(1.0);
}

/// Riverpod provider for glass settings.
final glassSettingsProvider =
    StateNotifierProvider<GlassSettingsNotifier, GlassSettingsState>((ref) {
  return GlassSettingsNotifier();
});

