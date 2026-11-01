import 'package:flutter/material.dart';

/// Renders a hardware-accelerated ambient atmospheric lighting canvas.
///
/// In dark mode, provides deep obsidian with subtle radial mint and emerald
/// light pools so [LiquidGlass] backdrop refraction has optical depth to refract.
/// In light mode, provides luminous morning mist with gentle soft-teal radiance.
class AtmosphericBackground extends StatelessWidget {
  final Widget child;

  const AtmosphericBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Stack(
      children: [
        // Base dark obsidian / light mist fill
        Positioned.fill(
          child: Container(
            color: isDark ? const Color(0xFF090D0B) : const Color(0xFFF4F7F5),
          ),
        ),

        // Ambient lighting pools (IgnorePointer prevents blocking touches)
        Positioned.fill(
          child: IgnorePointer(
            child: isDark ? const _DarkAtmosphere() : const _LightAtmosphere(),
          ),
        ),

        // Screen content
        child,
      ],
    );
  }
}

class _DarkAtmosphere extends StatelessWidget {
  const _DarkAtmosphere();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Top-right soft emerald bloom
        Positioned(
          top: -80,
          right: -60,
          width: 320,
          height: 320,
          child: DecoratedBox(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  const Color(0xFF1B4332).withValues(alpha: 0.45),
                  const Color(0xFF0D281E).withValues(alpha: 0.15),
                  Colors.transparent,
                ],
                stops: const [0.0, 0.55, 1.0],
              ),
            ),
          ),
        ),

        // Mid-left subtle mint aura
        Positioned(
          top: 280,
          left: -80,
          width: 300,
          height: 300,
          child: DecoratedBox(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  const Color(0xFF2D6A4F).withValues(alpha: 0.30),
                  const Color(0xFF1B4332).withValues(alpha: 0.10),
                  Colors.transparent,
                ],
                stops: const [0.0, 0.60, 1.0],
              ),
            ),
          ),
        ),

        // Lower-right jade reflection
        Positioned(
          bottom: 100,
          right: -40,
          width: 260,
          height: 260,
          child: DecoratedBox(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  const Color(0xFF103B2B).withValues(alpha: 0.35),
                  Colors.transparent,
                ],
                stops: const [0.0, 1.0],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _LightAtmosphere extends StatelessWidget {
  const _LightAtmosphere();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          top: -60,
          right: -40,
          width: 280,
          height: 280,
          child: DecoratedBox(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  const Color(0xFFD8F3DC).withValues(alpha: 0.70),
                  Colors.transparent,
                ],
                stops: const [0.0, 1.0],
              ),
            ),
          ),
        ),
        Positioned(
          top: 320,
          left: -60,
          width: 260,
          height: 260,
          child: DecoratedBox(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  const Color(0xFFE8F5E9).withValues(alpha: 0.60),
                  Colors.transparent,
                ],
                stops: const [0.0, 1.0],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
