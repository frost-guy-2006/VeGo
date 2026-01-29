import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vego/main.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});

    // Initialize Supabase with dummy values for testing
    // We try/catch because if it's already initialized in another test, it might throw
    try {
      await Supabase.initialize(
        url: 'https://dummy.supabase.co',
        anonKey: 'dummy',
      );
    } catch (_) {}
  });

  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const VeGoApp());
    // Use pump instead of pumpAndSettle to avoid timeouts if there are infinite animations
    await tester.pump();

    // Check for generic elements that should exist
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
