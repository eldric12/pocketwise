part of '../dashboard_tabs.dart';

class ReportAnalytics extends StatefulWidget {
  const ReportAnalytics({
    super.key,
    required this.transactions
  });

  final List<Transaction> transactions;

  @override
  State<ReportAnalytics> createState() => _ReportAnalytics();
}

class _ReportAnalytics extends State<ReportAnalytics> {
  _TrendFilter _filter = _TrendFilter.monthly;

  void _setFilter(_TrendFilter filter) {
    setState(() => _filter = filter);
  }

  List<ChartLegendItem> get _trendItems {
    switch (_filter) {
      case _TrendFilter.weekly:
        return getWeeklyChartItems(widget.transactions, now);
      case _TrendFilter.monthly:
        return getDailyChartItems(widget.transactions, now);
      case _TrendFilter.yearly:
        return getYearlyChartItems(widget.transactions, now);
    }
  }

  List<ChartLegendItem> get _categoryItems {
    switch (_filter) {
      case _TrendFilter.weekly:
        return getWeeklyCategoryItems(widget.transactions, now);

      case _TrendFilter.monthly:
        return getMonthlyChartItems(widget.transactions, now);

      case _TrendFilter.yearly:
        return getYearlyCategoryItems(widget.transactions, now);
    }
  }
  
  IncomeExpenseItem get _incomeExpense {
    switch (_filter) {
      case _TrendFilter.weekly:
        return getWeeklyIncomeExpense(widget.transactions, now);

      case _TrendFilter.monthly:
        return getMonthlyIncomeExpense(widget.transactions, now);

      case _TrendFilter.yearly:
        return getYearlyIncomeExpense(widget.transactions, now);
    }
  }


  @override
  Widget build(BuildContext context) {

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
          ))
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
                  selected: _filter == _TrendFilter.weekly,
                  onTap: () => _setFilter(_TrendFilter.weekly),
                ),
                FilterChipCard(
                  label: 'Monthly',
                  selected: _filter == _TrendFilter.monthly,
                  onTap: () => _setFilter(_TrendFilter.monthly),
                ),
                FilterChipCard(
                  label: 'Yearly',
                  selected: _filter == _TrendFilter.yearly,
                  onTap: () => _setFilter(_TrendFilter.yearly),
                ),
                CircleIconButton(
                  icon: Icons.calendar_month,
                  onPressed: () {

                  },
                )
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
              GlassPanel(
                child: LineChartCard(items: _trendItems)
              ),
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
            BarChartCard(data: _incomeExpense)
          ],
        ),
      )
    );
  }
}