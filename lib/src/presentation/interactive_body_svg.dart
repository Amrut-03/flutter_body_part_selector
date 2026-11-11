import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../data/body_diagram.dart';
import '../data/svg_asset_datasource.dart';
import '../domain/muscle.dart';
import 'body_diagram_painter.dart';

/// A widget that displays an interactive SVG body diagram.
///
/// This widget allows users to tap on muscles to select them, with visual
/// highlighting of selected muscles. The widget automatically uses the package's
/// built-in SVG assets based on the [isFront] parameter.
///
/// The widget does not own the selection: it renders [selectedMuscles] and
/// reports taps through [onMuscleTap]. Pair it with a [BodyMapController] or
/// any other state holder.
///
/// Example:
/// ```dart
/// InteractiveBodySvg(
///   isFront: true,
///   selectedMuscles: {Muscle.bicepsLeft, Muscle.tricepsRight},
///   onMuscleTap: (muscle) {
///     print('Selected: $muscle');
///   },
///   highlightColor: Colors.blue,
/// )
/// ```
class InteractiveBodySvg extends StatefulWidget {
  /// Optional path to a custom SVG asset.
  ///
  /// When `null` (the default), the package's built-in front or back diagram
  /// is used based on [isFront]. When set, this asset is loaded instead. Each
  /// muscle must be a `<path>`, or a `<g>` of paths, whose `id` matches the
  /// built-in assets (for example `biceps_left`). If the asset can't be
  /// loaded or parsed, an error is shown.
  final String? asset;

  /// Whether to show the front (`true`) or back (`false`) diagram.
  final bool isFront;

  /// Muscles drawn highlighted with [highlightColor].
  final Set<Muscle>? selectedMuscles;

  /// Muscles drawn greyed out with [disabledColor]. Taps on them go to
  /// [onMuscleTapDisabled] instead of [onMuscleTap].
  final Set<Muscle>? disabledMuscles;

  /// Called when an enabled muscle is tapped.
  final Function(Muscle)? onMuscleTap;

  /// Fill and stroke color of selected muscles, alpha included.
  ///
  /// Defaults to [Colors.blue] at 60% opacity.
  final Color? highlightColor;

  /// Fill and stroke color of disabled muscles, alpha included. Disabled
  /// muscles are drawn at a further 40% opacity.
  ///
  /// Defaults to [Colors.grey].
  final Color? disabledColor;

  /// Stroke width of selected muscles, in SVG units.
  final double selectedStrokeWidth;

  /// Stroke width of disabled muscles and of the body outline, in SVG units.
  final double unselectedStrokeWidth;

  /// Whether the diagram responds to taps and long presses. When `false`,
  /// taps on any muscle go to [onMuscleTapDisabled].
  final bool enableSelection;

  /// How the diagram is inscribed into the space allocated for it.
  final BoxFit fit;

  /// How far outside a muscle's edge, in SVG units, a tap still counts as
  /// hitting it. Only used when the tap is not inside any muscle.
  final double hitTestPadding;

  /// Width of the diagram. When only one of [width] and [height] is given,
  /// the other follows from the SVG's aspect ratio.
  final double? width;

  /// Height of the diagram. See [width].
  final double? height;

  /// How the diagram is aligned within its bounds.
  final Alignment alignment;

  /// Called when a disabled muscle is tapped, or any muscle while
  /// [enableSelection] is `false`.
  final Function(Muscle)? onMuscleTapDisabled;

  /// Called when a muscle is long-pressed.
  final Function(Muscle)? onMuscleLongPress;

  /// How the gesture detector over the diagram behaves during hit testing.
  final HitTestBehavior hitTestBehavior;

  /// Wraps the diagram each time a muscle is newly selected.
  ///
  /// Called with the rendered diagram as `child` and the muscle that was just
  /// added to [selectedMuscles]. The returned subtree is rebuilt from scratch
  /// on every new selection, so a `TweenAnimationBuilder` or implicit
  /// animation in it replays each time. While no newly selected muscle is
  /// still selected, the diagram is shown unwrapped.
  final Widget Function(BuildContext context, Widget child, Muscle muscle)?
      onSelectAnimationBuilder;

