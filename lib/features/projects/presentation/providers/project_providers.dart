import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:planner/features/projects/data/project_repository.dart'; // Import repository
import 'package:planner/features/projects/domain/entities/project.dart';

// 1. StreamProvider watching the repository stream
// This provider automatically handles loading, data, and error states.
final projectListProvider = StreamProvider<List<Project>>((ref) {
  // Watch the stream from the repository
  final repository = ref.watch(projectRepositoryProvider);
  return repository.watchProjects();
});

// 2. Provider for just the count (derived state from the stream provider)
final projectCountProvider = Provider<int>((ref) {
  // Watch the stream provider's state
  final projectListAsyncValue = ref.watch(projectListProvider);

  // Handle loading/error states, return count on success
  return projectListAsyncValue.when(
    data: (projects) => projects.length,
    loading:
        () => 0, // Or return a specific loading indicator if needed elsewhere
    error: (error, stackTrace) {
      print('Error in projectCountProvider: $error');
      return 0; // Or handle error state appropriately
    },
  );
});

// Note: Add/Update/Delete operations should now be called directly on the
// ProjectRepository instance obtained via ref.read(projectRepositoryProvider)
// in the UI layer. The UI will automatically rebuild when the projectListProvider
// stream emits new data due to the changes.
