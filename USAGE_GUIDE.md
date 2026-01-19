# Interactive Body - Complete Usage Guide

## Quick Answers to Your Questions

### 1. Toggle Selection in Multi-Mode

**How it works:**
- In multi-select mode, tapping a selected muscle will deselect it (toggle off)
- Tapping an unselected muscle will select it (toggle on)

**To enable multi-select:**
```dart
controller.setSelectionMode(SelectionMode.multi);
```

**In the UI:**
- There's now a checkbox icon button in the app bar to toggle between single and multi-select modes
- The icon changes based on current mode

### 2. How to Disable Muscles in UI

**Option 1: Programmatically**
```dart
// Disable a single muscle
controller.disableMuscle(Muscle.bicepsLeft);

// Disable multiple muscles
controller.setDisabledMuscles({
  Muscle.bicepsLeft,
  Muscle.tricepsRight,
});

// Enable a muscle
controller.enableMuscle(Muscle.bicepsLeft);
```

**Option 2: Using the UI Button**
- There's now a lock icon (🔒) in the app bar
- Click it to see a menu of muscles you can disable/enable
- The menu shows which muscles are currently disabled

**Visual Indication:**
- Disabled muscles appear greyed out with 40% opacity
- They cannot be selected when tapped
- The disabled color is customizable via `disabledColor` parameter

### 3. Disabled Muscles Visual Indication

**Current Implementation:**
- Disabled muscles use `disabledColor` (default: grey with 50% opacity)
- Applied opacity: 40% for better visibility
- Stroke color changes to disabled color
- Fill color changes to disabled color

**To customize:**
```dart
InteractiveBodySvg(
  disabledColor: Colors.red.withOpacity(0.3), // Custom disabled color
  // ...
)
```

### 4. Initial Selection - Screen Blink Fixed

**The Fix:**
- Added `isInitialSelection` flag to prevent callbacks on initial load
- Used `scheduleMicrotask` to batch state updates
- Only show loading indicator on first load, not on updates
- Cached SVG in fast performance mode

**How to use:**
```dart
// In your screen
bool _isInitialLoad = true;

@override
void initState() {
  super.initState();
  // Set initial selection
  controller.setInitialSelection({Muscle.chestLeft});
  
  // Mark initial load complete after first frame
  WidgetsBinding.instance.addPostFrameCallback((_) {
    _isInitialLoad = false;
  });
}

// In widget
InteractiveBodySvg(
  isInitialSelection: _isInitialLoad,
  // ...
)
```

### 5. Tooltip / Label Hooks

**How to Use:**
```dart
InteractiveBodySvg(
  tooltipBuilder: (muscle) {
    return '${muscle.displayName} - Tap to select';
  },
  // ...
)
```

**How it Works:**
- **Long press** on any muscle to see the tooltip
- Tooltip appears as a SnackBar at the bottom
- Shows the muscle name and action

