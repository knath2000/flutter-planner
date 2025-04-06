import 'package:flutter/material.dart';
import 'dart:math' as math;

class AnimatedBackground extends StatefulWidget {
  const AnimatedBackground({super.key});

  @override
  State<AnimatedBackground> createState() => _AnimatedBackgroundState();
}

class _AnimatedBackgroundState extends State<AnimatedBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  // Define base colors
  final Color _color1 = Colors.indigo[700]!;
  final Color _color2 = Colors.purple[600]!;
  final Color _color3 = Colors.teal[400]!;
  final Color _baseBgColor = Colors.black; // Base background color

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      // Speed up the animation slightly for more dynamism
      duration: const Duration(seconds: 8),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: _BackgroundPainter(
            animationValue: _controller.value,
            color1: _color1,
            color2: _color2,
            color3: _color3,
            baseBgColor: _baseBgColor,
          ),
          child: Container(),
        );
      },
    );
  }
}

class _BackgroundPainter extends CustomPainter {
  final double animationValue;
  final Color color1;
  final Color color2;
  final Color color3;
  final Color baseBgColor;

  _BackgroundPainter({
    required this.animationValue,
    required this.color1,
    required this.color2,
    required this.color3,
    required this.baseBgColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // --- Complex Animated Radial Gradients ---

    // Base background
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), Paint()..color = baseBgColor);

    // Calculate animated properties using sine/cosine for smooth looping
    final double angle1 = animationValue * 2 * math.pi;
    final double angle2 = (animationValue + 0.33) * 2 * math.pi; // Offset phase
    final double angle3 = (animationValue + 0.66) * 2 * math.pi; // Further offset phase

    // Animate centers and radii
    final Offset center1 = Offset(
      size.width * (0.5 + math.cos(angle1) * 0.3),
      size.height * (0.5 + math.sin(angle1) * 0.3),
    );
    final double radius1 = size.width * (0.4 + math.sin(angle1 + math.pi / 2) * 0.15);

    final Offset center2 = Offset(
      size.width * (0.5 + math.cos(angle2) * 0.25),
      size.height * (0.5 + math.sin(angle2) * 0.35),
    );
    final double radius2 = size.width * (0.35 + math.sin(angle2 + math.pi / 3) * 0.1);

     final Offset center3 = Offset(
      size.width * (0.5 + math.cos(angle3) * 0.35),
      size.height * (0.5 + math.sin(angle3) * 0.2),
    );
    final double radius3 = size.width * (0.3 + math.sin(angle3 + math.pi / 4) * 0.12);


    // Define paints for each radial gradient
    final paint1 = Paint()
      ..shader = RadialGradient(
        center: Alignment.lerp(Alignment.topLeft, Alignment.center, math.sin(angle1).abs())!, // Example: Animate center alignment
        radius: 0.8, // Keep radius relatively large
        colors: [color1.withOpacity(0.6), color1.withOpacity(0.0)],
        stops: const [0.0, 1.0],
      ).createShader(Rect.fromCircle(center: center1, radius: math.max(radius1, 1.0))); // Ensure radius is positive

    final paint2 = Paint()
      ..shader = RadialGradient(
        center: Alignment.lerp(Alignment.topRight, Alignment.center, math.cos(angle2).abs())!,
        radius: 0.7,
        colors: [color2.withOpacity(0.5), color2.withOpacity(0.0)],
        stops: const [0.0, 1.0],
      ).createShader(Rect.fromCircle(center: center2, radius: math.max(radius2, 1.0)));

    final paint3 = Paint()
      ..shader = RadialGradient(
        center: Alignment.lerp(Alignment.bottomCenter, Alignment.center, math.sin(angle3).abs())!,
        radius: 0.9,
        colors: [color3.withOpacity(0.55), color3.withOpacity(0.0)],
        stops: const [0.0, 1.0],
      ).createShader(Rect.fromCircle(center: center3, radius: math.max(radius3, 1.0)));


    // Draw the gradients onto the canvas
    // Using BlendMode.plus can create interesting additive light effects
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint1..blendMode = BlendMode.plus);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint2..blendMode = BlendMode.plus);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint3..blendMode = BlendMode.plus);

  }

  @override
  bool shouldRepaint(covariant _BackgroundPainter oldDelegate) {
    // Repaint whenever the animation value changes
    return oldDelegate.animationValue != animationValue;
  }
}