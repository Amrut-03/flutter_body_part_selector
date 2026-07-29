# Issues Check Report - flutter_body_part_selector v1.1.1

> **Demo app version**: 2.0.0 — See `CHANGELOG.md`

## Package Version
- **Current Version**: 1.1.1
- **Demo App Updated**: 2026-07-30 (v2.0.0)
- **Testing Method**: Fresh implementation from scratch

## Issues Test Results

### 1. ❌ **selectedMuscles Setter** - NOT AVAILABLE
**Test**: `_controller.selectedMuscles = updated;`
**Result**: No setter exists
**Workaround**: Computed getters from controller

### 2. ❌ **toggleMuscle() Method** - NOT AVAILABLE
**Test**: `_controller.toggleMuscle(muscle);`
**Result**: Method does not exist
**Workaround**: Clear-and-reselect pattern

### 3. ❌ **deselectMuscle() Method** - NOT AVAILABLE
**Test**: `_controller.deselectMuscle(muscle);`
**Result**: Method does not exist
**Workaround**: Clear-and-reselect pattern

### 4. ❌ **Initialization Constructor** - NOT AVAILABLE
**Test**: `BodyMapController(initialSelectedMuscles: {Muscle.bicepsLeft});`
**Result**: Constructor parameter not available
**Workaround**: Create empty, select programmatically

## Current Implementation (v2.0.0)

The `main.dart` now implements:

1. ✅ Computed getters for `_selectedMuscles` / `_disabledMuscles` (no local mirroring)
2. ✅ `_toggleMuscle` with disabled-muscle guard
3. ✅ `_toggleDisabledMuscle` properly deselects when disabling (previously bugged)
4. ✅ `_selectAll` with listener suppression for batch performance
5. ✅ Extracted widgets for SRP compliance (`_ViewToggleBar`, `_SelectionInfoBar`, `_MuscleTabSection`)
6. ✅ `Theme.of(context)` cached in extracted widgets
7. ✅ `_getMuscleName` is now `static`

## Next Steps

When upgrading `flutter_body_part_selector`:

1. Re-test that `selectMuscle()` doesn't auto-toggle
2. Verify clear-and-reselect workaround still needed
3. Check if any new API methods eliminate the workarounds
4. Update `AGENTS.md` and issue reports accordingly
