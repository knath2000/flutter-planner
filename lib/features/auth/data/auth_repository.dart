import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Simple provider for the AuthRepository
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(FirebaseAuth.instance);
});

class AuthRepository {
  final FirebaseAuth _firebaseAuth;

  AuthRepository(this._firebaseAuth);

  // Stream of authentication state changes
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  // Get current user (can be null)
  User? get currentUser => _firebaseAuth.currentUser;

  // Sign in with email and password
  Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      return await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      // Handle specific Firebase Auth errors (e.g., wrong password, user not found)
      // You might want to re-throw a custom exception or return a specific result type
      print('Firebase Auth Error (Sign In): ${e.code} - ${e.message}');
      rethrow; // Re-throw for the UI layer to handle
    } catch (e) {
      print('Generic Error (Sign In): $e');
      rethrow;
    }
  }

  // Sign up with email and password
  Future<UserCredential> createUserWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      return await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      // Optionally: Send verification email, update profile, etc.
    } on FirebaseAuthException catch (e) {
      // Handle specific errors (e.g., email already in use, weak password)
      print('Firebase Auth Error (Sign Up): ${e.code} - ${e.message}');
      rethrow;
    } catch (e) {
      print('Generic Error (Sign Up): $e');
      rethrow;
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();
    } catch (e) {
      print('Error signing out: $e');
      rethrow;
    }
  }
}
