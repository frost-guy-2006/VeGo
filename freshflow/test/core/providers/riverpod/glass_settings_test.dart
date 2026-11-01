import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vego/core/providers/riverpod/glass_settings_notifier.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('GlassSettingsState & Notifier', () {
    test('default state has 0.50 transparency', () {
      const state = GlassSettingsState();
      expect(state.transparency, 0.50);
    });

    test('copyWith updates transparency correctly', () {
      const state = GlassSettingsState(transparency: 0.2);
      final updated = state.copyWith(transparency: 0.8);
      expect(updated.transparency, 0.8);
    });

    test('updates state and persists to SharedPreferences', () async {
      SharedPreferences.setMockInitialValues({});
      final notifier = GlassSettingsNotifier();

      expect(notifier.state.transparency, 0.50);

      await notifier.setTransparency(0.25);
      expect(notifier.state.transparency, 0.25);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getDouble('liquid_glass_transparency'), 0.25);

      notifier.setFrosted();
      expect(notifier.state.transparency, 1.0);

      notifier.setPureGlass();
      expect(notifier.state.transparency, 0.0);

      notifier.setBalanced();
      expect(notifier.state.transparency, 0.50);
    });

    test('clamps transparency value between 0.0 and 1.0 on setTransparency', () async {
      SharedPreferences.setMockInitialValues({});
      final notifier = GlassSettingsNotifier();

      await notifier.setTransparency(1.5);
      expect(notifier.state.transparency, 1.0);

      await notifier.setTransparency(-0.4);
      expect(notifier.state.transparency, 0.0);
    });
  });
}
