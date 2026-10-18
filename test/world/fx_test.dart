import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:mofu_pet/creatures/boop/boop_creature.dart';
import 'package:mofu_pet/creatures/mofu/mofu_creature.dart';
import 'package:mofu_pet/creatures/oink/oink_creature.dart';
import 'package:mofu_pet/creatures/wuff/wuff_creature.dart';
import 'package:mofu_pet/world/fx.dart';
import 'package:mofu_pet/world/room_scene.dart';

void main() {
  test('effects are deterministic, start empty and end on time', () {
    for (final kind in FxKind.values) {
      final fx = Fx(kind, const Offset(100, 100), 2, seed: 7);
      expect(particlesOf(fx, 1.9), isEmpty, reason: '$kind before birth');
      final mid = 2 + fx.duration / 2;
      final a = particlesOf(fx, mid), b = particlesOf(Fx(kind, const Offset(100, 100), 2, seed: 7), mid);
      expect(a, isNotEmpty, reason: '$kind mid-way');
      expect([for (final p in a) p.pos], [for (final p in b) p.pos], reason: '$kind same seed, same path');
      expect(particlesOf(fx, 2 + fx.duration + 0.01), isEmpty, reason: '$kind after its end');
      for (final p in a) {
        expect(p.alpha, inInclusiveRange(0, 1));
        expect(p.pos.dx.isFinite && p.pos.dy.isFinite, isTrue);
      }
    }
  });

  test('a drop-in falls from above, lands at the impact time, squashes, and rests', () {
    const e = Entrance(EntranceStyle.drop, 0);
    const foot = Offset(200, 600);
    final start = entrancePose(e, 0.01, 50, foot);
    expect(start.dy, lessThan(-100), reason: 'starts well above the floor');
    expect(start.alpha, lessThan(1), reason: 'fades in');
    final landed = entrancePose(e, Entrance.impact + 0.001, 50, foot);
    expect(landed.dy, 0);
    expect(landed.sx, greaterThan(1.1), reason: 'squashes wide on impact');
    expect(landed.sy, lessThan(0.9));
    expect(identical(entrancePose(e, Entrance.duration + 0.01, 50, foot), EntrancePose.rest), isTrue);
  });

  test('a pop entrance starts at the egg and ends on the friend', () {
    const foot = Offset(300, 600);
    const egg = Offset(200, 560);
    const e = Entrance(EntranceStyle.pop, 0, from: egg);
    final first = entrancePose(e, 0.0, 50, foot);
    expect(Offset(foot.dx + first.dx, foot.dy + first.dy), offsetMoreOrLessEquals(egg, epsilon: 1));
    expect(first.sx, lessThan(0.5), reason: 'small as it comes out');
    final settled = entrancePose(e, Entrance.duration - 0.01, 50, foot);
    expect(settled.dx.abs() + settled.dy.abs(), lessThan(2));
  });

  test('neighbours are eased apart, never kicked, when a friend bursts or arrives', () {
    final s = RoomScene()..layout(const Rect.fromLTWH(0, 120, 440, 700), floorY: 820, sizeScale: 440 / 390);
    s
      ..add(BoopCreature(friendId: 'b', seed: 4, variant: 'mochi'))
      ..add(OinkCreature(friendId: 'o', seed: 1))
      ..add(MofuCreature(friendId: 'm', seed: 2))
      ..add(WuffCreature(friendId: 'w', seed: 3));
    s.settle();
    for (var i = 0; i < 120; i++) {
      s.update(1 / 60);
    }
    final mofu = s.byId('m')!;
    mofu.pointerDown(1, mofu.position);
    mofu.pointerUp(1, mofu.position);
    var last = {for (final c in s.creatures) c: c.position.dx};
    for (var i = 0; i < 60; i++) {
      s.update(1 / 60);
      for (final c in s.creatures) {
        if (c == mofu) continue;
        final step = (c.position.dx - last[c]!).abs();
        // Own walking aside, the room may add at most maxPush px/s.
        expect(step, lessThan(RoomScene.maxPush / 60 + 6), reason: '${c.friendId} frame $i moved ${step.toStringAsFixed(1)} px');
      }
      last = {for (final c in s.creatures) c: c.position.dx};
    }
  });
}
