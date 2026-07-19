import 'package:flutter_test/flutter_test.dart';
import 'package:pocketwise/features/dashboard/models/dashboard_summary.dart';
import 'package:pocketwise/features/dashboard/models/transaction.dart';

void main() {
  test('separates all-time balance from current-month totals', () {
    final transactions = [
      _transaction(amount: 1000, date: DateTime(2026, 6, 10)),
      _transaction(amount: 200, date: DateTime(2026, 6, 11), isExpense: true),
      _transaction(amount: 500, date: DateTime(2026, 7, 1)),
      _transaction(amount: 125, date: DateTime(2026, 7, 2), isExpense: true),
      _transaction(amount: 900, date: DateTime(2025, 7, 2), isExpense: true),
    ];

    final summary = DashboardSummary.fromTransactions(
      transactions,
      month: DateTime(2026, 7, 19),
    );

    expect(summary.currentBalance, 275);
    expect(summary.monthlyIncome, 500);
    expect(summary.monthlyExpense, 125);
  });

  test('returns zero values when there are no transactions', () {
    final summary = DashboardSummary.fromTransactions(
      const [],
      month: DateTime(2026, 7, 19),
    );

    expect(summary.currentBalance, 0);
    expect(summary.monthlyIncome, 0);
    expect(summary.monthlyExpense, 0);
  });
}

Transaction _transaction({
  required double amount,
  required DateTime date,
  bool isExpense = false,
}) {
  return Transaction(
    id: '${date.toIso8601String()}-$amount-$isExpense',
    title: 'Test transaction',
    amount: amount,
    date: date,
    categoryId: isExpense ? 'food' : 'salary',
    categoryLabel: isExpense ? 'Food' : 'Salary',
    isExpense: isExpense,
  );
}
