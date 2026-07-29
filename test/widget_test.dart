import 'package:flutter_test/flutter_test.dart';

import 'package:body_selector_app/main.dart';

void main() {
  testWidgets('App renders with title and initial UI', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Body Part Selector'), findsOneWidget);
    expect(find.text('Front'), findsOneWidget);
    expect(find.text('Toggle'), findsOneWidget);
    expect(find.text('Back'), findsOneWidget);
    expect(find.text('Select All'), findsOneWidget);
    expect(find.text('Selected: 0'), findsOneWidget);
    expect(find.text('View: Front'), findsOneWidget);
  });
}
