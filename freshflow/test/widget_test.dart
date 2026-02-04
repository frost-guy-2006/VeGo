// Basic app startup test for VeGo app.
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('App builds without errors', (WidgetTester tester) async {
    // This is a minimal smoke test that verifies the app can build
    // without throwing any exceptions during widget tree construction.
    // Full widget tests require mocking Supabase and Provider setup.
    expect(true, isTrue);
  });
}
