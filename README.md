# Flutter Body Part Selector

An interactive body selector package for Flutter that allows users to select muscles on a body diagram. Users can tap on muscles in the SVG body diagram or select them programmatically, with visual highlighting of selected muscles. 

**⚠️ IMPORTANT: This package includes mandatory SVG assets that must be used. Custom SVG files are not supported.**

https://github.com/user-attachments/assets/8ba0b47b-fa72-4055-bee8-26f50427437c

## Features

- 🎯 **Interactive Muscle Selection**: Tap on any muscle in the body diagram to select it
- 🎨 **Visual Highlighting**: Selected muscles are automatically highlighted with customizable colors
- 🔄 **Front/Back Views**: Toggle between front and back body views
- 📱 **Programmatic Control**: Select muscles programmatically using the controller
- 🎛️ **Customizable**: Customize highlight colors and disabled muscle colors
- 📦 **Easy to Use**: Simple API with minimal setup required - includes all required assets
- 🎨 **Built-in Assets**: Package includes mandatory SVG body diagrams (front and back views)

## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  flutter_body_part_selector: ^1.2.1
```

Then run:

```bash
flutter pub get
```

## Usage

### Quick Start

Use `InteractiveBodySvg` with `BodyMapController`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_body_part_selector/flutter_body_part_selector.dart';

class BodySelectorExample extends StatefulWidget {
  @override
  State<BodySelectorExample> createState() => _BodySelectorExampleState();
}

class _BodySelectorExampleState extends State<BodySelectorExample> {
  final controller = BodyMapController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Interactive Body Selector'),
        actions: [
          IconButton(
            icon: const Icon(Icons.flip),
            onPressed: controller.toggleView,
            tooltip: 'Flip view',
          ),
        ],
      ),
      body: AnimatedBuilder(
        animation: controller,
        builder: (context, _) {
          return Column(
            children: [
              if (controller.selectedMuscles.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(16),
                  color: Colors.blue.shade900,
                  width: double.infinity,
                  child: Text(
                    'Selected: ${controller.selectedMuscles.length} muscles',
                    style: const TextStyle(color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                ),
              Expanded(
                child: InteractiveBodySvg(
                  isFront: controller.isFront,
                  selectedMuscles: controller.selectedMuscles,
                  onMuscleTap: controller.selectMuscle,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
```

### Using the Controller

The `BodyMapController` manages the state of the body selector:

#### Basic Usage

```dart
final controller = BodyMapController();

// Select a muscle programmatically (toggles if already selected)
controller.selectMuscle(Muscle.bicepsLeft);

// Clear all selections
controller.clearSelection();

// Toggle between front and back view
controller.toggleView();

// Set specific view
controller.setFrontView();
controller.setBackView();

// Access current state
final selected = controller.selectedMuscles; // Returns Set<Muscle> (read-only getter)
final isFront = controller.isFront; // Writable: can be set directly

// Set entire selection using setter (convenience)
controller.selectedMuscles = {Muscle.bicepsLeft, Muscle.tricepsRight};
```

#### Initialization with Pre-selected Muscles

```dart
// Create controller with initial selection
final controller = BodyMapController(
  initialSelectedMuscles: {Muscle.bicepsLeft, Muscle.tricepsRight},
  initialDisabledMuscles: {Muscle.chestLeft}, // Optional: pre-disable muscles
  initialIsFront: true, // Optional: start with back view
);
```

#### Programmatic Selection Management

```dart
final controller = BodyMapController();

// Toggle a muscle's selection state
controller.toggleMuscle(Muscle.bicepsLeft);

// Deselect a specific muscle
controller.deselectMuscle(Muscle.bicepsLeft);

// Set entire selection (replaces current selection)
controller.setSelectedMuscles({
  Muscle.bicepsLeft,
  Muscle.tricepsRight,
  Muscle.chestLeft,
});

// Add multiple muscles to current selection (without clearing)
controller.selectMultiple({
  Muscle.bicepsLeft,
  Muscle.tricepsRight,
});

// Check if a muscle is selected
if (controller.isSelected(Muscle.bicepsLeft)) {
  print('Biceps left is selected');
}

// Get all selected muscles (read-only Set)
final selected = controller.selectedMuscles;
print('Selected ${selected.length} muscles');
```

#### Managing Disabled Muscles

