import 'package:flutter/material.dart';
import 'package:freshflow/core/models/product_model.dart';
import 'package:freshflow/core/providers/cart_provider.dart';
import 'package:freshflow/core/theme/app_colors.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class ProductDetailScreen extends StatelessWidget {
  final Product product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: AppColors.background,
            expandedHeight: 300,
            pinned: true,
            leading: IconButton(
              icon: const CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(Icons.arrow_back, color: AppColors.textDark),
              ),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Hero(
                tag: 'product-image-${product.id}',
                child: Image.network(
                  product.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) =>
                      Container(color: Colors.grey[200]),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              ),
              transform: Matrix4.translationValues(0, -20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title & Harvest Time
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          product.name,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textDark,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: AppColors.primary.withValues(alpha: 0.1)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.schedule,
                                size: 14, color: AppColors.secondary),
                            const SizedBox(width: 4),
                            Text(
                              'Harvested ${product.harvestTime}',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: AppColors.secondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Price Comparison Chart Mock
                  Text(
                    'Price History',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    height: 150,
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        _LocalPriceBar(
                            label: 'Supermarket',
                            price: product.marketPrice,
                            color: AppColors.secondary.withValues(alpha: 0.3),
                            isHigh: true),
                        _LocalPriceBar(
                            label: 'Local Vendor',
                            price: product.marketPrice * 0.9,
                            color: AppColors.secondary.withValues(alpha: 0.3),
                            isHigh: false),
                        _LocalPriceBar(
                            label: 'FreshFlow',
                            price: product.currentPrice,
                            color: AppColors.accent,
                            isHigh: false,
                            isSelected: true),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  Text(
                    'Description',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Freshly sourced directly from local farms. These ${product.name.toLowerCase()} are hand-picked at peak ripeness to ensure maximum flavor and nutrition.',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16,
                      color: AppColors.secondary,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 100), // Spacing for bottom bar
                ],
              ),
            ),
          ),
        ],
      ),

      // Bottom Bar
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: Row(
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Price',
                    style:
                        GoogleFonts.plusJakartaSans(color: AppColors.secondary),
                  ),
                  Text(
                    '₹${product.currentPrice.toStringAsFixed(0)}',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 24),
              Expanded(
                child: SizedBox(
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () {
                      context.read<CartProvider>().addToCart(product);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('${product.name} added to cart'),
                          duration: const Duration(milliseconds: 1500),
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.shopping_bag_outlined),
                        const SizedBox(width: 8),
                        Text(
                          'Add to Cart',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LocalPriceBar extends StatelessWidget {
  final String label;
  final double price;
  final Color color;
  final bool isHigh;
  final bool isSelected;

  const _LocalPriceBar({
    required this.label,
    required this.price,
    required this.color,
    this.isHigh = false,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (isSelected)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            margin: const EdgeInsets.only(bottom: 4),
            decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(8)),
            child: Text(
              'Best Price',
              style: GoogleFonts.plusJakartaSans(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold),
            ),
          ),
        Text(
          '₹${price.toStringAsFixed(0)}',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.bold,
            color: isSelected ? AppColors.textDark : AppColors.secondary,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: 40,
          height: price * 2.5, // Simple scaling
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 10,
            color: AppColors.secondary,
          ),
        ),
      ],
    );
  }
}
