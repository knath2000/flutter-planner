import 'package:firebase_auth/firebase_auth.dart'; // Import for FirebaseAuthException
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// Remove import for auth_providers.dart as we use the repository directly
import 'package:planner/features/auth/data/auth_repository.dart'; // Import repository provider
import 'package:planner/presentation/navigation/main_app_shell.dart'; // Import MainAppShell for GlobalKey

class LoginWidget extends ConsumerStatefulWidget {
  const LoginWidget({super.key});

  @override
  ConsumerState<LoginWidget> createState() => _LoginWidgetState();
}

class _LoginWidgetState extends ConsumerState<LoginWidget> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false; // Local loading state

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate() && !_isLoading) {
      setState(() => _isLoading = true); // Start loading
      try {
        // Call repository directly
        await ref
            .read(authRepositoryProvider)
            .signInWithEmailAndPassword(
              email: _emailController.text.trim(),
              password: _passwordController.text.trim(),
            );
        // Navigate back after successful login
        if (mounted) {
          MainAppShell.shellNavigatorKey.currentState?.pop();
        }
        // Original comment removed as navigation is now handled here:
        // // Navigation is handled by AuthWrapper listening to authStateChangesProvider
        // // No need to do anything here on success
      } on FirebaseAuthException catch (e) {
        // Handle specific Firebase errors
        String errorMessage = 'An error occurred. Please try again.';
        if (e.code == 'user-not-found' ||
            e.code == 'wrong-password' ||
            e.code == 'invalid-credential') {
          errorMessage = 'Invalid email or password.';
        } else if (e.code == 'invalid-email') {
          errorMessage = 'Please enter a valid email address.';
        }
        // Show error SnackBar
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMessage),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      } catch (e) {
        // Handle other generic errors
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('An unexpected error occurred.'),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      } finally {
        // Stop loading regardless of success or error
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Remove ref.listen and ref.watch for authControllerProvider

    // Use the local _isLoading state
    final isLoading = _isLoading;

    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextFormField(
            controller: _emailController,
            decoration: InputDecoration(
              labelText: 'Email',
              prefixIcon: const Icon(Icons.email_outlined),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            validator: (value) {
              if (value == null ||
                  value.trim().isEmpty ||
                  !value.contains('@')) {
                return 'Please enter a valid email address.';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _passwordController,
            decoration: InputDecoration(
              labelText: 'Password',
              prefixIcon: const Icon(Icons.lock_outline),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility_off : Icons.visibility,
                ),
                onPressed: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
              ),
            ),
            obscureText: _obscurePassword,
            textInputAction: TextInputAction.done,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter your password.';
              }
              return null;
            },
            onFieldSubmitted:
                (_) => _submit(), // Allow submitting from keyboard
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed:
                isLoading ? null : _submit, // Disable button when loading
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 50), // Make button wider
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child:
                isLoading
                    ? const SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                    : const Text('Login'),
          ),
        ],
      ),
    );
  }
}