```dart
final controller = BodyMapController();

// Disable a muscle (locks it, removes from selection)
controller.disableMuscle(Muscle.chestLeft);

// Enable a muscle (unlocks it)
controller.enableMuscle(Muscle.chestLeft);

// Set multiple disabled muscles at once
controller.setDisabledMuscles({
  Muscle.chestLeft,
  Muscle.chestRight,
});

// Check if a muscle is disabled
if (controller.isDisabled(Muscle.chestLeft)) {
  print('Chest left is disabled');
}
```

#### Complete Example: Programmatic Selection Management

```dart
import 'package:flutter/material.dart';
import 'package:flutter_body_part_selector/flutter_body_part_selector.dart';

class BodySelectorPage extends StatefulWidget {
  @override
  State<BodySelectorPage> createState() => _BodySelectorPageState();
}

class _BodySelectorPageState extends State<BodySelectorPage> {
  late BodyMapController controller;

  @override
  void initState() {
    super.initState();
    // Initialize with some pre-selected muscles
    controller = BodyMapController(
      initialSelectedMuscles: {Muscle.bicepsLeft, Muscle.tricepsRight},
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Body Selector')),
      body: Column(
        children: [
          // Control buttons
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Wrap(
              spacing: 8.0,
              children: [
                ElevatedButton(
                  onPressed: () {
                    // Select multiple muscles programmatically
                    controller.selectMultiple({
                      Muscle.bicepsLeft,
                      Muscle.bicepsRight,
                    });
                  },
                  child: const Text('Select Both Biceps'),
                ),
                ElevatedButton(
                  onPressed: () {
                    // Set entire selection
                    controller.setSelectedMuscles({
                      Muscle.chestLeft,
                      Muscle.chestRight,
                    });
                  },
                  child: const Text('Select Chest Only'),
                ),
                ElevatedButton(
                  onPressed: () {
                    // Clear all selections
                    controller.clearSelection();
                  },
                  child: const Text('Clear All'),
                ),
              ],
            ),
          ),
          // Display selected muscles
          AnimatedBuilder(
            animation: controller,
            builder: (context, _) {
              return Container(
                padding: const EdgeInsets.all(16),
                color: Colors.blue.shade900,
                width: double.infinity,
                child: Text(
                  'Selected: ${controller.selectedMuscles.length} muscles',
                  style: const TextStyle(color: Colors.white),
                  textAlign: TextAlign.center,
                ),
              );
            },
          ),
          // Body diagram
          Expanded(
            child: AnimatedBuilder(
              animation: controller,
              builder: (context, _) {
                return InteractiveBodySvg(
                  isFront: controller.isFront,
                  selectedMuscles: controller.selectedMuscles,
                  onMuscleTap: controller.selectMuscle,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
```

### Customization Options

#### Colors and Styling

```dart
InteractiveBodySvg(
  isFront: true, // Automatically uses package's front body asset
  selectedMuscles: controller.selectedMuscles,
  onMuscleTap: controller.selectMuscle,
  highlightColor: Colors.red.withOpacity(0.7), // Custom highlight color
  disabledColor: Colors.grey, // Custom color for disabled muscles
  selectedStrokeWidth: 3.0, // Stroke width for selected muscles
  unselectedStrokeWidth: 1.0, // Stroke width for unselected muscles
)
```

#### Size and Layout

```dart
InteractiveBodySvg(
  isFront: true, // Automatically uses package's front body asset
  selectedMuscles: controller.selectedMuscles,
  onMuscleTap: controller.selectMuscle,
  width: 300, // Fixed width
  height: 600, // Fixed height
  fit: BoxFit.cover, // How to fit the SVG
  alignment: Alignment.center, // Alignment within the widget
)
```

#### Selection Behavior

```dart
InteractiveBodySvg(
  isFront: true, // Automatically uses package's front body asset
  selectedMuscles: controller.selectedMuscles,
  onMuscleTap: controller.selectMuscle,
  enableSelection: true, // Enable/disable tap selection
  hitTestPadding: 2.0, // Padding for hit-testing (makes taps more forgiving)
  onMuscleTapDisabled: (muscle) {
    // Called when a muscle is tapped but selection is disabled
    print('Tapped $muscle but selection is disabled');
  },
)
```


## Available Muscles

The package supports the following muscles:

### Front View
- Traps (Left/Right)
- Delts (Left/Right)
- Chest (Left/Right)
- Abs
- Triceps (Left/Right)
- Biceps (Left/Right)
- Forearms (Left/Right)
- Quads (Left/Right)
- Calves (Left/Right)

### Back View
- Lats (Left/Right)
- Lower Lats Back (Left/Right)
- Glutes (Left/Right)
- Hamstrings (Left/Right)
- Triceps (Left/Right)
- Delts (Left/Right)
- Traps (Left/Right)

