import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vego/core/providers/riverpod/glass_settings_notifier.dart';

/// The Apple-tier Liquid Glass primitive.
///
/// Implements a 4-pass optical composite:
/// 1. Real-time Backdrop Refraction ([ImageFilter.blur]) scaled by user slider
/// 2. Wide Dynamic Range Surface Tint (0.05 Pure Crystal -> 0.78 Dense Frosted)
/// 3. Specular Highlight Rim (Brilliant 1px bevel simulating overhead physical reflection)
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
  final bool enableBlur;

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
    this.enableBlur = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final glassSettings = ref.watch(glassSettingsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final t = glassSettings.transparency; // 0.0 (Pure Crystal) to 1.0 (Dense Frosted)

    // Wide dynamic range: 0.05 (Crystal) to 0.78 (Dense Frosted)
    final blurSigma = customBlur ?? (4.0 + 24.0 * t);
    final surfaceAlpha = customOpacity ??
        (isDark ? (0.05 + 0.73 * t) : (0.12 + 0.73 * t));
    final specularAlpha = (0.75 - 0.55 * t).clamp(0.18, 0.85);

    final surfaceBaseColor = customSurfaceColor ??
        (isDark ? const Color(0xFF14241B) : Colors.white);

    Widget innerCard = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: surfaceBaseColor.withValues(alpha: surfaceAlpha),
        borderRadius: BorderRadius.circular(borderRadius),
        border: showSpecularBorder
            ? Border.all(
                color: isDark
                    ? Colors.white.withValues(alpha: specularAlpha)
                    : Colors.white.withValues(alpha: 0.90),
                width: 1.0,
              )
            : null,
      ),
      child: child,
    );

    Widget content = Container(
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.25 + 0.20 * t)
                : const Color(0xFF0F172A).withValues(alpha: 0.06),
            blurRadius: 16 + 12 * t,
            offset: const Offset(0, 6),
            spreadRadius: -2,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: enableBlur
            ? BackdropFilter(
                filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
                child: innerCard,
              )
            : innerCard,
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
