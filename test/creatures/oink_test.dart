import 'dart:io';
import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:mofu_pet/creatures/creature.dart';
import 'package:mofu_pet/creatures/oink/oink_art.dart';
import 'package:mofu_pet/creatures/oink/oink_catalog.dart';
import 'package:mofu_pet/creatures/oink/oink_creature.dart';

import 'contract.dart';

const _room = Rect.fromLTWH(0, 0, 400, 800);
const _floor = 620.0;

OinkCreature _pig({int seed = 3}) {
  final c = OinkCreature(friendId: 'o1', seed: seed)..layout(_room, floorY: _floor);
  for (var i = 0; i < 120; i++) {
    c.update(1 / 60);
  }
  c.drainEvents();
  return c;
}

void _run(Creature c, double seconds) {
  for (var i = 0; i < (seconds * 60).round(); i++) {
    c.update(1 / 60);
  }
}

/// Collects events while running [seconds].
List<CreatureEvent> _runEvents(Creature c, double seconds) {
  final out = <CreatureEvent>[];
  for (var i = 0; i < (seconds * 60).round(); i++) {
    c.update(1 / 60);
    out.addAll(c.drainEvents());
  }
  return out;
}

/// A quick tap at the design point [q].
List<CreatureEvent> _tapDesign(OinkCreature c, Offset q) {
  final p = c.designToRoom(q);
  c.pointerDown(1, p);
  c.update(0.05);
  c.pointerUp(1, p);
  final out = c.drainEvents().toList();
  out.addAll(_runEvents(c, 0.2));
  return out;
}

Iterable<String> _ids(List<CreatureEvent> evs, CreatureEventType t) => evs.where((e) => e.type == t).map((e) => e.id);

/// Drags across the belly along [xs] (design x values at design y [y]).
List<CreatureEvent> _dragBelly(OinkCreature c, List<double> xs, {double y = 88}) {
  final out = <CreatureEvent>[];
  c.pointerDown(1, c.designToRoom(Offset(xs.first, y)));
  for (final x in xs.skip(1)) {
    c.update(1 / 60);
    c.pointerMove(1, c.designToRoom(Offset(x, y)));
    out.addAll(c.drainEvents());
  }
  c.pointerUp(1, c.designToRoom(Offset(xs.last, y)));
  out.addAll(c.drainEvents());
  return out;
}

List<double> _sweep(double from, double to, {double step = 5}) {
  final out = <double>[];
  final n = ((to - from).abs() / step).round();
  for (var i = 0; i <= n; i++) {
    out.add(from + (to - from) * i / n);
  }
  return out;
}