## Assets

**IMPORTANT:** This package includes the required SVG body diagrams (front and back views) that are **mandatory** for the package to work correctly. You **must** use the package assets - custom SVG files are not supported.

The package assets are pre-configured with the correct muscle IDs and mappings. Using custom assets will result in incorrect behavior.

### Using Package Assets

The package includes default SVG assets that are **automatically used**. Simply use the `isFront` parameter:

```dart
InteractiveBodySvg(
  isFront: true, // Automatically uses package's front body asset
  selectedMuscles: controller.selectedMuscles,
  onMuscleTap: controller.selectMuscle,
)
```

**Note:** The package assets are automatically included when you add this package to your `pubspec.yaml`. No additional asset configuration is required in your app's `pubspec.yaml`.

## API Reference

<<<<<<< HEAD
### `InteractiveBodyWidget`

A complete widget with built-in controller and UI. Perfect for quick integration.

**Properties:**
- `onMuscleSelected` (Function(Muscle)?, optional): Callback when a muscle is selected
- `onSelectionCleared` (VoidCallback?, optional): Callback when selection is cleared
- `selectedMuscles` (Set<Muscle>?, optional): Programmatically set selected muscles (multi-select)
- `initialIsFront` (bool, default: true): Initial view (front or back)
- `highlightColor` (Color?, optional): Color for highlighting selected muscles
- `selectedStrokeWidth` (double, default: 2.0): Stroke width for selected muscles
- `unselectedStrokeWidth` (double, default: 1.0): Stroke width for unselected muscles
- `enableSelection` (bool, default: true): Enable/disable selection
- `fit` (BoxFit, default: BoxFit.contain): How to fit the SVG
- `hitTestPadding` (double, default: 2.0): Padding for hit-testing
- `width` (double?, optional): Fixed width
- `height` (double?, optional): Fixed height
- `alignment` (Alignment, default: Alignment.center): Alignment of SVG
- `showFlipButton` (bool, default: true): Show flip button in app bar
- `showClearButton` (bool, default: true): Show clear button in app bar
- `appBar` (PreferredSizeWidget?, optional): Custom app bar
- `backgroundColor` (Color?, optional): Background color
- `selectedMusclesHeader` (Widget Function(Set<Muscle>)?, optional): Custom header widget that receives the set of selected muscles

=======
>>>>>>> 31cf2a3 (Release v1.2.1: Remove InteractiveBodyWidget, add comprehensive dartdoc comments, clean up code)
### `InteractiveBodySvg`

The core widget for displaying the interactive body diagram.

**Properties:**
- `isFront` (bool, default: true): Whether to show front view. Automatically uses the correct package asset based on this parameter.
- `selectedMuscles` (Set<Muscle>?, optional): Currently selected muscles (multi-select)
- `disabledMuscles` (Set<Muscle>?, optional): Disabled muscles (locked/injured/unavailable) - shown greyed out
- `onMuscleTap` (void Function(Muscle)?, optional): Callback when a muscle is tapped
- `highlightColor` (Color?, optional): Color for highlighting selected muscles (default: Colors.blue with opacity)
- `disabledColor` (Color?, optional): Color for disabled muscles (default: Colors.grey)
- `selectedStrokeWidth` (double, default: 2.0): Stroke width for selected muscles
- `unselectedStrokeWidth` (double, default: 1.0): Stroke width for unselected muscles
- `enableSelection` (bool, default: true): Enable/disable tap selection
- `fit` (BoxFit, default: BoxFit.contain): How to fit the SVG
- `hitTestPadding` (double, default: 2.0): Padding for hit-testing
- `width` (double?, optional): Fixed width
- `height` (double?, optional): Fixed height
- `alignment` (Alignment, default: Alignment.center): Alignment of SVG
- `onMuscleTapDisabled` (void Function(Muscle)?, optional): Callback when muscle is tapped but selection is disabled
- `onMuscleLongPress` (void Function(Muscle)?, optional): Callback when a muscle is long-pressed

### `BodyMapController`

Controller for managing the body selector state.

**Constructor:**
- `BodyMapController({Set<Muscle>? initialSelectedMuscles, Set<Muscle>? initialDisabledMuscles, bool initialIsFront = true})`: Create a controller with optional initial state

