import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Import Riverpod
// Import Id type
import 'package:planner/features/projects/data/project_repository.dart'; // Import Project repository
import 'package:planner/features/projects/domain/entities/project.dart'; // Import Project entity
// Import Task repository
import 'package:planner/features/tasks/domain/entities/task.dart'; // Import Task entity
import 'package:planner/features/tasks/data/task_repository.dart'; // Import Task repository provider
import 'package:planner/features/tasks/presentation/providers/task_providers.dart'; // Import Task providers
import 'package:planner/features/tasks/presentation/widgets/task_item_widget.dart';

// Consider renaming this view to ProjectDetailsView if it primarily shows project details + tasks
class TaskDetailsView extends ConsumerWidget {
  // Change to ConsumerWidget
  final String projectUuid; // Accept project UUID as String

  const TaskDetailsView({
    super.key,
    required this.projectUuid, // Require projectUuid
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Add WidgetRef
    final theme = Theme.of(context);

    // Fetch the project name asynchronously using the repository by UUID
    final projectFuture = ref
        .watch(projectRepositoryProvider)
        .getProjectByUuid(projectUuid); // Use getProjectByUuid

    // Watch the providers for tasks (now returns List<Task>)
    // Watch the providers which now return AsyncValue<List<Task>>
    final incompleteTasksAsync = ref.watch(
      incompleteTasksProvider(projectUuid),
    );
    final completedTasksAsync = ref.watch(completedTasksProvider(projectUuid));

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Hero(
          tag: 'project_card_$projectUuid', // Use projectUuid in tag
          child: Material(
            type: MaterialType.transparency,
            // Use FutureBuilder to display project name when loaded
            child: FutureBuilder<Project?>(
              future: projectFuture,
              builder: (context, snapshot) {
                final name =
                    snapshot.hasData ? snapshot.data!.name : 'Loading...';
                return Text(name, style: theme.appBarTheme.titleTextStyle);
              },
            ),
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        // Removed IconButton from AppBar, FAB is used instead
      ),
      // Use a Builder to handle the AsyncValue states for both task lists
      // Use .when on both AsyncValues to handle loading/error/data states
      body: incompleteTasksAsync.when(
        data:
            (incompleteTasks) => completedTasksAsync.when(
              data: (completedTasks) {
                // Both lists loaded successfully
                if (incompleteTasks.isEmpty && completedTasks.isEmpty) {
                  return Center(
                    child: Text(
                      'No tasks yet for this project.',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: Colors.white70,
                      ),
                    ),
                  );
                }
                // Pass the actual lists to the helper
                return _buildTaskList(context, incompleteTasks, completedTasks);
              },
              loading:
                  () => const Center(
                    child: CircularProgressIndicator(),
                  ), // Completed tasks loading
              error:
                  (err, stack) => Center(
                    child: Text('Error loading completed tasks: $err'),
                  ), // Completed tasks error
            ),
        loading:
            () => const Center(
              child: CircularProgressIndicator(),
            ), // Incomplete tasks loading
        error:
            (err, stack) => Center(
              child: Text('Error loading incomplete tasks: $err'),
            ), // Incomplete tasks error
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _showAddTaskDialog(context, ref, projectUuid); // Pass projectUuid
        },
        label: const Text('Add Task'),
        icon: const Icon(Icons.add),
      ),
    );
  }

  // Helper method remains largely the same, accepts List<Task>
  Widget _buildTaskList(
    BuildContext context,
    List<Task> incompleteTasks,
    List<Task> completedTasks,
  ) {
    final theme = Theme.of(context);
    List<Widget> listItems = [];

    // Add incomplete tasks
    listItems.addAll(
      incompleteTasks
          .map(
            (task) => TaskItemWidget(
                  key: ValueKey(task.uuid),
                  task: task,
                ) // Use uuid for key
                .animate()
                .fadeIn(duration: 300.ms)
                .slideX(
                  begin: 0.2,
                  end: 0.0,
                  duration: 300.ms,
                  curve: Curves.easeOut,
                ),
          )
          .toList(),
    );

    // Add completed tasks section if needed
    if (completedTasks.isNotEmpty) {
      listItems.add(
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
          child: Divider(height: 1, color: Colors.white24),
        ),
      );
      listItems.add(
        Padding(
          padding: const EdgeInsets.only(left: 8.0, bottom: 8.0),
          child: Text(
            'Completed Tasks',
            style: theme.textTheme.titleMedium?.copyWith(color: Colors.white70),
          ).animate().fadeIn(delay: 100.ms),
        ),
      );
      listItems.addAll(
        completedTasks
            .map(
              (task) => TaskItemWidget(
                    key: ValueKey(task.uuid),
                    task: task,
                  ) // Use uuid for key
                  .animate()
                  .fadeIn(duration: 300.ms)
                  .slideX(
                    begin: 0.2,
                    end: 0.0,
                    duration: 300.ms,
                    curve: Curves.easeOut,
                  ),
            )
            .toList(),
      );
    }

    // Return the ListView
    return ListView.builder(
      padding: EdgeInsets.only(
        top: kToolbarHeight + MediaQuery.of(context).padding.top + 10,
        bottom: 80, // Padding for FAB
        left: 16,
        right: 16,
      ),
      itemCount: listItems.length,
      itemBuilder: (context, index) => listItems[index],
      physics: const BouncingScrollPhysics(),
    );
  }

  // Update dialog function to accept projectUuid (String) and use TaskRepository
  void _showAddTaskDialog(
    BuildContext context,
    WidgetRef ref,
    String projectUuid,
  ) {
    // Accept String projectUuid
    final titleController = TextEditingController();
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            // TODO: Style AlertDialog to match theme
            title: const Text('Add New Task'),
            content: TextField(
              controller: titleController,
              autofocus: true,
              decoration: const InputDecoration(hintText: 'Task title'),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () async {
                  // Make async
                  final title = titleController.text.trim();
                  if (title.isNotEmpty) {
                    // Create Task entity, passing the projectUuid
                    final newTask = Task(projectId: projectUuid, title: title);
                    // Call repository to add task (addTask now only takes the task)
                    // Call the repository directly to add the task
                    await ref.read(taskRepositoryProvider).addTask(newTask);
                    Navigator.pop(context); // Close dialog
                  }
                  // TODO: Add validation feedback if title is empty
                },
                child: const Text('Add'),
              ),
            ],
          ),
    ).then((_) {
      titleController.dispose();
    });
  }
}
