import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:path_parsing/path_parsing.dart';
import 'package:xml/xml.dart';

import '../domain/muscle.dart';
import 'muscle_mapper.dart';

/// Element IDs of the body silhouette in the built-in assets.
const Set<String> bodyOutlineIds = {'front_body', 'back_body'};

/// One muscle in a [BodyDiagram]: the paths of its `<path>` element, or of
/// every `<path>` inside its `<g>` element, in SVG user units.
class MuscleShape {
  /// Creates a shape for [muscle] from its element's [paths].
  MuscleShape({
    required this.svgId,
    required this.muscle,
    required this.paths,
  }) : bounds = paths
            .map((p) => p.getBounds())
            .reduce((a, b) => a.expandToInclude(b));

  /// The element ID in the SVG, e.g. `biceps_left`.
  final String svgId;

  /// The muscle this element represents.
  final Muscle muscle;

  /// Drawn and hit-tested separately, as the SVG renders each child path.
  final List<ui.Path> paths;

  /// Union of the bounds of [paths].
  final ui.Rect bounds;

  /// Whether [point] (SVG user units) lies inside any of [paths].
  bool contains(ui.Offset point) =>
      bounds.contains(point) && paths.any((p) => p.contains(point));
}

/// A body SVG parsed once into paths, so selection changes only repaint.
///
/// Built from SVG text by [BodyDiagram.parse]. Muscle elements are the ones
/// whose `id` is known to [MuscleMapper]; [bodyOutlineIds] elements become
/// [outlines]. Everything else is kept as SVG text in [otherContentSvg].
class BodyDiagram {
  BodyDiagram._({
    required this.size,
    required this.viewBox,
    required this.muscles,
    required this.outlines,
    required this.otherContentSvg,
  });

  /// Intrinsic size: the root `width`/`height`, else the viewBox size.
  final ui.Size size;

  /// The root `viewBox`, which maps onto [size].
  final ui.Rect viewBox;

  /// Muscle shapes in document order (later ones are drawn on top).
  final List<MuscleShape> muscles;

  /// Body silhouette paths, drawn above the muscles.
  final List<ui.Path> outlines;

  /// The SVG with muscle and outline elements removed. Same root element and
  /// attributes as the source, so it renders at the same size and viewBox.
  final String otherContentSvg;

  /// Parses [svg] text. Throws a [FormatException] if it isn't a usable SVG.
  factory BodyDiagram.parse(String svg) {
    final XmlDocument document;
    try {
      document = XmlDocument.parse(svg);
    } on XmlException catch (e) {
      throw FormatException('Invalid SVG XML: ${e.message}');
    }
    final root = document.rootElement;
    if (root.localName != 'svg') {
      throw FormatException('Root element is <${root.localName}>, not <svg>');
    }

    final viewBox = _parseViewBox(root.getAttribute('viewBox'));
    final width = _parseLength(root.getAttribute('width'));
    final height = _parseLength(root.getAttribute('height'));
    final size = ui.Size(
      width ?? viewBox?.width ?? 0,
      height ?? viewBox?.height ?? 0,
    );
    if (size.isEmpty) {
      throw const FormatException('SVG has no viewBox and no width/height');
    }

    final muscles = <MuscleShape>[];
    final outlines = <ui.Path>[];
    final consumed = <XmlElement>[];

    for (final element in root.descendantElements) {
      final id = element.getAttribute('id');
      if (id == null) continue;

      final muscle = MuscleMapper.svgIdToMuscle(id);
      if (muscle != null) {
        final paths = _elementPaths(element);
        if (paths.isNotEmpty) {
          muscles.add(MuscleShape(svgId: id, muscle: muscle, paths: paths));
        }
        consumed.add(element);
      } else if (bodyOutlineIds.contains(id)) {
        outlines.addAll(_elementPaths(element));
        consumed.add(element);
      }
    }

    // Detach after iterating; descendants of a consumed group go with it.
    for (final element in consumed) {
      if (element.parent != null) element.remove();
    }

    return BodyDiagram._(
      size: size,
      viewBox: viewBox ?? ui.Offset.zero & size,
      muscles: List.unmodifiable(muscles),
      outlines: List.unmodifiable(outlines),
      otherContentSvg: document.toXmlString(),
    );
  }