  /// Text shown in a [SnackBar] when a muscle is long-pressed. Return `null`
  /// to show nothing. Needs a [ScaffoldMessenger] above this widget.
  final String? Function(Muscle muscle)? tooltipBuilder;

  /// Screen-reader label for each selected muscle. The labels of all
  /// selected muscles are joined with commas. When nothing is selected, a
  /// generic description of the diagram is announced.
  final String? Function(Muscle muscle)? semanticLabelBuilder;

  /// When `true`, taps on enabled muscles are ignored.
  @Deprecated(
    'Ignores taps for as long as it is true and is no longer needed to avoid '
    'flicker. Pass the starting selection via selectedMuscles (or '
    'BodyMapController(initialSelectedMuscles: ...)) instead. '
    'Will be removed in 2.0.0.',
  )
  final bool isInitialSelection;

  /// Builds the widget shown while the SVG asset is loading.
  ///
  /// Defaults to a centered [CircularProgressIndicator]. Because that
  /// indicator animates indefinitely, `WidgetTester.pumpAndSettle()` cannot
  /// settle while the SVG is loading in widget tests. Pass a static widget
  /// here in tests to avoid that:
  ///
  /// ```dart
  /// InteractiveBodySvg(
  ///   loadingBuilder: (context) => const SizedBox.shrink(),
  /// )
  /// ```
  final WidgetBuilder? loadingBuilder;

  /// Creates an interactive body diagram.
  const InteractiveBodySvg({
    super.key,
    this.asset,
    this.isFront = true,
    this.selectedMuscles,
    this.disabledMuscles,
    this.onMuscleTap,
    this.highlightColor,
    this.disabledColor,
    this.selectedStrokeWidth = 2.0,
    this.unselectedStrokeWidth = 1.0,
    this.enableSelection = true,
    this.fit = BoxFit.contain,
    this.hitTestPadding = 2.0,
    this.width,
    this.height,
    this.alignment = Alignment.center,
    this.onMuscleTapDisabled,
    this.onMuscleLongPress,
    this.hitTestBehavior = HitTestBehavior.deferToChild,
    this.onSelectAnimationBuilder,
    this.tooltipBuilder,
    this.semanticLabelBuilder,
    @Deprecated('No longer needed. Will be removed in 2.0.0.')
    this.isInitialSelection = false,
    this.loadingBuilder,
  });

  String get _effectiveAsset =>
      asset ?? SvgAssetDataSource().getAssetPath(isFront);

  @override
  State<InteractiveBodySvg> createState() => _InteractiveBodySvgState();
}

class _InteractiveBodySvgState extends State<InteractiveBodySvg> {
  static const Color _outlineColor = Color(0xFFE0E0E0);

  /// Parsed diagrams per asset path, stored only after a successful load.
  ///
  /// Never caches an in-flight Future: under the widget-test fake clock such
  /// a Future may never complete, and a cached copy would hang every later
  /// load in the same test isolate.
  static final Map<String, BodyDiagram> _cache = {};

  /// The diagram on screen. While another asset loads, the previous one
  /// stays visible (and tappable) until the new one is ready.
  BodyDiagram? _diagram;
  String? _loadError;

  /// Incremented per load, so a load that finishes after a newer one
  /// started is discarded instead of overwriting it.
  int _loadSerial = 0;

  /// Muscle most recently added to the selection, for
  /// [InteractiveBodySvg.onSelectAnimationBuilder].
  Muscle? _animatedMuscle;
  int _selectionSerial = 0;
  final GlobalKey _diagramKey = GlobalKey();

  Set<Muscle> get _selectedMuscles => widget.selectedMuscles ?? const {};
  Set<Muscle> get _disabledMuscles => widget.disabledMuscles ?? const {};

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(InteractiveBodySvg oldWidget) {
    super.didUpdateWidget(oldWidget);
    _trackNewSelection(oldWidget.selectedMuscles ?? const {});
    // Selection, colors and stroke widths only need a repaint, which the
    // painter's shouldRepaint handles. Only a new asset needs loading.
    if (oldWidget._effectiveAsset != widget._effectiveAsset) {
      _load();
    }
  }

