import 'package:flutter_test/flutter_test.dart';
import 'package:vego/core/utils/input_validators.dart';

void main() {
  group('InputValidators', () {
    // Phone Validation
    test('validatePhone returns null for valid 10-digit number', () {
      expect(InputValidators.validatePhone('1234567890'), null);
    });

    test('validatePhone returns null for valid number with spaces', () {
      expect(InputValidators.validatePhone('123 456 7890'), null);
    });

    test('validatePhone returns null for valid international number', () {
      expect(InputValidators.validatePhone('+911234567890'), null);
    });

    test('validatePhone returns error for empty input', () {
      expect(InputValidators.validatePhone(''), 'Phone number is required');
    });

    test('validatePhone returns error for null input', () {
      expect(InputValidators.validatePhone(null), 'Phone number is required');
    });

    test('validatePhone returns error for invalid length', () {
      expect(InputValidators.validatePhone('123'), 'Enter a valid 10-digit phone number');
    });

    test('validatePhone returns error for non-numeric characters', () {
      expect(InputValidators.validatePhone('12345abcde'), 'Enter a valid 10-digit phone number');
    });

    // Email Validation
    test('validateEmail returns null for valid email', () {
      expect(InputValidators.validateEmail('test@example.com'), null);
    });

    test('validateEmail returns error for invalid email', () {
      expect(InputValidators.validateEmail('invalid-email'), 'Enter a valid email address');
    });

    test('validateEmail returns error for empty input', () {
      expect(InputValidators.validateEmail(''), 'Email is required');
    });

    // Password Validation
    test('validatePassword returns null for strong password', () {
      expect(InputValidators.validatePassword('Password123'), null);
    });

    test('validatePassword returns error for short password', () {
      expect(InputValidators.validatePassword('Pass1'), 'Password must be at least 8 characters');
    });

    test('validatePassword returns error for password without uppercase', () {
      expect(InputValidators.validatePassword('password123'), 'Password must contain at least one uppercase letter');
    });

    test('validatePassword returns error for password without lowercase', () {
      expect(InputValidators.validatePassword('PASSWORD123'), 'Password must contain at least one lowercase letter');
    });

    test('validatePassword returns error for password without number', () {
      expect(InputValidators.validatePassword('Password'), 'Password must contain at least one number');
    });

    // OTP Validation
    test('validateOtp returns null for valid 6-digit OTP', () {
      expect(InputValidators.validateOtp('123456'), null);
    });

    test('validateOtp returns error for invalid length', () {
      expect(InputValidators.validateOtp('12345'), 'Enter a valid 6-digit OTP');
    });

    test('validateOtp returns error for non-numeric input', () {
      expect(InputValidators.validateOtp('12345a'), 'Enter a valid 6-digit OTP');
    });
  });
}
