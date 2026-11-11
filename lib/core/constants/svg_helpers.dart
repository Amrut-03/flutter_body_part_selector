import 'package:flutter/material.dart';
import '../../feature/flutter_body_part_selector/data/mappers/muscle_mapper.dart';

/// Configuration for SVG element colors and styling
class ColorConfig {
  final String highlightHex;
  final String disabledHex;
  final String selectedStrokeWidth;
  final String unselectedStrokeWidth;

  const ColorConfig({
    required this.highlightHex,
    required this.disabledHex,
    required this.selectedStrokeWidth,
    required this.unselectedStrokeWidth,
  });
}

/// Container for selected and disabled SVG IDs
class SvgIds {
  final Set<String> selected;
  final Set<String> disabled;

  const SvgIds({
    required this.selected,
    required this.disabled,
  });
}

/// Represents the state of an SVG element (selected, disabled, etc.)
class ElementState {
  final String? id;
  final bool isSelected;
  final bool isDisabled;
  final bool isMuscleElement;
  final bool isBodyOutline;
  final bool isPath;
  final bool isGroup;

  ElementState({
    required this.id,
    required this.isSelected,
    required this.isDisabled,
    required this.isMuscleElement,
    required this.isBodyOutline,
    required this.isPath,
    required this.isGroup,
  });

  factory ElementState.from(String? id, SvgIds svgIds) {
    final isSelected = id != null && svgIds.selected.contains(id);
    final isDisabled = id != null && svgIds.disabled.contains(id);
    final isMuscleElement = id != null && MuscleMapper.isValidSvgId(id);
    final isBodyOutline = id == 'front_body' || id == 'back_body';

    return ElementState(
      id: id,
      isSelected: isSelected,
      isDisabled: isDisabled,
      isMuscleElement: isMuscleElement,
      isBodyOutline: isBodyOutline,
      isPath: (isMuscleElement || isBodyOutline),
      isGroup: isMuscleElement,
    );
  }

  String fillColor(ColorConfig config) {
    if (isSelected) return config.highlightHex;
    if (isDisabled) return config.disabledHex;
    return 'none';
  }

  String strokeColor(ColorConfig config) {
    if (isSelected) return config.highlightHex;
    if (isDisabled) return config.disabledHex;
    if (isBodyOutline) return '#E0E0E0';
    return 'none';
  }

  String strokeWidth(ColorConfig config) {
    return isSelected ? config.selectedStrokeWidth : config.unselectedStrokeWidth;
  }
}

/// Data container for SVG group extraction
class GroupData {
  final Rect bounds;
  final List<Rect> pathBounds;
  final List<String> pathDataList;

  GroupData({
    required this.bounds,
    required this.pathBounds,
    required this.pathDataList,
  });
}

/// Parser for SVG path data that converts path commands to coordinate points
class PathParser {
  static const double _bezierSampleStep = 0.05;
  
  final List<String> tokens;
  double currentX = 0;
  double currentY = 0;
  double startX = 0;
  double startY = 0;
  String? lastCommand;
  int i = 0;
  final List<Offset> points = [];

  PathParser(this.tokens);

  List<Offset> parse() {
    while (i < tokens.length) {
      final token = tokens[i];

      if (_isCommand(token)) {
        lastCommand = token;
        i++;
        continue;
      }

      if (lastCommand == null) {
        i++;
        continue;
      }

      _processCommand();
    }

    return points;
  }

  bool _isCommand(String token) {
    return token.length == 1 && RegExp(r'[MmLlHhVvCcSsQqTtZz]').hasMatch(token);
  }

  void _processCommand() {
    final command = lastCommand![0];
    final isAbsolute = command == command.toUpperCase();

    switch (command.toUpperCase()) {
      case 'M':
        _handleMoveTo(isAbsolute);
        break;
      case 'L':
        _handleLineTo(isAbsolute);
        break;
      case 'H':
        _handleHorizontalLineTo(isAbsolute);
        break;
      case 'V':
        _handleVerticalLineTo(isAbsolute);
        break;
      case 'C':
        _handleCubicBezier(isAbsolute);
        break;
      case 'Q':
        _handleQuadraticBezier(isAbsolute);
        break;
      case 'Z':
        _handleClosePath();
        break;
      default:
        i++;
        break;
    }
  }

  void _handleMoveTo(bool isAbsolute) {
    if (i + 1 >= tokens.length) {
      i++;
      return;
    }

    final x = double.tryParse(tokens[i]);
    final y = double.tryParse(tokens[i + 1]);
    if (x == null || y == null) {
      i++;
      return;
    }

    if (isAbsolute) {
      currentX = x;
      currentY = y;
    } else {
      currentX += x;
      currentY += y;
    }

    if (lastCommand == 'M') {
      startX = currentX;
      startY = currentY;
      points.add(Offset(currentX, currentY));
      lastCommand = 'L';
    } else {
      points.add(Offset(currentX, currentY));
    }

    i += 2;
  }

