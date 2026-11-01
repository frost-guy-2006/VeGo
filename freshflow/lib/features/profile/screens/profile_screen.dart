import 'package:vego/core/widgets/atmospheric_background.dart';
import 'package:vego/core/widgets/liquid_glass.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vego/core/providers/riverpod/providers.dart';
import 'package:vego/core/theme/app_colors.dart';
import 'package:google_fonts/google_fonts.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Auth state
    final authState = ref.watch(authProvider);
    final user = authState.user;
    final email = user?.email ?? 'user@vego.app';

    // Address state
    final addressState = ref.watch(addressProvider);
    final defaultAddress = addressState.defaultAddress;
    final displayName = defaultAddress?.fullName ?? 'VeGo User';
    final addressText =
        defaultAddress?.formattedAddress ?? 'Add delivery address';
    final displayPhone = (user?.phone?.isNotEmpty ?? false)
        ? user!.phone!
        : defaultAddress?.phoneNumber ?? 'Add phone number';

    // Wishlist state
    final wishlistState = ref.watch(wishlistProvider);

    // Order state
    final orderState = ref.watch(orderProvider);

    // Theme state
    final themeMode = ref.watch(themeProvider);
    final isDarkMode = themeMode == ThemeMode.dark ||
        (themeMode == ThemeMode.system &&
            MediaQuery.of(context).platformBrightness == Brightness.dark);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text(
          'Profile',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.bold,
            color: context.textPrimary,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: AtmosphericBackground(
        child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                  minHeight: constraints.maxHeight - 48), // -48 for padding
              child: IntrinsicHeight(
                child: Column(
                  children: [
                    const SizedBox(height: 24),
                    // Avatar
                    Center(
                      child: CircleAvatar(
                        radius: 50,
                        backgroundColor: AppColors.secondary,
                        child: Text(
                          displayName.isNotEmpty ? displayName[0].toUpperCase() : 'U',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      displayName,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: context.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextButton.icon(
                      onPressed: () => context.push('/profile/edit'),
                      icon: const Icon(Icons.edit_outlined,
                          size: 16, color: AppColors.primary),
                      label: Text(
                        'Edit Profile',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Details Card (Liquid Glass)
                    _buildGlassContainer(
                      context: context,
                      child: Column(
                        children: [
                          _buildProfileRow(
                              context, Icons.email_outlined, 'Email', email),
                          Divider(height: 32, color: context.borderColor),
                          _buildProfileRow(context, Icons.phone_android,
                              'Phone', displayPhone),
                          Divider(height: 32, color: context.borderColor),
                          _buildProfileRow(
                              context,
                              Icons.location_on_outlined,
                              'Address',
                              addressText),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // My Wishlist Button
                    _buildGlassTile(
                      context: context,
                      icon: Icons.favorite,
                      iconColor: AppColors.accent,
                      title: 'My Wishlist',
                      badge: '${wishlistState.itemCount}',
                      badgeColor: AppColors.accent,
                      onTap: () => context.push('/wishlist'),
                    ),

                    const SizedBox(height: 10),

                    // My Orders Button
                    Builder(builder: (context) {
                      final isDark =
                          Theme.of(context).brightness == Brightness.dark;
                      final orderColor =
                          isDark ? AppColors.primaryLight : AppColors.primary;
                      return _buildGlassTile(
                        context: context,
                        icon: Icons.receipt_long,
                        iconColor: orderColor,
                        title: 'My Orders',
                        badge: orderState.activeOrders.isNotEmpty
                            ? '${orderState.activeOrders.length} active'
                            : null,
                        badgeColor: orderColor,
                        onTap: () => context.push('/orders'),
                      );
                    }),

                    const SizedBox(height: 10),

                    // My Addresses Button
                    _buildGlassTile(
                      context: context,
                      icon: Icons.location_on,
                      iconColor: AppColors.accentWarm,
                      title: 'My Addresses',
                      badge: addressState.addressCount > 0
                          ? '${addressState.addressCount}'
                          : null,
                      badgeColor: AppColors.accentWarm,
                      onTap: () => context.push('/addresses'),
                    ),

                    const SizedBox(height: 10),

                    // Dark Mode Toggle
                    Builder(builder: (context) {
                      final isDark =
                          Theme.of(context).brightness == Brightness.dark;
                      final themeColor =
                          isDark ? AppColors.primaryLight : AppColors.primary;
                      return _buildGlassContainer(
                        context: context,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                _buildGradientIcon(
                                  isDarkMode
                                      ? Icons.dark_mode_rounded
                                      : Icons.light_mode_rounded,
                                  themeColor,
                                ),
                                const SizedBox(width: 14),
                                Text(
                                  'Dark Mode',
                                  style: GoogleFonts.outfit(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: context.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                            Switch.adaptive(
                              value: isDarkMode,
                              onChanged: (_) =>
                                  ref.read(themeProvider.notifier).toggleTheme(),
                              activeTrackColor: themeColor,
                            ),
                          ],
                        ),
                      );
                    }),

                                        const SizedBox(height: 14),

                    // Liquid Glass Transparency Slider Control
                    Consumer(
                      builder: (context, ref, _) {
                        final glass = ref.watch(glassSettingsProvider);
                        final pct = (glass.transparency * 100).toInt();
                        String modeName = 'Balanced (Default)';
                        if (glass.transparency < 0.20) {
                          modeName = 'Pure Crystal Glass';
                        } else if (glass.transparency > 0.80) {
                          modeName = 'Dense Frosted Glass';
                        }

                        return _buildGlassContainer(
                          context: context,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      _buildGradientIcon(
                                        Icons.blur_on_rounded,
                                        AppColors.primary,
                                      ),
                                      const SizedBox(width: 14),
                                      Text(
                                        'Liquid Glass',
                                        style: GoogleFonts.outfit(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                          color: context.textPrimary,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Text(
                                    '$pct% $modeName',
                                    style: GoogleFonts.jetBrainsMono(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.neonMint,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              SliderTheme(
                                data: SliderTheme.of(context).copyWith(
                                  activeTrackColor: AppColors.primary,
                                  inactiveTrackColor: context.textSecondary.withValues(alpha: 0.2),
                                  thumbColor: Colors.white,
                                  overlayColor: AppColors.primary.withValues(alpha: 0.2),
                                  trackHeight: 6,
                                ),
                                child: Slider(
                                  value: glass.transparency,
                                  min: 0.0,
                                  max: 1.0,
                                  onChanged: (val) {
                                    ref.read(glassSettingsProvider.notifier).setTransparency(val);
                                  },
                                ),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  _buildPresetPill(
                                    label: 'Pure Glass',
                                    isActive: glass.transparency < 0.20,
                                    onTap: () => ref.read(glassSettingsProvider.notifier).setPureGlass(),
                                  ),
                                  _buildPresetPill(
                                    label: 'Balanced',
                                    isActive: glass.transparency >= 0.20 && glass.transparency <= 0.80,
                                    onTap: () => ref.read(glassSettingsProvider.notifier).setBalanced(),
                                  ),
                                  _buildPresetPill(
                                    label: 'Frosted',
                                    isActive: glass.transparency > 0.80,
                                    onTap: () => ref.read(glassSettingsProvider.notifier).setFrosted(),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),

                    const Spacer(),
                    const SizedBox(height: 24),

                    // Logout Button
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: OutlinedButton(
                        onPressed: () {
                          ref.read(authProvider.notifier).signOut();
                        },
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.red),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Log Out',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          );
        },
      ),
      ),
    );
  }

  Widget _buildProfileRow(
      BuildContext context, IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: context.surfaceAltColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon,
              color: Theme.of(context).brightness == Brightness.dark
                  ? AppColors.primaryLight
                  : AppColors.primary,
              size: 20),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  color: context.textSecondary,
                ),
              ),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  value,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: context.textPrimary,
                    letterSpacing: -0.2,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildGlassTile({
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    required String title,
    String? badge,
    Color? badgeColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: _buildGlassContainer(
        context: context,
        child: Row(
          children: [
            _buildGradientIcon(icon, iconColor),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.outfit(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: context.textPrimary,
                ),
              ),
            ),
            if (badge != null) ...[
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: (badgeColor ?? iconColor).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  badge,
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: badgeColor ?? iconColor,
                  ),
                ),
              ),
              const SizedBox(width: 8),
            ],
            Icon(
              Icons.chevron_right_rounded,
              color: context.textSecondary,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGlassContainer({
    required BuildContext context,
    required Widget child,
  }) {
    return LiquidGlass(
      borderRadius: 16,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      child: child,
    );
  }

  Widget _buildGradientIcon(IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withValues(alpha: 0.15),
            color.withValues(alpha: 0.06),
          ],
        ),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: color.withValues(alpha: 0.1),
        ),
      ),
      child: Icon(icon, color: color, size: 20),
    );
  }
  Widget _buildPresetPill({
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isActive
              ? AppColors.primaryLight.withValues(alpha: 0.25)
              : Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isActive
                ? AppColors.primaryLight
                : Colors.white.withValues(alpha: 0.12),
            width: 1.0,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
            color: isActive ? AppColors.primaryLight : Colors.white70,
          ),
        ),
      ),
    );
  }
}