part of '../dashboard_tabs.dart';

// Line Chart
enum _TrendFilter { weekly, monthly, yearly }
final now = DateTime.now();

List<ChartLegendItem> getWeeklyChartItems(List<Transaction> transactions, DateTime now) {
  
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

List<ChartLegendItem> getDailyChartItems(List<Transaction> transactions, DateTime now) {

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

List<ChartLegendItem> getYearlyChartItems(List<Transaction> transactions, DateTime now) {

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

// Pie Chart
List<ChartLegendItem> getWeeklyCategoryItems(List<Transaction> transactions, DateTime now) {

  final startOfWeek = DateTime(now.year, now.month, now.day)
      .subtract(Duration(days: now.weekday - 1));

  final spendingByCategory = <String, double>{};

  for (final tx in transactions.where((tx) {
    final diff = tx.date.difference(startOfWeek).inDays;

    return tx.isExpense &&
        diff >= 0 &&
        diff < 7;
  })) {
    spendingByCategory.update(
      tx.categoryLabel,
      (value) => value + tx.amount,
      ifAbsent: () => tx.amount,
    );
  }

  return buildChartItems(spendingByCategory);
}

List<ChartLegendItem> getMonthlyChartItems(List<Transaction> transactions, DateTime now) {

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

List<ChartLegendItem> getYearlyCategoryItems(List<Transaction> transactions, DateTime now) {

  final spendingByCategory = <String, double>{};

  for (final tx in transactions.where((tx) =>
      tx.isExpense &&
      tx.date.year == now.year)) {
    spendingByCategory.update(
      tx.categoryLabel,
      (value) => value + tx.amount,
      ifAbsent: () => tx.amount,
    );
  }

  return buildChartItems(spendingByCategory);
}
