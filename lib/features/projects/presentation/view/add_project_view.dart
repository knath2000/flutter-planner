import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Import Riverpod
// Import providers
import 'package:planner/features/projects/data/project_repository.dart'; // Import repository provider
import 'package:planner/features/projects/domain/entities/project.dart'; // Import Project entity
import 'package:planner/features/dashboard/presentation/widgets/animated_background.dart';
import 'package:planner/presentation/common_widgets/navigation_button_widget.dart';
// TODO: Consider creating a reusable CustomTextField widget later

class AddProjectView extends ConsumerStatefulWidget {
  // Change to ConsumerStatefulWidget
  const AddProjectView({super.key});

  @override
  ConsumerState<AddProjectView> createState() => _AddProjectViewState(); // Change to ConsumerState
}

class _AddProjectViewState extends ConsumerState<AddProjectView> {
  // Change to ConsumerState
  bool _isLoading = false; // Add loading state variable
  late final TextEditingController _projectNameController;

  @override
  void initState() {
    super.initState();
    _projectNameController = TextEditingController();
  }

  @override
  void dispose() {
    _projectNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final safePadding = MediaQuery.of(context).padding;

    return Scaffold(
      backgroundColor: Colors.transparent, // Ensure background shows through
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text('Add New Project', style: theme.appBarTheme.titleTextStyle),
        backgroundColor: Colors.transparent, // Match other views
        elevation: 0,
        // Back button is automatically added by default
      ),
      body: Stack(
        children: [
          const Positioned.fill(
            child: AnimatedBackground(),
          ), // Reuse background
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                children: [
                  SizedBox(
                    height: kToolbarHeight + safePadding.top + 20,
                  ), // Space below AppBar
                  // --- Form Elements Start ---
                  TextField(
                    controller: _projectNameController,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                    ), // Input text style
                    cursorColor:
                        theme
                            .colorScheme
                            .primary, // Use primary color for cursor
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: theme.colorScheme.surface.withOpacity(
                        0.8,
                      ), // Use surface color for background
                      hintText: 'Enter project name...',
                      hintStyle: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.white38,
                      ), // Hint text style
                      border: OutlineInputBorder(
                        // Use outline border for shape
                        borderRadius: BorderRadius.circular(
                          12.0,
                        ), // Rounded corners
                        borderSide:
                            BorderSide.none, // No visible border line initially
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        // Add subtle border on focus
                        borderRadius: BorderRadius.circular(12.0),
                        borderSide: BorderSide(
                          color: theme.colorScheme.primary,
                          width: 1.5,
                        ), // Primary color border when focused
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ), // Adjust padding
                    ),
                  ),

                  // --- Form Elements End ---
                  const Spacer(), // Push buttons to bottom
                  // --- Action Buttons Start ---
                  Row(
                    children: [
                      Expanded(
                        child: NavigationButtonWidget(
                          label: 'Cancel',
                          icon: Icons.cancel_outlined,
                          onPressed: () {
                            Navigator.of(
                              context,
                            ).pop(); // Simple pop for cancel
                          },
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: NavigationButtonWidget(
                          label: 'Save Project',
                          icon: Icons.save_alt_outlined,
                          // Pass isLoading state to the button (requires modification in NavigationButtonWidget)
                          isLoading: _isLoading,
                          onPressed:
                              _isLoading
                                  ? null
                                  : () async {
                                    // Disable button while loading
                                    // 1. Get text from TextField controller
                                    final projectName =
                                        _projectNameController.text.trim();

                                    // 2. Validate input
                                    if (projectName.isEmpty) {
                                      // 3. Show themed error SnackBar if invalid
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            'Project name cannot be empty!',
                                            style: TextStyle(
                                              color: theme.colorScheme.onError,
                                            ),
                                          ),
                                          backgroundColor:
                                              theme.colorScheme.error,
                                          behavior: SnackBarBehavior.floating,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              10.0,
                                            ),
                                          ),
                                        ),
                                      );
                                      return; // Stop processing
                                    }

                                    // If valid: Set loading, call provider, pop screen
                                    setState(() => _isLoading = true);
                                    try {
                                      // Optional delay to visualize loading
                                      await Future.delayed(
                                        const Duration(milliseconds: 500),
                                      );

                                      // 4. Create Project entity and call repository to save
                                      final newProject = Project(
                                        name: projectName,
                                      );
                                      // Call the repository directly to add the project
                                      await ref
                                          .read(
                                            projectRepositoryProvider,
                                          ) // Read the repository provider
                                          .addProject(
                                            newProject,
                                          ); // Call addProject on the repository
                                      print(
                                        'Project "$projectName" added via repository.',
                                      ); // Debugging

                                      // 5. Pop screen on success
                                      if (mounted) Navigator.of(context).pop();
                                    } finally {
                                      // Ensure loading state is reset even if errors occur (though none expected here yet)
                                      if (mounted) {
                                        setState(() => _isLoading = false);
                                      }
                                    }
                                  },
                        ),
                      ),
                    ],
                  ),

                  // --- Action Buttons End ---
                  const SizedBox(height: 30), // Bottom padding
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
