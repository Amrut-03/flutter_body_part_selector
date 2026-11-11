import 'package:flutter/material.dart';
import '../domain/muscle.dart';

/// Controller for managing the state of the interactive body selector.
///
/// This controller manages muscle selection, disabled muscles, and view state
/// (front/back) for the body diagram. It extends [ChangeNotifier] to notify
/// listeners when the state changes.
///
/// Example:
/// ```dart
/// final controller = BodyMapController(
///   initialSelectedMuscles: {Muscle.bicepsLeft, Muscle.tricepsRight},
///   initialIsFront: true,
/// );
///
/// // Listen to changes
/// controller.addListener(() {
///   print('Selected: ${controller.selectedMuscles.length} muscles');
/// });
///
/// // Don't forget to dispose
/// controller.dispose();
/// ```
class BodyMapController extends ChangeNotifier {
  final Set<Muscle> _selectedMuscles = {};
  final Set<Muscle> _disabledMuscles = {};

  /// Whether the body diagram is showing the front view.
  ///
  /// Set to `true` for front view, `false` for back view. This property can
  /// be modified directly or through the view methods like [toggleView],
  /// [setFrontView], or [setBackView]. Setting it to a new value notifies
  /// listeners.
  ///
  /// Example:
  /// ```dart
  /// controller.isFront = false; // Switch to back view
  /// ```
  bool get isFront => _isFront;
  set isFront(bool value) {
    if (_isFront == value) return;
    _isFront = value;
    notifyListeners();
  }

  bool _isFront = true;

  /// Creates a new [BodyMapController] with optional initial state.
  ///
  /// [initialSelectedMuscles] - Muscles to be selected initially. Disabled
  /// muscles will be automatically excluded from the initial selection.
  ///
  /// [initialDisabledMuscles] - Muscles to be disabled initially. Disabled
  /// muscles cannot be selected until they are enabled.
  ///
  /// [initialIsFront] - Whether to show the front view initially (default: true).
  ///
  /// Example:
  /// ```dart
  /// final controller = BodyMapController(
  ///   initialSelectedMuscles: {Muscle.bicepsLeft, Muscle.tricepsRight},
  ///   initialDisabledMuscles: {Muscle.chestLeft},
  ///   initialIsFront: false,
  /// );
  /// ```
  BodyMapController({
    Set<Muscle>? initialSelectedMuscles,
    Set<Muscle>? initialDisabledMuscles,
    bool initialIsFront = true,
  }) {
    if (initialSelectedMuscles != null) {
      _selectedMuscles.addAll(initialSelectedMuscles.where((m) =>
          initialDisabledMuscles == null ||
          !initialDisabledMuscles.contains(m)));
    }
    if (initialDisabledMuscles != null) {
      _disabledMuscles.addAll(initialDisabledMuscles);
    }
    _isFront = initialIsFront;
  }

  /// Currently selected muscles (read-only).
  ///
  /// Returns an unmodifiable set of selected muscles. To modify the selection,
  /// use the selection methods like [selectMuscle], [setSelectedMuscles], etc.
  ///
  /// Example:
  /// ```dart
  /// final selected = controller.selectedMuscles;
  /// print('Selected ${selected.length} muscles');
  /// ```
  Set<Muscle> get selectedMuscles => Set.unmodifiable(_selectedMuscles);

  /// Sets the entire selection, replacing any existing selection.
  ///
  /// This is a convenience setter that calls [setSelectedMuscles].
  ///
  /// Example:
  /// ```dart
  /// controller.selectedMuscles = {Muscle.bicepsLeft, Muscle.tricepsRight};
  /// ```
  set selectedMuscles(Set<Muscle> muscles) {
    setSelectedMuscles(muscles);
  }

  /// Checks if a muscle is currently selected.
  ///
  /// Returns `true` if the muscle is selected, `false` otherwise.
  ///
  /// Example:
  /// ```dart
  /// if (controller.isSelected(Muscle.bicepsLeft)) {
  ///   print('Biceps left is selected');
  /// }
  /// ```
  bool isSelected(Muscle muscle) => _selectedMuscles.contains(muscle);

