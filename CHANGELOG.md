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
