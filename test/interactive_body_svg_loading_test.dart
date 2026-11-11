import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_body_part_selector/flutter_body_part_selector.dart';

Widget _wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

void main() {
  testWidgets('shows the default spinner while loading', (tester) async {
    await tester.pumpWidget(_wrap(const InteractiveBodySvg()));
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    // No pending-Timer failure when the test ends here.
  });

  testWidgets(
      'loadingBuilder replaces the spinner and lets pumpAndSettle settle',
      (tester) async {
    await tester.pumpWidget(_wrap(InteractiveBodySvg(
      loadingBuilder: (context) => const Text('loading body map'),
    )));
    await tester.pumpAndSettle();

    expect(find.text('loading body map'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });

  testWidgets('the SVG renders when loaded inside tester.runAsync',
      (tester) async {
    await tester.runAsync(() async {
      await tester.pumpWidget(_wrap(const InteractiveBodySvg()));
      // Let the real asset I/O complete outside the fake clock.
      // Up to ~5 s; the first XML parse of the diagram can take over 1 s.
      for (var i = 0;
          i < 100 && find.byType(SvgPicture).evaluate().isEmpty;
          i++) {
        await Future<void>.delayed(const Duration(milliseconds: 50));
        await tester.pump();
      }
    });
    await tester.pump();

    expect(find.byType(SvgPicture), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });
}
