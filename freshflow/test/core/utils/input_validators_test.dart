import 'package:flutter_test/flutter_test.dart';
import 'package:vego/core/utils/input_validators.dart';

void main() {
  group('InputValidators', () {
    group('validatePhone', () {
      test('returns null for valid phone number', () {
        expect(InputValidators.validatePhone('9876543210'), null);
        expect(InputValidators.validatePhone(' 9876543210 '), null);
        expect(InputValidators.validatePhone('+919876543210'), null);
      });

      test('returns error for invalid phone number', () {
        expect(InputValidators.validatePhone(''), 'Phone number is required');
        expect(InputValidators.validatePhone('123'),
            'Enter a valid 10-digit phone number');
        expect(InputValidators.validatePhone('abcdefghij'),
            'Enter a valid 10-digit phone number');
      });
    });

    group('validateEmail', () {
      test('returns null for valid email', () {
        expect(InputValidators.validateEmail('test@example.com'), null);
        expect(InputValidators.validateEmail('user.name+tag@example.co.uk'),
            null);
      });

      test('returns error for invalid email', () {
        expect(InputValidators.validateEmail(''), 'Email is required');
        expect(InputValidators.validateEmail('invalid-email'),
            'Enter a valid email address');
        expect(InputValidators.validateEmail('@example.com'),
            'Enter a valid email address');
      });
    });

    group('validatePassword', () {
      test('returns null for valid password', () {
        expect(InputValidators.validatePassword('Password123'), null);
      });

      test('returns error for invalid password', () {
        expect(InputValidators.validatePassword(''), 'Password is required');
        expect(InputValidators.validatePassword('short'),
            'Password must be at least 8 characters');
        expect(InputValidators.validatePassword('password'),
            'Password must contain at least one uppercase letter');
        expect(InputValidators.validatePassword('password123'),
            'Password must contain at least one uppercase letter');
        expect(InputValidators.validatePassword('PASSWORD123'),
            'Password must contain at least one lowercase letter');
        expect(InputValidators.validatePassword('Password'),
            'Password must contain at least one number');
      });
    });

    group('validatePasswordLogin', () {
        test('returns null for valid login password', () {
            expect(InputValidators.validatePasswordLogin('123456'), null);
        });

        test('returns error for short login password', () {
            expect(InputValidators.validatePasswordLogin('12345'), 'Password must be at least 6 characters');
        });
    });

    group('validateOtp', () {
      test('returns null for valid OTP', () {
        expect(InputValidators.validateOtp('123456'), null);
      });

      test('returns error for invalid OTP', () {
        expect(InputValidators.validateOtp(''), 'OTP is required');
        expect(InputValidators.validateOtp('12345'),
            'Enter a valid 6-digit OTP');
        expect(InputValidators.validateOtp('abcdef'),
            'Enter a valid 6-digit OTP');
      });
    });
  });
}
