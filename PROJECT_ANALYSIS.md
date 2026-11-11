# Project Analysis — body_selector_app

> Analysis date: 2026-11-11 · Commit: `fdb400c` · Flutter 3.47.7 (stable)

## Overview

A demo app for the `flutter_body_part_selector` package (it is **not** the package itself). It contains one Dart file (`lib/main.dart`, 531 lines), one smoke test, the standard platform folders, and four Markdown docs.

**Health check**

| Check | Result |
|---|---|
| `flutter analyze` | 9 info-level lints, no errors or warnings |
| `flutter test` | 1/1 passing |
| Locked package version | `flutter_body_part_selector` **1.1.3** (1.2.1 available) |

---

## Prioritized action plan

Every improvement and suggestion from this analysis, ranked. Details for each item are in the numbered sections below.

**Priority levels**
- **P0 – Fix now:** wrong behavior, dead code or docs that mislead readers.
- **P1 – Next:** protects against regressions and keeps the project current.
- **P2 – Polish:** cleaner code and small performance wins.
- **P3 – Optional:** housekeeping, or only matters if the app ships.

| # | Priority | Task | Where | Effort | Why | Details |
|---|---|---|---|---|---|---|
| 1 | **P0** | Delete the dead clear-and-reselect block in `_toggleDisabledMuscle`; keep just `disableMuscle` / `enableMuscle` | `lib/main.dart:84-97` | 2 min | The block never runs, and the CHANGELOG calls it a bug fix | §1 |
| 2 | **P0** | Replace the `_toggleMuscle` workaround with `_controller.toggleMuscle(muscle)` | `lib/main.dart:68-82` | 2 min | Each deselect currently fires N+1 notifications and rebuilds | §1 |
| 3 | **P0** | Replace `_selectAll` with `_controller.selectMultiple(Muscle.values.toSet())` | `lib/main.dart:251-260` | 2 min | The current code makes about 25 set copies (O(n²)) and juggles the listener | §1 |
| 4 | **P0** | Delete `FINAL_ISSUES_REPORT_V1.1.1.md` and `ISSUES_CHECK_V1.1.1.md`, or replace both with one correct note | repo root | 5 min | Both say APIs are missing that exist in 1.1.3 and 1.2.1, and they disagree on the version | §1, §3 |
| 5 | **P0** | Rewrite the README "Known Package Limitations" section and remove the `AGENTS.md` link | `README.md` | 5 min | The limitations are wrong and the link is broken (the file is gitignored and missing) | §3 |
| 6 | **P0** | Correct the 2.0.0 CHANGELOG entries for `_toggleDisabledMuscle` and `_selectAll` | `CHANGELOG.md` | 3 min | They describe fixes and batching that don't hold | §3 |
| 7 | **P1** | Add controller unit tests: toggle, deselect, disable-while-selected, select-all with disabled muscles, clear | `test/` | 30 min | The logic that drifted has no coverage. Ideally write these alongside items 1–3. | §5 |
| 8 | **P1** | Add widget tests for the list Disable / Deselect / Enable buttons, the FAB and the clear-all action | `test/widget_test.dart` | 30 min | The current test only checks static text | §5 |
| 9 | **P1** | Run `flutter pub upgrade` to move `flutter_body_part_selector` from 1.1.3 to 1.2.1, then re-run analyze and tests | `pubspec.lock` | 5 min | Stay on the latest release of your own package | §2 |
| 10 | **P1** | Fix the 9 `prefer_final_fields` lints: make the fields `final`/`const`, or add a settings sheet that changes them | `lib/main.dart:40-48` | 5 min (final) / 1–2 h (settings UI) | Gets the analyzer clean. A settings UI would match what the README promises. | §4 |
| 11 | **P2** | Replace `_getMuscleName` with `Muscle.displayName` and capitalize the first letter | `lib/main.dart:115` | 5 min | Removes duplicated logic and fixes lowercase labels ("biceps Left") | §4 |
| 12 | **P2** | Read the selected and disabled sets once per `build` and pass a `List` to the `ListView`s instead of calling `elementAt` | `lib/main.dart:34-35, 441, 488` | 10 min | Avoids about 6 set copies per build and O(n²) list building | §1, §4 |
| 13 | **P2** | Replace the manual `addListener` / `setState` wiring with `ListenableBuilder` | `lib/main.dart:50-66` | 15 min | Less boilerplate, and rebuilds are scoped to the widgets that need them | §4 |
| 14 | **P2** | Remove the redundant disabled-tap guard in `_toggleMuscle` | `lib/main.dart:69` | 1 min | The widget and controller already handle disabled taps | §1 |
| 15 | **P3** | Remove `cupertino_icons`, or bump it to 2.0.0 if you start using it | `pubspec.yaml` | 2 min | The dependency isn't used | §2 |
| 16 | **P3** | Clarify the app version vs. the package version in the README, or change the app version scheme | `pubspec.yaml`, `README.md` | 5 min | The app is 2.0.0 while the package is 1.x, which invites confusion | §2 |
| 17 | **P3** | Align naming: the directory, the pubspec name `body_selector_app` and the Android namespace `com.example.*` | `android/`, `ios/` | 30 min | Only matters if you publish the app; `com.example` can't go to the Play Store | §3 |

