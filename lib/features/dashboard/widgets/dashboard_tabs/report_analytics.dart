part of '../dashboard_tabs.dart';

enum _TrendFilter { weekly, monthly, yearly }

List<ChartLegendItem> getWeeklyChartItems(List<Transaction> transactions) {
  final now = DateTime.now();
  final startOfWeek = DateTime(now.year, now.month, now.day)
      .subtract(Duration(days: now.weekday - 1)); // Monday
  const weekdayLabels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  final spendingByDay = <int, double>{for (var i = 0; i < 7; i++) i: 0};

  for (final tx in transactions.where((tx) => tx.isExpense)) {
    final diff = tx.date.difference(startOfWeek).inDays;
    if (diff >= 0 && diff < 7) {
      spendingByDay[diff] = (spendingByDay[diff] ?? 0) + tx.amount;
    }
  }

  return List.generate(
    7,
    (i) => ChartLegendItem(
      label: weekdayLabels[i],
      amount: spendingByDay[i] ?? 0,
      color: AppColors.primary,
    ),
  );
}

List<ChartLegendItem> getDailyChartItems(List<Transaction> transactions) {
  final now = DateTime.now();

  final spendingByDay = <int, double>{};

  for (final tx in transactions.where((tx) =>
      tx.isExpense &&
      tx.date.year == now.year &&
      tx.date.month == now.month)) {
    spendingByDay.update(
      tx.date.day,
      (value) => value + tx.amount,
      ifAbsent: () => tx.amount,
    );
  }

  return spendingByDay.entries
      .map(
        (e) => ChartLegendItem(
          label: e.key.toString(), // 1,2,3...
          amount: e.value,
          color: AppColors.primary,
        ),
      )
      .toList()
    ..sort((a, b) => int.parse(a.label).compareTo(int.parse(b.label)));
}

List<ChartLegendItem> getYearlyChartItems(List<Transaction> transactions) {
  final now = DateTime.now();
  const monthLabels = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  final spendingByMonth = <int, double>{for (var i = 1; i <= 12; i++) i: 0};

  for (final tx in transactions.where(
    (tx) => tx.isExpense && tx.date.year == now.year,
  )) {
    spendingByMonth[tx.date.month] =
        (spendingByMonth[tx.date.month] ?? 0) + tx.amount;
  }

  return List.generate(
    12,
    (i) => ChartLegendItem(
      label: monthLabels[i],
      amount: spendingByMonth[i + 1] ?? 0,
      color: AppColors.primary,
    ),
  );
}

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
        return getWeeklyChartItems(widget.transactions);
      case _TrendFilter.monthly:
        return getDailyChartItems(widget.transactions);
      case _TrendFilter.yearly:
        return getYearlyChartItems(widget.transactions);
    }
  }

  @override
  Widget build(BuildContext context) {
    final chartItems = getMonthlyChartItems(widget.transactions);
    final trendItems = _trendItems;

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
            const SizedBox(height: 12),
            Text(
              'Spending trend',
              style: GoogleFonts.inter(
                color: context.themeColors.textPrimary,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            if (trendItems.every((e) => e.amount == 0))
              const EmptyStateCard(
                title: 'No spending data',
                subtitle: 'No expenses found for this period.',
              )
            else
              GlassPanel(
                child: LineChartCard(items: trendItems)
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
            OverviewCard(items: chartItems),
          ],
        ),
      )
    );
  }
}