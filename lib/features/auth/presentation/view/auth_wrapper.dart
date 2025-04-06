import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:planner/features/auth/presentation/providers/auth_providers.dart';
import 'package:planner/features/auth/presentation/view/auth_screen.dart';
import 'package:planner/presentation/navigation/main_app_shell.dart'; // Import your main app screen/shell

class AuthWrapper extends ConsumerWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the authentication state changes provider
    final authState = ref.watch(authStateChangesProvider);

    // Use .when to handle the different states of the stream provider
    return authState.when(
      data: (user) {
        // If user is logged in, show the main app shell
        if (user != null) {
          return const MainAppShell();
        }
        // If user is not logged in, show the authentication screen
        return const AuthScreen();
      },
      loading: () {
        // Show a loading indicator while checking auth state
        // TODO: Replace with a themed loading indicator, maybe using AnimatedBackground?
        return const Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        );
      },
      error: (error, stackTrace) {
        // Show an error screen if auth state check fails
        // TODO: Implement a proper error screen
        print('Auth State Error: $error'); // Log error
        return Scaffold(
          body: Center(
            child: Text('Error checking authentication state: $error'),
          ),
        );
      },
    );
  }
}