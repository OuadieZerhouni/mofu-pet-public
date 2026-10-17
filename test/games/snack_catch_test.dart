import 'package:flutter_test/flutter_test.dart';
import 'package:mofu_pet/games/snack_catch.dart';

void main() {
  const menu = ['bone', 'bacon', 'cheese'];

  /// A game with the random spawner off, so a test sees only what it drops.
  SnackCatchGame make({int seed = 1, bool spawning = false}) => SnackCatchGame(snacks: menu, seed: seed)
    ..catcherX = 0.5
    ..spawning = spawning;

  group('catching', () {
    test('a snack inside the catch radius is caught: +1', () {
      final g = make();
      g.drop(FallKind.snack, 0.5, y: g.catchY - 0.2);
      for (var i = 0; i < 50; i++) {
        g.update(0.02);
      }
      expect(g.score, 1);
      expect(g.caught, 1);
    });

    test('an exact scenario: one snack, one catch, one event', () {
      final g = make();
      final it = g.drop(FallKind.snack, 0.5 + g.catchRadius - 0.01, y: g.catchY - 0.2, snack: 'bacon');
      var caught = <SnackCatchEvent>[];
      for (var i = 0; i < 100 && caught.isEmpty; i++) {
        g.update(0.02);
        caught = g.drainEvents().where((e) => e.type == SnackEventType.caught).toList();
      }
      expect(caught, hasLength(1));
      expect(caught.single.points, 1);
      expect(caught.single.snack, 'bacon');
      expect(g.items.contains(it), isFalse);
    });

    test('outside the radius nothing is caught; the snack falls past and is missed', () {
      final g = make();
      final it = g.drop(FallKind.snack, 0.5 + g.catchRadius + 0.05, y: g.catchY - 0.2);
      var missed = 0;
      for (var i = 0; i < 200 && g.items.contains(it); i++) {
        g.update(0.02);
        for (final e in g.drainEvents()) {
          expect(e.type == SnackEventType.caught, isFalse, reason: 'it was out of reach');
          if (e.type == SnackEventType.missed && e.snack == it.snack) missed++;
        }
      }
      expect(g.items.contains(it), isFalse, reason: 'removed once off the bottom');
      expect(missed, greaterThanOrEqualTo(1));
    });

    test('the radius is exactly the catch zone', () {
      for (final dx in [-0.9, -0.5, 0.0, 0.5, 0.9]) {
        final g = make();
        g.drop(FallKind.snack, 0.5 + dx * g.catchRadius, y: g.catchY - 0.1);
        var ok = false;
        for (var i = 0; i < 100; i++) {
          g.update(0.02);
          if (g.drainEvents().any((e) => e.type == SnackEventType.caught)) ok = true;
        }
        expect(ok, isTrue, reason: 'dx $dx');
      }
    });

    test('sliding under a snack in time catches it', () {
      final g = make();
      g.catcherX = 0.2;
      final it = g.drop(FallKind.snack, 0.8, y: g.catchY - 0.25);
      var caught = false;
      for (var i = 0; i < 100 && !caught; i++) {
        if (i == 5) g.catcherX = 0.8;
        g.update(0.02);
        if (!g.items.contains(it)) caught = g.score > 0;
      }
      expect(caught, isTrue);
    });

    test('a golden snack is +3', () {
      final g = make();
      g.drop(FallKind.golden, 0.5, y: g.catchY - 0.1);
      var points = 0;
      for (var i = 0; i < 60; i++) {
        g.update(0.02);
        for (final e in g.drainEvents()) {
          if (e.type == SnackEventType.golden) points = e.points;
        }
      }
      expect(points, 3);
    });

    test('a long frame cannot jump an item past the catch band', () {
      final g = make();
      final it = g.drop(FallKind.snack, 0.5, y: g.catchY - 0.3, speed: 0.6);
      g.update(0.5); // 0.3 screen heights in one go
      expect(g.items.contains(it), isFalse);
      expect(g.drainEvents().where((e) => e.type == SnackEventType.caught), hasLength(1));
    });

    test('the catcher stays between minX and maxX', () {
      final g = make()
        ..minX = 0.2
        ..maxX = 0.8;
      g.catcherX = -3;
      expect(g.catcherX, 0.2);
      g.catcherX = 9;
      expect(g.catcherX, 0.8);
      g.catcherX = double.nan;
      expect(g.catcherX, 0.8);
    });
  });

  group('bees', () {
    test('a bee costs 3 points and stuns', () {
      final g = make();
      g.score = 10;
      g.drop(FallKind.bee, 0.5, y: g.catchY - 0.1);
      SnackCatchEvent? sting;
      for (var i = 0; i < 40 && sting == null; i++) {
        g.update(0.02);
        for (final e in g.drainEvents()) {
          if (e.type == SnackEventType.stung) sting = e;
        }
      }
      expect(sting, isNotNull);
      expect(sting!.points, -3);
      expect(g.score, 7);
      expect(g.stings, 1);
      expect(g.stunned, isTrue);
      expect(g.stunLeft, closeTo(SnackCatchGame.stunSeconds, 0.1));
    });

    test('the score never goes below zero', () {
      final g = make();
      g.score = 1;
      g.drop(FallKind.bee, 0.5, y: g.catchY - 0.05);
      for (var i = 0; i < 20; i++) {
        g.update(0.02);
      }
      expect(g.score, 0);
      expect(g.stings, 1);
    });

    test('a bee that misses is harmless', () {
      final g = make();
      g.score = 5;
      final bee = g.drop(FallKind.bee, 0.5 + g.catchRadius + 0.1, y: g.catchY - 0.2);
      for (var i = 0; i < 200 && g.items.contains(bee); i++) {
        g.update(0.02);
      }
      expect(g.stings, 0);
      expect(g.score, 5);
    });

    test('while stunned nothing is caught and a second bee is harmless', () {
      final g = make();
      g.drop(FallKind.bee, 0.5, y: g.catchY - 0.05);
      for (var i = 0; i < 10; i++) {
        g.update(0.02);
      }
      expect(g.stunned, isTrue);
      g.items.clear();
      g.drainEvents();
      g.drop(FallKind.snack, 0.5, y: g.catchY - 0.1);
      g.drop(FallKind.bee, 0.5, y: g.catchY - 0.1);
      for (var i = 0; i < 25; i++) {
        g.update(0.02);
      }
      // 0.5 s into a 1 s stun.
      expect(g.stunned, isTrue);
      expect(g.stings, 1, reason: 'no second sting during the stun');
      expect(g.score, 0);
      expect(g.caught, 0);
    });

    test('the stun wears off after a second and catching works again', () {
      final g = make();
      g.drop(FallKind.bee, 0.5, y: g.catchY - 0.05);
      for (var i = 0; i < 10; i++) {
        g.update(0.02);
      }
      expect(g.stunned, isTrue);
      for (var i = 0; i < 55; i++) {
        g.update(0.02);
      }
      expect(g.stunned, isFalse);
      g.drop(FallKind.snack, 0.5, y: g.catchY - 0.1);
      for (var i = 0; i < 40; i++) {
        g.update(0.02);
      }
      expect(g.caught, greaterThanOrEqualTo(1));
    });

    test('no bees in the first seconds of the round', () {
      for (var seed = 1; seed <= 20; seed++) {
        final g = make(seed: seed, spawning: true);
        final kinds = <FallKind>{};
        while (g.elapsed < SnackCatchGame.beeGrace) {
          g.update(0.02);
          kinds.addAll(g.items.map((i) => i.kind));
        }
        expect(kinds.contains(FallKind.bee), isFalse, reason: 'seed $seed');
      }
    });
  });

  group('the round', () {
    test('lasts 45 seconds, then it is over and nothing more happens', () {
      final g = make(spawning: true);
      expect(g.duration, 45);
      g.update(44.9);
      expect(g.finished, isFalse);
      g.update(0.2);
      expect(g.finished, isTrue);
      expect(g.timeLeft, 0);
      expect(g.items, isEmpty);
      final score = g.score;
      g.drop(FallKind.snack, 0.5, y: g.catchY);
      g.update(1);
      expect(g.score, score);
      expect(g.elapsed, 45);
    });

    test('bad time steps do nothing', () {
      final g = make();
      g.update(-1);
      g.update(0);
      g.update(double.infinity);
      g.update(double.nan);
      expect(g.elapsed, 0);
    });

    test('snacks come from the friend\'s menu only', () {
      final g = make(seed: 5, spawning: true);
      final seen = <String>{};
      while (!g.finished) {
        g.update(0.05);
        for (final i in g.items) {
          if (i.kind != FallKind.bee) seen.add(i.snack);
        }
      }
      expect(seen, isNotEmpty);
      expect(seen.difference(menu.toSet()), isEmpty);
      expect(seen.length, greaterThan(1));
    });

    test('items fall inside the reachable range', () {
      final g = SnackCatchGame(snacks: menu, seed: 8, minX: 0.25, maxX: 0.7);
      while (!g.finished) {
        g.update(0.05);
        for (final i in g.items) {
          expect(i.x, inInclusiveRange(0.25, 0.7));
        }
      }
    });
  });

  group('speed ramp', () {
    test('fall speed, spawn rate and bee chance all grow with progress', () {
      expect(SnackCatchGame.fallSpeedAt(1), greaterThan(SnackCatchGame.fallSpeedAt(0)));
      expect(SnackCatchGame.spawnGapAt(1), lessThan(SnackCatchGame.spawnGapAt(0)));
      expect(SnackCatchGame.beeChanceAt(1), greaterThan(SnackCatchGame.beeChanceAt(0)));
    });

    test('items spawned late fall faster than items spawned early', () {
      final early = <double>[], late = <double>[];
      for (var seed = 1; seed <= 5; seed++) {
        final g = make(seed: seed, spawning: true);
        final seen = <int>{};
        while (!g.finished) {
          g.update(0.02);
          for (final i in g.items) {
            if (seen.add(i.serial)) (g.progress < 0.2 ? early : (g.progress > 0.8 ? late : <double>[])).add(i.speed);
          }
        }
      }
      expect(early, isNotEmpty);
      expect(late, isNotEmpty);
      expect(late.reduce((a, b) => a < b ? a : b), greaterThan(early.reduce((a, b) => a > b ? a : b)));
    });

    test('the live fall speed rises as the round goes on', () {
      final g = make();
      final start = g.fallSpeed;
      g.update(30);
      expect(g.fallSpeed, greaterThan(start));
    });
  });

  group('determinism', () {
    List<(FallKind, String, double)> run(int seed, double dt) {
      final g = SnackCatchGame(snacks: menu, seed: seed);
      final out = <(FallKind, String, double)>[];
      final seen = <int>{};
      while (!g.finished) {
        g.update(dt);
        for (final i in g.items) {
          if (seen.add(i.serial)) out.add((i.kind, i.snack, double.parse(i.x.toStringAsFixed(6))));
        }
      }
      return out;
    }

    test('the same seed gives the same round', () {
      expect(run(11, 0.02), run(11, 0.02));
      expect(run(11, 0.02), isNotEmpty);
    });

    test('different seeds differ', () {
      expect(run(1, 0.02), isNot(run(2, 0.02)));
    });
  });
}
