import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:mofu_pet/creatures/creature.dart';
import 'package:mofu_pet/creatures/mofu/mofu_creature.dart';
import 'package:mofu_pet/creatures/oink/oink_creature.dart';
import 'package:mofu_pet/world/spa_session.dart';

Creature _placed(Creature c) {
  c.layout(const Rect.fromLTWH(0, 0, 400, 800), floorY: 620);
  for (var i = 0; i < 30; i++) {
    c.update(1 / 60);
  }
  return c;
}

/// Scribbles over the body for [seconds] at a brisk speed.
void scrub(SpaSession s, double seconds, {Offset offset = Offset.zero}) {
  final c = s.creature;
  for (var i = 0; i < (seconds * 60).round(); i++) {
    final t = i / 60;
    final p = c.position + offset + Offset(c.radius * 0.7 * (t * 3 % 2 - 1), c.radius * 0.4 * ((t * 1.7) % 2 - 1));
    s.rub(p, 700, 1 / 60);
    c.update(1 / 60);
  }
}

/// Scrubs until the step changes; returns the seconds it took.
double untilNext(SpaSession s, {Offset offset = Offset.zero, double max = 30}) {
  final start = s.step;
  var t = 0.0;
  while (s.step == start && t < max) {
    scrub(s, 0.25, offset: offset);
    t += 0.25;
  }
  return t;
}

void main() {
  test('a full routine walks foam → rinse → towel → dry → done and shines', () {
    final c = _placed(MofuCreature(friendId: 'm', seed: 2));
    final s = SpaSession(c);
    expect(c.pinned, isTrue);
    final steps = <double>[];
    steps.add(untilNext(s));
    expect(s.step, SpaStep.rinse, reason: 'enough foam advances to rinse');
    expect(c.care.foam.length, greaterThanOrEqualTo(SpaSession.foamTarget));
    steps.add(untilNext(s, offset: Offset(0, -c.radius * 0.5)));
    expect(s.step, SpaStep.towel, reason: 'foam rinsed off and fur soaked');
    expect(c.care.foam, isEmpty);
    expect(c.care.wet, greaterThan(0.6), reason: "soaked (the towel may already have started)");
    steps.add(untilNext(s));
    expect(s.step, SpaStep.dry);
    expect(c.care.wet, 0);
    steps.add(untilNext(s));
    expect(s.finished, isTrue);
    for (final t in steps) {
      expect(t, inInclusiveRange(1.5, 12), reason: 'each step lasts long enough to enjoy, never a chore: $steps');
    }
    expect(c.care.shine, 1);
    expect(c.pinned, isFalse);
    expect(s.drainCues(), contains('spa.done'));
  });

  test('foam scrubs mud off a muddy pig', () {
    final c = _placed(OinkCreature(friendId: 'o', seed: 2));
    c.care.mud.addAll([FoamBlob(const Offset(0.2, 0.1), 0.15, 0), FoamBlob(const Offset(-0.3, 0.2), 0.12, 0)]);
    final s = SpaSession(c);
    scrub(s, 8);
    expect(c.care.mud, isEmpty);
    expect(s.step, isNot(SpaStep.foam));
  });

  test('rubbing off the body does nothing', () {
    final c = _placed(MofuCreature(friendId: 'm', seed: 2));
    final s = SpaSession(c);
    for (var i = 0; i < 300; i++) {
      s.rub(const Offset(5, 5), 900, 1 / 60);
    }
    expect(c.care.foam, isEmpty);
    expect(s.progress, 0);
  });

  test('abandon rinses and unpins without a reward', () {
    final c = _placed(MofuCreature(friendId: 'm', seed: 2));
    final s = SpaSession(c);
    scrub(s, 2);
    s.abandon();
    expect(c.care.foam, isEmpty);
    expect(c.pinned, isFalse);
    expect(c.care.shine, 0);
  });
}
