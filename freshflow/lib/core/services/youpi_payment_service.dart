import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';

enum YouPiPaymentType {
  upiIntent,
  upiQr,
  cashOnDelivery,
}

class YouPiPaymentResult {
  final bool isSuccess;
  final String? transactionId;
  final String? message;
  final YouPiPaymentType paymentType;

  const YouPiPaymentResult({
    required this.isSuccess,
    this.transactionId,
    this.message,
    required this.paymentType,
  });

  factory YouPiPaymentResult.success({
    required String transactionId,
    required YouPiPaymentType paymentType,
    String? message,
  }) {
    return YouPiPaymentResult(
      isSuccess: true,
      transactionId: transactionId,
      message: message ?? 'Payment completed successfully',
      paymentType: paymentType,
    );
  }

  factory YouPiPaymentResult.failed({
    required YouPiPaymentType paymentType,
    required String message,
  }) {
    return YouPiPaymentResult(
      isSuccess: false,
      message: message,
      paymentType: paymentType,
    );
  }

  factory YouPiPaymentResult.cancelled({
    required YouPiPaymentType paymentType,
  }) {
    return YouPiPaymentResult(
      isSuccess: false,
      message: 'Payment was cancelled by the user',
      paymentType: paymentType,
    );
  }
}

/// YouPI-PG Gateway Client Service
/// Implements standard Indian UPI deep linking, dynamic QR generation,
/// and Cash-on-Delivery with sandbox testing verification.
class YouPiPaymentService {
  static final YouPiPaymentService _instance = YouPiPaymentService._internal();
  factory YouPiPaymentService() => _instance;
  YouPiPaymentService._internal();

  /// Default demo VPA (Virtual Payment Address) for showcase
  static const String defaultVpa = 'freshflow@upi';
  static const String defaultPayeeName = 'FreshFlow Quick Commerce';

  /// Generates the standard UPI deep-link URL (NPCI specification)
  String generateUpiUri({
    required String orderId,
    required double amount,
    String vpa = defaultVpa,
    String payeeName = defaultPayeeName,
    String? note,
  }) {
    final formattedAmount = amount.toStringAsFixed(2);
    final txnNote = Uri.encodeComponent(note ?? 'Order #$orderId');
    final encodedName = Uri.encodeComponent(payeeName);

    return 'upi://pay?pa=$vpa&pn=$encodedName&am=$formattedAmount&cu=INR&tr=$orderId&tn=$txnNote';
  }

  /// Launch UPI Intent to native payment apps (GPay, PhonePe, Paytm, CRED, etc.)
  Future<bool> launchUpiApp({
    required String orderId,
    required double amount,
    String vpa = defaultVpa,
    String payeeName = defaultPayeeName,
  }) async {
    final upiUrl = generateUpiUri(
      orderId: orderId,
      amount: amount,
      vpa: vpa,
      payeeName: payeeName,
    );

    final uri = Uri.parse(upiUrl);
    try {
      // Directly trigger externalApplication mode to force Android to display the native UPI chooser
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      if (launched) return true;

      if (await canLaunchUrl(uri)) {
        return await launchUrl(uri, mode: LaunchMode.externalNonBrowserApplication);
      }
      return false;
    } catch (e) {
      debugPrint('YouPI-PG Error launching UPI app: $e');
      try {
        return await launchUrl(uri, mode: LaunchMode.externalNonBrowserApplication);
      } catch (_) {
        return false;
      }
    }
  }

  /// Simulates payment verification in Sandbox / Showcase mode
  Future<YouPiPaymentResult> verifyPaymentSimulation({
    required String orderId,
    required YouPiPaymentType type,
    Duration delay = const Duration(seconds: 2),
  }) async {
    await Future.delayed(delay);
    final mockTxnId = 'YOUPI_TXN_${DateTime.now().millisecondsSinceEpoch}_${orderId.substring(0, orderId.length > 6 ? 6 : orderId.length)}';
    return YouPiPaymentResult.success(
      transactionId: mockTxnId,
      paymentType: type,
      message: type == YouPiPaymentType.cashOnDelivery
          ? 'COD Order Confirmed! Please pay cash at doorstep.'
          : 'UPI Payment Verified via YouPI-PG Gateway!',
    );
  }
}
