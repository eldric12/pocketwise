part of '../dashboard_tabs.dart';

class BudgetsTab extends StatelessWidget {
  const BudgetsTab({
    super.key,
    required this.transactions,
    required this.budgetLimits,
    required this.onSetBudget,
    required this.onRemoveBudget,
  });

  final List<Transaction> transactions;
  final Map<String, double> budgetLimits;
  final void Function(String category, double limit) onSetBudget;
  final ValueChanged<String> onRemoveBudget;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final budgets = _buildMonthlyBudgets(transactions, now, budgetLimits);

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 120),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Budgets',
                style: GoogleFonts.inter(
                  color: context.themeColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const Spacer(),
              MonthPill(label: _monthName(now.month)),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Monthly limits per category — warned before you overspend.',
            style: GoogleFonts.inter(
              color: context.themeColors.textSecondary,
              fontSize: 13,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 22),
          if (budgets.isEmpty)
            const EmptyStateCard(
              title: 'No budget categories yet',
              subtitle: 'Add an expense first, then set a monthly limit for its category.',
            )
          else
            ...budgets.map(
              (budget) => Padding(
                padding: const EdgeInsets.only(bottom: 18),
                child: BudgetCard(
                  data: budget,
                  onSetBudget: () => _openBudgetDialog(context, budget),
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _monthName(int month) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return months[month - 1];
  }

  Future<void> _openBudgetDialog(
    BuildContext context,
    BudgetViewData budget,
  ) async {
    final result = await showDialog<double>(
      context: context,
      builder: (context) => _SetBudgetDialog(
        category: budget.category,
        currentLimit: budget.limit,
        onRemove: budget.limit == null
            ? null
            : () {
                onRemoveBudget(budget.category);
                Navigator.pop(context);
              },
      ),
    );
    if (result != null) onSetBudget(budget.category, result);
  }
}



