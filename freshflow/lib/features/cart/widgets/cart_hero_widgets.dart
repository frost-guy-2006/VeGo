import 'package:flutter/material.dart';
import 'package:freshflow/core/theme/app_colors.dart';
import 'package:google_fonts/google_fonts.dart';

class FreeDeliveryProgressBar extends StatelessWidget {
  final double currentTotal;
  final double threshold;

  const FreeDeliveryProgressBar({
    super.key,
    required this.currentTotal,
    this.threshold = 500,
  });

  @override
  Widget build(BuildContext context) {
    // Zepto/Blinkit style: "Add ₹X to unlock Free Delivery"
    // If unlocked: "Free Delivery Unlocked! 🎉"

    final progress = (currentTotal / threshold).clamp(0.0, 1.0);
    final isUnlocked = currentTotal >= threshold;
    final remaining = threshold - currentTotal;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isUnlocked
              ? Colors.green.withOpacity(0.3)
              : Colors.orange.withOpacity(0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isUnlocked
                      ? Colors.green.withOpacity(0.1)
                      : Colors.orange.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isUnlocked ? Icons.check_circle : Icons.local_shipping,
                  color: isUnlocked ? Colors.green : Colors.orange,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isUnlocked
                          ? 'Free Delivery Unlocked!'
                          : 'Add ₹${remaining.toStringAsFixed(0)} for Free Delivery',
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: AppColors.textDark,
                      ),
                    ),
                    if (!isUnlocked)
                      Text(
                        'Save ₹40 on delivery charges',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          color: AppColors.secondary,
                        ),
                      ),
                  ],
                ),
              ),
              if (isUnlocked)
                const Text(
                  '🎉',
                  style: TextStyle(fontSize: 24),
                ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey[100],
              valueColor: AlwaysStoppedAnimation<Color>(
                isUnlocked ? Colors.green : Colors.orange,
              ),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }
}

class SmartSwapWidget extends StatefulWidget {
  final VoidCallback onSwap;

  const SmartSwapWidget({super.key, required this.onSwap});

  @override
  State<SmartSwapWidget> createState() => _SmartSwapWidgetState();
}

class _SmartSwapWidgetState extends State<SmartSwapWidget> {
  bool _isVisible = true;

  @override
  Widget build(BuildContext context) {
    if (!_isVisible) return const SizedBox.shrink();

    return Dismissible(
      key: const Key('swap_card'),
      onDismissed: (_) => setState(() => _isVisible = false),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFF0FDF4), // Light green bg
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.green.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child:
                  const Icon(Icons.swap_horiz, color: Colors.green, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Save ₹20 with this swap!',
                    style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: Colors.green[800],
                    ),
                  ),
                  Text(
                    'Switch to Farm Fresh Tomatoes',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      color: Colors.green[700],
                    ),
                  ),
                ],
              ),
            ),
            TextButton(
              onPressed: widget.onSwap,
              style: TextButton.styleFrom(
                backgroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              child: Text(
                'SWAP',
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: Colors.green,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
