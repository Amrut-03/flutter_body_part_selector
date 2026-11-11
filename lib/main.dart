import 'package:flutter/material.dart';
import 'package:flutter_body_part_selector/flutter_body_part_selector.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Body Part Selector',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const BodyPartSelectorScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class BodyPartSelectorScreen extends StatefulWidget {
  const BodyPartSelectorScreen({super.key});

  @override
  State<BodyPartSelectorScreen> createState() => _BodyPartSelectorScreenState();
}

/// Human-readable label, e.g. `Muscle.latsBackLeft` -> "Lats Back Left".
String _muscleLabel(Muscle muscle) {
  final name = muscle.displayName;
  return name.isEmpty ? name : name[0].toUpperCase() + name.substring(1);
}

class _BodyPartSelectorScreenState extends State<BodyPartSelectorScreen> {
  final BodyMapController _controller = BodyMapController();

  // Customization options (fixed for this demo; change here to try other props)
  final Color _highlightColor = Colors.blue;
  final Color _disabledColor = Colors.grey;
  final double _selectedStrokeWidth = 2.5;
  final double _unselectedStrokeWidth = 1.0;
  final double _hitTestPadding = 10.0;
  final BoxFit _boxFit = BoxFit.contain;
  final bool _enableSelection = true;
  final bool _showTooltips = true;
  final bool _showAnimations = true;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleDisabledMuscle(Muscle muscle) {
    if (_controller.isDisabled(muscle)) {
      _controller.enableMuscle(muscle);
    } else {
      // disableMuscle() also removes the muscle from the selection.
      _controller.disableMuscle(muscle);
    }
  }

  void _onMuscleLongPress(Muscle muscle) {
    final wasDisabled = _controller.isDisabled(muscle);
    _toggleDisabledMuscle(muscle);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${_muscleLabel(muscle)} ${wasDisabled ? 'enabled' : 'disabled'}'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _selectAll() {
    // Single notification; disabled and already-selected muscles are skipped.
    _controller.selectMultiple(Muscle.values.toSet());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Body Part Selector'),
        elevation: 2,
        actions: [
          IconButton(
            icon: const Icon(Icons.clear_all),
            onPressed: _controller.clearSelection,
            tooltip: 'Clear All Selections',
          ),
        ],
      ),
      body: SafeArea(
        // Only the body depends on controller state; the app bar and FAB
        // are not rebuilt on selection changes.
        child: ListenableBuilder(
          listenable: _controller,
          builder: (context, _) {
            // Read each (copied, unmodifiable) set once per build.
            final selected = _controller.selectedMuscles;
            final disabled = _controller.disabledMuscles;
            final isFront = _controller.isFront;

            return Column(
              children: [
                _ViewToggleBar(
                  isFront: isFront,
                  onFrontPressed: _controller.setFrontView,
                  onTogglePressed: _controller.toggleView,
                  onBackPressed: _controller.setBackView,
                ),
                Expanded(
                  flex: 3,
                  child: Container(
                    margin: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: _buildBodyMap(isFront, selected, disabled),
                    ),
                  ),
                ),
                _SelectionInfoBar(
                  selectedCount: selected.length,
                  disabledCount: disabled.length,
                  disabledColor: _disabledColor,
                  isFront: isFront,
                ),
                Expanded(
                  flex: 2,
                  child: _MuscleTabSection(
                    selectedMuscles: selected.toList(growable: false),
                    disabledMuscles: disabled.toList(growable: false),
                    disabledColor: _disabledColor,
                    onDisable: _toggleDisabledMuscle,
                    onDeselect: _controller.deselectMuscle,
                  ),
                ),
              ],
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _selectAll,
        icon: const Icon(Icons.select_all),
        label: const Text('Select All'),
        tooltip: 'Select All Body Parts',
      ),
    );
  }

  Widget _buildBodyMap(bool isFront, Set<Muscle> selected, Set<Muscle> disabled) {
    return InteractiveBodySvg(
      isFront: isFront,
      selectedMuscles: selected,
      disabledMuscles: disabled,
      // Disabled taps are already filtered by the widget and the controller.
      onMuscleTap: _enableSelection ? _controller.toggleMuscle : null,
      onMuscleLongPress: _onMuscleLongPress,
      highlightColor: _highlightColor.withValues(alpha: 0.6),
      disabledColor: _disabledColor,
      selectedStrokeWidth: _selectedStrokeWidth,
      unselectedStrokeWidth: _unselectedStrokeWidth,
      enableSelection: _enableSelection,
      fit: _boxFit,
      hitTestPadding: _hitTestPadding,
      tooltipBuilder: _showTooltips ? _muscleLabel : null,
      semanticLabelBuilder: (muscle) => '${_muscleLabel(muscle)} muscle',
      onSelectAnimationBuilder: _showAnimations
          ? (context, child, muscle) {
              return TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                builder: (context, value, child) {
                  return Opacity(
                    opacity: value,
                    child: Transform.scale(
                      scale: 0.9 + (0.1 * value),
                      child: child!,
                    ),
                  );
                },
                child: child,
              );
            }
          : null,
    );
  }
}

