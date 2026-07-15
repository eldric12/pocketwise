import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  AuthService._internal();
  static final AuthService instance = AuthService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Returns null on success, or an error message on failure.
  Future<String?> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim().toLowerCase(),
        password: password,
      );
      await _firestore.collection('users').doc(credential.user!.uid).set({
        'name': name.trim(),
        'email': email.trim().toLowerCase(),
      });
      return null;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'email-already-in-use':
          return 'An account with this email already exists.';
        case 'weak-password':
          return 'Password is too weak (use at least 6 characters).';
        case 'invalid-email':
          return 'Please enter a valid email.';
        default:
          return e.message ?? 'Something went wrong. Please try again.';
      }
    }
  }

  /// Returns null on success, or an error message on failure.
  Future<String?> login({
    required String userId,
    required String password,
  }) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: userId.trim().toLowerCase(),
        password: password,
      );
      return null;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
          return 'No account found with that email.';
        case 'wrong-password':
        case 'invalid-credential':
          return 'Incorrect password.';
        case 'invalid-email':
          return 'Please enter a valid email.';
        default:
          return e.message ?? 'Something went wrong. Please try again.';
      }
    }
  }

  String? get currentUserId => _auth.currentUser?.uid;

  Future<void> logout() async {
    await _auth.signOut();
  }
}