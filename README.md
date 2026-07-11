# PocketWise Flutter App

PocketWise is the main Flutter mobile application in this repository. It is being built as an offline-first personal finance tracker for students and young adults, with a strong focus on fast expense logging, budget awareness, and a polished fintech-style UI.

## Project Vision

This project is not meant to be a barebones CRUD demo. The goal is to build a finance app that feels thoughtful, modern, and maintainable, while still being realistic for a university final-year project.

Core product goals:

- log income and expenses in a few seconds
- keep data locally on-device
- help users stay within category budgets
- show spending patterns clearly
- maintain a clean and scalable Flutter architecture

## Tech Stack

- Flutter
- Dart
- Riverpod
- SQLite support via `sqflite`
- `fl_chart` for charts
- `google_fonts` for typography

## Current Status

Currently implemented:

- custom dark fintech-style UI direction
- dashboard shell with bottom navigation
- home/activity/budget/more sections
- add transaction screen
- refactored dashboard feature structure
- mock/sample transaction data through Riverpod

Not implemented yet:

- persistent local database
- full create/read/update/delete transaction flow
- category CRUD
- dynamic budgets and warnings
- reports screen
- settings screen logic
- theme switching

## Folder Structure

```text
lib/
├── main.dart
├── app/
│   └── app.dart
├── core/
│   └── constants/
│       └── app_colors.dart
└── features/
    └── dashboard/
        ├── models/
        │   ├── dashboard_ui_models.dart
        │   └── transaction.dart
        ├── providers/
        │   └── dashboard_provider.dart
        ├── screens/
        │   ├── dashboard_screen.dart
        │   └── new_transaction_screen.dart
        ├── utils/
        │   └── dashboard_ui_helpers.dart
        └── widgets/
            ├── dashboard_common_widgets.dart
            ├── dashboard_navigation.dart
            └── dashboard_tabs.dart
```

## How To Run

From this directory:

```bash
flutter pub get
flutter run
```

To check code health:

```bash
flutter analyze
```

## Working Style For Contributors

Please follow these project conventions when continuing the app:

- keep files feature-based and reasonably small
- avoid putting an entire feature into one large screen file
- reuse widgets instead of duplicating UI
- keep styling consistent with the premium fintech direction
- prefer clean structure over quick hacks

## UI Direction

The current design direction is:

- dark navy background
- blue accent colors
- white typography
- premium finance-dashboard look
- rounded but controlled surfaces
- subtle glass/surface treatment
- minimal, non-childish visual language

Reference inspiration:

- Revolut
- Wise
- Apple Wallet
- modern banking and crypto dashboards

## Suggested Next Development Order

1. Add local persistence layer
2. Connect real transaction creation to storage
3. Add categories and budgets data models
4. Replace mock budget warning with dynamic logic
5. Build reports and settings modules
6. Add testing and polish interactions

## Handoff Notes

If a teammate is picking this up:

- start from `lib/features/dashboard/`
- understand the current UI split before adding new screens
- keep new modules aligned with the same feature-first structure
- do not reintroduce oversized screen files


