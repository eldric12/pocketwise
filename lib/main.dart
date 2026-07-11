import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize local persistence / SQLite here if needed
  
  runApp(
    const ProviderScope(
      child: PocketWiseApp(),
    ),
  );
}
