import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_body_part_selector/flutter_body_part_selector.dart';
import 'package:flutter_body_part_selector/src/data/body_diagram.dart';
import 'package:flutter_body_part_selector/src/presentation/body_diagram_painter.dart';

/// A small diagram exercising the cases the built-in assets don't:
/// relative commands, H/V, arcs, an even-odd hole, overlap, extra content,
/// and a viewBox offset from the origin and scaled against width/height.
const _synthetic = '''
<svg xmlns="http://www.w3.org/2000/svg" width="200" height="400" viewBox="10,20 100 200">
  <circle id="decoration" cx="50" cy="50" r="5"/>
  <path id="chest_left" d="M20 30 h30 v40 H20 z"/>
  <g id="biceps_left">
    <path d="M60 30 l20 0 0 20 -20 0 Z"/>
    <path d="M60 60 a10 10 0 1 0 20 0 a10 10 0 1 0 -20 0"/>
  </g>
  <path id="abs" fill-rule="evenodd"
        d="M20 100 H100 V180 H20 Z M40 120 H80 V160 H40 Z"/>
  <path id="chest_right" d="M30 40 H45 V60 H30 Z"/>
  <path id="front_body" d="M10 20 H110 V220 H10 Z"/>
</svg>
''';

String _asset(String name) => File('assets/svg/$name').readAsStringSync();

