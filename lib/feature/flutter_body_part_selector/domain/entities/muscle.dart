/// This is the core business entity that represents a muscle
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

  String get id {
    return name;
  }

  String get displayName {
    return name
        .replaceAllMapped(
          RegExp(r'([A-Z])'),
          (match) => ' ${match.group(1)}',
        )
        .trim();
  }

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
