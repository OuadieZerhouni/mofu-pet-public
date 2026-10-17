import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mofu_pet/creatures/creature.dart';
import 'package:mofu_pet/model/house_store.dart';
import 'package:mofu_pet/ui/games/boop_rush_screen.dart';

import 'game_test_kit.dart';

void main() {
  final board = find.byKey(const ValueKey('boop-rush-board'));

  Future<void> open(WidgetTester tester, HouseStore store, {int seed = 7, double width = 430, double height = 900}) async {
    phone(tester, width: width, height: height);
    await tester.pumpWidget(gameHost((context) => Navigator.of(context).push<void>(
          MaterialPageRoute<void>(fullscreenDialog: true, builder: (_) => BoopRushScreen(store: store, seed: seed)),
        )));
    await tester.tap(find.text('open-game'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
  }

  /// Taps every hole once; most of the time something is out.
  Future<void> tapAll(WidgetTester tester) async {
    final r = tester.getRect(board);
    for (var i = 0; i < 9; i++) {
      final c = Offset(r.left + (i % 3 + 0.5) * r.width / 3, r.top + (i ~/ 3 + 0.5) * r.height / 3);
      await tester.tapAt(c);
    }
  }

  testWidgets('countdown, play, tap, time up, result card, play again, done', (tester) async {
    final store = await memoryStore();
    await open(tester, store);

    // Ready? ... Go! ...
    expect(find.text('Ready?'), findsOneWidget);
    expect(find.text('Boop Rush'), findsOneWidget);
    expect(find.text('Score 0'), findsOneWidget);
    expect(find.text('30s'), findsOneWidget);
    expect(await pumpUntil(tester, find.text('Go!'), maxSeconds: 3), isTrue);
    expect(find.text('Ready?'), findsNothing);
    await pumpFor(tester, 0.8);
    expect(find.text('Go!'), findsNothing, reason: 'the round is on');

    final result = find.byKey(const ValueKey('game-result'));
    final scoreText = find.textContaining('Score ');
    await pumpFor(tester, 4);
    expect(result, findsNothing, reason: 'the round lasts 30 s, not 4');
    expect(scoreText, findsOneWidget);
    var maxScore = 0;

    // Boop everything for the rest of the round.
    var guard = 0;
    while (result.evaluate().isEmpty && guard++ < 400) {
      await tapAll(tester);
      await tester.pump(const Duration(milliseconds: 100));
      final m = RegExp(r'Score (\d+)').firstMatch((tester.widget(scoreText) as Text).data ?? '');
      if (m != null) maxScore = int.parse(m.group(1)!);
    }
    expect(result, findsOneWidget, reason: 'the result card shows when the round ends');
    expect(maxScore, greaterThan(0), reason: 'tapping the holes boops something');

    // The card.
    expect(find.text('New best!'), findsOneWidget);
    expect(find.text('Play again'), findsOneWidget);
    expect(find.text('Done'), findsOneWidget);
    expect(find.textContaining('Up to 12'), findsOneWidget);
    final shown = int.parse((tester.widget(find.byKey(const ValueKey('game-result-score'))) as Text).data!);
    expect(shown, store.bestBoopRush);
    expect(shown, greaterThanOrEqualTo(maxScore));
    expect(store.stars, store.starsToday[StarSource.boopRush] ?? 0);
    expect(find.text('+${store.stars} ★'), findsOneWidget);
    expect(store.stars, (shown ~/ 5).clamp(0, 12));
    await settleStore(tester);

    // Play again: a new countdown, the card is gone.
    await tester.tap(find.text('Play again'));
    await tester.pump();
    expect(find.text('Ready?'), findsOneWidget);
    expect(result, findsNothing);
    expect(find.text('Score 0'), findsOneWidget);

    // Leave mid-countdown through pause > quit.
    await tester.tap(find.bySemanticsLabel('Pause'));
    await tester.pump();
    expect(find.text('Resume'), findsOneWidget);
    await tester.tap(find.text('Quit'));
    await pumpFor(tester, 0.8);
    expect(find.text('open-game'), findsOneWidget);
    expect(store.stars, shown ~/ 5 > 12 ? 12 : shown ~/ 5, reason: 'quitting earns nothing more');
    await settleStore(tester);
  });

  int secsLeft(WidgetTester tester) {
    final f = find.byWidgetPredicate((w) => w is Text && RegExp(r'^\d+s$').hasMatch(w.data ?? ''));
    return int.parse((tester.widget(f) as Text).data!.replaceAll('s', ''));
  }

  testWidgets('pause freezes the clock, resume continues, leaving the app pauses by itself', (tester) async {
    final store = await memoryStore();
    await open(tester, store);
    await pumpFor(tester, 2.5); // countdown is over
    expect(find.text('Go!'), findsNothing);
    await pumpFor(tester, 3);
    final t0 = secsLeft(tester);
    expect(t0, inInclusiveRange(24, 28));

    await tester.tap(find.bySemanticsLabel('Pause'));
    await tester.pump();
    expect(find.text('Pause'), findsOneWidget);
    expect(find.text('Resume'), findsOneWidget);
    expect(find.text('Quit'), findsOneWidget);
    await pumpFor(tester, 5);
    expect(secsLeft(tester), t0, reason: 'paused: the clock does not move');

    await tester.tap(find.text('Resume'));
    await tester.pump();
    expect(find.text('Resume'), findsNothing);
    await pumpFor(tester, 2.5);
    final t1 = secsLeft(tester);
    expect(t1, lessThan(t0));
    expect(t1, inInclusiveRange(t0 - 3, t0 - 2));

    // The app goes to the background: paused until the player resumes.
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    await tester.pump();
    expect(find.text('Resume'), findsOneWidget);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await pumpFor(tester, 3);
    expect(secsLeft(tester), t1, reason: 'coming back does not restart the clock by itself');
    await tester.tap(find.text('Resume'));
    await tester.pump();
    await pumpFor(tester, 1.5);
    expect(secsLeft(tester), lessThan(t1));

    // The system back button pauses; back again leaves.
    await tester.binding.handlePopRoute();
    await tester.pump();
    expect(find.text('Resume'), findsOneWidget);
    await tester.binding.handlePopRoute();
    await pumpFor(tester, 0.8);
    expect(find.text('open-game'), findsOneWidget);
    await settleStore(tester);
  });

  testWidgets('a round with reduce motion on still plays to the result card', (tester) async {
    final store = await memoryStore();
    store.setReduceMotion(true);
    await open(tester, store, seed: 3);
    var guard = 0;
    final result = find.byKey(const ValueKey('game-result'));
    while (result.evaluate().isEmpty && guard++ < 400) {
      await tapAll(tester);
      await tester.pump(const Duration(milliseconds: 100));
    }
    expect(result, findsOneWidget);
    expect(tester.takeException(), isNull);
    await settleStore(tester);
  });

  testWidgets('hatched Boops are the critters of the meadow', (tester) async {
    final store = await memoryStore();
    store.adopt(Species.boop, variant: 'kiwi');
    store.adopt(Species.boop, variant: 'coco');
    expect(rushVariantsFor(store), ['kiwi', 'coco', 'mochi']);
    final empty = await memoryStore();
    expect(rushVariantsFor(empty), ['mochi', 'pip', 'bao']);
    final many = await memoryStore();
    for (final v in HouseStore.boopOrder) {
      many.adopt(Species.boop, variant: v);
    }
    expect(rushVariantsFor(many), hasLength(6));
    await open(tester, store);
    await pumpFor(tester, 5);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
    await settleStore(tester);
  });

  testWidgets('a small phone (360 x 640) lays out without overflow, result card included', (tester) async {
    final store = await memoryStore();
    await open(tester, store, width: 360, height: 640);
    final result = find.byKey(const ValueKey('game-result'));
    var guard = 0;
    while (result.evaluate().isEmpty && guard++ < 400) {
      await tapAll(tester);
      await tester.pump(const Duration(milliseconds: 100));
    }
    expect(result, findsOneWidget);
    expect(tester.takeException(), isNull);
    final board = tester.getRect(find.byKey(const ValueKey('boop-rush-board')));
    expect(board.width, greaterThanOrEqualTo(240));
    expect(board.width / 3, greaterThanOrEqualTo(48), reason: 'every hole is a big target');
    await settleStore(tester);
  });

  testWidgets('the entry point opens the screen and its buttons are big enough to hit', (tester) async {
    final store = await memoryStore();
    phone(tester);
    await tester.pumpWidget(gameHost((context) => playBoopRush(context, store: store)));
    await tester.tap(find.text('open-game'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Ready?'), findsOneWidget);
    final pause = tester.getSize(find.bySemanticsLabel('Pause'));
    expect(pause.width, greaterThanOrEqualTo(48));
    expect(pause.height, greaterThanOrEqualTo(48));
    await tester.tap(find.bySemanticsLabel('Pause'));
    await tester.pump();
    for (final label in ['Resume', 'Quit']) {
      final size = tester.getSize(find.bySemanticsLabel(label));
      expect(size.height, greaterThanOrEqualTo(48), reason: label);
    }
    await tester.tap(find.text('Quit'));
    await pumpFor(tester, 0.8);
    expect(find.text('open-game'), findsOneWidget);
  });
}
