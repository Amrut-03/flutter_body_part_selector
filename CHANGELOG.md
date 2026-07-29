# Changelog

## [2.0.0] - 2026-07-30

### Added
- Extracted `_ViewToggleBar`, `_SelectionInfoBar`, and `_MuscleTabSection` widgets for SRP compliance
- Long-press guard: disabled muscles cannot be tapped to select

### Fixed
- `_toggleDisabledMuscle`: disabling a selected muscle now properly deselects it (was calling `selectMuscle` instead)
- `_selectAll`: batched listener notifications to avoid N rebuilds on select-all

### Changed
- `_selectedMuscles` and `_disabledMuscles` converted from local fields to computed getters reading from controller
- `_getMuscleName` changed from instance method to static method
- `_highlightColor` changed from `var` to `final` (never mutated)
- Cached `Theme.of(context)` calls in extracted widgets for performance
- `_onControllerChanged` simplified — no longer manually syncs redundant state

### Removed
- `_updateSelectedMuscles()` and `_updateDisabledMuscles()` — no longer needed after getter conversion
- Unnecessary `initState` calls to update empty sets

## [1.0.0] - Initial release
