import 'package:flutter/material.dart';
import '../../domain/entities/muscle.dart';

class BodyMapController extends ChangeNotifier {
  final Set<Muscle> _selectedMuscles = {};
  final Set<Muscle> _disabledMuscles = {};
  bool isFront = true;

  BodyMapController({
    Set<Muscle>? initialSelectedMuscles,
    Set<Muscle>? initialDisabledMuscles,
    bool initialIsFront = true,
  }) {
    if (initialSelectedMuscles != null) {
      _selectedMuscles.addAll(initialSelectedMuscles
          .where((m) => initialDisabledMuscles == null || !initialDisabledMuscles.contains(m)));
    }
    if (initialDisabledMuscles != null) {
      _disabledMuscles.addAll(initialDisabledMuscles);
    }
    isFront = initialIsFront;
  }

  Set<Muscle> get selectedMuscles => Set.unmodifiable(_selectedMuscles);
  set selectedMuscles(Set<Muscle> muscles) {
    setSelectedMuscles(muscles);
  }

  bool isSelected(Muscle muscle) => _selectedMuscles.contains(muscle);
  bool isDisabled(Muscle muscle) => _disabledMuscles.contains(muscle);
  Set<Muscle> get disabledMuscles => Set.unmodifiable(_disabledMuscles);

  void selectMuscle(Muscle muscle) {
    if (_disabledMuscles.contains(muscle)) {
      return;
    }

    if (_selectedMuscles.contains(muscle)) {
      _selectedMuscles.remove(muscle);
    } else {
      _selectedMuscles.add(muscle);
    }
    notifyListeners();
  }

  void toggleMuscle(Muscle muscle) {
    selectMuscle(muscle); 
  }

  void deselectMuscle(Muscle muscle) {
    if (_selectedMuscles.remove(muscle)) {
      notifyListeners();
    }
  }

  void setSelectedMuscles(Set<Muscle> muscles) {
    _selectedMuscles.clear();
    _selectedMuscles.addAll(muscles.where((m) => !_disabledMuscles.contains(m)));
    notifyListeners();
  }

  void selectMultiple(Set<Muscle> muscles) {
    final added = muscles.where(
        (m) => !_disabledMuscles.contains(m) && !_selectedMuscles.contains(m));
    if (added.isNotEmpty) {
      _selectedMuscles.addAll(added);
      notifyListeners();
    }
  }

  void clearSelection() {
    if (_selectedMuscles.isNotEmpty) {
      _selectedMuscles.clear();
      notifyListeners();
    }
  }

  void setInitialSelection(Set<Muscle> muscles) {
    _selectedMuscles.clear();
    _selectedMuscles.addAll(muscles.where((m) => !_disabledMuscles.contains(m)));
  }

  void enableMuscle(Muscle muscle) {
    if (_disabledMuscles.remove(muscle)) {
      notifyListeners();
    }
  }

  void disableMuscle(Muscle muscle) {
    _disabledMuscles.add(muscle);
    _selectedMuscles.remove(muscle);
    notifyListeners();
  }

  void setDisabledMuscles(Set<Muscle> muscles) {
    _disabledMuscles.clear();
    _disabledMuscles.addAll(muscles);
    _selectedMuscles.removeWhere((m) => _disabledMuscles.contains(m));
    notifyListeners();
  }

  void toggleView() {
    isFront = !isFront;
    notifyListeners();
  }

  void setFrontView() {
    if (!isFront) {
      isFront = true;
      notifyListeners();
    }
  }

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
