import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:planner/features/dashboard/presentation/widgets/animated_background.dart'; // Temporarily commented out
import 'package:planner/presentation/navigation/app_content.dart';
import 'package:planner/presentation/navigation/app_header.dart';

/// Main app shell that contains the app's layout structure
class MainAppShell extends ConsumerWidget {
  const MainAppShell({super.key});

  // GlobalKey for the nested navigator
  static final GlobalKey<NavigatorState> shellNavigatorKey =
      GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            children: [
              // Layer 1: Animated Background
              // Temporarily replace AnimatedBackground with a simple color
              Positioned.fill(child: Container(color: Colors.black)),

              // Layer 2: App Content with Layout
              Column(
                children: [
                  // Header
                  const AppHeader(),

                  // Content Area (takes remaining space)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: AppContent(navigatorKey: shellNavigatorKey),
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}
