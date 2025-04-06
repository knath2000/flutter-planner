import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:planner/features/tasks/data/task_repository.dart'; // Import repository
import 'package:planner/features/tasks/domain/entities/task.dart';

// 1. StreamProvider watching the repository stream for ALL tasks
final taskListProvider = StreamProvider<List<Task>>((ref) {
  final repository = ref.watch(taskRepositoryProvider);
  return repository.watchAllTasks();
});

// 2. StreamProvider.family to watch tasks filtered by project UUID directly from the repository
final tasksForProjectProvider = StreamProvider.family<List<Task>, String>((
  ref,
  projectUuid,
) {
  final repository = ref.watch(taskRepositoryProvider);
  return repository.watchTasksForProjectUuid(projectUuid);
});

// 3. Provider.family for INCOMPLETE tasks for a specific project (derived from filtered stream)
// Returns AsyncValue<List<Task>>
final incompleteTasksProvider = Provider.family<AsyncValue<List<Task>>, String>(
  (ref, projectUuid) {
    // Watch the filtered stream provider for the project
    final projectTasksAsync = ref.watch(tasksForProjectProvider(projectUuid));

    // Map the AsyncValue state
    return projectTasksAsync.when(
      data:
          (tasks) => AsyncValue.data(
            tasks.where((task) => task.status != TaskStatus.done).toList(),
          ),
      loading: () => const AsyncValue.loading(),
      error: (err, stack) => AsyncValue.error(err, stack),
    );
  },
);

// 4. Provider.family for COMPLETED tasks for a specific project (derived from filtered stream)
// Returns AsyncValue<List<Task>>
final completedTasksProvider = Provider.family<AsyncValue<List<Task>>, String>((
  ref,
  projectUuid,
) {
  // Watch the filtered stream provider for the project
  final projectTasksAsync = ref.watch(tasksForProjectProvider(projectUuid));

  // Map the AsyncValue state
  return projectTasksAsync.when(
    data:
        (tasks) => AsyncValue.data(
          tasks.where((task) => task.status == TaskStatus.done).toList(),
        ),
    loading: () => const AsyncValue.loading(),
    error: (err, stack) => AsyncValue.error(err, stack),
  );
});

// 5. Provider.family for task counts (completed/total) for a specific project (derived)
// Returns AsyncValue<({int completed, int total})>
final taskCountsForProjectProvider = Provider.family<
  AsyncValue<({int completed, int total})>,
  String
>((ref, projectUuid) {
  // Watch the filtered stream provider for the project
  final projectTasksAsync = ref.watch(tasksForProjectProvider(projectUuid));

  // Map the AsyncValue state
  return projectTasksAsync.when(
    data: (tasks) {
      final completedCount =
          tasks.where((task) => task.status == TaskStatus.done).length;
      return AsyncValue.data((completed: completedCount, total: tasks.length));
    },
    loading: () => const AsyncValue.loading(),
    error: (err, stack) => AsyncValue.error(err, stack),
  );
});

// 6. Provider for the count of "due" tasks (not done) across ALL projects (derived)
// Returns AsyncValue<int>
final tasksDueCountProvider = Provider<AsyncValue<int>>((ref) {
  // Watch the main list stream provider
  final allTasksAsync = ref.watch(taskListProvider);

  // Map the AsyncValue state
  return allTasksAsync.when(
    data:
        (tasks) => AsyncValue.data(
          tasks.where((task) => task.status != TaskStatus.done).length,
        ),
    loading: () => const AsyncValue.loading(),
    error: (err, stack) => AsyncValue.error(err, stack),
  );
});

// Note: The TaskListNotifier class is removed.
// Add/Update/Delete operations should now be called directly on the
// TaskRepository instance obtained via ref.read(taskRepositoryProvider)
// in the UI layer. The UI will automatically rebuild when the relevant stream providers
// emit new data due to the changes.
