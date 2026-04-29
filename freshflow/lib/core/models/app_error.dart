import 'package:supabase_flutter/supabase_flutter.dart';

/// Unified error model for handling structured errors
/// from Supabase Edge Functions and other backend services.
///
/// All Edge Functions return errors in the format:
/// ```json
/// { "code": "INVALID_INPUT", "message": "Cart is empty", "details": ["At least one item required"] }
/// ```
class AppError implements Exception {
  /// Machine-readable error code (e.g., 'INVALID_INPUT', 'OUT_OF_STOCK')
  final String code;

  /// Human-readable error message
  final String message;

  /// Additional details about the error
  final List<String> details;

  const AppError({
    required this.code,
    required this.message,
    this.details = const [],
  });

  /// Parse from Edge Function JSON response
  factory AppError.fromJson(Map<String, dynamic> json) => AppError(
        code: json['code'] as String? ?? 'UNKNOWN_ERROR',
        message: json['message'] as String? ?? 'An unknown error occurred',
        details: (json['details'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList() ??
            [],
      );

  /// Create a generic network error
  factory AppError.network([String? message]) => AppError(
        code: 'NETWORK_ERROR',
        message: message ??
            'Unable to connect. Please check your internet connection.',
      );

  /// Create a generic unknown error
  factory AppError.unknown([String? message]) => AppError(
        code: 'UNKNOWN_ERROR',
        message: message ?? 'Something went wrong. Please try again.',
      );

  /// Create an authentication error
  factory AppError.auth([String? message]) => AppError(
        code: 'AUTH_ERROR',
        message: message ?? 'Authentication failed. Please sign in again.',
      );

  /// Common error codes as constants for easy comparison
  static const String invalidInput = 'INVALID_INPUT';
  static const String outOfStock = 'OUT_OF_STOCK';
  static const String notFound = 'NOT_FOUND';
  static const String unauthorized = 'UNAUTHORIZED';
  static const String serverError = 'SERVER_ERROR';

  /// Check if the error is a specific type
  bool get isOutOfStock => code == outOfStock;
  bool get isInvalidInput => code == invalidInput;
  bool get isNotFound => code == notFound;
  bool get isUnauthorized => code == unauthorized;

  @override
  String toString() => 'AppError($code): $message';

  /// Convert any caught exception into an [AppError].
  ///
  /// Handles Supabase-specific types (AuthException, PostgrestException,
  /// FunctionException) as well as common Dart exceptions.
  static AppError from(dynamic error) {
    if (error is AppError) return error;

    if (error is AuthException) {
      return AppError(code: unauthorized, message: error.message);
    }

    if (error is PostgrestException) {
      return AppError(
        code: serverError,
        message: error.message,
        details: [if (error.code != null) 'pg_code: ${error.code}'],
      );
    }

    if (error is FunctionException) {
      final body = error.details;
      if (body is Map<String, dynamic> &&
          body.containsKey('code') &&
          body.containsKey('message')) {
        return AppError.fromJson(body);
      }
      return AppError(code: serverError, message: error.toString());
    }

    final msg = error.toString();

    if (msg.contains('SocketException') || msg.contains('NetworkException')) {
      return AppError.network();
    }
    if (msg.contains('TimeoutException')) {
      return const AppError(
        code: 'TIMEOUT',
        message: 'Request timed out. Please try again.',
      );
    }

    return AppError.unknown(
        msg.length > 200 ? '${msg.substring(0, 200)}...' : msg);
  }
}
