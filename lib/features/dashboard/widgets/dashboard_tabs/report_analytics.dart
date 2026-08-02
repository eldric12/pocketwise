part of '../dashboard_tabs.dart';

class ReportAnalytics extends StatefulWidget {
  const ReportAnalytics({
    super.key,
    required this.transactions,
    required this.categories,
  });

  final List<Transaction> transactions;
  final List<CategoryDefinition> categories;

  @override
  State<ReportAnalytics> createState() => _ReportAnalytics();
}

class _ReportAnalytics extends State<ReportAnalytics> {
  TrendFilter _filter = TrendFilter.monthly;

  void _setFilter(TrendFilter filter) {
    setState(() => _filter = filter);
  }

  List<ChartLegendItem> get _trendItems {
    final now = DateTime.now();
    switch (_filter) {
      case TrendFilter.weekly:
        return getWeeklyChartItems(widget.transactions, now);
      case TrendFilter.monthly:
        return getDailyChartItems(widget.transactions, now);
      case TrendFilter.yearly:
        return getYearlyChartItems(widget.transactions, now);
    }
  }

  List<ChartLegendItem> get _categoryItems {
    final now = DateTime.now();
    switch (_filter) {
      case TrendFilter.weekly:
        return getWeeklyCategoryItems(
          widget.transactions,
          now,
          widget.categories,
          Theme.of(context).brightness,
        );

      case TrendFilter.monthly:
        return getMonthlyChartItems(
          widget.transactions,
          now,
          widget.categories,
          Theme.of(context).brightness,
        );

      case TrendFilter.yearly:
        return getYearlyCategoryItems(
          widget.transactions,
          now,
          widget.categories,
          Theme.of(context).brightness,
        );
    }
  }

  IncomeExpenseItem get _incomeExpense {
    final now = DateTime.now();
    switch (_filter) {
      case TrendFilter.weekly:
        return getWeeklyIncomeExpense(widget.transactions, now);

      case TrendFilter.monthly:
        return getMonthlyIncomeExpense(widget.transactions, now);

      case TrendFilter.yearly:
        return getYearlyIncomeExpense(widget.transactions, now);
    }
  }

  QuickStatistics get _statistics {
    final now = DateTime.now();
    switch (_filter) {
      case TrendFilter.weekly:
        return getWeeklyStatistics(widget.transactions, now);

      case TrendFilter.monthly:
        return getMonthlyStatistics(widget.transactions, now);

      case TrendFilter.yearly:
        return getYearlyStatistics(widget.transactions, now);
    }
  }

  @override
  Widget build(BuildContext context) {
    final stats = _statistics;

    return Scaffold(
      backgroundColor: context.themeColors.background,
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.only(left: 12),
          child: CircleIconButton(
            icon: Icons.arrow_back_ios,
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ),
        backgroundColor: context.themeColors.background,
        title: Text(
          'Reports & Analytics',
          style: GoogleFonts.inter(
            color: context.themeColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 120),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                FilterChipCard(
                  label: 'Weekly',
                  selected: _filter == TrendFilter.weekly,
                  onTap: () => _setFilter(TrendFilter.weekly),
                ),
                FilterChipCard(
                  label: 'Monthly',
                  selected: _filter == TrendFilter.monthly,
                  onTap: () => _setFilter(TrendFilter.monthly),
                ),
                FilterChipCard(
                  label: 'Yearly',
                  selected: _filter == TrendFilter.yearly,
                  onTap: () => _setFilter(TrendFilter.yearly),
                ),
              ],
            ),
            const SizedBox(height: 26),
            Text(
              'Spending trend',
              style: GoogleFonts.inter(
                color: context.themeColors.textPrimary,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            if (_trendItems.every((e) => e.amount == 0))
              const EmptyStateCard(
                title: 'No spending data',
                subtitle: 'No expenses found for this period.',
              )
            else
              GlassPanel(child: LineChartCard(items: _trendItems)),
            const SizedBox(height: 26),
            Text(
              'Category breakdown',
              style: GoogleFonts.inter(
                color: context.themeColors.textPrimary,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            OverviewCard(items: _categoryItems),
            const SizedBox(height: 26),
            Text(
              'Income Vs Expense',
              style: GoogleFonts.inter(
                color: context.themeColors.textPrimary,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            BarChartCard(data: _incomeExpense),
            const SizedBox(height: 26),
            Text(
              'Quick Statistic',
              style: GoogleFonts.inter(
                color: context.themeColors.textPrimary,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            QuickStatisticsCard(stats: stats),
          ],
        ),
      ),
    );
  }
}