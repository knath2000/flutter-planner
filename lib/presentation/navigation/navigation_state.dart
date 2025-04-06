import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:planner/presentation/navigation/app_router.dart';

/// Provider for the current route in the shell navigator
final shellRouteProvider = StateProvider<String>((ref) => AppRouter.dashboard);

/// Provider for whether the auth button should be visible
final showAuthButtonProvider = Provider<bool>((ref) {
  final currentRoute = ref.watch(shellRouteProvider);
  return currentRoute != AppRouter.auth;
});

/// A more efficient navigator observer that updates route state
class ShellRouteObserver extends NavigatorObserver {
  final StateController<String> routeController;

  ShellRouteObserver(this.routeController);

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _updateRoute(route);
    super.didPush(route, previousRoute);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    if (previousRoute != null) {
      _updateRoute(previousRoute);
    }
    super.didPop(route, previousRoute);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    if (newRoute != null) {
      _updateRoute(newRoute);
    }
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
  }

  void _updateRoute(Route<dynamic> route) {
    final routeName = route.settings.name;
    if (routeName != null && routeController.state != routeName) {
      // Use a post-frame callback to avoid modifying state during build
      WidgetsBinding.instance.addPostFrameCallback((_) {
        routeController.state = routeName;
      });
    }
  }
}

/// Custom page route for app-specific transitions
class AppPageRoute<T> extends PageRouteBuilder<T> {
  AppPageRoute({required Widget page, required RouteSettings settings})
    : super(
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeInOutCubic;

          var tween = Tween(
            begin: begin,
            end: end,
          ).chain(CurveTween(curve: curve));

          var offsetAnimation = animation.drive(tween);

          return SlideTransition(
            position: offsetAnimation,
            child: FadeTransition(opacity: animation, child: child),
          );
        },
        transitionDuration: const Duration(milliseconds: 300),
        settings: settings,
      );
}
