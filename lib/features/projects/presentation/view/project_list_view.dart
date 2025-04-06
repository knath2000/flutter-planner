import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Import Riverpod
// Import Riverpod
import 'package:planner/features/projects/presentation/providers/project_providers.dart'; // Import provider
// Import Project model explicitly
import 'package:flutter_animate/flutter_animate.dart'; // Import flutter_animate
// TaskDetailsView is not directly used here anymore
// import 'package:planner/features/tasks/presentation/view/task_details_view.dart';
import 'package:planner/features/projects/presentation/widgets/project_card_widget.dart';
import 'package:planner/presentation/navigation/app_router.dart'; // Import the router

// Change to ConsumerWidget as we don't need StatefulWidget lifecycle for listening here
class ProjectListView extends ConsumerWidget {
  const ProjectListView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Add WidgetRef
    final theme = Theme.of(context); // Get theme

    // ref.listen removed - SnackBar logic needs to be moved to where add/update is called

    // Watch the new StateNotifierProvider to get the List<Project> directly
    // Watch the StreamProvider to get AsyncValue<List<Project>>
    final projectsAsync = ref.watch(projectListProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text('Projects', style: theme.appBarTheme.titleTextStyle),
        backgroundColor: Colors.transparent, // Kept transparent
        elevation: 0, // Kept elevation 0
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            tooltip: 'Add Project',
            onPressed: () {
              // Use named route for navigation
              Navigator.of(context).pushNamed(AppRouter.addProject);
            },
          ),
        ],
      ),
      // Use the projects list directly, remove .when() wrapper
      // Use .when to handle loading/error/data states from the StreamProvider
      body: projectsAsync.when(
        data: (projects) {
          // Data loaded successfully
          if (projects.isEmpty) {
            return Center(
              child: Text(
                'No projects yet. Add one!',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
            );
          }
          return ListView.builder(
            padding: EdgeInsets.only(
              top: kToolbarHeight + MediaQuery.of(context).padding.top + 10,
              bottom: 20,
              left: 16,
              right: 16,
            ),
            itemCount: projects.length, // Use length from data
            itemBuilder: (context, index) {
              final project = projects[index]; // Get project from data list
              // Wrap card in GestureDetector for navigation AND Animate
              return GestureDetector(
                    onTap: () {
                      // Use named route for navigation, passing project UUID (String)
                      Navigator.of(context).pushNamed(
                        AppRouter.projectDetails,
                        arguments: project.uuid, // Pass the project UUID
                      );
                    },
                    child: ProjectCardWidget(
                      projectUuid: project.uuid, // Pass the project UUID
                      projectName: project.name,
                      // taskCount is fetched inside the widget
                    ),
                  )
                  // Apply entry animation using flutter_animate
                  .animate()
                  .fadeIn(
                    duration: 400.ms,
                    delay: (100 * index).ms,
                  ) // Staggered fade-in
                  .slideY(
                    begin: 0.5,
                    end: 0.0,
                    duration: 400.ms,
                    delay: (100 * index).ms,
                    curve: Curves.easeOut,
                  ); // Staggered slide-up
            },
            physics: const BouncingScrollPhysics(), // Keep bouncing physics
          );
        },
        loading:
            () => const Center(
              child: CircularProgressIndicator(),
            ), // Loading state
        error: (error, stackTrace) {
          // Error state
          print('Error loading projects: $error'); // Log the error
          return Center(
            child: Text(
              'Error loading projects: $error',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
          );
        },
      ), // End body .when()
      // Removed loading: and error: handlers
    );
  }
}
