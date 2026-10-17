# SPEC v2 — Mofu & Friends (flagship)

> The contract for v1.0 (second submission). A feature is done when its acceptance criteria pass.
> **Why v2 exists:** on 2026-10-16 Apple rejected Mofu, Oink and Boop! together under **4.3 Spam (a)(b)** and
> **4.2.6 App Generation Services**, asking whether each app "could be delivered as an in-app purchase or
> content addition within another app on your account" and whether the binaries share code. Answer: yes, so
> they become **one app**. Oink, Boop! and Wuff are **not** resubmitted; their creatures live here.
> Niche research for the `mofu` token: `research/niche-research/niche-scout/history/2026-10-06_rotation37-next-ouo-tokens.md`.

## One line

A cozy pocket house where four kinds of very touchable creatures live together. Groom them in an ASMR spa,
feed them, play, hatch new friends, tuck them in with sleep sounds, and snap photos of the gang.

## Why this is not spam (the 4.3 / 4.2.6 bar, checked at every milestone)

1. **One app, not a family of clones.** All creatures and mechanics from four prototypes are merged into one
   product with depth (rooms, hatching, friendship, spa, sleep sounds, mini-games, photo booth).
2. **Its own look.** A new UI system (no header-card + 4-button dock + wardrobe grid template): a swipeable
   house of illustrated rooms, a friend bar, room-specific tool trays and paper-craft UI. Designed on the Claude
   Design canvas first.
3. **Signature mechanics no sibling has:** a multi-step ASMR spa (foam → rinse → towel → blow-dry),
   creatures that interact with each other, a sleep-sound mixer with timer, a hatchery, and a photo booth.
4. **Built by the content owner.** Every creature, sound and room is original work by the developer.
5. **Not OuO / Neko:** those are single reaction faces. This is a household of full-bodied creatures with
   care rooms and progression.

## Audience & tone

Cozy-game and kawaii fans, teens to adults, plus parents handing the phone to a child (4+, **not** in the
Kids category). Short sessions many times a day, plus a long session at bedtime (the sleep mixer). Tone: soft,
warm and playful. Nothing dies, nothing decays to sadness, and there is no nagging. Markets: US, JP, DE, BR, SA,
MX and FR, in 7 languages with Arabic right-to-left.

## The friends (species)

| Species | Body | Signature touch (ASMR) | Unlock |
| --- | --- | --- | --- |
| **Mofu** (fluff puff) | strand fur that grows | brushing makes it fluffier; squish, hug, toss | start |
| **Oink** (piglet) | soft round pig | belly rub (legs kick, giggle), snout boop "oink", mud splash in spa | hatch, 40 ★ |
| **Wuff** (puppy) | sitting pup, floppy ears, wagging tail | ear scratch (leg thump), tricks (sit, paw, spin), barks | hatch, 90 ★ |
| **Boops** (snoot critters, 12 variants) | soft-body jelly | snoot boop combos, sneeze at 30 | first at 150 ★, then each variant 60 ★ |

Each species keeps its own physics, face set, reactions and sounds (ported from its prototype), behind one
`Creature` interface.

## Rooms (swipe left/right; the house is the home screen)

| Room | What you do |
| --- | --- |
| **Living room** | Free play: touch, squish, toss friends onto each other, ball toy, friends interact |
| **Spa** (signature) | Foam → rinse → towel → blow-dry, per friend, step by step with ASMR sound and haptics |
| **Kitchen** | Drag snacks to mouths; each species has its own menu and a secret favourite |
| **Bedroom** | Tuck friends into bed (cuddle pile), night light, **sleep-sound mixer** with a timer |
| **Playroom** | Mini-games: **Boop Rush** (30 s) and **Snack Catch** (45 s) |
| **Garden** | **Hatchery** (eggs → new friends), daily gift, photo booth entry |

## Features

### F1 — The house and rooms
**Acceptance criteria**
- [ ] Horizontal paging between six rooms with parallax layers (back wall, furniture, foreground). The room
      name and dots show the position, and the last room is restored on launch.
- [ ] Each room has day, evening and night lighting from the clock (night 22–6) with a smooth transition.
- [ ] Rooms render at 60 fps on an iPhone 11 class device (particle and strand caps enforced in code).

### F2 — Friends and the friend bar
- [ ] Up to 4 friends are in the active room. A friend bar (bottom) shows every hatched friend. Drag a friend's
      chip into the room to bring them, or out of it to send them away.
- [ ] Friends stand on the room floor without overlapping (soft separation), idle (breathe, blink, look, hop),
      and turn to look at whichever friend is being touched.
- [ ] Group behaviours: toss one friend onto another and both react; idle friends occasionally boop or nuzzle a
      neighbour; at night idle friends gather into a cuddle pile.

### F3 — Signature touch per species
- [ ] Mofu: everything in Mofu v1 (tap boing, tickle, eye poke, squish → hug, pick up and toss, stroke purr,
      spin, brush mode with fluff growth and tidy).
- [ ] Oink: snout boop (6 oinks), belly rub (giggle and kicking legs), ear flop, tail spin.
- [ ] Wuff: ear scratch (leg thump), chin scratch, nose boop, tricks from the friend card (sit, paw, spin,
      speak, play dead, high five), barks.
- [ ] Boops: boop combos (pitch rises, tier banners at 10, 25 and 50, sneeze every 30), squash and stretch, hug.
- [ ] Every interaction has visible + haptic (+ sound) feedback within 100 ms.