void main() {
  runCreatureContract('oink', () => OinkCreature(friendId: 'o1', seed: 3));

  group('oink species', () {
    test('identity, size and geometry', () {
      final c = _pig();
      expect(c.species, Species.oink);
      expect(c.radius, closeTo(0.15 * 400, 0.001));
      expect(c.footPoint.dy, closeTo(_floor, 0.5));
      final big = OinkCreature(friendId: 'x', seed: 1)..layout(_room, floorY: _floor, sizeScale: 1.5);
      expect(big.radius, closeTo(90, 0.001));
      // the head sits above the body, the mouth is on the face
      expect(c.anchor(AccessorySlot.head).at.dy, lessThan(c.anchor(AccessorySlot.face).at.dy));
      expect(c.anchor(AccessorySlot.face).at.dy, lessThan(c.anchor(AccessorySlot.neck).at.dy));
      expect(c.silhouette.contains(c.mouth), isTrue);
      expect(c.silhouette.contains(c.designToRoom(OinkGeo.eyeL)), isTrue);
      expect(c.silhouette.contains(c.designToRoom(OinkGeo.bodyC + const Offset(0, 40))), isTrue);
      expect(c.silhouette.contains(Offset(c.position.dx + c.radius * 3, c.position.dy)), isFalse);
      expect(c.bounds.contains(c.designToRoom(OinkGeo.earHitL)), isTrue);
      expect(c.bounds.contains(c.designToRoom(OinkGeo.tailHit)), isTrue);
    });

    test('design <-> room transforms are inverses', () {
      final c = _pig();
      c.pose
        ..squash = 0.4
        ..lean = 0.1
        ..bounce = -12;
      for (final q in [OinkGeo.headC, OinkGeo.bodyC, OinkGeo.snoutC, const Offset(40, 90)]) {
        final back = c.roomToDesign(c.designToRoom(q));
        expect((back - q).distance, lessThan(0.001));
      }
    });

    test('zones are where the SPEC puts them', () {
      final c = _pig();
      OinkZone? at(Offset q) => c.zoneAt(c.designToRoom(q));
      expect(at(OinkGeo.snoutC), OinkZone.snout);
      expect(at(OinkGeo.headC + const Offset(0, -30)), OinkZone.head);
      expect(at(OinkGeo.bodyC + const Offset(0, 40)), OinkZone.belly);
      expect(at(OinkGeo.earHitL), OinkZone.ear);
      expect(at(OinkGeo.earHitR), OinkZone.ear);
      expect(at(OinkGeo.tailHit), OinkZone.tail);
      expect(c.zoneAt(const Offset(2, 2)), isNull);
    });

    test('snout tap: one of six oinks, snout squish, bubble', () {
      final c = _pig();
      final evs = <CreatureEvent>[];
      var peakSquish = 0.0;
      final p = c.designToRoom(OinkGeo.snoutC);
      for (var n = 0; n < 12; n++) {
        c.pointerDown(1, p);
        c.update(0.05);
        c.pointerUp(1, p);
        for (var i = 0; i < 30; i++) {
          c.update(1 / 60);
          peakSquish = peakSquish < c.pose.snoutSquish ? c.pose.snoutSquish : peakSquish;
          evs.addAll(c.drainEvents());
        }
        // let the tickle window lapse so each tap is a plain snout tap
        evs.addAll(_runEvents(c, 1.6));
      }
      final oinks = _ids(evs, CreatureEventType.sound).where((s) => s.startsWith('oink.oink')).toSet();
      expect(oinks.length, greaterThan(2), reason: 'random of 6, never the same twice in a row');
      expect(oinks.every((s) => RegExp(r'^oink\.oink[1-6]$').hasMatch(s)), isTrue);
      expect(_ids(evs, CreatureEventType.reaction), contains('oink.snout'));
      expect(_ids(evs, CreatureEventType.bubble), contains('bubble.oink'));
      expect(peakSquish, greaterThan(0.8));
    });

    test('head tap: happy eyes, ears perk, hearts', () {
      final c = _pig();
      final p = c.designToRoom(OinkGeo.headC + const Offset(0, -30));
      c.pointerDown(1, p);
      c.update(0.05);
      c.pointerUp(1, p);
      var sawHappy = false;
      var minEar = 0.0;
      final evs = <CreatureEvent>[];
      for (var i = 0; i < 40; i++) {
        c.update(1 / 60);
        sawHappy |= c.pose.eyes == OinkEyes.happy;
        minEar = [minEar, c.pose.earLeft, c.pose.earRight].reduce((a, b) => a < b ? a : b);
        evs.addAll(c.drainEvents());
      }
      expect(_ids(evs, CreatureEventType.reaction), contains('oink.head'));
      expect(sawHappy, isTrue);
      expect(minEar, lessThan(-0.1), reason: 'ears perk up (rotate inward)');
      expect(c.particles.any((q) => q.kind == OinkParticleKind.heart), isTrue);
    });

    test('belly tap: giggle, legs kick, hearts', () {
      final c = _pig();
      final p = c.designToRoom(OinkGeo.bodyC + const Offset(0, 40));
      c.pointerDown(1, p);
      c.update(0.05);
      c.pointerUp(1, p);
      var kick = 0.0;
      final evs = <CreatureEvent>[];
      for (var i = 0; i < 40; i++) {
        c.update(1 / 60);
        kick = kick < c.pose.legKick ? c.pose.legKick : kick;
        evs.addAll(c.drainEvents());
      }
      expect(_ids(evs, CreatureEventType.reaction), contains('oink.belly'));
      expect(_ids(evs, CreatureEventType.sound), anyOf(contains('oink.giggle1'), contains('oink.giggle2')));
      expect(kick, greaterThan(0.4));
      expect(c.particles.any((q) => q.kind == OinkParticleKind.heart), isTrue);
    });

    test('ear tap: that ear flops, snort', () {
      for (final left in [true, false]) {
        final c = _pig();
        final evs = _tapDesign(c, left ? OinkGeo.earHitL : OinkGeo.earHitR);
        expect(_ids(evs, CreatureEventType.reaction), contains('oink.ear'));
        expect(_ids(evs, CreatureEventType.sound), anyOf(contains('oink.snort1'), contains('oink.snort2')));
        // measure the flop during the action
        final d = _pig();
        final p = d.designToRoom(left ? OinkGeo.earHitL : OinkGeo.earHitR);
        d.pointerDown(1, p);
        d.update(0.05);
        d.pointerUp(1, p);
        var peakL = 0.0, peakR = 0.0;
        for (var i = 0; i < 30; i++) {
          d.update(1 / 60);
          peakL = peakL < d.pose.earLeft ? d.pose.earLeft : peakL;
          peakR = peakR < d.pose.earRight ? d.pose.earRight : peakR;
        }
        expect(left ? peakL : peakR, greaterThan(0.6));
        expect(left ? peakR : peakL, lessThan(0.5), reason: 'only the tapped ear flops');
      }
    });

    test('tail tap: tail spins, surprised "oink?"', () {
      final c = _pig();
      final p = c.designToRoom(OinkGeo.tailHit);
      c.pointerDown(1, p);
      c.update(0.05);
      c.pointerUp(1, p);
      var peakTail = 0.0;
      var surprised = false;
      final evs = <CreatureEvent>[];
      for (var i = 0; i < 60; i++) {
        c.update(1 / 60);
        peakTail = peakTail < c.pose.tail ? c.pose.tail : peakTail;
        surprised |= c.pose.eyes == OinkEyes.surprised;
        evs.addAll(c.drainEvents());
      }
      expect(_ids(evs, CreatureEventType.reaction), contains('oink.tail'));
      expect(_ids(evs, CreatureEventType.bubble), contains('bubble.oinkq'));
      expect(_ids(evs, CreatureEventType.sound).any((s) => s.startsWith('oink.oink')), isTrue);
      expect(peakTail, greaterThan(6), reason: 'two full turns');
      expect(surprised, isTrue);
    });

    test('pressing squashes, releasing stretches back', () {
      final c = _pig();
      final p = c.designToRoom(OinkGeo.bodyC);
      c.pointerDown(1, p);
      _run(c, 0.25);
      expect(c.pose.squash, greaterThan(0.15), reason: 'flattened under the finger');
      c.pointerUp(1, p);
      var minSquash = 1.0;
      for (var i = 0; i < 40; i++) {
        c.update(1 / 60);
        minSquash = minSquash < c.pose.squash ? minSquash : c.pose.squash;
      }
      expect(minSquash, lessThan(0.0), reason: 'overshoots into a stretch');
    });

    test('rapid taps tickle', () {
      final c = _pig();
      final p = c.designToRoom(OinkGeo.headC + const Offset(0, -30));
      final evs = <CreatureEvent>[];
      for (var i = 0; i < 6; i++) {
        c.pointerDown(1, p);
        c.update(0.04);
        c.pointerUp(1, p);
        c.update(0.1);
        evs.addAll(c.drainEvents());
      }
      expect(_ids(evs, CreatureEventType.reaction), contains('oink.tickle'));
      expect(evs.any((e) => e.type == CreatureEventType.progress && e.id == 'combo'), isTrue);
    });

    test('belly rub needs back-and-forth motion', () {
      final one = _pig();
      final straight = _dragBelly(one, _sweep(-50, 55));
      expect(_ids(straight, CreatureEventType.reaction), isNot(contains('oink.rub')), reason: 'one stroke is not a rub');
      expect(_ids(straight, CreatureEventType.reaction), isNot(contains('oink.belly')), reason: 'a drag is not a tap');

      final two = _pig();
      final zig = [..._sweep(-50, 50), ..._sweep(50, -50).skip(1), ..._sweep(-50, 50).skip(1)];
      final rub = _dragBelly(two, zig);
      expect(_ids(rub, CreatureEventType.reaction), contains('oink.rub'));
      expect(_ids(rub, CreatureEventType.sound), anyOf(contains('oink.giggle1'), contains('oink.giggle2')));
      expect(rub.any((e) => e.type == CreatureEventType.coach), isTrue);
      expect(two.particles.any((q) => q.kind == OinkParticleKind.heart), isTrue);
    });

    test('rubbing the head back and forth pats it', () {
      final c = _pig();
      final c0 = OinkGeo.headC.dy - 30;
      final xs = [..._sweep(-40, 40), ..._sweep(40, -40).skip(1), ..._sweep(-40, 40).skip(1)];
      final out = <CreatureEvent>[];
      c.pointerDown(1, c.designToRoom(Offset(xs.first, c0)));
      for (final x in xs.skip(1)) {
        c.update(1 / 60);
        c.pointerMove(1, c.designToRoom(Offset(x, c0)));
        out.addAll(c.drainEvents());
      }
      c.pointerUp(1, c.designToRoom(Offset(xs.last, c0)));
      out.addAll(c.drainEvents());
      expect(_ids(out, CreatureEventType.reaction), contains('oink.pat'));
      expect(_ids(out, CreatureEventType.sound), contains('oink.squeal'));
    });

    test('holding then dragging lifts the pig, letting go tosses it', () {
      final c = _pig();
      final start = c.position;
      final p = c.designToRoom(OinkGeo.bodyC);
      c.pointerDown(1, p);
      _run(c, 0.6);
      final held = c.drainEvents();
      expect(_ids(held, CreatureEventType.reaction), contains('oink.squish'));
      expect(c.life, LifeState.awake);
      var q = p;
      for (var i = 0; i < 12; i++) {
        q = q + const Offset(0, -10);
        c.update(1 / 60);
        c.pointerMove(1, q);
      }
      expect(c.life, LifeState.held);
      expect(c.position.dy, lessThan(start.dy - 40));
      expect(_ids(c.drainEvents(), CreatureEventType.reaction), contains('oink.pickup'));
      c.pointerUp(1, q);
      expect(c.life, LifeState.airborne);
      final evs = _runEvents(c, 3);
      expect(c.life, LifeState.awake);
      expect((c.position.dy - start.dy).abs(), lessThan(1));
      expect(_ids(evs, CreatureEventType.sound), contains('oink.pop'));
    });

    test('a pinned pig cannot be picked up', () {
      final c = _pig()..pinned = true;
      final p = c.designToRoom(OinkGeo.bodyC);
      c.pointerDown(1, p);
      _run(c, 0.6);
      var q = p;
      for (var i = 0; i < 12; i++) {
        q = q + const Offset(0, -10);
        c.update(1 / 60);
        c.pointerMove(1, q);
      }
      expect(c.life, isNot(LifeState.held));
      c.pointerUp(1, q);
    });

    test('sleep yawns, starts the snore loop and Zzz; wake stops it', () {
      final c = _pig();
      c.sleep();
      final evs = _runEvents(c, 2.5);
      expect(c.life, LifeState.asleep);
      expect(_ids(evs, CreatureEventType.sound), contains('oink.yawn'));
      final loops = evs.where((e) => e.type == CreatureEventType.loopStart).toList();
      expect(loops.length, 1);
      expect(loops.single.id, 'oink.snore');
      expect(loops.single.value, inInclusiveRange(0.1, 1.0));
      expect(c.pose.eyes, OinkEyes.closed);
      expect(c.particles.any((q) => q.kind == OinkParticleKind.zzz), isTrue);
      c.wake();
      final w = c.drainEvents();
      expect(w.any((e) => e.type == CreatureEventType.loopStop && e.id == 'oink.snore'), isTrue);
      expect(_ids(w, CreatureEventType.sound), contains('oink.wake'));
    });

    test('sleeping pig grumbles when poked and stays asleep; three pokes wake it', () {
      final c = _pig()..sleep();
      _run(c, 1.5);
      c.drainEvents();
      final first = _tapDesign(c, OinkGeo.headC + const Offset(0, -30));
      expect(_ids(first, CreatureEventType.reaction), contains('oink.grumble'));
      expect(_ids(first, CreatureEventType.reaction), isNot(contains('oink.head')));
      expect(c.asleep, isTrue);
      _tapDesign(c, OinkGeo.bodyC + const Offset(0, 40));
      expect(c.asleep, isTrue);
      _tapDesign(c, OinkGeo.bodyC + const Offset(0, 40));
      expect(c.asleep, isFalse);
    });

    test('night makes it sleepy sooner, daylight does not', () {
      final day = _pig();
      _run(day, 20);
      expect(day.asleep, isFalse);
      final night = _pig()..night = true;
      _run(night, 20);
      expect(night.asleep, isTrue);
    });

    test('eating: munch, gulp, crumbs; favourite is a bigger reward', () {
      final c = _pig();
      c.eat(favorite: false);
      expect(c.life, LifeState.eating);
      final evs = c.drainEvents().toList()..addAll(_runEvents(c, 1.5));
      expect(_ids(evs, CreatureEventType.reaction), contains('oink.munch'));
      final sounds = _ids(evs, CreatureEventType.sound).toList();
      expect(sounds.where((s) => s.startsWith('oink.munch')).length, greaterThanOrEqualTo(2));
      expect(sounds, contains('oink.gulp'));
      expect(evs.firstWhere((e) => e.type == CreatureEventType.progress && e.id == 'bond').value, 2);
      expect(c.life, LifeState.awake);

      final f = _pig();
      f.eat(favorite: true);
      final fe = f.drainEvents().toList()..addAll(_runEvents(f, 1.5));
      expect(_ids(fe, CreatureEventType.reaction), contains('oink.favorite'));
      expect(fe.firstWhere((e) => e.type == CreatureEventType.progress && e.id == 'bond').value, 3);
      expect(fe.any((e) => e.type == CreatureEventType.haptic && e.id == 'success'), isTrue);
    });

    test('a hovering snack opens the mouth', () {
      final c = _pig();
      c.setSnackHover(true, c.mouth);
      _run(c, 0.4);
      expect(c.pose.mouth, OinkMouth.open);
      expect(c.pose.eyes, OinkEyes.surprised);
      c.setSnackHover(false);
      _run(c, 0.6);
      expect(c.pose.mouth, OinkMouth.smile);
    });

    test('refusing when full: head shake and grumble', () {
      final c = _pig();
      c.refuseFull();
      var peak = 0.0;
      final evs = c.drainEvents().toList();
      for (var i = 0; i < 50; i++) {
        c.update(1 / 60);
        peak = peak < c.pose.shake.abs() ? c.pose.shake.abs() : peak;
        evs.addAll(c.drainEvents());
      }
      expect(peak, greaterThan(0.06));
      expect(_ids(evs, CreatureEventType.sound), contains('oink.grumble'));
      expect(_ids(evs, CreatureEventType.bubble), contains('bubble.full'));
      expect(_ids(evs, CreatureEventType.reaction), contains('oink.full'));
      _run(c, 0.5);
      expect(c.pose.mouth, isNot(OinkMouth.frown), reason: 'back to a smile afterwards');
    });

    test('grooming: foam wiggles and giggles, dryer flaps the ears, towel rubs', () {
      final foam = _pig();
      final fe = <CreatureEvent>[];
      var kick = 0.0;
      for (var i = 0; i < 90; i++) {
        foam.groom(foam.position + Offset(foam.radius * 0.3 * (i.isEven ? 1 : -1), 0), 500, tool: 'foam');
        foam.update(1 / 60);
        kick = kick < foam.pose.legKick ? foam.pose.legKick : kick;
        fe.addAll(foam.drainEvents());
      }
      expect(_ids(fe, CreatureEventType.reaction), contains('oink.groom'));
      expect(_ids(fe, CreatureEventType.reaction).where((r) => r == 'oink.groom').length, 1, reason: 'once per session');
      expect(_ids(fe, CreatureEventType.sound), anyOf(contains('oink.giggle1'), contains('oink.giggle2')));
      expect(_ids(fe, CreatureEventType.sound), contains('oink.scrub'));
      expect(kick, greaterThan(0.3));

      final dry = _pig();
      var minL = 9.0, maxL = -9.0;
      final de = <CreatureEvent>[];
      for (var i = 0; i < 60; i++) {
        dry.groom(dry.position, 300, tool: 'dryer');
        dry.update(1 / 60);
        minL = minL < dry.pose.earLeft ? minL : dry.pose.earLeft;
        maxL = maxL > dry.pose.earLeft ? maxL : dry.pose.earLeft;
        de.addAll(dry.drainEvents());
      }
      expect(maxL - minL, greaterThan(0.5), reason: 'ears flap in the wind');
      expect(_ids(de, CreatureEventType.reaction), contains('oink.dryer'));

      final towel = _pig();
      towel.groom(towel.position, 300, tool: 'towel');
      expect(_ids(towel.drainEvents().toList(), CreatureEventType.reaction), contains('oink.towel'));

      // a long scrub ends with a sparkle
      final spa = _pig();
      for (var i = 0; i < 200; i++) {
        spa.groom(spa.position, 300, tool: 'foam');
        spa.update(1 / 60);
      }
      spa.drainEvents();
      final after = _runEvents(spa, 0.6);
      expect(_ids(after, CreatureEventType.sound), contains('oink.sparkle'));
    });

    test('grooming a sleeper wakes it; grooming far away does nothing', () {
      final c = _pig()..sleep();
      _run(c, 0.5);
      c.drainEvents();
      c.groom(const Offset(5, 5), 300, tool: 'foam');
      expect(c.asleep, isTrue);
      expect(c.drainEvents(), isEmpty);
      c.groom(c.position, 300, tool: 'foam');
      expect(c.asleep, isFalse);
    });

    test('mud is the room\'s business: care state never breaks the pig', () {
      final c = _pig();
      c.care.mud.add(FoamBlob(const Offset(0.2, -0.1), 0.3, 0));
      c.care.wet = 1;
      _run(c, 1);
      expect(c.position.dx.isFinite, isTrue);
    });

    test('social cues each get a distinct, in-character reaction', () {
      final c = _pig();
      c.react(SocialCue.friendTouched, from: const Offset(40, 600));
      expect(_ids(c.drainEvents().toList(), CreatureEventType.reaction), contains('oink.peek'));
      c.react(SocialCue.nuzzled);
      expect(_ids(c.drainEvents().toList(), CreatureEventType.reaction), contains('oink.nuzzle'));
      c.react(SocialCue.landedOnMe);
      expect(_ids(c.drainEvents().toList(), CreatureEventType.reaction), contains('oink.bumped'));
      c.react(SocialCue.celebrate);
      final ev = c.drainEvents();
      expect(_ids(ev.toList(), CreatureEventType.reaction), contains('oink.cheer'));
      expect(ev.any((e) => e.type == CreatureEventType.haptic && e.id == 'success'), isTrue);
    });

    test('eyes follow lookAt and the finger', () {
      final c = _pig();
      c.lookAt(Offset(c.position.dx + 300, c.position.dy));
      _run(c, 0.5);
      expect(c.pose.look.dx, greaterThan(0.5));
      c.lookAt(Offset(c.position.dx - 300, c.position.dy));
      _run(c, 0.5);
      expect(c.pose.look.dx, lessThan(-0.5));
    });

    test('nudges slide it and it leans into the slide', () {
      final c = _pig();
      final x0 = c.position.dx;
      c.nudge(const Offset(900, 0));
      _run(c, 0.1);
      expect(c.position.dx, greaterThan(x0 + 20));
      expect(c.pose.lean, greaterThan(0.02));
      _run(c, 2);
      expect(c.pose.lean.abs(), lessThan(0.02));
    });

    test('an upward kick makes it airborne and it lands again', () {
      final c = _pig();
      c.nudge(const Offset(0, -900));
      c.update(1 / 60);
      expect(c.life, LifeState.airborne);
      _run(c, 3);
      expect(c.life, LifeState.awake);
      expect(c.footPoint.dy, closeTo(_floor, 0.5));
    });

    test('it wanders and hops on its own, unless pinned or reduceMotion', () {
      final c = _pig();
      final xs = <double>{};
      var hopped = false;
      for (var i = 0; i < 60 * 40; i++) {
        c.update(1 / 60);
        if (i % 30 == 0) xs.add(c.position.dx.roundToDouble());
        hopped |= c.pose.bounce < -8;
        c.drainEvents();
        if (c.asleep) c.wake();
      }
      expect(xs.length, greaterThan(3), reason: 'wanders');
      expect(hopped, isTrue);

      final calm = _pig()..reduceMotion = true;
      final start = calm.position;
      _run(calm, 30);
      expect(calm.position, start);
    });

    test('layout rescales and keeps the pig inside', () {
      final c = _pig();
      c.layout(const Rect.fromLTWH(0, 0, 200, 400), floorY: 300);
      _run(c, 1);
      expect(c.radius, closeTo(30, 0.001));
      expect(c.position.dx, inInclusiveRange(0, 200));
      expect(c.footPoint.dy, closeTo(300, 0.5));
    });

    test('position setter above the floor drops the pig', () {
      final c = _pig();
      c.position = Offset(c.position.dx, c.position.dy - 150);
      c.update(1 / 60);
      expect(c.life, LifeState.airborne);
      _run(c, 3);
      expect(c.life, LifeState.awake);
    });

    test('same seed, same behaviour', () {
      List<String> script(int seed) {
        final c = _pig(seed: seed);
        final out = <String>[];
        for (var i = 0; i < 60 * 20; i++) {
          c.update(1 / 60);
          if (i == 100) _tapDesign(c, OinkGeo.snoutC);
          out.addAll(c.drainEvents().map((e) => '${e.type.name}:${e.id}:${e.value.toStringAsFixed(3)}'));
        }
        return out;
      }

      expect(script(5), script(5));
    });

    test('every event the pig can emit is in the catalogue and prefixed', () {
      final c = _pig();
      final all = <CreatureEvent>[];
      void flush() => all.addAll(c.drainEvents());
      for (final q in [OinkGeo.snoutC, OinkGeo.headC + const Offset(0, -30), OinkGeo.bodyC + const Offset(0, 40), OinkGeo.earHitL, OinkGeo.earHitR, OinkGeo.tailHit]) {
        _tapDesign(c, q);
        flush();
        _run(c, 1.6);
        flush();
      }
      c.eat(favorite: true);
      _run(c, 2);
      flush();
      c.eat(favorite: false);
      _run(c, 2);
      flush();
      c.refuseFull();
      _run(c, 1);
      flush();
      c.celebrate();
      _run(c, 2);
      flush();
      for (final cue in SocialCue.values) {
        c.react(cue, from: const Offset(100, 600));
        _run(c, 1);
        flush();
      }
      for (final tool in ['foam', 'towel', 'dryer', 'sponge']) {
        for (var i = 0; i < 120; i++) {
          c.groom(c.position, 400, tool: tool);
          c.update(1 / 60);
        }
        _run(c, 1);
        flush();
      }
      c.sleep();
      _run(c, 3);
      flush();
      _tapDesign(c, OinkGeo.headC);
      flush();
      c.wake();
      flush();
      c.nudge(const Offset(0, -1200));
      _run(c, 3);
      flush();

      final sounds = all.where((e) => e.type == CreatureEventType.sound || e.type == CreatureEventType.loopStart || e.type == CreatureEventType.loopStop);
      expect(sounds, isNotEmpty);
      for (final e in sounds) {
        expect(e.id, startsWith('oink.'));
        expect(oinkSounds.containsKey(e.id), isTrue, reason: 'unknown sound ${e.id}');
        if (e.type != CreatureEventType.sound) expect(oinkLoops, contains(e.id));
        if (e.type == CreatureEventType.sound) expect(e.value, inInclusiveRange(0.5, 2.0), reason: 'pitch of ${e.id}');
      }
      final reactionIds = oinkReactions.map((r) => r.id).toSet();
      for (final e in all.where((e) => e.type == CreatureEventType.reaction)) {
        expect(e.id, startsWith('oink.'));
        expect(reactionIds, contains(e.id));
      }
      for (final e in all.where((e) => e.type == CreatureEventType.haptic)) {
        expect(['selection', 'light', 'medium', 'heavy', 'success'], contains(e.id));
      }
      for (final e in all.where((e) => e.type == CreatureEventType.bubble)) {
        expect(e.id, startsWith('bubble.'));
      }
      for (final e in all.where((e) => e.type == CreatureEventType.progress)) {
        expect(['fluff', 'bond', 'combo', 'trick'], contains(e.id));
      }
    });
  });

  group('oink catalogue', () {
    test('tints, snacks, reactions', () {
      expect(oinkTints.length, greaterThanOrEqualTo(6));
      for (final id in ['classic', 'peach', 'spotted', 'chocolate', 'lavender', 'golden']) {
        expect(oinkTints.map((t) => t.id), contains(id));
      }
      expect(oinkTints.map((t) => t.id).toSet().length, oinkTints.length);
      for (final t in oinkTints) {
        expect(oinkPalettes, contains(t.id), reason: 'palette for ${t.id}');
      }
      expect(oinkSnacks.length, 6);
      expect(oinkSnacks.map((s) => s.id).toSet().length, 6);
      expect(oinkReactions.length, greaterThanOrEqualTo(15));
      expect(oinkReactions.map((r) => r.id).toSet().length, oinkReactions.length);
      for (final r in oinkReactions) {
        expect(r.id, startsWith('oink.'));
        expect(r.englishName, isNotEmpty);
        expect(r.englishHint, isNotEmpty);
      }
    });

    test('every sound id is prefixed and its file exists', () {
      expect(oinkSounds, isNotEmpty);
      for (final e in oinkSounds.entries) {
        expect(e.key, startsWith('oink.'));
        expect(e.value, startsWith('assets/sounds/oink/'));
        expect(File(e.value).existsSync(), isTrue, reason: e.value);
        expect(File(e.value).lengthSync(), greaterThan(500));
      }
    });
  });

  group('oink art', () {
    Picture draw(OinkCreature c, String tint, {bool shadow = true}) {
      final rec = PictureRecorder();
      const OinkArt().paint(Canvas(rec), c, CreatureLook(variant: tint, accessories: const ['bow']), shadow: shadow);
      return rec.endRecording();
    }

    test('every tint paints without throwing, in many poses', () {
      for (final t in oinkTints) {
        final c = _pig();
        draw(c, t.id).dispose();
        draw(c, t.id, shadow: false).dispose();
        // surprised + open mouth + hearts
        _tapDesign(c, OinkGeo.tailHit);
        draw(c, t.id).dispose();
        c.eat(favorite: true);
        for (var i = 0; i < 40; i++) {
          c.update(1 / 60);
          draw(c, t.id).dispose();
        }
        c.sleep();
        for (var i = 0; i < 150; i++) {
          c.update(1 / 60);
        }
        draw(c, t.id).dispose();
        c.wake();
        for (var i = 0; i < 40; i++) {
          c.groom(c.position, 400, tool: 'dryer');
          c.update(1 / 60);
          draw(c, t.id).dispose();
        }
      }
    });

    test('unknown tint falls back to classic; a foreign creature is ignored', () {
      final c = _pig();
      draw(c, 'no-such-coat').dispose();
      expect(oinkPalette('no-such-coat'), same(oinkPalettes['classic']));
      expect(oinkPalettes.keys, containsAll(oinkTints.map((t) => t.id)));
    });

    test('every sad/sleepy/squint eye mode paints', () {
      final c = _pig();
      for (final eyes in OinkEyes.values) {
        for (final mouth in OinkMouth.values) {
          c.pose
            ..eyes = eyes
            ..mouth = mouth
            ..mouthOpen = 0.7;
          draw(c, 'spotted').dispose();
        }
      }
    });
  });
}