class _ViewToggleBar extends StatelessWidget {
  final bool isFront;
  final VoidCallback onFrontPressed;
  final VoidCallback onTogglePressed;
  final VoidCallback onBackPressed;

  const _ViewToggleBar({
    required this.isFront,
    required this.onFrontPressed,
    required this.onTogglePressed,
    required this.onBackPressed,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      color: colorScheme.surfaceContainerHighest,
      child: Row(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: ElevatedButton.icon(
                onPressed: onFrontPressed,
                icon: const Icon(Icons.person, size: 18),
                label: const Text('Front', style: TextStyle(fontSize: 12)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isFront ? colorScheme.primaryContainer : null,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                ),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: ElevatedButton.icon(
                onPressed: onTogglePressed,
                icon: const Icon(Icons.swap_horiz, size: 18),
                label: const Text('Toggle', style: TextStyle(fontSize: 12)),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                ),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: ElevatedButton.icon(
                onPressed: onBackPressed,
                icon: const Icon(Icons.person_outline, size: 18),
                label: const Text('Back', style: TextStyle(fontSize: 12)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: !isFront ? colorScheme.primaryContainer : null,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SelectionInfoBar extends StatelessWidget {
  final int selectedCount;
  final int disabledCount;
  final Color disabledColor;
  final bool isFront;

  const _SelectionInfoBar({
    required this.selectedCount,
    required this.disabledCount,
    required this.disabledColor,
    required this.isFront,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      color: theme.colorScheme.surfaceContainerHighest,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Selected: $selectedCount',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (disabledCount > 0)
                Text(
                  'Disabled: $disabledCount',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: disabledColor,
                  ),
                ),
            ],
          ),
          Text(
            'View: ${isFront ? "Front" : "Back"}',
            style: theme.textTheme.titleMedium,
          ),
        ],
      ),
    );
  }
}

class _MuscleTabSection extends StatelessWidget {
  final List<Muscle> selectedMuscles;
  final List<Muscle> disabledMuscles;
  final Color disabledColor;
  final void Function(Muscle) onDisable;
  final void Function(Muscle) onDeselect;

  const _MuscleTabSection({
    required this.selectedMuscles,
    required this.disabledMuscles,
    required this.disabledColor,
    required this.onDisable,
    required this.onDeselect,
  });

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          TabBar(
            tabs: [
              Tab(
                icon: const Icon(Icons.check_circle),
                text: 'Selected (${selectedMuscles.length})',
              ),
              Tab(
                icon: const Icon(Icons.block),
                text: 'Disabled (${disabledMuscles.length})',
              ),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                _buildSelectedTab(context),
                _buildDisabledTab(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedTab(BuildContext context) {
    if (selectedMuscles.isEmpty) {
      return _buildEmptyState(
        context,
        'No body parts selected.\nTap on the body map to select parts.\nLong press to disable parts.',
      );
    }
    final theme = Theme.of(context);
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: selectedMuscles.length,
      itemBuilder: (context, index) {
        final muscle = selectedMuscles[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: theme.colorScheme.primaryContainer,
              child: Icon(
                Icons.check_circle,
                color: theme.colorScheme.primary,
              ),
            ),
            title: Text(
              _muscleLabel(muscle),
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.block),
                  onPressed: () => onDisable(muscle),
                  tooltip: 'Disable',
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => onDeselect(muscle),
                  tooltip: 'Deselect',
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDisabledTab(BuildContext context) {
    if (disabledMuscles.isEmpty) {
      return _buildEmptyState(
        context,
        'No disabled parts.\nLong press on body parts to disable them.',
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: disabledMuscles.length,
      itemBuilder: (context, index) {
        final muscle = disabledMuscles[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          color: disabledColor.withValues(alpha: 0.1),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: disabledColor,
              child: const Icon(
                Icons.block,
                color: Colors.white,
              ),
            ),
            title: Text(
              _muscleLabel(muscle),
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: disabledColor,
                decoration: TextDecoration.lineThrough,
              ),
            ),
            trailing: IconButton(
              icon: const Icon(Icons.check_circle_outline),
              onPressed: () => onDisable(muscle),
              tooltip: 'Enable',
            ),
          ),
        );
      },
    );
  }

  static Widget _buildEmptyState(BuildContext context, String message) {
    final theme = Theme.of(context);
    return Center(
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: theme.textTheme.bodyLarge?.copyWith(
          color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
        ),
      ),
    );
  }
}
