# PocketWise Flutter App

PocketWise is an offline-first personal finance application in active development. It is designed to help students and young adults record transactions quickly, understand monthly spending, and stay aware of category budgets.

The product direction combines a premium fintech interface with a maintainable, feature-based Flutter architecture.

## Current Status

### Implemented

- premium dark navy dashboard and bottom navigation
- dynamic monthly income, expense, and balance calculations
- expense and income transaction entry
- custom amount keypad
- expense and income category selection
- temporary custom category creation
- transaction date, payment method, and memo fields
- activity grouping and recent transaction summaries
- dynamic spending breakdown by category
- interactive donut chart with slice and legend selection
- user-defined category budget limits
- budget editing and removal
- automatic near-limit and over-budget warnings
- empty states for transactions, spending, and budgets
- modular dashboard and transaction UI files

### Not Implemented Yet

- SQLite persistence for transactions, budgets, and categories
- transaction editing from the activity screen
- complete delete and undo user flow
- permanent category management
- reports and analytics screens
- settings behavior and theme switching
- automated unit and widget test coverage

All transaction and budget data currently lives in Riverpod memory and resets when the application restarts.

## Tech Stack

- Flutter and Dart
- `flutter_riverpod` for application state
- `fl_chart` for spending visualizations
- `google_fonts` for typography
- `sqflite` and `path` declared for the planned persistence layer
- Material 3 components and platform-safe interactions

## Project Structure

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
        │   ├── new_transaction_screen.dart
        │   └── new_transaction/
        │       ├── amount_controls.dart
        │       ├── category_controls.dart
        │       └── detail_controls.dart
        ├── utils/
        │   └── dashboard_ui_helpers.dart
        └── widgets/
            ├── dashboard_common_widgets.dart
            ├── dashboard_navigation.dart
            ├── dashboard_tabs.dart
            └── dashboard_tabs/
                ├── activity_tab.dart
                ├── budget_calculation.dart
                ├── budget_widgets.dart
                ├── budgets_tab.dart
                ├── home_summary_widgets.dart
                ├── home_tab.dart
                ├── more_tab.dart
                ├── spending_overview.dart
                └── transaction_widgets.dart
```

`dashboard_tabs.dart` and `new_transaction_screen.dart` are library entry points. Their focused internal components use Dart `part` files so private implementation details can remain scoped to their parent library.

## Running The App

From `flutter_project/`:

```bash
flutter pub get
flutter run
```

Choose a device explicitly when needed:

```bash
flutter devices
flutter run -d <device-id>
```

## Code Quality

```bash
flutter analyze
flutter test
```

Run formatting before committing:

```bash
dart format lib test
```

## Development Conventions

- Keep financial values derived from state; do not hardcode sample totals, percentages, warnings, or dates.
- Keep individual handwritten Dart files focused and preferably below 500 lines.
- Place reusable feature widgets in the relevant component folder.
- Keep calculations outside rendering code when they can be expressed as pure helpers.
- Preserve the established color tokens in `app_colors.dart`.
- Use clear empty, loading, validation, and error states.
- Maintain minimum 48dp touch targets for interactive mobile controls.
- Ensure new features work with both expense and income transactions where applicable.
- Do not claim data is persistent until it is connected to the local database.

## UI Direction

PocketWise uses a restrained modern-finance visual language:

- dark navy background
- layered blue-gray surfaces
- blue primary actions
- semantic green, amber, and red financial states
- strong white typography hierarchy
- controlled corner radii and subtle borders
- minimal gradients and decorative effects
- clear spacing based on a 4dp/8dp rhythm

Reference products include Revolut, Wise, Apple Wallet, and modern investment dashboards.

## Recommended Next Steps

1. Add a repository and SQLite database layer.
2. Persist transactions and restore them during provider initialization.
3. Persist user-defined budgets and custom categories.
4. Add transaction editing, deletion confirmation, and undo.
5. Build reports from the same stored transaction source.
6. Add unit tests for calculations and widget tests for critical flows.

## Contributor Handoff

Start with `dashboard_screen.dart` to understand navigation and provider wiring. Follow the library entry points into their component folders, and keep state changes inside `dashboard_provider.dart` until a dedicated repository layer is introduced.

When changing financial behavior, verify these flows together:

- dashboard totals
- spending category breakdown
- recent activity
- budget progress
- dashboard warning state

These views intentionally derive from the same transaction and budget state and should remain consistent.
