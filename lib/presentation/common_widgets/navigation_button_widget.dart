import 'dart:ui' show lerpDouble; // For lerpDouble
import 'package:flutter/material.dart';

// Custom GradientTransform for horizontal translation
class _GradientTranslateTransform extends GradientTransform {
  final double dx;

  const _GradientTranslateTransform(this.dx);

  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) {
    return Matrix4.translationValues(dx, 0.0, 0.0);
  }
}

class NavigationButtonWidget extends StatefulWidget {
  final String label;
  final IconData icon;
  final VoidCallback? onPressed; // Allow null for disabled state
  final bool isLoading; // Add isLoading parameter
  final bool isActive; // Add isActive parameter

  const NavigationButtonWidget({
    super.key,
    required this.label,
    required this.icon,
    required this.onPressed,
    this.isLoading = false, // Default to false
    this.isActive = false, // Default to false
  });

  @override
  State<NavigationButtonWidget> createState() => _NavigationButtonWidgetState();
}

class _NavigationButtonWidgetState extends State<NavigationButtonWidget>
    with SingleTickerProviderStateMixin {
  // Add mixin
  bool _isHovering = false;
  bool _isPressed = false;
  static const Duration _animationDuration = Duration(milliseconds: 150);
  late AnimationController
  _highlightController; // Animation controller for highlight
  static const Color _goldColor = Color(0xFFFFD700); // Gold color for highlight

  double get _scale {
    // Disable hover scale if button is active
    if (_isPressed && !widget.isActive) return 0.95;
    if (_isHovering && !widget.isActive) return 1.05;
    return 1.0;
  }

  @override
  void initState() {
    super.initState();
    _highlightController = AnimationController(
      duration: const Duration(seconds: 5), // 5 second cycle
      vsync: this,
    )..repeat(); // Repeat the animation
  }

  @override
  void dispose() {
    _highlightController.dispose(); // Dispose controller
    super.dispose();
  }

  @override
  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    // Define gradient colors based on state (active, hover, default)
    final List<Color> gradientColors;
    if (widget.isActive) {
      gradientColors = [
        colorScheme.primary,
        colorScheme.secondary,
      ]; // Full opacity when active
    } else if (_isHovering) {
      gradientColors = [
        colorScheme.primary.withOpacity(0.95),
        colorScheme.secondary.withOpacity(0.85),
      ]; // Brighter gradient on hover
    } else {
      gradientColors = [
        colorScheme.primary.withOpacity(0.8),
        colorScheme.secondary.withOpacity(0.7),
      ]; // Default gradient
    }

    return MouseRegion(
      // Disable hover effect if active
      onEnter:
          widget.isActive ? null : (_) => setState(() => _isHovering = true),
      onExit:
          widget.isActive ? null : (_) => setState(() => _isHovering = false),
      cursor:
          widget.isLoading || widget.onPressed == null
              ? SystemMouseCursors.basic
              : SystemMouseCursors.click, // Change cursor when loading/disabled
      child: GestureDetector(
        // Disable gestures while loading
        onTapDown:
            widget.isLoading ? null : (_) => setState(() => _isPressed = true),
        onTapUp:
            widget.isLoading
                ? null
                : (_) {
                  setState(() => _isPressed = false);
                  widget.onPressed?.call(); // Use null-aware call
                },
        onTapCancel:
            widget.isLoading ? null : () => setState(() => _isPressed = false),
        child: AnimatedContainer(
          duration: _animationDuration,
          curve: Curves.easeInOut,
          transform: Matrix4.identity()..scale(_scale),
          transformAlignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          decoration: BoxDecoration(
            // Use gradient instead of solid color
            gradient: LinearGradient(
              colors: gradientColors,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(30.0),
            border: Border.all(
              // Make border slightly more opaque when active
              color: colorScheme.onPrimary.withOpacity(
                widget.isActive ? 0.8 : 0.5,
              ),
              width:
                  widget.isActive
                      ? 1.2
                      : 1, // Slightly thicker border when active
            ),
            boxShadow: [
              BoxShadow(
                // Adjust shadow based on active/pressed/hover state
                color: Colors.black.withOpacity(
                  widget.isActive
                      ? 0.35
                      : (_isPressed ? 0.15 : (_isHovering ? 0.3 : 0.2)),
                ),
                blurRadius:
                    widget.isActive
                        ? 6
                        : (_isPressed ? 4 : (_isHovering ? 8 : 5)),
                offset: Offset(
                  0,
                  widget.isActive
                      ? 3
                      : (_isPressed ? 1 : (_isHovering ? 3 : 2)),
                ),
              ),
            ],
          ),
          // Conditionally display loading indicator or button content
          child: ClipRRect(
            // Clip the content to the button's border radius
            borderRadius: BorderRadius.circular(30.0),
            child: AnimatedBuilder(
              // Use AnimatedBuilder for the highlight
              animation: _highlightController,
              builder: (context, child) {
                // Calculate highlight visibility and progress
                final animationValue = _highlightController.value;
                // Highlight sweeps across in the first 1.5 seconds (30% of 5s)
                final double sweepDurationFraction = 0.3;
                final double sweepProgress =
                    (animationValue / sweepDurationFraction).clamp(0.0, 1.0);
                final bool isHighlightVisible =
                    animationValue < sweepDurationFraction;

                return ShaderMask(
                  blendMode:
                      BlendMode.srcATop, // Blend highlight onto the content
                  shaderCallback: (Rect bounds) {
                    if (!isHighlightVisible) {
                      // Return transparent shader when not highlighting
                      return const LinearGradient(
                        colors: [Colors.transparent, Colors.transparent],
                      ).createShader(bounds);
                    }

                    // Calculate translation for the gradient sweep
                    const double highlightWidthFactor =
                        0.3; // Width of the gold highlight
                    final double highlightPixelWidth =
                        bounds.width * highlightWidthFactor;
                    final double startOffset =
                        -highlightPixelWidth; // Start off-screen left
                    final double endOffset =
                        bounds.width; // End off-screen right
                    final double translate =
                        lerpDouble(startOffset, endOffset, sweepProgress)!;

                    // Define the gradient for the highlight sweep
                    return LinearGradient(
                      colors: [
                        Colors.transparent,
                        _goldColor.withOpacity(0.0), // Fade in edge
                        _goldColor.withOpacity(
                          0.5,
                        ), // Gold highlight center (adjust opacity)
                        _goldColor.withOpacity(0.0), // Fade out edge
                        Colors.transparent,
                      ],
                      stops: const [
                        0.0, // Start transparent
                        0.4, // Start fade-in
                        0.5, // Full gold center
                        0.6, // Start fade-out
                        1.0, // End transparent
                      ],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      // Apply translation using custom GradientTransform
                      transform: _GradientTranslateTransform(translate),
                      tileMode: TileMode.clamp,
                    ).createShader(bounds);
                  },
                  child: child, // Apply shader to the original content
                );
              },
              // Original content (loading indicator or icon/text row)
              child:
                  widget.isLoading
                      ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Colors.white, // Keep indicator white
                        ),
                      )
                      : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(widget.icon, color: colorScheme.onPrimary),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              widget.label,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: colorScheme.onPrimary,
                              ),
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
            ),
          ),
        ),
      ),
    );
  }
}