  /// Checks if a muscle is currently disabled.
  ///
  /// Returns `true` if the muscle is disabled, `false` otherwise.
  /// Disabled muscles cannot be selected until they are enabled.
  ///
  /// Example:
  /// ```dart
  /// if (controller.isDisabled(Muscle.chestLeft)) {
  ///   print('Chest left is disabled');
  /// }
  /// ```
  bool isDisabled(Muscle muscle) => _disabledMuscles.contains(muscle);

  /// Currently disabled muscles (read-only).
  ///
  /// Returns an unmodifiable set of disabled muscles. To modify disabled muscles,
  /// use [disableMuscle], [enableMuscle], or [setDisabledMuscles].
  ///
  /// Example:
  /// ```dart
  /// final disabled = controller.disabledMuscles;
  /// print('${disabled.length} muscles are disabled');
  /// ```
  Set<Muscle> get disabledMuscles => Set.unmodifiable(_disabledMuscles);

  /// Toggles a muscle's selection: selects it if it isn't selected,
  /// deselects it if it is. Disabled muscles are ignored.
  ///
  /// This is the method to pass as `InteractiveBodySvg.onMuscleTap` for
  /// tap-to-toggle selection.
  ///
  /// [muscle] - The muscle to toggle.
  ///
  /// Example:
  /// ```dart
  /// InteractiveBodySvg(
  ///   selectedMuscles: controller.selectedMuscles,
  ///   onMuscleTap: controller.toggleMuscle,
  /// )
  /// ```
  void toggleMuscle(Muscle muscle) {
    if (_disabledMuscles.contains(muscle)) {
      return;
    }

    if (!_selectedMuscles.remove(muscle)) {
      _selectedMuscles.add(muscle);
    }
    notifyListeners();
  }

  /// Same as [toggleMuscle]: selects the muscle if it isn't selected and
  /// **deselects it if it is**.
  ///
  /// Kept under this name for compatibility with earlier versions. Prefer
  /// [toggleMuscle], whose name says what it does; to only ever add muscles,
  /// use [selectMultiple].
  ///
  /// [muscle] - The muscle to toggle.
  void selectMuscle(Muscle muscle) => toggleMuscle(muscle);

  /// Deselects a specific muscle.
  ///
  /// If the muscle is selected, it will be deselected. If it's not selected,
  /// this method does nothing.
  ///
  /// [muscle] - The muscle to deselect.
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

  /// Sets the entire selection, replacing any existing selection.
  ///
  /// This method clears the current selection and sets it to the provided
  /// muscles. Disabled muscles will be automatically excluded.
  ///
  /// [muscles] - The set of muscles to select.
  ///
  /// Example:
  /// ```dart
  /// controller.setSelectedMuscles({
  ///   Muscle.bicepsLeft,
  ///   Muscle.tricepsRight,
  ///   Muscle.chestLeft,
  /// });
  /// ```
  void setSelectedMuscles(Set<Muscle> muscles) {
    _selectedMuscles.clear();
    _selectedMuscles
        .addAll(muscles.where((m) => !_disabledMuscles.contains(m)));
    notifyListeners();
  }

  /// Adds multiple muscles to the current selection without clearing existing selection.
  ///
  /// This method adds the provided muscles to the current selection. Muscles
  /// that are already selected or disabled will be skipped.
  ///
  /// [muscles] - The set of muscles to add to the selection.
  ///
  /// Example:
  /// ```dart
  /// // Current selection: {Muscle.bicepsLeft}
  /// controller.selectMultiple({Muscle.tricepsRight, Muscle.chestLeft});
  /// // New selection: {Muscle.bicepsLeft, Muscle.tricepsRight, Muscle.chestLeft}
  /// ```
  void selectMultiple(Set<Muscle> muscles) {
    final added = muscles.where(
        (m) => !_disabledMuscles.contains(m) && !_selectedMuscles.contains(m));
    if (added.isNotEmpty) {
      _selectedMuscles.addAll(added);
      notifyListeners();
    }
  }

