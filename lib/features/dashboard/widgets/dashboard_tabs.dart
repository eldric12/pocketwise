import 'dart:ui';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_colors.dart';
import '../models/dashboard_ui_models.dart';
import '../models/transaction.dart';
import '../utils/dashboard_ui_helpers.dart';
import 'dashboard_common_widgets.dart';

class HomeTab extends StatelessWidget {
  const HomeTab({super.key, required this.transactions});

  final List<Transaction> transactions;

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
    final spendingByCategory = <String, double>{};

    for (final tx in monthlyTransactions.where((tx) => tx.isExpense)) {
      spendingByCategory.update(
        tx.categoryLabel,
        (value) => value + tx.amount,
        ifAbsent: () => tx.amount,
      );
    }

    final chartItems = buildChartItems(spendingByCategory);

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 120),
          sliver: SliverList(
            delegate: SliverChildListDelegate(
              [
                const HeaderSection(),
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
                  onAction: () {},
                ),
                const SizedBox(height: 12),
                OverviewCard(items: chartItems),
                const SizedBox(height: 26),
                SectionHeader(
                  title: 'Recent activity',
                  actionLabel: 'See all',
                  onAction: () {},
                ),
                const SizedBox(height: 12),
                if (recent.isEmpty)
                  const EmptyStateCard(
                    title: 'No transactions yet',
                    subtitle: 'Your latest activity will appear here once you add your first transaction.',
                  )
                else
                  TransactionCardList(transactions: recent),
                const SizedBox(height: 14),
                const BudgetWarningCard(
                  title: 'Food budget at 87%',
                  subtitle: 'RM244 of RM280 spent this month.',
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class ActivityTab extends StatelessWidget {
  const ActivityTab({super.key, required this.transactions});

  final List<Transaction> transactions;

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final startOfToday = DateTime(today.year, today.month, today.day);
    final startOfYesterday = startOfToday.subtract(const Duration(days: 1));

    final todayItems = transactions
        .where(
          (tx) => tx.date.isAfter(startOfToday.subtract(const Duration(seconds: 1))),
        )
        .toList();
    final yesterdayItems = transactions
        .where(
          (tx) =>
              tx.date.isAfter(startOfYesterday.subtract(const Duration(seconds: 1))) &&
              tx.date.isBefore(startOfToday),
        )
        .toList();

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 120),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Transactions',
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const Spacer(),
              const CircleIconButton(icon: Icons.swap_vert_rounded),
            ],
          ),
          const SizedBox(height: 20),
          const Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              FilterChipCard(label: 'All', selected: true),
              FilterChipCard(label: 'Income'),
              FilterChipCard(label: 'Expense'),
              FilterChipCard(label: 'This month'),
            ],
          ),
          const SizedBox(height: 24),
          if (transactions.isEmpty)
            const EmptyStateCard(
              title: 'Nothing to review',
              subtitle: 'Your transactions, filters, and history will show up here once you start logging activity.',
            )
          else ...[
            ActivityGroup(title: 'Today', transactions: todayItems),
            const SizedBox(height: 18),
            ActivityGroup(title: 'Yesterday', transactions: yesterdayItems),
          ],
        ],
      ),
    );
  }
}

class BudgetsTab extends StatelessWidget {
  const BudgetsTab({super.key, required this.transactions});

  final List<Transaction> transactions;

  @override
  Widget build(BuildContext context) {
    final budgets = [
      const BudgetViewData(
        category: 'Food',
        spent: 244,
        limit: 280,
        color: AppColors.warning,
      ),
      const BudgetViewData(
        category: 'Transport',
        spent: 149,
        limit: 150,
        color: AppColors.danger,
      ),
      const BudgetViewData(
        category: 'Bills',
        spent: 152,
        limit: 300,
        color: AppColors.primary,
      ),
      const BudgetViewData(category: 'Shopping'),
    ];

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
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const Spacer(),
              const MonthPill(label: 'July'),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Monthly limits per category — warned before you overspend.',
            style: GoogleFonts.inter(
              color: AppColors.mutedText,
              fontSize: 13,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 22),
          ...budgets.map(
            (budget) => Padding(
              padding: const EdgeInsets.only(bottom: 18),
              child: BudgetCard(data: budget),
            ),
          ),
        ],
      ),
    );
  }
}

