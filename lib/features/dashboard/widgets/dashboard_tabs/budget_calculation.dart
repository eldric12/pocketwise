part of '../dashboard_tabs.dart';

List<BudgetViewData> _buildMonthlyBudgets(
  List<Transaction> transactions,
  DateTime month,
  Map<String, double> budgetLimits,
  List<CategoryDefinition> categories,
  Brightness brightness,
) {
  final spending = <String, double>{};
  for (final transaction in transactions.where(
    (transaction) =>
        transaction.isExpense &&
        transaction.date.year == month.year &&
        transaction.date.month == month.month,
  )) {
    spending.update(
      transaction.categoryLabel,
      (amount) => amount + transaction.amount,
      ifAbsent: () => transaction.amount,
    );
  }

  final categoryNames = <String>{...budgetLimits.keys, ...spending.keys};
  return categoryNames.map((category) {
    final spent = spending[category] ?? 0;
    final limit = budgetLimits[category];
    final ratio = limit == null || limit == 0 ? 0.0 : spent / limit;
    final categoryColor = categoryVisual(
      category,
      isExpense: true,
      categories: categories,
      brightness: brightness,
    ).foreground;
    final color = ratio >= 1
        ? AppColors.danger
        : ratio >= 0.8
        ? AppColors.warning
        : categoryColor;
    return BudgetViewData(
      category: category,
      spent: spent,
      limit: limit,
      color: color,
    );
  }).toList();
}
