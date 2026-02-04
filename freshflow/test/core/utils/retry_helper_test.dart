import 'package:flutter_test/flutter_test.dart';
import 'package:vego/core/utils/retry_helper.dart';

void main() {
  group('RetryHelper', () {
    test('succeeds on first try', () async {
      int callCount = 0;

      final result = await RetryHelper.withRetry(() async {
        callCount++;
        return 'success';
      });

      expect(result, 'success');
      expect(callCount, 1);
    });

    test('retries on transient error and succeeds', () async {
      int callCount = 0;

      final result = await RetryHelper.withRetry(
        () async {
          callCount++;
          if (callCount < 3) {
            throw Exception('Connection refused');
          }
          return 'success';
        },
        config: const RetryConfig(
          maxAttempts: 3,
          initialDelay: Duration(milliseconds: 10),
        ),
      );

      expect(result, 'success');
      expect(callCount, 3);
    });

    test('throws after max attempts', () async {
      int callCount = 0;

      await expectLater(
        () => RetryHelper.withRetry(
          () async {
            callCount++;
            throw Exception('Connection refused');
          },
          config: const RetryConfig(
            maxAttempts: 2,
            initialDelay: Duration(milliseconds: 10),
          ),
        ),
        throwsException,
      );

      expect(callCount, 2); // Should have tried exactly 2 times
    });

    test('does not retry non-retryable errors', () async {
      int callCount = 0;

      expect(
        () => RetryHelper.withRetry(
          () async {
            callCount++;
            throw ArgumentError('Invalid argument');
          },
          config: const RetryConfig(
            maxAttempts: 3,
            initialDelay: Duration(milliseconds: 10),
          ),
        ),
        throwsArgumentError,
      );

      // Should only be called once since ArgumentError is not retryable
      expect(callCount, 1);
    });
  });
}
