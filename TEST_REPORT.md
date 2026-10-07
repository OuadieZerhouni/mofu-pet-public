# Test drive — Mofu 1.0.0+1 · 2026-10-07 15:42
iPhone 17 Pro sim (iOS 26.5) · Xcode 27.0 · build 23s (failed) · commit c4fdb54 · seams: DEBUG_SKIP_ADS

PASS 0 · FAIL 1 · BLOCKED 37 · SKIP 0   (of 37 criteria + F0)

| Criterion | Verdict | Evidence | Note |
| --- | --- | --- | --- |
| F0 builds | FAIL | test-drive/20261007-1542/F0-build.log | expected a simulator build; observed `error: The iOS Simulator deployment target 'IPHONEOS_DEPLOYMENT_TARGET' is set to 13.0, but the range of supported deployment target versions is 15.0 to 27.0.x.` in targets Runner, Pods-Runner and Flutter |
| F1-c1 Fur is drawn as individual strands whose length grows with the fluff l… | BLOCKED | | F0 build failed |
| F1-c2 Idle life: breathing scale, blink every 2.5–6 s, a glance or hop every… | BLOCKED | | F0 build failed |
| F1-c3 When a finger is down near Mofu, its pupils track the finger. | BLOCKED | | F0 build failed |
| F1-c4 Holds 60 fps on the home screen. A 600-strand render stays under 8 ms … | BLOCKED | | F0 build failed |
| F1-c5 Reduce Motion: hops and screen-wide bounces are disabled; breathing an… | BLOCKED | | F0 build failed |
| F2-c1 Tap → squash-and-stretch boing, a squeak and a happy face. | BLOCKED | | F0 build failed |
| F2-c2 5+ taps within 1.5 s → a giggle fit ("tickle"). | BLOCKED | | F0 build failed |
| F2-c3 Stroke/pet (a drag across the body without holding first) → fur bends … | BLOCKED | | F0 build failed |
| F2-c4 Hold still for 0.45 s → squish (flattens like mochi). Keep holding 1.6… | BLOCKED | | F0 build failed |
| F2-c5 Hold, then move → pick Mofu up. Release → it falls with gravity, bounc… | BLOCKED | | F0 build failed |
| F2-c6 Double-tap an eye → protest face (><). | BLOCKED | | F0 build failed |
| F2-c7 Shake the phone → dizzy face and messy fur (strands frizz), which brus… | BLOCKED | | F0 build failed |
| F2-c8 Every interaction gives a light haptic when haptics are on. | BLOCKED | | F0 build failed |
| F3-c1 A brush tool (dock) turns strokes into brushing: sparkles follow the b… | BLOCKED | | F0 build failed |
| F3-c2 Fluff level 0–100 is persisted. Milestones at 25/50/75/100 play a cele… | BLOCKED | | F0 build failed |
| F3-c3 Fluff never decreases while the app is closed, so there is no punishme… | BLOCKED | | F0 build failed |
| F3-c4 Daily brush: the first brush of each local day gives a sparkle burst, … | BLOCKED | | F0 build failed |
| F4-c1 Snack tray with 6 snacks (strawberry, dango, cookie, onigiri, pudding,… | BLOCKED | | F0 build failed |
| F4-c2 Dragging a snack onto Mofu's mouth area feeds it: mouth opens, chews, … | BLOCKED | | F0 build failed |
| F4-c3 Each Mofu has one favourite snack, derived deterministically from its … | BLOCKED | | F0 build failed |
| F4-c4 After 6 snacks within a rolling hour Mofu is full: it shakes its head … | BLOCKED | | F0 build failed |
| F5-c1 10 fur colours and 10 accessories. Locked items show the exact unlock … | BLOCKED | | F0 build failed |
| F5-c2 Selecting a colour or accessory updates Mofu instantly and persists. | BLOCKED | | F0 build failed |
| F5-c3 A newly unlocked item shows a "New!" dot until viewed. | BLOCKED | | F0 build failed |
| F6-c1 24 discoverable reactions, each with an icon, a name and a one-line hi… | BLOCKED | | F0 build failed |
| F6-c2 Discovering one shows a small toast ("New! Tickle fit") and persists. | BLOCKED | | F0 build failed |
| F7-c1 The room colours follow local time (morning / day / evening / night). | BLOCKED | | F0 build failed |
| F7-c2 At night (22:00–06:00), or after 45 s without touch, Mofu dozes off (c… | BLOCKED | | F0 build failed |
| F8-c1 A fluff seed wobbles, then a tap hatches it into Mofu. | BLOCKED | | F0 build failed |
| F8-c2 The user can name Mofu (1–16 chars, default "Mofu") or skip. The name … | BLOCKED | | F0 build failed |
| F8-c3 A one-time coach hint ("Pet me!") appears until the first stroke. | BLOCKED | | F0 build failed |
| F9-c1 Fetched from `raw.githubusercontent.com/OuadieZerhouni/app-configs/mai… | BLOCKED | | F0 build failed |
| F9-c2 Supports: min/latest version and update URL, a one-time announcement, … | BLOCKED | | F0 build failed |
| F9-c3 Malformed values fall back to code defaults; a test covers every secti… | BLOCKED | | F0 build failed |
| F10-c1 Sound on/off and haptics on/off, both persisted. | BLOCKED | | F0 build failed |
| F10-c2 Rename, privacy policy link, support link, app version. | BLOCKED | | F0 build failed |
| F10-c3 Reset Mofu (with confirmation) clears every persisted key. | BLOCKED | | F0 build failed |

## Regressions

None: there is no earlier committed report.

## Findings

- **No behaviour trace seam.** `debug_flags.dart` has no `DEBUG_GESTURE_TRACE` (or equivalent), and `DEBUG_INSPECTOR`
  is declared but never read. Timer-driven criteria (F1-c2 blink/glance/hop, F7-c2 doze after 45 s) therefore
  cannot be read from the device log, only from mistimeable screenshots.
- Flutter warns that every iOS plugin is a Swift Package while the project still integrates CocoaPods
  (non-standard Podfile). This does not block the build; it is noted for build time.

## Next for /build

| F0 builds | FAIL | test-drive/20261007-1542/F0-build.log | expected a simulator build; observed `IPHONEOS_DEPLOYMENT_TARGET` 13.0 rejected by Xcode 27 (supported 15.0–27.0.x) in Runner, Pods-Runner, Flutter |
