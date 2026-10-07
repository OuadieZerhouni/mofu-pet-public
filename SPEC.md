# SPEC — Mofu

> The contract for v1.0. A feature is done when its acceptance criteria pass.
> Niche research: `research/niche-research/niche-scout/history/2026-10-06_rotation37-next-ouo-tokens.md`
> (the token `mofu` measured T84/D21 US, JP 84/35, DE 84/22, BR 79/23, SA 70/23 with no app embodying it).

## One line

Mofu is a round, ultra-fluffy little creature that lives on your iPhone. Pet it, brush it fluffier, squish it,
toss it and feed it snacks, and discover everything it can do.

## Audience & tone

Kawaii and cozy-game fans, teens to young adults, worldwide (US, JP, DE, BR, SA first). They open it many times a
day for a few seconds of comfort, sometimes to show a friend. The tone is soft, warm and playful. There are no
timers to fear, nothing to lose and no nagging. It is a sibling of **OuO cute pet**: same gentleness, a clearly
different character (a fluffy puffball with a body and fur, not a face).

## Screens

| Screen | Purpose | Entry |
| --- | --- | --- |
| Home (room) | Mofu lives here; every interaction happens on it | launch |
| Snack tray | pick a snack and drag it to Mofu | dock button |
| Wardrobe | fur colours and accessories, locked ones show how to earn them | dock button |
| Journal | discovered reactions (silhouettes + hints for the rest) | dock button |
| Settings | sound, haptics, rename, links, version | gear (top) |
| First run | Mofu hatches out of a fluff seed and the user names it | first launch only |

## Features

### F1 — The fluffy creature (rendering + life)

A procedurally drawn puffball: hundreds of fur strands around a soft body, big shiny eyes, a tiny mouth and blush.
It breathes, blinks, looks around, follows the finger with its eyes, and hops now and then.

**Acceptance criteria**
- [x] Fur is drawn as individual strands whose length grows with the fluff level (visibly fluffier at 100 than at 0).
- [x] Idle life: breathing scale, blink every 2.5–6 s, a glance or hop every 6–14 s.
- [x] When a finger is down near Mofu, its pupils track the finger.
- [x] Holds 60 fps on the home screen. A 600-strand render stays under 8 ms per frame in the profile test.
- [x] Reduce Motion: hops and screen-wide bounces are disabled; breathing and blinking remain.

### F2 — Touch interactions

**Acceptance criteria**
- [x] **Tap** → squash-and-stretch boing, a squeak and a happy face.
- [x] **5+ taps within 1.5 s** → a giggle fit ("tickle").
- [x] **Stroke/pet** (a drag across the body without holding first) → fur bends along the stroke, eyes close happily,
      a purr plays while stroking, hearts float up, fluff rises.
- [x] **Hold still for 0.45 s** → squish (flattens like mochi). **Keep holding 1.6 s** → hug (blush, hearts).
- [x] **Hold, then move** → pick Mofu up. **Release** → it falls with gravity, bounces off the walls and floor, and lands
      with a squish. A fast throw makes it dizzy.
- [x] **Double-tap an eye** → protest face (><).
- [x] **Shake the phone** → dizzy face and messy fur (strands frizz), which brushing fixes.
- [x] Every interaction gives a light haptic when haptics are on.

### F3 — Brush & fluff growth

**Acceptance criteria**
- [x] A brush tool (dock) turns strokes into brushing: sparkles follow the brush, messy fur becomes smooth, and fluff
      rises faster than petting. A soft brushing sound plays.
- [x] Fluff level 0–100 is persisted. Milestones at 25/50/75/100 play a celebration and unlock an item (see F5).
- [x] Fluff never decreases while the app is closed, so there is no punishment for absence.
- [ ] Daily brush: the first brush of each local day gives a sparkle burst and counts a "fluffy day".

### F4 — Snacks

**Acceptance criteria**
- [ ] Snack tray with 6 snacks (mochi, strawberry, dango, cookie, onigiri, star candy).
- [x] Dragging a snack onto Mofu's mouth area feeds it: mouth opens, chews, cheeks puff, happy. Dropping it elsewhere
      returns it to the tray.
- [x] Each Mofu has one favourite snack, derived deterministically from its name, which gets a special reaction.
- [ ] After 6 snacks within a rolling hour Mofu is full: it pats its belly and declines politely. This is a
      discoverable reaction, not a lock.

### F5 — Wardrobe (fur colours & accessories, all free)

**Acceptance criteria**
- [ ] 10 fur colours and 10 accessories. Locked items show the exact unlock condition (fluffy days, fluff milestone,
      journal count).
- [x] Selecting a colour or accessory updates Mofu instantly and persists.
- [x] A newly unlocked item shows a "New!" dot until viewed.

### F6 — Journal of reactions

**Acceptance criteria**
- [x] 24 discoverable reactions, each with an icon, a name and a one-line hint. Undiscovered ones are shown as
      silhouettes with the hint only.
- [x] Discovering one shows a small toast ("New! Tickle fit") and persists.

### F7 — Day & night

**Acceptance criteria**
- [x] The room colours follow local time (morning / day / evening / night).
- [x] At night (22:00–06:00), or after 45 s without touch, Mofu dozes off (closed eyes, slow breathing, zzz, soft snore).
      A tap wakes it with a sleepy blink.

### F8 — First run

**Acceptance criteria**
- [x] A fluff seed wobbles, then a tap hatches it into Mofu.
- [x] The user can name Mofu (1–16 chars, default "Mofu") or skip. The name shows in the header and Settings.
- [x] A one-time coach hint ("Pet me!") appears until the first stroke.

### F9 — Remote config (GitHub-hosted JSON, no Firebase)

**Acceptance criteria**
- [ ] Fetched from `raw.githubusercontent.com/OuadieZerhouni/app-configs/main/mofu-pet/config.json` in the background
      (6 s timeout), cached, and never blocking launch.
- [ ] Supports: min/latest version and update URL, a one-time announcement, feature kill-switches (shake, toss,
      sounds), a seasonal accessory window, links, and reserved `ads`/`iap` flags (read, never acted on in v1).
- [ ] Malformed values fall back to code defaults; a test covers every section.

### F10 — Settings

**Acceptance criteria**
- [x] Sound on/off and haptics on/off, both persisted.
- [x] Rename, privacy policy link, support link, app version.
- [x] Reset Mofu (with confirmation) clears every persisted key.

All features work in every locale in `app.yaml` (en, ja, de, pt, es, fr, ar), with Arabic laid out right-to-left.

## Non-goals (v1.0)

Home-screen widget (v1.1), ads, in-app purchases, accounts, cloud sync, notifications, multiple Mofus at once,
AR, voice lines.

## Data & permissions

- Local only (SharedPreferences): name, colour, accessory, fluff, discovered reactions, unlocks, visit days, settings.
- Network: one GET for the public remote-config JSON. No analytics, no tracking, no accounts.
- Permissions: none. The accelerometer needs no permission. No microphone, no camera, no notifications.
- App Privacy: **Data Not Collected**.

## Monetization

None in v1. Reserved remote flags (`ads.enabled`, `iap.enabled`) are read and ignored until a later version ships code for them.

## Store

- Category: Entertainment (primary). Final choice comes from the ASO report.
- Age rating: 4+ (no violence, gambling or UGC).
- Keyword seeds: mofu, mofumofu, fluffy, fluffy pet, cute pet, kawaii, virtual pet, squishy, plush, relax.
- Privacy policy and support: `app-configs/mofu-pet/PRIVACY.md` and `SUPPORT.md` (public repo).
