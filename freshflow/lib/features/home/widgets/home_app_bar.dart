import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:vego/core/providers/address_provider.dart';
import 'package:vego/core/providers/wishlist_provider.dart';
import 'package:vego/core/theme/app_colors.dart';
import 'package:vego/features/address/screens/address_management_screen.dart';
import 'package:vego/features/wishlist/screens/wishlist_screen.dart';

/// Home app bar with delivery badge, address, and wishlist button.
/// Extracted from HomeContent for cleaner architecture.
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
          backgroundColor: AppColors.background,
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
              _DeliveryBadge(),
              const SizedBox(width: 8),
              Text(
                'to $addressLabel',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Text(
                addressText,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.secondary,
                ),
              ),
              const Icon(Icons.keyboard_arrow_down,
                  color: AppColors.secondary, size: 18),
            ],
          ),
        ],
      ),
    );
  }
}

class _DeliveryBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.bolt, color: Colors.yellow, size: 14),
          const SizedBox(width: 4),
          Text(
            '10 MINS',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class _WishlistButton extends StatelessWidget {
  final int wishlistCount;

  const _WishlistButton({required this.wishlistCount});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        IconButton(
          icon: const CircleAvatar(
            backgroundColor: Colors.white,
            child: Icon(Icons.favorite_outline, color: AppColors.textDark),
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
            right: 8,
            top: 8,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
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