  void _handleLineTo(bool isAbsolute) {
    if (i + 1 >= tokens.length) {
      i++;
      return;
    }

    final x = double.tryParse(tokens[i]);
    final y = double.tryParse(tokens[i + 1]);
    if (x == null || y == null) {
      i++;
      return;
    }

    if (isAbsolute) {
      currentX = x;
      currentY = y;
    } else {
      currentX += x;
      currentY += y;
    }

    points.add(Offset(currentX, currentY));
    i += 2;
  }

  void _handleHorizontalLineTo(bool isAbsolute) {
    if (i >= tokens.length) {
      i++;
      return;
    }

    final x = double.tryParse(tokens[i]);
    if (x == null) {
      i++;
      return;
    }

    if (isAbsolute) {
      currentX = x;
    } else {
      currentX += x;
    }

    points.add(Offset(currentX, currentY));
    i++;
  }

  void _handleVerticalLineTo(bool isAbsolute) {
    if (i >= tokens.length) {
      i++;
      return;
    }

    final y = double.tryParse(tokens[i]);
    if (y == null) {
      i++;
      return;
    }

    if (isAbsolute) {
      currentY = y;
    } else {
      currentY += y;
    }

    points.add(Offset(currentX, currentY));
    i++;
  }

  void _handleCubicBezier(bool isAbsolute) {
    while (i + 5 < tokens.length) {
      final x1 = double.tryParse(tokens[i]);
      final y1 = double.tryParse(tokens[i + 1]);
      final x2 = double.tryParse(tokens[i + 2]);
      final y2 = double.tryParse(tokens[i + 3]);
      final x = double.tryParse(tokens[i + 4]);
      final y = double.tryParse(tokens[i + 5]);

      if (x1 == null ||
          y1 == null ||
          x2 == null ||
          y2 == null ||
          x == null ||
          y == null) {
        break;
      }

      final p0 = Offset(currentX, currentY);
      final p1 = isAbsolute
          ? Offset(x1, y1)
          : Offset(currentX + x1, currentY + y1);
      final p2 = isAbsolute
          ? Offset(x2, y2)
          : Offset(currentX + x2, currentY + y2);
      final p3 = isAbsolute
          ? Offset(x, y)
          : Offset(currentX + x, currentY + y);

      _sampleCubicBezier(p0, p1, p2, p3);

      currentX = p3.dx;
      currentY = p3.dy;
      i += 6;
    }
  }

  void _handleQuadraticBezier(bool isAbsolute) {
    while (i + 3 < tokens.length) {
      final x1 = double.tryParse(tokens[i]);
      final y1 = double.tryParse(tokens[i + 1]);
      final x = double.tryParse(tokens[i + 2]);
      final y = double.tryParse(tokens[i + 3]);

      if (x1 == null || y1 == null || x == null || y == null) {
        break;
      }

      final p0 = Offset(currentX, currentY);
      final p1 = isAbsolute
          ? Offset(x1, y1)
          : Offset(currentX + x1, currentY + y1);
      final p2 = isAbsolute
          ? Offset(x, y)
          : Offset(currentX + x, currentY + y);

      _sampleQuadraticBezier(p0, p1, p2);

      currentX = p2.dx;
      currentY = p2.dy;
      i += 4;
    }
  }

  void _handleClosePath() {
    if (points.isNotEmpty) {
      points.add(Offset(startX, startY));
    }
    currentX = startX;
    currentY = startY;
    lastCommand = null;
    i++;
  }

  void _sampleCubicBezier(Offset p0, Offset p1, Offset p2, Offset p3) {
    for (double t = _bezierSampleStep; t <= 1.0; t += _bezierSampleStep) {
      points.add(_cubicBezierPoint(p0, p1, p2, p3, t));
    }
  }

  void _sampleQuadraticBezier(Offset p0, Offset p1, Offset p2) {
    for (double t = _bezierSampleStep; t <= 1.0; t += _bezierSampleStep) {
      points.add(_quadraticBezierPoint(p0, p1, p2, t));
    }
  }

  Offset _cubicBezierPoint(Offset p0, Offset p1, Offset p2, Offset p3, double t) {
    final u = 1 - t;
    final tt = t * t;
    final uu = u * u;
    final uuu = uu * u;
    final ttt = tt * t;

    final x = uuu * p0.dx + 3 * uu * t * p1.dx + 3 * u * tt * p2.dx + ttt * p3.dx;
    final y = uuu * p0.dy + 3 * uu * t * p1.dy + 3 * u * tt * p2.dy + ttt * p3.dy;

    return Offset(x, y);
  }

  Offset _quadraticBezierPoint(Offset p0, Offset p1, Offset p2, double t) {
    final u = 1 - t;
    final tt = t * t;
    final uu = u * u;

    final x = uu * p0.dx + 2 * u * t * p1.dx + tt * p2.dx;
    final y = uu * p0.dy + 2 * u * t * p1.dy + tt * p2.dy;

    return Offset(x, y);
  }
}
