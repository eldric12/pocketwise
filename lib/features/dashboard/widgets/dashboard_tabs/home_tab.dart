part of '../dashboard_tabs.dart';

List<ChartLegendItem> getMonthlyChartItems(List<Transaction> transactions) {
  final now = DateTime.now();

  final spendingByCategory = <String, double>{};

  for (final tx in transactions.where((tx) =>
      tx.isExpense &&
      tx.date.year == now.year &&
      tx.date.month == now.month)) {
    spendingByCategory.update(
      tx.categoryLabel,
      (value) => value + tx.amount,
      ifAbsent: () => tx.amount,
    );
  }

  return buildChartItems(spendingByCategory);
}

class HomeTab extends StatelessWidget {
  const HomeTab({
    super.key,
    required this.transactions,
    required this.budgetLimits,
    required this.onOpenReports,
    required this.onSeeAll,
    required this.onToggleTheme,
  });

  final List<Transaction> transactions;
  final Map<String, double> budgetLimits;
  final VoidCallback onOpenReports;
  final VoidCallback onSeeAll;
  final VoidCallback onToggleTheme;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final monthlyTransactions = transactions
        .where((tx) => tx.date.year == now.year && tx.date.month == now.month)
        .toList();
    final recent = transactions.take(3).toList();
    final income = monthlyTransactions
        .where((tx) => !tx.isExpense)
        .fold<double>(0, (sum, tx) => sum + tx.amount);
    final expense = monthlyTransactions
        .where((tx) => tx.isExpense)
        .fold<double>(0, (sum, tx) => sum + tx.amount);
    final balance = income - expense;

    final chartItems = getMonthlyChartItems(transactions);
    final budgetAlerts = _buildMonthlyBudgets(transactions, now, budgetLimits)
        .where(
          (budget) =>
              budget.limit != null &&
              budget.limit! > 0 &&
              budget.spent! / budget.limit! >= 0.8,
        )
        .toList()
      ..sort(
        (a, b) =>
            (b.spent! / b.limit!).compareTo(a.spent! / a.limit!),
      );
    final warningBudget = budgetAlerts.isEmpty ? null : budgetAlerts.first;

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 120),
          sliver: SliverList(
            delegate: SliverChildListDelegate(
              [
                HeaderSection(onToggleTheme: onToggleTheme),
                const SizedBox(height: 22),
                BalanceCard(
                  balance: balance,
                  income: income,
                  expense: expense,
                ),
                const SizedBox(height: 26),
                SectionHeader(
                  title: 'Spending overview',
                  actionLabel: 'Reports',
                  onAction: onOpenReports,
                ),
                const SizedBox(height: 12),
                OverviewCard(items: chartItems),
                const SizedBox(height: 26),
                SectionHeader(
                  title: 'Recent activity',
                  actionLabel: 'See all',
                  onAction: onSeeAll,
                ),
                const SizedBox(height: 12),
                if (recent.isEmpty)
                  const EmptyStateCard(
                    title: 'No transactions yet',
                    subtitle: 'Your latest activity will appear here once you add your first transaction.',
                  )
                else
                  TransactionCardList(transactions: recent),
                if (warningBudget != null) ...[
                  const SizedBox(height: 14),
                  BudgetWarningCard.fromBudget(warningBudget),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}
