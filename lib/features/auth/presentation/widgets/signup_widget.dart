import 'package:firebase_auth/firebase_auth.dart'; // Import for FirebaseAuthException
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// Remove import for auth_providers.dart
import 'package:planner/features/auth/data/auth_repository.dart'; // Import repository provider
import 'package:planner/presentation/navigation/main_app_shell.dart'; // Import MainAppShell for GlobalKey

class SignUpWidget extends ConsumerStatefulWidget {
  const SignUpWidget({super.key});

  @override
  ConsumerState<SignUpWidget> createState() => _SignUpWidgetState();
}

class _SignUpWidgetState extends ConsumerState<SignUpWidget> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false; // Local loading state

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate() && !_isLoading) {
      setState(() => _isLoading = true); // Start loading
      try {
        // Call repository directly
        final userCredential = await ref
            .read(authRepositoryProvider)
            .createUserWithEmailAndPassword(
              email: _emailController.text.trim(),
              password: _passwordController.text.trim(),
            );

        // IMPORTANT: Trigger data migration after successful signup
        if (mounted && userCredential.user != null) {
          print(
            'TODO: Trigger data migration for user ${userCredential.user!.uid}',
          );
          // Example: await ref.read(dataMigrationServiceProvider).migrateLocalDataToUser(userCredential.user!.uid);
          // This migration logic needs to be implemented (Step 6 of the plan)
        }

        // Navigate back after successful signup
        if (mounted) {
          MainAppShell.shellNavigatorKey.currentState?.pop();
        }

        // Navigation is handled by AuthWrapper or listener elsewhere
      } on FirebaseAuthException catch (e) {
        // Handle specific Firebase errors
        String errorMessage = 'An error occurred. Please try again.';
        if (e.code == 'weak-password') {
          errorMessage = 'The password provided is too weak.';
        } else if (e.code == 'email-already-in-use') {
          errorMessage = 'An account already exists for that email.';
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
              content: const Text(
                'An unexpected error occurred during sign up.',
              ),
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
    // Remove ref.listen and ref.watch

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
            textInputAction: TextInputAction.next,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter a password.';
              }
              if (value.trim().length < 6) {
                // Example: Enforce minimum length
                return 'Password must be at least 6 characters.';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            // Confirm Password Field
            controller: _confirmPasswordController,
            decoration: InputDecoration(
              labelText: 'Confirm Password',
              prefixIcon: const Icon(Icons.lock_outline),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureConfirmPassword
                      ? Icons.visibility_off
                      : Icons.visibility,
                ),
                onPressed: () {
                  setState(() {
                    _obscureConfirmPassword = !_obscureConfirmPassword;
                  });
                },
              ),
            ),
            obscureText: _obscureConfirmPassword,
            textInputAction: TextInputAction.done,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please confirm your password.';
              }
              if (value != _passwordController.text) {
                return 'Passwords do not match.';
              }
              return null;
            },
            onFieldSubmitted: (_) => _submit(),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: isLoading ? null : _submit,
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 50),
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
                    : const Text('Sign Up'),
          ),
        ],
      ),
    );
  }
}
