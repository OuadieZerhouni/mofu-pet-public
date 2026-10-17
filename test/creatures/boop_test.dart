import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:mofu_pet/creatures/boop/boop_art.dart';
import 'package:mofu_pet/creatures/boop/boop_catalog.dart';
import 'package:mofu_pet/creatures/boop/boop_creature.dart';
import 'package:mofu_pet/creatures/creature.dart';

import 'contract.dart';

const _room = Rect.fromLTWH(0, 0, 400, 800);

BoopCreature _boop({String? variant, bool reduceMotion = false}) {
  final c = BoopCreature(friendId: 'b1', seed: 3, variant: variant ?? boopVariants.first.id)
    ..reduceMotion = reduceMotion
    ..layout(_room, floorY: 620);
  for (var i = 0; i < 30; i++) {
    c.update(1 / 60);
  }
  c.drainEvents();
  return c;
}

/// A point on the body that is not the nose.
Offset _forehead(BoopCreature c) => c.position + Offset(0, -c.b * 0.7);

int _nextPointer = 100;

/// A quick tap: down, a few frames, up.
void _tap(BoopCreature c, Offset p, {double hold = 0.05}) {
  final id = _nextPointer++;
  c.pointerDown(id, p);
  c.update(hold);
  c.pointerUp(id, p);
}

List<CreatureEvent> _tapEvents(BoopCreature c, Offset p) {
  _tap(c, p);
  return c.drainEvents();
}

bool _isSqueak(CreatureEvent e) => e.type == CreatureEventType.sound && e.id.startsWith('boop.boop_');

