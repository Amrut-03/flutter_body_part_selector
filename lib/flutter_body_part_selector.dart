/// Flutter Body Part Selector
///
/// An interactive body selector package for Flutter that allows users to select
/// muscles on a body diagram. Users can tap on muscles in the SVG body diagram
/// or select them programmatically, with visual highlighting of selected muscles.
///
/// The package includes:
/// - [InteractiveBodySvg]: The main widget for displaying the interactive body diagram
/// - [BodyMapController]: Controller for managing selection state
/// - [Muscle]: Enumeration of all available muscles
///
/// Example:
/// ```dart
/// import 'package:flutter_body_part_selector/flutter_body_part_selector.dart';
///
/// final controller = BodyMapController();
///
/// InteractiveBodySvg(
///   isFront: controller.isFront,
///   selectedMuscles: controller.selectedMuscles,
///   onMuscleTap: controller.toggleMuscle,
/// )
/// ```
library;

// Domain layer - entities
export 'src/domain/muscle.dart';

// Presentation layer - controllers and widgets
export 'src/presentation/body_map_controller.dart';
export 'src/presentation/interactive_body_svg.dart';
