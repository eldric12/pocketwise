import 'package:flutter/material.dart';

import '../models/category_definition.dart';
import '../models/dashboard_ui_models.dart';

class CategoryIconChoice {
  const CategoryIconChoice(this.key, this.label, this.icon);

  final String key;
  final String label;
  final IconData icon;
}

class CategoryColorChoice {
  const CategoryColorChoice(this.key, this.label, this.accent);

  final String key;
  final String label;
  final Color accent;
}

const categoryIconChoices = <CategoryIconChoice>[
  CategoryIconChoice('category', 'General', Icons.category_outlined),
  CategoryIconChoice('food', 'Food', Icons.restaurant_rounded),
  CategoryIconChoice('transport', 'Transport', Icons.directions_car_rounded),
  CategoryIconChoice('bills', 'Bills', Icons.receipt_long_rounded),
  CategoryIconChoice('entertainment', 'Entertainment', Icons.movie_outlined),
  CategoryIconChoice('shopping', 'Shopping', Icons.shopping_bag_outlined),
  CategoryIconChoice('books', 'Books', Icons.menu_book_rounded),
  CategoryIconChoice('health', 'Health', Icons.medical_services_outlined),
  CategoryIconChoice('home', 'Home', Icons.home_outlined),
  CategoryIconChoice('travel', 'Travel', Icons.flight_takeoff_rounded),
  CategoryIconChoice('education', 'Education', Icons.school_outlined),
  CategoryIconChoice('fitness', 'Fitness', Icons.fitness_center_rounded),
  CategoryIconChoice('pets', 'Pets', Icons.pets_outlined),
  CategoryIconChoice('salary', 'Salary', Icons.account_balance_wallet_rounded),
  CategoryIconChoice('work', 'Work', Icons.work_outline_rounded),
  CategoryIconChoice('gift', 'Gift', Icons.card_giftcard_rounded),
  CategoryIconChoice('refund', 'Refund', Icons.replay_rounded),
  CategoryIconChoice('savings', 'Savings', Icons.savings_outlined),
];

const categoryColorChoices = <CategoryColorChoice>[
  CategoryColorChoice('coral', 'Coral', Color(0xFFFF6B7A)),
  CategoryColorChoice('amber', 'Amber', Color(0xFFF4B740)),
  CategoryColorChoice('emerald', 'Emerald', Color(0xFF35C998)),
  CategoryColorChoice('sky', 'Sky', Color(0xFF38BDF8)),
  CategoryColorChoice('indigo', 'Indigo', Color(0xFF7C8CFF)),
  CategoryColorChoice('violet', 'Violet', Color(0xFFA78BFA)),
  CategoryColorChoice('pink', 'Pink', Color(0xFFF472B6)),
  CategoryColorChoice('teal', 'Teal', Color(0xFF2DD4BF)),
  CategoryColorChoice('slate', 'Slate', Color(0xFF94A3B8)),
];

const defaultCategories = <CategoryDefinition>[
  CategoryDefinition(
    id: 'food',
    label: 'Food',
    isExpense: true,
    iconKey: 'food',
    colorKey: 'coral',
    isCustom: false,
  ),
  CategoryDefinition(
    id: 'transport',
    label: 'Transport',
    isExpense: true,
    iconKey: 'transport',
    colorKey: 'amber',
    isCustom: false,
  ),
  CategoryDefinition(
    id: 'bills',
    label: 'Bills',
    isExpense: true,
    iconKey: 'bills',
    colorKey: 'indigo',
    isCustom: false,
  ),
  CategoryDefinition(
    id: 'entertainment',
    label: 'Entertainment',
    isExpense: true,
    iconKey: 'entertainment',
    colorKey: 'violet',
    isCustom: false,
  ),
  CategoryDefinition(
    id: 'shopping',
    label: 'Shopping',
    isExpense: true,
    iconKey: 'shopping',
    colorKey: 'pink',
    isCustom: false,
  ),
  CategoryDefinition(
    id: 'books',
    label: 'Books',
    isExpense: true,
    iconKey: 'books',
    colorKey: 'sky',
    isCustom: false,
  ),
  CategoryDefinition(
    id: 'salary',
    label: 'Salary',
    isExpense: false,
    iconKey: 'salary',
    colorKey: 'emerald',
    isCustom: false,
  ),
  CategoryDefinition(
    id: 'freelance',
    label: 'Freelance',
    isExpense: false,
    iconKey: 'work',
    colorKey: 'sky',
    isCustom: false,
  ),
  CategoryDefinition(
    id: 'gift',
    label: 'Gift',
    isExpense: false,
    iconKey: 'gift',
    colorKey: 'pink',
    isCustom: false,
  ),
  CategoryDefinition(
    id: 'refund',
    label: 'Refund',
    isExpense: false,
    iconKey: 'refund',
    colorKey: 'teal',
    isCustom: false,
  ),
];

IconData categoryIcon(String key) {
  return categoryIconChoices
          .where((choice) => choice.key == key)
          .map((choice) => choice.icon)
          .firstOrNull ??
      Icons.category_outlined;
}

CategoryColorChoice categoryColor(String key) {
  return categoryColorChoices
          .where((choice) => choice.key == key)
          .firstOrNull ??
      categoryColorChoices.last;
}

CategoryDefinition? findCategory(
  Iterable<CategoryDefinition> categories, {
  String? id,
  String? label,
  required bool isExpense,
}) {
  for (final category in categories) {
    if (category.isExpense != isExpense) continue;
    if (id != null && category.id == id) return category;
  }
  if (label == null) return null;
  for (final category in categories) {
    if (category.isExpense == isExpense &&
        category.label.toLowerCase() == label.toLowerCase()) {
      return category;
    }
  }
  return null;
}

CategoryVisual categoryAppearance(
  CategoryDefinition? category,
  Brightness brightness,
) {
  final color = categoryColor(category?.colorKey ?? 'slate').accent;
  final isDark = brightness == Brightness.dark;
  final background = Color.lerp(
    isDark ? const Color(0xFF182235) : Colors.white,
    color,
    isDark ? 0.24 : 0.18,
  )!;
  final foreground = isDark ? color : Color.lerp(color, Colors.black, 0.34)!;
  return CategoryVisual(
    icon: categoryIcon(category?.iconKey ?? 'category'),
    background: background,
    foreground: foreground,
  );
}

String legacyCategoryId(String label) {
  final normalized = label
      .trim()
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
      .replaceAll(RegExp(r'^_+|_+$'), '');
  return normalized.isEmpty ? 'category' : normalized;
}
