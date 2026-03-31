import 'package:flutter_test/flutter_test.dart';
import 'package:vego/core/utils/validators.dart';

void main() {
  group('Validators - cleanPhone', () {
    test('removes whitespace', () {
      expect(Validators.cleanPhone('98765 43210'), '9876543210');
      expect(Validators.cleanPhone(' 9876543210 '), '9876543210');
    });

    test('strips +91 prefix', () {
      expect(Validators.cleanPhone('+919876543210'), '9876543210');
      expect(Validators.cleanPhone('+91 98765 43210'), '9876543210');
    });

    test('strips 91 prefix if total length is 12', () {
      expect(Validators.cleanPhone('919876543210'), '9876543210');
    });

    test('does not strip 91 if it is part of the 10 digit number', () {
      // If user enters 9112345678 (10 digits starting with 91)
      expect(Validators.cleanPhone('9112345678'), '9112345678');
    });

    test('handles other cases', () {
      expect(Validators.cleanPhone('123'), '123');
      expect(Validators.cleanPhone(''), '');
    });
  });

  group('Validators - validatePhone', () {
    test('validates 10 digit numbers starting with 6-9', () {
      expect(Validators.validatePhone('9876543210'), null);
      expect(Validators.validatePhone('6000000000'), null);
    });

    test('invalidates numbers starting with 0-5', () {
      // validatePhone uses ^[6-9]
      expect(Validators.validatePhone('5876543210'), isNotNull);
      expect(Validators.validatePhone('0987654321'), isNotNull);
    });

    test('validates numbers with whitespace', () {
      expect(Validators.validatePhone('98765 43210'), null);
    });

    test('validates numbers with +91 prefix', () {
      expect(Validators.validatePhone('+91 98765 43210'), null);
      expect(Validators.validatePhone('+919876543210'), null);
    });

    test('validates numbers with 91 prefix (12 digits)', () {
      expect(Validators.validatePhone('919876543210'), null);
    });

    test('invalidates incorrect lengths', () {
      expect(Validators.validatePhone('987654321'), isNotNull); // 9 digits
      expect(Validators.validatePhone('98765432100'), isNotNull); // 11 digits
    });

    test('invalidates empty or null', () {
       expect(Validators.validatePhone(''), isNotNull);
       expect(Validators.validatePhone(null), isNotNull);
    });
  });
}
