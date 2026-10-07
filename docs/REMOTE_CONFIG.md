# Remote config

The authoritative schema for this app's remote config blob. Read before adding
a key.

## The four-file convention

| File | Role |
| --- | --- |
| `remote_config_current.json` | Snapshot of what is **live** right now |
| `remote_config_proposed.json` | Changes staged for the next push |
| `remote_config_template.json` | Every key with a safe default and a comment |

Keeping `current` in the repo is what makes "what is live?" answerable without
opening a console — and reviewable in a diff. Validate JSON after every edit;
a malformed blob degrades to code defaults silently, which looks like the
feature never shipped.

## Rules

- **Config tunes behaviour; it never invents it.** A flag may change a number,
  a probability, or a phrase list. It must not be able to request behaviour the
  app has no code for.
- **Every key has a code default** that is safe on its own, because the very
  first launch on a new install has no fetched config yet.
- **Kill switches default to off.** A feature ships dark and is enabled
  deliberately, per platform if needed.
- Malformed values clamp or fall back; they never crash. One test per config
  section asserts this.

## Sections

_(Add one `##` block per section as the app grows## Where it lives

Public, unauthenticated, never secret:
`https://raw.githubusercontent.com/OuadieZerhouni/app-configs/main/mofu-pet/config.json`
(repo `OuadieZerhouni/app-configs`, folder `mofu-pet/`, beside `PRIVACY.md` and
`SUPPORT.md`). To change what is live: edit `remote_config_proposed.json`, copy it
over `config.json` in that repo, push, then copy it to `remote_config_current.json`
here. Nothing secret ever goes in that repo — it is public.

How the app reads it (`lib/core/remote_config.dart`): the last good blob is
cached in `SharedPreferences` and applied at launch; a background fetch (6 s
timeout, a 10-minute cache-buster query so the raw CDN cannot pin a stale copy)
replaces it. Launch never waits on the network, and a failed or malformed fetch
keeps the cached or built-in values.

## Sections

Every key is optional. Wrong types fall back to the code default per field,
never per blob.

### Versions

| Key | Type | Default | Notes |
| --- | --- | --- | --- |
| `schemaVersion` | int | `1` | Bump only on a breaking shape change. |
| `minSupportedVersion` | `x.y.z` | `1.0.0` | Below this, a blocking "update needed" dialog — **only if `updateUrlIos` is set**. |
| `latestVersion` | `x.y.z` | `1.0.0` | Below this, a dismissible "update available" dialog (same condition). |
| `updateUrlIos` | https URL | `""` | The App Store link. Empty disables both dialogs, so a typo can never lock users out of an app they cannot update. Non-https values are ignored. |

### `announcement`

`{enabled, id, title: {en, ja, …}, body: {…}, url}`. Shown once per `id`
(remembered on device). Needs `enabled: true` **and** a non-empty `id`. Text
falls back to `en`, then any language present. `url` must be https or is dropped.

### `features`

| Key | Default | Effect when `false` |
| --- | --- | --- |
| `shake` | `true` | Shaking the phone does nothing. |
| `toss` | `true` | Mofu cannot be picked up or thrown (squish and hug still work). |
| `sounds` | `true` | All sound off regardless of the user's switch (haptics unaffected). |

These are kill switches for a v1 that ships them **on**: they exist so a bad
interaction can be turned off without a release.

### `seasons`

List of `{id, start: "MM-DD", end: "MM-DD"}`; windows may wrap the year
(`12-15` → `01-06`). Only ids the code knows (`halloween` → witch hat,
`winter` → santa hat) can award anything — config moves the dates, it cannot
invent an item. An open window awards its accessory once, on the first visit
inside it, and it is kept forever. Missing list = the code defaults
(halloween `10-20…11-02`, winter `12-15…01-06`); an empty list = no seasons.

### `reviewPrompt`, `ads`, `iap`

Reserved, all `{enabled: false}`. v1 has **no** review prompt, ads or purchases;
these keys exist so a later version can ship them dark and enable them here.
Setting them `true` on v1 does nothing — there is no code behind them.

### `links`

| Key | Default |
| --- | --- |
| `privacyPolicy` | `…/app-configs/blob/main/mofu-pet/PRIVACY.md` |
| `support` | `…/app-configs/blob/main/mofu-pet/SUPPORT.md` |
| `appStore` | `""` — set after release; the Settings "Rate Mofu" row only appears when this is non-empty. |

All must be https or they are ignored.

## After the first release

1. Put the App Store URL (`https://apps.apple.com/app/id<APPLE_ID>`) in both
   `updateUrlIos` and `links.appStore`.
2. From then on, raise `latestVersion` after each release to nudge updates, and
   `minSupportedVersion` only for a version that is genuinely broken.
