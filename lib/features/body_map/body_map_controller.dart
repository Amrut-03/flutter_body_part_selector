import 'package:flutter/material.dart';
import '../../core/models/muscle.dart';

/// Controller for managing the interactive body map state
/// Supports multi-muscle selection only
class BodyMapController extends ChangeNotifier {
  /// The currently selected muscles (multi-select only)
  final Set<Muscle> _selectedMuscles = {};

  /// Disabled muscles (locked/injured/unavailable)
  final Set<Muscle> _disabledMuscles = {};

  /// Whether to show the front view (true) or back view (false) (writable)
  /// 
  /// You can modify this directly or use [toggleView], [setFrontView], or [setBackView].
  bool isFront = true;

  /// Constructor with optional initial selected muscles
  /// 
  /// Example:
  /// ```dart
  /// final controller = BodyMapController(
  ///   initialSelectedMuscles: {Muscle.bicepsLeft, Muscle.tricepsRight},
  /// );
  /// ```
  BodyMapController({Set<Muscle>? initialSelectedMuscles, Set<Muscle>? initialDisabledMuscles, bool initialIsFront = true}) {
    if (initialSelectedMuscles != null) {
      _selectedMuscles.addAll(initialSelectedMuscles.where((m) => initialDisabledMuscles == null || !initialDisabledMuscles.contains(m)));
    }
    if (initialDisabledMuscles != null) {
      _disabledMuscles.addAll(initialDisabledMuscles);
    }
    isFront = initialIsFront;
  }

  /// Get selected muscles (read-only)
  /// 
  /// To modify selection, use methods like [selectMuscle], [deselectMuscle],
  /// [toggleMuscle], [setSelectedMuscles], or [selectMultiple].
  Set<Muscle> get selectedMuscles => Set.unmodifiable(_selectedMuscles);

  /// Check if a muscle is selected (read-only)
  bool isSelected(Muscle muscle) => _selectedMuscles.contains(muscle);

  /// Check if a muscle is disabled (read-only)
  bool isDisabled(Muscle muscle) => _disabledMuscles.contains(muscle);

  /// Get disabled muscles (read-only)
  /// 
  /// To modify disabled muscles, use [enableMuscle], [disableMuscle], or [setDisabledMuscles].
  Set<Muscle> get disabledMuscles => Set.unmodifiable(_disabledMuscles);

  /// Select or toggle a muscle (multi-select mode)
  /// If muscle is already selected, it will be deselected (toggle behavior)
  /// 
  /// This is equivalent to [toggleMuscle]. Use [selectMuscle] for consistency
  /// with tap interactions, or [toggleMuscle] for explicit toggle semantics.
  void selectMuscle(Muscle muscle) {
    if (_disabledMuscles.contains(muscle)) {
      return; // Don't select disabled muscles
    }

    if (_selectedMuscles.contains(muscle)) {
      // Toggle off - deselect the muscle
      _selectedMuscles.remove(muscle);
    } else {
      // Toggle on - select the muscle
      _selectedMuscles.add(muscle);
    }
    notifyListeners();
  }

  /// Toggle a muscle's selection state
  /// 
  /// If the muscle is selected, it will be deselected. If not selected, it will be selected.
  /// Disabled muscles cannot be toggled.
  /// 
  /// Example:
  /// ```dart
  /// controller.toggleMuscle(Muscle.bicepsLeft);
  /// ```
  void toggleMuscle(Muscle muscle) {
    selectMuscle(muscle); // Same behavior as selectMuscle
  }

  /// Deselect a specific muscle
  /// 
  /// Example:
  /// ```dart
  /// controller.deselectMuscle(Muscle.bicepsLeft);
  /// ```
  void deselectMuscle(Muscle muscle) {
    if (_selectedMuscles.remove(muscle)) {
      notifyListeners();
    }
  }

  /// Set the entire selection to a specific set of muscles
  /// 
  /// This replaces the current selection with the provided set.
  /// Disabled muscles will be automatically excluded.
  /// 
  /// Example:
  /// ```dart
  /// controller.setSelectedMuscles({Muscle.bicepsLeft, Muscle.tricepsRight});
  /// ```
  void setSelectedMuscles(Set<Muscle> muscles) {
    _selectedMuscles.clear();
    _selectedMuscles.addAll(muscles.where((m) => !_disabledMuscles.contains(m)));
    notifyListeners();
  }

  /// Select multiple muscles at once
  /// 
  /// Adds the provided muscles to the current selection without clearing
  /// existing selections. Disabled muscles will be automatically excluded.
  /// 
  /// Example:
  /// ```dart
  /// controller.selectMultiple({Muscle.bicepsLeft, Muscle.tricepsRight});
  /// ```
  void selectMultiple(Set<Muscle> muscles) {
    final added = muscles.where((m) => !_disabledMuscles.contains(m) && !_selectedMuscles.contains(m));
    if (added.isNotEmpty) {
      _selectedMuscles.addAll(added);
      notifyListeners();
    }
  }

  /// Clear all selections
  void clearSelection() {
    if (_selectedMuscles.isNotEmpty) {
      _selectedMuscles.clear();
      notifyListeners();
    }
  }

  /// Set initial selection (without triggering listeners)
  void setInitialSelection(Set<Muscle> muscles) {
    _selectedMuscles.clear();
    _selectedMuscles.addAll(muscles.where((m) => !_disabledMuscles.contains(m)));
    // Don't notify listeners for initial selection
  }

  /// Enable a muscle (remove from disabled set)
  void enableMuscle(Muscle muscle) {
    if (_disabledMuscles.remove(muscle)) {
      notifyListeners();
    }
  }

  /// Disable a muscle (add to disabled set and remove from selection)
  void disableMuscle(Muscle muscle) {
    _disabledMuscles.add(muscle);
    _selectedMuscles.remove(muscle);
    notifyListeners();
  }

  /// Set disabled muscles
  void setDisabledMuscles(Set<Muscle> muscles) {
    _disabledMuscles.clear();
    _disabledMuscles.addAll(muscles);
    // Remove disabled muscles from selection
    _selectedMuscles.removeWhere((m) => _disabledMuscles.contains(m));
    notifyListeners();
  }

  /// Toggle between front and back view
  void toggleView() {
    isFront = !isFront;
    notifyListeners();
  }

  /// Set the view to front
  void setFrontView() {
    if (!isFront) {
      isFront = true;
      notifyListeners();
    }
  }

  /// Set the view to back
  void setBackView() {
    if (isFront) {
      isFront = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _selectedMuscles.clear();
    _disabledMuscles.clear();
    super.dispose();
  }
}
