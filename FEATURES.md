# Enterprise Features Guide

This document describes all the enterprise-grade features available in the Interactive Body package.

## 1. Single & Multi-Select Support

### Single Selection (Default)
```dart
final controller = BodyMapController();
controller.setSelectionMode(SelectionMode.single);

// Select a muscle
controller.selectMuscle(Muscle.bicepsLeft);

// Get selected muscle
final selected = controller.selectedMuscle; // Muscle?
```

### Multi Selection
```dart
final controller = BodyMapController();
controller.setSelectionMode(SelectionMode.multi);

// Select multiple muscles
controller.selectMuscle(Muscle.bicepsLeft);
controller.selectMuscle(Muscle.tricepsRight);

// Get all selected muscles
final selected = controller.selectedMuscles; // Set<Muscle>

// Check if a muscle is selected
if (controller.isSelected(Muscle.bicepsLeft)) {
  // ...
}
```

### Using with Widget
```dart
InteractiveBodySvg(
  asset: 'assets/svg/body_front.svg',
  selectedMuscles: controller.selectedMuscles, // For multi-select
  // OR
  selectedMuscle: controller.selectedMuscle, // For single-select
  onMuscleTap: controller.selectMuscle,
)
```

## 2. Stable Muscle ID System

Each muscle has a stable string ID for persistence and API calls:

```dart
// Get stable ID
final muscle = Muscle.bicepsLeft;
final id = muscle.id; // "bicepsLeft"

// Get display name
final name = muscle.displayName; // "Biceps Left"

// Get muscle from ID
final muscle = Muscle.fromId("bicepsLeft"); // Muscle.bicepsLeft or null
```

### Use Cases
- **Persistence**: Save selected muscles to database
- **API Calls**: Send muscle IDs to backend
- **Analytics**: Track muscle selections

```dart
// Save to SharedPreferences
final selectedIds = controller.selectedMuscles
    .map((m) => m.id)
    .toList();
await prefs.setStringList('selected_muscles', selectedIds);

// Restore from SharedPreferences
final savedIds = prefs.getStringList('selected_muscles') ?? [];
final restored = savedIds
    .map((id) => Muscle.fromId(id))
    .whereType<Muscle>()
    .toSet();
controller.setInitialSelection(restored);
```

## 3. Automatic Highlighting

Highlighting works automatically:
- **Selected** → Highlighted with `highlightColor`
- **Unselected** → Normal with `baseColor`
- **Disabled** → Greyed out with `disabledColor`

```dart
InteractiveBodySvg(
  asset: 'assets/svg/body_front.svg',
  selectedMuscle: controller.selectedMuscle,
  highlightColor: Colors.blue.withOpacity(0.6), // Selected color
  baseColor: Colors.white, // Unselected color
  disabledColor: Colors.grey.withOpacity(0.5), // Disabled color
  onMuscleTap: controller.selectMuscle,
)
```

## 4. Disabled / Locked Muscles

Lock muscles for various use cases:

```dart
final controller = BodyMapController();

// Disable specific muscles (injury recovery)
controller.disableMuscle(Muscle.bicepsLeft);
controller.disableMuscle(Muscle.tricepsRight);

// Disable multiple muscles (beginner plan)
controller.setDisabledMuscles({
  Muscle.bicepsLeft,
  Muscle.tricepsLeft,
  Muscle.chestLeft,
});

// Check if disabled
if (controller.isDisabled(Muscle.bicepsLeft)) {
  // Show message: "This muscle is locked"
}

// Enable a muscle
controller.enableMuscle(Muscle.bicepsLeft);

// Get all disabled muscles
final disabled = controller.disabledMuscles;
```

### Use Cases

**Injury Recovery:**
```dart
// Lock injured muscles
controller.setDisabledMuscles({
  Muscle.bicepsLeft, // Injured
  Muscle.shoulderLeft, // Injured
});
```

**Beginner Plans:**
```dart
// Lock advanced muscles
controller.setDisabledMuscles({
  Muscle.hamstringsLeft,
  Muscle.hamstringsRight,
  // ... other advanced muscles
});
```

**Paid Feature Locking:**
```dart
// Lock premium muscles
if (!isPremiumUser) {
  controller.setDisabledMuscles({
    Muscle.glutesLeft,
    Muscle.glutesRight,
    // ... premium muscles
  });
}
```