**Status (2026-11-11):** ✅ P0 items 1–6, ✅ P1 items 7–10 and ✅ P2 items 11–14 and ✅ P3 items 15–16 are done, none of it committed yet. Item 17 (app IDs and naming) is ⏸ **deferred** by choice: the app is a local demo that isn't published, so the `com.example.*` IDs stay until you decide to ship it. `flutter analyze` reports no issues, and `flutter test` passes all 19 tests (13 controller, 6 widget). Item 10 took the quick `final` option; the settings-UI alternative is still open. Upgrading to 1.2.1 (item 9) required removing the `baseColor` and `performanceMode` arguments, which 1.2.x dropped without a changelog note (see below).

### Found during P1: issues in the `flutter_body_part_selector` package itself

| Version | Issue |
|---|---|
| 1.2.x | `InteractiveBodySvg` dropped the `baseColor` parameter and the `PerformanceMode` enum in a minor release, and the package CHANGELOG doesn't mention either. Apps passing them stop compiling. |
| 1.2.x | The default `hitTestPadding` changed from `10.0` to `2.0`, which isn't in the CHANGELOG either. Apps that rely on the default get smaller tap targets. |
| 1.2.0 | The CHANGELOG says the `asset` parameter was removed, but the constructor still accepts it. |
| all | `InteractiveBodySvg` loads its SVG with `rootBundle.loadString` behind a `CircularProgressIndicator`. Under the widget-test clock the load never finishes, so `pumpAndSettle()` times out in any consuming app's tests. Document this, or let the SVG be injected for tests. |
| all | The `toggleMuscle` doc comment says it's an alias for `selectMuscle`. Because `selectMuscle` also toggles, its name is misleading, and the app's original clear-and-reselect workaround may have come from that confusion. |

**Fastest path:** items 1–6 together take about 20 minutes and fix everything that is wrong today. Items 7–10 take about an hour more and leave the project tested, lint-clean and on the latest package. Items 11–17 can wait.

---

## 1. Main problem: the docs list APIs as missing, but they exist

`README.md`, `FINAL_ISSUES_REPORT_V1.1.1.md` and `ISSUES_CHECK_V1.1.1.md` say `BodyMapController` has no `toggleMuscle()`, no `deselectMuscle()`, no `selectedMuscles` setter and no initial-state constructor.

The package source shows that **all of them exist in 1.1.3 (the locked version) and in 1.2.1 (the latest)**. The controller also has `selectMultiple`, `setSelectedMuscles`, `setDisabledMuscles` and `isSelected`. The constructor accepts `initialSelectedMuscles`, `initialDisabledMuscles` and `initialIsFront`.

So the workarounds in `lib/main.dart` aren't needed, and some of them make things worse:

