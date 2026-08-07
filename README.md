# PocketWise Flutter App

PocketWise is a student-focused personal finance application for recording income and expenses, understanding spending habits, and monitoring monthly category budgets. The app combines Firebase-backed accounts with a locally cached Flutter experience and a premium light/dark fintech interface.

## Current Features

### Accounts and Data

- Firebase email/password registration and sign-in, with input validated for completeness, email format, minimum password length, and matching confirmation
- forgot-password flow with a non-disclosing reset confirmation
- automatic session check on startup (auto-login for an already-authenticated user)
- confirmed logout that clears the session and returns to Login
- per-user Firestore transaction and budget storage
- user-aware dashboard greeting from the saved profile name
- user-scoped SQLite cache for transactions, budgets, and categories, with local fallback on startup

### Transactions

- add income and expense transactions
- record amount, category, date, payment method, and optional notes
- custom amount keypad and type-aware visual styling
- edit existing transactions with prefilled values
- delete transactions through a confirmation flow
- view all transactions grouped by their actual calendar date
- sort transactions newest-first or oldest-first
- combine type, date-range, and category filters
- filter by all dates, today, the past seven days, or this month

### Categories

- predefined categories (Food, Transport, Bills, Salary, Entertainment, and more)
- add custom categories with an assignable icon and color
- category names are locked after creation (transactions and budgets reference them by label); icon and color remain editable at any time

### Dashboard and Budgets

- all-time current balance calculated as total income minus total expenses
- clearly separated current-month income and expense totals
- current-month spending donut chart derived by category
- interactive chart slices and legend rows
- recent transaction preview with navigation to the full activity list
- editable monthly category budget limits
- dynamic progress bars and near-limit or overspending warnings
- useful empty states when transaction, chart, or budget data is unavailable

### Reports and Analytics

- weekly, monthly, and yearly spending trend charts
- category-wise breakdown as a pie/donut chart
- income vs expense comparison over the selected period
- explanatory empty states when a period has no data

### Settings

- light/dark theme switching (applied immediately app-wide)
- CSV export of transaction history
- clear-all-data with a confirmation step, restoring the predefined categories

### Experience

- premium dark navy visual system and accessible light theme
- animated light/dark theme switching
- responsive mobile layouts with safe-area-aware bottom navigation
- modular dashboard and transaction screen components
- semantic labels and minimum touch-target considerations

## Data Persistence

PocketWise uses a hybrid, local-first persistence model:

| Data | Primary storage | Behavior |
| --- | --- | --- |
| User accounts and profile names | Firebase Authentication | Firebase-managed session data |
| Transactions and budgets | SQLite (local), synced to Cloud Firestore | Writes go to SQLite first and update the UI immediately; Firestore sync is then attempted in the background and retried on next load if it fails |
| Custom category labels, icons, colors | SQLite only | Not synced to Firestore; local to the device |

On startup, the app loads from the local SQLite cache first (so the dashboard is usable instantly and offline), then refreshes transactions and budgets from Firestore in the background if a connection is available.

## Tech Stack

- Flutter and Dart
- `flutter_riverpod` for application state
- Firebase Authentication and Cloud Firestore
- `sqflite` and `path` for local persistence
- `fl_chart` for spending visualizations
- `go_router` for navigation
- `google_fonts` and `lucide_icons` for typography and iconography
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
|   |   `-- app_colors.dart
|   `-- theme/
|       `-- app_theme_colors.dart
`-- features/
    |-- auth/
    |   |-- providers/
    |   |   `-- auth_provider.dart
    |   |-- screens/
    |   |   |-- splash_screen.dart
    |   |   |-- login_screen.dart
    |   |   |-- signup_screen.dart
    |   |   `-- forgot_password_screen.dart
    |   |-- services/
    |   |   |-- auth_service.dart
    |   |   `-- transaction_service.dart
    |   `-- widgets/
    |       `-- auth_header_wave.dart
    `-- dashboard/
        |-- models/
        |   |-- category_definition.dart
        |   |-- dashboard_summary.dart
        |   |-- dashboard_ui_models.dart
        |   `-- transaction.dart
        |-- providers/
        |   `-- dashboard_provider.dart
        |-- services/
        |   `-- local_finance_service.dart
        |-- screens/
        |   |-- dashboard_screen.dart
        |   |-- manage_categories_screen.dart
        |   |-- new_transaction_screen.dart
        |   `-- new_transaction/
        |       |-- amount_controls.dart
        |       |-- category_controls.dart
        |       `-- detail_controls.dart
        |-- utils/
        |   |-- category_catalog.dart
        |   |-- csv_exporter.dart
        |   |-- csv_downloader.dart / csv_downloader_web.dart / csv_downloader_stub.dart
        |   `-- dashboard_ui_helpers.dart
        `-- widgets/
            |-- category_editor_sheet.dart
            |-- dashboard_common_widgets.dart
            |-- dashboard_navigation.dart
            |-- dashboard_tabs.dart
            `-- dashboard_tabs/
                |-- home_tab.dart / home_summary_widgets.dart / quick_statistics_widget.dart
                |-- activity_tab.dart / transaction_widgets.dart
                |-- budgets_tab.dart / budget_widgets.dart / budget_calculation.dart
                |-- report_analytics.dart / spending_overview.dart / spending_chart_calculation.dart
                |-- setting_tab.dart
                `-- more_tab.dart
```

`dashboard_tabs.dart` and `new_transaction_screen.dart` are library entry points. Focused internal components use Dart `part` files so related private widgets remain scoped to their parent library without creating oversized files.

## Getting Started

### Requirements

- Flutter SDK compatible with Dart `^3.12.0` (Flutter `^3.44.0`)
- Android Studio or VS Code with Flutter support
- an emulator, simulator, or connected device
- access to the team Firebase project, or a separate Firebase project configured with FlutterFire

### Install and Run

From the repository root:

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

1. Add a dedicated read-only transaction detail screen (currently reuses the edit screen).
2. Allow a budget to be set for a category before any expense is recorded under it.
3. Persist the selected theme preference across app restarts.
4. Reduce the Splash screen's fixed startup delay so cold start meets the 2-second dashboard-load target.
5. Rename the "Total Spending" dashboard label to "Current Balance" to match the value it displays.
6. Allow category names to be renamed (currently locked after creation to preserve label-based links to transactions and budgets).
7. Add offline write-conflict resolution for transactions/budgets edited on multiple devices while offline.
8. Expand unit, widget, provider, and persistence test coverage.

## Contributor Handoff

Start with `lib/features/dashboard/screens/dashboard_screen.dart` for navigation and provider wiring. Financial state is managed through `dashboard_provider.dart`, cloud transaction operations through `transaction_service.dart`, and device persistence through `local_finance_service.dart`.

When changing transaction behavior, verify the dashboard balance, monthly metrics, spending chart, recent activity, activity filters, budget progress, Firestore record, and SQLite cache remain consistent.