void main() {
  runCreatureContract('boop', () => BoopCreature(friendId: 'b1', seed: 3, variant: boopVariants.first.id));

  group('catalog', () {
    test('twelve distinct variants, at least twelve reactions, every sound is a boop. id', () {
      expect(boopVariants, hasLength(12));
      expect({for (final v in boopVariants) v.id}, hasLength(12));
      expect(boopReactions.length, greaterThanOrEqualTo(12));
      expect(boopReactions.every((r) => r.id.startsWith('boop.')), isTrue);
      expect(boopSounds.keys.every((k) => k.startsWith('boop.')), isTrue);
      expect(boopSqueakId(3, 1), 'boop.boop_03');
      expect(boopSqueakId(6, 100), 'boop.boop_13');
    });

    test('every emitted sound and reaction id exists in the catalog', () {
      final c = _boop(variant: 'pip');
      final seen = <CreatureEvent>[];
      void collect() => seen.addAll(c.drainEvents());
      for (var i = 0; i < 60; i++) {
        _tap(c, c.nosePos, hold: 0.1);
        collect();
      }
      _tap(c, _forehead(c));
      collect();
      c.react(SocialCue.nuzzled, from: const Offset(50, 600));
      c.react(SocialCue.landedOnMe);
      c.celebrate();
      c.eat(favorite: true);
      c.eat(favorite: false);
      c.refuseFull();
      c.groom(c.position, 600, tool: 'foam');
      collect();
      final reactionIds = {for (final r in boopReactions) r.id};
      for (final e in seen) {
        if (e.type == CreatureEventType.sound) expect(boopSounds, contains(e.id));
        if (e.type == CreatureEventType.reaction) expect(reactionIds, contains(e.id));
      }
    });
  });

  group('boop behaviour', () {
    test('a nose tap counts a boop with a squeak, a light haptic and a heart', () {
      final c = _boop();
      expect(c.hitNose(c.nosePos), isTrue);
      final evs = _tapEvents(c, c.nosePos);
      expect(c.combo, 1);
      expect(c.totalBoops, 1);
      expect(evs.where(_isSqueak), hasLength(1));
      expect(evs.any((e) => e.type == CreatureEventType.haptic && e.id == 'light'), isTrue);
      expect(c.particles.any((p) => p.kind == BoopParticleKind.heart), isTrue);
    });

    test('a body tap wobbles and giggles but is not a boop', () {
      final c = _boop();
      final p = _forehead(c);
      expect(c.hitNose(p), isFalse);
      final evs = _tapEvents(c, p);
      expect(c.totalBoops, 0);
      expect(c.combo, 0);
      expect(evs.where(_isSqueak), isEmpty);
      expect(evs.any((e) => e.type == CreatureEventType.sound && e.id == 'boop.giggle'), isTrue);
    });

    test('squeak pitch rises within a combo', () {
      final c = _boop(variant: 'bao');
      final ids = <String>[];
      for (var i = 0; i < 10; i++) {
        _tap(c, c.nosePos, hold: 0.1);
        ids.addAll(c.drainEvents().where(_isSqueak).map((e) => e.id));
      }
      expect(ids, hasLength(10));
      expect(ids.first, 'boop.boop_01');
      expect(ids.last, 'boop.boop_04');
    });

    test('boops under 1.0 s apart chain; a longer gap resets', () {
      final c = _boop();
      for (var i = 0; i < 4; i++) {
        c.pointerDown(i + 1, c.nosePos);
        c.pointerUp(i + 1, c.nosePos);
        for (var k = 0; k < 4; k++) {
          c.update(0.1);
        }
      }
      expect(c.combo, 4);
      expect(c.bestCombo, 4);
      for (var i = 0; i < 7; i++) {
        c.update(0.1); // 1.1 s since the last boop
      }
      expect(c.combo, 0);
      c.pointerDown(9, c.nosePos);
      c.pointerUp(9, c.nosePos);
      expect(c.combo, 1);
      expect(c.bestCombo, 4, reason: 'best combo is kept for the session');
    });

    test('tier events fire at 10, 25 and 50', () {
      final c = _boop();
      final progress = <double>[];
      final bubbles = <String>[];
      for (var i = 0; i < 50; i++) {
        c.pointerDown(1, c.nosePos);
        c.pointerUp(1, c.nosePos);
        c.update(0.1);
        for (final e in c.drainEvents()) {
          if (e.type == CreatureEventType.progress && e.id == 'combo') progress.add(e.value);
          if (e.type == CreatureEventType.bubble) bubbles.add(e.id);
        }
      }
      expect(progress, [10, 25, 50]);
      expect(bubbles, containsAll(['bubble.combo10', 'bubble.combo25', 'bubble.combo50']));
      expect(c.bestCombo, 50);
    });

    test('the 30th boop of a combo sneezes, and no other does', () {
      final c = _boop();
      var sneezes = 0;
      var atBoop = 0;
      for (var i = 1; i <= 30; i++) {
        c.pointerDown(1, c.nosePos);
        c.pointerUp(1, c.nosePos);
        for (final e in c.drainEvents()) {
          if (e.type == CreatureEventType.sound && e.id == 'boop.sneeze') {
            sneezes++;
            atBoop = i;
          }
        }
        if (i < 30) c.update(0.1);
      }
      expect(sneezes, 1);
      expect(atBoop, 30);
      expect(c.pose.face, BoopFace.surprised);
    });

    test('holding on the body for 0.6 s becomes a hug with hearts, and is not a boop', () {
      final c = _boop();
      final p = _forehead(c);
      c.pointerDown(1, p);
      for (var i = 0; i < 25; i++) {
        c.update(1 / 60);
      }
      expect(c.pose.face, isNot(BoopFace.hug), reason: 'not yet at 0.42 s');
      for (var i = 0; i < 30; i++) {
        c.update(1 / 60);
      }
      expect(c.pose.face, BoopFace.hug);
      final evs = c.drainEvents();
      expect(evs.any((e) => e.type == CreatureEventType.reaction && e.id == 'boop.hug'), isTrue);
      expect(evs.any((e) => e.type == CreatureEventType.sound && e.id == 'boop.hug'), isTrue);
      for (var i = 0; i < 120; i++) {
        c.update(1 / 60);
      }
      expect(c.particles.where((q) => q.kind == BoopParticleKind.heart), isNotEmpty);
      c.pointerUp(1, p);
      c.update(1 / 60);
      expect(c.pose.face, isNot(BoopFace.hug));
      expect(c.totalBoops, 0);
    });

    test('dragging stretches toward the finger and springs back', () {
      final c = _boop();
      final p = _forehead(c);
      c.pointerDown(1, p);
      for (var i = 1; i <= 20; i++) {
        c.pointerMove(1, p + Offset(i * 4.0, 0));
        c.update(1 / 60);
      }
      expect(c.pose.shear.dx, greaterThan(0.2));
      c.pointerUp(1, p + const Offset(80, 0));
      for (var i = 0; i < 180; i++) {
        c.update(1 / 60);
      }
      expect(c.pose.shear.dx.abs(), lessThan(0.01));
      expect(c.totalBoops, 0);
    });

    test('goes sleepy after 30 s idle and falls asleep after 60 s; touch wakes it', () {
      final c = _boop();
      for (var i = 0; i < 31 * 60; i++) {
        c.update(1 / 60);
      }
      expect(c.pose.face, BoopFace.sleepy);
      expect(c.asleep, isFalse);
      expect(c.particles.any((p) => p.kind == BoopParticleKind.zzz), isTrue);
      for (var i = 0; i < 31 * 60; i++) {
        c.update(1 / 60);
      }
      expect(c.asleep, isTrue);
      expect(c.pose.face, BoopFace.asleep);
      c.pointerDown(1, c.nosePos);
      c.pointerUp(1, c.nosePos);
      expect(c.asleep, isFalse);
    });

    test('nuzzled boops back without touching the player combo', () {
      final c = _boop();
      c.react(SocialCue.nuzzled, from: const Offset(100, 600));
      final evs = c.drainEvents();
      expect(evs.any((e) => e.type == CreatureEventType.reaction && e.id == 'boop.boopBack'), isTrue);
      expect(evs.where(_isSqueak), hasLength(1));
      expect(c.combo, 0);
      expect(c.totalBoops, 0);
    });

    test('reduce motion keeps the feedback but drops the motion', () {
      final c = _boop(reduceMotion: true);
      final evs = _tapEvents(c, c.nosePos);
      expect(evs.where(_isSqueak), hasLength(1));
      expect(c.particles.where((p) => p.kind == BoopParticleKind.heart), isEmpty);
      expect(c.pose.squashY, greaterThan(0.9));
    });

    test('a long random session never produces NaN', () {
      final c = _boop();
      var i = 0;
      for (var f = 0; f < 3000; f++) {
        if (f % 7 == 0) _tap(c, c.position + Offset((i * 13 % 60) - 30.0, (i * 7 % 50) - 25.0), hold: 0.02);
        if (f % 211 == 0) c.groom(c.position, 800, tool: 'foam');
        if (f % 97 == 0) c.nudge(Offset((i % 2 == 0 ? 1 : -1) * 3000.0, -500));
        i++;
        c.update(f.isEven ? 1 / 60 : 0.1);
        final p = c.position;
        expect(p.dx.isFinite && p.dy.isFinite, isTrue);
        expect(c.pose.squashX.isFinite && c.pose.squashY.isFinite && c.pose.tilt.isFinite, isTrue);
      }
    });
  });

  group('art', () {
    test('every variant paints without throwing, in every face', () {
      const art = BoopArt();
      for (final v in boopVariants) {
        final c = _boop(variant: v.id);
        final look = CreatureLook(variant: v.id);
        for (var step = 0; step < 6; step++) {
          switch (step) {
            case 1:
              _tap(c, c.nosePos);
            case 2:
              c.pointerDown(77, _forehead(c));
              for (var i = 0; i < 40; i++) {
                c.update(1 / 60);
              }
            case 3:
              c.pointerUp(77, _forehead(c));
              c.eat(favorite: true);
              c.update(0.2);
            case 4:
              c.sleep();
              c.update(0.5);
            case 5:
              c.wake();
              c.react(SocialCue.celebrate);
              c.update(0.1);
          }
          final recorder = PictureRecorder();
          final canvas = Canvas(recorder, _room);
          art.paint(canvas, c, look);
          art.paint(canvas, c, look, shadow: false);
          recorder.endRecording();
        }
      }
    });
  });
}
