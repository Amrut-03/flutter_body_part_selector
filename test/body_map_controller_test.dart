import 'package:flutter_body_part_selector/flutter_body_part_selector.dart';
import 'package:flutter_test/flutter_test.dart';

/// Pins the BodyMapController behaviour that lib/main.dart relies on, so a
/// package upgrade that changes these semantics fails here first.
void main() {
  late BodyMapController controller;
  late int notifications;

  setUp(() {
    controller = BodyMapController();
    notifications = 0;
    controller.addListener(() => notifications++);
  });

  tearDown(() => controller.dispose());

  group('toggleMuscle', () {
    test('selects an unselected muscle, then deselects it', () {
      controller.toggleMuscle(Muscle.bicepsLeft);
      expect(controller.selectedMuscles, {Muscle.bicepsLeft});

      controller.toggleMuscle(Muscle.bicepsLeft);
      expect(controller.selectedMuscles, isEmpty);
      expect(notifications, 2);
    });

    test('only affects the toggled muscle', () {
      controller.selectMultiple({Muscle.bicepsLeft, Muscle.abs, Muscle.calvesRight});
      controller.toggleMuscle(Muscle.abs);
      expect(controller.selectedMuscles, {Muscle.bicepsLeft, Muscle.calvesRight});
    });

    test('ignores disabled muscles', () {
      controller.disableMuscle(Muscle.abs);
      notifications = 0;
      controller.toggleMuscle(Muscle.abs);
      expect(controller.selectedMuscles, isEmpty);
      expect(notifications, 0);
    });
  });

  group('deselectMuscle', () {
    test('removes a selected muscle with one notification', () {
      controller.selectMultiple({Muscle.bicepsLeft, Muscle.abs});
      notifications = 0;
      controller.deselectMuscle(Muscle.abs);
      expect(controller.selectedMuscles, {Muscle.bicepsLeft});
      expect(notifications, 1);
    });

    test('is a silent no-op for an unselected muscle', () {
      controller.deselectMuscle(Muscle.abs);
      expect(controller.selectedMuscles, isEmpty);
      expect(notifications, 0);
    });
  });

  group('disableMuscle / enableMuscle', () {
    test('disabling a selected muscle also deselects it', () {
      controller.selectMultiple({Muscle.bicepsLeft, Muscle.abs});
      controller.disableMuscle(Muscle.abs);
      expect(controller.isDisabled(Muscle.abs), isTrue);
      expect(controller.selectedMuscles, {Muscle.bicepsLeft});
    });

    test('enabling makes the muscle selectable again', () {
      controller.disableMuscle(Muscle.abs);
      controller.enableMuscle(Muscle.abs);
      expect(controller.isDisabled(Muscle.abs), isFalse);

      controller.toggleMuscle(Muscle.abs);
      expect(controller.isSelected(Muscle.abs), isTrue);
    });
  });

  group('selectMultiple (Select All)', () {
    test('selects every muscle with a single notification', () {
      controller.selectMultiple(Muscle.values.toSet());
      expect(controller.selectedMuscles, Muscle.values.toSet());
      expect(notifications, 1);
    });

    test('skips disabled muscles and keeps existing selection', () {
      controller.disableMuscle(Muscle.chestLeft);
      controller.toggleMuscle(Muscle.abs);
      controller.selectMultiple(Muscle.values.toSet());
      expect(controller.selectedMuscles.length, Muscle.values.length - 1);
      expect(controller.isSelected(Muscle.chestLeft), isFalse);
      expect(controller.isSelected(Muscle.abs), isTrue);
    });

    test('does not notify when nothing new is selected', () {
      controller.selectMultiple(Muscle.values.toSet());
      notifications = 0;
      controller.selectMultiple(Muscle.values.toSet());
      expect(notifications, 0);
    });
  });

  group('clearSelection', () {
    test('clears selection but keeps disabled muscles', () {
      controller.disableMuscle(Muscle.abs);
      controller.selectMultiple(Muscle.values.toSet());
      controller.clearSelection();
      expect(controller.selectedMuscles, isEmpty);
      expect(controller.disabledMuscles, {Muscle.abs});
    });

    test('does not notify when already empty', () {
      controller.clearSelection();
      expect(notifications, 0);
    });
  });

  group('view', () {
    test('toggleView / setFrontView / setBackView', () {
      expect(controller.isFront, isTrue);
      controller.toggleView();
      expect(controller.isFront, isFalse);
      controller.setFrontView();
      expect(controller.isFront, isTrue);
      controller.setBackView();
      expect(controller.isFront, isFalse);
    });
  });
}
