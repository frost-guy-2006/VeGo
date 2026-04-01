import 'package:flutter_test/flutter_test.dart';
import 'package:vego/core/utils/input_validators.dart';

void main() {
  group('InputValidators Tests', () {
    // ========== Phone Validation ==========
    group('validatePhone', () {
      test('Returns null for valid 10-digit phone number', () {
        expect(InputValidators.validatePhone('9876543210'), null);
      });

      test('Returns null for valid phone number with spaces', () {
        expect(InputValidators.validatePhone('987 654 3210'), null);
      });

      test('Returns null for valid phone number with + and country code', () {
         expect(InputValidators.validatePhone('+919876543210'), null);
      });

      test('Returns error for null', () {
        expect(InputValidators.validatePhone(null), 'Phone number is required');
      });

      test('Returns error for empty string', () {
        expect(InputValidators.validatePhone(''), 'Phone number is required');
      });

      test('Returns error for invalid length', () {
        expect(InputValidators.validatePhone('12345'), 'Enter a valid 10-digit phone number');
        expect(InputValidators.validatePhone('12345678901'), 'Enter a valid 10-digit phone number');
      });

      test('Returns error for non-numeric characters', () {
        expect(InputValidators.validatePhone('abcdefghij'), 'Enter a valid 10-digit phone number');
      });
    });

    // ========== Email Validation ==========
    group('validateEmail', () {
      test('Returns null for valid email', () {
        expect(InputValidators.validateEmail('test@example.com'), null);
        expect(InputValidators.validateEmail('user.name@domain.co.in'), null);
      });

      test('Returns error for null', () {
        expect(InputValidators.validateEmail(null), 'Email is required');
      });

      test('Returns error for empty string', () {
        expect(InputValidators.validateEmail(''), 'Email is required');
      });

      test('Returns error for invalid format', () {
        expect(InputValidators.validateEmail('invalid-email'), 'Enter a valid email address');
        expect(InputValidators.validateEmail('user@'), 'Enter a valid email address');
        expect(InputValidators.validateEmail('@domain.com'), 'Enter a valid email address');
        expect(InputValidators.validateEmail('user@domain'), 'Enter a valid email address');
      });
    });

    // ========== Password Validation ==========
    group('validatePassword', () {
      test('Returns null for valid strong password', () {
        expect(InputValidators.validatePassword('StrongP@ss1'), null);
      });

      test('Returns error for null', () {
        expect(InputValidators.validatePassword(null), 'Password is required');
      });

      test('Returns error for empty string', () {
        expect(InputValidators.validatePassword(''), 'Password is required');
      });

      test('Returns error for short password', () {
        expect(InputValidators.validatePassword('Short1!'), 'Password must be at least 8 characters');
      });

      test('Returns error for missing uppercase', () {
        expect(InputValidators.validatePassword('lowercase1!'), 'Password must contain at least one uppercase letter');
      });

      test('Returns error for missing lowercase', () {
        expect(InputValidators.validatePassword('UPPERCASE1!'), 'Password must contain at least one lowercase letter');
      });

      test('Returns error for missing number', () {
        expect(InputValidators.validatePassword('NoNumber!'), 'Password must contain at least one number');
      });
    });

    group('validatePasswordLogin', () {
      test('Returns null for valid length password', () {
        expect(InputValidators.validatePasswordLogin('password'), null);
      });

      test('Returns error for null', () {
        expect(InputValidators.validatePasswordLogin(null), 'Password is required');
      });

      test('Returns error for empty string', () {
        expect(InputValidators.validatePasswordLogin(''), 'Password is required');
      });

      test('Returns error for very short password', () {
        expect(InputValidators.validatePasswordLogin('12345'), 'Password must be at least 6 characters');
      });
    });

    // ========== OTP Validation ==========
    group('validateOtp', () {
      test('Returns null for valid 6-digit OTP', () {
        expect(InputValidators.validateOtp('123456'), null);
      });

      test('Returns error for null', () {
        expect(InputValidators.validateOtp(null), 'OTP is required');
      });

      test('Returns error for empty string', () {
        expect(InputValidators.validateOtp(''), 'OTP is required');
      });

      test('Returns error for invalid length', () {
        expect(InputValidators.validateOtp('12345'), 'Enter a valid 6-digit OTP');
        expect(InputValidators.validateOtp('1234567'), 'Enter a valid 6-digit OTP');
      });

      test('Returns error for non-numeric characters', () {
        expect(InputValidators.validateOtp('12a456'), 'Enter a valid 6-digit OTP');
      });
    });

    // ========== Generic Text Validation ==========
    group('validateRequired', () {
      test('Returns null for non-empty string', () {
        expect(InputValidators.validateRequired('Some value', 'Field'), null);
      });

      test('Returns error for null', () {
        expect(InputValidators.validateRequired(null, 'Field'), 'Field is required');
      });

      test('Returns error for empty string', () {
        expect(InputValidators.validateRequired('', 'Field'), 'Field is required');
      });

      test('Returns error for whitespace only string', () {
        expect(InputValidators.validateRequired('   ', 'Field'), 'Field is required');
      });
    });

    group('validateMinLength', () {
      test('Returns null for string meeting min length', () {
        expect(InputValidators.validateMinLength('12345', 5, 'Field'), null);
      });

      test('Returns error for string shorter than min length', () {
        expect(InputValidators.validateMinLength('1234', 5, 'Field'), 'Field must be at least 5 characters');
      });
    });

    group('validateMaxLength', () {
      test('Returns null for string within max length', () {
        expect(InputValidators.validateMaxLength('12345', 5, 'Field'), null);
      });

      test('Returns error for string exceeding max length', () {
        expect(InputValidators.validateMaxLength('123456', 5, 'Field'), 'Field cannot exceed 5 characters');
      });
    });

    // ========== Pincode Validation ==========
    group('validatePincode', () {
      test('Returns null for valid 6-digit pincode', () {
        expect(InputValidators.validatePincode('560102'), null);
      });

      test('Returns error for null', () {
        expect(InputValidators.validatePincode(null), 'Pincode is required');
      });

      test('Returns error for empty string', () {
        expect(InputValidators.validatePincode(''), 'Pincode is required');
      });

      test('Returns error for invalid length', () {
        expect(InputValidators.validatePincode('56010'), 'Enter a valid 6-digit pincode');
        expect(InputValidators.validatePincode('5601023'), 'Enter a valid 6-digit pincode');
      });

      test('Returns error for starting with 0', () {
        expect(InputValidators.validatePincode('060102'), 'Enter a valid 6-digit pincode');
      });

      test('Returns error for non-numeric characters', () {
        expect(InputValidators.validatePincode('56010a'), 'Enter a valid 6-digit pincode');
      });
    });
  });
}
