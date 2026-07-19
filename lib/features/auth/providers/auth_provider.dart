import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Holds the Firebase uid of the currently logged-in user, or null if logged out.
final currentUserIdProvider = StateProvider<String?>((ref) => null);

/// Watches the signed-in user's profile name stored in Firestore.
final currentUserNameProvider = StreamProvider<String?>((ref) async* {
  final userId = ref.watch(currentUserIdProvider);
  if (userId == null) {
    yield null;
    return;
  }

  try {
    await for (final snapshot in FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .snapshots()) {
      final rawName = snapshot.data()?['name'];
      final firestoreName = rawName is String ? rawName.trim() : null;
      if (firestoreName != null && firestoreName.isNotEmpty) {
        yield firestoreName;
      } else {
        yield _firebaseUserName();
      }
    }
  } catch (_) {
    yield _firebaseUserName();
  }
});

String? _firebaseUserName() {
  final user = FirebaseAuth.instance.currentUser;
  final authName = user?.displayName?.trim();
  if (authName != null && authName.isNotEmpty) return authName;

  final email = user?.email;
  return email == null ? null : email.split('@').first;
}
