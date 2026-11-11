import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_body_part_selector/flutter_body_part_selector.dart';

void main() {
  group('Muscle.displayName', () {
    test('capitalizes every word', () {
      expect(Muscle.bicepsLeft.displayName, 'Biceps Left');
      expect(Muscle.abs.displayName, 'Abs');
      expect(Muscle.lowerLatsBackRight.displayName, 'Lower Lats Back Right');
    });

    test('every name starts with a capital letter', () {
      for (final muscle in Muscle.values) {
        expect(muscle.displayName[0], muscle.displayName[0].toUpperCase(),
            reason: muscle.name);
      }
    });
  });

  group('BodyMapController', () {
    late BodyMapController controller;
    late int notifications;

    setUp(() {
      controller = BodyMapController();
      notifications = 0;
      controller.addListener(() => notifications++);
    });
    tearDown(() => controller.dispose());

    test('setting isFront notifies listeners, only when it changes', () {
      controller.isFront = false;
      expect(controller.isFront, isFalse);
      expect(notifications, 1);

      controller.isFront = false;
      expect(notifications, 1);

      controller.setFrontView();
      controller.setFrontView();
      expect(controller.isFront, isTrue);
      expect(notifications, 2);

      controller.toggleView();
      expect(controller.isFront, isFalse);
      expect(notifications, 3);
    });

    test('initialIsFront does not notify', () {
      final back = BodyMapController(initialIsFront: false);
      expect(back.isFront, isFalse);
      back.dispose();
    });

    test('setInitialSelection replaces the selection without notifying', () {
      controller.setDisabledMuscles({Muscle.abs});
      notifications = 0;

      controller.setInitialSelection({Muscle.chestLeft, Muscle.abs});
      expect(controller.selectedMuscles, {Muscle.chestLeft});
      expect(notifications, 0);
    });

    test('toggleMuscle and selectMuscle both toggle and notify', () {
      controller.toggleMuscle(Muscle.abs);
      expect(controller.isSelected(Muscle.abs), isTrue);
      controller.selectMuscle(Muscle.abs);
      expect(controller.isSelected(Muscle.abs), isFalse);
      expect(notifications, 2);
    });

    test('toggling a disabled muscle does nothing', () {
      controller.disableMuscle(Muscle.abs);
      notifications = 0;
      controller.toggleMuscle(Muscle.abs);
      expect(controller.isSelected(Muscle.abs), isFalse);
      expect(notifications, 0);
    });
  });
}