  /// The muscle at [point] (SVG user units), or `null`.
  ///
  /// The topmost muscle containing [point] wins. If none does, points
  /// [tolerance] units away in eight directions are tried, so taps just
  /// outside a muscle's edge still count.
  Muscle? muscleAt(ui.Offset point, {double tolerance = 0}) {
    final exact = _topmostAt(point);
    if (exact != null || tolerance <= 0) return exact;

    for (var i = 0; i < 8; i++) {
      final angle = i * math.pi / 4;
      final probe = point +
          ui.Offset(math.cos(angle) * tolerance, math.sin(angle) * tolerance);
      final hit = _topmostAt(probe);
      if (hit != null) return hit;
    }
    return null;
  }

  Muscle? _topmostAt(ui.Offset point) {
    for (final shape in muscles.reversed) {
      if (shape.contains(point)) return shape.muscle;
    }
    return null;
  }

  static List<ui.Path> _elementPaths(XmlElement element) {
    final pathElements = element.localName == 'path'
        ? [element]
        : element.descendantElements.where((e) => e.localName == 'path');

    final paths = <ui.Path>[];
    for (final pathElement in pathElements) {
      final d = pathElement.getAttribute('d');
      if (d == null || d.trim().isEmpty) continue;

      final path = ui.Path()..fillType = _fillType(pathElement, element);
      writeSvgPathDataToPath(d, _UiPathProxy(path));
      paths.add(path);
    }
    return paths;
  }

  /// `fill-rule` of [path], inherited from ancestors up to [muscleRoot].
  static ui.PathFillType _fillType(XmlElement path, XmlElement muscleRoot) {
    XmlElement? current = path;
    while (current != null) {
      final rule = current.getAttribute('fill-rule') ??
          _styleProperty(current.getAttribute('style'), 'fill-rule');
      if (rule != null) {
        return rule.trim() == 'evenodd'
            ? ui.PathFillType.evenOdd
            : ui.PathFillType.nonZero;
      }
      if (identical(current, muscleRoot)) break;
      final parent = current.parent;
      current = parent is XmlElement ? parent : null;
    }
    return ui.PathFillType.nonZero;
  }

  static String? _styleProperty(String? style, String name) {
    if (style == null) return null;
    for (final declaration in style.split(';')) {
      final parts = declaration.split(':');
      if (parts.length == 2 && parts[0].trim() == name) return parts[1];
    }
    return null;
  }

  static ui.Rect? _parseViewBox(String? value) {
    if (value == null) return null;
    final numbers =
        value.trim().split(RegExp(r'[\s,]+')).map(double.tryParse).toList();
    if (numbers.length != 4 || numbers.contains(null)) {
      throw FormatException('Invalid viewBox "$value"');
    }
    final rect =
        ui.Rect.fromLTWH(numbers[0]!, numbers[1]!, numbers[2]!, numbers[3]!);
    return rect.isEmpty ? null : rect;
  }

  /// Parses an absolute length such as `337` or `337px`; `null` otherwise
  /// (missing, percentages, or other units).
  static double? _parseLength(String? value) {
    if (value == null) return null;
    final match =
        RegExp(r'^\s*([0-9]*\.?[0-9]+)\s*(px)?\s*$').firstMatch(value);
    final length = match == null ? null : double.parse(match.group(1)!);
    return length == null || length <= 0 ? null : length;
  }
}

class _UiPathProxy extends PathProxy {
  _UiPathProxy(this.path);

  final ui.Path path;

  @override
  void moveTo(double x, double y) => path.moveTo(x, y);

  @override
  void lineTo(double x, double y) => path.lineTo(x, y);

  @override
  void cubicTo(
    double x1,
    double y1,
    double x2,
    double y2,
    double x3,
    double y3,
  ) =>
      path.cubicTo(x1, y1, x2, y2, x3, y3);

  @override
  void close() => path.close();
}
