import 'dart:io';
import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:mofu_pet/creatures/creature.dart';
import 'package:mofu_pet/creatures/wuff/wuff_art.dart';
import 'package:mofu_pet/creatures/wuff/wuff_catalog.dart';
import 'package:mofu_pet/creatures/wuff/wuff_creature.dart';

import 'contract.dart';

const _room = Rect.fromLTWH(0, 0, 400, 800);

WuffCreature _pup({int seed = 3}) {
  final c = WuffCreature(friendId: 'w1', seed: seed)..layout(_room, floorY: 620);
  for (var i = 0; i < 120; i++) {
    c.update(1 / 60);
  }
  c.drainEvents();
  return c;
}

/// Runs [seconds] of frames and returns every event produced.
List<CreatureEvent> _run(WuffCreature c, double seconds) {
  final out = <CreatureEvent>[];
  for (var i = 0; i < (seconds * 60).round(); i++) {
    c.update(1 / 60);
    out.addAll(c.drainEvents());
  }
  return out;
}

/// A quick tap at [p]; returns events from the tap and the next frames.
List<CreatureEvent> _tap(WuffCreature c, Offset p) {
  final out = <CreatureEvent>[];
  expect(c.pointerDown(1, p), isTrue);
  c.update(0.05);
  c.pointerUp(1, p);
  out.addAll(c.drainEvents());
  out.addAll(_run(c, 0.2));
  return out;
}

bool _has(List<CreatureEvent> evs, CreatureEventType t, [bool Function(String id)? idOk]) =>
    evs.any((e) => e.type == t && (idOk == null || idOk(e.id)));

