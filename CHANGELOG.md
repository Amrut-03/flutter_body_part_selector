# Changelog

## [Unreleased]

### Fixed
- `_toggleMuscle` now calls `BodyMapController.toggleMuscle()` instead of clearing and re-selecting every other muscle, which fired N+1 notifications per deselect.
- `_toggleDisabledMuscle` relies on `disableMuscle()`, which already removes the muscle from the selection. The clear-and-reselect block added in 2.0.0 never ran and has been removed.
- `_selectAll` now uses `selectMultiple()`: one notification, disabled muscles skipped, no listener juggling.
- The list's "Deselect" button now calls `deselectMuscle()` instead of a toggle.

### Changed
- Upgraded `flutter_body_part_selector` from 1.1.3 to **1.2.1** (constraint `^1.2.1`).
- Removed the `baseColor` and `performanceMode` arguments, which `InteractiveBodySvg` no longer accepts as of 1.2.x. In 1.2.x, unselected muscles are drawn unfilled with a light outline instead of a white fill.
- Customization fields in the screen state are now `final`, so `flutter analyze` reports no issues.
- Muscle labels use `Muscle.displayName` with the first letter capitalized ("Biceps Left" instead of "biceps Left"), via a shared `_muscleLabel` helper that replaces `_getMuscleName`.
- The screen now rebuilds through a `ListenableBuilder` scoped to the body, replacing the manual `addListener`/`setState` wiring. The app bar and FAB no longer rebuild on selection changes.
- Selected and disabled sets are read once per build, and the lists receive `List`s instead of calling `Set.elementAt` per item (which was O(n²)).
- Removed the redundant disabled-muscle guard and the one-line wrapper methods (`_toggleMuscle`, `_clearAll`, view setters); controller methods are passed directly.

### Added
- `test/body_map_controller_test.dart`: 13 unit tests pinning the controller behaviour the app relies on (toggle, deselect, disable/enable, select-all with disabled muscles, clear, view).
- `test/widget_test.dart`: widget tests for Select All, Clear All, Deselect, Disable/Enable via the Disabled tab, and the view buttons.

### Build
- Android: fixed `Gradle build failed due to Java/Gradle incompatibility`. Android Studio's bundled JDK is now Java 25, which Gradle 8.14 can't run on. Upgraded to the versions Flutter 3.47.7's own template uses: Gradle **9.3.1**, Android Gradle Plugin **9.1.0**, Kotlin **2.4.0**. In `android/app/build.gradle.kts`, the `kotlin-android` plugin line and the `kotlinOptions` block are replaced by `kotlin { compilerOptions { jvmTarget = JVM_17 } }`.

### Removed
- Unused `cupertino_icons` dependency.
- `FINAL_ISSUES_REPORT_V1.1.1.md` and `ISSUES_CHECK_V1.1.1.md`. They said `toggleMuscle`, `deselectMuscle`, the `selectedMuscles` setter and the initial-state constructor were missing, but all of them exist in the package (1.1.3+).

### Docs
- README: replaced "Known Package Limitations" (incorrect) with the controller API the app uses, and removed the reference to the untracked `AGENTS.md`.
- 2.0.0 entries below are annotated where they were inaccurate.
- README: added a "Versioning" section explaining that the app (2.0.0) and the package (1.2.1) are versioned independently.

## [2.0.0] - 2026-07-30

### Added
- Extracted `_ViewToggleBar`, `_SelectionInfoBar`, and `_MuscleTabSection` widgets for SRP compliance
- Long-press guard: disabled muscles cannot be tapped to select

### Fixed
- `_toggleDisabledMuscle`: disabling a selected muscle now properly deselects it (was calling `selectMuscle` instead). *Correction: `disableMuscle()` already deselects, so the added code never ran. Removed in Unreleased.*
- `_selectAll`: batched listener notifications to avoid N rebuilds on select-all. *Correction: the controller still notified N times, and the state was only detached from them. Replaced with `selectMultiple()` in Unreleased.*

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
