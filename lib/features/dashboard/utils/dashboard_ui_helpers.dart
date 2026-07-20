import 'package:flutter/material.dart';

import '../models/category_definition.dart';
import '../models/dashboard_ui_models.dart';
import 'category_catalog.dart';

List<ChartLegendItem> buildChartItems(
  Map<String, double> values, {
  List<CategoryDefinition> categories = const [],
  Brightness brightness = Brightness.dark,
}) {
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
        color: categoryVisual(
          visibleEntries[i].key,
          isExpense: true,
          categories: categories,
          brightness: brightness,
        ).foreground,
      ),
    if (remainingTotal > 0)
      ChartLegendItem(
        label: 'Other',
        amount: remainingTotal,
        color: categoryColor('slate').accent,
      ),
  ];
}

CategoryVisual categoryVisual(
  String label, {
  String? categoryId,
  bool? isExpense,
  List<CategoryDefinition> categories = const [],
  Brightness brightness = Brightness.dark,
}) {
  final source = categories.isEmpty ? defaultCategories : categories;
  CategoryDefinition? match;
  if (isExpense != null) {
    match = findCategory(
      source,
      id: categoryId,
      label: label,
      isExpense: isExpense,
    );
  } else {
    for (final category in source) {
      if (categoryId != null && category.id == categoryId) {
        match = category;
        break;
      }
      if (category.label.toLowerCase() == label.toLowerCase()) {
        match = category;
        break;
      }
    }
  }
  return categoryAppearance(match, brightness);
}

String formatAmount(
  double amount, {
  required bool signed,
  bool positive = true,
}) {
  if (!signed && amount < 0) {
    return '-RM ${amount.abs().toStringAsFixed(2)}';
  }
  final prefix = signed ? (positive ? '+' : '-') : '';
  return '${prefix}RM ${amount.abs().toStringAsFixed(2)}';
}
