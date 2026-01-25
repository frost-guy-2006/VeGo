import 'package:flutter/material.dart';
import 'package:freshflow/core/models/product_model.dart';
import 'package:freshflow/core/theme/app_colors.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:freshflow/core/providers/cart_provider.dart';
import 'package:freshflow/features/cart/widgets/cart_bottom_sheet.dart';
import 'package:freshflow/features/product/screens/product_detail_screen.dart';
import 'package:provider/provider.dart';

class PriceComparisonCard extends StatelessWidget {
  final Product product;

  const PriceComparisonCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => ProductDetailScreen(product: product)),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product Image
                Expanded(
                  flex: 6,
                  child: Hero(
                    tag: 'product-image-${product.id}',
                    child: ClipRRect(
                      borderRadius:
                          const BorderRadius.vertical(top: Radius.circular(16)),
                      child: Image.network(
                        product.imageUrl,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: AppColors.background,
                          child: const Center(
                              child: Icon(Icons.broken_image,
                                  color: AppColors.secondary)),
                        ),
                      ),
                    ),
                  ),
                ),

                // Details
                Expanded(
                  flex: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              product.name,
                              style: GoogleFonts.plusJakartaSans(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                                color: AppColors.textDark,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Harvested at ${product.harvestTime}',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
                                color: AppColors.secondary,
                              ),
                            ),
                          ],
                        ),

                        // Price Block
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '₹${product.currentPrice.toStringAsFixed(0)}',
                              style: GoogleFonts.plusJakartaSans(
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                                color: AppColors.textDark,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 2),
                              child: Text(
                                '₹${product.marketPrice.toStringAsFixed(0)}',
                                style: GoogleFonts.plusJakartaSans(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                  color: AppColors.accent,
                                  decoration: TextDecoration.lineThrough,
                                  decorationColor: AppColors.accent,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // Add Button
            Positioned(
              right: 12,
              top: 130, // Adjust based on image height
              child: Container(
                decoration: BoxDecoration(
                  color: product.stock > 0 ? AppColors.primary : Colors.grey,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color:
                          (product.stock > 0 ? AppColors.primary : Colors.grey)
                              .withValues(alpha: 0.4),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: IconButton(
                  icon: const Icon(Icons.add, color: Colors.white, size: 20),
                  onPressed: product.stock > 0
                      ? () {
                          context.read<CartProvider>().addToCart(product);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('${product.name} added to cart'),
                              duration: const Duration(seconds: 1),
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                            ),
                          );
                        }
                      : null,
                  constraints:
                      const BoxConstraints(minWidth: 40, minHeight: 40),
                ),
              ),
            ),

            // Badge
            Positioned(
              top: 12,
              left: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${product.discountPercent}% OFF',
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                    color: AppColors.accent,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
