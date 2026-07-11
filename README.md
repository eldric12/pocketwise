# PocketWise - Flutter Project Source Code (Clean Architecture + MVVM + Riverpod)

This directory contains the production-quality Flutter and Dart source code for your final year university project, matching the architecture and design requirements.

You can copy these files directly into your local Flutter project workspace in VS Code or Android Studio.

## Architecture Structure

```
lib/
├── main.dart
├── app/
│   ├── app.dart
│   ├── routes.dart
│   └── theme.dart
├── core/
│   ├── constants/
│   ├── utils/
│   └── widgets/
└── features/
    ├── dashboard/
    │   ├── data/
    │   ├── models/
    │   ├── providers/
    │   ├── screens/
    │   └── widgets/
    ├── transactions/
    ├── categories/
    ├── budgets/
    ├── reports/
    └── settings/
```

## Setup & Dependencies

Add the following to your local `pubspec.yaml`:

```yaml
dependencies:
  flutter:
    sdk: flutter
  
  # State Management
  flutter_riverpod: ^2.4.9
  riverpod_annotation: ^2.3.3

  # Local Persistence
  sqflite: ^2.3.0
  path: ^1.8.3

  # Charts
  fl_chart: ^0.66.0

  # Navigation & Fonts
  go_router: ^13.1.0
  google_fonts: ^6.1.0
  lucide_icons: ^0.321.0
```
