import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Import Riverpod
import 'package:planner/features/projects/presentation/providers/project_providers.dart';
import 'package:planner/features/tasks/presentation/providers/task_providers.dart'; // Import task providers
import 'package:planner/features/dashboard/presentation/widgets/stat_card_widget.dart';
import 'package:planner/presentation/common_widgets/navigation_button_widget.dart';
import 'package:planner/presentation/navigation/app_router.dart'; // Import the router

class DashboardView extends ConsumerWidget {
  // Change to ConsumerWidget
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Add WidgetRef
    // Watch the count providers, which now return direct int values
    final projectCount = ref.watch(projectCountProvider);
    final tasksDueCount = ref.watch(
      tasksDueCountProvider,
    ); // Assuming this is also refactored

    // Get screen size for potential responsive adjustments later
    // final screenSize = MediaQuery.of(context).size;
    // Get safe area padding
    final safePadding = MediaQuery.of(context).padding;

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        // Apply theme's titleTextStyle
        title: Text(
          'Dashboard',
          style: Theme.of(context).appBarTheme.titleTextStyle,
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        // TODO: Implement custom AppBar styling later
      ),
      // Body no longer needs Stack or AnimatedBackground, provided by the shell
      body: SafeArea(
        // Assign SafeArea directly to body
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 20.0,
          ), // Horizontal padding
          child: Column(
            children: [
              // Add padding at the top equivalent to AppBar height + some space
              SizedBox(height: kToolbarHeight + safePadding.top + 20),

              // Row for Stat Cards near the top
              Row(
                // Remove const here
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Use Expanded or fixed width if needed for responsiveness
                  // TODO: Get active projects count from Riverpod provider
                  // Handle AsyncValue for project count
                  Expanded(
                    // Use direct value, remove .when()
                    child: StatCardWidget(
                      key: ValueKey(projectCount),
                      title: 'Active Projects',
                      value: projectCount.toString(),
                      icon: Icons.folder_special,
                    ),
                    // Removed loading/error handling for now
                  ),
                  const SizedBox(width: 20), // Spacing between cards
                  // Handle AsyncValue for tasks due count
                  // Handle AsyncValue for tasks due count
                  Expanded(
                    child: tasksDueCount.when(
                      data:
                          (count) => StatCardWidget(
                            key: ValueKey(
                              count,
                            ), // Use count in key when data is available
                            title: 'Tasks Due',
                            value: count.toString(),
                            icon: Icons.warning_amber,
                          ),
                      loading:
                          () => StatCardWidget(
                            title: 'Tasks Due',
                            value: '...', // Placeholder for loading
                            icon: Icons.warning_amber,
                          ),
                      error:
                          (err, stack) => StatCardWidget(
                            title: 'Tasks Due',
                            value: 'Error', // Placeholder for error
                            icon: Icons.error_outline,
                            // Optionally style differently for error
                          ),
                    ),
                  ),
                ],
              ),

              const Spacer(), // Pushes the button to the bottom
              // Navigation Button near the bottom
              NavigationButtonWidget(
                label: 'View Projects',
                icon: Icons.arrow_forward,
                onPressed: () {
                  // Use named route for navigation
                  Navigator.of(context).pushNamed(AppRouter.projects);
                },
              ),

              const SizedBox(height: 30), // Padding at the bottom
              // TODO: Add other dashboard elements (Rive widget?)
            ],
          ),
        ),
      ),
      // The closing parentheses for Padding (line 66) and SafeArea (line 67) are correct.
      // Remove the extra lines 68 and 69 that were added in error.
    ); // End Scaffold
  }
}
