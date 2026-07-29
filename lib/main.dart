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

class _BodyPartSelectorScreenState extends State<BodyPartSelectorScreen> {
  late BodyMapController _controller;
  Set<Muscle> get _selectedMuscles => _controller.selectedMuscles;
  Set<Muscle> get _disabledMuscles => _controller.disabledMuscles;

  // Customization options
  final Color _highlightColor = Colors.blue;
  final Color _baseColor = Colors.white;
  Color _disabledColor = Colors.grey;
  double _selectedStrokeWidth = 2.5;
  double _unselectedStrokeWidth = 1.0;
  double _hitTestPadding = 10.0;
  PerformanceMode _performanceMode = PerformanceMode.balanced;
  BoxFit _boxFit = BoxFit.contain;
  bool _enableSelection = true;
  bool _showTooltips = true;
  bool _showAnimations = true;

  @override
  void initState() {
    super.initState();
    _controller = BodyMapController();
    _controller.addListener(_onControllerChanged);
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerChanged);
    _controller.dispose();
    super.dispose();
  }

  void _onControllerChanged() {
    setState(() {});
  }

  void _toggleMuscle(Muscle muscle) {
    if (_disabledMuscles.contains(muscle)) return;
    if (_selectedMuscles.contains(muscle)) {
      // Deselect: save current selection, clear all, then reselect all except this one
      final musclesToKeep = _selectedMuscles.where((m) => m != muscle).toSet();
      _controller.clearSelection();
      // Reselect all muscles except the one being deselected
      for (var m in musclesToKeep) {
        _controller.selectMuscle(m);
      }
    } else {
      // Select
      _controller.selectMuscle(muscle);
    }
  }

  void _toggleDisabledMuscle(Muscle muscle) {
    if (_disabledMuscles.contains(muscle)) {
      _controller.enableMuscle(muscle);
    } else {
      _controller.disableMuscle(muscle);
      if (_selectedMuscles.contains(muscle)) {
        final musclesToKeep = _selectedMuscles.where((m) => m != muscle).toSet();
        _controller.clearSelection();
        for (var m in musclesToKeep) {
          _controller.selectMuscle(m);
        }
      }
    }
  }

  void _clearAll() {
    _controller.clearSelection();
  }

  void _toggleView() {
    _controller.toggleView();
  }

  void _setFrontView() {
    _controller.setFrontView();
  }

  void _setBackView() {
    _controller.setBackView();
  }

  static String _getMuscleName(Muscle muscle) {
    return muscle.toString().split('.').last.replaceAllMapped(
      RegExp(r'([A-Z])'),
      (match) => ' ${match.group(1)}',
    ).trim();
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
            onPressed: _clearAll,
            tooltip: 'Clear All Selections',
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            _ViewToggleBar(
              isFront: _controller.isFront,
              onFrontPressed: _setFrontView,
              onTogglePressed: _toggleView,
              onBackPressed: _setBackView,
            ),

            // Body Map Selector with all features
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
                  child: InteractiveBodySvg(
                    isFront: _controller.isFront,
                    selectedMuscles: _selectedMuscles,
                    disabledMuscles: _disabledMuscles,
                    onMuscleTap: _enableSelection ? (muscle) {
                      _toggleMuscle(muscle);
                    } : null,
                    onMuscleLongPress: (muscle) {
                      // Long press to disable/enable muscle
                      final wasDisabled = _controller.isDisabled(muscle);
                      _toggleDisabledMuscle(muscle);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            !wasDisabled
                                ? '${_getMuscleName(muscle)} disabled'
                                : '${_getMuscleName(muscle)} enabled',
                          ),
                          duration: const Duration(seconds: 1),
                        ),
                      );
                    },
                    highlightColor: _highlightColor.withValues(alpha: 0.6),
                    baseColor: _baseColor,
                    disabledColor: _disabledColor,
                    selectedStrokeWidth: _selectedStrokeWidth,
                    unselectedStrokeWidth: _unselectedStrokeWidth,
                    enableSelection: _enableSelection,
                    fit: _boxFit,
                    hitTestPadding: _hitTestPadding,
                    performanceMode: _performanceMode,
                    tooltipBuilder: _showTooltips ? (muscle) => _getMuscleName(muscle) : null,
                    semanticLabelBuilder: (muscle) => '${_getMuscleName(muscle)} muscle',
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
                  ),
                ),
              ),
            ),

            _SelectionInfoBar(
              selectedCount: _selectedMuscles.length,
              disabledCount: _disabledMuscles.length,
              disabledColor: _disabledColor,
              isFront: _controller.isFront,
            ),

            Expanded(
              flex: 2,
              child: _MuscleTabSection(
                selectedMuscles: _selectedMuscles,
                disabledMuscles: _disabledMuscles,
                disabledColor: _disabledColor,
                onDisable: _toggleDisabledMuscle,
                onDeselect: _toggleMuscle,
                getMuscleName: _getMuscleName,
              ),
            ),
          ],
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

  void _selectAll() {
    _controller.removeListener(_onControllerChanged);
    for (var muscle in Muscle.values) {
      if (!_selectedMuscles.contains(muscle) && !_disabledMuscles.contains(muscle)) {
        _controller.selectMuscle(muscle);
      }
    }
    _controller.addListener(_onControllerChanged);
    _onControllerChanged();
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
  final Set<Muscle> selectedMuscles;
  final Set<Muscle> disabledMuscles;
  final Color disabledColor;
  final void Function(Muscle) onDisable;
  final void Function(Muscle) onDeselect;
  final String Function(Muscle) getMuscleName;

  const _MuscleTabSection({
    required this.selectedMuscles,
    required this.disabledMuscles,
    required this.disabledColor,
    required this.onDisable,
    required this.onDeselect,
    required this.getMuscleName,
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
        final muscle = selectedMuscles.elementAt(index);
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
              getMuscleName(muscle),
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
        final muscle = disabledMuscles.elementAt(index);
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
              getMuscleName(muscle),
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
