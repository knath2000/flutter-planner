import 'package:flutter/material.dart';
import 'dart:math' as math; // For tilt effect
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Import Riverpod
// Import Id type
import 'package:planner/features/tasks/presentation/providers/task_providers.dart'; // Import task providers

// Convert to ConsumerStatefulWidget
class ProjectCardWidget extends ConsumerStatefulWidget {
  final String projectUuid; // Change to projectUuid (String)
  final String projectName;
  // Remove taskCount, will be fetched via provider

  const ProjectCardWidget({
    super.key,
    required this.projectUuid, // Require projectUuid
    required this.projectName,
  });

  @override
  // Update state type
  ConsumerState<ProjectCardWidget> createState() => _ProjectCardWidgetState();
}

// Update state class to extend ConsumerState
class _ProjectCardWidgetState extends ConsumerState<ProjectCardWidget> {
  bool _isHovering = false;
  // bool _isPressed = false; // Removed state for press effect
  static const Duration _animationDuration = Duration(
    milliseconds: 150,
  ); // Faster animation for press/hover

  // Calculate scale based on hover and press state
  // Calculate scale based only on hover state
  double get _scale {
    // if (_isPressed) return 0.98; // Removed press scale effect
    if (_isHovering) return 1.03; // Scale up when hovering
    return 1.0; // Default scale
  }

  // Calculate rotation based only on hover (press shouldn't affect tilt)
  double get _rotationAngle {
    return _isHovering ? -math.pi / 70 : 0.0;
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Hero(
      tag: 'project_card_${widget.projectUuid}', // Use projectUuid for Hero tag
      child: Material(
        type: MaterialType.transparency,
        child: MouseRegion(
          onEnter: (_) => setState(() => _isHovering = true),
          onExit: (_) => setState(() => _isHovering = false),
          cursor: SystemMouseCursors.click,
          // Removed inner GestureDetector that was consuming taps
          // The AnimatedContainer is now the direct child of MouseRegion
          child: AnimatedContainer(
            duration: _animationDuration,
            curve: Curves.easeInOut,
            transform:
                Matrix4.identity()
                  ..setEntry(3, 2, 0.001) // Perspective
                  ..rotateY(_rotationAngle) // Apply rotation
                  ..scale(_scale), // Apply scale based on hover/press
            transformAlignment: Alignment.center,
            margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              // Adjust style slightly on hover/press? Maybe just shadow/scale is enough.
              color:
                  _isHovering
                      ? Colors.white.withOpacity(0.15)
                      : Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16.0),
              border: Border.all(
                color:
                    _isHovering
                        ? Colors.white.withOpacity(0.5)
                        : Colors.white.withOpacity(0.3),
                width: 1,
              ),
              boxShadow:
                  _isHovering
                      ? [
                        BoxShadow(
                          color: Colors.white.withOpacity(0.1),
                          blurRadius: 10,
                          spreadRadius: 1,
                        ),
                      ]
                      : [],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.projectName,
                  style: textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                // Watch the task counts provider directly using ref from ConsumerState
                Builder(
                  // Use Builder to get context if needed, or just watch directly
                  builder: (context) {
                    // Watch the provider (now returns a record directly)
                    final counts = ref.watch(
                      taskCountsForProjectProvider(widget.projectUuid),
                    );
                    // Use .when to handle the AsyncValue states
                    return counts.when(
                      data:
                          (data) => Text(
                            // Access the record fields inside the data callback
                            '${data.completed}/${data.total} Tasks',
                            style: textTheme.bodyMedium?.copyWith(
                              color: Colors.white70,
                            ),
                          ),
                      loading:
                          () => Text(
                            'Loading tasks...', // Show loading state
                            style: textTheme.bodyMedium?.copyWith(
                              color: Colors.white54,
                            ),
                          ),
                      error:
                          (error, stack) => Text(
                            'Error', // Show error state
                            style: textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.error,
                            ),
                          ),
                    );
                  },
                ),
              ],
            ),
          ),
          // Removed closing parenthesis for the inner GestureDetector
        ),
      ),
    );
  }
}
