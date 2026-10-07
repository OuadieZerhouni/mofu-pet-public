# Release

```bash
$APP_FACTORY/.venv/bin/python $APP_FACTORY/tools/release.py ship --branch main
```

Or `/ship` in Claude Code, which adds the changelog and the go/no-go judgment.

## What runs before anything expensive

1. Working tree clean; branch pushed.
2. `flutter analyze` + `flutter test`.
3. `manifest_sync_test` — generated files still agree with `app.yaml`.
4. **Version-train check.** App Store Connect refuses any build whose
   `CFBundleShortVersionString` matches an already-approved version, whatever
   the build number (errors 90062 and 90186). Two 18-minute OuO builds were
   spent discovering that the hard way, so it is checked in seconds first.
5. Build number bumped; version name bumped only when the train is closed.

## What you will be asked for

Nothing, on a normal release. The export-compliance question is preempted by
`ITSAppUsesNonExemptEncryption` in `Info.plist`, so builds go straight to
processing instead of stopping at "Missing Compliance".

Gates appear in `owner-todo.md` when they are genuinely unavoidable — the first
build of a new app needs an identifier, an App Store Connect record, and a
Codemagic app.

## Mofu: first release checklist

1. Owner gates in `owner-todo.md` (bundle id, App Store Connect record, Codemagic app).
2. Codemagic workflow `testFlight` builds the IPA on a Mac and uploads to
   TestFlight. There is no Mac here: Codemagic is the only iOS build path.
3. Install from TestFlight on a real iPhone and run the device checklist in
   `owner-todo.md` (sound, haptics, shake — none of these exist on web or in tests).
4. App Store Connect listing: paste per-locale fields from `ASO/metadata.json`;
   upload `ASO/screenshots/<locale>/*.png` (6.9" only — Apple scales it down).
5. App Privacy: **Data Not Collected**. Age rating: 4+, no objectionable content.
6. After approval: set `app_store_id` in `app.yaml`, and the store URL in remote
   config (`docs/REMOTE_CONFIG.md` → "After the first release").
