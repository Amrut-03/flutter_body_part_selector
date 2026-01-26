## 1.2.1

* **BREAKING**: Removed `InteractiveBodyWidget` - package now provides only `InteractiveBodySvg` widget without Scaffold/AppBar
* **IMPROVED**: Simplified package API - single widget (`InteractiveBodySvg`) for better flexibility
* **IMPROVED**: Users can now integrate the widget into their own UI without built-in Scaffold/AppBar constraints
* **IMPROVED**: Cleaned up all debug code and unnecessary comments for production-ready codebase
* **IMPROVED**: Updated documentation to reflect single widget architecture

## 1.2.0

* **BREAKING**: Removed `asset` parameter from `InteractiveBodySvg` - widget now always uses package assets based on `isFront` parameter
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
