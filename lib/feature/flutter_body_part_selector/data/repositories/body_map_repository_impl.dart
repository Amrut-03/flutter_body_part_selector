import '../../domain/entities/muscle.dart';
import '../../domain/repositories/body_map_repository.dart';
import '../datasources/svg_asset_datasource.dart';
import '../mappers/muscle_mapper.dart';

/// This implements the repository interface using the data layer components.
class BodyMapRepositoryImpl implements BodyMapRepository {
  final SvgAssetDataSource _assetDataSource;

  BodyMapRepositoryImpl({SvgAssetDataSource? assetDataSource})
      : _assetDataSource = assetDataSource ?? SvgAssetDataSource();

  @override
  String getSvgAssetPath(bool isFront) {
    return _assetDataSource.getAssetPath(isFront);
  }

  @override
  String? getSvgIdForMuscle(Muscle muscle) {
    return MuscleMapper.muscleToSvgId(muscle);
  }

  @override
  Muscle? getMuscleForSvgId(String svgId) {
    return MuscleMapper.svgIdToMuscle(svgId);
  }

  @override
  bool isValidMuscleSvgId(String svgId) {
    return MuscleMapper.isValidSvgId(svgId);
  }
}
