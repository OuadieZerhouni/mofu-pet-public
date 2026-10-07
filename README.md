# Mofu — Fluffy Pet

A round, very fluffy little creature that lives on your phone. Pet it, tickle
it, squish it, toss it, brush it until it is a cloud, feed it snacks, dress it
up, and tuck it in at night. iOS first, Flutter, no account, no ads, no
purchases, no data collected.

| | |
| --- | --- |
| Bundle id | `com.ouadieZerhouni.mofuPet` |
| Store name | **Mofu: Fluffy Pet** (`Mofu` alone is taken on the App Store) |
| Platforms | iPhone only, portrait, iOS 13+ |
| Languages | en · ja · de · pt · es · fr · ar (RTL) |
| Remote config | [`app-configs/mofu-pet/config.json`](https://raw.githubusercontent.com/OuadieZerhouni/app-configs/main/mofu-pet/config.json) — see `docs/REMOTE_CONFIG.md` |
| Spec | `SPEC.md` (features F1–F10 with acceptance criteria) |
| ASO | `ASO/metadata.json` (8 store locales), `ASO/screenshots/` |
| Owner steps | `owner-todo.md` |

## Run

```bash
flutter pub get
flutter gen-l10n
flutter analyze
flutter test
flutter run                      # device or simulator
flutter run -d web-server --web-port=8684   # quick look in a browser (no sound/haptics)
```

## Regenerate assets

```bash
python tools/audio/synth_sfx.py          # 21 sound effects + 3 loops -> assets/sounds/
python tools/icon/make_icons.py          # app icon set from build/icon/icon_1024.png
python tools/l10n/translations.py && flutter gen-l10n
python tools/aso/metadata.py             # ASO/metadata.json, validated against store limits
flutter test test/store_screenshots_test.dart --run-skipped && python tools/screenshots/compose.py
```

## How it is built

- `lib/sim/mofu_sim.dart` — the creature: pure-Dart physics and gesture
  recognition (tap, tickle, eye-poke, hold → squish → hug, pick-up and throw,
  stroke → fur bend, brush, spin), sleep/wake, eating, particles. No Flutter
  imports, so every interaction is unit-tested.
- `lib/ui/mofu_painter.dart` — ~800 fur strands in three layers, face,
  13 accessories, particles. Everything is drawn; there are no image assets.
- `lib/model/` — catalogue (10 furs, 13 accessories, 6 snacks, 24 reactions)
  and `PetStore` (one JSON blob in `SharedPreferences`, debounced saves).
- `lib/core/` — remote config, sound (`flutter_soloud`, ambient session that
  never stops the user's music), app services.
