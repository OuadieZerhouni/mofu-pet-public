import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:mofu_pet/creatures/boop/boop_creature.dart';
import 'package:mofu_pet/creatures/mofu/mofu_creature.dart';
import 'package:mofu_pet/sim/mofu_sim.dart' show MofuMode;
import 'package:mofu_pet/world/room_scene.dart';

void main() {
  RoomScene scene({int n = 2}) {
    final s = RoomScene()..layout(const Rect.fromLTWH(0, 0, 400, 800), floorY: 620);
    s.add(MofuCreature(friendId: 'm', seed: 1));
    if (n > 1) s.add(BoopCreature(friendId: 'b', seed: 2, variant: 'mochi'));
    if (n > 2) s.add(BoopCreature(friendId: 'c', seed: 3, variant: 'pip'));
    return s;
  }

  void run(RoomScene s, double seconds) {
    for (var i = 0; i < (seconds * 60).round(); i++) {
      s.update(1 / 60);
    }
  }

  test('friends arrive spread out and never overlap for long', () {
    final s = scene(n: 3);
    run(s, 3);
    final xs = s.creatures.map((c) => c.position.dx).toList()..sort();
    for (var i = 1; i < xs.length; i++) {
      expect(xs[i] - xs[i - 1], greaterThan(30));
    }
  });

  test('two friends placed on the same spot drift apart', () {
    final s = scene();
    for (final c in s.creatures) {
      c.position = Offset(200, c.position.dy);
    }
    run(s, 2);
    final a = s.creatures[0], b = s.creatures[1];
    expect((a.position.dx - b.position.dx).abs(), greaterThan((a.radius + b.radius) * 0.6));
  });

  test('pointer goes to the friend under the finger; others look at it', () {
    final s = scene();
    run(s, 1);
    final b = s.byId('b')!;
    final owner = s.pointerDown(1, b.position);
    expect(owner, same(b));
    expect(b.activePointer, 1);
    s.pointerUp(1, b.position);
    run(s, 0.2);
    expect(s.drainEvents().any((e) => e.friendId == 'b'), isTrue);
  });

  test('empty floor does not claim the pointer', () {
    final s = scene();
    expect(s.pointerDown(1, const Offset(5, 5)), isNull);
  });

  test('a friend landing next to another triggers a pile-up', () {
    final s = scene();
    run(s, 1);
    final m = s.byId('m')! as MofuCreature;
    final b = s.byId('b')!;
    // Throw Mofu straight down onto the Boop.
    m.sim.mode = MofuMode.air;
    m.sim.pos = Offset(b.position.dx, 200);
    m.sim.vel = const Offset(0, 300);
    run(s, 1.5);
    final moments = s.drainMoments();
    expect(moments.any((mo) => mo.$1 == GroupMoment.pileUp && mo.$3 == 'b'), isTrue);
  });

  test('idle friends nuzzle now and then', () {
    final s = scene();
    for (final c in s.creatures) {
      c.position = Offset(c.position.dx < 200 ? 160 : 260, c.position.dy);
    }
    run(s, 40);
    expect(s.drainMoments().any((m) => m.$1 == GroupMoment.nuzzle), isTrue);
  });

  test('sleepAll puts everyone to sleep, paint order is stable and complete', () {
    final s = scene(n: 3)..sleepAll();
    run(s, 0.5);
    expect(s.creatures.every((c) => c.asleep), isTrue);
    expect(s.paintOrder.length, 3);
  });
}
