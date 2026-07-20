part of '../dashboard_tabs.dart';

class QuickStatisticsCard extends StatelessWidget {
  const QuickStatisticsCard({super.key, required this.stats});

  final QuickStatistics stats;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: context.themeColors.expenseText.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.attach_money_outlined),
          ),
          title: Text(
            'Highest Expense',
            style: GoogleFonts.inter(
              color: context.themeColors.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
          ),
          subtitle: Text(
            stats.highestExpense?.categoryLabel ?? 'No expense',
            style: GoogleFonts.inter(
              color: context.themeColors.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w400,
            ),
          ),
          trailing: Text(
            stats.highestExpense == null
                ? '-'
                : '-RM${stats.highestExpense!.amount.toStringAsFixed(2)}',
            style: GoogleFonts.inter(
              color: Colors.red,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          tileColor: context.themeColors.expenseBackground,
          onTap: () {},
        ),
        const SizedBox(height: 12),
        ListTile(
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: context.themeColors.incomeText.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.wallet_outlined),
          ),
          title: Text(
            'Highest Income',
            style: GoogleFonts.inter(
              color: context.themeColors.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
          ),
          subtitle: Text(
            stats.highestIncome?.categoryLabel ?? 'No income',
            style: GoogleFonts.inter(
              color: context.themeColors.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w400,
            ),
          ),
          trailing: Text(
            stats.highestIncome == null
                ? '-'
                : '+RM${stats.highestIncome!.amount.toStringAsFixed(2)}',
            style: GoogleFonts.inter(
              color: Colors.green,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          tileColor: context.themeColors.incomeBackground,
          onTap: () {},
        ),
        const SizedBox(height: 12),
        ListTile(
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: context.themeColors.categoryText.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.category),
          ),
          title: Text(
            'Most used category',
            style: GoogleFonts.inter(
              color: context.themeColors.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
          ),
          subtitle: Text(
            stats.mostUsedCategory ?? '',
            style: GoogleFonts.inter(
              color: context.themeColors.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w400,
            ),
          ),
          trailing: Text(stats.mostUsedCategory ?? '-'),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          tileColor: context.themeColors.categoryBackground,
          onTap: () {},
        ),
        const SizedBox(height: 12),
        ListTile(
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: context.themeColors.warningText.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.wallet_outlined),
          ),
          title: Text(
            'Average Daily Spending',
            style: GoogleFonts.inter(
              color: context.themeColors.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
          ),
          subtitle: const Text(''),
          trailing: Text(
            stats.averageDailySpending == 0
                ? '-'
                : '- RM${stats.averageDailySpending.toStringAsFixed(2)}',
            style: GoogleFonts.inter(
              color: context.themeColors.warningText,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          tileColor: context.themeColors.warningBackground,
          onTap: () {},
        ),
      ],
    );
  }
}
