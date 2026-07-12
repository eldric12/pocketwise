import 'dart:ui';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_colors.dart';
import '../models/dashboard_ui_models.dart';
import '../models/transaction.dart';
import '../utils/dashboard_ui_helpers.dart';
import 'dashboard_common_widgets.dart';

List<BudgetViewData> _buildMonthlyBudgets(
  List<Transaction> transactions,
  DateTime month,
  Map<String, double> budgetLimits,
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

  final categories = <String>{
    ...budgetLimits.keys,
    ...spending.keys,
  };
  return categories.map((category) {
    final spent = spending[category] ?? 0;
    final limit = budgetLimits[category];
    final ratio = limit == null || limit == 0 ? 0.0 : spent / limit;
    final color = ratio >= 1
        ? AppColors.danger
        : ratio >= 0.8
            ? AppColors.warning
            : AppColors.primary;
    return BudgetViewData(
      category: category,
      spent: spent,
      limit: limit,
      color: color,
    );
  }).toList();
}

class HomeTab extends StatelessWidget {
  const HomeTab({
    super.key,
    required this.transactions,
    required this.budgetLimits,
  });

  final List<Transaction> transactions;
  final Map<String, double> budgetLimits;

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
                  color: Colors.white,
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
              color: AppColors.mutedText,
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

class OverviewCard extends StatefulWidget {
  const OverviewCard({
    super.key,
    required this.items,
  });

  final List<ChartLegendItem> items;

  @override
  State<OverviewCard> createState() => _OverviewCardState();
}

class _OverviewCardState extends State<OverviewCard> {
  int _touchedIndex = -1;

  @override
  void didUpdateWidget(covariant OverviewCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_touchedIndex >= widget.items.length) _touchedIndex = -1;
  }

