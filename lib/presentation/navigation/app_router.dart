import 'package:flutter/material.dart';
import 'package:planner/features/dashboard/presentation/view/dashboard_view.dart';
import 'package:planner/features/projects/presentation/view/add_project_view.dart';
import 'package:planner/features/projects/presentation/view/project_list_view.dart';
import 'package:planner/features/tasks/presentation/view/task_details_view.dart';
import 'package:planner/features/auth/presentation/view/auth_view.dart';
import 'package:planner/presentation/navigation/navigation_state.dart';

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
        return AppPageRoute(page: const DashboardView(), settings: settings);
      case projects:
        return AppPageRoute(page: const ProjectListView(), settings: settings);
      case addProject:
        return AppPageRoute(page: const AddProjectView(), settings: settings);
      case projectDetails:
        // Expecting project UUID (String) as argument
        final projectUuid = settings.arguments as String?;
        if (projectUuid != null) {
          return AppPageRoute(
            page: TaskDetailsView(projectUuid: projectUuid),
            settings: settings,
          );
        } else {
          // Handle error: Argument missing or wrong type
          return _errorRoute(
            'Project details requires a non-null project UUID (String) argument.',
          );
        }
      case auth:
        // Use a different transition for auth view (fade transition)
        return PageRouteBuilder(
          // opaque: false, // Reverted: Route should cover underlying content
          pageBuilder:
              (context, animation, secondaryAnimation) => const AuthView(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          settings: settings,
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