## 5. Initial Selection (No State Change)

Set initial selection without triggering callbacks:

```dart
final controller = BodyMapController();

// Set initial selection (no callbacks triggered)
controller.setInitialSelection({
  Muscle.bicepsLeft,
  Muscle.tricepsRight,
});

// Or use isInitialSelection flag
InteractiveBodySvg(
  asset: 'assets/svg/body_front.svg',
  selectedMuscle: controller.selectedMuscle,
  isInitialSelection: true, // Prevents callback on initial load
  onMuscleTap: controller.selectMuscle,
)
```

## 6. Tooltip / Label Hooks

Show tooltips when hovering or tapping:

```dart
InteractiveBodySvg(
  asset: 'assets/svg/body_front.svg',
  selectedMuscle: controller.selectedMuscle,
  tooltipBuilder: (muscle) {
    // Return custom tooltip text
    return '${muscle.displayName} - Tap to select';
  },
  onMuscleTap: controller.selectMuscle,
)
```

## 7. Gesture Precision Modes

Control hit-testing behavior:

```dart
InteractiveBodySvg(
  asset: 'assets/svg/body_front.svg',
  selectedMuscle: controller.selectedMuscle,
  hitTestBehavior: HitTestBehavior.precise, // Precise hit-testing
  // OR
  hitTestBehavior: HitTestBehavior.deferToChild, // Default
  // OR
  hitTestBehavior: HitTestBehavior.opaque, // Fast but less accurate
  onMuscleTap: controller.selectMuscle,
)
```

**Recommendations:**
- **Precise**: Best accuracy, slightly slower (default for quality mode)
- **DeferToChild**: Balanced (default)
- **Opaque**: Fastest, less accurate (use with fast performance mode)

## 8. Animation Hooks

Add custom animations without forcing opinions:

```dart
InteractiveBodySvg(
  asset: 'assets/svg/body_front.svg',
  selectedMuscle: controller.selectedMuscle,
  onSelectAnimationBuilder: (context, child, muscle) {
    // Pulse animation
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 1.0, end: 1.1),
      duration: const Duration(milliseconds: 500),
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
  onMuscleTap: controller.selectMuscle,
)
```

### Example Animations

**Glow Effect:**
```dart
onSelectAnimationBuilder: (context, child, muscle) {
  return Container(
    decoration: BoxDecoration(
      boxShadow: [
        BoxShadow(
          color: Colors.blue.withOpacity(0.5),
          blurRadius: 20,
          spreadRadius: 5,
        ),
      ],
    ),
    child: child,
  );
}
```

**Scale Animation:**
```dart
onSelectAnimationBuilder: (context, child, muscle) {
  return AnimatedScale(
    scale: 1.05,
    duration: const Duration(milliseconds: 200),
    child: child,
  );
}
```

**Shake Animation:**
```dart
onSelectAnimationBuilder: (context, child, muscle) {
  return TweenAnimationBuilder<double>(
    tween: Tween(begin: -5.0, end: 5.0),
    duration: const Duration(milliseconds: 100),
    builder: (context, value, child) {
      return Transform.translate(
        offset: Offset(value, 0),
        child: child,
      );
    },
    child: child,
  );
}
```

## 9. Performance Modes

Optimize for different use cases:

```dart
InteractiveBodySvg(
  asset: 'assets/svg/body_front.svg',
  selectedMuscle: controller.selectedMuscle,
  performanceMode: PerformanceMode.fast, // Optimized for performance
  // OR
  performanceMode: PerformanceMode.balanced, // Default
  // OR
  performanceMode: PerformanceMode.quality, // Best quality
  onMuscleTap: controller.selectMuscle,
)
```

**Performance Modes:**
- **Fast**: Caches SVG, reduces rebuilds, best for low-end devices
- **Balanced**: Good performance with full features (default)
- **Quality**: Best visual quality, may be slower

## 10. Semantic Accessibility

Enterprise-grade accessibility support:

```dart
InteractiveBodySvg(
  asset: 'assets/svg/body_front.svg',
  selectedMuscle: controller.selectedMuscle,
  semanticLabelBuilder: (muscle) {
    // Return semantic label for screen readers
    return 'Selected muscle: ${muscle.displayName}';
  },
  onMuscleTap: controller.selectMuscle,
)
```

