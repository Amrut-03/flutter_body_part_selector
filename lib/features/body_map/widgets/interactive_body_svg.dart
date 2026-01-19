import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:xml/xml.dart';
import '../../../core/models/muscle.dart';
import '../../../core/models/performance_mode.dart';
import '../../../core/constants/muscle_ids.dart';

/// An interactive SVG widget that allows users to tap on muscle paths
/// to select them, with visual highlighting of selected muscles.
/// 
/// Supports multi-select, disabled muscles, animations, and more.
class InteractiveBodySvg extends StatefulWidget {
  /// The asset path to the SVG file
  final String asset;

  /// The currently selected muscles (multi-select)
  final Set<Muscle>? selectedMuscles;

  /// Disabled muscles (locked/injured/unavailable) - shown greyed out
  final Set<Muscle>? disabledMuscles;

  /// Callback when a muscle is tapped
  final Function(Muscle)? onMuscleTap;

  /// Color to highlight selected muscles (default: Colors.blue with opacity)
  final Color? highlightColor;

  /// Base color for unselected muscles (default: Colors.white)
  final Color? baseColor;

  /// Color for disabled muscles (default: Colors.grey)
  final Color? disabledColor;

  /// Stroke width for selected muscles (default: 2.0)
  final double selectedStrokeWidth;

  /// Stroke width for unselected muscles (default: 1.0)
  final double unselectedStrokeWidth;

  /// Whether selection is enabled (default: true)
  final bool enableSelection;

  /// How the SVG should be fitted (default: BoxFit.contain)
  final BoxFit fit;

  /// Padding for hit-testing to make taps more forgiving (default: 10.0)
  final double hitTestPadding;

  /// Width of the widget (optional, if null, takes available space)
  final double? width;

  /// Height of the widget (optional, if null, takes available space)
  final double? height;

  /// Alignment of the SVG within the widget (default: Alignment.center)
  final Alignment alignment;

  /// Callback when a muscle is tapped but selection is disabled
  final Function(Muscle)? onMuscleTapDisabled;

  /// Callback when a muscle is long-pressed (for disable/enable toggle)
  final Function(Muscle)? onMuscleLongPress;

  /// Gesture precision mode for hit-testing
  final HitTestBehavior hitTestBehavior;

  /// Performance mode
  final PerformanceMode performanceMode;

  /// Animation builder for selected muscles
  /// Receives the child widget and should return an animated version
  final Widget Function(BuildContext context, Widget child, Muscle muscle)? onSelectAnimationBuilder;

  /// Tooltip/label builder for muscles
  /// Returns the tooltip text to show when hovering/tapping
  final String? Function(Muscle muscle)? tooltipBuilder;

  /// Semantic label builder for accessibility
  /// Returns the semantic label for screen readers
  final String? Function(Muscle muscle)? semanticLabelBuilder;

  /// Whether to use initial selection without triggering callbacks
  final bool isInitialSelection;

  const InteractiveBodySvg({
    super.key,
    required this.asset,
    this.selectedMuscles,
    this.disabledMuscles,
    this.onMuscleTap,
    this.highlightColor,
    this.baseColor,
    this.disabledColor,
    this.selectedStrokeWidth = 2.0,
    this.unselectedStrokeWidth = 1.0,
    this.enableSelection = true,
    this.fit = BoxFit.contain,
    this.hitTestPadding = 10.0,
    this.width,
    this.height,
    this.alignment = Alignment.center,
    this.onMuscleTapDisabled,
    this.onMuscleLongPress,
    this.hitTestBehavior = HitTestBehavior.deferToChild,
    this.performanceMode = PerformanceMode.balanced,
    this.onSelectAnimationBuilder,
    this.tooltipBuilder,
    this.semanticLabelBuilder,
    this.isInitialSelection = false,
  });

  @override
  State<InteractiveBodySvg> createState() => _InteractiveBodySvgState();
}

