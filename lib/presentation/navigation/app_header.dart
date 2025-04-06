import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:planner/features/auth/data/auth_repository.dart';
import 'package:planner/features/auth/presentation/providers/auth_providers.dart';
import 'package:planner/presentation/common_widgets/navigation_button_widget.dart';
import 'package:planner/presentation/navigation/app_router.dart';
import 'package:planner/presentation/navigation/main_app_shell.dart';
import 'package:planner/presentation/navigation/navigation_state.dart';

/// A reusable app header component that contains the app title and auth button
class AppHeader extends ConsumerWidget {
  const AppHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final userId = ref.watch(currentUserIdProvider);
    final isLoggedIn = userId != null;

    // Watch the provider to determine if auth button should be shown
    final showAuthButton = ref.watch(showAuthButtonProvider);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        // Remove the Container with background decoration to keep the header transparent
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // App title with subtle animation
            TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0.8, end: 1.0),
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeOutCubic,
              builder: (context, value, child) {
                return Transform.scale(scale: value, child: child);
              },
              child: Text(
                'Planner',
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            // Conditional auth button with animation
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child:
                  showAuthButton
                      ? AnimatedOpacity(
                        opacity: showAuthButton ? 1.0 : 0.0,
                        duration: const Duration(milliseconds: 200),
                        child:
                            isLoggedIn
                                ? NavigationButtonWidget(
                                  label: 'Sign Out',
                                  icon: Icons.logout,
                                  onPressed: () async {
                                    try {
                                      await ref
                                          .read(authRepositoryProvider)
                                          .signOut();
                                    } catch (e) {
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              'Error signing out: $e',
                                            ),
                                            backgroundColor:
                                                theme.colorScheme.error,
                                          ),
                                        );
                                      }
                                    }
                                  },
                                )
                                : NavigationButtonWidget(
                                  label: 'Login / Sign Up',
                                  icon: Icons.login,
                                  onPressed: () {
                                    MainAppShell.shellNavigatorKey.currentState
                                        ?.pushNamed(AppRouter.auth);
                                  },
                                ),
                      )
                      : const SizedBox.shrink(), // Empty widget when hidden
            ),
          ],
        ),
      ),
    );
  }
}
