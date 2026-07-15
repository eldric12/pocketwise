import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Holds the Firebase uid of the currently logged-in user, or null if logged out.
final currentUserIdProvider = StateProvider<String?>((ref) => null);