import 'package:flutter/material.dart';
import 'package:freshflow/core/providers/cart_provider.dart';
import 'package:freshflow/core/theme/app_colors.dart';
import 'package:freshflow/features/cart/widgets/cart_hero_widgets.dart';
import 'package:freshflow/features/tracking/screens/tracking_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:slide_to_act/slide_to_act.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'My Cart',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.bold,
            color: AppColors.textDark,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: Consumer<CartProvider>(
        builder: (context, cart, child) {
          if (cart.items.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.shopping_cart_outlined,
                      size: 64, color: AppColors.secondary),
                  const SizedBox(height: 16),
                  Text(
                    'Your cart is empty',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 18,
                      color: AppColors.secondary,
                    ),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              // Hero Feature 1: Gamified Delivery Bar
              FreeDeliveryProgressBar(currentTotal: cart.totalPrice),

              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  itemCount:
                      cart.items.length + 1, // +1 for Swap Widget at the bottom
                  separatorBuilder: (_, __) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    // Hero Feature 2: Smart Swap at the end of list
                    if (index == cart.items.length) {
                      return SmartSwapWidget(onSwap: () {
                        // Mock Swap Logic: In real app, replace item.
                        // For now, show a snackbar.
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text('Swapped! You saved ₹20.'),
                          backgroundColor: Colors.green,
                          behavior: SnackBarBehavior.floating,
                          margin: const EdgeInsets.all(20),
                        ));
                      });
                    }

                    final item = cart.items[index];
                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              item.product.imageUrl,
                              width: 80,
                              height: 80,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  Container(
                                width: 80,
                                height: 80,
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
                                    color: AppColors.textDark,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '₹${item.product.currentPrice.toStringAsFixed(0)}',
                                  style: GoogleFonts.plusJakartaSans(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove_circle_outline),
                                color: AppColors.secondary,
                                onPressed: () =>
                                    cart.decreaseQuantity(item.product.id),
                              ),
                              Text(
                                '${item.quantity}',
                                style: GoogleFonts.plusJakartaSans(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: AppColors.textDark,
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
                      ),
                    );
                  },
                ),
              ),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(24)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
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
                              color: AppColors.textDark,
                            ),
                          ),
                          Text(
                            '₹${cart.totalPrice.toStringAsFixed(0)}',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textDark,
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
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
