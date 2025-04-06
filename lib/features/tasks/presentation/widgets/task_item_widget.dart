// Keep math if needed elsewhere, remove if not.
import 'package:flutter/material.dart';
import 'package:planner/features/tasks/domain/entities/task.dart'; // Import the new Task entity and TaskStatus enum
import 'package:planner/features/tasks/data/task_repository.dart'; // Import Task repository provider
// Import Task repository

import 'package:flutter_riverpod/flutter_riverpod.dart'; // Import Riverpod
// Import Task providers
// Task providers are not directly needed here anymore for updates/deletes

// Convert to ConsumerWidget for Riverpod interaction
class TaskItemWidget extends ConsumerWidget {
  // Change to ConsumerWidget
  final Task task; // Accept a Task object

  const TaskItemWidget({
    super.key,
    required this.task, // Require the task object
  });

  // No createState needed for ConsumerWidget

  // Remove local state management (_TaskItemWidgetState, initState, _currentStatus)
  static const Duration _animationDuration = Duration(
    milliseconds: 300,
  ); // Keep animation speed if needed by AnimatedSwitcher

  // Helper to get color based on status
  Color _getStatusColor(TaskStatus status, BuildContext context) {
    switch (status) {
      // Use the imported TaskStatus enum
      case TaskStatus.todo:
        return Colors.orangeAccent;
      case TaskStatus.inProgress:
        return Colors.blueAccent; // Assuming inProgress maps to blue
      case TaskStatus.done:
        return Colors.green;
      default:
        return Theme.of(context).colorScheme.secondary;
    }
  }

  // Remove local _toggleStatus method, logic will be inline in onTap

  @override
  // Add override for ConsumerWidget build method
  Widget build(BuildContext context, WidgetRef ref) {
    // Add WidgetRef
    // Get status directly from the task object
    final TaskStatus currentStatus = task.status;
    final Color statusColor = _getStatusColor(currentStatus, context);

    // Removed the Stack, back to AnimatedContainer as the root
    // Define the main content of the task item
    final Widget taskContent = AnimatedContainer(
      duration: _animationDuration,
      curve: Curves.easeInOut,
      // Removed margin here, will be applied by Dismissible's background or padding if needed
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12.0),
        border: Border(
          left: BorderSide(
            color: statusColor, // Animated border color
            width: 4.0,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              task.title, // Use title from task object
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.white,
                decoration:
                    currentStatus ==
                            TaskStatus
                                .done // Use currentStatus from task
                        ? TextDecoration.lineThrough
                        : TextDecoration.none,
                decorationColor: Colors.white70,
              ),
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: () async {
              // Make async
              // Determine the new status
              final newStatus =
                  currentStatus == TaskStatus.done
                      ? TaskStatus
                          .todo // If done, toggle back to todo
                      : TaskStatus.done; // Otherwise, mark as done

              // Create the updated task object
              final updatedTask =
                  Task(
                      projectId: task.projectId,
                      title: task.title,
                      status: newStatus,
                    )
                    ..uuid =
                        task
                            .uuid // Preserve UUID
                    ..createdAt = task.createdAt; // Preserve createdAt

              // Call the repository to update the task
              await ref.read(taskRepositoryProvider).updateTask(updatedTask);
            },
            child: AnimatedSwitcher(
              // Animate icon change
              duration: _animationDuration,
              transitionBuilder: (Widget child, Animation<double> animation) {
                return ScaleTransition(scale: animation, child: child);
              },
              child: Icon(
                // Use Key to help AnimatedSwitcher differentiate icons
                currentStatus == TaskStatus.done
                    ? Icons.check_circle
                    : Icons
                        .radio_button_unchecked, // Use currentStatus from task
                key: ValueKey<TaskStatus>(
                  currentStatus,
                ), // Key based on status from task
                color: statusColor,
              ),
            ),
          ),
        ],
      ),
    );

    // Wrap the content with Dismissible
    return Dismissible(
      key: ValueKey(task.uuid), // Use task UUID for the key
      direction: DismissDirection.endToStart, // Swipe from right to left
      background: Container(
        // REMOVE color property here
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        margin: const EdgeInsets.symmetric(
          vertical: 6.0,
        ), // Match original item margin
        // Apply border radius and color via decoration
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.0),
          color: Colors.redAccent.withOpacity(
            0.8,
          ), // Keep color inside decoration
        ),
        child: const Icon(Icons.delete_sweep_outlined, color: Colors.white),
      ),
      onDismissed: (direction) async {
        // Make async
        // Call delete method in repository using the task's uuid
        // Call the repository to delete the task
        await ref
            .read(taskRepositoryProvider)
            .deleteTaskByUuid(task.projectId, task.uuid);

        // Show simple confirmation SnackBar (Undo removed for now)
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Task "${task.title}" deleted.'),
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
          ),
        );
      },
      child: Padding(
        // Add padding to simulate the margin removed from AnimatedContainer
        padding: const EdgeInsets.symmetric(vertical: 6.0),
        child: taskContent,
      ),
    );
  }
}
