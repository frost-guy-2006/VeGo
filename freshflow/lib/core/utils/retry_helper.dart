import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';

/// Configuration for retry behavior.
class RetryConfig {
  final int maxAttempts;
  final Duration initialDelay;
  final double backoffMultiplier;
  final Duration maxDelay;

  const RetryConfig({
    this.maxAttempts = 3,
    this.initialDelay = const Duration(milliseconds: 500),
    this.backoffMultiplier = 2.0,
    this.maxDelay = const Duration(seconds: 10),
  });
}

/// Utility class for retry logic on network operations.
class RetryHelper {
  /// Default retry configuration.
  static const defaultConfig = RetryConfig();

  /// Execute an async operation with retry logic.
  /// Retries on network errors (SocketException, TimeoutException).
  static Future<T> withRetry<T>(
    Future<T> Function() operation, {
    RetryConfig config = defaultConfig,
    void Function(int attempt, Object error)? onRetry,
  }) async {
    int attempt = 0;
    Duration delay = config.initialDelay;

    while (true) {
      attempt++;
      try {
        return await operation();
      } catch (e) {
        // Only retry on transient network errors
        if (!_isRetryableError(e)) {
          rethrow;
        }

        if (attempt >= config.maxAttempts) {
          rethrow;
        }

        // Log retry attempt
        if (kDebugMode) {
          debugPrint(
              'RetryHelper: Attempt $attempt failed, retrying in ${delay.inMilliseconds}ms...');
        }

        // Call optional callback
        onRetry?.call(attempt, e);

        // Wait before retrying
        await Future.delayed(delay);

        // Calculate next delay with exponential backoff
        delay = Duration(
          milliseconds:
              (delay.inMilliseconds * config.backoffMultiplier).round(),
        );
        if (delay > config.maxDelay) {
          delay = config.maxDelay;
        }
      }
    }
  }

  /// Check if error is retryable (transient network error).
  static bool _isRetryableError(Object error) {
    final errorString = error.toString();
    return error is SocketException ||
        error is TimeoutException ||
        errorString.contains('SocketException') ||
        errorString.contains('TimeoutException') ||
        errorString.contains('Connection refused') ||
        errorString.contains('Connection reset');
  }
}
