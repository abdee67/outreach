import 'package:flutter_test/flutter_test.dart';

import 'package:my_crm/main.dart';

void main() {
  testWidgets('App launches with empty state', (WidgetTester tester) async {
    await tester.pumpWidget(const OutreachCrmApp());
    await tester.pumpAndSettle();

    expect(find.text('No businesses yet'), findsOneWidget);
    expect(find.text('Import CSV'), findsWidgets);
  });
}
