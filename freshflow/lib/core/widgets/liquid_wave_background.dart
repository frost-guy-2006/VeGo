import 'dart:math';
import 'package:flutter/material.dart';
import 'package:vego/core/theme/app_colors.dart';

/// An animated liquid wave background inspired by flowing water over
/// fresh produce. Renders 3 layered sine-wave paths with floating
/// leaf-like particles. Designed for use on auth screens.
class LiquidWaveBackground extends StatefulWidget {
  final Widget child;

  const LiquidWaveBackground({super.key, required this.child});

  @override
  State<LiquidWaveBackground> createState() => _LiquidWaveBackgroundState();
}

class _LiquidWaveBackgroundState extends State<LiquidWaveBackground>
    with TickerProviderStateMixin {
  late final AnimationController _waveController;
  late final AnimationController _particleController;
  late final List<_Particle> _particles;

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();

    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat();

    _particles = List.generate(8, (_) => _Particle.random());
  }

  @override
  void dispose() {
    _waveController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Stack(
      children: [
        // Gradient base
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: isDark
                  ? [AppColors.backgroundDark, const Color(0xFF0D2818)]
                  : [AppColors.background, const Color(0xFFD8F3DC)],
            ),
          ),
        ),

        // Animated waves
        AnimatedBuilder(
          animation: _waveController,
          builder: (context, _) {
            return CustomPaint(
              size: Size.infinite,
              painter: _WavePainter(
                phase: _waveController.value,
                isDark: isDark,
              ),
            );
          },
        ),

        // Floating particles
        AnimatedBuilder(
          animation: _particleController,
          builder: (context, _) {
            return CustomPaint(
              size: Size.infinite,
              painter: _ParticlePainter(
                particles: _particles,
                progress: _particleController.value,
                isDark: isDark,
              ),
            );
          },
        ),

        // Child content
        widget.child,
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Wave Painter — Draws 3 layered sine waves
// ---------------------------------------------------------------------------
class _WavePainter extends CustomPainter {
  final double phase;
  final bool isDark;

  _WavePainter({required this.phase, required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    _drawWave(
      canvas,
      size,
      waveHeight: 35,
      baseY: size.height * 0.70,
      speed: 1.0,
      color: isDark
          ? AppColors.primaryLight.withValues(alpha: 0.08)
          : AppColors.primaryLight.withValues(alpha: 0.12),
    );
    _drawWave(
      canvas,
      size,
      waveHeight: 25,
      baseY: size.height * 0.78,
      speed: 1.4,
      color: isDark
          ? AppColors.primary.withValues(alpha: 0.12)
          : AppColors.primary.withValues(alpha: 0.15),
    );
    _drawWave(
      canvas,
      size,
      waveHeight: 18,
      baseY: size.height * 0.85,
      speed: 0.7,
      color: isDark
          ? AppColors.primaryDark.withValues(alpha: 0.18)
          : AppColors.primaryDark.withValues(alpha: 0.20),
    );
  }

  void _drawWave(
    Canvas canvas,
    Size size, {
    required double waveHeight,
    required double baseY,
    required double speed,
    required Color color,
  }) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(0, size.height);

    for (double x = 0; x <= size.width; x++) {
      final normalizedX = x / size.width;
      final y = baseY +
          sin((normalizedX * 2 * pi) + (phase * 2 * pi * speed)) * waveHeight +
          sin((normalizedX * 4 * pi) + (phase * 2 * pi * speed * 0.6)) *
              (waveHeight * 0.4);
      if (x == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _WavePainter oldDelegate) =>
      oldDelegate.phase != phase;
}

// ---------------------------------------------------------------------------
// Floating Particle — a small drifting dot (leaf-like)
// ---------------------------------------------------------------------------
class _Particle {
  final double startX; // 0..1 normalized
  final double startY; // 0..1 normalized
  final double radius;
  final double speed; // multiplier
  final double drift; // horizontal sway amplitude

  _Particle({
    required this.startX,
    required this.startY,
    required this.radius,
    required this.speed,
    required this.drift,
  });

  factory _Particle.random() {
    final rng = Random();
    return _Particle(
      startX: rng.nextDouble(),
      startY: 0.5 + rng.nextDouble() * 0.5, // bottom half
      radius: 2 + rng.nextDouble() * 3,
      speed: 0.3 + rng.nextDouble() * 0.7,
      drift: 0.02 + rng.nextDouble() * 0.04,
    );
  }
}

class _ParticlePainter extends CustomPainter {
  final List<_Particle> particles;
  final double progress;
  final bool isDark;

  _ParticlePainter({
    required this.particles,
    required this.progress,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = isDark
          ? AppColors.accentGold.withValues(alpha: 0.25)
          : AppColors.accentGold.withValues(alpha: 0.35)
      ..style = PaintingStyle.fill;

    for (final p in particles) {
      // Particle rises from startY to top, wrapping around
      final yProgress = (progress * p.speed) % 1.0;
      final y = size.height * (p.startY - yProgress * p.startY);
      final x = size.width * p.startX +
          sin(progress * 2 * pi * p.speed) * size.width * p.drift;

      // Fade out as particle reaches top
      final fadeAlpha = (1.0 - (1.0 - y / size.height).clamp(0.0, 1.0));
      paint.color = isDark
          ? AppColors.accentGold.withValues(alpha: 0.25 * fadeAlpha)
          : AppColors.accentGold.withValues(alpha: 0.35 * fadeAlpha);

      canvas.drawCircle(Offset(x, y), p.radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _ParticlePainter oldDelegate) => true;
}
