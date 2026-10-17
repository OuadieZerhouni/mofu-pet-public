import 'package:flutter_test/flutter_test.dart';
import 'package:mofu_pet/games/boop_rush.dart';

void main() {
  /// Runs a round with no taps and returns every spawn, as comparable tuples.
  List<(int, RushKind, int, double)> spawns(BoopRushGame g, double dt) {
    final out = <(int, RushKind, int, double)>[];
    var guard = 0;
    while (!g.finished && guard++ < 100000) {
      g.update(dt);
      for (final e in g.drainEvents()) {
        if (e.type == RushEventType.spawn) out.add((e.cell, e.kind!, e.critter, g.elapsed));
      }
    }
    return out;
  }

  group('scoring', () {
    test('an awake critter is +1, a golden one +5', () {
      final g = BoopRushGame();
      g.place(0, RushKind.awake);
      final a = g.tap(0);
      expect(a.type, RushEventType.boop);
      expect(a.points, 1);
      expect(g.score, 1);
      g.place(4, RushKind.golden);
      final b = g.tap(4);
      expect(b.type, RushEventType.golden);
      expect(b.points, 5);
      expect(g.score, 6);
      expect(g.goodBoops, 2);
    });

    test('a sleepy critter is -1', () {
      final g = BoopRushGame();
      g.place(0, RushKind.awake);
      g.tap(0);
      g.place(1, RushKind.awake);
      g.tap(1);
      g.place(2, RushKind.sleepy);
      final e = g.tap(2);
      expect(e.type, RushEventType.sleepy);
      expect(e.points, -1);
      expect(g.score, 1);
      expect(g.goodBoops, 2, reason: 'sleepy taps are not boops');
    });

    test('the score never goes below zero', () {
      final g = BoopRushGame();
      for (var i = 0; i < 5; i++) {
        g.place(i, RushKind.sleepy);
        final e = g.tap(i);
        expect(e.points, 0, reason: 'nothing to lose at 0');
      }
      expect(g.score, 0);
    });

    test('a tapped critter is gone; tapping the empty hole is a miss that costs nothing', () {
      final g = BoopRushGame();
      g.place(3, RushKind.awake);
      g.tap(3);
      expect(g.slots[3], isNull);
      final again = g.tap(3);
      expect(again.type, RushEventType.miss);
      expect(g.score, 1);
    });

    test('out of range cells and taps after the round are ignored', () {
      final g = BoopRushGame();
      g.place(0, RushKind.awake);
      expect(g.tap(-1).type, RushEventType.miss);
      expect(g.tap(9).type, RushEventType.miss);
      expect(g.score, 0);
      g.update(30);
      expect(g.finished, isTrue);
      g.place(0, RushKind.awake);
      g.tap(0);
      expect(g.score, 0);
    });

    test('streak grows on boops, resets on a sleepy one, best streak is kept', () {
      final g = BoopRushGame();
      for (var i = 0; i < 4; i++) {
        g.place(i, RushKind.awake);
        expect(g.tap(i).streak, i + 1);
      }
      g.place(5, RushKind.sleepy);
      g.tap(5);
      expect(g.streak, 0);
      expect(g.bestStreak, 4);
      g.place(6, RushKind.awake);
      expect(g.tap(6).streak, 1);
    });
  });

  group('the round', () {
    test('lasts 30 seconds, then everything is over', () {
      final g = BoopRushGame();
      expect(g.duration, 30);
      expect(g.timeLeft, 30);
      g.update(29.9);
      expect(g.finished, isFalse);
      expect(g.timeLeft, closeTo(0.1, 1e-9));
      g.update(0.2);
      expect(g.finished, isTrue);
      expect(g.timeLeft, 0);
      expect(g.liveCount, 0);
      final ends = g.drainEvents().where((e) => e.type == RushEventType.end);
      expect(ends, hasLength(1));
      g.update(5);
      expect(g.drainEvents(), isEmpty, reason: 'nothing happens after the end');
      expect(g.elapsed, 30);
    });

    test('critters duck back down on their own', () {
      final g = BoopRushGame();
      g.place(2, RushKind.awake, lifetime: 1);
      g.update(0.9);
      expect(g.slots[2], isNotNull);
      g.update(0.2);
      expect(g.slots[2], isNull);
      expect(g.drainEvents().where((e) => e.type == RushEventType.expire), hasLength(1));
    });

    test('the board is 3x3', () {
      expect(BoopRushGame.cells, 9);
      expect(BoopRushGame().slots, hasLength(9));
    });

    test('negative, zero and NaN time do nothing', () {
      final g = BoopRushGame();
      g.update(-1);
      g.update(0);
      g.update(double.nan);
      expect(g.elapsed, 0);
    });

    test('no sleepy critters in the first 3 seconds', () {
      for (var seed = 1; seed <= 20; seed++) {
        final list = spawns(BoopRushGame(seed: seed), 1 / 30).where((s) => s.$4 <= 3);
        expect(list.where((s) => s.$2 == RushKind.sleepy), isEmpty, reason: 'seed $seed');
      }
    });

    test('all three kinds show up over a round', () {
      final kinds = <RushKind>{};
      for (var seed = 1; seed <= 10; seed++) {
        kinds.addAll(spawns(BoopRushGame(seed: seed), 1 / 30).map((s) => s.$2));
      }
      expect(kinds, RushKind.values.toSet());
    });
  });

  group('speed ramp', () {
    test('spawn gap and lifetime shrink, room for more critters grows', () {
      expect(BoopRushGame.spawnGapAt(1), lessThan(BoopRushGame.spawnGapAt(0)));
      expect(BoopRushGame.lifetimeAt(1), lessThan(BoopRushGame.lifetimeAt(0)));
      expect(BoopRushGame.maxLiveAt(0), 2);
      expect(BoopRushGame.maxLiveAt(1), 4);
      var last = 0.0;
      for (var t = 0.0; t <= 1; t += 0.1) {
        expect(BoopRushGame.spawnGapAt(t), lessThanOrEqualTo(last == 0 ? 9 : last));
        last = BoopRushGame.spawnGapAt(t);
      }
    });

    test('more critters appear in the second half than in the first', () {
      var first = 0, second = 0;
      for (var seed = 1; seed <= 10; seed++) {
        for (final s in spawns(BoopRushGame(seed: seed), 1 / 30)) {
          s.$4 <= 15 ? first++ : second++;
        }
      }
      expect(second, greaterThan(first));
    });

    test('critters stay out for less time late in the round', () {
      final g = BoopRushGame(seed: 4);
      final life = <double>[];
      var guard = 0;
      while (!g.finished && guard++ < 10000) {
        g.update(1 / 30);
        for (final p in g.slots) {
          if (p != null && p.kind != RushKind.sleepy && !life.contains(p.lifetime)) life.add(p.lifetime);
        }
      }
      expect(life.first, greaterThan(life.last));
    });

    test('never more critters out than the ramp allows', () {
      for (var seed = 1; seed <= 5; seed++) {
        final g = BoopRushGame(seed: seed);
        var guard = 0;
        while (!g.finished && guard++ < 10000) {
          g.update(1 / 30);
          expect(g.liveCount, lessThanOrEqualTo(BoopRushGame.maxLiveAt(g.progress)), reason: 'seed $seed at ${g.elapsed}');
        }
      }
    });
  });

  group('determinism', () {
    test('the same seed gives the same round', () {
      expect(spawns(BoopRushGame(seed: 42), 1 / 60), spawns(BoopRushGame(seed: 42), 1 / 60));
    });

    test('and the frame rate does not change it', () {
      final fine = spawns(BoopRushGame(seed: 7), 1 / 120).map((s) => (s.$1, s.$2, s.$3)).toList();
      final coarse = spawns(BoopRushGame(seed: 7), 0.1).map((s) => (s.$1, s.$2, s.$3)).toList();
      expect(coarse, fine);
      expect(fine, isNotEmpty);
    });

    test('different seeds give different rounds', () {
      expect(spawns(BoopRushGame(seed: 1), 1 / 30), isNot(spawns(BoopRushGame(seed: 2), 1 / 30)));
    });

    test('critter looks stay inside the given count', () {
      final list = spawns(BoopRushGame(seed: 3, critterCount: 3), 1 / 30);
      expect(list.map((s) => s.$3).toSet().difference({0, 1, 2}), isEmpty);
      expect(list.map((s) => s.$3).toSet().length, greaterThan(1));
    });
  });
}
