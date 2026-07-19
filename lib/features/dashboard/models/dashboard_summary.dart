import 'transaction.dart';

class DashboardSummary {
  const DashboardSummary({
    required this.currentBalance,
    required this.monthlyIncome,
    required this.monthlyExpense,
  });

  final double currentBalance;
  final double monthlyIncome;
  final double monthlyExpense;

  factory DashboardSummary.fromTransactions(
    Iterable<Transaction> transactions, {
    required DateTime month,
  }) {
    var totalIncome = 0.0;
    var totalExpense = 0.0;
    var monthlyIncome = 0.0;
    var monthlyExpense = 0.0;

    for (final transaction in transactions) {
      final isInSelectedMonth =
          transaction.date.year == month.year &&
          transaction.date.month == month.month;

      if (transaction.isExpense) {
        totalExpense += transaction.amount;
        if (isInSelectedMonth) monthlyExpense += transaction.amount;
      } else {
        totalIncome += transaction.amount;
        if (isInSelectedMonth) monthlyIncome += transaction.amount;
      }
    }

    return DashboardSummary(
      currentBalance: totalIncome - totalExpense,
      monthlyIncome: monthlyIncome,
      monthlyExpense: monthlyExpense,
    );
  }
}
