import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:mofu_pet/creatures/boop/boop_creature.dart';
import 'package:mofu_pet/creatures/mofu/mofu_creature.dart';
import 'package:mofu_pet/creatures/oink/oink_creature.dart';
import 'package:mofu_pet/creatures/wuff/wuff_creature.dart';
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

  // F2-c2: the others turn to look at the friend being touched.
  test('touching a friend makes the others look at it', () {
    final s = RoomScene()..layout(const Rect.fromLTWH(0, 0, 400, 800), floorY: 620);
    final a = MofuCreature(friendId: 'a', seed: 1), b = MofuCreature(friendId: 'b', seed: 2);
    s
      ..add(a)
      ..add(b);
    run(s, 1);
    expect(a.sim.lookTarget, isNull);
    s.pointerDown(1, b.position);
    run(s, 0.1);
    expect(a.sim.lookTarget, isNotNull);
    expect((a.sim.lookTarget! - b.position).distance, lessThan(b.radius * 2));
    s.pointerUp(1, b.position);
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

  // F2-c2: a nuzzle's mutual gaze lets go, so idle glances resume.
  test('after a nuzzle both friends stop staring and glance around again', () {
    final s = RoomScene()..layout(const Rect.fromLTWH(0, 0, 400, 800), floorY: 620);
    final a = MofuCreature(friendId: 'a', seed: 1), b = MofuCreature(friendId: 'b', seed: 2);
    s
      ..add(a)
      ..add(b);
    a.position = Offset(160, a.position.dy);
    b.position = Offset(260, b.position.dy);
    var nuzzled = false;
    for (var i = 0; i < 60 * 40 && !nuzzled; i++) {
      s.update(1 / 60);
      nuzzled = s.drainMoments().any((m) => m.$1 == GroupMoment.nuzzle);
    }
    expect(nuzzled, isTrue);
    expect(a.sim.lookTarget != null || b.sim.lookTarget != null, isTrue);
    run(s, 3);
    expect(a.sim.lookTarget, isNull);
    expect(b.sim.lookTarget, isNull);
  });

  test('sleepAll puts everyone to sleep, paint order is stable and complete', () {
    final s = scene(n: 3)..sleepAll();
    run(s, 0.5);
    expect(s.creatures.every((c) => c.asleep), isTrue);
    expect(s.paintOrder.length, 3);
  });

  test('a full room of four species fits inside the walls and stands on the floor', () {
    for (final w in [375.0, 440.0]) {
      final s = RoomScene()..layout(Rect.fromLTWH(0, 180, w, 400), floorY: 580, sizeScale: w / 390);
      s
        ..add(OinkCreature(friendId: 'o', seed: 1))
        ..add(MofuCreature(friendId: 'm', seed: 2))
        ..add(WuffCreature(friendId: 'w', seed: 3))
        ..add(BoopCreature(friendId: 'b', seed: 4, variant: 'mochi'));
      run(s, 8);
      expect(s.crowdScale, lessThan(1));
      for (final c in s.creatures) {
        expect(c.bounds.left, greaterThanOrEqualTo(-2), reason: '${c.friendId} @ $w');
        expect(c.bounds.right, lessThanOrEqualTo(w + 2), reason: '${c.friendId} @ $w');
        expect(c.footPoint.dy, closeTo(580, 1.5), reason: '${c.friendId} @ $w');
      }
      // Moving to a room with a higher floor keeps everyone on it.
      s.layout(Rect.fromLTWH(0, 180, w, 300), floorY: 480, sizeScale: w / 390);
      run(s, 1);
      for (final c in s.creatures) {
        expect(c.footPoint.dy, closeTo(480, 1.5), reason: '${c.friendId} relayout @ $w');
      }
    }
  });

  test('a lone friend in the garden is placed off the nest, and settle() respects it', () {
    final s = RoomScene()
      ..layout(const Rect.fromLTWH(0, 120, 390, 500), floorY: 620)
      ..keepOut = const [(0.36, 0.64)];
    final o = OinkCreature(friendId: 'o', seed: 1);
    s.add(o);
    expect(o.position.dx < 390 * 0.36 || o.position.dx > 390 * 0.64, isTrue, reason: 'spawned beside the nest');
    o.position = Offset(195, o.position.dy); // e.g. an old save in the middle
    s.settle();
    expect(o.position.dx < 390 * 0.36 || o.position.dx > 390 * 0.64, isTrue, reason: 'settled beside the nest');
  });
}
