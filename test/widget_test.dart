// This is a basic Flutter widget test for the flutter_body_part_selector package.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_body_part_selector/flutter_body_part_selector.dart';

void main() {
  testWidgets('InteractiveBodyWidget smoke test', (WidgetTester tester) async {
    // Build the widget
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: InteractiveBodyWidget(
            // Asset paths are optional - package includes default assets
          ),
        ),
      ),
    );

    // Verify that the widget is rendered
    expect(find.byType(InteractiveBodyWidget), findsOneWidget);
  });

  testWidgets('BodyMapController test', (WidgetTester tester) async {
    final controller = BodyMapController();

    // Test initial state
    expect(controller.selectedMuscles.isEmpty, true);
    expect(controller.isFront, true);
    
    // Test muscle selection
    controller.selectMuscle(Muscle.bicepsLeft);
    expect(controller.isSelected(Muscle.bicepsLeft), true);
    expect(controller.selectedMuscles.length, 1);

    // Test toggle selection
    controller.selectMuscle(Muscle.bicepsLeft);
    expect(controller.isSelected(Muscle.bicepsLeft), false);
    expect(controller.selectedMuscles.isEmpty, true);
    
    // Test view toggle
    controller.toggleView();
    expect(controller.isFront, false);
    
    controller.dispose();
  });
}