  void _trackNewSelection(Set<Muscle> oldSelection) {
    final added = _selectedMuscles.difference(oldSelection);
    if (added.isNotEmpty) {
      _animatedMuscle = added.last;
      _selectionSerial++;
    } else if (_animatedMuscle != null &&
        !_selectedMuscles.contains(_animatedMuscle)) {
      _animatedMuscle = null;
    }
  }

  /// Loads [InteractiveBodySvg._effectiveAsset]. Synchronous when cached,
  /// so flipping back to an already-seen view never shows the loader.
  void _load() {
    final asset = widget._effectiveAsset;
    final serial = ++_loadSerial;

    final cached = _cache[asset];
    if (cached != null) {
      // Called from initState/didUpdateWidget, which are followed by build.
      _diagram = cached;
      _loadError = null;
      return;
    }
    unawaited(_loadUncached(asset, serial, builtIn: widget.asset == null));
  }

  Future<void> _loadUncached(
    String asset,
    int serial, {
    required bool builtIn,
  }) async {
    // Defer past initState so DefaultAssetBundle.of(context) is allowed.
    // A microtask (unlike Future.delayed) leaves no pending Timer, which
    // would otherwise fail widget tests that end before it fires.
    await Future<void>.microtask(() {});
    if (!mounted || serial != _loadSerial) return;

    try {
      final svg = await _loadString(asset, builtIn: builtIn);
      if (!mounted || serial != _loadSerial) return;

      final diagram = BodyDiagram.parse(svg);
      _cache[asset] = diagram;
      if (!mounted || serial != _loadSerial) return;
      setState(() {
        _diagram = diagram;
        _loadError = null;
      });
    } catch (e) {
      if (!mounted || serial != _loadSerial) return;
      setState(() {
        // Show the failure rather than leaving the previous asset on screen.
        _diagram = null;
        _loadError = e.toString();
      });
    }
  }

  Future<String> _loadString(String asset, {required bool builtIn}) async {
    // The un-prefixed path only resolves inside this package's own tests and
    // example. Never fall back to it for a custom asset, or a missing custom
    // asset would silently show the built-in diagram.
    final candidates = [
      asset,
      if (builtIn) SvgAssetDataSource().getAssetPathDirect(widget.isFront),
    ];
    final bundles = [rootBundle, DefaultAssetBundle.of(context)];

    Object? lastError;
    for (final candidate in candidates) {
      for (final bundle in bundles.toSet()) {
        try {
          // cache: false so the bundle never caches an in-flight Future (see
          // _cache).
          return await bundle.loadString(candidate, cache: false);
        } catch (e) {
          lastError = e;
        }
      }
    }
    throw lastError ?? Exception('Failed to load SVG asset "$asset"');
  }

  Muscle? _muscleAt(Offset localPosition) {
    final diagram = _diagram;
    if (diagram == null) return null;

    // The gesture detector sits inside the FittedBox, at the diagram's
    // intrinsic size, so only the viewBox mapping is left to apply.
    final viewBox = diagram.viewBox;
    final svgPoint = Offset(
      viewBox.left + localPosition.dx * viewBox.width / diagram.size.width,
      viewBox.top + localPosition.dy * viewBox.height / diagram.size.height,
    );
    return diagram.muscleAt(svgPoint, tolerance: widget.hitTestPadding);
  }

  void _handleTap(TapUpDetails details) {
    final muscle = _muscleAt(details.localPosition);
    if (muscle == null) return;

    if (_disabledMuscles.contains(muscle) || !widget.enableSelection) {
      widget.onMuscleTapDisabled?.call(muscle);
      return;
    }

    // ignore: deprecated_member_use_from_same_package
    if (!widget.isInitialSelection) {
      widget.onMuscleTap?.call(muscle);
    }
  }

