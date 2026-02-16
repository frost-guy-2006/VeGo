import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:vego/core/models/product_model.dart';
import 'package:vego/core/theme/app_colors.dart';
import 'package:vego/features/home/widgets/price_comparison_card.dart';

/// Product grid sliver with loading, error, and empty states.
/// Supports pagination via external state management.
class ProductGridSliver extends StatelessWidget {
  final List<Product> products;
  final bool isLoading;
  final String? errorMessage;
  final VoidCallback onRetry;
  final VoidCallback onSeedData;

  const ProductGridSliver({
    super.key,
    required this.products,
    required this.isLoading,
    this.errorMessage,
    required this.onRetry,
    required this.onSeedData,
  });

  @override
  Widget build(BuildContext context) {
    // Initial loading state
    if (isLoading && products.isEmpty) {
      return _buildLoadingGrid();
    }

    // Error state
    if (errorMessage != null && products.isEmpty) {
      return _buildErrorState(context);
    }

    // Empty state
    if (products.isEmpty) {
      return _buildEmptyState(context);
    }

    // Products grid
    return SliverMasonryGrid.count(
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        return PriceComparisonCard(
          key: ValueKey(product.id),
          product: product,
          index: index,
        );
      },
    );
  }

  Widget _buildLoadingGrid() {
    return SliverMasonryGrid.count(
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childCount: 4,
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Container(
            height: 240,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        );
      },
    );
  }

  Widget _buildErrorState(BuildContext context) {
    return SliverToBoxAdapter(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                'Error loading products',
                style: GoogleFonts.plusJakartaSans(
                  color: context.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                errorMessage!,
                style: GoogleFonts.plusJakartaSans(
                  color: context.textSecondary,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh, size: 16),
                label: const Text('Retry'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return SliverToBoxAdapter(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            children: [
              const Icon(Icons.shopping_basket_outlined,
                  size: 48, color: Colors.grey),
              const SizedBox(height: 16),
              Text(
                'No products found',
                style: GoogleFonts.plusJakartaSans(
                  color: context.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Try running the seed script.',
                style: GoogleFonts.plusJakartaSans(
                  color: context.textSecondary,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: onSeedData,
                icon: const Icon(Icons.cloud_upload, size: 16),
                label: const Text('Seed Database'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
