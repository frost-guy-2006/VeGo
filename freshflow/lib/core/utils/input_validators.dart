/// Input validation utilities following Security Review skill patterns.
/// Centralizes validation logic for reuse across the app.
class InputValidators {
  InputValidators._();

  // ========== Phone Validation ==========

  /// Validates phone number format.
  /// Returns null if valid, error message if invalid.
  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }

    final cleaned = value.replaceAll(RegExp(r'\s+'), '');

    // Check if it's exactly 10 digits (Indian format without country code)
    if (!RegExp(r'^[0-9]{10}$').hasMatch(cleaned) &&
        !RegExp(r'^\+[0-9]{10,15}$').hasMatch(cleaned)) {
      return 'Enter a valid phone number';
    }

    return null;
  }

  // ========== Email Validation ==========

  /// Validates email format using RFC 5322 compliant regex.
  /// Returns null if valid, error message if invalid.
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }

    // RFC 5322 compliant email regex (simplified)
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
      caseSensitive: false,
    );

    if (!emailRegex.hasMatch(value)) {
      return 'Enter a valid email address';
    }

    return null;
  }

  // ========== Password Validation ==========

  /// Validates password strength.
  /// Returns null if valid, error message if invalid.
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }

    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }

    // Check for at least one uppercase, lowercase, and number
    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return 'Password must contain at least one uppercase letter';
    }

    if (!RegExp(r'[a-z]').hasMatch(value)) {
      return 'Password must contain at least one lowercase letter';
    }

    if (!RegExp(r'[0-9]').hasMatch(value)) {
      return 'Password must contain at least one number';
    }

    return null;
  }

  /// Validates password for login (less strict than sign-up).
  static String? validatePasswordLogin(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }

    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }

    return null;
  }

  // ========== OTP Validation ==========

  /// Validates OTP format (typically 6 digits).
  static String? validateOtp(String? value) {
    if (value == null || value.isEmpty) {
      return 'OTP is required';
    }

    if (!RegExp(r'^[0-9]{6}$').hasMatch(value)) {
      return 'Enter a valid 6-digit OTP';
    }

    return null;
  }

  // ========== Generic Text Validation ==========

  /// Validates required text field.
  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }

    return null;
  }

  /// Validates minimum length.
  static String? validateMinLength(
      String? value, int minLength, String fieldName) {
    if (value == null || value.length < minLength) {
      return '$fieldName must be at least $minLength characters';
    }

    return null;
  }

  /// Validates maximum length.
  static String? validateMaxLength(
      String? value, int maxLength, String fieldName) {
    if (value != null && value.length > maxLength) {
      return '$fieldName cannot exceed $maxLength characters';
    }

    return null;
  }

  // ========== Address Validation ==========

  /// Validates pincode (Indian format - 6 digits).
  static String? validatePincode(String? value) {
    if (value == null || value.isEmpty) {
      return 'Pincode is required';
    }

    if (!RegExp(r'^[1-9][0-9]{5}$').hasMatch(value)) {
      return 'Enter a valid 6-digit pincode';
    }

    return null;
  }
}