  @override
  Widget build(BuildContext context) {
    final items = widget.items;
    final total = items.fold<double>(0, (sum, item) => sum + item.amount);
    final selectedItem = _touchedIndex >= 0 ? items[_touchedIndex] : null;
    final centerLabel = selectedItem?.label.toUpperCase() ?? 'TOTAL EXP';
    final centerAmount = selectedItem?.amount ?? total;

    if (items.isEmpty) {
      return GlassPanel(
        child: SizedBox(
          height: 116,
          child: Row(
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Icon(
                  Icons.donut_large_rounded,
                  color: AppColors.primary,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'No spending this month',
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Add an expense to see your category breakdown.',
                      style: GoogleFonts.inter(
                        color: AppColors.mutedText,
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return GlassPanel(
      child: Row(
        children: [
          SizedBox(
            width: 142,
            height: 142,
            child: Stack(
              alignment: Alignment.center,
              children: [
                PieChart(
                  PieChartData(
                    sectionsSpace: 2,
                    centerSpaceRadius: 39,
                    startDegreeOffset: -90,
                    pieTouchData: PieTouchData(
                      touchCallback: (event, response) {
                        final touchedIndex = response
                                ?.touchedSection
                                ?.touchedSectionIndex ??
                            -1;
                        final nextIndex = event.isInterestedForInteractions
                            ? touchedIndex
                            : -1;
                        if (nextIndex != _touchedIndex) {
                          setState(() => _touchedIndex = nextIndex);
                        }
                      },
                    ),
                    sections: items
                        .asMap()
                        .entries
                        .map(
                          (entry) => PieChartSectionData(
                            value: entry.value.amount,
                            color: entry.value.color,
                            radius: entry.key == _touchedIndex ? 24 : 20,
                            showTitle: false,
                          ),
                        )
                        .toList(),
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 72,
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          centerLabel,
                          maxLines: 1,
                          style: GoogleFonts.inter(
                            color: const Color(0xFF8FB3E8),
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.7,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 3),
                    SizedBox(
                      width: 74,
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          'RM ${centerAmount.toStringAsFixed(0)}',
                          maxLines: 1,
                          style: GoogleFonts.spaceGrotesk(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            fontFeatures: const [FontFeature.tabularFigures()],
                          ),
                        ),
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
                  .asMap()
                  .entries
                  .map(
                    (entry) => MouseRegion(
                      onEnter: (_) {
                        setState(() => _touchedIndex = entry.key);
                      },
                      onExit: (_) {
                        setState(() => _touchedIndex = -1);
                      },
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () {
                          setState(() {
                            _touchedIndex = _touchedIndex == entry.key
                                ? -1
                                : entry.key;
                          });
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Row(
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: entry.value.color,
                                  borderRadius: BorderRadius.circular(99),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  '${entry.value.label} · RM${entry.value.amount.toStringAsFixed(0)}',
                                  style: GoogleFonts.inter(
                                    color: _touchedIndex == entry.key
                                        ? Colors.white
                                        : const Color(0xFFD7DEEA),
                                    fontSize: 13,
                                    fontWeight: _touchedIndex == entry.key
                                        ? FontWeight.w700
                                        : FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
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

class _SetBudgetDialog extends StatefulWidget {
  const _SetBudgetDialog({
    required this.category,
    this.currentLimit,
    this.onRemove,
  });

  final String category;
  final double? currentLimit;
  final VoidCallback? onRemove;

  @override
  State<_SetBudgetDialog> createState() => _SetBudgetDialogState();
}

class _SetBudgetDialogState extends State<_SetBudgetDialog> {
  late final TextEditingController _controller;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: widget.currentLimit?.toStringAsFixed(0) ?? '',
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.surface,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: Color(0xFF33435B)),
      ),
      title: Text(
        widget.currentLimit == null ? 'Set budget' : 'Edit budget',
        style: GoogleFonts.inter(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Monthly limit for ${widget.category}',
            style: GoogleFonts.inter(
              color: AppColors.mutedText,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _controller,
            autofocus: true,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d{0,7}(\.\d{0,2})?')),
            ],
            style: GoogleFonts.spaceGrotesk(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
            decoration: InputDecoration(
              labelText: 'Budget amount',
              prefixText: 'RM ',
              errorText: _errorText,
              filled: true,
              fillColor: AppColors.background,
              labelStyle: GoogleFonts.inter(color: AppColors.mutedText),
              prefixStyle: GoogleFonts.spaceGrotesk(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFF3A4960)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: AppColors.primary,
                  width: 1.5,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.danger),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.danger),
              ),
            ),
            onChanged: (_) {
              if (_errorText != null) setState(() => _errorText = null);
            },
            onSubmitted: (_) => _submit(),
          ),
        ],
      ),
      actionsAlignment: widget.onRemove == null
          ? MainAxisAlignment.end
          : MainAxisAlignment.spaceBetween,
      actions: [
        if (widget.onRemove != null)
          TextButton(
            onPressed: widget.onRemove,
            style: TextButton.styleFrom(foregroundColor: AppColors.danger),
            child: const Text('Remove'),
          ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            const SizedBox(width: 4),
            FilledButton(
              onPressed: _submit,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              child: const Text('Save'),
            ),
          ],
        ),
      ],
    );
  }

  void _submit() {
    final amount = double.tryParse(_controller.text.trim());
    if (amount == null || amount <= 0) {
      setState(() => _errorText = 'Enter an amount greater than RM 0.');
      return;
    }
    Navigator.pop(context, amount);
  }
}

class BudgetCard extends StatelessWidget {
  const BudgetCard({
    super.key,
    required this.data,
    required this.onSetBudget,
  });

  final BudgetViewData data;
  final VoidCallback onSetBudget;

  @override
  Widget build(BuildContext context) {
    final progress = data.limit == null || data.limit == 0
        ? 0.0
        : (data.spent! / data.limit!).clamp(0.0, 1.0).toDouble();
    final percentage = data.limit == null || data.limit == 0
        ? null
        : ((data.spent! / data.limit!) * 100).round();
    final overAmount = data.limit != null && data.spent! > data.limit!
        ? data.spent! - data.limit!
        : null;
    final badgeLabel = overAmount == null
        ? '$percentage%'
        : 'RM${overAmount == overAmount.roundToDouble() ? overAmount.toStringAsFixed(0) : overAmount.toStringAsFixed(2)} over';

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
            TextButton(
              onPressed: onSetBudget,
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primary,
                minimumSize: const Size(48, 44),
                padding: const EdgeInsets.symmetric(horizontal: 8),
              ),
              child: Text(
                data.limit == null ? '+ Set budget' : 'Edit',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
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
                            badgeLabel,
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
    this.color = AppColors.warning,
  });

  factory BudgetWarningCard.fromBudget(BudgetViewData budget) {
    final spent = budget.spent!;
    final limit = budget.limit!;
    final percentage = ((spent / limit) * 100).round();
    final isExceeded = spent >= limit;
    return BudgetWarningCard(
      title: isExceeded
          ? '${budget.category} budget exceeded'
          : '${budget.category} budget at $percentage%',
      subtitle:
          'RM${spent.toStringAsFixed(0)} of RM${limit.toStringAsFixed(0)} spent this month.',
      color: isExceeded ? AppColors.danger : AppColors.warning,
    );
  }

  final String title;
  final String subtitle;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.52),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: color.withValues(alpha: 0.75),
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
              color: color,
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
