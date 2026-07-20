part of '../dashboard_tabs.dart';

class HomeTab extends StatelessWidget {
  const HomeTab({
    super.key,
    required this.transactions,
    required this.categories,
    required this.budgetLimits,
    required this.userName,
    required this.onTransactionTap,
    required this.onOpenReports,
    required this.onSeeAll,
    required this.onToggleTheme,
  });

  final List<Transaction> transactions;
  final List<CategoryDefinition> categories;
  final Map<String, double> budgetLimits;
  final String? userName;
  final ValueChanged<Transaction> onTransactionTap;
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
    final summary = DashboardSummary.fromTransactions(transactions, month: now);
    final spendingByCategory = <String, double>{};

    for (final tx in monthlyTransactions.where((tx) => tx.isExpense)) {
      spendingByCategory.update(
        tx.categoryLabel,
        (value) => value + tx.amount,
        ifAbsent: () => tx.amount,
      );
    }

    final chartItems = buildChartItems(
      spendingByCategory,
      categories: categories,
      brightness: Theme.of(context).brightness,
    );
    final budgetAlerts =
        _buildMonthlyBudgets(
              transactions,
              now,
              budgetLimits,
              categories,
              Theme.of(context).brightness,
            )
            .where(
              (budget) =>
                  budget.limit != null &&
                  budget.limit! > 0 &&
                  budget.spent! / budget.limit! >= 0.8,
            )
            .toList()
          ..sort(
            (a, b) => (b.spent! / b.limit!).compareTo(a.spent! / a.limit!),
          );
    final warningBudget = budgetAlerts.isEmpty ? null : budgetAlerts.first;

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 120),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              HeaderSection(userName: userName, onToggleTheme: onToggleTheme),
              const SizedBox(height: 22),
              BalanceCard(
                currentBalance: summary.currentBalance,
                monthlyIncome: summary.monthlyIncome,
                monthlyExpense: summary.monthlyExpense,
              ),
              const SizedBox(height: 26),
              SectionHeader(
                title: 'Spending this month',
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
                  subtitle:
                      'Your latest activity will appear here once you add your first transaction.',
                )
              else
                TransactionCardList(
                  transactions: recent,
                  categories: categories,
                  onTransactionTap: onTransactionTap,
                ),
              if (warningBudget != null) ...[
                const SizedBox(height: 14),
                BudgetWarningCard.fromBudget(warningBudget),
              ],
            ]),
          ),
        ),
      ],
    );
  }
}
