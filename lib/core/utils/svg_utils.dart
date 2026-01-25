import 'package:flutter/material.dart';

/// Utility functions for SVG processing and widget operations

/// Convert a Flutter Color to a hex string format (#RRGGBB)
String colorToHex(Color color) {
  final argb = color.toARGB32().toRadixString(16).padLeft(8, '0');
  return '#${argb.substring(2).toUpperCase()}';
}

/// Compare two sets for equality (handles null cases)
bool setsEqual<T>(Set<T>? a, Set<T>? b) {
  if (a == null && b == null) return true;
  if (a == null || b == null) return false;
  if (a.length != b.length) return false;
  return a.every((item) => b.contains(item));
}

/// Expand a rectangle to include another rectangle
Rect expandRect(Rect rect1, Rect rect2) {
  return Rect.fromLTRB(
    rect1.left < rect2.left ? rect1.left : rect2.left,
    rect1.top < rect2.top ? rect1.top : rect2.top,
    rect1.right > rect2.right ? rect1.right : rect2.right,
    rect1.bottom > rect2.bottom ? rect1.bottom : rect2.bottom,
  );
}

/// Extract coordinate points from a list of numbers
List<Offset> extractCoordinates(List<double> numbers) {
  final coordinates = <Offset>[];
  for (int i = 0; i < numbers.length - 1; i += 2) {
    coordinates.add(Offset(numbers[i], numbers[i + 1]));
  }

  if (numbers.length % 2 == 1 && numbers.length > 1) {
    final lastY = coordinates.isNotEmpty ? coordinates.last.dy : 0.0;
    coordinates.add(Offset(numbers[numbers.length - 1], lastY));
  }

  return coordinates;
}

/// Calculate bounding rectangle from a list of coordinate points
Rect calculateBounds(List<Offset> coordinates, {double margin = 2.0}) {
  double minX = coordinates[0].dx;
  double maxX = coordinates[0].dx;
  double minY = coordinates[0].dy;
  double maxY = coordinates[0].dy;

  for (final coord in coordinates) {
    if (coord.dx < minX) minX = coord.dx;
    if (coord.dx > maxX) maxX = coord.dx;
    if (coord.dy < minY) minY = coord.dy;
    if (coord.dy > maxY) maxY = coord.dy;
  }

  return Rect.fromLTRB(
    minX - margin,
    minY - margin,
    maxX + margin,
    maxY + margin,
  );
}
