import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mofu_pet/core/app_scope.dart';
import 'package:mofu_pet/core/remote_config.dart';
import 'package:mofu_pet/core/sfx.dart';
import 'package:mofu_pet/l10n/app_localizations.dart';
import 'package:mofu_pet/main.dart';
import 'package:mofu_pet/model/pet_store.dart';
import 'package:mofu_pet/sim/mofu_sim.dart';
import 'package:mofu_pet/ui/first_run.dart';
import 'package:mofu_pet/ui/home_screen.dart';
import 'package:mofu_pet/ui/room.dart';
import 'package:mofu_pet/ui/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The whole app, every locale, the smallest and largest supported iPhones.
/// Layout overflow anywhere fails the test (flutter_test reports it as an
/// exception), which is the point of running every sheet in every language.
///
/// The home screen animates forever (Mofu breathes), so these tests pump fixed
/// durations instead of `pumpAndSettle`.
void main() {
  const small = Size(375, 667); // iPhone SE (3rd gen)
  const large = Size(440, 956); // iPhone 16 Pro Max

  Future<PetStore> pumpApp(WidgetTester tester,
      {required Locale locale,
      Size size = large,
      bool seeded = true,
      DateTime? at,
      void Function(PetStore)? prepare,
      Map<String, dynamic>? config}) async {
    final clock = at ?? DateTime(2026, 10, 7, 14);
    tester.view
      ..physicalSize = size * 3
      ..devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    SharedPreferences.setMockInitialValues({});
    final store = PetStore(clock: () => clock);
    await store.load();
    if (seeded) {
      store
        ..firstRunDone = true
        ..coachDone = false;
    }
    prepare?.call(store);
    final services = AppServices(
      store: store,
      config: RemoteConfigService()..value = RemoteConfig.fromJson(config ?? const {}),
      sfx: Sfx.instance,
      clock: () => clock,
    );
    await tester.pumpWidget(MofuApp(services: services, locale: locale));
    await tester.pump(const Duration(milliseconds: 100));
    return store;
  }

  Future<void> settle(WidgetTester tester, [int ms = 600]) async {
    for (var i = 0; i < ms ~/ 50; i++) {
      await tester.pump(const Duration(milliseconds: 50));
    }
  }

  Future<void> closeSheet(WidgetTester tester) async {
    await tester.tapAt(const Offset(20, 40)); // barrier above the sheet
    await settle(tester);
  }

  AppLocalizations l10n(WidgetTester tester) => AppLocalizations.of(tester.element(find.byType(HomeScreen)));

  testWidgets('first run: tap the seed, name it, land on the room', (tester) async {
    final store = await pumpApp(tester, locale: const Locale('en'), seeded: false);
    expect(find.byType(FirstRunOverlay), findsOneWidget);
    final seed = find.descendant(of: find.byType(FirstRunOverlay), matching: find.byType(Transform));
    double tilt() => tester.widgetList<Transform>(seed).map((t) => t.transform.entry(1, 0).abs()).reduce(math.max);
    final tilts = <double>{};
    for (var i = 0; i < 8; i++) {
      await tester.pump(const Duration(milliseconds: 90));
      tilts.add((tilt() * 1000).roundToDouble());
    }
    expect(tilts.length, greaterThan(3), reason: 'the seed wobbles');
    await tester.tap(find.descendant(of: find.byType(FirstRunOverlay), matching: find.byType(GestureDetector)).first);
    await settle(tester, 1800);
    expect(find.byType(TextField), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'Puffy');
    await tester.tap(find.text('Save'));
    await settle(tester);
    expect(store.firstRunDone, isTrue);
    expect(store.name, 'Puffy');
    expect(find.byType(FirstRunOverlay), findsNothing);
    expect(find.text('Puffy'), findsWidgets);
    expect(find.text('Pet me!'), findsOneWidget);
    expect(store.visitDays, 1);
  });

  for (final locale in AppLocalizations.supportedLocales) {
    for (final size in [small, large]) {
      testWidgets('${locale.languageCode} @ ${size.width.toInt()}: room and every sheet lay out', (tester) async {
        await pumpApp(tester, locale: locale, size: size);
        final l = l10n(tester);
        for (final label in [l.dockBrush, l.dockSnacks, l.dockWardrobe, l.dockJournal]) {
          expect(find.text(label), findsOneWidget, reason: '${locale.languageCode} dock "$label"');
        }
        // Snack tray.
        await tester.tap(find.text(l.dockSnacks));
        await settle(tester);
        expect(find.byType(SnackTray), findsOneWidget);
        await tester.tap(find.text(l.dockSnacks));
        await settle(tester);
        // Brush mode toggles the coach text.
        await tester.tap(find.text(l.dockBrush));
        await settle(tester);
        await tester.tap(find.text(l.dockBrush));
        await settle(tester);
        // Sheets.
        await tester.tap(find.text(l.dockWardrobe));
        await settle(tester);
        expect(find.text(l.wardrobeTitle), findsWidgets);
        await tester.tap(find.text(l.tabAccessories));
        await settle(tester);
        await closeSheet(tester);
        await tester.tap(find.text(l.dockJournal));
        await settle(tester);
        expect(find.text(l.journalTitle), findsWidgets);
        await closeSheet(tester);
        await tester.tap(find.bySemanticsLabel(l.semanticsSettings));
        await settle(tester);
        expect(find.text(l.settingsReset), findsOneWidget);
        await closeSheet(tester);
      });
    }
  }

  testWidgets('Arabic lays out right-to-left', (tester) async {
    await pumpApp(tester, locale: const Locale('ar'));
    final ctx = tester.element(find.text('فرشاة'));
    expect(Directionality.of(ctx), TextDirection.rtl);
  });

  testWidgets('petting Mofu discovers "pet" and clears the coach bubble', (tester) async {
    final store = await pumpApp(tester, locale: const Locale('en'));
    final sim = tester.state<HomeScreenState>(find.byType(HomeScreen)).sim;
    final start = sim.pos - const Offset(50, 30);
    final g = await tester.startGesture(start);
    for (var i = 0; i < 50; i++) {
      await g.moveBy(Offset(i.isEven ? 6 : -4, 0));
      await tester.pump(const Duration(milliseconds: 20));
    }
    await g.up();
    await settle(tester);
    expect(store.discovered, contains('pet'));
    expect(store.coachDone, isTrue);
    expect(store.fluff, greaterThan(8));
    expect(find.text('Pet me!'), findsNothing);
    await settle(tester, 800); // let the debounced save land
  });

  testWidgets('dragging a snack to the mouth feeds Mofu', (tester) async {
    final store = await pumpApp(tester, locale: const Locale('en'));
    await tester.tap(find.text('Snacks'));
    await settle(tester);
    final sim = tester.state<HomeScreenState>(find.byType(HomeScreen)).sim;
    final snack = find.descendant(of: find.byType(SnackTray), matching: find.bySemanticsLabel('Strawberry'));
    final from = tester.getCenter(snack);
    final g = await tester.startGesture(from);
    await tester.pump(const Duration(milliseconds: 50));
    const steps = 12;
    final to = sim.mouthPos;
    for (var i = 1; i <= steps; i++) {
      await g.moveTo(Offset.lerp(from, to, i / steps)!);
      await tester.pump(const Duration(milliseconds: 16));
    }
    await g.up();
    await settle(tester, 2600);
    expect(store.snacksFed, 1);
    expect(store.discovered, contains('yum'));
    await settle(tester, 800); // let the debounced save land
  });

  testWidgets('dropping a snack on empty floor does not feed', (tester) async {
    final store = await pumpApp(tester, locale: const Locale('en'));
    await tester.tap(find.text('Snacks'));
    await settle(tester);
    final from = tester.getCenter(find.descendant(of: find.byType(SnackTray), matching: find.bySemanticsLabel('Cookie')));
    final g = await tester.startGesture(from);
    await tester.pump(const Duration(milliseconds: 50));
    await g.moveTo(const Offset(20, 200));
    await tester.pump(const Duration(milliseconds: 16));
    await g.up();
    await settle(tester);
    expect(store.snacksFed, 0);
  });

  testWidgets('settings: toggles persist, start over returns to the seed', (tester) async {
    final store = await pumpApp(tester, locale: const Locale('en'));
    await tester.tap(find.bySemanticsLabel('Settings'));
    await settle(tester);
    await tester.tap(find.text('Sounds'));
    await settle(tester, 300);
    expect(store.soundOn, isFalse);
    await tester.tap(find.text('Start over'));
    await settle(tester);
    await tester.tap(find.widgetWithText(FilledButton, 'Start over'));
    await settle(tester);
    expect(store.firstRunDone, isFalse);
    expect(store.soundOn, isTrue);
    expect(find.byType(FirstRunOverlay), findsOneWidget);
  });

  testWidgets('wardrobe: choosing an unlocked accessory wears it', (tester) async {
    final store = await pumpApp(tester, locale: const Locale('en'));
    await tester.tap(find.text('Wardrobe'));
    await settle(tester);
    await tester.tap(find.text('Accessories'));
    await settle(tester);
    await tester.tap(find.bySemanticsLabel('Bow'));
    await settle(tester, 300);
    expect(store.accessoryId, 'bow');
    await closeSheet(tester);
    expect(store.discovered, contains('dressUp'));
  });

  Future<void> pet(WidgetTester tester, {int moves = 50}) async {
    final sim = tester.state<HomeScreenState>(find.byType(HomeScreen)).sim;
    final g = await tester.startGesture(sim.pos - const Offset(50, 30));
    for (var i = 0; i < moves; i++) {
      await g.moveBy(Offset(i.isEven ? 6 : -4, 0));
      await tester.pump(const Duration(milliseconds: 20));
    }
    await g.up();
  }

  Future<Set<String>> toastsDuring(WidgetTester tester, int ms) async {
    final seen = <String>{};
    for (var i = 0; i < ms ~/ 100; i++) {
      await tester.pump(const Duration(milliseconds: 100));
      for (final t in tester.widgetList<Text>(find.descendant(of: find.byType(ToastView), matching: find.byType(Text)))) {
        if (t.data != null) seen.add(t.data!);
      }
    }
    return seen;
  }

  // F6-c1, F6-c2
  testWidgets('journal: undiscovered = silhouette + hint; discovering toasts "New! …" and fills the entry', (tester) async {
    final store = await pumpApp(tester, locale: const Locale('en'));
    await tester.tap(find.text('Journal'));
    await settle(tester);
    expect(find.text('Stroke its fur'), findsOneWidget);
    expect(find.text('Happy pets'), findsNothing);
    expect(find.text('???'), findsNothing);
    final silhouettes = tester.widgetList(find.byType(ColorFiltered)).length;
    expect(silhouettes, greaterThan(6), reason: 'every visible entry is a silhouette');
    await closeSheet(tester);
    await pet(tester);
    final toasts = await toastsDuring(tester, 1200);
    expect(toasts, contains('New! Happy pets'));
    expect(store.discovered, contains('pet'));
    await settle(tester, 2600);
    await tester.tap(find.text('Journal'));
    await settle(tester);
    expect(find.text('Happy pets'), findsOneWidget);
    expect(find.byType(ColorFiltered), findsNWidgets(silhouettes - 1));
    await closeSheet(tester);
    await settle(tester, 800);
  });

  // F3-c2, F5-c3
  testWidgets('crossing 25% fluff celebrates, unlocks Lavender, and the wardrobe shows "New!" once', (tester) async {
    final store = await pumpApp(tester, locale: const Locale('en'), prepare: (s) => s.fluff = 24.9);
    expect(store.unseenUnlocks, isEmpty);
    await pet(tester);
    final toasts = await toastsDuring(tester, 8000);
    expect(toasts, containsAll(['Mofu mofu! 25% fluffy', 'Unlocked: Lavender']));
    expect(store.colorUnlocked('lavender'), isTrue);
    expect(store.unseenUnlocks, isNotEmpty);
    await tester.tap(find.text('Wardrobe'));
    await settle(tester);
    expect(find.text('New!'), findsOneWidget);
    await closeSheet(tester);
    expect(store.unseenUnlocks, isEmpty);
    await tester.tap(find.text('Wardrobe'));
    await settle(tester);
    expect(find.text('New!'), findsNothing);
    await closeSheet(tester);
    await settle(tester, 800);
  });

  // F5-c1, F5-c2
  testWidgets('wardrobe: locked items say how to earn them; choosing a colour persists', (tester) async {
    final store = await pumpApp(tester, locale: const Locale('en'));
    await tester.tap(find.text('Wardrobe'));
    await settle(tester);
    expect(find.bySemanticsLabel('Lavender. Reach 25% fluff'), findsOneWidget);
    expect(find.text('Reach 25% fluff'), findsOneWidget);
    await tester.tap(find.bySemanticsLabel('Cream'));
    await settle(tester, 300);
    expect(store.colorId, 'cream');
    await closeSheet(tester);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString(PetStore.prefsKey), contains('"color":"cream"'));
  });

  // F8-c2
  testWidgets('first run: skipping the name keeps "Mofu", shown in the header and Settings', (tester) async {
    final store = await pumpApp(tester, locale: const Locale('en'), seeded: false);
    await tester.tap(find.descendant(of: find.byType(FirstRunOverlay), matching: find.byType(GestureDetector)).first);
    await settle(tester, 1800);
    await tester.tap(find.text('Skip'));
    await settle(tester);
    expect(store.firstRunDone, isTrue);
    expect(store.name, 'Mofu');
    expect(find.text('Mofu'), findsWidgets);
    await tester.tap(find.bySemanticsLabel('Settings'));
    await settle(tester);
    expect(find.descendant(of: find.byType(BottomSheet), matching: find.text('Mofu')), findsOneWidget);
    await closeSheet(tester);
  });

  // F10-c1, F10-c2
  testWidgets('settings: haptics toggle persists; rename, privacy, support and version are there', (tester) async {
    final store = await pumpApp(tester, locale: const Locale('en'));
    await tester.tap(find.bySemanticsLabel('Settings'));
    await settle(tester);
    for (final row in ['Rename', 'Privacy policy', 'Help & feedback']) {
      expect(find.text(row), findsOneWidget, reason: row);
    }
    expect(find.textContaining('Version '), findsOneWidget);
    await tester.tap(find.text('Haptics'));
    await settle(tester, 300);
    expect(store.hapticsOn, isFalse);
    expect(Sfx.instance.hapticsOn, isFalse);
    await tester.tap(find.text('Haptics'));
    await settle(tester, 300);
    expect(store.hapticsOn, isTrue);
    await closeSheet(tester);
  });

  // F7-c1
  for (final (hour, period) in [
    (8, RoomPeriod.morning),
    (14, RoomPeriod.day),
    (19, RoomPeriod.evening),
    (23, RoomPeriod.night),
  ]) {
    testWidgets('the room at $hour:00 is ${period.name}', (tester) async {
      await pumpApp(tester, locale: const Locale('en'), at: DateTime(2026, 10, 7, hour));
      final painters = tester.widgetList<CustomPaint>(find.byType(CustomPaint)).map((c) => c.painter).whereType<RoomPainter>();
      expect(painters.single.period, period);
    });
  }

  // F9-c2
  testWidgets('remote kill-switches reach the creature and the sound engine', (tester) async {
    await pumpApp(tester, locale: const Locale('en'), config: {
      'features': {'toss': false, 'sounds': false},
    });
    final home = tester.state<HomeScreenState>(find.byType(HomeScreen));
    expect(home.sim.tossEnabled, isFalse);
    expect(Sfx.instance.remoteSoundsEnabled, isFalse);
    Sfx.instance.remoteSoundsEnabled = true;
  });

  testWidgets('an announcement shows once per id', (tester) async {
    const ann = {
      'announcement': {'enabled': true, 'id': 'hello26', 'title': 'Hello!', 'body': 'Mofu says hi'},
    };
    final store = await pumpApp(tester, locale: const Locale('en'), config: ann);
    await settle(tester);
    expect(find.text('Mofu says hi'), findsOneWidget);
    expect(store.lastAnnouncementId, 'hello26');
    await tester.tap(find.text('OK'));
    await settle(tester);
    expect(find.text('Mofu says hi'), findsNothing);
    await tester.pumpWidget(const SizedBox());
    await pumpApp(tester, locale: const Locale('en'), config: ann, prepare: (s) => s.markAnnouncementSeen('hello26'));
    await settle(tester);
    expect(find.text('Mofu says hi'), findsNothing);
  });

  // F3-c4
  testWidgets('the first brush of the day sparkles, toasts and adds fluff; the second one does not', (tester) async {
    final store = await pumpApp(tester, locale: const Locale('en'));
    final home = tester.state<HomeScreenState>(find.byType(HomeScreen));
    await tester.tap(find.text('Brush'));
    await settle(tester);
    expect(home.sim.brushMode, isTrue);
    final before = store.fluff;
    await pet(tester, moves: 30);
    final toasts = await toastsDuring(tester, 600);
    expect(toasts, contains('First brush of the day ✨'));
    expect(home.sim.particles.where((p) => p.kind == ParticleKind.sparkle).length, greaterThanOrEqualTo(10));
    expect(store.fluff - before, greaterThan(3));
    await settle(tester, 2600);
    await pet(tester, moves: 30);
    expect(await toastsDuring(tester, 600), isNot(contains('First brush of the day ✨')));
    await settle(tester, 800);
  });

  // F5-c1: day-based unlocks count days visited.
  testWidgets('a locked day colour says how many visits it needs', (tester) async {
    await pumpApp(tester, locale: const Locale('en'));
    await tester.tap(find.text('Wardrobe'));
    await settle(tester);
    expect(find.bySemanticsLabel('Mint. Visit on 2 days'), findsOneWidget);
    await closeSheet(tester);
  });
}