**Note:** Tooltips appear on long press, not on hover (mobile doesn't have hover)

### 6. Animation Hooks

**How to Use:**
```dart
InteractiveBodySvg(
  onSelectAnimationBuilder: (context, child, muscle) {
    // Return an animated version of the child
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 1.0, end: 1.08),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: child,
        );
      },
      child: child,
    );
  },
  // ...
)
```

**Current Implementation:**
- Animation is applied when any muscle is selected
- The entire SVG scales up slightly (1.0 to 1.08)
- Animation duration: 300ms
- Uses easeInOut curve

**To make it more visible:**
- Increase the scale value (e.g., 1.1 instead of 1.08)
- Add glow effect
- Add color animation

### 7. Semantic Accessibility

**How to Use:**
```dart
InteractiveBodySvg(
  semanticLabelBuilder: (muscle) {
    return '${muscle.displayName} muscle. ${controller.isSelected(muscle) ? "Selected" : "Not selected"}.';
  },
  // ...
)
```

**How it Works:**
- Screen readers will announce the semantic label
- Label is always available (even when nothing is selected)
- Default label: "Interactive body diagram. Tap to select muscles."

**Testing:**
- Enable screen reader on your device
- Navigate to the body diagram
- Screen reader will read the semantic labels

## Complete Example with All Features

```dart
class CompleteExample extends StatefulWidget {
  @override
  State<CompleteExample> createState() => _CompleteExampleState();
}

class _CompleteExampleState extends State<CompleteExample> {
  final controller = BodyMapController();
  bool _isInitialLoad = true;

  @override
  void initState() {
    super.initState();
    
    // Set multi-select mode
    controller.setSelectionMode(SelectionMode.multi);
    
    // Disable some muscles (example: injured muscles)
    controller.setDisabledMuscles({
      Muscle.bicepsLeft, // Injured
    });
    
    // Set initial selection (no callbacks triggered)
    controller.setInitialSelection({
      Muscle.chestLeft,
      Muscle.chestRight,
    });
    
    // Mark initial load complete
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _isInitialLoad = false;
      });
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Complete Example'),
        actions: [
          // Toggle single/multi select
          IconButton(
            icon: Icon(
              controller.selectionMode == SelectionMode.multi
                  ? Icons.check_box
                  : Icons.check_box_outline_blank,
            ),
            onPressed: () {
              controller.setSelectionMode(
                controller.selectionMode == SelectionMode.multi
                    ? SelectionMode.single
                    : SelectionMode.multi,
              );
            },
          ),
          // Disable/enable muscles
          PopupMenuButton<Muscle>(
            icon: const Icon(Icons.lock),
            itemBuilder: (context) => [
              PopupMenuItem(
                value: Muscle.bicepsLeft,
                child: Text(
                  controller.isDisabled(Muscle.bicepsLeft)
                      ? 'Enable Left Biceps'
                      : 'Disable Left Biceps',
                ),
              ),
              // Add more muscles...
            ],
            onSelected: (muscle) {
              if (controller.isDisabled(muscle)) {
                controller.enableMuscle(muscle);
              } else {
                controller.disableMuscle(muscle);
              }
            },
          ),
        ],
      ),
      body: AnimatedBuilder(
        animation: controller,
        builder: (context, _) {
          return Column(
            children: [
              // Show selected muscles
              if (controller.selectedMuscles.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(16),
                  child: Wrap(
                    spacing: 8,
                    children: controller.selectedMuscles.map((muscle) {
                      return Chip(
                        label: Text(muscle.displayName),
                        onDeleted: () => controller.deselectMuscle(muscle),
                      );
                    }).toList(),
                  ),
                ),
              // Show disabled muscles
              if (controller.disabledMuscles.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(8),
                  color: Colors.grey.shade800,
                  child: Text(
                    'Disabled: ${controller.disabledMuscles.length} muscles',
                    style: const TextStyle(color: Colors.white70),
                  ),
                ),
              // Body diagram
              Expanded(
                child: InteractiveBodySvg(
                  asset: controller.isFront
                      ? 'assets/svg/body_front.svg'
                      : 'assets/svg/body_back.svg',
                  selectedMuscle: controller.selectionMode == SelectionMode.single
                      ? controller.selectedMuscle
                      : null,
                  selectedMuscles: controller.selectionMode == SelectionMode.multi
                      ? controller.selectedMuscles
                      : null,
                  disabledMuscles: controller.disabledMuscles,
                  onMuscleTap: controller.selectMuscle,
                  isInitialSelection: _isInitialLoad,
                  // Tooltips
                  tooltipBuilder: (muscle) {
                    if (controller.isDisabled(muscle)) {
                      return '${muscle.displayName} is disabled';
                    }
                    return '${muscle.displayName} - ${controller.isSelected(muscle) ? "Tap to deselect" : "Tap to select"}';
                  },
                  // Semantic labels
                  semanticLabelBuilder: (muscle) {
                    String status = controller.isDisabled(muscle)
                        ? 'Disabled'
                        : controller.isSelected(muscle)
                            ? 'Selected'
                            : 'Not selected';
                    return '${muscle.displayName} muscle. $status.';
                  },
                  // Animation
                  onSelectAnimationBuilder: (context, child, muscle) {
                    return TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.0, end: 1.0),
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      builder: (context, value, child) {
                        final scale = 1.0 + (0.08 * (value < 0.5 ? value * 2 : (1 - value) * 2));
                        return Transform.scale(
                          scale: scale,
                          child: child,
                        );
                      },
                      child: child,
                    );
                  },
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

## Troubleshooting

### Animation not visible?
- Make sure `onSelectAnimationBuilder` is provided
- Increase the scale value (e.g., 1.1 instead of 1.05)
- Check that muscles are actually selected

### Tooltip not showing?
- Tooltips appear on **long press**, not tap
- Make sure `tooltipBuilder` is provided
- Long press on a muscle area

### Disabled muscles not greyed out?
- Make sure `disabledMuscles` is passed to the widget
- Check that `disabledColor` is set (default is grey)
- Verify the muscles are actually in the disabled set

### Screen still blinking?
- Make sure `isInitialSelection` is set correctly
- Use `setInitialSelection()` instead of `selectMuscle()` for initial load
- Check that `scheduleMicrotask` is being used

### Multi-select toggle not working?
- Make sure `setSelectionMode(SelectionMode.multi)` is called
- In multi-mode, tapping a selected muscle deselects it
- Check that `selectedMuscles` (not `selectedMuscle`) is passed to widget
