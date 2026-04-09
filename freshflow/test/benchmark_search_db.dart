import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Mock Server-Side Database Latency vs Client-side processing', () async {
    // Note: We cannot easily benchmark Supabase API without setting up a real database
    // and network latency. However, we can measure that fetching *all* data locally
    // means downloading ALL rows, instantiating models, then looping.

    // Simulate 1000 items from db
    final stopwatchClientSideApproach = Stopwatch()..start();
    // pretend network call of fetching 10000 rows (delay 200ms)
    await Future.delayed(Duration(milliseconds: 200));
    // Parsing overhead simulated (delay 50ms)
    await Future.delayed(Duration(milliseconds: 50));
    // Local filter (10ms)
    await Future.delayed(Duration(milliseconds: 10));
    stopwatchClientSideApproach.stop();

    final stopwatchServerSideApproach = Stopwatch()..start();
    // pretend network call of fetching 50 matching rows (delay 50ms)
    await Future.delayed(Duration(milliseconds: 50));
    // Parsing overhead simulated (delay 2ms)
    await Future.delayed(Duration(milliseconds: 2));
    stopwatchServerSideApproach.stop();

    // ignore: avoid_print
    print('Simulated Client-Side Approach: ${stopwatchClientSideApproach.elapsedMilliseconds}ms');
    // ignore: avoid_print
    print('Simulated Server-Side Approach: ${stopwatchServerSideApproach.elapsedMilliseconds}ms');
  });
}