### Screen Reader Support

The widget automatically provides semantic labels for screen readers:

```dart
// Screen reader will announce:
// "Selected muscle: Biceps Left"
// "Selected muscle: Triceps Right, Biceps Left"
```

## 11. API Design - Stateless with Callbacks

The package follows best practices:

✅ **Stateless Widgets**: No forced architecture
✅ **Callbacks**: Simple function callbacks
✅ **Optional Controller**: Use controller or manage state yourself

### Example: Without Controller

```dart
class MyWidget extends StatefulWidget {
  @override
  State<MyWidget> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  Muscle? selectedMuscle;

  @override
  Widget build(BuildContext context) {
    return InteractiveBodySvg(
      asset: 'assets/svg/body_front.svg',
      selectedMuscle: selectedMuscle,
      onMuscleTap: (muscle) {
        setState(() {
          selectedMuscle = muscle;
        });
      },
    );
  }
}
```

### Example: With Controller

```dart
class MyWidget extends StatelessWidget {
  final controller = BodyMapController();

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        return InteractiveBodySvg(
          asset: 'assets/svg/body_front.svg',
          selectedMuscle: controller.selectedMuscle,
          onMuscleTap: controller.selectMuscle,
        );
      },
    );
  }
}
```

### Example: With Bloc/GetX/Riverpod

```dart
// Works with any state management
class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final bloc = context.watch<BodyMapBloc>();
    
    return InteractiveBodySvg(
      asset: 'assets/svg/body_front.svg',
      selectedMuscle: bloc.state.selectedMuscle,
      onMuscleTap: (muscle) {
        bloc.add(SelectMuscle(muscle));
      },
    );
  }
}
```

## Complete Example

```dart
class EnterpriseBodySelector extends StatefulWidget {
  @override
  State<EnterpriseBodySelector> createState() => _EnterpriseBodySelectorState();
}

class _EnterpriseBodySelectorState extends State<EnterpriseBodySelector> {
  final controller = BodyMapController();

  @override
  void initState() {
    super.initState();
    
    // Set multi-select mode
    controller.setSelectionMode(SelectionMode.multi);
    
    // Disable injured muscles
    controller.setDisabledMuscles({
      Muscle.bicepsLeft, // Injured
    });
    
    // Set initial selection
    controller.setInitialSelection({
      Muscle.chestLeft,
      Muscle.chestRight,
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
        title: const Text('Enterprise Body Selector'),
        actions: [
          IconButton(
            icon: const Icon(Icons.flip),
            onPressed: controller.toggleView,
          ),
          IconButton(
            icon: const Icon(Icons.clear),
            onPressed: controller.clearSelection,
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
              // Body diagram
              Expanded(
                child: InteractiveBodySvg(
                  asset: controller.isFront
                      ? 'assets/svg/body_front.svg'
                      : 'assets/svg/body_back.svg',
                  selectedMuscles: controller.selectedMuscles,
                  disabledMuscles: controller.disabledMuscles,
                  onMuscleTap: controller.selectMuscle,
                  highlightColor: Colors.blue.withOpacity(0.6),
                  baseColor: Colors.white,
                  disabledColor: Colors.grey.withOpacity(0.5),
                  performanceMode: PerformanceMode.balanced,
                  hitTestBehavior: HitTestBehavior.precise,
                  tooltipBuilder: (muscle) => muscle.displayName,
                  semanticLabelBuilder: (muscle) => 
                      'Selected: ${muscle.displayName}',
                  onSelectAnimationBuilder: (context, child, muscle) {
                    return TweenAnimationBuilder<double>(
                      tween: Tween(begin: 1.0, end: 1.05),
                      duration: const Duration(milliseconds: 200),
                      builder: (context, value, child) {
                        return Transform.scale(scale: value, child: child);
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

## Summary

All features are designed to be:
- ✅ **Optional**: Use only what you need
- ✅ **Composable**: Mix and match features
- ✅ **Performant**: Optimized for production
- ✅ **Accessible**: Enterprise-grade accessibility
- ✅ **Flexible**: Works with any architecture
