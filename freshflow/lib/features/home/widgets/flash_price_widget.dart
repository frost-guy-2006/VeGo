import 'dart:async';
import 'package:flutter/material.dart';
import 'package:vego/core/models/product_model.dart';
import 'package:vego/core/theme/app_colors.dart';
import 'package:vego/features/product/screens/product_detail_screen.dart';
import 'package:google_fonts/google_fonts.dart';

class FlashPriceWidget extends StatefulWidget {
  final Product? product;
  const FlashPriceWidget({super.key, this.product});

  @override
  State<FlashPriceWidget> createState() => _FlashPriceWidgetState();
}

class _FlashPriceWidgetState extends State<FlashPriceWidget> {
  Timer? _timer;
  Duration _timeLeft = const Duration(hours: 4, minutes: 23, seconds: 12);

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeLeft.inSeconds > 0) {
        setState(() {
          _timeLeft = _timeLeft - const Duration(seconds: 1);
        });
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.product == null) return const SizedBox.shrink();
    final product = widget.product!;
    final discount = (product.marketPrice > 0 && product.marketPrice > product.currentPrice)
        ? (((product.marketPrice - product.currentPrice) / product.marketPrice) * 100).round()
        : 0;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProductDetailScreen(product: product),
          ),
        );
      },
      child: SizedBox(
        height: 180,
        width: 320,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // Background Gradient Card
            Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primary, AppColors.flashDark],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'FLASH DEAL',
                    style: GoogleFonts.plusJakartaSans(
                      color: AppColors.accent,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: 160,
                    child: Text(
                      product.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.plusJakartaSans(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                        height: 1.2,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                          color: Colors.white.withValues(alpha: 0.2)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.timer_outlined,
                            color: AppColors.accent, size: 16),
                        const SizedBox(width: 6),
                        Text(
                          '${_timeLeft.inHours.toString().padLeft(2, '0')}:${(_timeLeft.inMinutes % 60).toString().padLeft(2, '0')}:${(_timeLeft.inSeconds % 60).toString().padLeft(2, '0')}',
                          style: GoogleFonts.plusJakartaSans(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Contained Bento Image with integrated discount badge
            Positioned(
              right: 16,
              top: 16,
              bottom: 16,
              child: SizedBox(
                width: 110,
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Hero(
                          tag: 'flash-product-${product.id}',
                          child: Image.network(
                            product.imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Container(
                              color: Colors.white.withValues(alpha: 0.1),
                              child: const Icon(Icons.eco, color: Colors.white70),
                            ),
                          ),
                        ),
                      ),
                    ),
                    if (discount > 0)
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.accent,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.accent.withValues(alpha: 0.4),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Text(
                            '-$discount%',
                            style: GoogleFonts.jetBrainsMono(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
