import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pocketwise/core/theme/app_theme_colors.dart';
import 'package:pocketwise/features/dashboard/models/category_definition.dart';
import 'package:pocketwise/features/dashboard/widgets/category_editor_sheet.dart';

void main() {
  testWidgets('creates a category with the selected icon and color', (
    tester,
  ) async {
    CategoryDefinition? result;

    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(
          brightness: Brightness.dark,
          extensions: const [AppThemeColors.dark],
        ),
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: FilledButton(
                onPressed: () async {
                  result = await showCategoryEditorSheet(
                    context: context,
                    isExpense: true,
                    existingNames: const {'Food'},
                  );
                },
                child: const Text('Open editor'),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open editor'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Health');
    await tester.tap(find.bySemanticsLabel('Health icon'));
    final tealColor = find.bySemanticsLabel('Teal color');
    await tester.ensureVisible(tealColor);
    await tester.tap(tealColor);
    await tester.ensureVisible(find.text('Add category'));
    await tester.tap(find.text('Add category'));
    await tester.pumpAndSettle();

    expect(result, isNotNull);
    expect(result!.label, 'Health');
    expect(result!.iconKey, 'health');
    expect(result!.colorKey, 'teal');
    expect(result!.isExpense, isTrue);
  });
}
