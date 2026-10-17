import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mofu_pet/creatures/creature.dart';
import 'package:mofu_pet/games/snack_catch.dart';
import 'package:mofu_pet/model/house_store.dart';
import 'package:mofu_pet/ui/games/snack_catch_screen.dart';
import 'package:mofu_pet/world/creature_factory.dart';

import 'game_test_kit.dart';

void main() {
  Future<void> open(WidgetTester tester, HouseStore store, Friend friend, {int seed = 5, double width = 430, double height = 900}) async {
    phone(tester, width: width, height: height);
    await tester.pumpWidget(gameHost((context) => Navigator.of(context).push<void>(
          MaterialPageRoute<void>(fullscreenDialog: true, builder: (_) => SnackCatchScreen(store: store, friend: friend, seed: seed)),
        )));
    await tester.tap(find.text('open-game'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
  }

  int secsLeft(WidgetTester tester) {
    final f = find.byWidgetPredicate((w) => w is Text && RegExp(r'^\d+s$').hasMatch(w.data ?? ''));
    return int.parse((tester.widget(f) as Text).data!.replaceAll('s', ''));
  }

  /// Slides a finger left and right across the screen for the whole round.
  Future<void> dragAbout(WidgetTester tester, Finder until, {double maxSeconds = 60}) async {
    final size = tester.view.physicalSize / tester.view.devicePixelRatio;
    final y = size.height * 0.5;
    final gesture = await tester.startGesture(Offset(size.width / 2, y));
    var i = 0;
    while (until.evaluate().isEmpty && i < maxSeconds * 10) {
      // A slow sweep across the middle 80% of the screen.
      final phase = (i % 40) / 40;
      final x = size.width * (0.1 + 0.8 * (phase < 0.5 ? phase * 2 : (1 - phase) * 2));
      await gesture.moveTo(Offset(x, y));
      await tester.pump(const Duration(milliseconds: 100));
      i++;
    }
    await gesture.up();
  }

  testWidgets('countdown, drag, time up, result card, play again, done', (tester) async {
    final store = await memoryStore();
    final friend = store.adopt(Species.oink, name: 'Oinky');
    await open(tester, store, friend);

    expect(find.text('Ready?'), findsOneWidget);
    expect(find.text('Snack Catch'), findsOneWidget);
    expect(find.text('Drag left and right'), findsWidgets);
    expect(find.text('Score 0'), findsOneWidget);
    expect(find.text('45s'), findsOneWidget);
    expect(await pumpUntil(tester, find.text('Go!'), maxSeconds: 3), isTrue);
    await pumpFor(tester, 0.8);
    expect(find.text('Go!'), findsNothing);

    final result = find.byKey(const ValueKey('game-result'));
    await dragAbout(tester, result);
    expect(result, findsOneWidget, reason: 'the result card shows when the 45 s are up');

    final shown = int.parse((tester.widget(find.byKey(const ValueKey('game-result-score'))) as Text).data!);
    expect(shown, store.bestSnackCatch);
    expect(find.text('Oinky'), findsOneWidget);
    expect(find.text('Play again'), findsOneWidget);
    expect(find.text('Done'), findsOneWidget);
    expect(find.text('Up to 12 ★ a day'), findsOneWidget);
    expect(store.stars, (shown ~/ 4).clamp(0, 12));
    expect(find.text('+${store.stars} ★'), findsOneWidget);
    if (shown > 0) expect(find.text('New best!'), findsOneWidget);
    await settleStore(tester);

    await tester.tap(find.text('Play again'));
    await tester.pump();
    expect(result, findsNothing);
    expect(find.text('Ready?'), findsOneWidget);
    expect(find.text('Score 0'), findsOneWidget);
    expect(find.text('45s'), findsOneWidget);

    await pumpFor(tester, 3);
    await tester.tap(find.bySemanticsLabel('Pause'));
    await tester.pump();
    await tester.tap(find.text('Quit'));
    await pumpFor(tester, 0.8);
    expect(find.text('open-game'), findsOneWidget);
    await settleStore(tester);
  });

  testWidgets('pause freezes the clock; leaving the app pauses by itself', (tester) async {
    final store = await memoryStore();
    final friend = store.adopt(Species.mofu);
    await open(tester, store, friend);
    await pumpFor(tester, 5);
    final t0 = secsLeft(tester);
    expect(t0, inInclusiveRange(39, 42));

    await tester.tap(find.bySemanticsLabel('Pause'));
    await tester.pump();
    expect(find.text('Resume'), findsOneWidget);
    await pumpFor(tester, 4);
    expect(secsLeft(tester), t0);
    await tester.tap(find.text('Resume'));
    await tester.pump();
    await pumpFor(tester, 2.5);
    expect(secsLeft(tester), lessThan(t0));

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    await tester.pump();
    expect(find.text('Resume'), findsOneWidget);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    final t1 = secsLeft(tester);
    await pumpFor(tester, 2);
    expect(secsLeft(tester), t1);
    await tester.tap(find.text('Quit'));
    await pumpFor(tester, 0.8);
    expect(find.text('open-game'), findsOneWidget);
    await settleStore(tester);
  });

  testWidgets('a small phone (360 x 640) lays out without overflow, result card included', (tester) async {
    final store = await memoryStore();
    final friend = store.adopt(Species.wuff, name: 'Biscuit');
    await open(tester, store, friend, width: 360, height: 640);
    final result = find.byKey(const ValueKey('game-result'));
    await dragAbout(tester, result);
    expect(result, findsOneWidget);
    expect(tester.takeException(), isNull);
    await settleStore(tester);
  });

  for (final species in Species.values) {
    testWidgets('${species.name}: the real creature catches, drags and plays', (tester) async {
      final store = await memoryStore();
      store.setReduceMotion(species == Species.wuff); // both paths get covered
      final friend = store.adopt(species, name: 'Pal');
      await open(tester, store, friend, seed: 11);
      await pumpFor(tester, 2);
      final size = tester.view.physicalSize / tester.view.devicePixelRatio;
      final gesture = await tester.startGesture(Offset(size.width * 0.5, size.height * 0.5));
      for (var i = 0; i < 80; i++) {
        await gesture.moveTo(Offset(size.width * (0.15 + 0.7 * ((i % 20) / 20)), size.height * 0.5));
        await tester.pump(const Duration(milliseconds: 100));
      }
      await gesture.up();
      expect(tester.takeException(), isNull);
      expect(find.text('Score 0'), findsNothing, reason: 'sweeping the screen for 8 s catches something');
      await tester.pumpWidget(const SizedBox());
      await settleStore(tester);
    });
  }

  test('every species can really reach most of the screen width', () {
    for (final species in Species.values) {
      final f = Friend(id: 'f1', species: species, name: 'Pal', variant: HouseStore.defaultVariant(species), hatchedDay: '2026-10-17');
      final c = makeCreature(f)..pinned = true;
      const w = 430.0, h = 900.0;
      c.layout(const Rect.fromLTWH(0, 0, w, h), floorY: h * 0.84);
      final (lo, hi) = measureCatcherReach(c, w);
      expect(lo, lessThan(w * 0.3), reason: '${species.name} lo $lo');
      expect(hi, greaterThan(w * 0.7), reason: '${species.name} hi $hi');
      // The creature really ends up where the game puts it.
      for (final x in [lo, (lo + hi) / 2, hi]) {
        c.position = Offset(x, c.position.dy);
        for (var i = 0; i < 5; i++) {
          c.update(1 / 60);
        }
        expect(c.position.dx, closeTo(x, 1.5), reason: '${species.name} at $x');
      }
      final g = SnackCatchGame(snacks: snacksFor(species))
        ..minX = lo / w
        ..maxX = hi / w;
      expect(g.maxX - g.minX, greaterThan(0.4));
    }
  });

  test('each species has a menu and its own munch sound', () {
    for (final s in Species.values) {
      expect(snacksFor(s), isNotEmpty);
    }
    expect(munchSoundFor(Species.oink), 'oink.munch1');
    expect(munchSoundFor(Species.wuff), 'wuff.chomp');
    expect(munchSoundFor(Species.mofu), 'mofu.chew');
    expect(munchSoundFor(Species.boop), 'boop.pop');
  });
}
