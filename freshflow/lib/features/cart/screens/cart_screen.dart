import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vego/core/providers/riverpod/providers.dart';
import 'package:vego/core/theme/app_colors.dart';
import 'package:go_router/go_router.dart';
import 'package:slide_to_act/slide_to_act.dart';
import 'package:vego/core/widgets/delivery_slot_picker.dart';

class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});

  void _showClearConfirmation(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Cart'),
        content: const Text('Are you sure you want to remove all items?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              ref.read(cartProvider.notifier).clearCart();
              Navigator.pop(context);
            },
            child: const Text('Clear', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(cartProvider);
    final hasStockIssue = cart.items.any(
      (item) => item.quantity > item.product.stock,
    );

    return Scaffold(
      backgroundColor: context.backgroundColor,
      appBar: AppBar(
        title: Text(
          'My Cart',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.bold,
            color: context.textPrimary,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded,
              color: context.textPrimary, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (cart.items.isNotEmpty)
            IconButton(
              icon: Icon(Icons.delete_outline_rounded, color: context.textPrimary),
              onPressed: () => _showClearConfirmation(context, ref),
            ),
        ],
      ),
      body: cart.items.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shopping_cart_outlined,
                      size: 64,
                      color: context.textSecondary.withValues(alpha: 0.5)),
                  const SizedBox(height: 16),
                  Text(
                    'Your cart is empty',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: context.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Add some fresh goodies!',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      color: context.textSecondary.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.all(20),
                    itemCount: cart.items.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      final item = cart.items[index];
                      return Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: context.surfaceColor,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.03),
                              blurRadius: 16,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Image.network(
                                item.product.imageUrl,
                                width: 80,
                                height: 80,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    Container(
                                  width: 80,
                                  height: 80,
                                  color: context.surfaceAltColor,
                                  child: Icon(Icons.image_not_supported_outlined,
                                      color: context.textSecondary
                                          .withValues(alpha: 0.5)),
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
                                  const SizedBox(height: 4),
                                  Text(
                                    '₹${item.product.currentPrice.toStringAsFixed(0)}',
                                    style: GoogleFonts.plusJakartaSans(
                                      color: context.textSecondary,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  if (item.quantity > item.product.stock)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 4),
                                      child: Text(
                                        'Only ${item.product.stock} in stock',
                                        style: GoogleFonts.plusJakartaSans(
                                          color: Colors.red,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            Container(
                              decoration: BoxDecoration(
                                color: context.surfaceAltColor,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                    color: context.borderColor
                                        .withValues(alpha: 0.5)),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.remove_rounded,
                                        size: 18),
                                    color: context.textSecondary,
                                    onPressed: () => ref.read(cartProvider.notifier).decreaseQuantity(item.product.id),
                                    constraints: const BoxConstraints(
                                        minWidth: 36, minHeight: 36),
                                    padding: EdgeInsets.zero,
                                  ),
                                  Text(
                                    '${item.quantity}',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontWeight: FontWeight.bold,
                                      color: context.textPrimary,
                                      fontSize: 14,
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.add_rounded, size: 18),
                                    color: AppColors.primary,
                                    onPressed: () => ref.read(cartProvider.notifier).addToCart(item.product),
                                    constraints: const BoxConstraints(
                                        minWidth: 36, minHeight: 36),
                                    padding: EdgeInsets.zero,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                ClipRect(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 16),
                      decoration: BoxDecoration(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? context.surfaceColor.withValues(alpha: 0.7)
                            : Colors.white.withValues(alpha: 0.65),
                        border: Border(
                          top: BorderSide(
                            color: Theme.of(context).brightness == Brightness.dark
                                ? Colors.white.withValues(alpha: 0.08)
                                : Colors.white.withValues(alpha: 0.6),
                          ),
                        ),
                      ),
                      child: SafeArea(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Total',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 16,
                                    color: context.textSecondary,
                                    fontWeight: FontWeight.w600,
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
                            const SizedBox(height: 12),
                            const _DeliverySlotButton(),
                            const SizedBox(height: 16),
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(24),
                                boxShadow: [
                                  BoxShadow(
                                    color:
                                        AppColors.primary.withValues(alpha: 0.25),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: hasStockIssue
                                  ? Container(
                                      width: double.infinity,
                                      height: 48,
                                      decoration: BoxDecoration(
                                        color: Colors.red.withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(24),
                                        border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
                                      ),
                                      child: Center(
                                        child: Text(
                                          'Reduce quantity to checkout',
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.red,
                                          ),
                                        ),
                                      ),
                                    )
                                  : SizedBox(
                                width: double.infinity,
                                height: 48,
                                child: SlideAction(
                                  text: "Slide to Pay",
                                  textStyle: GoogleFonts.plusJakartaSans(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    letterSpacing: 0.5,
                                  ),
                                  outerColor: AppColors.primary,
                                  innerColor: Colors.white,
                                  key: const Key('slide_to_pay'),
                                  borderRadius: 24,
                                  sliderButtonIconSize: 14,
                                  sliderButtonIconPadding: 10,
                                  sliderButtonIcon: const Icon(
                                      Icons.arrow_forward_rounded,
                                      color: AppColors.primary),
                                  onSubmit: () async {
                                    if (cart.items.isNotEmpty) {
                                      // Wait for order creation
                                      final user = ref.read(authProvider).user;
                                      if (user == null) return null;
                                      final address = ref.read(addressProvider).effectiveDeliveryAddress;
                                      final deliveryAddress = address?.formattedAddress ?? 'Unknown';

                                      final order = await ref.read(orderProvider.notifier).createOrder(
                                        cart: cart,
                                        userId: user.id,
                                        deliveryAddress: deliveryAddress,
                                      );
                                      final orderId = order.id;
                                      if (context.mounted) {
                                        ref.read(cartProvider.notifier).clearCart();
                                        context.push('/tracking', extra: orderId);
                                      }
                                    }
                                    return null;
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

class _DeliverySlotButton extends StatefulWidget {
  const _DeliverySlotButton();

  @override
  State<_DeliverySlotButton> createState() => _DeliverySlotButtonState();
}

class _DeliverySlotButtonState extends State<_DeliverySlotButton> {
  DeliverySlot? _slot;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final result = await showDeliverySlotPicker(context);
        if (result != null && mounted) {
          setState(() => _slot = result);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: _slot != null
              ? AppColors.primary.withValues(alpha: 0.08)
              : context.surfaceAltColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _slot != null
                ? AppColors.primary.withValues(alpha: 0.3)
                : context.borderColor.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          children: [
            Icon(
              _slot != null ? Icons.check_circle : Icons.schedule_rounded,
              size: 18,
              color: _slot != null ? AppColors.primary : context.textSecondary,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                _slot?.displayText ?? 'Schedule delivery time',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: _slot != null
                      ? AppColors.primary
                      : context.textSecondary,
                ),
              ),
            ),
            Icon(Icons.chevron_right_rounded,
                size: 18, color: context.textSecondary),
          ],
        ),
      ),
    );
  }
}