void main() {
  runCreatureContract('wuff', () => WuffCreature(friendId: 'w1', seed: 3));

  group('wuff species', () {
    test('is a wuff, sized from the room width', () {
      final c = _pup();
      expect(c.species, Species.wuff);
      expect(c.radius, closeTo(400 * 0.15, 0.001));
      final big = WuffCreature(friendId: 'w2', seed: 1)..layout(_room, floorY: 620, sizeScale: 1.5);
      expect(big.radius, closeTo(400 * 0.15 * 1.5, 0.001));
    });

    test('ear scratch: back leg thumps, loop and journal reaction', () {
      final c = _pup();
      final ear = c.toRoom(c.earPivot(1) + (c.earTip(1) - c.earPivot(1)) * 0.92);
      expect(c.regionAt(ear), WuffRegion.earR);
      expect(c.pointerDown(1, ear), isTrue);
      final evs = <CreatureEvent>[];
      var p = ear;
      var dir = 1.0;
      for (var i = 0; i < 90; i++) {
        p = ear + Offset(0, dir * 14);
        dir = -dir;
        c.pointerMove(1, p);
        c.update(1 / 60);
        evs.addAll(c.drainEvents());
      }
      expect(c.thump, greaterThan(0), reason: 'the leg thumps while the ear is scratched');
      expect(_has(evs, CreatureEventType.loopStart, (id) => id == 'wuff.thump'), isTrue);
      expect(_has(evs, CreatureEventType.reaction, (id) => id == 'wuff.earScratch'), isTrue);
      c.pointerUp(1, p);
      final after = _run(c, 0.2);
      expect(_has(after, CreatureEventType.loopStop, (id) => id == 'wuff.thump'), isTrue);
      expect(_has(evs + after, CreatureEventType.progress, (id) => id == 'bond'), isTrue);
    });

    test('chin scratch gives a blep', () {
      final c = _pup();
      final chin = c.toRoom(c.chin);
      expect(c.pointerDown(1, chin), isTrue);
      final evs = <CreatureEvent>[];
      for (var i = 0; i < 80; i++) {
        c.pointerMove(1, chin + Offset(i.isEven ? 10 : -10, 0));
        c.update(1 / 60);
        evs.addAll(c.drainEvents());
      }
      expect(c.blep, greaterThan(0.5));
      expect(_has(evs, CreatureEventType.reaction, (id) => id == 'wuff.blep'), isTrue);
    });

    test('nose boop: a wuff.* sound, then a sneeze', () {
      final c = _pup();
      final nose = c.toRoom(c.nose);
      expect(c.regionAt(nose), WuffRegion.nose);
      final evs = _tap(c, nose);
      expect(evs.where((e) => e.type == CreatureEventType.sound), isNotEmpty);
      for (final e in evs.where((e) => e.type == CreatureEventType.sound)) {
        expect(e.id, startsWith('wuff.'));
      }
      final more = _run(c, 1.2);
      expect(_has(evs + more, CreatureEventType.sound, (id) => id == 'wuff.sneeze'), isTrue);
      expect(_has(evs + more, CreatureEventType.reaction, (id) => id == 'wuff.achoo'), isTrue);
    });

    test('three boops make a big sneeze', () {
      final c = _pup();
      final nose = c.toRoom(c.nose);
      final evs = <CreatureEvent>[];
      for (var i = 0; i < 3; i++) {
        evs.addAll(_tap(c, nose));
        evs.addAll(_run(c, 0.2));
      }
      evs.addAll(_run(c, 2));
      expect(_has(evs, CreatureEventType.sound, (id) => id == 'wuff.bigsneeze'), isTrue);
    });

    test('five quick taps start the zoomies', () {
      final c = _pup();
      final evs = <CreatureEvent>[];
      for (var i = 0; i < 5; i++) {
        evs.addAll(_tap(c, c.position));
      }
      expect(_has(evs, CreatureEventType.reaction, (id) => id == 'wuff.zoomies'), isTrue);
    });

    test('hold: snuggle, then love', () {
      final c = _pup();
      expect(c.pointerDown(1, c.position), isTrue);
      final evs = _run(c, 2.2);
      c.pointerUp(1, c.position);
      expect(_has(evs, CreatureEventType.reaction, (id) => id == 'wuff.snuggle'), isTrue);
      expect(_has(evs, CreatureEventType.reaction, (id) => id == 'wuff.love'), isTrue);
    });

    test('every trick plays and emits sounds plus a progress/trick event', () {
      for (final t in wuffTricks) {
        final c = _pup();
        c.doTrick(t.id, success: true);
        final evs = _run(c, 3.2);
        expect(_has(evs, CreatureEventType.sound), isTrue, reason: '${t.id} makes noise');
        expect(
          evs.where((e) => e.type == CreatureEventType.progress && e.id == 'trick'),
          isNotEmpty,
          reason: '${t.id} reports progress',
        );
        expect(_has(evs, CreatureEventType.reaction, (id) => id == 'wuff.trick.${t.id}'), isTrue);
        for (final e in evs.where((e) => e.type == CreatureEventType.sound)) {
          expect(wuffSounds.containsKey(e.id), isTrue, reason: 'unknown sound ${e.id}');
        }
        expect(c.life, LifeState.awake);
        expect(c.roll, closeTo(0, 0.05));
      }
    });

    test('a failed trick is confused, no progress', () {
      final c = _pup();
      c.doTrick('sit', success: false);
      final evs = _run(c, 2);
      expect(_has(evs, CreatureEventType.sound, (id) => id == 'wuff.huh'), isTrue);
      expect(_has(evs, CreatureEventType.progress, (id) => id == 'trick'), isFalse);
    });

    test('play dead lies down and gets up', () {
      final c = _pup();
      c.doTrick('playDead', success: true);
      _run(c, 1.2);
      expect(c.roll, greaterThan(0.9));
      final lying = c.silhouette.getBounds();
      expect(lying.width, greaterThan(lying.height * 0.9), reason: 'lying on its side');
      expect(c.silhouette.contains(c.position), isTrue);
      _run(c, 2.5);
      expect(c.roll, lessThan(0.05));
    });

    test('bark pads emit their sound and a bubble; every pad works', () {
      for (final pad in wuffBarkPads) {
        final c = _pup();
        c.bark(pad.id);
        final evs = _run(c, 2.5);
        final sounds = evs.where((e) => e.type == CreatureEventType.sound).map((e) => e.id).toList();
        expect(sounds, isNotEmpty, reason: pad.id);
        expect(sounds.every((s) => s.startsWith('wuff.') && wuffSounds.containsKey(s)), isTrue, reason: '$sounds');
        expect(sounds.first, startsWith(pad.sound.replaceAll(RegExp(r'\d$'), '')), reason: pad.id);
        expect(c.life, LifeState.awake);
      }
      final c = _pup();
      c.bark('howl');
      expect(_run(c, 0.5).any((e) => e.id == 'bubble.wuff.howl'), isTrue);
    });

    test('barks vary their take and pitch', () {
      final c = _pup();
      final ids = <String>{};
      final pitches = <double>{};
      for (var i = 0; i < 20; i++) {
        c.bark('hello');
        for (final e in c.drainEvents().where((e) => e.type == CreatureEventType.sound)) {
          ids.add(e.id);
          pitches.add(e.value);
        }
      }
      expect(ids.length, greaterThan(1));
      expect(pitches.length, greaterThan(3));
      expect(pitches.every((p) => p > 0.9 && p < 1.1), isTrue);
    });

    test('sleep starts a snore loop, wake yawns and stops it', () {
      final c = _pup();
      c.sleep();
      final evs = _run(c, 0.5);
      expect(c.asleep, isTrue);
      expect(_has(evs, CreatureEventType.loopStart, (id) => id == 'wuff.snore'), isTrue);
      expect(evs.firstWhere((e) => e.type == CreatureEventType.loopStart).value, inInclusiveRange(0, 1));
      _run(c, 2);
      expect(c.particles.any((p) => p.kind == WuffParticleKind.zzz), isTrue);
      c.wake();
      final w = _run(c, 0.5);
      expect(_has(w, CreatureEventType.loopStop, (id) => id == 'wuff.snore'), isTrue);
      expect(_has(w, CreatureEventType.sound, (id) => id == 'wuff.yawn'), isTrue);
      expect(c.asleep, isFalse);
    });

    test('falls asleep on its own when idle, sooner at night', () {
      final day = _pup();
      _run(day, 30);
      expect(day.asleep, isFalse);
      _run(day, 20);
      expect(day.asleep, isTrue);
      final nightPup = _pup()..night = true;
      _run(nightPup, 14);
      expect(nightPup.asleep, isTrue);
    });

    test('touching a sleeper only wakes it', () {
      final c = _pup()..sleep();
      _run(c, 0.2);
      final evs = _tap(c, c.position);
      expect(c.asleep, isFalse);
      expect(_has(evs, CreatureEventType.sound, (id) => id == 'wuff.yawn'), isTrue);
      expect(_has(evs, CreatureEventType.sound, (id) => id.startsWith('wuff.yip')), isFalse);
    });

    test('eating: chomp, yum, bond; favourite adds a journal reaction', () {
      final c = _pup();
      c.setSnackHover(true, c.mouth);
      _run(c, 0.3);
      expect(c.mouthOpen, greaterThan(0.3));
      c.eat(favorite: true);
      expect(c.life, LifeState.eating);
      final evs = _run(c, 3);
      expect(_has(evs, CreatureEventType.sound, (id) => id == 'wuff.yum'), isTrue);
      expect(_has(evs, CreatureEventType.reaction, (id) => id == 'wuff.favorite'), isTrue);
      expect(_has(evs, CreatureEventType.progress, (id) => id == 'bond'), isTrue);
    });

    test('a treat right after a trick is a good pup', () {
      final c = _pup();
      c.doTrick('sit', success: true);
      _run(c, 2);
      c.eat(favorite: false);
      expect(_has(c.drainEvents(), CreatureEventType.reaction, (id) => id == 'wuff.goodPup'), isTrue);
    });

    test('refuse when full: huff, reaction and bubble.full', () {
      final c = _pup();
      c.refuseFull();
      final evs = _run(c, 0.1);
      expect(_has(evs, CreatureEventType.sound, (id) => id == 'wuff.huff'), isTrue);
      expect(_has(evs, CreatureEventType.reaction, (id) => id == 'wuff.full'), isTrue);
      expect(_has(evs, CreatureEventType.bubble, (id) => id == 'bubble.full'), isTrue);
    });

    test('grooming: foam squints happily, dryer flutters the ears, shake-off flings water', () {
      final c = _pup()..pinned = true;
      final y0 = c.position.dy;
      c.care.wet = 0.8;
      final evs = <CreatureEvent>[];
      for (var i = 0; i < 90; i++) {
        c.groom(c.headCentre + Offset(i.isEven ? 20 : -20, 0), 700, tool: 'foam');
        c.update(1 / 60);
        evs.addAll(c.drainEvents());
      }
      expect(c.expr, WuffExpr.bliss);
      expect(_has(evs, CreatureEventType.haptic), isTrue);
      expect(_has(evs, CreatureEventType.reaction, (id) => id == 'wuff.groomed'), isTrue);
      evs.addAll(_run(c, 1.0));
      expect(_has(evs, CreatureEventType.reaction, (id) => id == 'wuff.shakeOff'), isTrue);
      expect(c.position.dy, closeTo(y0, 0.5), reason: 'pinned stays put');

      final d = _pup()..pinned = true;
      var maxEar = 0.0;
      for (var i = 0; i < 60; i++) {
        d.groom(d.headCentre, 900, tool: 'dryer');
        d.update(1 / 60);
        maxEar = [maxEar, (d.earAngle(-1) - 0.22).abs(), (d.earAngle(1) - 0.22).abs()].reduce((a, b) => a > b ? a : b);
      }
      final calm = _pup();
      var calmEar = 0.0;
      for (var i = 0; i < 60; i++) {
        calm.update(1 / 60);
        calmEar = [calmEar, (calm.earAngle(-1) - 0.22).abs(), (calm.earAngle(1) - 0.22).abs()].reduce((a, b) => a > b ? a : b);
      }
      expect(maxEar, greaterThan(calmEar + 0.08), reason: 'ears flutter in the dryer');
    });

    test('pinned puppies do not hop', () {
      final c = _pup()..pinned = true;
      c.celebrate();
      c.react(SocialCue.landedOnMe);
      var maxJump = 0.0;
      for (var i = 0; i < 120; i++) {
        c.update(1 / 60);
        if (c.jump > maxJump) maxJump = c.jump;
      }
      expect(maxJump, 0);
    });

    test('social cues: look at a friend, wag when nuzzled, startled hop', () {
      final c = _pup();
      c.react(SocialCue.friendTouched, from: const Offset(40, 620));
      _run(c, 0.4);
      expect(c.lookX, lessThan(-0.2), reason: 'looks toward the friend on its left');

      c.react(SocialCue.nuzzled, from: const Offset(300, 620));
      final nz = _run(c, 0.3);
      expect(_has(nz, CreatureEventType.reaction, (id) => id == 'wuff.nuzzled'), isTrue);
      expect(c.tailSpeed, greaterThan(8));
      expect(c.expr, WuffExpr.happy);

      _run(c, 3);
      c.react(SocialCue.landedOnMe, from: const Offset(300, 620));
      var maxJump = 0.0;
      final st = <CreatureEvent>[];
      for (var i = 0; i < 40; i++) {
        c.update(1 / 60);
        st.addAll(c.drainEvents());
        if (c.jump > maxJump) maxJump = c.jump;
      }
      expect(maxJump, greaterThan(10));
      expect(_has(st, CreatureEventType.reaction, (id) => id == 'wuff.startled'), isTrue);
    });

    test('lookAt follows a target until cleared', () {
      final c = _pup();
      c.lookAt(const Offset(390, 300));
      _run(c, 0.5);
      expect(c.lookX, greaterThan(0.3));
      c.lookAt(null);
      _run(c, 12);
      expect(c.lookX.isFinite, isTrue);
    });

    test('nudge slides it sideways and it stops at the wall', () {
      final c = _pup();
      final x0 = c.position.dx;
      c.nudge(const Offset(500, 0));
      _run(c, 0.3);
      expect(c.position.dx, greaterThan(x0 + 5));
      for (var i = 0; i < 20; i++) {
        c.nudge(const Offset(4000, 0));
        c.update(1 / 60);
      }
      _run(c, 1);
      expect(c.bounds.right, lessThanOrEqualTo(_room.right + 1));
      expect(c.position.dx, greaterThan(x0));
    });

    test('hit-testing follows the pose (rolled puppy)', () {
      final c = _pup();
      c.doTrick('playDead', success: true);
      _run(c, 1.2);
      expect(c.hitTest(c.position), isTrue);
      expect(c.hitTest(const Offset(5, 5)), isFalse);
      final m = c.mouth;
      expect(c.silhouette.getBounds().inflate(c.radius).contains(m), isTrue);
      final back = c.fromRoom(c.toRoom(const Offset(123, 456)));
      expect(back.dx, closeTo(123, 1e-6));
      expect(back.dy, closeTo(456, 1e-6));
    });

    test('anchors: head above the face above the neck', () {
      final c = _pup();
      final h = c.anchor(AccessorySlot.head), f = c.anchor(AccessorySlot.face), n = c.anchor(AccessorySlot.neck);
      expect(h.at.dy, lessThan(f.at.dy));
      expect(f.at.dy, lessThan(n.at.dy));
      expect(c.silhouette.getBounds().top, lessThan(h.at.dy));
      expect(h.scale, closeTo(c.radius / 92, 0.001));
    });

    test('long odd frame times and heavy abuse never produce NaN', () {
      final c = _pup();
      for (var i = 0; i < 400; i++) {
        c.update(i.isEven ? 0.1 : 0.0001);
        if (i % 40 == 0) c.doTrick(wuffTricks[(i ~/ 40) % wuffTricks.length].id, success: true);
        if (i % 50 == 0) c.bark(wuffBarkPads[(i ~/ 50) % wuffBarkPads.length].id);
        if (i % 90 == 0) c.shake();
        c.drainEvents();
      }
      for (final v in [c.position.dx, c.position.dy, c.radius, c.tailPhase, c.squash.value, c.tilt.value, c.earL.value, c.roll]) {
        expect(v.isFinite, isTrue);
      }
      expect(c.bounds.isFinite, isTrue);
    });

    test('catalog: coats, reactions and sound bank are consistent', () {
      expect(wuffCoats.map((c) => c.id), [
        'golden', 'cream', 'chocolate', 'blackTan', 'snow', 'corgi', 'dalmatian', 'husky', 'beagle', 'cottonCandy',
      ]);
      expect(wuffTricks.map((t) => t.id), ['sit', 'paw', 'spin', 'speak', 'playDead', 'highFive']);
      expect(wuffBarkPads, hasLength(9));
      expect(wuffReactions.length, greaterThanOrEqualTo(15));
      expect(wuffReactions.every((r) => r.id.startsWith('wuff.') && r.englishName.isNotEmpty && r.englishHint.isNotEmpty), isTrue);
      expect(wuffReactions.map((r) => r.id).toSet().length, wuffReactions.length);
      for (final pad in wuffBarkPads) {
        expect(wuffSounds.containsKey(pad.sound), isTrue, reason: pad.id);
      }
      for (final path in wuffSounds.values) {
        expect(File(path).existsSync(), isTrue, reason: '$path is bundled');
      }
      expect(wuffCoat('nope').id, 'golden');
    });

    test('every reaction a puppy emits is in the catalogue', () {
      final known = wuffReactions.map((r) => r.id).toSet();
      final seen = <String>{};
      void collect(List<CreatureEvent> evs) {
        for (final e in evs) {
          if (e.type == CreatureEventType.reaction) seen.add(e.id);
        }
      }

      for (var seed = 0; seed < 4; seed++) {
        final c = _pup(seed: seed);
        for (final t in wuffTricks) {
          c.doTrick(t.id, success: true);
          collect(_run(c, 3));
        }
        for (final pad in wuffBarkPads) {
          c.bark(pad.id);
          collect(_run(c, 2.2));
        }
        for (final cue in SocialCue.values) {
          c.react(cue, from: const Offset(300, 620));
          collect(_run(c, 2));
        }
        c.shake();
        collect(_run(c, 2.5));
        c.zoomies();
        collect(_run(c, 2));
        c.eat(favorite: true);
        collect(_run(c, 3));
        c.refuseFull();
        collect(_run(c, 2));
        c.sleep();
        collect(_run(c, 1));
        c.wake();
        collect(_run(c, 1));
      }
      expect(seen.difference(known), isEmpty);
    });
  });

  group('wuff art', () {
    const art = WuffArt();

    Picture paintInto(Creature c, String coat, {bool shadow = true}) {
      final rec = PictureRecorder();
      final canvas = Canvas(rec, const Rect.fromLTWH(0, 0, 400, 800));
      art.paint(canvas, c, CreatureLook(variant: coat), shadow: shadow);
      return rec.endRecording();
    }

    test('every coat paints without throwing', () {
      final c = _pup();
      for (final coat in wuffCoats) {
        final pic = paintInto(c, coat.id);
        expect(pic.approximateBytesUsed, greaterThan(0), reason: coat.id);
        pic.dispose();
      }
      paintInto(c, 'unknown-coat', shadow: false).dispose();
    });

    test('every coat paints in every expression and mid-trick pose', () {
      for (final coat in wuffCoats) {
        final c = _pup();
        for (final e in WuffExpr.values) {
          c.holdExpression(e);
          c.update(1 / 60);
          paintInto(c, coat.id).dispose();
        }
        for (final t in wuffTricks) {
          c.poseTrick(t.id, 0.6);
          paintInto(c, coat.id).dispose();
          c.update(3);
        }
        c.bark('howl');
        c.update(0.5);
        c.celebrate();
        c.update(0.2);
        c.shake();
        c.update(0.3);
        paintInto(c, coat.id).dispose();
      }
    });

    test('paints particles and survives a wild spin without a singular matrix', () {
      final c = _pup();
      c.zoomies();
      for (var i = 0; i < 90; i++) {
        c.update(1 / 60);
        final m = c.poseMatrix;
        expect(m.every((v) => v.isFinite), isTrue);
        paintInto(c, 'dalmatian').dispose();
      }
    });
  });
}
