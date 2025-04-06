import 'package:flutter/material.dart';
import 'package:planner/features/auth/presentation/widgets/login_widget.dart';
import 'package:planner/features/auth/presentation/widgets/signup_widget.dart';
import 'package:planner/features/dashboard/presentation/widgets/animated_background.dart'; // Reuse background
import 'package:planner/presentation/common_widgets/navigation_button_widget.dart'; // Import the custom button

class AuthView extends StatefulWidget {
  const AuthView({super.key});

  @override
  State<AuthView> createState() => _AuthViewState();
}

class _AuthViewState extends State<AuthView> {
  // Removed SingleTickerProviderStateMixin
  // Removed TabController
  bool _showLogin = true; // State to toggle between Login and Sign Up

  // Removed initState as TabController is gone

  // Removed dispose as TabController is gone

  @override
  Widget build(BuildContext context) {
    // final theme = Theme.of(context); // Theme is accessed within widgets now

    return Scaffold(
      backgroundColor: Colors.transparent, // Show background
      // Removed extendBodyBehindAppBar and AppBar
      // Removed inner Stack and redundant AnimatedBackground
      body: SafeArea(
        child: Center(
          // Center the content vertically
          child: SingleChildScrollView(
            // Allow scrolling
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 32.0,
            ),
            child: ConstrainedBox(
              // Limit max width
              constraints: const BoxConstraints(maxWidth: 400),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Row for Login/Sign Up buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      NavigationButtonWidget(
                        label: 'Login',
                        icon: Icons.login,
                        isActive: _showLogin,
                        onPressed: () {
                          if (!_showLogin) {
                            setState(() => _showLogin = true);
                          }
                        },
                      ),
                      const SizedBox(width: 16), // Spacing between buttons
                      NavigationButtonWidget(
                        label: 'Sign Up',
                        icon: Icons.person_add_alt_1, // Changed icon
                        isActive: !_showLogin,
                        onPressed: () {
                          if (_showLogin) {
                            setState(() => _showLogin = false);
                          }
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 32), // Spacing below buttons
                  // AnimatedSwitcher for the forms
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    transitionBuilder: (
                      Widget child,
                      Animation<double> animation,
                    ) {
                      return FadeTransition(opacity: animation, child: child);
                    },
                    child:
                        _showLogin
                            ? const LoginWidget(
                              key: ValueKey('login'),
                            ) // Add keys
                            : const SignUpWidget(key: ValueKey('signup')),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
