import 'package:flutter/material.dart';
import '../../core/models/muscle.dart';

/// Controller for managing the interactive body map state
/// Supports multi-muscle selection only
class BodyMapController extends ChangeNotifier {
  /// The currently selected muscles (multi-select only)
  final Set<Muscle> _selectedMuscles = {};

  /// Disabled muscles (locked/injured/unavailable)
  final Set<Muscle> _disabledMuscles = {};

  /// Whether to show the front view (true) or back view (false)
  bool isFront = true;

  /// Get selected muscles
  Set<Muscle> get selectedMuscles => Set.unmodifiable(_selectedMuscles);

  /// Check if a muscle is selected
  bool isSelected(Muscle muscle) => _selectedMuscles.contains(muscle);

  /// Check if a muscle is disabled
  bool isDisabled(Muscle muscle) => _disabledMuscles.contains(muscle);

  /// Get disabled muscles
  Set<Muscle> get disabledMuscles => Set.unmodifiable(_disabledMuscles);

  /// Select or toggle a muscle (multi-select mode)
  /// If muscle is already selected, it will be deselected (toggle behavior)
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

  /// Deselect a specific muscle
  void deselectMuscle(Muscle muscle) {
    if (_selectedMuscles.remove(muscle)) {
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
