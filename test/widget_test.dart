import 'package:flutter/material.dart';
import 'package:flutter_body_part_selector/flutter_body_part_selector.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:body_selector_app/main.dart';

final int _allCount = Muscle.values.length;

Future<void> _pumpApp(WidgetTester tester) async {
  // Tall phone-sized viewport so the list section has room for items.
  tester.view.physicalSize = const Size(1080, 2400);
  tester.view.devicePixelRatio = 2.0;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(const MyApp());
  await _settle(tester);
}

/// InteractiveBodySvg shows a spinner until its SVG asset loads, which never
/// completes under the fake test clock, so pumpAndSettle() would time out.
/// Pump a fixed duration instead (long enough for tab/page animations).
Future<void> _settle(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 500));
}

Future<void> _tapSelectAll(WidgetTester tester) async {
  await tester.tap(find.text('Select All'));
  await _settle(tester);
}

void main() {
  testWidgets('App renders with title and initial UI', (tester) async {
    await _pumpApp(tester);

    expect(find.text('Body Part Selector'), findsOneWidget);
    expect(find.text('Front'), findsOneWidget);
    expect(find.text('Toggle'), findsOneWidget);
    expect(find.text('Back'), findsOneWidget);
    expect(find.text('Select All'), findsOneWidget);
    expect(find.text('Selected: 0'), findsOneWidget);
    expect(find.text('View: Front'), findsOneWidget);
  });

  testWidgets('Select All selects every muscle', (tester) async {
    await _pumpApp(tester);
    await _tapSelectAll(tester);

    expect(find.text('Selected: $_allCount'), findsOneWidget);
    expect(find.text('Selected ($_allCount)'), findsOneWidget);
    // Labels come from Muscle.displayName with the first letter capitalized.
    expect(find.text('Traps Left'), findsOneWidget);
    expect(find.text('traps Left'), findsNothing);
  });

  testWidgets('Clear All empties the selection', (tester) async {
    await _pumpApp(tester);
    await _tapSelectAll(tester);

    await tester.tap(find.byTooltip('Clear All Selections'));
    await _settle(tester);

    expect(find.text('Selected: 0'), findsOneWidget);
    expect(find.textContaining('No body parts selected'), findsOneWidget);
  });

  testWidgets('Deselect button removes exactly one muscle', (tester) async {
    await _pumpApp(tester);
    await _tapSelectAll(tester);

    await tester.tap(find.byTooltip('Deselect').first);
    await _settle(tester);

    expect(find.text('Selected: ${_allCount - 1}'), findsOneWidget);
    expect(find.text('Disabled: 1'), findsNothing);
  });

  testWidgets('Disable deselects the muscle; Enable restores it', (tester) async {
    await _pumpApp(tester);
    await _tapSelectAll(tester);

    await tester.tap(find.byTooltip('Disable').first);
    await _settle(tester);

    expect(find.text('Selected: ${_allCount - 1}'), findsOneWidget);
    expect(find.text('Disabled: 1'), findsOneWidget);
    expect(find.text('Disabled (1)'), findsOneWidget);

    // Select All must skip the disabled muscle.
    await _tapSelectAll(tester);
    expect(find.text('Selected: ${_allCount - 1}'), findsOneWidget);

    // Re-enable from the Disabled tab.
    await tester.tap(find.text('Disabled (1)'));
    await _settle(tester);
    await tester.tap(find.byTooltip('Enable'));
    await _settle(tester);

    expect(find.text('Disabled (0)'), findsOneWidget);
    expect(find.text('Disabled: 1'), findsNothing);

    // Now Select All picks it up again.
    await _tapSelectAll(tester);
    expect(find.text('Selected: $_allCount'), findsOneWidget);
  });

  testWidgets('View buttons switch front/back', (tester) async {
    await _pumpApp(tester);

    await tester.tap(find.text('Back'));
    await _settle(tester);
    expect(find.text('View: Back'), findsOneWidget);

    await tester.tap(find.text('Toggle'));
    await _settle(tester);
    expect(find.text('View: Front'), findsOneWidget);
  });
}
