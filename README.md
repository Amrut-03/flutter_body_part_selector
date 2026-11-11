# Flutter Body Part Selector

An interactive body selector package for Flutter that allows users to select muscles on a body diagram. Users can tap on muscles in the SVG body diagram or select them programmatically, with visual highlighting of selected muscles. 

The front and back body diagrams ship with the package; no asset setup is needed.

https://github.com/user-attachments/assets/8ba0b47b-fa72-4055-bee8-26f50427437c

## Features

- 🎯 **Interactive Muscle Selection**: Tap on any muscle in the body diagram to select it
- 🎨 **Visual Highlighting**: Selected muscles are automatically highlighted with customizable colors
- 🔄 **Front/Back Views**: Toggle between front and back body views
- 📱 **Programmatic Control**: Select muscles programmatically using the controller
- 🎛️ **Customizable**: Customize highlight colors and disabled muscle colors
- 🚫 **Disabled Muscles**: Lock muscles (injured, premium, unavailable) so they render greyed out and can't be selected
- 🪝 **Hooks**: Long-press, tooltip, semantic-label and selection-animation callbacks
- 📦 **Easy to Use**: Simple API with minimal setup required - includes all required assets
- 🎨 **Built-in Assets**: Package includes mandatory SVG body diagrams (front and back views)

## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  flutter_body_part_selector: ^1.3.0
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
                  onMuscleTap: controller.toggleMuscle,
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
controller.toggleMuscle(Muscle.bicepsLeft);

// Clear all selections
controller.clearSelection();

// Toggle between front and back view
controller.toggleView();

// Set specific view
controller.setFrontView();
controller.setBackView();

// Access current state
final selected = controller.selectedMuscles; // Returns Set<Muscle> (read-only getter)
final isFront = controller.isFront; // Writable: setting it notifies listeners

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
                  onMuscleTap: controller.toggleMuscle,
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
  onMuscleTap: controller.toggleMuscle,
  highlightColor: Colors.red.withValues(alpha: 0.7), // Custom highlight color
  disabledColor: Colors.grey, // Custom color for disabled muscles
  selectedStrokeWidth: 3.0, // Stroke width for selected muscles
  unselectedStrokeWidth: 1.0, // Stroke width for unselected muscles
)
```

Color alpha is respected: a highlight color with `alpha: 0.7` is drawn 70% opaque. Disabled muscles are additionally drawn at 40% opacity.

#### Size and Layout

```dart
InteractiveBodySvg(
  isFront: true, // Automatically uses package's front body asset
  selectedMuscles: controller.selectedMuscles,
  onMuscleTap: controller.toggleMuscle,
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
  onMuscleTap: controller.toggleMuscle,
  enableSelection: true, // Enable/disable tap selection
  hitTestPadding: 2.0, // Padding for hit-testing (makes taps more forgiving)
  onMuscleTapDisabled: (muscle) {
    // Called when a disabled muscle is tapped, or any muscle while
    // enableSelection is false
    print('Tapped $muscle but it cannot be selected');
  },
)
```

Taps fire when the finger lifts, so a scroll or drag that starts on a muscle does not select it, and a long press does not also count as a tap.

#### Hooks

```dart
InteractiveBodySvg(
  selectedMuscles: controller.selectedMuscles,
  onMuscleTap: controller.toggleMuscle,

  // Long press on a muscle
  onMuscleLongPress: (muscle) => print('Long-pressed ${muscle.displayName}'),

  // Text shown in a SnackBar on long press (needs a ScaffoldMessenger,
  // which MaterialApp provides). Return null to show nothing.
  tooltipBuilder: (muscle) => '${muscle.displayName} - tap to select',

  // Screen-reader label: the labels of the selected muscles, joined by commas
  semanticLabelBuilder: (muscle) => '${muscle.displayName} selected',

  // Wraps the diagram each time a muscle is newly selected. The subtree is
  // rebuilt on every new selection, so this pulse replays each time.
  onSelectAnimationBuilder: (context, child, muscle) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 1.04, end: 1.0),
      duration: const Duration(milliseconds: 250),
      builder: (context, scale, child) =>
          Transform.scale(scale: scale, child: child),
      child: child,
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
- Biceps (Left/Right)
- Forearms (Left/Right)
- Quads (Left/Right)
- Calves (Left/Right)

### Back View
- Traps (Left/Right)
- Delts (Left/Right)
- Triceps (Left/Right)
- Lats (Left/Right)
- Lower Lats Back (Left/Right)
- Forearms (Left/Right)
- Glutes (Left/Right)
- Hamstrings (Left/Right)
- Calves (Left/Right)

Muscles that appear in both views (traps, delts, forearms, calves) map to the same `Muscle` value, so a selection made on one side stays highlighted on the other.

## Assets

The package includes the front and back SVG body diagrams, pre-configured with the muscle IDs the widget maps to `Muscle` values.

### Using Package Assets

The package includes default SVG assets that are **automatically used**. Simply use the `isFront` parameter:

```dart
InteractiveBodySvg(
  isFront: true, // Automatically uses package's front body asset
  selectedMuscles: controller.selectedMuscles,
  onMuscleTap: controller.toggleMuscle,
)
```

**Note:** The package assets are automatically included when you add this package to your `pubspec.yaml`. No additional asset configuration is required in your app's `pubspec.yaml`.

