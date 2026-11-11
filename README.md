# body_selector_app

An interactive body part / muscle selector demo app built with the [`flutter_body_part_selector`](https://pub.dev/packages/flutter_body_part_selector) package and Flutter.

## Features

- **Body map selection**: Tap muscles on front/back body SVG to toggle selection
- **Disable muscles**: Long-press to disable a muscle (greyed out, non-tappable)
- **Dual lists**: Tab-based list views for selected and disabled muscles
- **View toggle**: Front view, back view, and toggle button controls
- **Select all / Clear all**: FAB and app bar action for bulk operations
- **Animations & tooltips**: Configurable via state (demo showcases customization props)

## Architecture

```
lib/
  main.dart          # App shell, screen, controller wiring, extracted widget classes
test/
  body_map_controller_test.dart  # Unit tests pinning the controller behaviour the app relies on
  widget_test.dart               # Widget tests: select all, clear, deselect, disable/enable, view switching
```

Uses `flutter_body_part_selector` **^1.2.1**.

## Versioning

This demo app and the `flutter_body_part_selector` package are versioned **independently**:

| | Version | Where it's set | What it tracks |
|---|---|---|---|
| Demo app (`body_selector_app`) | 2.0.0 | `pubspec.yaml` → `version`, `CHANGELOG.md` | Changes to this demo |
| Package (`flutter_body_part_selector`) | 1.2.1 | `pubspec.yaml` → `dependencies`, [pub.dev](https://pub.dev/packages/flutter_body_part_selector/changelog) | The selector widget and controller |

The app's 2.0.0 does not mean it targets a package 2.x. To see the package version actually in use, check `flutter_body_part_selector` in `pubspec.lock`.

The app is a **single-screen demo** with the state class managing a `BodyMapController` instance. UI sections are split into private widget classes for maintainability:

- `_ViewToggleBar` — front/toggle/back buttons
- `_SelectionInfoBar` — selected/disabled counts + view indicator
- `_MuscleTabSection` — tabbed list of selected and disabled muscles (with empty states)

## Controller API Used

The app drives all state through `BodyMapController` (these methods are available since `flutter_body_part_selector` 1.1.3), with no workarounds:

| Action | Controller call |
|---|---|
| Tap a muscle on the map | `toggleMuscle(muscle)` |
| Deselect from the list | `deselectMuscle(muscle)` |
| Long-press / disable from the list | `disableMuscle(muscle)` (also removes it from the selection) / `enableMuscle(muscle)` |
| Select All (FAB) | `selectMultiple(Muscle.values.toSet())` (skips disabled muscles, one notification) |
| Clear All (app bar) | `clearSelection()` |
| Front / Back / Toggle | `setFrontView()` / `setBackView()` / `toggleView()` |

The controller also supports `selectedMuscles = {...}` (setter), `setSelectedMuscles`, `setDisabledMuscles`, `isSelected`, `isDisabled`, and an initial-state constructor:

```dart
BodyMapController(
  initialSelectedMuscles: {Muscle.bicepsLeft},
  initialDisabledMuscles: {Muscle.chestLeft},
  initialIsFront: true,
);
```

## Getting Started

```bash
flutter pub get
flutter run
flutter analyze
flutter test
```
