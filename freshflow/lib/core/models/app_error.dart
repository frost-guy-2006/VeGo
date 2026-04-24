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
        message: message ?? 'Unable to connect. Please check your internet connection.',
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
}
