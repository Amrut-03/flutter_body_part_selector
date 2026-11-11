## 1.3.0

* **FIXED**: `hitTestPadding` had no effect. It is now a real tap tolerance: a tap up to that many SVG units outside a muscle's edge selects it.
* **FIXED**: Selection changes made while the diagram was still processing a previous change were dropped, leaving the highlight out of sync with `selectedMuscles`.
* **FIXED**: After a failed load, the error view stayed on screen even when a later load succeeded.
* **FIXED**: A missing custom `asset` silently showed the built-in diagram instead of the error view.
* **FIXED**: The alpha of `highlightColor` and `disabledColor` was ignored. Colors are now drawn with their alpha, so the default highlight (blue at 60%) is translucent as intended. The `disabledColor` default is now opaque `Colors.grey` so disabled muscles look the same as before.
* **FIXED**: Taps fired on touch-down, so starting a scroll on the diagram selected a muscle and a long press also counted as a tap. Taps now fire on release.
* **FIXED**: `onMuscleTapDisabled` is now called for taps while `enableSelection` is `false`, as documented.
* **FIXED**: A `viewBox` separated by commas or multiple spaces no longer fails to load.
* **NEW**: `onSelectAnimationBuilder` is now implemented. It was accepted but never called.
* **PERFORMANCE**: Each SVG is parsed once into paths and cached. Selecting, deselecting or recoloring muscles now only repaints, instead of re-parsing, rewriting and re-rendering the whole SVG (431 KB for the front view) on every change. Switching back to an already loaded view is instant.
* **IMPROVED**: Hit testing uses the exact path geometry, including curves, arcs, relative commands and `fill-rule="evenodd"`.
* **FIXED**: Setting `BodyMapController.isFront` directly now notifies listeners. It used to change the value silently, so the UI didn't rebuild.
* **CHANGED**: `Muscle.displayName` now capitalizes every word: `"Biceps Left"` instead of `"biceps Left"`. Update any code that compares against the old strings.
* **IMPROVED**: `toggleMuscle` is now the documented tap-to-toggle method, and the README and example pass it to `onMuscleTap`. `selectMuscle` is unchanged and still toggles; its docs now say so.
* **DOCS**: Documented `setInitialSelection`, which replaces the selection without notifying listeners. Corrected the per-view grouping in the `Muscle` enum (triceps are on the back view).
* **EXAMPLE**: Added Android and iOS runners to the example app. The VS Code launch configurations no longer pin Windows/Android devices.
* **DEPRECATED**: `isInitialSelection`. It ignores taps while `true` and is no longer needed to avoid flicker. Pass the starting selection through `selectedMuscles` instead.
* **CHANGED**: Minimum versions lowered to Dart 3.6 / Flutter 3.27 (was Dart 3.10.4). `xml` 7.x is now allowed.
* **CHANGED**: Implementation files moved under `lib/src/`. Import `package:flutter_body_part_selector/flutter_body_part_selector.dart`. Deep imports of internal files (for example `.../feature/.../muscle_mapper.dart`) no longer resolve.
* **REMOVED**: Unused internal duplicates (a second `Muscle` enum, a second SVG ID map, an unused repository layer) and the app-template platform folders that were being published with the package.
* **DOCS**: Merged the useful parts of `FEATURES.md` and `USAGE_GUIDE.md` into the README and removed both. They documented parameters that no longer exist (`baseColor`, `performanceMode`). Corrected the per-view muscle lists.

## 1.2.2

* **FIXED**: Widget tests no longer hang or fail because of `InteractiveBodySvg`:
  * Loading no longer leaves a pending `Timer`, which caused "A Timer is still pending even after the widget tree was disposed" when a test ended right after `pumpWidget`.
  * A load started under the test fake clock no longer poisons the asset bundle cache for later tests in the same file. Loaded SVG text is now cached by the widget only after a successful load.
