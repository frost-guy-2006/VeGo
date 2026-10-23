import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:vego/core/services/youpi_payment_service.dart';
import 'package:vego/core/theme/app_colors.dart';

class YouPiPaymentSheet extends StatefulWidget {
  final double totalAmount;
  final String orderTempId;
  final String deliveryAddress;

  const YouPiPaymentSheet({
    super.key,
    required this.totalAmount,
    required this.orderTempId,
    required this.deliveryAddress,
  });

  static Future<YouPiPaymentResult?> show(
    BuildContext context, {
    required double totalAmount,
    required String orderTempId,
    required String deliveryAddress,
  }) {
    return showModalBottomSheet<YouPiPaymentResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => YouPiPaymentSheet(
        totalAmount: totalAmount,
        orderTempId: orderTempId,
        deliveryAddress: deliveryAddress,
      ),
    );
  }

  @override
  State<YouPiPaymentSheet> createState() => _YouPiPaymentSheetState();
}

class _YouPiPaymentSheetState extends State<YouPiPaymentSheet> {
  YouPiPaymentType _selectedType = YouPiPaymentType.upiIntent;
  bool _isProcessing = false;
  int _qrCountdown = 300; // 5 minutes QR validity
  Timer? _qrTimer;

  @override
  void initState() {
    super.initState();
    _startQrTimer();
  }

  void _startQrTimer() {
    _qrTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_qrCountdown > 0) {
        if (mounted) setState(() => _qrCountdown--);
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _qrTimer?.cancel();
    super.dispose();
  }

