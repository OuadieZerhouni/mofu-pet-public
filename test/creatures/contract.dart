// Shared behavioural contract every species must pass. Each species test file
// calls `runCreatureContract('oink', () => OinkCreature(friendId: 'f1', seed: 3))`.
import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:mofu_pet/creatures/creature.dart';

const _room = Rect.fromLTWH(0, 0, 400, 800);
const _floor = 620.0;

Creature _placed(Creature Function() make) {
  final c = make()..layout(_room, floorY: _floor);
  for (var i = 0; i < 120; i++) {
    c.update(1 / 60);
  }
  return c;
}

bool _finite(Offset o) => o.dx.isFinite && o.dy.isFinite;

void runCreatureContract(String name, Creature Function() make) {
  group('$name creature contract', () {
    test('settles on the floor inside the room, finite everywhere', () {
      final c = _placed(make);
      expect(_finite(c.position), isTrue);
      expect(_room.inflate(1).contains(c.position), isTrue);
      expect((c.footPoint.dy - _floor).abs(), lessThan(c.radius * 0.6), reason: 'feet rest near the floor');
      expect(c.radius, greaterThan(20));
      expect(c.bounds.contains(c.position), isTrue);
      expect(c.silhouette.contains(c.position), isTrue, reason: 'silhouette covers the body centre');
    });

    test('survives odd frame times and a resize without NaN', () {
      final c = _placed(make);
      for (final dt in [0.0, 0.1, 0.0001, 0.1, 0.016]) {
        c.update(dt);
      }
      c.layout(const Rect.fromLTWH(0, 0, 320, 560), floorY: 440);
      for (var i = 0; i < 60; i++) {
        c.update(1 / 60);
      }
      expect(_finite(c.position), isTrue);
      expect(c.position.dx, inInclusiveRange(0, 320));
    });

    test('claims a pointer on its body, ignores one far away', () {
      final c = _placed(make);
      expect(c.pointerDown(1, const Offset(5, 5)), isFalse);
      expect(c.pointerDown(2, c.position), isTrue);
      expect(c.activePointer, 2);
      c.pointerUp(2, c.position);
      c.update(1 / 60);
      expect(c.activePointer, isNull);
    });

    test('a tap produces feedback events (sound or haptic) within a few frames', () {
      final c = _placed(make);
      c.drainEvents();
      c.pointerDown(1, c.position);
      c.update(0.05);
      c.pointerUp(1, c.position);
      final evs = <CreatureEvent>[];
      for (var i = 0; i < 6; i++) {
        c.update(1 / 60);
        evs.addAll(c.drainEvents());
      }
      expect(evs.any((e) => e.type == CreatureEventType.sound || e.type == CreatureEventType.haptic), isTrue,
          reason: 'every touch gives feedback within 100 ms');
      expect(c.drainEvents(), isEmpty, reason: 'drain empties the queue');
    });

    test('sleep and wake', () {
      final c = _placed(make);
      c.sleep();
      for (var i = 0; i < 30; i++) {
        c.update(1 / 60);
      }
      expect(c.asleep, isTrue);
      c.wake();
      for (var i = 0; i < 30; i++) {
        c.update(1 / 60);
      }
      expect(c.asleep, isFalse);
    });

    test('feeding: mouth is on the body, eat and refuse emit events', () {
      final c = _placed(make);
      expect(c.nearMouth(c.mouth), isTrue);
      expect(c.bounds.contains(c.mouth), isTrue);
      c.drainEvents();
      c.eat(favorite: true);
      for (var i = 0; i < 90; i++) {
        c.update(1 / 60);
      }
      expect(c.drainEvents(), isNotEmpty);
      c.refuseFull();
      c.update(1 / 60);
      expect(c.drainEvents(), isNotEmpty);
    });

    test('pinned creatures do not wander or get picked up; grooming reacts', () {
      final c = _placed(make)..pinned = true;
      final start = c.position;
      for (var i = 0; i < 600; i++) {
        c.update(1 / 60);
      }
      expect((c.position - start).distance, lessThan(c.radius * 0.5));
      c.drainEvents();
      for (var i = 0; i < 30; i++) {
        c.groom(c.position + Offset(c.radius * 0.3 * (i.isEven ? 1 : -1), 0), 600, tool: 'foam');
        c.update(1 / 60);
      }
      expect(c.drainEvents(), isNotEmpty, reason: 'grooming gives feedback');
    });

    test('anchors sit on the creature', () {
      final c = _placed(make);
      for (final s in AccessorySlot.values) {
        final a = c.anchor(s);
        expect(_finite(a.at), isTrue);
        expect(c.bounds.inflate(c.radius * 0.6).contains(a.at), isTrue, reason: '$s anchor near the body');
        expect(a.scale, greaterThan(0));
      }
    });

    test('nudges move it and it stays inside the room', () {
      final c = _placed(make);
      for (var i = 0; i < 30; i++) {
        c.nudge(const Offset(-4000, 0));
        c.update(1 / 60);
      }
      expect(c.position.dx, greaterThanOrEqualTo(0));
      for (var i = 0; i < 120; i++) {
        c.update(1 / 60);
      }
      expect(_finite(c.position), isTrue);
    });

    test('social cues and lookAt never throw', () {
      final c = _placed(make);
      c.lookAt(const Offset(10, 10));
      for (final cue in SocialCue.values) {
        c.react(cue, from: const Offset(100, 600));
        c.update(1 / 60);
      }
      c.lookAt(null);
      c.celebrate();
      for (var i = 0; i < 60; i++) {
        c.update(1 / 60);
      }
      expect(_finite(c.position), isTrue);
    });
  });
}
