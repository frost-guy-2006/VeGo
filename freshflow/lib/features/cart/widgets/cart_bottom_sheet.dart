import 'package:flutter/material.dart';
import 'package:vego/features/tracking/screens/tracking_screen.dart';
import 'package:slide_to_act/slide_to_act.dart';
import 'package:vego/core/providers/cart_provider.dart';
import 'package:vego/core/theme/app_colors.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class CartBottomSheet extends StatelessWidget {
  const CartBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag Handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          Expanded(
            child: Consumer<CartProvider>(
              builder: (context, cart, child) {
                if (cart.items.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.shopping_cart_outlined,
                            size: 64, color: context.textSecondary),
                        const SizedBox(height: 16),
                        Text(
                          'Your cart is empty',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 18,
                            color: context.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(24),
                  itemCount: cart.items.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final item = cart.items[index];
                    return Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            item.product.imageUrl,
                            width: 64,
                            height: 64,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Container(
                              width: 64,
                              height: 64,
                              color: Colors.grey[200],
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.product.name,
                                style: GoogleFonts.plusJakartaSans(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: context.textPrimary,
                                ),
                              ),
                              Text(
                                '\$${item.product.currentPrice.toStringAsFixed(2)}',
                                style: GoogleFonts.plusJakartaSans(
                                  color: context.textSecondary,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove_circle_outline),
                              color: context.textSecondary,
                              onPressed: () =>
                                  cart.decreaseQuantity(item.product.id),
                            ),
                            Text(
                              '${item.quantity}',
                              style: GoogleFonts.plusJakartaSans(
                                fontWeight: FontWeight.bold,
                                color: context.textPrimary,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.add_circle_outline),
                              color: AppColors.primary,
                              onPressed: () => cart.addToCart(item.product),
                            ),
                          ],
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ),

          // Checkout Area
          Consumer<CartProvider>(
            builder: (context, cart, child) {
              return Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: context.surfaceColor,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
                child: SafeArea(
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Total',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 18,
                              color: context.textPrimary,
                            ),
                          ),
                          Text(
                            '₹${cart.totalPrice.toStringAsFixed(0)}',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: context.textPrimary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: SlideAction(
                          text: "Slide to Pay",
                          textStyle: GoogleFonts.plusJakartaSans(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          outerColor: AppColors.primary,
                          innerColor: Colors.white,
                          key: const Key('slide_to_pay'),
                          onSubmit: () async {
                            if (cart.items.isNotEmpty) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => const TrackingScreen()),
                              );
                            }
                            return null; // Reset slider
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
