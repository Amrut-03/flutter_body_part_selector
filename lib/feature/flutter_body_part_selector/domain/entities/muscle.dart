/// Enumeration of all available muscles in the body diagram.
///
/// This enum represents muscles that can be selected on the interactive body
/// diagram. Muscles are organized by body view (front or back) and include
/// left/right variants where applicable.
///
/// Example:
/// ```dart
/// final muscle = Muscle.bicepsLeft;
/// print(muscle.displayName); // "biceps Left"
/// ```
enum Muscle {
  // Front body
  trapsLeft,
  trapsRight,
  deltsLeft,
  deltsRight,
  chestLeft,
  chestRight,
  abs,
  tricepsLeft,
  tricepsRight,
  bicepsLeft,
  bicepsRight,
  forearmsLeft,
  forearmsRight,
  quadsLeft,
  quadsRight,
  calvesLeft,
  calvesRight,
  // Back body
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
  /// The display name adds spaces before capital letters for better readability.
  ///
  /// Example:
  /// ```dart
  /// Muscle.bicepsLeft.displayName; // "biceps Left"
  /// ```
  String get displayName {
    return name
        .replaceAllMapped(
          RegExp(r'([A-Z])'),
          (match) => ' ${match.group(1)}',
        )
        .trim();
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
