import 'package:flutter/material.dart';
import 'package:planner/presentation/navigation/main_app_shell.dart'; // Import the main shell

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToHome();
  }

  void _navigateToHome() {
    // Ensure navigation happens after the first frame is rendered
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        // Check if the widget is still in the tree
        // Replace the splash screen with the main app shell
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder:
                (context, animation, secondaryAnimation) =>
                    const MainAppShell(),
            // Optional: Add a fade transition from splash to main app
            transitionsBuilder: (
              context,
              animation,
              secondaryAnimation,
              child,
            ) {
              return FadeTransition(opacity: animation, child: child);
            },
            transitionDuration: const Duration(
              milliseconds: 300,
            ), // Adjust duration as needed
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Simple splash screen UI
    return const Scaffold(
      backgroundColor: Colors.black, // Match the main background base
      body: Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      ),
    );
  }
}
