import 'package:flutter_test/flutter_test.dart';
import 'package:vego/core/utils/input_validators.dart';

void main() {
  group('InputValidators Tests', () {
    test('validatePhone validation', () {
      expect(InputValidators.validatePhone('9876543210'), null);
      expect(InputValidators.validatePhone('+919876543210'), null);
      expect(InputValidators.validatePhone('12345'), 'Enter a valid 10-digit phone number');
      expect(InputValidators.validatePhone(''), 'Phone number is required');
      expect(InputValidators.validatePhone(null), 'Phone number is required');
    });

    test('validateEmail validation', () {
      expect(InputValidators.validateEmail('test@example.com'), null);
      expect(InputValidators.validateEmail('test.name@example.co.uk'), null);
      expect(InputValidators.validateEmail('invalid-email'), 'Enter a valid email address');
      expect(InputValidators.validateEmail(''), 'Email is required');
      expect(InputValidators.validateEmail(null), 'Email is required');
    });

    test('validatePassword validation', () {
      expect(InputValidators.validatePassword('Password123'), null);
      expect(InputValidators.validatePassword('weak'), 'Password must be at least 8 characters');
      expect(InputValidators.validatePassword('onlylowercase1'), 'Password must contain at least one uppercase letter');
      expect(InputValidators.validatePassword('ONLYUPPERCASE1'), 'Password must contain at least one lowercase letter');
      expect(InputValidators.validatePassword('NoNumbersHere'), 'Password must contain at least one number');
      expect(InputValidators.validatePassword(''), 'Password is required');
      expect(InputValidators.validatePassword(null), 'Password is required');
    });

    test('validatePasswordLogin validation', () {
      expect(InputValidators.validatePasswordLogin('password'), null);
      expect(InputValidators.validatePasswordLogin('12345'), 'Password must be at least 6 characters');
      expect(InputValidators.validatePasswordLogin(''), 'Password is required');
      expect(InputValidators.validatePasswordLogin(null), 'Password is required');
    });

    test('validateOtp validation', () {
      expect(InputValidators.validateOtp('123456'), null);
      expect(InputValidators.validateOtp('12345'), 'Enter a valid 6-digit OTP');
      expect(InputValidators.validateOtp('abcdef'), 'Enter a valid 6-digit OTP');
      expect(InputValidators.validateOtp(''), 'OTP is required');
      expect(InputValidators.validateOtp(null), 'OTP is required');
    });
  });
}
