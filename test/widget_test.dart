import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pocketwise/app/app.dart';

void main() {
  testWidgets('PocketWise dashboard loads', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: PocketWiseApp()),
    );
    await tester.pump();

    expect(find.text('Your financial overview'), findsOneWidget);
    expect(find.text('Total Spending'), findsOneWidget);
    expect(find.text('ALL TIME'), findsOneWidget);
  });
}
