# Mofu & Friends — Cute Pet House

A cozy little house of cute pets: Mofu the fluffy cloud, Oink the piglet, Wuff
the puppy and a family of jelly Boops. Six rooms (living room, ASMR spa, kitchen,
bedroom with a sleep-sound mixer, playroom with two mini-games, garden with the
egg hatchery and photo booth), dress-up and a reaction journal. iOS first,
Flutter, no account, no ads, no purchases, no data collected.

Oink, Boop! and Wuff were separate apps until the 2026-10-16 App Review rejection
(4.3 spam); they now live here as characters. See `docs/APP_REVIEW_REPLY.md`.

| | |
| --- | --- |
| Bundle id | `com.ouadieZerhouni.mofuPet` |
| Store name | **Mofu: Cute Pet House** (was `Mofu: Fluffy Pet`; `Mofu` alone is taken) |
| Platforms | iPhone only, portrait, iOS 13+ |
| Languages | en · ja · de · pt · es · fr · ar (RTL) |
| Remote config | [`app-configs/mofu-pet/config.json`](https://raw.githubusercontent.com/OuadieZerhouni/app-configs/main/mofu-pet/config.json) — see `docs/REMOTE_CONFIG.md` |
| Spec | `SPEC.md` v2 (flagship features F1–F13, 4.3 rationale, architecture) |
| ASO | **`ASO/ASO.md`** (copy-paste listing, 8 store locales) + `ASO/metadata.json`, `ASO/screenshots/` |
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
python tools/audio/synth_sfx.py          # synthesized Mofu sound effects -> assets/sounds/
python tools/audio/synth_ambience.py     # fallback ambience loops (shipped rain/fire/ocean/purr + spa loops
                                         # are Stable Audio, see tools/art/prompts.json)
flutter test test/icon_flagship_test.dart --run-skipped   # icon candidates -> build/icon/flagship/
python tools/icon/make_icons.py          # app icon set from build/icon/icon_1024.png
python tools/l10n/translations.py && flutter gen-l10n
python tools/aso/metadata.py             # ASO/metadata.json + ASO/ASO.md, validated against store limits
flutter test test/store_screenshots_test.dart --run-skipped && python tools/screenshots/compose.py
flutter test test/ux_dump_test.dart --run-skipped --dart-define=LANGS=en,ar   # visual QA renders -> build/ux/
```

## How it is built

- `lib/creatures/` — one `Creature` interface (pure-Dart simulation + `CreatureArt`
  painter) and four species: `mofu/` (adapter over `lib/sim/mofu_sim.dart`, ~800
  painted fur strands), `oink/`, `wuff/` (tricks), `boop/` (12 variants). Every
  species passes `test/creatures/contract.dart`.
- `lib/world/` — `RoomScene` (several friends per room: pointer routing, crowd
  scaling, separation, landings, nuzzles), `HouseController` (rooms, events →
  audio/haptics/stars/xp/journal), `SpaSession` (foam → rinse → towel → dry).
- `lib/model/house_store.dart` — the household in one JSON blob (`mofu.house.v2`,
  migrates the v1 save): friends, stars with daily caps, friendship levels, egg
  schedule, feeding limits, gift streak, settings. `wardrobe.dart` — outfits.
- `lib/ui/house/` — the house screen, six room modules, friend card, photo booth,
  settings; `lib/ui/games/` — Boop Rush and Snack Catch.
- `lib/audio/` — `AudioEngine` (`flutter_soloud`; ambient session that never stops
  the user's music, switching to playback only for the sleep mixer) and `SoundBank`.
