import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_body_part_selector/flutter_body_part_selector.dart';
import 'package:flutter_body_part_selector/src/presentation/body_diagram_painter.dart';

/// viewBox sizes of the bundled assets.
const _frontSize = Size(337, 946);
const _backSize = Size(353, 935);

/// Points well inside a muscle, in SVG coordinates (computed from the paths).
const _chestLeft = Offset(122, 218);
const _bicepsLeft = Offset(56, 271);
const _latsRight = Offset(135, 316);
const _emptyFront = Offset(10, 10);

const _boxSize = Size(400, 600);

Widget _host(Widget child) => MaterialApp(
      home: Scaffold(
        body: Center(
          child: SizedBox.fromSize(size: _boxSize, child: child),
        ),
      ),
    );

/// Pumps [widget] and waits, outside the fake clock, until the asset loaded.
Future<void> _pumpLoaded(WidgetTester tester, Widget widget) async {
  await tester.runAsync(() async {
    await tester.pumpWidget(_host(widget));
    for (var i = 0;
        i < 100 && find.text('loading').evaluate().isNotEmpty;
        i++) {
      await Future<void>.delayed(const Duration(milliseconds: 50));
      await tester.pump();
    }
  });
  await tester.pump();
  expect(find.text('loading'), findsNothing,
      reason: 'SVG never finished loading');
}

/// Global position of an SVG point for BoxFit.contain + Alignment.center.
Offset _toGlobal(WidgetTester tester, Offset svgPoint, Size svgSize) {
  final box = tester.getRect(find.byType(InteractiveBodySvg));
  final scale = (box.width / svgSize.width) < (box.height / svgSize.height)
      ? box.width / svgSize.width
      : box.height / svgSize.height;
  final rendered = svgSize * scale;
  final origin = box.topLeft +
      Offset(
          (box.width - rendered.width) / 2, (box.height - rendered.height) / 2);
  return origin + svgPoint * scale;
}

Widget _loading(BuildContext context) => const Text('loading');

