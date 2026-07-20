import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pocketwise/features/dashboard/models/category_definition.dart';
import 'package:pocketwise/features/dashboard/utils/category_catalog.dart';
import 'package:pocketwise/features/dashboard/utils/dashboard_ui_helpers.dart';

void main() {
  group('category catalog', () {
    test('built-in categories use valid, unique appearance keys', () {
      final identities = <String>{};
      final iconKeys = categoryIconChoices.map((choice) => choice.key).toSet();
      final colorKeys = categoryColorChoices
          .map((choice) => choice.key)
          .toSet();

      for (final category in defaultCategories) {
        expect(identities.add('${category.isExpense}:${category.id}'), isTrue);
        expect(iconKeys, contains(category.iconKey));
        expect(colorKeys, contains(category.colorKey));
      }
    });

    test('assigned icon and color resolve consistently', () {
      const category = CategoryDefinition(
        id: 'custom_health',
        label: 'Health',
        isExpense: true,
        iconKey: 'health',
        colorKey: 'teal',
        isCustom: true,
      );

      final visual = categoryAppearance(category, Brightness.dark);
      final resolved = categoryVisual(
        category.label,
        categoryId: category.id,
        isExpense: true,
        categories: const [category],
        brightness: Brightness.dark,
      );

      expect(resolved.icon, Icons.medical_services_outlined);
      expect(resolved.icon, visual.icon);
      expect(resolved.foreground, visual.foreground);
      expect(resolved.background, visual.background);
    });

    test('chart legend uses the assigned category color', () {
      const category = CategoryDefinition(
        id: 'custom_travel',
        label: 'Travel',
        isExpense: true,
        iconKey: 'travel',
        colorKey: 'violet',
        isCustom: true,
      );

      final items = buildChartItems(
        const {'Travel': 125},
        categories: const [category],
        brightness: Brightness.dark,
      );

      expect(items, hasLength(1));
      expect(
        items.single.color,
        categoryAppearance(category, Brightness.dark).foreground,
      );
    });

    test('unknown categories receive a safe fallback', () {
      final visual = categoryVisual(
        'Legacy category',
        categories: const [],
        brightness: Brightness.light,
      );

      expect(visual.icon, Icons.category_outlined);
      expect(visual.background, isNot(Colors.transparent));
    });
  });
}
