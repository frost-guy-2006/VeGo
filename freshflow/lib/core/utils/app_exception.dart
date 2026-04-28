import 'dart:io';

enum ErrorType { network, auth, server, validation, notFound, unknown }

class AppException implements Exception {
  final String message;
  final String? userMessage;
  final ErrorType type;
  final int? statusCode;
  final dynamic originalError;

  const AppException({
    required this.message,
    this.userMessage,
    this.type = ErrorType.unknown,
    this.statusCode,
    this.originalError,
  });

  String get displayMessage => userMessage ?? _defaultMessage;

  String get _defaultMessage {
    switch (type) {
      case ErrorType.network:
        return 'No internet connection. Please check your network.';
      case ErrorType.auth:
        return 'Session expired. Please sign in again.';
      case ErrorType.server:
        return 'Something went wrong on our end. Try again shortly.';
      case ErrorType.validation:
        return message;
      case ErrorType.notFound:
        return 'The requested item was not found.';
      case ErrorType.unknown:
        return 'An unexpected error occurred. Please try again.';
    }
  }

  factory AppException.fromError(dynamic error) {
    if (error is SocketException) {
      return AppException(
        message: error.toString(),
        type: ErrorType.network,
        originalError: error,
      );
    }
    if (error is AppException) return error;

    final msg = error.toString();
    if (msg.contains('AuthException') || msg.contains('JWT')) {
      return AppException(
        message: msg,
        type: ErrorType.auth,
        originalError: error,
      );
    }
    if (msg.contains('PostgrestException')) {
      return AppException(
        message: msg,
        type: ErrorType.server,
        originalError: error,
      );
    }
    return AppException(
      message: msg,
      type: ErrorType.unknown,
      originalError: error,
    );
  }

  @override
  String toString() => 'AppException($type): $message';
}
