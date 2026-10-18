# Test drive — Mofu 1.0.0+1 · 2026-10-07 15:44
iPhone 17 Pro sim (iOS 26.5) · Xcode 27.0 · build 82s · commit 5105af9 · seams: DEBUG_SKIP_ADS (no trace seam exists, see Findings)

PASS 29 · FAIL 0 · BLOCKED 5 · SKIP 3   (of 37 criteria; F0 build and RTL also PASS)

| Criterion | Verdict | Evidence | Note |
| --- | --- | --- | --- |
| F0 builds | PASS | (sim.py run output, 82 s) | fixed in 5105af9 (deployment target 15.0) |
| F1-c1 Fur strands grow with fluff | PASS | test-drive/20261007-1544/RTL-home-ar.png, test-drive/20261007-1544/F3-c2-milestone-25.png | 8% vs 27%: visibly bigger, longer fur |
| F1-c2 Idle life: breathing, blink 2.5–6 s, glance/hop 6–14 s | BLOCKED | | no trace seam, so intervals can't be read from the log; screenshots can't time them. Covered by sim_test 'idle life…' |
| F1-c3 Pupils track the finger | PASS | test-drive/20261007-1544/F1-c3-look-topleft.png, test-drive/20261007-1544/F1-c3-look-bottomright.png | pupils shift up-left / down-right relative to the mouth |
| F1-c4 60 fps; 600-strand render under 8 ms | SKIP | | 60 fps needs a device (the simulator renders on the Mac GPU). The 8 ms half: render_budget_test median 0.14 ms. Device: GATE-DEVICE-QA §10 |
| F1-c5 Reduce Motion | BLOCKED | | iOS Reduce Motion not toggled this run (iOS Settings app). Covered by sim_test 'Reduce Motion…' |
| F2-c1 Tap: boing, squeak, happy face | PASS | test-drive/20261007-1544/F2-c1-tap.png | happy face + sparkles + "New! Boing". Squeak is device QA |
| F2-c2 5+ taps in 1.5 s: tickle | BLOCKED | | the MCP can't produce 5 taps within 1.5 s; covered by sim_test 'five quick taps…' |
| F2-c3 Stroke: bend, eyes close, purr, hearts, fluff | PASS | test-drive/20261007-1544/F2-c3-after-stroke.png | hearts, bliss, 8→9%, "New! Happy pets". Purr is device QA |
| F2-c4 Hold: squish, then hug | PASS | test-drive/20261007-1544/F2-c4-hug.png | "New! Big hug" toast after a 2.8 s hold; mid-hold frame not caught |
| F2-c5 Hold and move: pick up, gravity, bounce, land squished; fast throw dizzy | PASS | test-drive/20261007-1544/F2-c5-air.png, test-drive/20261007-1544/F2-c5-landed.png | airborne and squashed with a shadow, then lands. My fling wasn't fast enough for dizzy: sim_test 'a fast throw…' |
| F2-c6 Double-tap an eye: protest | BLOCKED | | 0.42 s window is sub-second for MCP taps; sim_test 'double-tap an eye…' |
| F2-c7 Shake: dizzy + messy fur | SKIP | | accelerometer; device QA (GATE-DEVICE-QA §5) |
| F2-c8 Light haptic for every interaction | SKIP | | haptics need a device; sim_test + sfx_test |
| F3-c1 Brush: sparkles, smooths, faster fluff, sound | PASS | test-drive/20261007-1544/F3-c4-first-brush.png | one pass 9→17% (petting gave +1%). Sound is device QA |
| F3-c2 Fluff persisted; milestones celebrate + unlock | PASS | test-drive/20261007-1544/F3-c2-relaunch.png, test-drive/20261007-1544/F3-c2-milestone-25.png, test-drive/20261007-1544/F3-c2-milestone-unlock.png | 9% survives a relaunch; 25%: "Mofu mofu! 25% fluffy", hearts, then wardrobe dot (Lavender) |
| F3-c3 Fluff never decreases while closed | PASS | test-drive/20261007-1544/F3-c2-relaunch.png | same 9% after terminate/launch; long absence: store_test |
| F3-c4 First daily brush: burst + toast + bonus | PASS | test-drive/20261007-1544/F3-c4-first-brush.png | "First brush of the day ✨", sparkles |
| F4-c1 Six snacks | PASS | test-drive/20261007-1544/F4-c1-tray.png | strawberry, dango, cookie, onigiri, pudding, candy |
| F4-c2 Drag to mouth feeds: chew, cheeks, happy | PASS | test-drive/20261007-1544/F4-c2-chewing.png, test-drive/20261007-1544/F4-c2-after-eat.png | mouth open, crumbs, then happy + "New! Yum!" |
| F4-c3 Favourite snack, special reaction | PASS | test-drive/20261007-1544/F6-c1-journal-2.png | "Every Mofu has one" (favourite) discovered during the six feeds |
| F4-c4 Full after 6 in an hour | PASS | test-drive/20261007-1544/F4-c4-seventh.png | 7th: content face + "… is full. Maybe later!" |
| F5-c1 10 colours / 10 accessories; lock conditions | PASS | test-drive/20261007-1544/F5-c1-wardrobe-fur.png, test-drive/20261007-1544/F5-c3-accessories-new.png | "Visit on 2 days", "Reach 25% fluff", "Discover 6 reactions" |
| F5-c2 Selection updates instantly and persists | PASS | test-drive/20261007-1544/F5-c2-cream.png, test-drive/20261007-1544/F5-c2-wearing.png, test-drive/20261007-1544/F3-c2-relaunch.png | Cream + Daisy survive a relaunch |
| F5-c3 "New!" until viewed | PASS | test-drive/20261007-1544/F5-c3-accessories-new.png | Daisy carried "New!" |
| F6-c1 24 reactions; silhouettes + hint | PASS | test-drive/20261007-1544/F6-c1-journal.png, test-drive/20261007-1544/F6-c1-journal-2.png | "10 of 24"; undiscovered = silhouette + hint |
| F6-c2 Discovery toast "New! …" | PASS | test-drive/20261007-1544/F2-c1-tap.png | "New! Boing" |
| F7-c1 Room colours follow local time | PASS | test-drive/20261007-1544/F2-c1-tap.png | day room at 15:4x local; other periods: app_smoke 'the room at H:00…' |
| F7-c2 Dozes; a tap wakes with a sleepy blink | PASS | test-drive/20261007-1544/F8-c3-home-coach.png, test-drive/20261007-1544/F7-c2-waking.png, test-drive/20261007-1544/F7-c2-awake.png | asleep with closed eyes and zzz; the waking frame shows heavy lids mid-blink |
| F8-c1 Seed wobbles; tap hatches | PASS | test-drive/20261007-1544/F8-c1-seed-a.png, test-drive/20261007-1544/F8-c1-seed-b.png, test-drive/20261007-1544/F8-c2-name-dialog.png | seed angle differs between frames; tap → "Hi! I'm your Mofu" |
| F8-c2 Name 1–16, default "Mofu" or skip; header + Settings | PASS | test-drive/20261007-1544/F8-c2-name-limit.png, test-drive/20261007-1544/F8-c3-home-coach.png, test-drive/20261007-1544/F10-c2-settings.png, test-drive/20261007-1544/RTL-home-ar.png | input capped at 16 chars; Skip keeps "Mofu" |
| F8-c3 One-time "Pet me!" until the first stroke | PASS | test-drive/20261007-1544/F8-c3-home-coach.png, test-drive/20261007-1544/F2-c3-after-stroke.png, test-drive/20261007-1544/F3-c2-relaunch.png | gone after the stroke and after a relaunch |
| F9-c1 Background fetch, 6 s timeout, cache, non-blocking | PASS | test-drive/20261007-1544/F9-c1-launch.log | config URL returns 200; no "fetch skipped" within 12 s of launch; app interactive immediately |
| F9-c2 Versions/announcement/kill-switches/seasons/links/reserved | BLOCKED | | needs editing the owner's live public config; covered by app_smoke wiring tests + remote_config_test |
| F9-c3 Malformed values fall back; test per section | PASS | test/remote_config_test.dart | the criterion is about the test itself ('every section survives garbage') |
| F10-c1 Sound/haptics persisted | PASS | test-drive/20261007-1544/F10-c1-sound-off-relaunch.png | Sounds off survives a relaunch |
| F10-c2 Rename, privacy, support, version | PASS | test-drive/20261007-1544/F10-c2-settings.png | links return 200 |
| F10-c3 Reset with confirmation | PASS | test-drive/20261007-1544/F10-c3-confirm.png, test-drive/20261007-1544/F10-c3-after-reset.png | back to the peach seed |
| RTL (ar) | PASS | test-drive/20261007-1544/RTL-seed-ar.png, test-drive/20261007-1544/RTL-name-ar.png, test-drive/20261007-1544/RTL-home-ar.png | dock, header and dialog mirrored |

