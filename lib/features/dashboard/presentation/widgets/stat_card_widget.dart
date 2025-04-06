import 'package:flutter/material.dart';
import 'dart:math' as math; // Import math for rotation

// Add SingleTickerProviderStateMixin for the counter animation
class StatCardWidget extends StatefulWidget {
  final String title;
  final String value; // Expecting a string that can be parsed to a number
  final IconData icon;

  const StatCardWidget({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  State<StatCardWidget> createState() => _StatCardWidgetState();
}

// Add SingleTickerProviderStateMixin
class _StatCardWidgetState extends State<StatCardWidget> with SingleTickerProviderStateMixin {
  bool _isHovering = false;
  late AnimationController _counterController;
  late Animation<double> _counterAnimation;

  @override
  void initState() {
    super.initState();
    _counterController = AnimationController(
      duration: const Duration(milliseconds: 800), // Duration for counter animation
      vsync: this,
    );

    // Try parsing the input value, default to 0.0 if parsing fails
    final double endValue = double.tryParse(widget.value) ?? 0.0;

    // Create a Tween animation from 0.0 to the target value
    _counterAnimation = Tween<double>(begin: 0.0, end: endValue).animate(
      CurvedAnimation(parent: _counterController, curve: Curves.easeOut),
    );

    // Start the animation when the widget is initialized
    _counterController.forward();
  }

  @override
  void dispose() {
    _counterController.dispose(); // Dispose counter controller
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;
    const Duration hoverAnimationDuration = Duration(milliseconds: 200);

    // Calculate rotation angle for tilt effect
    final double rotationAngle = _isHovering ? -math.pi / 60 : 0.0; // Small tilt angle on hover

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      cursor: SystemMouseCursors.click,
      child: AnimatedContainer(
        duration: hoverAnimationDuration,
        curve: Curves.easeInOut,
        // Combine scale and rotation in the transform
        transform: Matrix4.identity()
          ..setEntry(3, 2, 0.001) // Add perspective for rotation
          ..rotateY(rotationAngle) // Apply rotation
          ..scale(_isHovering ? 1.05 : 1.0), // Apply scale
        transformAlignment: Alignment.center,
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: _isHovering
              ? Colors.black.withOpacity(0.6)
              : Colors.black.withOpacity(0.4),
          borderRadius: BorderRadius.circular(20.0),
          border: Border.all(
            color: _isHovering
                ? Colors.white.withOpacity(0.4)
                : Colors.white.withOpacity(0.2),
            width: 1,
          ),
          boxShadow: _isHovering ? [
            BoxShadow(
              color: colorScheme.primary.withOpacity(0.3),
              blurRadius: 12,
              spreadRadius: 2,
            )
          ] : [],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(widget.icon, size: 30, color: colorScheme.primary),
            const SizedBox(height: 8),
            Text(
              widget.title,
              textAlign: TextAlign.center,
              style: textTheme.titleMedium?.copyWith(color: Colors.white.withOpacity(0.8)),
            ),
            const SizedBox(height: 4),
            // Use AnimatedBuilder to display the animated counter value
            AnimatedBuilder(
              animation: _counterAnimation,
              builder: (context, child) {
                // Display the animated value, formatted as an integer
                return Text(
                  _counterAnimation.value.toStringAsFixed(0),
                  style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: Colors.white),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}