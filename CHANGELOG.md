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