  void _handleLongPress(LongPressStartDetails details) {
    final muscle = _muscleAt(details.localPosition);
    if (muscle == null) return;

    widget.onMuscleLongPress?.call(muscle);

    final tooltipText = widget.tooltipBuilder?.call(muscle);
    if (tooltipText != null) {
      ScaffoldMessenger.maybeOf(context)?.showSnackBar(
        SnackBar(
          content: Text(tooltipText),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final diagram = _diagram;

    Widget child;
    if (_loadError != null) {
      child = _buildError(_loadError!);
    } else if (diagram == null) {
      child = widget.loadingBuilder?.call(context) ??
          const Center(child: CircularProgressIndicator());
    } else {
      child = _buildDiagram(diagram);
    }

    if (widget.width != null || widget.height != null) {
      child =
          SizedBox(width: widget.width, height: widget.height, child: child);
    }

    final semanticLabel = _buildSemanticLabel();
    if (semanticLabel != null) {
      child = Semantics(
        label: semanticLabel,
        button: widget.enableSelection,
        child: child,
      );
    }
    return child;
  }

  Widget _buildDiagram(BodyDiagram diagram) {
    Widget picture = Stack(
      children: [
        // Anything in the SVG besides muscles and outline. For the built-in
        // assets this is an empty <svg>, parsed once and cached by flutter_svg.
        SvgPicture.string(
          diagram.otherContentSvg,
          width: diagram.size.width,
          height: diagram.size.height,
        ),
        CustomPaint(
          size: diagram.size,
          painter: BodyDiagramPainter(
            diagram: diagram,
            selectedMuscles: _selectedMuscles,
            disabledMuscles: _disabledMuscles,
            highlightColor:
                widget.highlightColor ?? Colors.blue.withValues(alpha: 0.6),
            disabledColor: widget.disabledColor ?? Colors.grey,
            outlineColor: _outlineColor,
            selectedStrokeWidth: widget.selectedStrokeWidth,
            unselectedStrokeWidth: widget.unselectedStrokeWidth,
          ),
        ),
      ],
    );

    // With selection off, taps are only listened to when someone wants to
    // hear about them, so the diagram doesn't compete in the gesture arena.
    if (widget.enableSelection || widget.onMuscleTapDisabled != null) {
      picture = GestureDetector(
        behavior: widget.hitTestBehavior,
        onTapUp: _handleTap,
        onLongPressStart: widget.enableSelection ? _handleLongPress : null,
        child: picture,
      );
    }

    // Same layout as flutter_svg's SvgPicture: an outer box at the requested
    // (or intrinsic) size, the picture inscribed with fit and alignment.
    // Painting and hit testing both happen inside the FittedBox, in the
    // diagram's own coordinates, so they always line up.
    var width = widget.width;
    var height = widget.height;
    if (width == null && height == null) {
      width = diagram.size.width;
      height = diagram.size.height;
    } else if (height != null && width == null) {
      width = height / diagram.size.height * diagram.size.width;
    } else if (width != null && height == null) {
      height = width / diagram.size.width * diagram.size.height;
    }

    Widget result = RepaintBoundary(
      child: SizedBox(
        width: width,
        height: height,
        child: FittedBox(
          fit: widget.fit,
          alignment: widget.alignment,
          clipBehavior: Clip.hardEdge,
          child: SizedBox.fromSize(size: diagram.size, child: picture),
        ),
      ),
    );

    final animationBuilder = widget.onSelectAnimationBuilder;
    final animatedMuscle = _animatedMuscle;
    if (animationBuilder != null && animatedMuscle != null) {
      // A new key per selection restarts the caller's animation; the
      // GlobalKey moves the diagram's state across instead of rebuilding it.
      result = KeyedSubtree(
        key: ValueKey(_selectionSerial),
        child: animationBuilder(
          context,
          KeyedSubtree(key: _diagramKey, child: result),
          animatedMuscle,
        ),
      );
    } else {
      result = KeyedSubtree(key: _diagramKey, child: result);
    }
    return result;
  }

  Widget _buildError(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 48),
          const SizedBox(height: 16),
          const Text('Failed to load SVG', style: TextStyle(fontSize: 16)),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              message,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  String? _buildSemanticLabel() {
    final builder = widget.semanticLabelBuilder;
    if (builder == null) return null;

    if (_selectedMuscles.isNotEmpty) {
      final labels =
          _selectedMuscles.map(builder).whereType<String>().join(', ');
      return labels.isNotEmpty ? labels : null;
    }
    return 'Interactive body diagram. Tap to select muscles.';
  }
}
