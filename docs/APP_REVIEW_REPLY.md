# Reply to App Review — Mofu (4.3 Spam / 4.2.6) — DRAFT for Ouadie to send

> Send this yourself from App Store Connect → Mofu → App Review → "Reply to App Review",
> **together with the resubmitted build**. Edit anything that is not exactly true for you
> (especially the beta-testing answer — only describe testing you actually did).
> Before sending: in App Store Connect, make sure Oink, Boop! and Wuff are **not** in review
> and will not be resubmitted (their characters now live inside Mofu).

## Review notes (App Store Connect → App Review Information → Notes)

```
Mofu & Friends replaces our earlier separate submissions (Mofu, Oink, Boop!, Wuff): their creatures
now live together in this single app, and the other three will not be resubmitted.
How to try it: tap the seed to hatch Mofu. Swipe between six rooms. Spa: bring a friend and rub
(foam, rinse, towel, dry). Kitchen: drag a snack to a mouth. Bedroom: Sleep sounds + Mix (keeps
playing with the screen locked - this is why the app declares background audio). Garden: the egg
hatches a new friend when enough stars are earned (a debug-free build; stars come from playing).
No account, no ads, no purchases, no data collected.
```

---

Hello App Review team,

Thank you for the detailed feedback. You were right that Mofu, Oink and Boop! were too close to each
other as separate submissions. We have consolidated them: Oink, Boop! and Wuff will not be resubmitted,
and their creatures now live inside this single app, which has been rebuilt with substantial new
functionality. Answers to your questions:

**1. What the app does and the problem it solves.**
Mofu & Friends is a cozy virtual home where the user cares for a small household of creatures (a fluffy
"Mofu", a piglet, a puppy and a family of jelly "Boops"). It is built around calm, tactile interactions:
a step-by-step spa (foam, rinse, towel, blow-dry) with soft sound and haptic feedback, feeding each
friend from its own menu, tucking them in at night, and a sleep-sound mixer (rain, purr, fireplace,
ocean, chimes, soft noise) with a fade-out timer that keeps playing with the screen locked. The problem it
solves is a gentle, low-stakes daily ritual for winding down: short moments of comfort during the day,
and a bedtime routine with relaxing sounds at night. Nothing decays, nothing dies and there is no
pressure to return.

**2. Intended users.**
Teens and adults who enjoy cozy games and cute characters, and people who use soothing sounds to relax
or fall asleep. Parents also share it with children (rated 4+; not submitted to the Kids category). It
is localized in English, Japanese, German, Portuguese, Spanish, French and Arabic.

**3. The gap it addresses.**
Most virtual-pet apps are either a single reactive character or a care loop built on decaying needs and
guilt notifications. Mofu & Friends combines a multi-creature household (friends react to each other,
pile up and nuzzle), a hands-on ASMR grooming routine, and a built-in sleep-sound mixer in one offline,
ad-free app that collects no data. We could not find an app that combines tactile creature care with a
bedtime sound mixer in this way.

**4. Beta testing.**
Before this submission, testing was done by the developer; we have not yet run an external TestFlight
group. Release builds were tested by hand room by room, the flagship build went through a separate UX
review and a correctness review, and every change runs against an automated suite of 306 tests
(gestures, saving, every language and right-to-left layout) plus a motion-capture harness that records
each animation frame by frame. Findings from that testing that changed this build: rapid taps on the room
arrows repeated the same room and now step through rooms; a single friend in the garden no longer lands
on the hatching nest; an egg hatch could get stuck if the garden was paged away; moving a friend out of
the spa mid-routine left it pinned; the sleep mixer now obeys the app's Sound switch; the Share button
was clipped in Arabic in the photo booth; tapping a friend no longer jolts its neighbours. On the first
Mofu build, simulator testing found that Mofu fell asleep behind the onboarding screen, which was fixed
before that submission.

**5. Standalone or part of a suite?**
It is a standalone product. The other apps on this developer account are: OuO cute pet (a single
animated face that reacts to touch, as a screen companion), OuO Weather (a weather forecast with a cat
widget), Neko: Pixel Cat Drums & Widget (a single pixel-art cat that plays bongo drums as you tap, with a
home-screen widget), Ocarina Pocket (a musical instrument with tabs and a tuner), Hot Cold Globe (a
geography quiz) and Orbit Rage (an arcade game). Oink and Boop! also have rejected records and will not
be resubmitted. Mofu & Friends shares no screens or gameplay with any of them: it is the only app on the
account with a multi-creature household, rooms, a grooming routine, feeding, hatching new friends and a
sleep-sound mixer. Unlike OuO and Neko, which each centre on one character's reactions, it is a care and
bedtime routine across a household of creatures.

**6. Could it be an in-app purchase or content addition in another app?**
That was the case for our earlier separate submissions, and we acted on it: the three creature apps have
been merged into this one, so each creature is now content within a single app rather than its own
binary. It does not fit inside OuO, whose scope is a single face on the screen.

**7. Shared code or assets with other apps on the account?**
Like our other apps, it starts from our own in-house project template, which provides only a small
foundation: settings storage, a remote-configuration loader, localization setup and build scripts. It also
uses common open-source Flutter packages (audio playback, localization, storage). Everything users see
and do — the creature simulations, art, rooms, sound design and gameplay — is specific to this app. The
earlier Oink, Boop! and Wuff prototypes were merged into it and will not ship separately.

**8. Codebase, SDK or content shared with a third-party app?**
No. All characters, illustrations and rooms were created by the developer for this app. Sounds were
designed by the developer, some with the help of Stability AI's Stable Audio model (credited in the app's
Settings → Credits). Only standard third-party frameworks are used (Flutter and open-source packages).

**9. Built for a client or third party?**
No. The developer designed, built and owns the concept, content and branding, and submits it under their
own account. The in-house project template mentioned above is the developer's own; no commercial template
or app-generation service is used.

Thank you for your time.
