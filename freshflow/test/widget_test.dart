import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:vego/main.dart';
import 'package:vego/core/constants/env.dart';

void main() {
  setUpAll(() async {
    // Mock SharedPreferences
    SharedPreferences.setMockInitialValues({});

    // Initialize Supabase
    // We use try-catch because it might already be initialized if running multiple tests
    try {
        // Initialize with Env values which we verified exist
        await Supabase.initialize(
          url: Env.supabaseUrl,
          anonKey: Env.supabaseAnonKey,
        );
    } catch (_) {
        // Already initialized
    }
  });

  testWidgets('VeGoApp smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const VeGoApp());

    // Wait for animations and providers to settle
    // pumpAndSettle might time out if there's an infinite animation (like a progress indicator)
    // The LoginScreen shouldn't have one initially unless it's loading, but AuthProvider starts with _isLoading = false.
    await tester.pumpAndSettle();

    // Verify that the LoginScreen is displayed
    // We check for the "Welcome to VeGo" text.
    // Since it might be split into multiple text widgets or one with newline, checking textContaining is safer.
    expect(find.textContaining('Welcome to'), findsOneWidget);
    expect(find.textContaining('VeGo'), findsOneWidget);
  });
}
