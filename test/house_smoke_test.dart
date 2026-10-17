import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mofu_pet/core/app_scope.dart';
import 'package:mofu_pet/core/remote_config.dart';
import 'package:mofu_pet/creatures/creature.dart';
import 'package:mofu_pet/l10n/app_localizations.dart';
import 'package:mofu_pet/main.dart';
import 'package:mofu_pet/model/house_store.dart';
import 'package:mofu_pet/ui/house/house_screen.dart';
import 'package:mofu_pet/ui/house/house_text.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The whole house, every locale, the smallest and largest supported iPhones.
/// Any layout overflow fails the test. The house animates forever, so this
/// pumps fixed durations instead of `pumpAndSettle`.
void main() {
  const small = Size(375, 667); // iPhone SE (3rd gen)
  const large = Size(440, 956); // iPhone 16 Pro Max

  Future<HouseStore> pumpHouse(WidgetTester tester, {required Locale locale, Size size = large, bool seeded = true, int hour = 14}) async {
    tester.view
      ..physicalSize = size * 3
      ..devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    SharedPreferences.setMockInitialValues({});
    final clock = DateTime(2026, 10, 17, hour);
    final store = HouseStore(clock: () => clock);
    await store.load();
    if (seeded) {
      store.adopt(Species.mofu);
      store.stars = 400;
      while (store.eggReady && store.friends.length < 5) {
        store.hatch();
      }
      store.completeFirstRun();
    }
    await tester.pumpWidget(MofuApp(services: AppServices(store: store, config: RemoteConfigService(), clock: () => clock), locale: locale));
    await tester.pump(const Duration(milliseconds: 100));
    return store;
  }

  Future<void> settle(WidgetTester tester, [int ms = 700]) async {
    for (var i = 0; i < ms ~/ 50; i++) {
      await tester.pump(const Duration(milliseconds: 50));
    }
  }

  AppLocalizations l10n(WidgetTester tester) => AppLocalizations.of(tester.element(find.byType(HouseScreen)));

  testWidgets('first run: tap the seed, name the hatchling, land in the living room', (tester) async {
    final store = await pumpHouse(tester, locale: const Locale('en'), seeded: false);
    final l = l10n(tester);
    await tester.tap(find.bySemanticsLabel(l.firstRunTapSeed).last);
    await settle(tester, 1500);
    expect(find.byType(TextField), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'Puffy');
    await tester.tap(find.text(l.actionSave));
    await settle(tester);
    expect(store.firstRunDone, isTrue);
    expect(store.friends.single.name, 'Puffy');
    expect(store.friends.single.room, Room.living);
  });

  for (final lang in ['en', 'ja', 'de', 'pt', 'es', 'fr', 'ar']) {
    for (final size in [small, large]) {
      testWidgets('$lang @ ${size.width.toInt()}: every room and sheet lays out', (tester) async {
        final store = await pumpHouse(tester, locale: Locale(lang), size: size);
        final l = l10n(tester);
        final state = tester.state<HouseScreenState>(find.byType(HouseScreen));
        for (final r in Room.values) {
          state.goTo(r);
          await settle(tester, 900);
          expect(find.text(l.roomName(r)), findsWidgets, reason: 'room title for $r');
          // Bring the first friend into each room so its tools render with someone.
          if (store.inRoom(r).isEmpty) {
            state.house.moveFriend(store.friends.first.id, r);
            await settle(tester);
          }
        }
        // Friend card, each tab.
        state.goTo(Room.living);
        await settle(tester, 900);
        for (final f in store.friends.take(4)) {
          final open = state.openFriend(f.id);
          await settle(tester, 700);
          for (final tab in [l.cardTabPlay, l.cardTabWardrobe, l.cardTabJournal]) {
            await tester.tap(find.text(tab).last);
            await settle(tester, 300);
          }
          await tester.tapAt(const Offset(20, 40));
          await settle(tester, 500);
          await open;
        }
        await settle(tester, 900);
      });
    }
  }

  testWidgets('Arabic lays out right-to-left', (tester) async {
    await pumpHouse(tester, locale: const Locale('ar'));
    expect(Directionality.of(tester.element(find.byType(HouseScreen))), TextDirection.rtl);
    await settle(tester, 900);
  });

  testWidgets('settings: reduce motion persists, start over empties the house', (tester) async {
    final store = await pumpHouse(tester, locale: const Locale('en'));
    final l = l10n(tester);
    await tester.tap(find.bySemanticsLabel(l.navSettings));
    await settle(tester);
    await tester.tap(find.text(l.settingsReduceMotion));
    await settle(tester);
    expect(store.reduceMotion, isTrue);
    await tester.scrollUntilVisible(find.text(l.settingsReset), 100, scrollable: find.byType(Scrollable).last);
    await tester.tap(find.text(l.settingsReset));
    await settle(tester);
    await tester.tap(find.text(l.resetConfirm).last);
    await settle(tester, 1200);
    expect(store.friends, isEmpty);
    expect(store.firstRunDone, isFalse);
  });

  testWidgets('daily gift pays once a day', (tester) async {
    final store = await pumpHouse(tester, locale: const Locale('en'));
    final l = l10n(tester);
    final before = store.stars;
    tester.state<HouseScreenState>(find.byType(HouseScreen)).goTo(Room.garden);
    await settle(tester, 900);
    await tester.tap(find.text(l.gardenGiftDay(1)));
    await settle(tester);
    expect(store.stars, before + 6);
    expect(find.text(l.gardenGiftClaimed), findsOneWidget);
    await settle(tester, 2600);
  });
}
