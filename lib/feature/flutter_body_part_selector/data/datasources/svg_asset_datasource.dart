/// Handles the retrieval of SVG asset paths for front and back views.
class SvgAssetDataSource {
  static const String _frontAssetPath =
      'packages/flutter_body_part_selector/assets/svg/body_front.svg';
  static const String _backAssetPath =
      'packages/flutter_body_part_selector/assets/svg/body_back.svg';

  String getFrontAssetPath() => _frontAssetPath;

  String getBackAssetPath() => _backAssetPath;

  String getAssetPath(bool isFront) {
    return isFront ? _frontAssetPath : _backAssetPath;
  }
}
