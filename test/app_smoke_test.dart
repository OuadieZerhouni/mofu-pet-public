import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mofu_pet/core/app_scope.dart';
import 'package:mofu_pet/core/remote_config.dart';
import 'package:mofu_pet/core/sfx.dart';
import 'package:mofu_pet/l10n/app_localizations.dart';
import 'package:mofu_pet/main.dart';
import 'package:mofu_pet/model/pet_store.dart';
import 'package:mofu_pet/ui/first_run.dart';
import 'package:mofu_pet/ui/home_screen.dart';
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

  Future<PetStore> pumpApp(WidgetTester tester, {required Locale locale, Size size = large, bool seeded = true}) async {
    tester.view
      ..physicalSize = size * 3
      ..devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    SharedPreferences.setMockInitialValues({});
    final store = PetStore(clock: () => DateTime(2026, 10, 7, 14));
    await store.load();
    if (seeded) {
      store
        ..firstRunDone = true
        ..coachDone = false;
    }
    final services = AppServices(
      store: store,
      config: RemoteConfigService(),
      sfx: Sfx.instance,
      clock: () => DateTime(2026, 10, 7, 14),
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
}
