/// Handles the retrieval of SVG asset paths for front and back views.
class SvgAssetDataSource {
  static const String _frontAssetPath =
      'packages/flutter_body_part_selector/assets/svg/body_front.svg';
  static const String _backAssetPath =
      'packages/flutter_body_part_selector/assets/svg/body_back.svg';
  
  // Direct paths (without packages/ prefix) as fallback
  static const String _frontAssetPathDirect = 'assets/svg/body_front.svg';
  static const String _backAssetPathDirect = 'assets/svg/body_back.svg';

  String getFrontAssetPath() => _frontAssetPath;

  String getBackAssetPath() => _backAssetPath;

  String getAssetPath(bool isFront) {
    return isFront ? _frontAssetPath : _backAssetPath;
  }
  
  /// Gets the direct asset path (without packages/ prefix) as fallback
  String getAssetPathDirect(bool isFront) {
    return isFront ? _frontAssetPathDirect : _backAssetPathDirect;
  }
}
