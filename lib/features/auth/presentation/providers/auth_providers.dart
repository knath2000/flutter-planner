import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:planner/features/auth/data/auth_repository.dart'; // Import the repository

/// Provider that exposes the stream of Firebase authentication state changes.
///
/// This allows the UI or other providers to reactively listen to whether a user
/// is signed in or signed out.
final authStateChangesProvider = StreamProvider<User?>((ref) {
  // Watch the repository provider
  final authRepository = ref.watch(authRepositoryProvider);
  // Return the authStateChanges stream from the repository
  return authRepository.authStateChanges;
});

/// Provider to get the current user's ID (or null if not logged in).
/// Useful for easily accessing the UID in other providers/widgets.
final currentUserIdProvider = Provider<String?>((ref) {
  final authState = ref.watch(authStateChangesProvider);
  return authState.value?.uid; // Access the user object within AsyncValue.data
});
