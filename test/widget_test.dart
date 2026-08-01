import 'package:flutter_test/flutter_test.dart';

import 'package:outreach/main.dart';

void main() {
  testWidgets('App launches with empty state', (WidgetTester tester) async {
    await tester.pumpWidget(const OutreachApp());
    await tester.pumpAndSettle();

    expect(find.text('No businesses yet'), findsOneWidget);
    expect(find.text('Import CSV'), findsWidgets);
  });
}
