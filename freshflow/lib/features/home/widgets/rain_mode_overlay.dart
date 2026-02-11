import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class RainModeOverlay extends StatefulWidget {
  final bool isEnabled;
  const RainModeOverlay({super.key, this.isEnabled = false});

  @override
  State<RainModeOverlay> createState() => _RainModeOverlayState();
}

class _RainModeOverlayState extends State<RainModeOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<RainDrop> _drops = [];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();

    // Initialize drops
    for (int i = 0; i < 100; i++) {
      _drops.add(RainDrop(
        x: _random.nextDouble(),
        y: _random.nextDouble(),
        speed: 0.5 + _random.nextDouble() * 0.5,
        length: 0.05 + _random.nextDouble() * 0.05,
      ));
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isEnabled) return const SizedBox.shrink();

    return IgnorePointer(
      child: Stack(
        children: [
          // Dark Tint
          Container(color: Colors.black.withValues(alpha: 0.1)),

          // Rain Animation
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return CustomPaint(
                painter: RainPainter(
                  drops: _drops,
                  progress: _controller.value,
                  random: _random,
                ),
                size: Size.infinite,
              );
            },
          ),

          // Contextual Message
          Positioned(
            top: 130, // Below header
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.blueGrey[900]!.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [
                  BoxShadow(color: Colors.black26, blurRadius: 10)
                ],
              ),
              child: Row(
                children: [
                  const Icon(Icons.cloud, color: Colors.blueAccent, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "It's raining outside 🌧️",
                          style: GoogleFonts.plusJakartaSans(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          "Delivery partners are driving slowly. Slight delays expected.",
                          style: GoogleFonts.plusJakartaSans(
                            color: Colors.white70,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class RainDrop {
  double x;
  double y;
  double speed;
  double length;

  RainDrop(
      {required this.x,
      required this.y,
      required this.speed,
      required this.length});
}

class RainPainter extends CustomPainter {
  final List<RainDrop> drops;
  final double progress;
  final Random random;

  RainPainter({
    required this.drops,
    required this.progress,
    required this.random,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue.withValues(alpha: 0.3)
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;

    for (var drop in drops) {
      // Simulate movement: y increases
      // We use progress just to "tick", but actual position stored in drop object
      // is simpler to handle if we update it.
      // But CustomPainter paint should be stateless ideally if just drawing frame.
      // Let's rely on simple stateless calculation relative to time if possible,
      // or simple mutable update here is practically fine for this visual.

      drop.y += drop.speed * 0.02; // Move down
      if (drop.y > 1.0) {
        drop.y = -drop.length; // Reset to top
        drop.x = random.nextDouble(); // Random new X
      }

      final startX = drop.x * size.width;
      final startY = drop.y * size.height;
      final endX =
          startX - (drop.length * size.height * 0.2); // Slanted slightly
      final endY = startY + (drop.length * size.height);

      canvas.drawLine(Offset(startX, startY), Offset(endX, endY), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
