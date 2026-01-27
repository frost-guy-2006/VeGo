import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:vego/main.dart';
import 'package:vego/features/auth/screens/login_screen.dart';

void main() {
  setUpAll(() async {
    // Mock SharedPreferences
    SharedPreferences.setMockInitialValues({});

    // Mock Supabase
    // We initialize Supabase with dummy values.
    // Since we can't easily mock the network calls inside Supabase without
    // a proper mock client, this initialization prevents the 'instance not found' error.
    // Tests that trigger actual Supabase calls will still fail if not properly mocked,
    // but the app initialization (which checks currentUser) should work if we
    // don't expect a logged-in user immediately or if we mock the auth state.
    // However, Supabase.initialize is a static setup.
    await Supabase.initialize(
      url: 'https://example.supabase.co',
      anonKey: 'dummy',
    );
  });

  testWidgets('VeGoApp smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const VeGoApp());
    await tester.pumpAndSettle();

    // Verify that we are either at LoginScreen or HomeScreen.
    // Since SharedPreferences is empty and Supabase has no session by default (or dummy),
    // it should likely show LoginScreen.
    // Note: AuthProvider checks currentUser. If dummy Supabase returns null user,
    // it goes to LoginScreen.

    expect(find.byType(LoginScreen), findsOneWidget);
  });
}