* **NEW**: `loadingBuilder` parameter on `InteractiveBodySvg` to replace the default loading spinner, for example with a static placeholder so `pumpAndSettle()` can settle in tests.
* **DOCS**: Added a Testing section to the README covering `loadingBuilder` and `tester.runAsync`.
* **DOCS**: Removed unresolved merge-conflict markers and the stale `InteractiveBodyWidget` API reference from the README.
* **DOCS**: Documented the `asset` parameter, which still exists (see the 1.2.0 correction below).
* **DOCS**: Corrected the 1.2.0 entry. It omitted three breaking changes and wrongly said `asset` was removed.

## 1.2.1

* **BREAKING**: Removed `InteractiveBodyWidget` - package now provides only `InteractiveBodySvg` widget without Scaffold/AppBar
* **IMPROVED**: Simplified package API - single widget (`InteractiveBodySvg`) for better flexibility
* **IMPROVED**: Users can now integrate the widget into their own UI without built-in Scaffold/AppBar constraints
* **IMPROVED**: Cleaned up all debug code and unnecessary comments for production-ready codebase
* **IMPROVED**: Updated documentation to reflect single widget architecture

## 1.2.0

* **BREAKING**: Removed `asset` parameter from `InteractiveBodySvg` - widget now always uses package assets based on `isFront` parameter. *Correction (1.2.2): `asset` was not removed. It is still accepted and overrides the built-in SVG path. When omitted, the package asset for `isFront` is used.*
* **BREAKING** *(added in 1.2.2, previously undocumented)*: Removed the `baseColor` parameter from `InteractiveBodySvg`. Unselected muscles are now drawn unfilled with a light outline.
* **BREAKING** *(added in 1.2.2, previously undocumented)*: Removed the `performanceMode` parameter and the `PerformanceMode` enum.
* **CHANGED** *(added in 1.2.2, previously undocumented)*: The default `hitTestPadding` changed from `10.0` to `2.0`, giving smaller tap targets. Pass `hitTestPadding: 10.0` to restore the old behavior.
* **IMPROVED**: Simplified API - no need to specify asset paths, widget automatically uses correct package assets
* **IMPROVED**: Better code organization with clean architecture structure
* **IMPROVED**: Enhanced developer-friendly comments throughout the codebase
* **IMPROVED**: Optimized SVG processing and hit testing performance

## 1.1.5

* **FIXED**: Shortened package description to meet pub.dev requirements (60-180 characters)
* **IMPROVED**: Added missing dartdoc comments for better API documentation
* **NEW**: Added example directory with a complete example app

## 1.1.4

* **NEW**: Added demo video to README for better package showcase

## 1.1.3

* **NEW**: Made `asset` parameter optional in `InteractiveBodySvg` - now you can use `isFront` parameter to automatically use package assets without specifying paths
* **IMPROVED**: Simplified usage - no need to manually specify asset paths when using package assets

## 1.1.2

* **NEW**: Added setter for `selectedMuscles` property - now supports `controller.selectedMuscles = {...}` syntax for convenience
* **FIXED**: Removed trailing garbage text from README.md

## 1.1.1

* Minor version update

## 1.1.0

* **NEW**: Added `toggleMuscle()` method for explicit muscle selection toggling
* **NEW**: Added `deselectMuscle()` method to deselect a specific muscle
* **NEW**: Added `setSelectedMuscles()` method to replace entire selection programmatically
* **NEW**: Added `selectMultiple()` method to add multiple muscles without clearing existing selection
* **NEW**: Added constructor to `BodyMapController` for initial state (selected muscles, disabled muscles, initial view)
* **IMPROVED**: Enhanced documentation with clear read-only vs writable property markers
* **IMPROVED**: Added comprehensive "Common Pitfalls" section to README
* **IMPROVED**: Added extensive examples for programmatic selection management
* **IMPROVED**: Better documentation for all controller methods with usage examples

## 1.0.0

* Initial release
* Interactive body selector with SVG support
* Tap to select muscles functionality
* Visual highlighting of selected muscles
* Front and back body views
* Programmatic muscle selection via controller
* Customizable highlight and base colors
* Support for 30+ muscles across front and back views