## Regressions

None. The previous report (c4fdb54) had F0 FAIL and everything else BLOCKED; F0 now passes.

## Findings

1. **FIXED after the drive**: idle time is now frozen while the first run, a sheet or a dialog covers the room. Verified on the simulator (test-drive/20261007-1544/finding1-fixed-after-55s-overlay.png: awake after 55 s on the seed screen) and by app_smoke 'Mofu does not doze off behind the first-run overlay or a sheet'. Original finding: **Mofu falls asleep behind the first-run overlay and behind sheets.** The idle timer keeps counting while the
   seed/name overlay or the wardrobe sheet is open, and those absorb every touch. After a 45 s+ naming, the new user
   meets a **sleeping** Mofu (and "Sleepyhead" is logged) instead of a freshly hatched happy one
   (test-drive/20261007-1544/F8-c3-home-coach.png). The same happened after the wardrobe (test-drive/20261007-1544/F5-c2-wearing.png).
2. **No behaviour trace seam.** `DEBUG_INSPECTOR` is declared but never read, and nothing logs gestures or timers.
   F1-c2 and similar can't be verified from the device log.
3. "Visit at sunrise" silhouette renders as a **square**, because 🌅 is a square emoji (test-drive/20261007-1544/F6-c1-journal-2.png).
4. The "Start over?" dialog title uses the system font, not the app's rounded font (test-drive/20261007-1544/F10-c3-confirm.png).
5. Flutter notes that all iOS plugins are Swift Packages while the project still uses CocoaPods (build-time only).

## Next for /build

No FAIL rows.
