# PocketWise Flutter App

PocketWise is a student-focused personal finance application for recording income and expenses, understanding spending habits, and monitoring monthly category budgets. The app combines Firebase-backed accounts with a locally cached Flutter experience and a premium light/dark fintech interface.

## Current Features

### Accounts and Data

- Firebase email/password registration and sign-in
- per-user Firestore transaction storage
- user-aware dashboard greeting from the saved profile name
- user-scoped SQLite transaction cache with local fallback on startup
- locally persisted category budgets and custom category labels

### Transactions

- add income and expense transactions
- record amount, category, date, payment method, and optional notes
- custom amount keypad and type-aware visual styling
- add persistent custom income or expense categories
- edit existing transactions with prefilled values
- delete transactions through a confirmation flow
- view all transactions grouped by their actual calendar date
- sort transactions newest-first or oldest-first
- combine type, date-range, and category filters
- filter by all dates, today, the past seven days, or this month

### Dashboard and Budgets

- all-time current balance calculated as total income minus total expenses
- clearly separated current-month income and expense totals
- current-month spending donut chart derived by category
- interactive chart slices and legend rows
- recent transaction preview with navigation to the full activity list
- editable monthly category budget limits
- dynamic progress bars and near-limit or overspending warnings
- useful empty states when transaction, chart, or budget data is unavailable

### Experience

- premium dark navy visual system and accessible light theme
- animated light/dark theme switching
- responsive mobile layouts with safe-area-aware bottom navigation
- modular dashboard and transaction screen components
- semantic labels and minimum touch-target considerations

## Data Persistence

PocketWise currently uses a hybrid persistence model:

| Data | Primary storage | Local behavior |
| --- | --- | --- |
| User accounts and profile names | Firebase Authentication and Firestore | Firebase-managed session data |
| Transactions | Cloud Firestore | Cached in user-scoped SQLite and shown when remote loading fails |
| Category budgets | SQLite | Persisted locally per signed-in user |
| Custom category labels | SQLite | Persisted locally per signed-in user |

Transaction creation, editing, and deletion currently write to Firebase before updating the local cache. Full offline write synchronization and conflict resolution are not implemented yet.

## Tech Stack

- Flutter and Dart
- `flutter_riverpod` for application state
- Firebase Authentication and Cloud Firestore
- `sqflite` and `path` for local persistence
- `fl_chart` for spending visualizations
- `google_fonts` for typography
- Material 3 and custom theme extensions

## Project Structure

```text
lib/
|-- main.dart
|-- firebase_options.dart
|-- app/
|   `-- app.dart
|-- core/
|   |-- constants/
|   `-- theme/
`-- features/
    |-- auth/
    |   |-- providers/
    |   |-- screens/
    |   |-- services/
    |   `-- widgets/
    `-- dashboard/
        |-- models/
        |   |-- custom_category.dart
        |   |-- dashboard_summary.dart
        |   |-- dashboard_ui_models.dart
        |   `-- transaction.dart
        |-- providers/
        |   `-- dashboard_provider.dart
        |-- screens/
        |   |-- dashboard_screen.dart
        |   |-- new_transaction_screen.dart
        |   `-- new_transaction/
        |-- services/
        |   `-- local_finance_service.dart
        |-- utils/
        `-- widgets/
            |-- dashboard_tabs.dart
            `-- dashboard_tabs/
```

`dashboard_tabs.dart` and `new_transaction_screen.dart` are library entry points. Focused internal components use Dart `part` files so related private widgets remain scoped to their parent library without creating oversized files.

## Getting Started

### Requirements

- Flutter SDK compatible with Dart `^3.12.0`
- Android Studio or VS Code with Flutter support
- an emulator, simulator, or connected device
- access to the team Firebase project, or a separate Firebase project configured with FlutterFire

### Install and Run

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

If you use a different Firebase project, regenerate the platform configuration with FlutterFire before running the app.

## Quality Checks

```bash
dart format lib test
flutter analyze
flutter test
```

Focused coverage currently includes the dashboard summary calculation that separates all-time balance from current-month totals. Broader provider, persistence, and user-flow tests are still needed.

## Development Conventions

- Derive totals, percentages, warnings, and chart values from application state; do not hardcode financial data.
- Keep handwritten Dart files focused and preferably below 500 lines.
- Put reusable feature widgets in the relevant component folder.
- Keep financial calculations in pure helpers or models instead of embedding them in rendering code.
- Use the shared theme tokens and verify changes in both light and dark modes.
- Provide loading, empty, validation, and error states for new flows.
- Keep interactive controls at least 48dp where practical.
- Verify dashboard totals, charts, activity, budgets, Firebase data, and local cache behavior together after transaction changes.

## UI Direction

PocketWise uses a restrained modern-finance visual language inspired by Revolut, Wise, Apple Wallet, and modern investment dashboards:

- dark navy and cool white backgrounds
- layered blue-gray surfaces
- blue primary actions
- semantic green, amber, and red financial states
- strong typography hierarchy with tabular financial figures
- controlled corner radii, subtle borders, and minimal gradients
- spacing based on a consistent 4dp/8dp rhythm

## Known Gaps and Next Steps

1. Add a dedicated read-only transaction detail screen.
2. Add custom category editing, deletion, icon selection, and color selection.
3. Build weekly/monthly reports and category analytics.
4. Add CSV export and clear-all-data behavior.
5. Persist the selected theme preference.
6. Add transaction deletion undo.
7. Add offline write synchronization and conflict handling.
8. Expand unit, widget, provider, and persistence tests.

## Contributor Handoff

Start with `lib/features/dashboard/screens/dashboard_screen.dart` for navigation and provider wiring. Financial state is managed through `dashboard_provider.dart`, cloud transaction operations through `transaction_service.dart`, and device persistence through `local_finance_service.dart`.

When changing transaction behavior, verify the dashboard balance, monthly metrics, spending chart, recent activity, activity filters, budget progress, Firestore record, and SQLite cache remain consistent.
