import 'package:flutter/material.dart';
import 'package:flutter_body_part_selector/feature/flutter_body_part_selector/domain/entities/muscle.dart';
import 'package:flutter_body_part_selector/feature/flutter_body_part_selector/presentation/controllers/body_map_controller.dart';
import 'package:flutter_body_part_selector/feature/flutter_body_part_selector/presentation/widgets/interactive_body_svg.dart';

class InteractiveBodyWidget extends StatefulWidget {

  final String? frontAsset;
  final String? backAsset;
  final Function(Muscle)? onMuscleSelected;
  final VoidCallback? onSelectionCleared;
  final Set<Muscle>? selectedMuscles;
  final bool initialIsFront;
  final Color? highlightColor;
  final Color? baseColor;
  final double selectedStrokeWidth;
  final double unselectedStrokeWidth;
  final bool enableSelection;
  final BoxFit fit;
  final double hitTestPadding;
  final double? width;
  final double? height;
  final Alignment alignment;
  final bool showFlipButton;
  final bool showClearButton;
  final PreferredSizeWidget? appBar;
  final Color? backgroundColor;
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
    // Create the controller with initial state
    // This is more efficient than setting it after creation
    _controller = BodyMapController(
      initialSelectedMuscles: widget.selectedMuscles,
      initialIsFront: widget.initialIsFront,
    );
    // Listen for changes so we can call callbacks when selection changes
    _controller.addListener(_onControllerChanged);
  }

  @override
  void didUpdateWidget(InteractiveBodyWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedMuscles != oldWidget.selectedMuscles) {
      if (widget.selectedMuscles != null && widget.selectedMuscles!.isNotEmpty) {
        _controller.setSelectedMuscles(widget.selectedMuscles!);
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
                    selectedMuscles: _controller.selectedMuscles.toSet(),
                    onMuscleTap: (muscle) => _controller.selectMuscle(muscle),
                    highlightColor: widget.highlightColor,
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