void main() {
  group('BodyDiagram.parse', () {
    final diagram = BodyDiagram.parse(_synthetic);

    test('reads size and an offset, comma-separated viewBox', () {
      expect(diagram.size, const Size(200, 400));
      expect(diagram.viewBox, const Rect.fromLTWH(10, 20, 100, 200));
    });

    test('collects muscles in document order and the outline', () {
      expect(diagram.muscles.map((m) => m.muscle), [
        Muscle.chestLeft,
        Muscle.bicepsLeft,
        Muscle.abs,
        Muscle.chestRight,
      ]);
      expect(diagram.muscles[1].paths, hasLength(2));
      expect(diagram.outlines, hasLength(1));
    });

    test(
        'computes bounds from the real geometry, including H/V and relative commands',
        () {
      expect(diagram.muscles[0].bounds, const Rect.fromLTRB(20, 30, 50, 70));
      expect(diagram.muscles[1].bounds.left, closeTo(60, 0.01));
      expect(diagram.muscles[1].bounds.right, closeTo(80, 0.01));
      expect(diagram.muscles[1].bounds.bottom, closeTo(70, 0.5));
    });

    test('keeps other content, minus muscles and outline, in otherContentSvg',
        () {
      final other = diagram.otherContentSvg;
      expect(other, contains('decoration'));
      expect(other, contains('viewBox'));
      for (final id in ['chest_left', 'biceps_left', 'abs', 'front_body']) {
        expect(other, isNot(contains(id)), reason: id);
      }
    });

    test('rejects documents that are not usable SVGs', () {
      expect(() => BodyDiagram.parse('<svg'), throwsFormatException);
      expect(() => BodyDiagram.parse('<html/>'), throwsFormatException);
      expect(() => BodyDiagram.parse('<svg/>'), throwsFormatException);
      expect(() => BodyDiagram.parse('<svg viewBox="0 0 1"/>'),
          throwsFormatException);
    });

    test('falls back to the viewBox size without width/height', () {
      final d = BodyDiagram.parse('<svg viewBox="0 0 30 60"/>');
      expect(d.size, const Size(30, 60));
    });
  });

  group('BodyDiagram.muscleAt', () {
    final diagram = BodyDiagram.parse(_synthetic);

    test('finds the muscle containing the point', () {
      expect(diagram.muscleAt(const Offset(25, 65)), Muscle.chestLeft);
      expect(diagram.muscleAt(const Offset(70, 40)), Muscle.bicepsLeft);
    });

    test('hit-tests arcs as curves, not as their endpoints', () {
      expect(diagram.muscleAt(const Offset(70, 61)), Muscle.bicepsLeft);
      expect(diagram.muscleAt(const Offset(61, 52)), isNull,
          reason: 'inside the bounding box but outside the circle');
    });

    test('honours fill-rule evenodd holes', () {
      expect(diagram.muscleAt(const Offset(30, 110)), Muscle.abs);
      expect(diagram.muscleAt(const Offset(60, 140)), isNull);
    });

    test('the topmost (last drawn) muscle wins where muscles overlap', () {
      expect(diagram.muscleAt(const Offset(35, 50)), Muscle.chestRight);
    });

    test('returns null on empty space and ignores the outline', () {
      expect(diagram.muscleAt(const Offset(100, 200)), isNull);
    });

    test('tolerance catches taps just outside an edge', () {
      const justOutside = Offset(51.5, 50);
      expect(diagram.muscleAt(justOutside), isNull);
      expect(diagram.muscleAt(justOutside, tolerance: 2), Muscle.chestLeft);
      expect(diagram.muscleAt(const Offset(55, 50), tolerance: 2), isNull);
    });
  });

  group('built-in assets', () {
    final front = BodyDiagram.parse(_asset('body_front.svg'));
    final back = BodyDiagram.parse(_asset('body_back.svg'));

    test('every Muscle is drawn in at least one view', () {
      final drawn = {
        ...front.muscles.map((m) => m.muscle),
        ...back.muscles.map((m) => m.muscle),
      };
      expect(drawn, Muscle.values.toSet());
    });

    test('nothing but muscles and the outline is in the assets', () {
      expect(front.outlines, hasLength(1));
      expect(back.outlines, hasLength(1));
      expect(front.otherContentSvg, isNot(contains('<path')));
      expect(back.otherContentSvg, isNot(contains('<path')));
    });

    test('hit-tests known interior points', () {
      expect(front.muscleAt(const Offset(122, 218)), Muscle.chestLeft);
      expect(front.muscleAt(const Offset(56, 271)), Muscle.bicepsLeft);
      expect(front.muscleAt(const Offset(147, 377)), Muscle.abs);
      expect(back.muscleAt(const Offset(135, 316)), Muscle.latsBackRight);
      expect(back.muscleAt(const Offset(212, 471)), Muscle.glutesLeft);
      expect(front.muscleAt(const Offset(10, 10)), isNull);
    });
  });

  group('BodyDiagramPainter.shouldRepaint', () {
    final diagram = BodyDiagram.parse(_synthetic);
    BodyDiagramPainter painter({
      Set<Muscle> selected = const {},
      Color highlight = Colors.blue,
    }) =>
        BodyDiagramPainter(
          diagram: diagram,
          selectedMuscles: selected,
          disabledMuscles: const {},
          highlightColor: highlight,
          disabledColor: Colors.grey,
          outlineColor: Colors.black,
          selectedStrokeWidth: 2,
          unselectedStrokeWidth: 1,
        );

    test('compares selections by content', () {
      expect(
        painter(selected: {Muscle.abs})
            .shouldRepaint(painter(selected: {Muscle.abs})),
        isFalse,
      );
      expect(
        painter(selected: {Muscle.abs}).shouldRepaint(painter()),
        isTrue,
      );
      expect(
        painter(highlight: Colors.red).shouldRepaint(painter()),
        isTrue,
      );
    });
  });

  group('BodyDiagramPainter colors', () {
    // Paints onto a transparent canvas at 1 px per SVG unit and reads back
    // the alpha at a point well inside a muscle (away from its stroke).
    Future<int> alphaAt(Offset point, BodyDiagramPainter painter) async {
      final size = painter.diagram.size;
      final recorder = ui.PictureRecorder();
      painter.paint(Canvas(recorder), size);
      final image = await recorder
          .endRecording()
          .toImage(size.width.ceil(), size.height.ceil());
      final bytes = (await image.toByteData())!;
      final offset = (point.dy.toInt() * image.width + point.dx.toInt()) * 4;
      return bytes.getUint8(offset + 3);
    }

    final front = BodyDiagram.parse(_asset('body_front.svg'));
    const chestInterior = Offset(122, 218);

    BodyDiagramPainter painter({
      Set<Muscle> selected = const {},
      Set<Muscle> disabled = const {},
      required Color highlight,
      Color disabledColor = Colors.grey,
    }) =>
        BodyDiagramPainter(
          diagram: front,
          selectedMuscles: selected,
          disabledMuscles: disabled,
          highlightColor: highlight,
          disabledColor: disabledColor,
          outlineColor: Colors.black,
          selectedStrokeWidth: 2,
          unselectedStrokeWidth: 1,
        );

    test('the highlight color is drawn with its alpha', () async {
      final translucent = await alphaAt(
        chestInterior,
        painter(
          selected: {Muscle.chestLeft},
          highlight: Colors.blue.withValues(alpha: 0.6),
        ),
      );
      expect(translucent, closeTo(153, 2));

      final opaque = await alphaAt(
        chestInterior,
        painter(selected: {Muscle.chestLeft}, highlight: Colors.blue),
      );
      expect(opaque, 255);
    });

    test('disabled muscles get a further 40% opacity', () async {
      final alpha = await alphaAt(
        chestInterior,
        painter(
          disabled: {Muscle.chestLeft},
          highlight: Colors.blue,
          disabledColor: Colors.grey.withValues(alpha: 0.5),
        ),
      );
      expect(alpha, closeTo(255 * 0.5 * 0.4, 2));
    });

    test('unselected, enabled muscles are not drawn', () async {
      expect(await alphaAt(chestInterior, painter(highlight: Colors.blue)), 0);
    });
  });
}