  String _formatTimer(int totalSeconds) {
    final m = (totalSeconds ~/ 60).toString().padLeft(2, '0');
    final s = (totalSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  Future<void> _handlePayment() async {
    setState(() => _isProcessing = true);
    final service = YouPiPaymentService();

    if (_selectedType == YouPiPaymentType.upiIntent) {
      final launched = await service.launchUpiApp(
        orderId: widget.orderTempId,
        amount: widget.totalAmount,
      );

      // If launched on device or running in emulator/web showcase,
      // simulate sandbox verification after a brief delay
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(launched
                ? 'Opening UPI App... Waiting for payment verification'
                : 'No UPI App found. Simulating Sandbox verification...'),
            backgroundColor: AppColors.primary,
          ),
        );
      }
      
      final result = await service.verifyPaymentSimulation(
        orderId: widget.orderTempId,
        type: YouPiPaymentType.upiIntent,
      );

      if (mounted) {
        Navigator.pop(context, result);
      }
    } else if (_selectedType == YouPiPaymentType.upiQr) {
      // Dynamic QR confirmation
      final result = await service.verifyPaymentSimulation(
        orderId: widget.orderTempId,
        type: YouPiPaymentType.upiQr,
      );
      if (mounted) {
        Navigator.pop(context, result);
      }
    } else {
      // Cash on Delivery
      final result = await service.verifyPaymentSimulation(
        orderId: widget.orderTempId,
        type: YouPiPaymentType.cashOnDelivery,
        delay: const Duration(milliseconds: 600),
      );
      if (mounted) {
        Navigator.pop(context, result);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface = isDark ? const Color(0xFF1E2420) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF1C2520);
    final subTextColor = isDark ? Colors.white60 : Colors.black54;

    final upiUri = YouPiPaymentService().generateUpiUri(
      orderId: widget.orderTempId,
      amount: widget.totalAmount,
    );

    return Container(
      decoration: BoxDecoration(
        color: surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 20, offset: Offset(0, -4)),
        ],
      ),
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 48,
              height: 5,
              decoration: BoxDecoration(
                color: isDark ? Colors.white24 : Colors.grey.shade300,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.account_balance_wallet_rounded,
                    color: AppColors.primary, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'YouPI-PG Gateway',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.green.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '0% Fee',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Text(
                      'Direct UPI & Doorstep Cash Verification',
                      style: GoogleFonts.plusJakartaSans(fontSize: 12, color: subTextColor),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const Divider(height: 24),

          // Total amount banner
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary.withValues(alpha: 0.1),
                  AppColors.accent.withValues(alpha: 0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Total Payable',
                        style: GoogleFonts.plusJakartaSans(fontSize: 12, color: subTextColor)),
                    Text(
                      '₹${widget.totalAmount.toStringAsFixed(2)}',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('Order ID',
                        style: GoogleFonts.plusJakartaSans(fontSize: 11, color: subTextColor)),
                    Text(
                      '#${widget.orderTempId.substring(0, widget.orderTempId.length > 8 ? 8 : widget.orderTempId.length)}',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: textColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // Payment option selection
          Text(
            'SELECT PAYMENT METHOD',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.1,
              color: subTextColor,
            ),
          ),
          const SizedBox(height: 10),

          // Option 1: Native UPI Apps
          _buildPaymentOption(
            type: YouPiPaymentType.upiIntent,
            icon: Icons.flash_on_rounded,
            title: 'UPI Apps (GPay, PhonePe, Paytm)',
            subtitle: 'Instant one-tap app authorization',
            badge: 'Fastest',
          ),
          const SizedBox(height: 8),

          // Option 2: Dynamic QR Code
          _buildPaymentOption(
            type: YouPiPaymentType.upiQr,
            icon: Icons.qr_code_scanner_rounded,
            title: 'Scan Dynamic UPI QR',
            subtitle: 'Scan with any UPI camera or app',
          ),
          const SizedBox(height: 8),

          // Option 3: Cash on Delivery
          _buildPaymentOption(
            type: YouPiPaymentType.cashOnDelivery,
            icon: Icons.local_shipping_outlined,
            title: 'Cash on Delivery (COD)',
            subtitle: 'Pay at your doorstep after delivery inspection',
          ),
          const SizedBox(height: 16),

          // If QR code is selected, render live QR view
          if (_selectedType == YouPiPaymentType.upiQr) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? Colors.black26 : Colors.grey.shade50,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: const [
                        BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4)),
                      ],
                    ),
                    child: QrImageView(
                      data: upiUri,
                      version: QrVersions.auto,
                      size: 160.0,
                      eyeStyle: const QrEyeStyle(
                        eyeShape: QrEyeShape.square,
                        color: Color(0xFF1E5E3A),
                      ),
                      dataModuleStyle: const QrDataModuleStyle(
                        dataModuleShape: QrDataModuleShape.square,
                        color: Color(0xFF1E5E3A),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.timer_outlined, size: 14, color: AppColors.accent),
                      const SizedBox(width: 4),
                      Text(
                        'QR Valid for: ${_formatTimer(_qrCountdown)}',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.accent,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'VPA: ${YouPiPaymentService.defaultVpa}',
                    style: GoogleFonts.spaceGrotesk(fontSize: 11, color: subTextColor),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Pay / Confirm Button
          ElevatedButton(
            onPressed: _isProcessing ? null : _handlePayment,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 2,
            ),
            child: _isProcessing
                ? const SizedBox(
                    height: 22,
                    width: 22,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                  )
                : Text(
                    _selectedType == YouPiPaymentType.cashOnDelivery
                        ? 'Confirm Cash on Delivery Order'
                        : _selectedType == YouPiPaymentType.upiQr
                            ? 'Simulate / Verify QR Payment'
                            : 'Pay ₹${widget.totalAmount.toStringAsFixed(2)} via UPI',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.3,
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentOption({
    required YouPiPaymentType type,
    required IconData icon,
    required String title,
    required String subtitle,
    String? badge,
  }) {
    final isSelected = _selectedType == type;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: () => setState(() => _selectedType = type),
      borderRadius: BorderRadius.circular(14),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.1)
              : (isDark ? Colors.white.withValues(alpha: 0.04) : Colors.grey.shade50),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : (isDark ? Colors.white12 : Colors.grey.shade200),
            width: isSelected ? 1.8 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : Colors.grey.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: isSelected ? Colors.white : (isDark ? Colors.white70 : Colors.black87),
                size: 18,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          title,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                            color: isDark ? Colors.white : const Color(0xFF1C2520),
                          ),
                        ),
                      ),
                      if (badge != null) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                          decoration: BoxDecoration(
                            color: AppColors.accent.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            badge,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: AppColors.accent,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  Text(
                    subtitle,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      color: isDark ? Colors.white60 : Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: isSelected ? AppColors.primary : Colors.grey,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
