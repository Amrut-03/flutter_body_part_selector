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
  widget_test.dart   # Smoke test verifying initial UI renders
```

The app is a **single-screen demo** with the state class managing a `BodyMapController` instance. UI sections are split into private widget classes for maintainability:

- `_ViewToggleBar` — front/toggle/back buttons
- `_SelectionInfoBar` — selected/disabled counts + view indicator
- `_MuscleTabSection` — tabbed list of selected and disabled muscles (with empty states)

## Known Package Limitations

The `flutter_body_part_selector` package has missing API methods. Workarounds are documented in `AGENTS.md`. Key points:

- No `toggleMuscle()` or `deselectMuscle()` — use clear-and-reselect pattern
- `selectedMuscles` is read-only — use computed getters from controller
- No initialization constructor — create empty controller and select programmatically

## Getting Started

```bash
flutter pub get
flutter run
flutter analyze
flutter test
```
