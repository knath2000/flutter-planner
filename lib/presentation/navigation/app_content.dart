import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:planner/presentation/navigation/app_router.dart';
import 'package:planner/presentation/navigation/navigation_state.dart';

/// A component that manages the content area of the app
/// This includes the nested navigator and handles layout adjustments
class AppContent extends ConsumerStatefulWidget {
  const AppContent({super.key, required this.navigatorKey});

  final GlobalKey<NavigatorState> navigatorKey;

  @override
  ConsumerState<AppContent> createState() => _AppContentState();
}

class _AppContentState extends ConsumerState<AppContent>
    with SingleTickerProviderStateMixin {
  late final ShellRouteObserver _routeObserver;
  late final AnimationController _animationController;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize the route observer
    _routeObserver = ShellRouteObserver(ref.read(shellRouteProvider.notifier));

    // Initialize animation controller for content transitions
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    _animationController.forward();

    // Check initial route after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkInitialRoute();
    });
  }

  void _checkInitialRoute() {
    final currentState = widget.navigatorKey.currentState;
    if (currentState != null && currentState.mounted) {
      currentState.popUntil((route) {
        // Use the public method instead of the private one
        if (route.settings.name != null) {
          ref.read(shellRouteProvider.notifier).state = route.settings.name!;
        }
        return true; // Stop popping
      });
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Watch the current route to trigger animations when it changes
    final currentRoute = ref.watch(shellRouteProvider);

    // Trigger animation when route changes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_animationController.status == AnimationStatus.completed) {
        _animationController.reset();
        _animationController.forward();
      }
    });

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Navigator(
        key: widget.navigatorKey,
        initialRoute: AppRouter.dashboard,
        onGenerateRoute: AppRouter.generateRoute,
        observers: [_routeObserver],
      ),
    );
  }
}
