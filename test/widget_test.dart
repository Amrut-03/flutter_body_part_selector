// This is a basic Flutter widget test for the flutter_body_part_selector package.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_body_part_selector/flutter_body_part_selector.dart';

void main() {
  testWidgets('InteractiveBodySvg smoke test', (WidgetTester tester) async {
    final controller = BodyMapController();
    // Build the widget
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: InteractiveBodySvg(
            isFront: controller.isFront,
            selectedMuscles: controller.selectedMuscles,
            onMuscleTap: controller.selectMuscle,
          ),
        ),
      ),
    );

    // Verify that the widget is rendered
    expect(find.byType(InteractiveBodySvg), findsOneWidget);
    controller.dispose();
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

  testWidgets('BodyMapController - new selection methods', (WidgetTester tester) async {
    final controller = BodyMapController();

    // Test toggleMuscle
    controller.toggleMuscle(Muscle.bicepsLeft);
    expect(controller.isSelected(Muscle.bicepsLeft), true);
    controller.toggleMuscle(Muscle.bicepsLeft);
    expect(controller.isSelected(Muscle.bicepsLeft), false);

    // Test deselectMuscle
    controller.selectMuscle(Muscle.bicepsLeft);
    controller.deselectMuscle(Muscle.bicepsLeft);
    expect(controller.isSelected(Muscle.bicepsLeft), false);

    // Test setSelectedMuscles
    controller.setSelectedMuscles({Muscle.bicepsLeft, Muscle.tricepsRight});
    expect(controller.selectedMuscles.length, 2);
    expect(controller.isSelected(Muscle.bicepsLeft), true);
    expect(controller.isSelected(Muscle.tricepsRight), true);

    // Test selectMultiple
    controller.clearSelection();
    controller.selectMultiple({Muscle.bicepsLeft, Muscle.tricepsRight});
    expect(controller.selectedMuscles.length, 2);
    controller.selectMultiple({Muscle.chestLeft}); // Add more
    expect(controller.selectedMuscles.length, 3);
    
    controller.dispose();
  });

  testWidgets('BodyMapController - constructor with initial state', (WidgetTester tester) async {
    final controller = BodyMapController(
      initialSelectedMuscles: {Muscle.bicepsLeft, Muscle.tricepsRight},
      initialDisabledMuscles: {Muscle.chestLeft},
      initialIsFront: false,
    );

    // Test initial selection
    expect(controller.selectedMuscles.length, 2);
    expect(controller.isSelected(Muscle.bicepsLeft), true);
    expect(controller.isSelected(Muscle.tricepsRight), true);

    // Test initial disabled muscles
    expect(controller.isDisabled(Muscle.chestLeft), true);
    expect(controller.disabledMuscles.length, 1);

    // Test initial view
    expect(controller.isFront, false);

    // Test that disabled muscles can't be selected
    controller.selectMuscle(Muscle.chestLeft);
    expect(controller.isSelected(Muscle.chestLeft), false);
    
    controller.dispose();
  });
}
