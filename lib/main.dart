import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app/app.dart';
import 'package:device_preview/device_preview.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize local persistence / SQLite here if needed
  
  runApp(
    ProviderScope(
      child: DevicePreview(
        enabled: true,
        builder: (context) => const PocketWiseApp(),
      ),
    ),
  );
}
