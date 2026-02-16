import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:vego/core/providers/address_provider.dart';
import 'package:vego/core/providers/wishlist_provider.dart';
import 'package:vego/core/theme/app_colors.dart';
import 'package:vego/features/address/screens/address_management_screen.dart';
import 'package:vego/features/wishlist/screens/wishlist_screen.dart';

/// Home app bar with delivery badge, address, and wishlist button.
class HomeAppBar extends StatelessWidget {
  const HomeAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<AddressProvider, WishlistProvider>(
      builder: (context, addressProvider, wishlistProvider, _) {
        final defaultAddress = addressProvider.defaultAddress;
        final addressLabel = defaultAddress?.label ?? 'Home';
        final addressText = defaultAddress != null
            ? '${defaultAddress.city}, ${defaultAddress.state}'
            : 'Add Address';
        final wishlistCount = wishlistProvider.itemCount;

        return SliverAppBar(
          pinned: true,
          floating: true,
          backgroundColor: context.backgroundColor,
          elevation: 0,
          expandedHeight: 90,
          toolbarHeight: 70,
          title: _AddressSection(
            addressLabel: addressLabel,
            addressText: addressText,
          ),
          actions: [
            _WishlistButton(wishlistCount: wishlistCount),
            const SizedBox(width: 16),
          ],
        );
      },
    );
  }
}

class _AddressSection extends StatelessWidget {
  final String addressLabel;
  final String addressText;

  const _AddressSection({
    required this.addressLabel,
    required this.addressText,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const AddressManagementScreen(),
          ),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const _DeliveryBadge(),
              const SizedBox(width: 8),
              Text(
                'to $addressLabel',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: context.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 3),
          Row(
            children: [
              Text(
                addressText,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: context.textSecondary,
                ),
              ),
              Icon(Icons.keyboard_arrow_down,
                  color: context.textSecondary, size: 20),
            ],
          ),
        ],
      ),
    );
  }
}

class _DeliveryBadge extends StatefulWidget {
  const _DeliveryBadge();

  @override
  State<_DeliveryBadge> createState() => _DeliveryBadgeState();
}

class _DeliveryBadgeState extends State<_DeliveryBadge>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.primary,
                AppColors.primaryLight,
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryLight
                    .withValues(alpha: 0.2 + (_pulseAnimation.value * 0.2)),
                blurRadius: 8 + (_pulseAnimation.value * 4),
                offset: const Offset(0, 2),
                spreadRadius: -2,
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.bolt_rounded, color: Colors.yellow, size: 14),
              const SizedBox(width: 4),
              Text(
                '10 MIN',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: 0.6,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _WishlistButton extends StatelessWidget {
  final int wishlistCount;

  const _WishlistButton({required this.wishlistCount});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Stack(
      children: [
        IconButton(
          icon: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.08)
                      : Colors.white.withValues(alpha: 0.55),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.12)
                        : Colors.white.withValues(alpha: 0.5),
                  ),
                ),
                child: Icon(Icons.favorite_outline,
                    color:
                        isDark ? AppColors.primaryLight : context.textPrimary,
                    size: 20),
              ),
            ),
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const WishlistScreen()),
            );
          },
        ),
        if (wishlistCount > 0)
          Positioned(
            right: 6,
            top: 6,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.accent, Color(0xFFFF6B6B)],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.accent.withValues(alpha: 0.4),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                wishlistCount.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
