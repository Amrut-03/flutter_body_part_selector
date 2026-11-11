import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';

import '../data/body_diagram.dart';
import '../domain/muscle.dart';

/// Paints the selected and disabled muscles of a [BodyDiagram], then the
/// body outline, into a box of the diagram's intrinsic size.
///
/// Unselected, enabled muscles are not drawn. The painter is cheap to
/// recreate: it holds no parsed data of its own, so a selection change is a
/// repaint rather than a reload.
class BodyDiagramPainter extends CustomPainter {
  /// Creates a painter for [diagram] with the given selection and styling.
  BodyDiagramPainter({
    required this.diagram,
    required this.selectedMuscles,
    required this.disabledMuscles,
    required this.highlightColor,
    required this.disabledColor,
    required this.outlineColor,
    required this.selectedStrokeWidth,
    required this.unselectedStrokeWidth,
  });

  /// Opacity applied on top of [disabledColor] to disabled muscles.
  static const double disabledOpacity = 0.4;

  final BodyDiagram diagram;
  final Set<Muscle> selectedMuscles;
  final Set<Muscle> disabledMuscles;
  final Color highlightColor;
  final Color disabledColor;
  final Color outlineColor;
  final double selectedStrokeWidth;
  final double unselectedStrokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final viewBox = diagram.viewBox;
    canvas
      ..save()
      ..scale(size.width / viewBox.width, size.height / viewBox.height)
      ..translate(-viewBox.left, -viewBox.top);

    for (final shape in diagram.muscles) {
      final selected = selectedMuscles.contains(shape.muscle);
      final disabled = disabledMuscles.contains(shape.muscle);
      if (!selected && !disabled) continue;

      final color = selected ? highlightColor : disabledColor;
      final fill = Paint()..color = color;
      final stroke = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = selected ? selectedStrokeWidth : unselectedStrokeWidth;

      if (disabled) {
        // Group opacity, like SVG `opacity`: fill and stroke composite first.
        canvas.saveLayer(
          shape.bounds.inflate(stroke.strokeWidth),
          Paint()
            ..color =
                const Color(0xFF000000).withValues(alpha: disabledOpacity),
        );
      }
      for (final path in shape.paths) {
        canvas
          ..drawPath(path, fill)
          ..drawPath(path, stroke);
      }
      if (disabled) canvas.restore();
    }

    final outline = Paint()
      ..color = outlineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = unselectedStrokeWidth;
    for (final path in diagram.outlines) {
      canvas.drawPath(path, outline);
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(BodyDiagramPainter oldDelegate) =>
      !identical(diagram, oldDelegate.diagram) ||
      highlightColor != oldDelegate.highlightColor ||
      disabledColor != oldDelegate.disabledColor ||
      outlineColor != oldDelegate.outlineColor ||
      selectedStrokeWidth != oldDelegate.selectedStrokeWidth ||
      unselectedStrokeWidth != oldDelegate.unselectedStrokeWidth ||
      !setEquals(selectedMuscles, oldDelegate.selectedMuscles) ||
      !setEquals(disabledMuscles, oldDelegate.disabledMuscles);
}
