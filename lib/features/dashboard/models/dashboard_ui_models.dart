import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../models/transaction.dart';

class BudgetViewData {
  const BudgetViewData({
    required this.category,
    this.spent,
    this.limit,
    this.color = AppColors.primary,
  });

  final String category;
  final double? spent;
  final double? limit;
  final Color color;
}

class ChartLegendItem {
  const ChartLegendItem({
    required this.label,
    required this.amount,
    required this.color,
  });

  final String label;
  final double amount;
  final Color color;
}

class CategoryVisual {
  const CategoryVisual({
    required this.icon,
    required this.background,
    required this.foreground,
  });

  final IconData icon;
  final Color background;
  final Color foreground;
}

class IncomeExpenseItem {
  const IncomeExpenseItem({
    required this.income,
    required this.expense
  });

  final double income;
  final double expense;
}

class QuickStatistics {
  const QuickStatistics({
    this.highestExpense,
    this.highestIncome,
    required this.mostUsedCategory,
    required this.averageDailySpending,
  });

  final Transaction? highestExpense;
  final Transaction? highestIncome;
  final String mostUsedCategory;
  final double averageDailySpending;
}