/// Enumeration of all available muscles in the body diagram.
///
/// This enum represents muscles that can be selected on the interactive body
/// diagram, with left/right variants where applicable. Traps, delts,
/// forearms and calves are drawn in both views and map to the same value, so
/// a selection stays highlighted when the view is flipped.
///
/// Example:
/// ```dart
/// final muscle = Muscle.bicepsLeft;
/// print(muscle.displayName); // "Biceps Left"
/// ```
enum Muscle {
  // Both views
  trapsLeft,
  trapsRight,
  deltsLeft,
  deltsRight,
  // Front view only
  chestLeft,
  chestRight,
  abs,
  // Back view only
  tricepsLeft,
  tricepsRight,
  // Front view only
  bicepsLeft,
  bicepsRight,
  // Both views
  forearmsLeft,
  forearmsRight,
  // Front view only
  quadsLeft,
  quadsRight,
  // Both views
  calvesLeft,
  calvesRight,
  // Back view only
  latsBackLeft,
  latsBackRight,
  lowerLatsBackLeft,
  lowerLatsBackRight,
  glutesLeft,
  glutesRight,
  hamstringsLeft,
  hamstringsRight;

  /// Returns the unique identifier for this muscle.
  ///
  /// The ID is the same as the enum value's name.
  ///
  /// Example:
  /// ```dart
  /// Muscle.bicepsLeft.id; // "bicepsLeft"
  /// ```
  String get id {
    return name;
  }

  /// Returns a human-readable display name for this muscle.
  ///
  /// Each word of the enum name is capitalized and separated by a space.
  ///
  /// Example:
  /// ```dart
  /// Muscle.bicepsLeft.displayName; // "Biceps Left"
  /// Muscle.lowerLatsBackRight.displayName; // "Lower Lats Back Right"
  /// ```
  String get displayName {
    final spaced = name.replaceAllMapped(
      RegExp(r'([A-Z])'),
      (match) => ' ${match.group(1)}',
    );
    return spaced[0].toUpperCase() + spaced.substring(1);
  }

  /// Finds a muscle by its ID string.
  ///
  /// Returns the matching [Muscle] if found, or `null` if no muscle with
  /// the given ID exists.
  ///
  /// [id] - The muscle ID to search for.
  ///
  /// Example:
  /// ```dart
  /// final muscle = Muscle.fromId('bicepsLeft');
  /// // muscle == Muscle.bicepsLeft
  /// ```
  static Muscle? fromId(String id) {
    try {
      return Muscle.values.firstWhere(
        (muscle) => muscle.id == id,
      );
    } catch (e) {
      return null;
    }
  }
}
