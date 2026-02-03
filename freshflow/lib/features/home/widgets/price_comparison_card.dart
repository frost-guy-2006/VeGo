import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:vego/core/models/product_model.dart';
import 'package:vego/core/theme/app_colors.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vego/core/providers/cart_provider.dart';
import 'package:vego/core/providers/wishlist_provider.dart';
import 'package:vego/features/product/screens/product_detail_screen.dart';
import 'package:provider/provider.dart';

class PriceComparisonCard extends StatefulWidget {
  final Product product;
  final int index;

  const PriceComparisonCard({
    super.key,
    required this.product,
    this.index = 0,
  });

  @override
  State<PriceComparisonCard> createState() => _PriceComparisonCardState();
}

class _PriceComparisonCardState extends State<PriceComparisonCard>
    with SingleTickerProviderStateMixin {
  bool _isPressed = false;
  late AnimationController _shimmerController;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  int get discountPercent {
    if (widget.product.marketPrice <= 0) return 0;
    return (((widget.product.marketPrice - widget.product.currentPrice) /
                widget.product.marketPrice) *
            100)
        .round();
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: () {
        HapticFeedback.lightImpact();
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => ProductDetailScreen(product: product)),
        );
      },
      child: AnimatedScale(
        scale: _isPressed ? 0.96 : 1.0,
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOutQuint,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: _isPressed
                    ? AppColors.primary.withOpacity(0.15)
                    : Colors.black.withOpacity(0.06),
                blurRadius: _isPressed ? 24 : 16,
                offset: Offset(0, _isPressed ? 8 : 4),
                spreadRadius: _isPressed ? 2 : 0,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product Image with 1:1 aspect ratio
                _buildImageSection(product),

                // Product Details
                _buildDetailsSection(product),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImageSection(Product product) {
    return Stack(
      children: [
        // Image with 1:1 aspect ratio
        AspectRatio(
          aspectRatio: 1.0,
          child: Hero(
            tag: 'product-image-${product.id}',
            child: CachedNetworkImage(
              imageUrl: product.imageUrl,
              fit: BoxFit.cover,
              placeholder: (context, url) => _buildShimmerPlaceholder(),
              errorWidget: (context, url, error) => Container(
                color: AppColors.surfaceAlt,
                child: Center(
                  child: Icon(
                    Icons.image_outlined,
                    color: AppColors.textMuted.withOpacity(0.5),
                    size: 40,
                  ),
                ),
              ),
            ),
          ),
        ),

        // Discount Badge - Pill shape at top-left
        if (discountPercent > 0)
          Positioned(
            top: 10,
            left: 10,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.accentWarm,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.accentWarm.withOpacity(0.4),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                '$discountPercent% OFF',
                style: GoogleFonts.outfit(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: 0.3,
                ),
              ),
            ),
          ),

        // Wishlist Heart - Top right
        Positioned(
          top: 8,
          right: 8,
          child: Consumer<WishlistProvider>(
            builder: (context, wishlist, _) {
              final isWishlisted = wishlist.isInWishlist(product.id);
              return GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  wishlist.toggleWishlist(product);
                },
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    transitionBuilder: (child, animation) => ScaleTransition(
                      scale: animation,
                      child: child,
                    ),
                    child: Icon(
                      isWishlisted ? Icons.favorite : Icons.favorite_outline,
                      key: ValueKey(isWishlisted),
                      size: 18,
                      color:
                          isWishlisted ? AppColors.accent : AppColors.textMuted,
                    ),
                  ),
                ),
              );
            },
          ),
        ),

        // Add to Cart Button - Bottom right of image
        Positioned(
          bottom: -20,
          right: 10,
          child: _buildAddButton(product),
        ),
      ],
    );
  }

  Widget _buildShimmerPlaceholder() {
    return AnimatedBuilder(
      animation: _shimmerController,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment(-1.0 + 2 * _shimmerController.value, 0),
              end: Alignment(1.0 + 2 * _shimmerController.value, 0),
              colors: [
                AppColors.surfaceAlt,
                AppColors.surfaceAlt.withOpacity(0.5),
                AppColors.surfaceAlt,
              ],
              stops: const [0.0, 0.5, 1.0],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAddButton(Product product) {
    final inStock = product.stock > 0;

    return GestureDetector(
      onTap: inStock
          ? () {
              HapticFeedback.mediumImpact();
              context.read<CartProvider>().addToCart(product);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      const Icon(Icons.check_circle,
                          color: Colors.white, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '${product.name} added to cart',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  duration: const Duration(milliseconds: 1200),
                  behavior: SnackBarBehavior.floating,
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  margin: const EdgeInsets.all(16),
                ),
              );
            }
          : null,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          gradient: inStock
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.accent,
                    AppColors.accent.withRed(220),
                  ],
                )
              : null,
          color: inStock ? null : Colors.grey.shade400,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color:
                  (inStock ? AppColors.accent : Colors.grey).withOpacity(0.4),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Icon(
          Icons.add_rounded,
          color: Colors.white,
          size: 22,
        ),
      ),
    );
  }

  Widget _buildDetailsSection(Product product) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 24, 12, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product Name
          Text(
            product.name,
            style: GoogleFonts.outfit(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: AppColors.textDark,
              height: 1.2,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),

          // Harvest time / Description
          Row(
            children: [
              Icon(
                Icons.schedule_rounded,
                size: 12,
                color: AppColors.primary.withOpacity(0.7),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  product.harvestTime,
                  style: GoogleFonts.outfit(
                    fontSize: 11,
                    color: AppColors.textMuted,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Price Row
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '₹${product.currentPrice.toStringAsFixed(0)}',
                style: GoogleFonts.outfit(
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                '₹${product.marketPrice.toStringAsFixed(0)}',
                style: GoogleFonts.outfit(
                  fontWeight: FontWeight.w500,
                  fontSize: 12,
                  color: AppColors.textMuted,
                  decoration: TextDecoration.lineThrough,
                  decorationColor: AppColors.textMuted.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