## API Reference

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
- `hitTestPadding` (double, default: 2.0): How far outside a muscle's edge, in SVG units, a tap still counts as hitting it
- `width` (double?, optional): Fixed width
- `height` (double?, optional): Fixed height
- `alignment` (Alignment, default: Alignment.center): Alignment of SVG
- `onMuscleTapDisabled` (void Function(Muscle)?, optional): Callback when muscle is tapped but selection is disabled
- `onMuscleLongPress` (void Function(Muscle)?, optional): Callback when a muscle is long-pressed
- `tooltipBuilder` (String? Function(Muscle)?, optional): Text shown in a SnackBar when a muscle is long-pressed
- `semanticLabelBuilder` (String? Function(Muscle)?, optional): Screen-reader label for each selected muscle
- `onSelectAnimationBuilder` (Widget Function(BuildContext, Widget, Muscle)?, optional): Wraps the diagram each time a muscle is newly selected; see [Hooks](#hooks)
- `hitTestBehavior` (HitTestBehavior, default: deferToChild): Hit-test behavior of the gesture detector
- `loadingBuilder` (WidgetBuilder?, optional): Widget shown while the SVG loads (default: a centered `CircularProgressIndicator`). See [Testing](#testing).
- `asset` (String?, optional, advanced): Overrides the built-in SVG path. Not recommended; see [Common Pitfalls](#common-pitfalls).
- `isInitialSelection` (bool, **deprecated**): Ignores taps while `true`. No longer needed; pass the starting selection through `selectedMuscles` instead.

### `BodyMapController`

Controller for managing the body selector state.

**Constructor:**
- `BodyMapController({Set<Muscle>? initialSelectedMuscles, Set<Muscle>? initialDisabledMuscles, bool initialIsFront = true})`: Create a controller with optional initial state

**Selection Methods (Writable):**
- `toggleMuscle(Muscle)`: Select the muscle, or deselect it if already selected. Pass it as `onMuscleTap` for tap-to-toggle
- `selectMuscle(Muscle)`: Same as `toggleMuscle` (it also deselects an already-selected muscle); kept for compatibility
- `deselectMuscle(Muscle)`: Deselect a specific muscle
- `setSelectedMuscles(Set<Muscle>)`: Set the entire selection (replaces current selection)
- `selectMultiple(Set<Muscle>)`: Add multiple muscles to current selection (without clearing)
- `clearSelection()`: Clear all selections

**View Methods (Writable):**
- `toggleView()`: Toggle between front and back view
- `setFrontView()`: Set view to front
- `setBackView()`: Set view to back

- `setInitialSelection(Set<Muscle>)`: Replace the selection **without** notifying listeners, for seeding state before the first build

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
- `isFront` (bool, **writable**): Whether showing front view. Can be set directly (notifies listeners) or use view methods.
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
controller.toggleMuscle(Muscle.bicepsLeft);
controller.setSelectedMuscles({Muscle.bicepsLeft, Muscle.tricepsRight});
controller.clearSelection();
```

### ❌ Don't: Forget to listen to controller changes

```dart
// ❌ WRONG - UI won't update when selection changes
final controller = BodyMapController();
controller.toggleMuscle(Muscle.bicepsLeft);
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

### ❌ Don't: Use a custom SVG without the package's element IDs

```dart
// ❌ WRONG - Muscle taps and highlights only work for elements whose
// IDs match the package's built-in SVGs (e.g. `biceps_left`, `lats_right`)
InteractiveBodySvg(
  asset: 'assets/my_body.svg',
)
```

The `asset` parameter is an advanced override. Each muscle must be a `<path>` or a `<g>` of paths whose `id` matches the built-in SVGs. If the asset can't be loaded, the widget shows an error instead of falling back to the built-in diagram.

### ✅ Do: Use the package's included assets

```dart
// ✅ CORRECT - Automatically uses package assets
InteractiveBodySvg(
  isFront: true, // Automatically uses package's front body asset
)
```

## Testing

`InteractiveBodySvg` loads its SVG asynchronously from the asset bundle. Under the `flutter_test` fake clock that load does not complete on its own, and the default loading spinner animates forever, so `tester.pumpAndSettle()` times out.

**If your test doesn't need the diagram itself** (you're testing surrounding UI), pass a static `loadingBuilder` and `pumpAndSettle()` works normally:

```dart
await tester.pumpWidget(MaterialApp(
  home: Scaffold(
    body: InteractiveBodySvg(
      loadingBuilder: (context) => const SizedBox.shrink(),
    ),
  ),
));
await tester.pumpAndSettle(); // settles; the SVG stays unloaded
```

**If your test needs the rendered diagram**, let the real asset I/O run inside `tester.runAsync`:

```dart
await tester.runAsync(() async {
  await tester.pumpWidget(MaterialApp(home: Scaffold(body: InteractiveBodySvg())));
  // The first parse can take over a second; poll until the SVG appears.
  for (var i = 0; i < 100 && find.byType(SvgPicture).evaluate().isEmpty; i++) {
    await Future<void>.delayed(const Duration(milliseconds: 50));
    await tester.pump();
  }
});
await tester.pump();
expect(find.byType(SvgPicture), findsOneWidget); // from package:flutter_svg
```

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License.

## Support

If you encounter any issues or have questions, please file an issue on the [GitHub repository](https://github.com/Amrut-03/flutter_body_part_selector).