class _InteractiveBodySvgState extends State<InteractiveBodySvg> 
    with SingleTickerProviderStateMixin {
  String? _modifiedSvg;
  String? _cachedSvg; // Cache for performance
  String? _lastAsset; // Track last asset to detect changes
  bool _isLoading = true;
  Map<String, Rect>? _muscleBounds;
  Map<String, List<Rect>>? _groupPathBounds; // Store individual path bounds for groups
  List<String>? _orderedPathIds; // Path IDs in document order (for z-ordering)
  List<String>? _orderedGroupIds; // Group IDs in document order (for z-ordering)
  Size? _svgSize;
  Offset? _viewBoxOffset; // Store viewBox offset for coordinate transformation
  Set<Muscle>? _previousSelectedMuscles; // Track previous selection to prevent unnecessary rebuilds
  Set<Muscle>? _previousDisabledMuscles; // Track previous disabled muscles
  AnimationController? _animationController; // For continuous animations
  String? _lastBoundsAsset; // Track which asset bounds were extracted for
  bool _isProcessing = false; // Prevent concurrent processing
  bool _isWidgetReady = false; // Track if widget is fully laid out and ready for interactions

  @override
  void initState() {
    super.initState();
    // Don't initialize animation controller by default - it causes performance issues
    // Animation will be created on-demand if needed
    _loadAndModifySvg();
    
    // Ensure widget is fully laid out before enabling interactions
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {
          _isWidgetReady = true;
        });
      }
    });
  }

  @override
  void dispose() {
    _animationController?.dispose();
    super.dispose();
  }

  Set<Muscle> get _selectedMuscles {
    return widget.selectedMuscles ?? {};
  }

  Set<Muscle> get _disabledMuscles {
    return widget.disabledMuscles ?? {};
  }

  @override
  void didUpdateWidget(InteractiveBodySvg oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    final currentSelected = _selectedMuscles;
    final currentDisabled = _disabledMuscles;
    
    // Disable animation by default to prevent crashes
    // Animation can be enabled by users if they want, but it's disabled by default
    // for performance reasons
    
    // Only reload if necessary (prevent continuous state changes)
    final needsReload = 
        oldWidget.asset != widget.asset ||
        oldWidget.highlightColor != widget.highlightColor ||
        oldWidget.baseColor != widget.baseColor ||
        oldWidget.disabledColor != widget.disabledColor ||
        oldWidget.selectedStrokeWidth != widget.selectedStrokeWidth ||
        oldWidget.unselectedStrokeWidth != widget.unselectedStrokeWidth ||
        !_setsEqual(_previousSelectedMuscles, currentSelected) ||
        !_setsEqual(_previousDisabledMuscles, currentDisabled);
    
    if (needsReload) {
      _previousSelectedMuscles = Set.from(currentSelected);
      _previousDisabledMuscles = Set.from(currentDisabled);
      // Reload immediately for instant visual feedback
      // Don't reload if already processing
      if (!_isProcessing && mounted) {
        _loadAndModifySvg();
      }
    }
  }

  bool _setsEqual<T>(Set<T>? a, Set<T>? b) {
    if (a == null && b == null) return true;
    if (a == null || b == null) return false;
    if (a.length != b.length) return false;
    return a.every((item) => b.contains(item));
  }

  Future<void> _loadAndModifySvg() async {
    // Prevent concurrent processing
    if (_isProcessing) return;
    _isProcessing = true;
    
    // Only show loading indicator on first load, not on updates (prevents black blink)
    final isFirstLoad = _modifiedSvg == null;
    if (isFirstLoad && mounted) {
      setState(() => _isLoading = true);
    }
    
    try {
      // Use cached SVG string if available (for instant updates on selection changes)
      String svgString;
      final assetChanged = _lastAsset != widget.asset;
      
      // Fast path: reuse original SVG if available and asset hasn't changed
      if (!assetChanged && _cachedSvg != null) {
        svgString = _cachedSvg!;
      } else {
        // Load from assets only when asset changes
        svgString = await rootBundle.loadString(widget.asset);
        _lastAsset = widget.asset;
        // Always cache the original SVG
        _cachedSvg = svgString;
      }
      
      // Parse SVG synchronously for instant feedback (parsing is fast)
      final document = XmlDocument.parse(svgString);
      
      // Get selected muscles' SVG IDs
      final selectedSvgIds = _selectedMuscles
          .map((m) => muscleToSvgId[m])
          .whereType<String>()
          .toSet();
      
      // Get disabled muscles' SVG IDs
      final disabledSvgIds = _disabledMuscles
          .map((m) => muscleToSvgId[m])
          .whereType<String>()
          .toSet();

      // Highlight color with opacity
      final highlightColor = widget.highlightColor ?? 
          Colors.blue.withValues(alpha: 0.6);
      final baseColor = widget.baseColor ?? Colors.white;
      final disabledColor = widget.disabledColor ?? Colors.grey.withValues(alpha: 0.5);
      final selectedStrokeWidth = widget.selectedStrokeWidth.toString();
      final unselectedStrokeWidth = widget.unselectedStrokeWidth.toString();

      // Convert colors to hex strings
      final highlightHex = _colorToHex(highlightColor);
      final baseHex = _colorToHex(baseColor);
      final disabledHex = _colorToHex(disabledColor);

      // Get SVG dimensions and viewBox offset
      final svgElement = document.findAllElements('svg').firstOrNull;
      if (svgElement != null) {
        final viewBox = svgElement.getAttribute('viewBox');
        if (viewBox != null) {
          final values = viewBox.split(' ').map(double.parse).toList();
          if (values.length >= 4) {
            // viewBox format: "x y width height"
            _viewBoxOffset = Offset(values[0], values[1]);
            _svgSize = Size(values[2], values[3]);
          }
        }
      }

      // Extract bounds for all muscle elements (only if asset changed or not extracted yet)
      // IMPORTANT: Always extract bounds on first load to enable tap detection
      final boundsAssetChanged = _lastBoundsAsset != widget.asset;
      if (boundsAssetChanged || _muscleBounds == null || _svgSize == null || _viewBoxOffset == null) {
        _groupPathBounds = null; // Reset before extracting
        _orderedPathIds = null; // Reset ordered lists
        _orderedGroupIds = null;
        // Extract bounds - cache this to avoid repeated extraction
        _muscleBounds = _extractMuscleBounds(document);
        _lastBoundsAsset = widget.asset;
        // Ensure viewBoxOffset is set (it should be set above, but double-check)
        if (_viewBoxOffset == null) {
          final svgElement = document.findAllElements('svg').firstOrNull;
          if (svgElement != null) {
            final viewBox = svgElement.getAttribute('viewBox');
            if (viewBox != null) {
              final values = viewBox.split(' ').map(double.parse).toList();
              if (values.length >= 4) {
                _viewBoxOffset = Offset(values[0], values[1]);
                _svgSize = Size(values[2], values[3]);
              }
            }
          }
        }
      }

      // Process all elements in the SVG (start from root element)
      final rootElement = document.rootElement;
      _processElement(
        rootElement, 
        selectedSvgIds,
        disabledSvgIds,
        highlightHex, 
        baseHex,
        disabledHex,
        selectedStrokeWidth,
        unselectedStrokeWidth,
      );

      // Generate final SVG string
      final finalSvg = document.toXmlString(pretty: false);

      // Update state immediately for instant visual feedback
      // Ensure bounds and size are set before allowing interactions
      if (mounted) {
        setState(() {
          _modifiedSvg = finalSvg;
          _isLoading = false;
          _isProcessing = false;
          // Safety check: ensure bounds are ready (should already be set above)
          if (_muscleBounds == null || _svgSize == null) {
            // Re-extract bounds if missing (shouldn't happen, but safety check)
            _muscleBounds = _extractMuscleBounds(document);
            if (_svgSize == null) {
              final svgElement = document.findAllElements('svg').firstOrNull;
              if (svgElement != null) {
                final viewBox = svgElement.getAttribute('viewBox');
                if (viewBox != null) {
                  final values = viewBox.split(' ').map(double.parse).toList();
                  if (values.length >= 4) {
                    _viewBoxOffset = Offset(values[0], values[1]);
                    _svgSize = Size(values[2], values[3]);
                  }
                }
              }
            }
          }
        });
        
        // After state update, ensure widget is ready for interactions
        // Use a post-frame callback to ensure layout is complete
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && !_isWidgetReady) {
            setState(() {
              _isWidgetReady = true;
            });
          }
        });
      } else {
        _isProcessing = false;
      }
    } catch (e) {
      // Only log errors in debug mode
      assert(() {
        debugPrint('Error loading SVG: $e');
        return true;
      }());
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isProcessing = false;
        });
      } else {
        _isProcessing = false;
      }
    }
  }

  Map<String, Rect> _extractMuscleBounds(XmlDocument document) {
    final bounds = <String, Rect>{};
    _groupPathBounds = <String, List<Rect>>{};
    
    // Store path and group IDs in document order for proper z-ordering
    final pathIds = <String>[];
    final groupIds = <String>[];
    
    // Extract bounds from path elements (check in document order)
    final paths = document.findAllElements('path');
    for (final path in paths) {
      final id = path.getAttribute('id');
      if (id != null && svgIdToMuscle.containsKey(id)) {
        final d = path.getAttribute('d');
        if (d != null) {
                final rect = _parsePathBounds(d);
                if (rect != null) {
                  bounds[id] = rect;
                  pathIds.add(id);
                }
                // Removed debug prints for performance
              }
      }
    }

    // Extract bounds from group elements
    final groups = document.findAllElements('g');
    for (final group in groups) {
      final id = group.getAttribute('id');
      if (id != null && svgIdToMuscle.containsKey(id)) {
        // Get bounds from all paths in the group
        final groupPaths = group.findAllElements('path');
        final pathBounds = <Rect>[];
        Rect? groupRect;
        
        for (final path in groupPaths) {
          final d = path.getAttribute('d');
          if (d != null) {
            final rect = _parsePathBounds(d);
            if (rect != null) {
              pathBounds.add(rect);
              groupRect = groupRect == null 
                  ? rect 
                  : Rect.fromLTRB(
                      groupRect.left < rect.left ? groupRect.left : rect.left,
                      groupRect.top < rect.top ? groupRect.top : rect.top,
                      groupRect.right > rect.right ? groupRect.right : rect.right,
                      groupRect.bottom > rect.bottom ? groupRect.bottom : rect.bottom,
                    );
            }
          }
        }
        if (groupRect != null) {
                bounds[id] = groupRect;
                _groupPathBounds![id] = pathBounds; // Store individual path bounds
                groupIds.add(id);
              }
              // Removed debug prints for performance
      }
    }
    
    // Store ordered lists for hit-testing (paths first, then groups)
    _orderedPathIds = pathIds;
    _orderedGroupIds = groupIds;

    return bounds;
  }

  Rect? _parsePathBounds(String pathData) {
    // Improved parser that handles SVG path commands
    // Extracts all coordinate points from path commands (M, L, C, Q, Z, etc.)
    final numbers = RegExp(r'-?\d+\.?\d*')
        .allMatches(pathData)
        .map((m) => double.tryParse(m.group(0) ?? ''))
        .where((n) => n != null)
        .cast<double>()
        .toList();

    if (numbers.isEmpty) return null;

    // For paths, we need to extract actual coordinate points
    // SVG path commands: M (move), L (line), H (horizontal), V (vertical), 
    // C (curve), S (smooth curve), Q (quadratic), T (smooth quadratic), Z (close)
    // We'll extract all numbers and treat them as potential coordinates
    // For curves, we include control points which may extend beyond the path
    
    final coordinates = <Offset>[];
    
    // Extract coordinates - treat numbers in pairs as x,y
    for (int i = 0; i < numbers.length - 1; i += 2) {
      coordinates.add(Offset(numbers[i], numbers[i + 1]));
    }
    
    // If we have an odd number, add the last one as x (with y = previous y or 0)
    if (numbers.length % 2 == 1 && numbers.length > 1) {
      final lastY = coordinates.isNotEmpty ? coordinates.last.dy : 0.0;
      coordinates.add(Offset(numbers[numbers.length - 1], lastY));
    }

    if (coordinates.isEmpty) return null;

    double minX = coordinates[0].dx;
    double maxX = coordinates[0].dx;
    double minY = coordinates[0].dy;
    double maxY = coordinates[0].dy;

    for (final coord in coordinates) {
      if (coord.dx < minX) minX = coord.dx;
      if (coord.dx > maxX) maxX = coord.dx;
      if (coord.dy < minY) minY = coord.dy;
      if (coord.dy > maxY) maxY = coord.dy;
    }

    // Add a small margin to account for stroke width and curves
    const margin = 2.0;
    return Rect.fromLTRB(
      minX - margin,
      minY - margin,
      maxX + margin,
      maxY + margin,
    );
  }

  void _processElement(
    XmlElement element,
    Set<String> selectedSvgIds,
    Set<String> disabledSvgIds,
    String highlightHex,
    String baseHex,
    String disabledHex,
    String selectedStrokeWidth,
    String unselectedStrokeWidth,
  ) {
    // Check if this element has an ID that matches a muscle
    final id = element.getAttribute('id');
    final isSelected = id != null && selectedSvgIds.contains(id);
    final isDisabled = id != null && disabledSvgIds.contains(id);
    final isMuscleElement = id != null && svgIdToMuscle.containsKey(id);

    // Determine colors based on state: selected > disabled > normal
    final fillColor = isSelected 
        ? highlightHex 
        : isDisabled 
            ? disabledHex 
            : 'none';
    final strokeColor = isSelected 
        ? highlightHex 
        : isDisabled 
            ? disabledHex 
            : baseHex;
    final strokeWidth = isSelected 
        ? selectedStrokeWidth 
        : unselectedStrokeWidth;

    // If this is a path with a muscle ID, modify its color
    if (isMuscleElement && element.localName == 'path') {
      element.setAttribute('fill', fillColor);
      element.setAttribute('stroke', strokeColor);
      element.setAttribute('stroke-width', strokeWidth);
      if (isDisabled) {
        element.setAttribute('opacity', '0.4'); // More visible disabled state
      } else {
        element.removeAttribute('opacity'); // Remove opacity if not disabled
      }
    } else if (isMuscleElement && element.localName == 'g') {
      // Group element - only process direct child paths (not nested ones)
      // For groups: remove all strokes from inner paths to avoid inner outlines
      // Groups will only be visible when selected (filled)
      for (final child in element.children) {
        if (child is XmlElement) {
          final childId = child.getAttribute('id');
          // Only modify direct children that don't have their own muscle ID
          // This prevents double-processing
          if (childId == null || !svgIdToMuscle.containsKey(childId)) {
            if (child.localName == 'path') {
              // For paths inside groups: no stroke to avoid inner outlines
              child.setAttribute('fill', fillColor);
              child.setAttribute('stroke', 'none');
              child.setAttribute('stroke-width', '0');
              if (isDisabled) {
                child.setAttribute('opacity', '0.4'); // More visible disabled state
              } else {
                child.removeAttribute('opacity'); // Remove opacity if not disabled
              }
              // Remove any existing stroke-related attributes
              child.removeAttribute('stroke-linejoin');
              child.removeAttribute('stroke-linecap');
              child.removeAttribute('stroke-miterlimit');
            }
          }
        }
      }
      // Skip recursive processing of children inside a processed group
      // to avoid double-processing
      return;
    }

    // Recursively process child elements (only if we didn't return early)
    for (final child in element.children) {
      if (child is XmlElement) {
        _processElement(
          child, 
          selectedSvgIds,
          disabledSvgIds,
          highlightHex, 
          baseHex,
          disabledHex,
          selectedStrokeWidth,
          unselectedStrokeWidth,
        );
      }
    }
  }

  String _colorToHex(Color color) {
    final argb = color.toARGB32().toRadixString(16).padLeft(8, '0');
    return '#${argb.substring(2).toUpperCase()}';
  }

  bool _isPointInRect(Offset point, Rect rect, {double? padding}) {
    // Add padding to make hit-testing more forgiving
    final paddingValue = padding ?? widget.hitTestPadding;
    final expandedRect = Rect.fromLTRB(
      rect.left - paddingValue,
      rect.top - paddingValue,
      rect.right + paddingValue,
      rect.bottom + paddingValue,
    );
    return expandedRect.contains(point);
  }

  /// Helper method to find a muscle at a given point
  Muscle? _findMuscleAtPoint(Offset localPosition) {
    if (!_isWidgetReady || _muscleBounds == null || _svgSize == null || _viewBoxOffset == null) {
      return null;
    }

    final renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null || !renderBox.hasSize || renderBox.size.isEmpty) {
      return null;
    }

    // Calculate SVG coordinates from tap position
    final svgX = (localPosition.dx / renderBox.size.width) * _svgSize!.width;
    final svgY = (localPosition.dy / renderBox.size.height) * _svgSize!.height;
    final tapPoint = Offset(
      svgX + _viewBoxOffset!.dx,
      svgY + _viewBoxOffset!.dy,
    );

    // Find which muscle was tapped based on bounds
    String? tappedMuscleId;

    // First check standalone paths (they're drawn on top of groups)
    if (_orderedPathIds != null) {
      for (final pathId in _orderedPathIds!.reversed) {
        final bounds = _muscleBounds![pathId];
        if (bounds != null && _isPointInRect(tapPoint, bounds, padding: 5.0)) {
          tappedMuscleId = pathId;
          break;
        }
      }
    }

    // If not found in paths, check groups
    if (tappedMuscleId == null && _groupPathBounds != null && _orderedGroupIds != null) {
      final candidates = <MapEntry<String, double>>[];

      for (final groupId in _orderedGroupIds!.reversed) {
        final pathBounds = _groupPathBounds![groupId];
        if (pathBounds != null) {
          for (final pathRect in pathBounds.reversed) {
            if (_isPointInRect(tapPoint, pathRect, padding: 5.0)) {
              final center = pathRect.center;
              final distance = (tapPoint - center).distance;
              candidates.add(MapEntry(groupId, distance));
              break;
            }
          }
        }
      }

      if (candidates.isNotEmpty) {
        candidates.sort((a, b) => a.value.compareTo(b.value));
        tappedMuscleId = candidates.first.key;
      } else {
        // Fallback to overall group bounds
        for (final groupId in _orderedGroupIds!.reversed) {
          final overallBounds = _muscleBounds![groupId];
          if (overallBounds != null && _isPointInRect(tapPoint, overallBounds, padding: 3.0)) {
            tappedMuscleId = groupId;
            break;
          }
        }
      }
    }

    if (tappedMuscleId != null && svgIdToMuscle.containsKey(tappedMuscleId)) {
      return svgIdToMuscle[tappedMuscleId];
    }

    return null;
  }

  void _handleTap(TapDownDetails details) {
    final muscle = _findMuscleAtPoint(details.localPosition);
    if (muscle != null) {
      // Don't allow selection of disabled muscles
      if (_disabledMuscles.contains(muscle)) {
        widget.onMuscleTapDisabled?.call(muscle);
        return;
      }

      if (widget.enableSelection) {
        // Don't trigger callback for initial selection
        if (!widget.isInitialSelection) {
          widget.onMuscleTap?.call(muscle);
        }
      } else {
        widget.onMuscleTapDisabled?.call(muscle);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget svgWidget;
    
    // Show loading if SVG not ready OR if bounds not extracted yet OR widget not fully laid out
    if (_isLoading || _modifiedSvg == null || _muscleBounds == null || _svgSize == null || !_isWidgetReady) {
      svgWidget = const Center(child: CircularProgressIndicator());
    } else {
      // Use RepaintBoundary to isolate SVG rendering and prevent unnecessary repaints
      svgWidget = RepaintBoundary(
        child: SvgPicture.string(
          _modifiedSvg!,
          fit: widget.fit,
          alignment: widget.alignment,
        ),
      );
    }

    Widget result = svgWidget;
    
    // Wrap with size constraints if specified
    if (widget.width != null || widget.height != null) {
      result = SizedBox(
        width: widget.width,
        height: widget.height,
        child: result,
      );
    }

    // Wrap with gesture detector if selection is enabled
    if (widget.enableSelection) {
      result = GestureDetector(
        behavior: widget.hitTestBehavior,
        onTapDown: _handleTap,
        onLongPressStart: (details) {
          final muscle = _findMuscleAtPoint(details.localPosition);
          if (muscle != null) {
            // Call long press callback to toggle disable/enable
            widget.onMuscleLongPress?.call(muscle);
            
            // Show tooltip if builder is provided
            if (widget.tooltipBuilder != null) {
              final tooltipText = widget.tooltipBuilder!(muscle);
              if (tooltipText != null && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(tooltipText),
                    duration: const Duration(seconds: 2),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            }
          }
        },
        child: result,
      );
    }

    // Apply animations for selected muscles if provided
    // DISABLED BY DEFAULT - Animation causes performance issues and crashes
    // Users can enable it if they want, but it's not recommended for production
    // if (widget.onSelectAnimationBuilder != null && _selectedMuscles.isNotEmpty) {
    //   final firstSelected = _selectedMuscles.first;
    //   result = widget.onSelectAnimationBuilder!(context, result, firstSelected);
    // }
    
    // Add semantic labels for accessibility (always available, not just when selected)
    String? semanticLabel;
    if (widget.semanticLabelBuilder != null) {
      if (_selectedMuscles.isNotEmpty) {
        final labels = _selectedMuscles
            .map((m) => widget.semanticLabelBuilder!(m))
            .whereType<String>()
            .join(', ');
        semanticLabel = labels.isNotEmpty ? labels : null;
      } else {
        // Provide default semantic label even when nothing is selected
        semanticLabel = 'Interactive body diagram. Tap to select muscles.';
      }
    }
    
    if (semanticLabel != null) {
      result = Semantics(
        label: semanticLabel,
        button: widget.enableSelection,
        child: result,
      );
    }

    return result;
  }
}