| Location | Current code | Problem | Replace with |
|---|---|---|---|
| `lib/main.dart:68-82` `_toggleMuscle` | Clear the selection, then re-select all the others | Each deselect fires N+1 notifications and rebuilds. `selectMuscle` already toggles. | `_controller.toggleMuscle(muscle)` |
| `lib/main.dart:84-97` `_toggleDisabledMuscle` | Clear-and-reselect block after `disableMuscle` | **Dead code.** `disableMuscle` already removes the muscle from the selection, so the `contains` check is always false. | Delete the block |
| `lib/main.dart:251-260` `_selectAll` | Unhook the listener, loop with `contains`, hook it back | The CHANGELOG calls this an optimization. But each `_selectedMuscles` access is a getter that returns a new `Set.unmodifiable` copy, so the loop makes about 25 set copies (O(n²)). The listener juggling isn't needed. | `_controller.selectMultiple(Muscle.values.toSet())`: one notification, and disabled muscles are skipped for you |
| `lib/main.dart:69` | App-side guard for taps on disabled muscles | Harmless but redundant. The widget already sends disabled taps to `onMuscleTapDisabled`, and `selectMuscle` ignores disabled muscles. | Optional: remove |

**Computed getters:** the README tells you to "use computed getters because `selectedMuscles` is read-only", but there is a setter. As for the getters, `_selectedMuscles` and `_disabledMuscles` (`lib/main.dart:34-35`) build a new set on every access, and `build()` reads them about 6 times. That's cheap with 25 muscles, but cache them once per `build`.

---

## 2. Dependencies

- `flutter_body_part_selector: ^1.1.3` is locked at **1.1.3**. **1.2.1** is available within that constraint, so `flutter pub upgrade` will pick it up.
- `cupertino_icons` has 2.0.0 out. Nothing in `lib/` uses Cupertino icons, so you can probably remove it.
- The app is versioned `2.0.0+1` while the package is 1.x. Two "v2.0.0" labels for unrelated things could confuse people.

---

## 3. Documentation and repo hygiene

- `README.md` points readers to `AGENTS.md` for the workarounds, but `.gitignore` excludes `/AGENTS.md` and the file isn't on disk either. That link is broken for everyone.
- The two issue reports disagree on the package version. Their titles and body say "v1.1.1", while the header and lock file say 1.1.3. Both reports also overlap heavily and are wrong (see §1). Delete them or fold one correct version into the README.
- `CHANGELOG.md` says the `_toggleDisabledMuscle` bug was fixed, but the "fix" is the dead code above. It also describes the `_selectAll` change as batching, which is misleading.
- **Naming:** the directory is `flutter_body_part_selector`, the pubspec name is `body_selector_app`, and the Android namespace is `com.example.flutter_body_part_selector`. The `com.example` namespace can't go to the Play Store. That's fine for a demo, but rename it if you ever ship this.

---

## 4. Code quality (minor)

- **9 `prefer_final_fields` lints** (`lib/main.dart:40-48`). The "customization" fields are never changed because the app has no UI for them. Either make them `final`/`const`, or add a small settings sheet so the demo actually shows those props off, which is what the README promises.
- **`_getMuscleName`** (`lib/main.dart:115`) re-implements `Muscle.displayName` and produces the same lowercase-first output ("biceps Left", "lats Back Left"). Use `displayName`, and capitalize the first letter for display.
- **`selectedMuscles.elementAt(index)`** inside `ListView.builder` (`lib/main.dart:441`, `lib/main.dart:488`) walks the set on every item, which is O(n²). Convert the set to a list once per build.
- **Architecture:** all state lives in a `StatefulWidget` with a `ChangeNotifier` and `setState`. For a single-screen demo that's reasonable, and adding BLoC or Riverpod here would mostly hide how the package is meant to be used. A `ListenableBuilder` around the controller would remove the manual `addListener`/`setState` wiring.

---

## 5. Tests

The only test (`test/widget_test.dart`) checks static text. Nothing covers selecting, deselecting, disabling, select-all or clear-all, which is exactly the logic that drifted in §1. Add:

- Controller-level unit tests for toggle, deselect, disable-while-selected, select-all with disabled muscles, and clear.
- Widget tests that drive the tab list buttons (Disable / Deselect / Enable), FAB and app-bar clear action. The SVG itself is hard to hit-test.
