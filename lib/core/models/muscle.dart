/// Enum representing all available muscles in the body diagram
/// 
/// Each muscle has a stable string ID for consistent identification
enum Muscle {
  // Upper body - front
  trapsLeft,
  trapsRight,
  deltsLeft,
  deltsRight,
  chestLeft,
  chestRight,
  abs,
  latsFrontLeft,
  latsFrontRight,
  tricepsLeft,
  tricepsRight,
  bicepsLeft,
  bicepsRight,
  bicepsBrachialisLeft,
  bicepsBrachialisRight,
  forearmsLeft,
  forearmsRight,
  // Lower body - front
  quadsLeft,
  quadsRight,
  calvesLeft,
  calvesRight,
  // Back
  latsBackLeft,
  latsBackRight,
  lowerLatsBackLeft,
  lowerLatsBackRight,
  glutesLeft,
  glutesRight,
  hamstringsLeft,
  hamstringsRight;

  /// Stable string ID for this muscle
  /// Use this for persistence, API calls, or any external identification
  String get id {
    return name; // Uses the enum name as stable ID
  }

  /// Get a human-readable name for this muscle
  String get displayName {
    return name
        .replaceAllMapped(
          RegExp(r'([A-Z])'),
          (match) => ' ${match.group(1)}',
        )
        .trim();
  }

  /// Get muscle from stable ID
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
