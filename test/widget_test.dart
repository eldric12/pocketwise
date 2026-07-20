import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pocketwise/app/app.dart';

void main() {
  testWidgets('PocketWise app loads', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: PocketWiseApp()));
    await tester.pump();

    expect(find.text('PocketWise'), findsOneWidget);
    expect(find.byIcon(Icons.account_balance_wallet_rounded), findsOneWidget);
  });
}
