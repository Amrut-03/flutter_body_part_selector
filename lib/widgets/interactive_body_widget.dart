import 'package:flutter/material.dart';
import '../core/models/muscle.dart';
import '../features/body_map/body_map_controller.dart';
import '../features/body_map/widgets/interactive_body_svg.dart';

/// A complete interactive body selector widget with built-in controller
/// 
/// This widget provides a ready-to-use body selector with front/back view
/// toggle and muscle selection capabilities.
/// 
/// The package includes default SVG assets, so you can use it without specifying asset paths:
/// 
/// Example (simplest usage):
/// ```dart
/// InteractiveBodyWidget(
///   onMuscleSelected: (muscle) {
///     print('Selected: $muscle');
///   },
/// )
/// ```
/// 
/// Or specify custom asset paths if needed:
/// ```dart
/// InteractiveBodyWidget(
///   frontAsset: 'packages/flutter_body_part_selector/assets/svg/body_front.svg',
///   backAsset: 'packages/flutter_body_part_selector/assets/svg/body_back.svg',
///   onMuscleSelected: (muscle) {
///     print('Selected: $muscle');
///   },
/// )
/// ```
class InteractiveBodyWidget extends StatefulWidget {
  /// Asset path for the front body SVG
  /// Defaults to the package's included front body SVG
  final String? frontAsset;

  /// Asset path for the back body SVG
  /// Defaults to the package's included back body SVG
  final String? backAsset;

  /// Callback when a muscle is selected
  final Function(Muscle)? onMuscleSelected;

  /// Callback when selection is cleared
  final VoidCallback? onSelectionCleared;

  /// Currently selected muscles (for programmatic control) - multi-select only
  final Set<Muscle>? selectedMuscles;

  /// Initial view (front or back)
  final bool initialIsFront;

  /// Color to highlight selected muscles
  final Color? highlightColor;

  /// Base color for unselected muscles
  final Color? baseColor;

  /// Stroke width for selected muscles
  final double selectedStrokeWidth;

  /// Stroke width for unselected muscles
  final double unselectedStrokeWidth;

  /// Whether selection is enabled
  final bool enableSelection;

  /// How the SVG should be fitted
  final BoxFit fit;

  /// Padding for hit-testing
  final double hitTestPadding;

  /// Width of the widget
  final double? width;

  /// Height of the widget
  final double? height;

  /// Alignment of the SVG
  final Alignment alignment;

  /// Show flip button in app bar
  final bool showFlipButton;

  /// Show clear button in app bar
  final bool showClearButton;

  /// Custom app bar
  final PreferredSizeWidget? appBar;

  /// Background color
  final Color? backgroundColor;

  /// Custom header widget to show selected muscles
  final Widget Function(Set<Muscle>)? selectedMusclesHeader;

  const InteractiveBodyWidget({
    super.key,
    this.frontAsset,
    this.backAsset,
    this.onMuscleSelected,
    this.onSelectionCleared,
    this.selectedMuscles,
    this.initialIsFront = true,
    this.highlightColor,
    this.baseColor,
    this.selectedStrokeWidth = 2.0,
    this.unselectedStrokeWidth = 1.0,
    this.enableSelection = true,
    this.fit = BoxFit.contain,
    this.hitTestPadding = 10.0,
    this.width,
    this.height,
    this.alignment = Alignment.center,
    this.showFlipButton = true,
    this.showClearButton = true,
    this.appBar,
    this.backgroundColor,
    this.selectedMusclesHeader,
  });

  @override
  State<InteractiveBodyWidget> createState() => _InteractiveBodyWidgetState();
}

class _InteractiveBodyWidgetState extends State<InteractiveBodyWidget> {
  late BodyMapController _controller;

  @override
  void initState() {
    super.initState();
    _controller = BodyMapController();
    if (!widget.initialIsFront) {
      _controller.setBackView();
    }
    if (widget.selectedMuscles != null && widget.selectedMuscles!.isNotEmpty) {
      _controller.setInitialSelection(widget.selectedMuscles!);
    }
    _controller.addListener(_onControllerChanged);
  }

  @override
  void didUpdateWidget(InteractiveBodyWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedMuscles != oldWidget.selectedMuscles) {
      if (widget.selectedMuscles != null && widget.selectedMuscles!.isNotEmpty) {
        _controller.setInitialSelection(widget.selectedMuscles!);
      } else {
        _controller.clearSelection();
      }
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerChanged);
    _controller.dispose();
    super.dispose();
  }

  void _onControllerChanged() {
    if (_controller.selectedMuscles.isNotEmpty) {
      // Call callback for each selected muscle (or just the first one for backward compatibility)
      if (widget.onMuscleSelected != null) {
        for (final muscle in _controller.selectedMuscles) {
          widget.onMuscleSelected!.call(muscle);
        }
      }
    } else {
      widget.onSelectionCleared?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: widget.backgroundColor ?? Colors.black,
      appBar: widget.appBar ??
          (widget.showFlipButton || widget.showClearButton
              ? AppBar(
                  title: const Text('Interactive Body Selector'),
                  actions: [
                    if (widget.showFlipButton)
                      IconButton(
                        icon: const Icon(Icons.flip),
                        onPressed: _controller.toggleView,
                        tooltip: 'Flip view',
                      ),
                    if (widget.showClearButton && _controller.selectedMuscles.isNotEmpty)
                      IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _controller.clearSelection();
                        },
                        tooltip: 'Clear selection',
                      ),
                  ],
                )
              : null),
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return Column(
            children: [
              if (_controller.selectedMuscles.isNotEmpty)
                widget.selectedMusclesHeader?.call(_controller.selectedMuscles) ??
                    Container(
                      padding: const EdgeInsets.all(16),
                      color: widget.highlightColor?.withValues(alpha: 0.8) ??
                          Colors.blue.shade900,
                      width: double.infinity,
                      child: Text(
                        'Selected: ${_controller.selectedMuscles.length} muscle${_controller.selectedMuscles.length == 1 ? '' : 's'}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
              Expanded(
                child: Center(
                      child: InteractiveBodySvg(
                        asset: _controller.isFront
                            ? (widget.frontAsset ?? 'packages/flutter_body_part_selector/assets/svg/body_front.svg')
                            : (widget.backAsset ?? 'packages/flutter_body_part_selector/assets/svg/body_back.svg'),
                    selectedMuscles: _controller.selectedMuscles,
                    onMuscleTap: _controller.selectMuscle,
                    highlightColor: widget.highlightColor,
                    baseColor: widget.baseColor,
                    selectedStrokeWidth: widget.selectedStrokeWidth,
                    unselectedStrokeWidth: widget.unselectedStrokeWidth,
                    enableSelection: widget.enableSelection,
                    fit: widget.fit,
                    hitTestPadding: widget.hitTestPadding,
                    width: widget.width,
                    height: widget.height,
                    alignment: widget.alignment,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