### F4 — ASMR Spa
- [ ] Put one friend on the spa mat. Four steps with a progress ribbon: **Foam** (rubbing builds foam blobs that
      stick, wobble and pop into bubbles), **Rinse** (drag the shower head: water streaks, foam slides off),
      **Towel** (rub until dry; damp-fur look fades), **Blow-dry** (drag the dryer: fur or ears flutter, Mofu
      gains fluff).
- [ ] Each step has its own looping ASMR sound that follows the finger's speed, plus haptic ticks.
- [ ] Finishing all four gives a sparkle shine, +★, and a "Fresh!" reaction. Oink can be muddy first
      (mud splats appear after the garden) and the foam step removes them.

### F5 — Kitchen
- [ ] A species-specific snack tray (Mofu sweets, Oink fruit and veg, Wuff treats, Boops berries). Drag to a
      mouth: chew animation, crumbs, munch sound. The favourite (hashed from the name) gets hearts and a jingle.
- [ ] Six snacks per friend per hour, then "full" (polite head shake). No hunger decay; feeding is a reward, not a chore.

### F6 — Bedroom and sleep sounds
- [ ] Drag friends onto the bed; they curl up, breathe slowly and snore softly. Tap to wake gently.
- [ ] Sleep-sound mixer: rain, purr, fireplace, ocean, wind chimes and soft noise, each with its own volume,
      seamless loops, master fade-out timer (15 / 30 / 60 min / off). Audio keeps playing with the screen locked
      (iOS background audio) and pauses on interruptions (calls, other apps).
- [ ] Night light dims the room; tapping the lamp toggles it.

### F7 — Playroom mini-games
- [ ] **Boop Rush:** 30 s, critters pop up on a 3×3 board. Boop them (+1, golden +5); a sleeping one is −1.
      Best score saved. Pays ★ = score ÷ 5, capped per day.
- [ ] **Snack Catch:** 45 s, drag a friend left and right to catch falling snacks and dodge bees. Best score
      saved. Pays ★ = score ÷ 4, capped per day.
- [ ] Both: a countdown, pause on background, results card with best score and ★ earned.

### F8 — Stars, friendship, hatchery
- [ ] ★ (fluff stars) are earned by care (first touch of the day per friend, spa completion, feeding the
      favourite, mini-games, daily gift with a streak up to 7). Daily caps keep it calm. Never purchasable in v1.
- [ ] Each friend has a friendship level (hearts 1–10) raised by care. Levels unlock outfits and reactions.
- [ ] Hatchery: an egg becomes available at the ★ thresholds in the species table. Tapping it in the garden
      runs a hatch sequence (wobble, crack, pop, naming dialog), and the friend joins the friend bar.

### F9 — Wardrobe
- [ ] Shared accessories (hats, bows, glasses, scarves, headphones, crowns, seasonal) with per-species anchor
      points, plus species coats/colours (Mofu furs, Wuff coats, Oink tints, Boop variants). Locked items say
      how to unlock them (hearts, ★ milestone, season).

### F10 — Photo booth
- [ ] Pick a backdrop and up to 4 friends, drag them into place, add stickers, then share a 1080×1350 image via
      the system share sheet. No photo-library permission is needed.

### F11 — Journal
- [ ] Per-species discovered reactions (≥ 60 in total) with silhouettes and hints, friend profiles (name,
      hatch day, favourite snack, friendship level), and best mini-game scores.

### F12 — First run
- [ ] A fluff seed in the garden, tap to hatch Mofu, name it, then a three-step coach (touch, swipe rooms, spa)
      that can be skipped. First delight in ≤ 10 s.

### F13 — Settings, accessibility, platform
- [ ] Sound, haptics, reduce motion, rename friends, start over (confirmed), privacy, support, credits
      (incl. "Powered by Stability AI" if Stable Audio sounds ship), version.
- [ ] Semantics on every control and friend; Dynamic Type up to 1.3 without overflow; colour contrast AA.
- [ ] 7 languages (en, ja, de, pt, es, fr, ar RTL). Offline. No account, no ads, no purchases, no data
      collected. Remote config (GitHub JSON, safe defaults) can only tune existing behaviour.

## Look & feel (detailed on the Claude Design canvas "Mofu & Friends — UI design")

Paper-craft cozy: warm illustrated rooms with soft depth (contact shadows, ambient light, gentle bloom on
lights), creatures drawn procedurally with rim light and subsurface blush, UI as rounded "felt tags" and
trays that slide up from the floor. No emoji anywhere the user sees. Rounded type (Nunito, Baloo Bhaijaan 2
for Arabic).

## Architecture

- `lib/creatures/creature.dart`: the `Creature` interface (layout, pointers, update, events, hit-test,
  pose, look-at, state for spa and sleep) and `CreatureArt` (paint, accessories anchors, wet and foam overlays).
- One sim + painter per species under `lib/creatures/<species>/`, pure Dart sims unit-tested.
- `lib/world/`: house, rooms, multi-creature scene (separation, group behaviours), lighting.
- `lib/rooms/<room>/`: room logic + widgets (spa, kitchen, bedroom, playroom, garden).
- `lib/model/`: catalog, household store (friends, stars, friendship, unlocks), one JSON blob, migration
  from the v1 Mofu blob.
- `lib/audio/`: SFX + loops + sleep mixer (flutter_soloud, audio_session; background playback).
