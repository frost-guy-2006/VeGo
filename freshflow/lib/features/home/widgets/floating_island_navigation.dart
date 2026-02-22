import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:vego/core/providers/cart_provider.dart';
import 'package:vego/core/theme/app_colors.dart';

import 'package:vego/features/cart/screens/cart_screen.dart';

class FloatingIslandNavigation extends StatefulWidget {
  final int selectedIndex;
  final Function(int) onIndexChanged;

  const FloatingIslandNavigation({
    super.key,
    required this.selectedIndex,
    required this.onIndexChanged,
  });

  @override
  State<FloatingIslandNavigation> createState() =>
      _FloatingIslandNavigationState();
}

class _FloatingIslandNavigationState extends State<FloatingIslandNavigation> {
  @override
  Widget build(BuildContext context) {
    return Consumer<CartProvider>(
      builder: (context, cart, child) {
        final hasItems = cart.items.isNotEmpty;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOutBack,
          // Adjust width constraint based on state to ensure tight morphing
          // Use constraints to allow it to shrink/grow based on content
          constraints: BoxConstraints(
            minWidth: hasItems ? 280 : 200,
            maxWidth: hasItems ? 340 : 300,
            minHeight: 64,
            maxHeight: 72,
          ),
          margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          decoration: BoxDecoration(
            color: hasItems
                ? (Theme.of(context).brightness == Brightness.dark
                    ? AppColors.primary
                    : Theme.of(context).cardColor.withValues(alpha: 0.85))
                : Theme.of(context).cardColor.withValues(alpha: 0.85),
            borderRadius: BorderRadius.circular(36),
            boxShadow: [
              BoxShadow(
                color: hasItems
                    ? AppColors.primary.withValues(alpha: 0.3)
                    : Colors.black.withValues(alpha: 0.08),
                blurRadius: 24,
                offset: const Offset(0, 8),
                spreadRadius: -2,
              ),
            ],
            border: Border.all(
              color: hasItems
                  ? Colors.transparent
                  : Theme.of(context).dividerColor.withValues(alpha: 0.1),
              width: 1.5,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(36),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (child, animation) {
                  return FadeTransition(
                    opacity: animation,
                    child: ScaleTransition(
                      scale: animation,
                      child: child,
                    ),
                  );
                },
                child: hasItems
                    ? _buildCartMode(context, cart)
                    : _buildNavigationMode(context),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildNavigationMode(BuildContext context) {
    return Row(
      key: const ValueKey('nav_mode'),
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildNavItem(Icons.home_rounded, Icons.home_outlined, 0, 'Home'),
        _buildNavItem(
            Icons.shopping_bag_rounded, Icons.shopping_bag_outlined, 1, 'Cart'),
        _buildNavItem(
            Icons.favorite_rounded, Icons.favorite_outline, 2, 'Wishlist'),
      ],
    );
  }

  Widget _buildCartMode(BuildContext context, CartProvider cart) {
    return GestureDetector(
      key: const ValueKey('cart_mode'),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const CartScreen()),
        );
      },
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Left: Items Count Badge
            Builder(builder: (context) {
              final isDark = Theme.of(context).brightness == Brightness.dark;
              final cartTextColor =
                  isDark ? Colors.white : AppColors.primaryDark;
              return Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.2)
                      : AppColors.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Text(
                      '${cart.items.length}',
                      style: GoogleFonts.outfit(
                        color: cartTextColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(Icons.shopping_bag, color: cartTextColor, size: 16),
                  ],
                ),
              );
            }),

            // Center: Total Price
            Builder(builder: (context) {
              final isDark = Theme.of(context).brightness == Brightness.dark;
              final cartTextColor =
                  isDark ? Colors.white : AppColors.primaryDark;
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Total',
                    style: GoogleFonts.outfit(
                      color: cartTextColor.withValues(alpha: 0.7),
                      fontSize: 10,
                    ),
                  ),
                  Text(
                    '₹${cart.totalPrice.toStringAsFixed(0)}',
                    style: GoogleFonts.outfit(
                      color: cartTextColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              );
            }),

            // Right: Checkout Arrow
            Builder(builder: (context) {
              final isDark = Theme.of(context).brightness == Brightness.dark;
              return Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isDark ? Colors.white : AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.arrow_forward_rounded,
                  color: isDark ? AppColors.primary : Colors.white,
                  size: 20,
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(
      IconData selectedIcon, IconData unselectedIcon, int index, String label) {
    return _FloatingNavItem(
      selectedIcon: selectedIcon,
      unselectedIcon: unselectedIcon,
      isSelected: widget.selectedIndex == index,
      onTap: () => widget.onIndexChanged(index),
    );
  }
}

class _FloatingNavItem extends StatefulWidget {
  final IconData selectedIcon;
  final IconData unselectedIcon;
  final bool isSelected;
  final VoidCallback onTap;

  const _FloatingNavItem({
    required this.selectedIcon,
    required this.unselectedIcon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_FloatingNavItem> createState() => _FloatingNavItemState();
}

class _FloatingNavItemState extends State<_FloatingNavItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150), // Snappier
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.9).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  void handleTap() {
    _controller.forward().then((_) => _controller.reverse());
    widget.onTap();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final activeColor = Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : AppColors.primary;

    return GestureDetector(
      onTap: handleTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ScaleTransition(
              scale: _scaleAnimation,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutBack,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: widget.isSelected
                      ? activeColor.withValues(alpha: 0.1)
                      : Colors.transparent,
                  shape: BoxShape.circle,
                ),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder: (child, animation) {
                    return ScaleTransition(
                      scale: animation,
                      child: FadeTransition(opacity: animation, child: child),
                    );
                  },
                  child: Icon(
                    widget.isSelected
                        ? widget.selectedIcon
                        : widget.unselectedIcon,
                    key: ValueKey(widget.isSelected),
                    color: widget.isSelected
                        ? activeColor
                        : theme.iconTheme.color?.withValues(alpha: 0.6),
                    size: 24,
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
