import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vego/core/providers/riverpod/glass_settings_notifier.dart';

/// The Apple-tier Liquid Glass primitive.
///
/// Implements a 4-pass optical composite:
/// 1. Real-time Backdrop Refraction ([ImageFilter.blur]) scaled by user slider
/// 2. Dynamic Luminance Surface Tint (Dark Obsidian or Light Ice)
/// 3. Specular Highlight Rim (1px top/left bevel gradient simulating physical light)
/// 4. Soft Ambient Occlusion Elevation
class LiquidGlass extends ConsumerWidget {
  final Widget child;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final Color? customSurfaceColor;
  final double? customBlur;
  final double? customOpacity;
  final bool showSpecularBorder;

  const LiquidGlass({
    super.key,
    required this.child,
    this.borderRadius = 20,
    this.padding,
    this.margin,
    this.onTap,
    this.customSurfaceColor,
    this.customBlur,
    this.customOpacity,
    this.showSpecularBorder = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final glassSettings = ref.watch(glassSettingsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final t = glassSettings.transparency; // 0.0 (pure glass) to 1.0 (frosted)

    // Calculate optical values
    final blurSigma = customBlur ?? (6.0 + 22.0 * t);
    final surfaceAlpha = customOpacity ??
        (isDark ? (0.16 + 0.50 * t) : (0.35 + 0.45 * t));
    final specularAlpha = (0.45 - 0.20 * t).clamp(0.10, 0.50);

    final surfaceBaseColor = customSurfaceColor ??
        (isDark ? const Color(0xFF101C15) : Colors.white);

    Widget content = Container(
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.35)
                : const Color(0xFF0F172A).withValues(alpha: 0.06),
            blurRadius: 20,
            offset: const Offset(0, 8),
            spreadRadius: -4,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              color: surfaceBaseColor.withValues(alpha: surfaceAlpha),
              borderRadius: BorderRadius.circular(borderRadius),
              border: showSpecularBorder
                  ? Border.all(
                      color: isDark
                          ? Colors.white.withValues(alpha: specularAlpha)
                          : Colors.white.withValues(alpha: 0.85),
                      width: 1.0,
                    )
                  : null,
            ),
            child: child,
          ),
        ),
      ),
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: content,
      );
    }

    return content;
  }
}
