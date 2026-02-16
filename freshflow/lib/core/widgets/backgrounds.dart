import 'package:flutter/material.dart';
import 'package:vego/core/theme/app_colors.dart';

/// A gradient mesh background that creates atmospheric depth
class GradientMeshBackground extends StatelessWidget {
  final Widget child;
  final List<Color>? colors;
  final bool showNoise;

  const GradientMeshBackground({
    super.key,
    required this.child,
    this.colors,
    this.showNoise = false,
  });

  @override
  Widget build(BuildContext context) {
    final gradientColors = colors ??
        [
          context.backgroundColor,
          const Color(0xFFF0FDF4), // Mint whisper
          const Color(0xFFFEF3E2), // Peach cream
        ];

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradientColors,
          stops: const [0.0, 0.5, 1.0],
        ),
      ),
      child: child,
    );
  }
}

/// A decorative blob shape for visual interest
class DecorativeBlob extends StatelessWidget {
  final double size;
  final Color color;
  final double blur;

  const DecorativeBlob({
    super.key,
    this.size = 200,
    this.color = AppColors.primaryLight,
    this.blur = 80,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.3),
            blurRadius: blur,
            spreadRadius: blur / 2,
          ),
        ],
      ),
    );
  }
}

/// Frosted glass effect for cards
class FrostedGlass extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final EdgeInsets? padding;

  const FrostedGlass({
    super.key,
    required this.child,
    this.borderRadius = 20,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: Container(
        padding: padding ?? const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: context.surfaceColor.withValues(alpha: 0.7),
          borderRadius: BorderRadius.circular(borderRadius),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.3),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: child,
      ),
    );
  }
}
