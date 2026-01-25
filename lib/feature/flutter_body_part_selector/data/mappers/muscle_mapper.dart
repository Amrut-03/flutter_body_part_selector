import '../../domain/entities/muscle.dart';

/// This handles the mapping between domain entities and data layer representations.
class MuscleMapper {
  static const Map<String, Muscle> _svgIdToMuscle = {
    // Front view
    'traps_left': Muscle.trapsLeft,
    'traps_right': Muscle.trapsRight,
    'delts_left': Muscle.deltsLeft,
    'delts_right': Muscle.deltsRight,
    'chest_left': Muscle.chestLeft,
    'chest_right': Muscle.chestRight,
    'abs': Muscle.abs,
    'triceps_left': Muscle.tricepsLeft,
    'triceps_right': Muscle.tricepsRight,
    'biceps_left': Muscle.bicepsLeft,
    'biceps_right': Muscle.bicepsRight,
    'forearms_left': Muscle.forearmsLeft,
    'forearms_right': Muscle.forearmsRight,
    'quads_left': Muscle.quadsLeft,
    'quads_right': Muscle.quadsRight,
    'calves_left': Muscle.calvesLeft,
    'calves_right': Muscle.calvesRight,
    // Back view
    'lats_left': Muscle.latsBackLeft,
    'lats_right': Muscle.latsBackRight,
    'lowerlats_back_left': Muscle.lowerLatsBackLeft,
    'lowerlats_back_right': Muscle.lowerLatsBackRight,
    'glutes_left': Muscle.glutesLeft,
    'glutes_right': Muscle.glutesRight,
    'hamstrings_left': Muscle.hamstringsLeft,
    'hamstrings_right': Muscle.hamstringsRight,
  };

  static const Map<Muscle, String> _muscleToSvgId = {
    Muscle.trapsLeft: 'traps_left',
    Muscle.trapsRight: 'traps_right',
    Muscle.deltsLeft: 'delts_left',
    Muscle.deltsRight: 'delts_right',
    Muscle.chestLeft: 'chest_left',
    Muscle.chestRight: 'chest_right',
    Muscle.abs: 'abs',
    Muscle.tricepsLeft: 'triceps_left',
    Muscle.tricepsRight: 'triceps_right',
    Muscle.bicepsLeft: 'biceps_left',
    Muscle.bicepsRight: 'biceps_right',
    Muscle.forearmsLeft: 'forearms_left',
    Muscle.forearmsRight: 'forearms_right',
    Muscle.quadsLeft: 'quads_left',
    Muscle.quadsRight: 'quads_right',
    Muscle.calvesLeft: 'calves_left',
    Muscle.calvesRight: 'calves_right',
    Muscle.latsBackLeft: 'lats_left',
    Muscle.latsBackRight: 'lats_right',
    Muscle.lowerLatsBackLeft: 'lowerlats_back_left',
    Muscle.lowerLatsBackRight: 'lowerlats_back_right',
    Muscle.glutesLeft: 'glutes_left',
    Muscle.glutesRight: 'glutes_right',
    Muscle.hamstringsLeft: 'hamstrings_left',
    Muscle.hamstringsRight: 'hamstrings_right',
  };

  static Muscle? svgIdToMuscle(String svgId) {
    return _svgIdToMuscle[svgId];
  }

  static String? muscleToSvgId(Muscle muscle) {
    return _muscleToSvgId[muscle];
  }

  static bool isValidSvgId(String svgId) {
    return _svgIdToMuscle.containsKey(svgId);
  }

  static Set<String> getAllSvgIds() {
    return _svgIdToMuscle.keys.toSet();
  }
}