void main() {
  testWidgets('tapping a muscle reports it', (tester) async {
    final tapped = <Muscle>[];
    await _pumpLoaded(
      tester,
      InteractiveBodySvg(onMuscleTap: tapped.add, loadingBuilder: _loading),
    );

    await tester.tapAt(_toGlobal(tester, _chestLeft, _frontSize));
    await tester.tapAt(_toGlobal(tester, _bicepsLeft, _frontSize));
    await tester.tapAt(_toGlobal(tester, _emptyFront, _frontSize));
    await tester.pump(const Duration(seconds: 1));

    expect(tapped, [Muscle.chestLeft, Muscle.bicepsLeft]);
  });

  testWidgets('maps taps correctly under a non-uniform BoxFit.fill',
      (tester) async {
    final tapped = <Muscle>[];
    await _pumpLoaded(
      tester,
      InteractiveBodySvg(
        fit: BoxFit.fill,
        width: _boxSize.width,
        height: _boxSize.height,
        onMuscleTap: tapped.add,
        loadingBuilder: _loading,
      ),
    );

    // fill stretches each axis independently to the whole box.
    final box = tester.getRect(find.byType(InteractiveBodySvg));
    Offset toGlobal(Offset p) =>
        box.topLeft +
        Offset(p.dx * box.width / _frontSize.width,
            p.dy * box.height / _frontSize.height);

    await tester.tapAt(toGlobal(_chestLeft));
    await tester.tapAt(toGlobal(_bicepsLeft));
    await tester.pump(const Duration(seconds: 1));

    expect(tapped, [Muscle.chestLeft, Muscle.bicepsLeft]);
  });

  testWidgets('back view hit-tests the back muscles', (tester) async {
    final tapped = <Muscle>[];
    await _pumpLoaded(
      tester,
      InteractiveBodySvg(
        isFront: false,
        onMuscleTap: tapped.add,
        loadingBuilder: _loading,
      ),
    );

    await tester.tapAt(_toGlobal(tester, _latsRight, _backSize));
    await tester.pump(const Duration(seconds: 1));

    expect(tapped, [Muscle.latsBackRight]);
  });

  testWidgets('a drag that starts on a muscle does not select it',
      (tester) async {
    final tapped = <Muscle>[];
    await _pumpLoaded(
      tester,
      InteractiveBodySvg(onMuscleTap: tapped.add, loadingBuilder: _loading),
    );

    await tester.dragFrom(
      _toGlobal(tester, _chestLeft, _frontSize),
      const Offset(0, 120),
    );
    await tester.pump(const Duration(seconds: 1));

    expect(tapped, isEmpty);
  });

  testWidgets('a long press does not also count as a tap', (tester) async {
    final tapped = <Muscle>[];
    final longPressed = <Muscle>[];
    await _pumpLoaded(
      tester,
      InteractiveBodySvg(
        onMuscleTap: tapped.add,
        onMuscleLongPress: longPressed.add,
        loadingBuilder: _loading,
      ),
    );

    await tester.longPressAt(_toGlobal(tester, _chestLeft, _frontSize));
    await tester.pump(const Duration(seconds: 1));

    expect(longPressed, [Muscle.chestLeft]);
    expect(tapped, isEmpty);
  });

  testWidgets('tapping a disabled muscle goes to onMuscleTapDisabled',
      (tester) async {
    final tapped = <Muscle>[];
    final tappedDisabled = <Muscle>[];
    await _pumpLoaded(
      tester,
      InteractiveBodySvg(
        disabledMuscles: const {Muscle.chestLeft},
        onMuscleTap: tapped.add,
        onMuscleTapDisabled: tappedDisabled.add,
        loadingBuilder: _loading,
      ),
    );

    await tester.tapAt(_toGlobal(tester, _chestLeft, _frontSize));
    await tester.pump(const Duration(seconds: 1));

    expect(tapped, isEmpty);
    expect(tappedDisabled, [Muscle.chestLeft]);
  });

  testWidgets('the error view clears once a later load succeeds',
      (tester) async {
    Future<void> settleLoad() => tester.runAsync(() async {
          for (var i = 0; i < 100; i++) {
            await Future<void>.delayed(const Duration(milliseconds: 50));
            await tester.pump();
            if (find.text('loading').evaluate().isEmpty) break;
          }
        });

    await tester.runAsync(() async {
      await tester.pumpWidget(_host(const InteractiveBodySvg(
        asset: 'packages/flutter_body_part_selector/assets/svg/missing.svg',
        isFront: false,
        loadingBuilder: _loading,
      )));
    });
    await settleLoad();
    await tester.pump();
    expect(find.text('Failed to load SVG'), findsOneWidget);

    await tester.runAsync(() async {
      await tester.pumpWidget(_host(const InteractiveBodySvg(
        loadingBuilder: _loading,
      )));
    });
    await settleLoad();
    await tester.pump();
    expect(find.text('Failed to load SVG'), findsNothing);
  });

  testWidgets('selection and color changes repaint in the same frame',
      (tester) async {
    BodyDiagramPainter painter() => tester
        .widget<CustomPaint>(find.descendant(
          of: find.byType(InteractiveBodySvg),
          matching: find.byWidgetPredicate(
              (w) => w is CustomPaint && w.painter is BodyDiagramPainter),
        ))
        .painter! as BodyDiagramPainter;

    await _pumpLoaded(
        tester, const InteractiveBodySvg(loadingBuilder: _loading));
    expect(painter().selectedMuscles, isEmpty);

    // No runAsync and a single pump: nothing may be reloaded or parsed.
    await tester.pumpWidget(_host(const InteractiveBodySvg(
      selectedMuscles: {Muscle.chestLeft, Muscle.abs},
      disabledMuscles: {Muscle.bicepsLeft},
      highlightColor: Colors.red,
      loadingBuilder: _loading,
    )));
    expect(find.text('loading'), findsNothing);
    expect(painter().selectedMuscles, {Muscle.chestLeft, Muscle.abs});
    expect(painter().disabledMuscles, {Muscle.bicepsLeft});
    expect(painter().highlightColor, Colors.red);
  });

  testWidgets('flipping back to an already loaded view is synchronous',
      (tester) async {
    await _pumpLoaded(
        tester, const InteractiveBodySvg(loadingBuilder: _loading));
    await _pumpLoaded(tester,
        const InteractiveBodySvg(isFront: false, loadingBuilder: _loading));

    await tester
        .pumpWidget(_host(const InteractiveBodySvg(loadingBuilder: _loading)));
    expect(find.text('loading'), findsNothing);
    await tester.pumpWidget(_host(
        const InteractiveBodySvg(isFront: false, loadingBuilder: _loading)));
    expect(find.text('loading'), findsNothing);
  });

  group('onSelectAnimationBuilder', () {
    Widget body(Set<Muscle> selected, List<Muscle> calls) => InteractiveBodySvg(
          selectedMuscles: selected,
          loadingBuilder: _loading,
          onSelectAnimationBuilder: (context, child, muscle) {
            calls.add(muscle);
            return KeyedSubtree(key: const ValueKey('wrapper'), child: child);
          },
        );

    testWidgets('wraps the diagram with the newly selected muscle',
        (tester) async {
      final calls = <Muscle>[];
      await _pumpLoaded(tester, body(const {}, calls));
      expect(find.byKey(const ValueKey('wrapper')), findsNothing);

      await tester.pumpWidget(_host(body(const {Muscle.chestLeft}, calls)));
      expect(find.byKey(const ValueKey('wrapper')), findsOneWidget);
      expect(calls.last, Muscle.chestLeft);

      await tester
          .pumpWidget(_host(body(const {Muscle.chestLeft, Muscle.abs}, calls)));
      expect(calls.last, Muscle.abs);

      await tester.pumpWidget(_host(body(const {Muscle.chestLeft}, calls)));
      expect(find.byKey(const ValueKey('wrapper')), findsNothing,
          reason: 'abs, the animated muscle, was deselected');
    });

    testWidgets('taps still hit the right muscle inside the wrapper',
        (tester) async {
      final tapped = <Muscle>[];
      await _pumpLoaded(
        tester,
        InteractiveBodySvg(
          selectedMuscles: const {Muscle.abs},
          onMuscleTap: tapped.add,
          loadingBuilder: _loading,
          onSelectAnimationBuilder: (context, child, muscle) => child,
        ),
      );

      await tester.tapAt(_toGlobal(tester, _chestLeft, _frontSize));
      await tester.pump(const Duration(seconds: 1));
      expect(tapped, [Muscle.chestLeft]);
    });
  });
}
