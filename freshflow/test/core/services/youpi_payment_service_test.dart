import 'package:flutter_test/flutter_test.dart';
import 'package:vego/core/services/youpi_payment_service.dart';

void main() {
  group('YouPiPaymentService', () {
    final service = YouPiPaymentService();

    test('generateUpiUri produces valid NPCI compliant UPI deep-link', () {
      final uri = service.generateUpiUri(
        orderId: 'test_order_123',
        amount: 249.50,
        vpa: 'freshflow@upi',
        payeeName: 'FreshFlow',
        note: 'Order test',
      );

      expect(uri, contains('upi://pay?'));
      expect(uri, contains('pa=freshflow@upi'));
      expect(uri, contains('pn=FreshFlow'));
      expect(uri, contains('am=249.50'));
      expect(uri, contains('cu=INR'));
      expect(uri, contains('tr=test_order_123'));
    });

    test('verifyPaymentSimulation returns successful transaction result', () async {
      final result = await service.verifyPaymentSimulation(
        orderId: 'ord_987',
        type: YouPiPaymentType.upiIntent,
        delay: Duration.zero,
      );

      expect(result.isSuccess, isTrue);
      expect(result.transactionId, isNotNull);
      expect(result.paymentType, equals(YouPiPaymentType.upiIntent));
    });

    test('verifyPaymentSimulation handles cash on delivery confirmation', () async {
      final result = await service.verifyPaymentSimulation(
        orderId: 'ord_cod_111',
        type: YouPiPaymentType.cashOnDelivery,
        delay: Duration.zero,
      );

      expect(result.isSuccess, isTrue);
      expect(result.paymentType, equals(YouPiPaymentType.cashOnDelivery));
      expect(result.message, contains('COD Order Confirmed'));
    });
  });
}
