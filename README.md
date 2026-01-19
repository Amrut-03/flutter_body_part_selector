# Flutter Body Part Selector

An interactive body selector package for Flutter that allows users to select muscles on a body diagram. Users can tap on muscles in the SVG body diagram or select them programmatically, with visual highlighting of selected muscles. 

**⚠️ IMPORTANT: This package includes mandatory SVG assets that must be used. Custom SVG files are not supported.**

## Features

- 🎯 **Interactive Muscle Selection**: Tap on any muscle in the body diagram to select it
- 🎨 **Visual Highlighting**: Selected muscles are automatically highlighted with customizable colors
- 🔄 **Front/Back Views**: Toggle between front and back body views
- 📱 **Programmatic Control**: Select muscles programmatically using the controller
- 🎛️ **Customizable**: Customize highlight colors and base colors
- 📦 **Easy to Use**: Simple API with minimal setup required - includes all required assets
- 🎨 **Built-in Assets**: Package includes mandatory SVG body diagrams (front and back views)

## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  flutter_body_part_selector: ^1.0.0
```

Then run:

```bash
flutter pub get
```

## Usage

### Quick Start (Recommended)

The easiest way to use this package is with the `InteractiveBodyWidget`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_body_part_selector/flutter_body_part_selector.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: InteractiveBodyWidget(
        // Asset paths are optional - package includes default assets
        onMuscleSelected: (muscle) {
          print('Selected muscle: $muscle');
        },
      ),
    );
  }
}
```

### Advanced Usage

