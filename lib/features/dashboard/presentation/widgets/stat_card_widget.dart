import 'package:flutter/material.dart';
import 'dart:math' as math; // Import math for rotation

// Add SingleTickerProviderStateMixin for the counter animation
// Temporarily change to StatelessWidget to disable counter animation
class StatCardWidget extends StatelessWidget {
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
  // State<StatCardWidget> createState() => _StatCardWidgetState(); // Removed for StatelessWidget
  // } // Removed for StatelessWidget
  // class _StatCardWidgetState extends State<StatCardWidget> with SingleTickerProviderStateMixin { // Removed for StatelessWidget
  // bool _isHovering = false; // Keep hover state if needed, manage differently or remove hover effect too
  // Animation related fields removed
  // initState and dispose removed as they were only for the AnimationController
  @override
  Widget build(BuildContext context) {
    // Hover state removed for StatelessWidget test
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;
    const Duration hoverAnimationDuration = Duration(milliseconds: 200);

    // Rotation angle removed for StatelessWidget test

    // Need StatefulWidget + setState for hover, or manage hover state differently
    // For now, let's remove hover effect to simplify testing LCP
    return /*MouseRegion( // Temporarily remove MouseRegion and hover effect
      onEnter: (_) {}, // setState(() => _isHovering = true),
      onExit: (_) {}, // setState(() => _isHovering = false),
      cursor: SystemMouseCursors.click,
      child:*/ AnimatedContainer(
      // Keep AnimatedContainer for potential future hover, but disable effects for now
      duration: hoverAnimationDuration, // Add duration back
      curve: Curves.easeInOut, // Keep curve
      // Combine scale and rotation in the transform
      // Disable hover transform for testing
      transform: Matrix4.identity(), // ..scale(1.0),
      transformAlignment: Alignment.center,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        // Disable hover style changes for testing
        color: Colors.black.withOpacity(0.4),
        borderRadius: BorderRadius.circular(20.0),
        border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
        boxShadow: [], // Disable hover shadow
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 30,
            color: colorScheme.primary,
          ), // Use direct property access
          const SizedBox(height: 8),
          Text(
            title, // Use direct property access
            textAlign: TextAlign.center,
            style: textTheme.titleMedium?.copyWith(
              color: Colors.white.withOpacity(0.8),
            ),
          ),
          const SizedBox(height: 4),
          // Display the value directly, removing AnimatedBuilder
          Text(
            // Attempt to parse, default to '...' or widget.value if parsing fails
            (double.tryParse(value) != null
                ? double.parse(value).toStringAsFixed(0)
                : value), // Use direct property access
            style: textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
      // Commented out closing parenthesis removed
    );
  }
}
