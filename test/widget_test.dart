import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pocketwise/app/app.dart';

void main() {
  testWidgets('PocketWise dashboard loads', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: PocketWiseApp()),
    );
    await tester.pump();

    expect(find.text('This month'), findsOneWidget);
    expect(find.text('Your money at a glance'), findsOneWidget);
  });
}
