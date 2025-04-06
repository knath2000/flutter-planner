import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:planner/features/auth/presentation/widgets/login_widget.dart'; // Import LoginWidget
import 'package:planner/features/auth/presentation/widgets/signup_widget.dart'; // Import SignUpWidget

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  bool _showLoginPage = true; // State to toggle between Login and Sign Up

  void _toggleView() {
    setState(() {
      _showLoginPage = !_showLoginPage;
    });
  }

  @override
  Widget build(BuildContext context) {
    // TODO: Replace Placeholder with actual Login/SignUp widgets and toggle logic
    return Scaffold(
      // Potentially use AnimatedBackground here later?
      // backgroundColor removed to allow main background to show through
      body: Center(
        child: SingleChildScrollView(
          // Allow scrolling if content overflows
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _showLoginPage ? 'Login' : 'Sign Up',
                style: Theme.of(
                  context,
                ).textTheme.headlineMedium?.copyWith(color: Colors.white),
              ),
              const SizedBox(height: 40),
              // Placeholder for Login/Sign Up forms
              if (_showLoginPage)
                const LoginWidget() // Use LoginWidget
              else
                const SignUpWidget(), // Use SignUpWidget

              const SizedBox(height: 20),
              TextButton(
                onPressed: _toggleView,
                child: Text(
                  _showLoginPage
                      ? 'Need an account? Sign Up'
                      : 'Have an account? Login',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
