import 'package:flutter_test/flutter_test.dart';
import 'package:vego/core/utils/input_validators.dart';

void main() {
  group('InputValidators Tests', () {
    // Phone Validation
    test('validatePhone accepts valid 10-digit numbers', () {
      expect(InputValidators.validatePhone('9876543210'), null);
    });

    test('validatePhone accepts numbers with spaces', () {
      expect(InputValidators.validatePhone('987 654 3210'), null);
    });

    test('validatePhone rejects non-10 digits', () {
      expect(InputValidators.validatePhone('123'), 'Enter a valid 10-digit phone number');
      expect(InputValidators.validatePhone('12345678901'), 'Enter a valid 10-digit phone number');
    });

    test('validatePhone accepts numbers with + prefix', () {
       expect(InputValidators.validatePhone('+919876543210'), null);
    });

    // Email Validation
    test('validateEmail accepts valid emails', () {
      expect(InputValidators.validateEmail('test@example.com'), null);
      expect(InputValidators.validateEmail('user.name@domain.co.in'), null);
    });

    test('validateEmail rejects invalid emails', () {
      expect(InputValidators.validateEmail('test@'), 'Enter a valid email address');
      expect(InputValidators.validateEmail('test'), 'Enter a valid email address');
      expect(InputValidators.validateEmail('@example.com'), 'Enter a valid email address');
    });

    // Password Validation
    test('validatePassword enforces strong password', () {
      expect(InputValidators.validatePassword('StrongP@ss1'), null);
      expect(InputValidators.validatePassword('weak'), 'Password must be at least 8 characters');
      expect(InputValidators.validatePassword('nodigitPass'), 'Password must contain at least one number');
      expect(InputValidators.validatePassword('noupper1'), 'Password must contain at least one uppercase letter');
    });

    test('validatePasswordLogin enforces minimum length only', () {
      expect(InputValidators.validatePasswordLogin('password'), null);
      expect(InputValidators.validatePasswordLogin('12345'), 'Password must be at least 6 characters');
    });

    // OTP Validation
    test('validateOtp accepts 6 digits', () {
      expect(InputValidators.validateOtp('123456'), null);
    });

    test('validateOtp rejects invalid length or format', () {
      expect(InputValidators.validateOtp('12345'), 'Enter a valid 6-digit OTP');
      expect(InputValidators.validateOtp('1234567'), 'Enter a valid 6-digit OTP');
      expect(InputValidators.validateOtp('abcdef'), 'Enter a valid 6-digit OTP');
    });

    // Required Validation
    test('validateRequired enforces non-empty', () {
      expect(InputValidators.validateRequired('some text', 'Field'), null);
      expect(InputValidators.validateRequired('', 'Field'), 'Field is required');
      expect(InputValidators.validateRequired('   ', 'Field'), 'Field is required');
      expect(InputValidators.validateRequired(null, 'Field'), 'Field is required');
    });
  });
}
