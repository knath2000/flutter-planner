import 'package:flutter/material.dart';
import 'package:planner/features/dashboard/presentation/view/dashboard_view.dart';
import 'package:planner/features/projects/presentation/view/add_project_view.dart'
    deferred as add_project;
import 'package:planner/features/projects/presentation/view/project_list_view.dart'
    deferred as project_list;
import 'package:planner/features/tasks/presentation/view/task_details_view.dart'
    deferred as task_details;
import 'package:planner/features/auth/presentation/view/auth_view.dart'
    deferred as auth_lib;
import 'package:planner/presentation/navigation/navigation_state.dart'; // Assuming AppPageRoute is here or imported

// Placeholder for AppPageRoute if it's custom, otherwise use MaterialPageRoute
class AppPageRoute extends MaterialPageRoute {
  AppPageRoute({required Widget page, required RouteSettings settings})
    : super(builder: (context) => page, settings: settings);
  // Add custom transitions if needed
}

class AppRouter {
  static const String dashboard = '/';
  static const String projects = '/projects';
  static const String addProject = '/add_project';
  static const String projectDetails =
      '/project_details'; // Example for tasks view
  static const String auth = '/auth'; // Route for Login/Signup view

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case dashboard:
        // Dashboard is initial, load normally
        return AppPageRoute(page: const DashboardView(), settings: settings);
      case projects:
        return AppPageRoute(
          settings: settings,
          page: _DeferredRouteWidget(
            loadFuture: project_list.loadLibrary(),
            loadedBuilder: (context) => project_list.ProjectListView(),
          ),
        );
      case addProject:
        return AppPageRoute(
          settings: settings,
          page: _DeferredRouteWidget(
            loadFuture: add_project.loadLibrary(),
            loadedBuilder: (context) => add_project.AddProjectView(),
          ),
        );
      case projectDetails:
        final projectUuid = settings.arguments as String?;
        if (projectUuid != null) {
          return AppPageRoute(
            settings: settings,
            page: _DeferredRouteWidget(
              loadFuture: task_details.loadLibrary(),
              loadedBuilder:
                  (context) =>
                      task_details.TaskDetailsView(projectUuid: projectUuid),
            ),
          );
        } else {
          return _errorRoute(
            'Project details requires a non-null project UUID (String) argument.',
          );
        }
      case auth:
        // Use PageRouteBuilder for custom transition AND deferred loading
        return PageRouteBuilder(
          settings: settings,
          pageBuilder:
              (context, animation, secondaryAnimation) => _DeferredRouteWidget(
                loadFuture: auth_lib.loadLibrary(),
                loadedBuilder: (context) => auth_lib.AuthView(),
              ),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        );
      default:
        return _errorRoute('No route defined for ${settings.name}');
    }
  }

  static Route<dynamic> _errorRoute(String message) {
    return PageRouteBuilder(
      pageBuilder:
          (context, animation, secondaryAnimation) => Scaffold(
            appBar: AppBar(title: const Text('Error')),
            body: Center(child: Text('Routing Error: $message')),
          ),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(opacity: animation, child: child);
      },
    );
  }
}

// Helper widget for deferred loading (Top-level class)
class _DeferredRouteWidget extends StatefulWidget {
  final Future<void> loadFuture;
  final WidgetBuilder loadedBuilder;

  const _DeferredRouteWidget({
    super.key, // Added key
    required this.loadFuture,
    required this.loadedBuilder,
  });

  @override
  State<_DeferredRouteWidget> createState() => _DeferredRouteWidgetState();
}

class _DeferredRouteWidgetState extends State<_DeferredRouteWidget> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: widget.loadFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasError) {
            // Handle loading error - maybe show an error message
            print(
              'Error loading deferred library: ${snapshot.error}',
            ); // Added print
            return Center(
              child: Text('Error loading feature: ${snapshot.error}'),
            );
          }
          // Library loaded, build the actual widget
          return widget.loadedBuilder(context);
        } else {
          // Show loading indicator
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }
}
