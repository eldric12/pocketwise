import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../models/dashboard_ui_models.dart';

List<ChartLegendItem> buildChartItems(Map<String, double> values) {
  const palette = [
    AppColors.danger,
    AppColors.warning,
    AppColors.primary,
    AppColors.success,
    Color(0xFF38BDF8),
  ];
  final entries = values.entries.toList()
    ..sort((a, b) => b.value.compareTo(a.value));

  if (entries.isEmpty) return const [];

  const visibleCategoryCount = 4;
  final visibleEntries = entries.take(visibleCategoryCount).toList();
  final remainingTotal = entries
      .skip(visibleCategoryCount)
      .fold<double>(0, (sum, entry) => sum + entry.value);

  return [
    for (var i = 0; i < visibleEntries.length; i++)
      ChartLegendItem(
        label: visibleEntries[i].key,
        amount: visibleEntries[i].value,
        color: palette[i % palette.length],
      ),
    if (remainingTotal > 0)
      ChartLegendItem(
        label: 'Other',
        amount: remainingTotal,
        color: palette[4],
      ),
  ];
}

CategoryVisual categoryVisual(String category) {
  switch (category.toLowerCase()) {
    case 'food':
      return const CategoryVisual(
        icon: Icons.restaurant_rounded,
        background: Color(0xFF503447),
        foreground: Color(0xFFFF93AB),
      );
    case 'transport':
      return const CategoryVisual(
        icon: Icons.local_taxi_rounded,
        background: Color(0xFF4E442B),
        foreground: Color(0xFFFACB45),
      );
    case 'salary':
      return const CategoryVisual(
        icon: Icons.account_balance_wallet_outlined,
        background: Color(0xFF173E42),
        foreground: Color(0xFF4DE2B6),
      );
    case 'bills':
      return const CategoryVisual(
        icon: Icons.receipt_long_outlined,
        background: Color(0xFF2E3760),
        foreground: Color(0xFF9AA9FF),
      );
    default:
      return const CategoryVisual(
        icon: Icons.payments_outlined,
        background: Color(0xFF25314D),
        foreground: Color(0xFFA9C3EC),
      );
  }
}

String formatAmount(
  double amount, {
  required bool signed,
  bool positive = true,
}) {
  final prefix = signed ? (positive ? '+' : '-') : '';
  return '${prefix}RM ${amount.toStringAsFixed(2)}';
}