class MoreTab extends StatelessWidget {
  const MoreTab({
    super.key,
    required this.onOpenReports,
  });

  final VoidCallback onOpenReports;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 120),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'More',
            style: GoogleFonts.inter(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 16),
          GlassPanel(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                MoreRow(
                  icon: Icons.swap_vert_rounded,
                  label: 'Reports & analytics',
                  onTap: onOpenReports,
                ),
                const PanelDivider(),
                MoreRow(
                  icon: Icons.grid_view_rounded,
                  label: 'Manage categories',
                  onTap: () {},
                ),
                const PanelDivider(),
                MoreRow(
                  icon: Icons.settings_outlined,
                  label: 'Settings',
                  onTap: () {},
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class HeaderSection extends StatelessWidget {
  const HeaderSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'This month',
              style: GoogleFonts.inter(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.w800,
                height: 1.05,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Your money at a glance',
              style: GoogleFonts.inter(
                color: AppColors.mutedText,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const Spacer(),
        const CircleIconButton(icon: Icons.dark_mode_outlined),
      ],
    );
  }
}

class BalanceCard extends StatelessWidget {
  const BalanceCard({
    super.key,
    required this.balance,
    required this.income,
    required this.expense,
  });

  final double balance;
  final double income;
  final double expense;

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Total balance',
            style: GoogleFonts.inter(
              color: AppColors.mutedText,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            formatAmount(balance, signed: false),
            style: GoogleFonts.spaceGrotesk(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.w700,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: MetricTile(
                  label: 'Income',
                  amount: income,
                  positive: true,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: MetricTile(
                  label: 'Expense',
                  amount: expense,
                  positive: false,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class MetricTile extends StatelessWidget {
  const MetricTile({
    super.key,
    required this.label,
    required this.amount,
    required this.positive,
  });

  final String label;
  final double amount;
  final bool positive;

  @override
  Widget build(BuildContext context) {
    final color = positive ? AppColors.success : AppColors.danger;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              positive ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded,
              color: color,
              size: 14,
            ),
            const SizedBox(width: 5),
            Text(
              label,
              style: GoogleFonts.inter(
                color: AppColors.mutedText,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          formatAmount(amount, signed: true, positive: positive),
          style: GoogleFonts.spaceGrotesk(
            color: color,
            fontSize: 18,
            fontWeight: FontWeight.w700,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
      ],
    );
  }
}

class OverviewCard extends StatelessWidget {
  const OverviewCard({
    super.key,
    required this.items,
  });

  final List<ChartLegendItem> items;

  @override
  Widget build(BuildContext context) {
    final total = items.fold<double>(0, (sum, item) => sum + item.amount);

    return GlassPanel(
      child: Row(
        children: [
          SizedBox(
            width: 126,
            height: 126,
            child: Stack(
              alignment: Alignment.center,
              children: [
                PieChart(
                  PieChartData(
                    sectionsSpace: 2,
                    centerSpaceRadius: 32,
                    startDegreeOffset: -90,
                    sections: items
                        .map(
                          (item) => PieChartSectionData(
                            value: item.amount,
                            color: item.color,
                            radius: 18,
                            showTitle: false,
                          ),
                        )
                        .toList(),
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'RM${total.toStringAsFixed(0)}',
                      style: GoogleFonts.spaceGrotesk(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                    Text(
                      'this month',
                      style: GoogleFonts.inter(
                        color: AppColors.mutedText,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: items
                  .map(
                    (item) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: item.color,
                              borderRadius: BorderRadius.circular(99),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              '${item.label} · RM${item.amount.toStringAsFixed(0)}',
                              style: GoogleFonts.inter(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class TransactionCardList extends StatelessWidget {
  const TransactionCardList({
    super.key,
    required this.transactions,
  });

  final List<Transaction> transactions;

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          for (var i = 0; i < transactions.length; i++) ...[
            TransactionRow(transaction: transactions[i]),
            if (i != transactions.length - 1) const PanelDivider(),
          ],
        ],
      ),
    );
  }
}

class ActivityGroup extends StatelessWidget {
  const ActivityGroup({
    super.key,
    required this.title,
    required this.transactions,
  });

  final String title;
  final List<Transaction> transactions;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.inter(
            color: AppColors.mutedText,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 10),
        if (transactions.isEmpty)
          const EmptyStateCard(
            title: 'No transactions here',
            subtitle: 'This section stays clean until matching activity is available.',
          )
        else
          TransactionCardList(transactions: transactions),
      ],
    );
  }
}

class TransactionRow extends StatelessWidget {
  const TransactionRow({
    super.key,
    required this.transaction,
  });

  final Transaction transaction;

  @override
  Widget build(BuildContext context) {
    final visual = categoryVisual(transaction.categoryLabel);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: visual.background,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              visual.icon,
              color: visual.foreground,
              size: 18,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.title,
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    height: 1.15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${transaction.categoryLabel} · ${transaction.paymentMethod}',
                  style: GoogleFonts.inter(
                    color: AppColors.mutedText,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            formatAmount(
              transaction.amount,
              signed: true,
              positive: !transaction.isExpense,
            ),
            style: GoogleFonts.spaceGrotesk(
              color: transaction.isExpense ? AppColors.danger : AppColors.success,
              fontSize: 18,
              fontWeight: FontWeight.w700,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}

class BudgetCard extends StatelessWidget {
  const BudgetCard({
    super.key,
    required this.data,
  });

  final BudgetViewData data;

  @override
  Widget build(BuildContext context) {
    final progress = data.limit == null || data.limit == 0
        ? 0.0
        : (data.spent! / data.limit!).clamp(0.0, 1.0).toDouble();
    final percentage = data.limit == null || data.limit == 0
        ? null
        : ((data.spent! / data.limit!) * 100).round();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              data.category,
              style: GoogleFonts.inter(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
            const Spacer(),
            if (data.limit == null)
              Text(
                '+ Set budget',
                style: GoogleFonts.inter(
                  color: AppColors.primary,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
          ],
        ),
        const SizedBox(height: 10),
        GlassPanel(
          child: data.limit == null
              ? Text(
                  'No budget set — spending shown without a limit.',
                  style: GoogleFonts.inter(
                    color: AppColors.mutedText,
                    fontSize: 14,
                  ),
                )
              : Column(
                  children: [
                    Row(
                      children: [
                        Text(
                          'RM ${data.spent!.toStringAsFixed(0)}',
                          style: GoogleFonts.spaceGrotesk(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            fontFeatures: const [FontFeature.tabularFigures()],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '/ RM ${data.limit!.toStringAsFixed(0)}',
                          style: GoogleFonts.inter(
                            color: AppColors.mutedText,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: data.color.withValues(alpha: 0.16),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            '$percentage%',
                            style: GoogleFonts.inter(
                              color: data.color,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(999),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 8,
                        backgroundColor: Colors.white.withValues(alpha: 0.05),
                        valueColor: AlwaysStoppedAnimation<Color>(data.color),
                      ),
                    ),
                  ],
                ),
        ),
      ],
    );
  }
}

class BudgetWarningCard extends StatelessWidget {
  const BudgetWarningCard({
    super.key,
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.52),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: AppColors.warning.withValues(alpha: 0.75),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Icon(
              Icons.warning_amber_rounded,
              color: AppColors.warning,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  style: GoogleFonts.inter(
                    color: AppColors.mutedText,
                    fontSize: 14,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
