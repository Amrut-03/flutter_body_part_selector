import '../entities/muscle.dart';

/// This defines the contract for accessing body map data,
abstract class BodyMapRepository {
  String getSvgAssetPath(bool isFront);

  String? getSvgIdForMuscle(Muscle muscle);

  Muscle? getMuscleForSvgId(String svgId);

  bool isValidMuscleSvgId(String svgId);
}
