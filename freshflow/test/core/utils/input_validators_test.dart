import 'package:flutter_test/flutter_test.dart';
import 'package:vego/core/utils/input_validators.dart';

void main() {
  group('InputValidators Tests', () {
    // ========== Phone Validation ==========
    group('validatePhone', () {
      test('validates correctly formatted phone numbers', () {
        expect(InputValidators.validatePhone('9876543210'), null);
        expect(InputValidators.validatePhone('+919876543210'), null);
        expect(InputValidators.validatePhone(' +91 98765 43210 '), null);
      });

      test('rejects invalid phone numbers', () {
        expect(InputValidators.validatePhone(null), 'Phone number is required');
        expect(InputValidators.validatePhone(''), 'Phone number is required');
        expect(InputValidators.validatePhone('123'), 'Enter a valid 10-digit phone number');
        expect(InputValidators.validatePhone('abcdefghij'), 'Enter a valid 10-digit phone number');
      });
    });

    // ========== Email Validation ==========
    group('validateEmail', () {
      test('validates correct emails', () {
        expect(InputValidators.validateEmail('test@example.com'), null);
        expect(InputValidators.validateEmail('user.name@domain.co.in'), null);
      });

      test('rejects invalid emails', () {
        expect(InputValidators.validateEmail(null), 'Email is required');
        expect(InputValidators.validateEmail(''), 'Email is required');
        expect(InputValidators.validateEmail('plainaddress'), 'Enter a valid email address');
        expect(InputValidators.validateEmail('@example.com'), 'Enter a valid email address');
        expect(InputValidators.validateEmail('user@'), 'Enter a valid email address');
      });
    });

    // ========== Password Validation ==========
    group('validatePassword', () {
      test('validates strong passwords', () {
        expect(InputValidators.validatePassword('Password123'), null);
        expect(InputValidators.validatePassword('Strong@123'), null);
      });

      test('rejects weak passwords', () {
        expect(InputValidators.validatePassword(null), 'Password is required');
        expect(InputValidators.validatePassword('weak'), 'Password must be at least 8 characters');
        expect(InputValidators.validatePassword('password123'), 'Password must contain at least one uppercase letter');
        expect(InputValidators.validatePassword('PASSWORD123'), 'Password must contain at least one lowercase letter');
        expect(InputValidators.validatePassword('Password'), 'Password must contain at least one number');
      });
    });

    // ========== Password Login Validation ==========
    group('validatePasswordLogin', () {
      test('validates password length only', () {
        expect(InputValidators.validatePasswordLogin('123456'), null);
        expect(InputValidators.validatePasswordLogin('password'), null);
      });

      test('rejects short passwords', () {
        expect(InputValidators.validatePasswordLogin(null), 'Password is required');
        expect(InputValidators.validatePasswordLogin('12345'), 'Password must be at least 6 characters');
      });
    });

    // ========== OTP Validation ==========
    group('validateOtp', () {
      test('validates correct OTP', () {
        expect(InputValidators.validateOtp('123456'), null);
      });

      test('rejects invalid OTP', () {
        expect(InputValidators.validateOtp(null), 'OTP is required');
        expect(InputValidators.validateOtp('12345'), 'Enter a valid 6-digit OTP');
        expect(InputValidators.validateOtp('1234567'), 'Enter a valid 6-digit OTP');
        expect(InputValidators.validateOtp('abcdef'), 'Enter a valid 6-digit OTP');
      });
    });

    // ========== Required Field Validation ==========
    group('validateRequired', () {
      test('validates non-empty input', () {
        expect(InputValidators.validateRequired('some text', 'Field'), null);
      });

      test('rejects empty input', () {
        expect(InputValidators.validateRequired(null, 'Field'), 'Field is required');
        expect(InputValidators.validateRequired('', 'Field'), 'Field is required');
        expect(InputValidators.validateRequired('   ', 'Field'), 'Field is required');
      });
    });

    // ========== Pincode Validation ==========
    group('validatePincode', () {
      test('validates correct pincode', () {
        expect(InputValidators.validatePincode('110001'), null);
      });

      test('rejects invalid pincode', () {
        expect(InputValidators.validatePincode(null), 'Pincode is required');
        expect(InputValidators.validatePincode('010001'), 'Enter a valid 6-digit pincode'); // Starts with 0
        expect(InputValidators.validatePincode('12345'), 'Enter a valid 6-digit pincode');
        expect(InputValidators.validatePincode('1234567'), 'Enter a valid 6-digit pincode');
      });
    });
  });
}