For more control, use `InteractiveBodySvg` with `BodyMapController`:

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
              if (controller.selectedMuscle != null)
                Container(
                  padding: const EdgeInsets.all(16),
                  color: Colors.blue.shade900,
                  width: double.infinity,
                  child: Text(
                    'Selected: ${controller.selectedMuscle.toString()}',
                    style: const TextStyle(color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                ),
              Expanded(
                child: InteractiveBodySvg(
                  asset: controller.isFront
                      ? 'packages/flutter_body_part_selector/assets/svg/body_front.svg'
                      : 'packages/flutter_body_part_selector/assets/svg/body_back.svg',
                  selectedMuscle: controller.selectedMuscle,
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

```dart
final controller = BodyMapController();

// Select a muscle programmatically
controller.selectMuscle(Muscle.bicepsLeft);

// Clear selection
controller.clearSelection();

// Toggle between front and back view
controller.toggleView();

// Set specific view
controller.setFrontView();
controller.setBackView();

// Access current state
final selected = controller.selectedMuscle;
final isFront = controller.isFront;
```

### Customization Options

#### Colors and Styling

```dart
InteractiveBodySvg(
  asset: 'packages/flutter_body_part_selector/assets/svg/body_front.svg',
  selectedMuscles: controller.selectedMuscles,
  onMuscleTap: controller.selectMuscle,
  highlightColor: Colors.red.withOpacity(0.7), // Custom highlight color
  baseColor: Colors.white, // Custom base color for unselected muscles
  selectedStrokeWidth: 3.0, // Stroke width for selected muscles
  unselectedStrokeWidth: 1.0, // Stroke width for unselected muscles
)
```

#### Size and Layout

```dart
InteractiveBodySvg(
  asset: 'packages/flutter_body_part_selector/assets/svg/body_front.svg',
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
  asset: 'packages/flutter_body_part_selector/assets/svg/body_front.svg',
  selectedMuscles: controller.selectedMuscles,
  onMuscleTap: controller.selectMuscle,
  enableSelection: true, // Enable/disable tap selection
  hitTestPadding: 15.0, // Padding for hit-testing (makes taps more forgiving)
  onMuscleTapDisabled: (muscle) {
    // Called when a muscle is tapped but selection is disabled
    print('Tapped $muscle but selection is disabled');
  },
)
```

#### Using InteractiveBodyWidget

The `InteractiveBodyWidget` provides a complete solution with built-in UI:

```dart
InteractiveBodyWidget(
  frontAsset: 'packages/flutter_body_part_selector/assets/svg/body_front.svg',
  backAsset: 'packages/flutter_body_part_selector/assets/svg/body_back.svg',
  onMuscleSelected: (muscle) {
    print('Selected: $muscle');
  },
  highlightColor: Colors.blue,
  baseColor: Colors.white,
  showFlipButton: true, // Show flip button in app bar
  showClearButton: true, // Show clear button in app bar
  backgroundColor: Colors.black, // Background color
  selectedMuscleHeader: (muscle) {
    // Custom header widget
    return Container(
      padding: EdgeInsets.all(16),
      child: Text('Selected: $muscle'),
    );
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
- Lats Front (Left/Right)
- Triceps (Left/Right)
- Biceps (Left/Right)
- Biceps Brachialis (Left/Right)
- Forearms (Left/Right)
- Quads (Left/Right)
- Calves (Left/Right)

### Back View
- Lats Back (Left/Right)
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

The package includes default SVG assets that are **automatically used** by `InteractiveBodyWidget`. You don't need to specify asset paths:

```dart
// Simplest usage - assets are included automatically
InteractiveBodyWidget(
  onMuscleSelected: (muscle) {
    print('Selected: $muscle');
  },
)
```

If you need to specify asset paths explicitly (for `InteractiveBodySvg` or custom paths):

```dart
InteractiveBodySvg(
  asset: 'packages/flutter_body_part_selector/assets/svg/body_front.svg',
  // ...
)
```

**Note:** The package assets are automatically included when you add this package to your `pubspec.yaml`. No additional asset configuration is required in your app's `pubspec.yaml`.

## API Reference

### `InteractiveBodyWidget`

A complete widget with built-in controller and UI. Perfect for quick integration.

**Properties:**
- `frontAsset` (String?, optional): Path to the front body SVG. Defaults to `'packages/flutter_body_part_selector/assets/svg/body_front.svg'` if not specified. Custom SVG files are not supported.
- `backAsset` (String?, optional): Path to the back body SVG. Defaults to `'packages/flutter_body_part_selector/assets/svg/body_back.svg'` if not specified. Custom SVG files are not supported.
- `onMuscleSelected` (Function(Muscle)?, optional): Callback when a muscle is selected
- `onSelectionCleared` (VoidCallback?, optional): Callback when selection is cleared
- `selectedMuscles` (Set<Muscle>?, optional): Programmatically set selected muscles (multi-select)
- `initialIsFront` (bool, default: true): Initial view (front or back)
- `highlightColor` (Color?, optional): Color for highlighting selected muscles
- `baseColor` (Color?, optional): Base color for unselected muscles
- `selectedStrokeWidth` (double, default: 2.0): Stroke width for selected muscles
- `unselectedStrokeWidth` (double, default: 1.0): Stroke width for unselected muscles
- `enableSelection` (bool, default: true): Enable/disable selection
- `fit` (BoxFit, default: BoxFit.contain): How to fit the SVG
- `hitTestPadding` (double, default: 10.0): Padding for hit-testing
- `width` (double?, optional): Fixed width
- `height` (double?, optional): Fixed height
- `alignment` (Alignment, default: Alignment.center): Alignment of SVG
- `showFlipButton` (bool, default: true): Show flip button in app bar
- `showClearButton` (bool, default: true): Show clear button in app bar
- `appBar` (PreferredSizeWidget?, optional): Custom app bar
- `backgroundColor` (Color?, optional): Background color
- `selectedMuscleHeader` (Widget Function(Muscle)?, optional): Custom header widget

### `InteractiveBodySvg`

The core widget for displaying the interactive body diagram.

**Properties:**
- `asset` (String, required): **MUST** be the package asset path: `'packages/flutter_body_part_selector/assets/svg/body_front.svg'` or `'packages/flutter_body_part_selector/assets/svg/body_back.svg'`. Custom SVG files are not supported.
- `selectedMuscles` (Set<Muscle>?, optional): Currently selected muscles (multi-select)
- `onMuscleTap` (Function(Muscle)?, optional): Callback when a muscle is tapped
- `highlightColor` (Color?, optional): Color for highlighting selected muscles (default: Colors.blue with opacity)
- `baseColor` (Color?, optional): Base color for unselected muscles (default: Colors.white)
- `selectedStrokeWidth` (double, default: 2.0): Stroke width for selected muscles
- `unselectedStrokeWidth` (double, default: 1.0): Stroke width for unselected muscles
- `enableSelection` (bool, default: true): Enable/disable tap selection
- `fit` (BoxFit, default: BoxFit.contain): How to fit the SVG
- `hitTestPadding` (double, default: 10.0): Padding for hit-testing
- `width` (double?, optional): Fixed width
- `height` (double?, optional): Fixed height
- `alignment` (Alignment, default: Alignment.center): Alignment of SVG
- `onMuscleTapDisabled` (Function(Muscle)?, optional): Callback when muscle is tapped but selection is disabled

### `BodyMapController`

Controller for managing the body selector state.

**Methods:**
- `selectMuscle(Muscle)`: Select a muscle
- `clearSelection()`: Clear the current selection
- `toggleView()`: Toggle between front and back view
- `setFrontView()`: Set view to front
- `setBackView()`: Set view to back

**Properties:**
- `selectedMuscles` (Set<Muscle>): Currently selected muscles (multi-select)
- `isFront` (bool): Whether showing front view

### `Muscle`

Enum representing all available muscles. See the "Available Muscles" section above for the complete list.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License.

## Support

If you encounter any issues or have questions, please file an issue on the [GitHub repository](https://github.com/yourusername/flutter_body_part_selector).
#   f l u t t e r _ b o d y _ p a r t _ s e l e c t o r  
 