  /// Clears all selected muscles.
  ///
  /// This method removes all muscles from the selection. If no muscles are
  /// selected, this method does nothing.
  ///
  /// Example:
  /// ```dart
  /// controller.clearSelection();
  /// // All muscles are now deselected
  /// ```
  void clearSelection() {
    if (_selectedMuscles.isNotEmpty) {
      _selectedMuscles.clear();
      notifyListeners();
    }
  }

  /// Replaces the selection **without** notifying listeners.
  ///
  /// Meant for seeding state before the first build, for example in
  /// `initState`, where a notification would be redundant. Disabled muscles
  /// are excluded. After the UI is built, use [setSelectedMuscles] so
  /// listeners rebuild. To seed state at construction time, prefer
  /// `BodyMapController(initialSelectedMuscles: ...)`.
  ///
  /// [muscles] - The muscles to select.
  void setInitialSelection(Set<Muscle> muscles) {
    _selectedMuscles.clear();
    _selectedMuscles
        .addAll(muscles.where((m) => !_disabledMuscles.contains(m)));
  }

  /// Enables a previously disabled muscle.
  ///
  /// If the muscle is disabled, it will be enabled. If it's not disabled,
  /// this method does nothing.
  ///
  /// [muscle] - The muscle to enable.
  ///
  /// Example:
  /// ```dart
  /// controller.enableMuscle(Muscle.chestLeft);
  /// ```
  void enableMuscle(Muscle muscle) {
    if (_disabledMuscles.remove(muscle)) {
      notifyListeners();
    }
  }

  /// Disables a muscle, preventing it from being selected.
  ///
  /// Disabled muscles are automatically removed from the selection if they
  /// were previously selected.
  ///
  /// [muscle] - The muscle to disable.
  ///
  /// Example:
  /// ```dart
  /// controller.disableMuscle(Muscle.chestLeft);
  /// // chestLeft is now disabled and cannot be selected
  /// ```
  void disableMuscle(Muscle muscle) {
    _disabledMuscles.add(muscle);
    _selectedMuscles.remove(muscle);
    notifyListeners();
  }

  /// Sets the disabled muscles, replacing any existing disabled muscles.
  ///
  /// This method clears the current disabled muscles and sets them to the
  /// provided set. Any previously selected muscles that are now disabled
  /// will be automatically removed from the selection.
  ///
  /// [muscles] - The set of muscles to disable.
  ///
  /// Example:
  /// ```dart
  /// controller.setDisabledMuscles({
  ///   Muscle.chestLeft,
  ///   Muscle.chestRight,
  /// });
  /// ```
  void setDisabledMuscles(Set<Muscle> muscles) {
    _disabledMuscles.clear();
    _disabledMuscles.addAll(muscles);
    _selectedMuscles.removeWhere((m) => _disabledMuscles.contains(m));
    notifyListeners();
  }

  /// Toggles between front and back view.
  ///
  /// If currently showing the front view, switches to back view, and vice versa.
  ///
  /// Example:
  /// ```dart
  /// controller.toggleView();
  /// // If was showing front, now shows back
  /// ```
  void toggleView() {
    isFront = !isFront;
  }

  /// Sets the view to show the front of the body.
  ///
  /// If already showing the front view, this method does nothing.
  ///
  /// Example:
  /// ```dart
  /// controller.setFrontView();
  /// ```
  void setFrontView() {
    isFront = true;
  }

  /// Sets the view to show the back of the body.
  ///
  /// If already showing the back view, this method does nothing.
  ///
  /// Example:
  /// ```dart
  /// controller.setBackView();
  /// ```
  void setBackView() {
    isFront = false;
  }

  @override
  void dispose() {
    _selectedMuscles.clear();
    _disabledMuscles.clear();
    super.dispose();
  }
}