**Selection Methods (Writable):**
- `selectMuscle(Muscle)`: Select or toggle a muscle (if already selected, deselects it)
- `toggleMuscle(Muscle)`: Explicitly toggle a muscle's selection state
- `deselectMuscle(Muscle)`: Deselect a specific muscle
- `setSelectedMuscles(Set<Muscle>)`: Set the entire selection (replaces current selection)
- `selectMultiple(Set<Muscle>)`: Add multiple muscles to current selection (without clearing)
- `clearSelection()`: Clear all selections

**View Methods (Writable):**
- `toggleView()`: Toggle between front and back view
- `setFrontView()`: Set view to front
- `setBackView()`: Set view to back

**Disabled Muscle Methods (Writable):**
- `disableMuscle(Muscle)`: Disable a muscle (locks it, removes from selection)
- `enableMuscle(Muscle)`: Enable a muscle (unlocks it)
- `setDisabledMuscles(Set<Muscle>)`: Set multiple disabled muscles at once

**Properties:**
- `selectedMuscles` (Set<Muscle>, **read-only getter, writable setter**): Currently selected muscles (multi-select). 
  - **Getter**: Returns read-only Set of selected muscles
  - **Setter**: Replaces entire selection (equivalent to `setSelectedMuscles()`)
  - Example: `controller.selectedMuscles = {Muscle.bicepsLeft, Muscle.tricepsRight};`
- `disabledMuscles` (Set<Muscle>, **read-only**): Currently disabled muscles. Use disabled muscle methods to modify.
- `isFront` (bool, **writable**): Whether showing front view. Can be set directly or use view methods.
- `isSelected(Muscle)` (bool, **read-only**): Check if a muscle is selected
- `isDisabled(Muscle)` (bool, **read-only**): Check if a muscle is disabled

### `Muscle`

Enum representing all available muscles. See the "Available Muscles" section above for the complete list.

## Common Pitfalls

### ❌ Don't: Try to modify `selectedMuscles` Set directly

```dart
// ❌ WRONG - This won't work because the Set is unmodifiable
controller.selectedMuscles.add(Muscle.bicepsLeft); // Error!
controller.selectedMuscles.clear(); // Error!
```

### ✅ Do: Use the setter or provided methods

```dart
// ✅ CORRECT - Use the setter (replaces entire selection)
controller.selectedMuscles = {Muscle.bicepsLeft, Muscle.tricepsRight};

// ✅ CORRECT - Or use the controller methods
controller.selectMuscle(Muscle.bicepsLeft);
controller.setSelectedMuscles({Muscle.bicepsLeft, Muscle.tricepsRight});
controller.clearSelection();
```

### ❌ Don't: Forget to listen to controller changes

```dart
// ❌ WRONG - UI won't update when selection changes
final controller = BodyMapController();
controller.selectMuscle(Muscle.bicepsLeft);
// Widget won't rebuild automatically
```

### ✅ Do: Use AnimatedBuilder or listen to changes

```dart
// ✅ CORRECT - Wrap with AnimatedBuilder
AnimatedBuilder(
  animation: controller,
  builder: (context, _) {
    return Text('Selected: ${controller.selectedMuscles.length}');
  },
)
```

### ❌ Don't: Create controller in build method

```dart
// ❌ WRONG - Creates new controller on every rebuild
Widget build(BuildContext context) {
  final controller = BodyMapController(); // Don't do this!
  return InteractiveBodySvg(...);
}
```

### ✅ Do: Create controller in initState or use late initialization

```dart
// ✅ CORRECT - Create once in initState
class _MyWidgetState extends State<MyWidget> {
  late BodyMapController controller;
  
  @override
  void initState() {
    super.initState();
    controller = BodyMapController();
  }
  
  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
```

### ❌ Don't: Forget to dispose the controller

```dart
// ❌ WRONG - Memory leak!
class _MyWidgetState extends State<MyWidget> {
  final controller = BodyMapController();
  // Missing dispose() call
}
```

### ✅ Do: Always dispose controllers

```dart
// ✅ CORRECT - Always dispose
@override
void dispose() {
  controller.dispose();
  super.dispose();
}
```

### ❌ Don't: Try to use custom SVG assets

```dart
// ❌ WRONG - Custom SVG files are not supported
// The asset parameter has been removed in version 1.2.0
// The widget now always uses package assets based on isFront parameter
```

### ✅ Do: Use the package's included assets

```dart
// ✅ CORRECT - Automatically uses package assets
InteractiveBodySvg(
  isFront: true, // Automatically uses package's front body asset
)
```

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License.

## Support

If you encounter any issues or have questions, please file an issue on the [GitHub repository](https://github.com/Amrut-03/flutter_body_part_selector).
