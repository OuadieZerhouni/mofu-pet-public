import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:mofu_pet/sim/mofu_sim.dart';

/// Behaviour of the creature, SPEC F1–F7, driven without a frame scheduler.
void main() {
  late MofuSim sim;
  const room = Size(390, 760);

  MofuSim fresh({bool night = false}) {
    final s = MofuSim(seed: 1, reduceMotion: true)
      ..fluff = 0.3
      ..night = night;
    s.layout(room, top: 140, floor: 620);
    return s;
  }

  void run(double seconds) {
    const dt = 1 / 60;
    for (var t = 0.0; t < seconds; t += dt) {
      sim.update(dt);
    }
  }

  Set<String> reactions() =>
      sim.drainEvents().where((e) => e.type == SimEventType.reaction).map((e) => e.id).toSet();

  setUp(() => sim = fresh());

  test('rests on the floor, inside the room', () {
    run(0.5);
    expect(sim.mode, MofuMode.rest);
    expect(sim.pos.dy + sim.radius, closeTo(620, 0.01));
    expect(sim.pos.dx, inInclusiveRange(sim.radius, room.width - sim.radius));
  });

  test('tap → squash, happy, squeak, boing', () {
    sim.pointerDown(1, sim.pos);
    run(0.05);
    sim.pointerUp(1, sim.pos);
    final events = sim.drainEvents();
    expect(events.any((e) => e.type == SimEventType.sound && e.id == 'squeak'), isTrue);
    expect(events.any((e) => e.type == SimEventType.reaction && e.id == 'boing'), isTrue);
    run(0.03);
    expect(sim.squash, isNot(0));
    expect(sim.expr, Expr.happy);
  });

  test('five quick taps → tickle fit', () {
    for (var i = 0; i < 5; i++) {
      sim.pointerDown(1, sim.pos);
      run(0.05);
      sim.pointerUp(1, sim.pos);
      run(0.1);
    }
    expect(reactions(), contains('tickle'));
    expect(sim.expr, Expr.giggle);
  });

  test('taps far apart do not tickle', () {
    for (var i = 0; i < 5; i++) {
      sim.pointerDown(1, sim.pos);
      run(0.05);
      sim.pointerUp(1, sim.pos);
      run(0.5);
    }
    expect(reactions(), isNot(contains('tickle')));
  });

  test('hold → squish, keep holding → hug, release recovers', () {
    sim.pointerDown(1, sim.pos);
    run(0.5);
    expect(reactions(), contains('squish'));
    expect(sim.squashTarget, greaterThan(0));
    run(1.3);
    expect(reactions(), contains('hug'));
    expect(sim.expr, Expr.love);
    sim.pointerUp(1, sim.pos);
    run(1.5);
    expect(sim.squashTarget, 0);
    expect(sim.expr, isNot(Expr.love));
  });

  test('hold then move → pick up; throw → bounce → land inside the room', () {
    final start = sim.pos;
    sim.pointerDown(1, start);
    run(0.5);
    for (var i = 1; i <= 6; i++) {
      sim.pointerMove(1, start + Offset(i * 30.0, -i * 40.0));
      run(1 / 60);
    }
    expect(sim.mode, MofuMode.held);
    sim.pointerUp(1, start + const Offset(180, -240));
    expect(sim.mode, MofuMode.air);
    run(6);
    expect(sim.mode, MofuMode.rest);
    expect(sim.pos.dx, inInclusiveRange(sim.radius - 0.01, room.width - sim.radius + 0.01));
    expect(sim.pos.dy + sim.radius, closeTo(620, 0.01));
    expect(reactions(), contains('toss'));
  });

  test('toss can be disabled remotely', () {
    sim.tossEnabled = false;
    sim.pointerDown(1, sim.pos);
    run(0.5);
    sim.pointerMove(1, sim.pos + const Offset(60, -60));
    run(0.1);
    expect(sim.mode, isNot(MofuMode.held));
  });

  test('stroking bends fur, purrs, gains fluff, discovers pet', () {
    final p = sim.pos;
    sim.pointerDown(1, p - const Offset(40, 20));
    var fluff = 0.0;
    var purr = false;
    for (var i = 0; i < 60; i++) {
      sim.pointerMove(1, p + Offset(-40 + (i % 20) * 4.0, -20));
      run(1 / 60);
      for (final e in sim.drainEvents()) {
        if (e.type == SimEventType.fluff) fluff += e.value;
        if (e.type == SimEventType.loopStart && e.id == 'purr') purr = true;
      }
    }
    expect(sim.strands.any((s) => s.bend.abs() > 0.01), isTrue);
    sim.pointerUp(1, p);
    for (final e in sim.drainEvents()) {
      if (e.type == SimEventType.fluff) fluff += e.value;
    }
    expect(purr, isTrue);
    expect(fluff, greaterThan(0));
  });

  test('pet reaction after 0.6 s of stroking, once per gesture', () {
    final p = sim.pos;
    sim.pointerDown(1, p);
    final seen = <String>[];
    for (var i = 0; i < 90; i++) {
      sim.pointerMove(1, p + Offset((i % 10) * 6.0 - 30, 0));
      run(1 / 60);
      seen.addAll(sim.drainEvents().where((e) => e.type == SimEventType.reaction).map((e) => e.id));
    }
    expect(seen.where((id) => id == 'pet').length, 1);
  });

  test('shake makes fur messy; brushing tidies it', () {
    sim.shake();
    expect(sim.messLevel, greaterThan(0.3));
    expect(reactions(), contains('shake'));
    sim.brushMode = true;
    final p = sim.pos;
    final seen = <String>{};
    for (var pass = 0; pass < 80 && sim.messLevel > 0; pass++) {
      sim.pointerDown(1, p + const Offset(-90, -60));
      for (var i = 0; i <= 30; i++) {
        final a = i / 30;
        sim.pointerMove(1, p + Offset(-90 + 180 * a, -60 + (pass % 6) * 25.0));
        run(1 / 60);
      }
      sim.pointerUp(1, p);
      seen.addAll(reactions());
    }
    expect(sim.messLevel, lessThan(0.03));
    expect(seen, contains('tidy'));
    expect(seen, contains('brush'));
  });

  test('double-tap an eye → protest', () {
    final eye = sim.eyePos(-1);
    for (var i = 0; i < 2; i++) {
      sim.pointerDown(1, eye);
      run(0.05);
      sim.pointerUp(1, eye);
      run(0.1);
    }
    expect(reactions(), contains('eyePoke'));
    expect(sim.expr, Expr.protest);
  });

  test('falls asleep after 45 s idle; a touch wakes it', () {
    run(46);
    expect(sim.asleep, isTrue);
    expect(reactions(), contains('sleep'));
    sim.pointerDown(1, sim.pos);
    expect(sim.asleep, isFalse);
    expect(reactions(), contains('wake'));
  });

  test('at night it dozes sooner', () {
    sim = fresh(night: true);
    run(13);
    expect(sim.asleep, isTrue);
  });

  test('circling while petting → spin', () {
    final c = sim.pos;
    sim.pointerDown(1, c + const Offset(50, 0));
    final seen = <String>{};
    for (var i = 0; i <= 80; i++) {
      final a = i / 80 * 2 * 3.14159 * 1.3;
      sim.pointerMove(1, c + Offset(50 * math.cos(a), 50 * math.sin(a)));
      run(1 / 60);
      seen.addAll(reactions());
    }
    expect(seen, contains('spin'));
  });

  test('eating: favourite → favourite + yum; full → polite refusal', () {
    sim.eat(favorite: true);
    run(3);
    final r = reactions();
    expect(r, contains('favorite'));
    expect(r, contains('yum'));
    sim.refuseFull();
    expect(reactions(), contains('full'));
    // F4-c4: a content face and a head shake, then back to normal.
    expect(sim.expr, Expr.content);
    var shook = 0.0;
    for (var t = 0.0; t < 0.6; t += 1 / 60) {
      sim.update(1 / 60);
      shook = math.max(shook, sim.rot.abs());
    }
    expect(shook, greaterThan(0.02));
    run(2);
    expect(sim.expr, Expr.idle);
  });

  test('fluff makes Mofu bigger and its fur longer', () {
    sim.fluff = 0;
    final r0 = sim.radius, f0 = sim.furLength;
    sim.fluff = 1;
    expect(sim.radius, greaterThan(r0));
    expect(sim.furLength, greaterThan(f0 * 2));
  });

  test('a transient zero-size first layout still centres Mofu', () {
    final s = MofuSim(seed: 2, reduceMotion: true);
    s.layout(Size.zero, top: 0, floor: 0);
    s.layout(room, top: 140, floor: 620);
    expect(s.pos.dx, closeTo(room.width / 2, 0.01));
  });

  test('resizing keeps the relative position and the fur inside the walls', () {
    sim.pos = Offset(room.width * 0.75, sim.pos.dy);
    sim.layout(const Size(780, 760), top: 140, floor: 620);
    expect(sim.pos.dx, closeTo(585, 1));
    sim.layout(const Size(300, 760), top: 140, floor: 620);
    expect(sim.pos.dx + sim.radius + sim.furLength, lessThanOrEqualTo(300));
  });

  test('a second finger is ignored', () {
    sim.pointerDown(1, sim.pos);
    sim.pointerDown(2, sim.pos + const Offset(10, 0));
    sim.pointerUp(2, sim.pos);
    expect(sim.activePointer, 1);
    sim.pointerUp(1, sim.pos);
    expect(sim.activePointer, isNull);
  });

  test('a long frame does not explode the springs', () {
    sim.pointerDown(1, sim.pos);
    sim.pointerUp(1, sim.pos);
    sim.update(5); // app came back from background
    expect(sim.squash.isFinite, isTrue);
    expect(sim.pos.dy.isFinite, isTrue);
  });

  // F1-c2: idle life, observed without touching. Reduce Motion off so hops run.
  test('idle life: breathing, blinks every 2.5–6 s, glances and hops every 6–14 s', () {
    sim = MofuSim(seed: 3)..fluff = 0.3;
    sim.layout(room, top: 140, floor: 620);
    const dt = 1 / 60;
    final blinks = <double>[], hops = <double>[], glances = <double>[];
    final breaths = <double>{};
    var lastBlink = 0.0, lastLook = (sim.lookX, sim.lookY);
    var looking = false;
    var wasAir = false;
    for (var t = 0.0; t < 40; t += dt) {
      sim.update(dt);
      if (sim.blink > 0 && lastBlink == 0) blinks.add(sim.time);
      lastBlink = sim.blink;
      final moving = (sim.lookX - lastLook.$1).abs() + (sim.lookY - lastLook.$2).abs() > 1e-4;
      if (moving && !looking) glances.add(sim.time);
      looking = moving;
      lastLook = (sim.lookX, sim.lookY);
      final air = sim.mode == MofuMode.air;
      if (air && !wasAir) hops.add(sim.time);
      wasAir = air;
      breaths.add((sim.breath * 1000).roundToDouble());
    }
    expect(sim.asleep, isFalse);
    expect(breaths.length, greaterThan(10), reason: 'body scale breathes');
    List<double> gaps(List<double> xs) => [for (var i = 1; i < xs.length; i++) xs[i] - xs[i - 1]];
    expect(blinks.first, greaterThanOrEqualTo(2.5));
    expect(blinks.length, greaterThanOrEqualTo(6));
    for (final g in gaps(blinks)) {
      expect(g, inInclusiveRange(2.5, 6.1));
    }
    expect(hops.length, greaterThanOrEqualTo(2));
    for (final g in gaps(hops)) {
      expect(g, inInclusiveRange(6, 14.1));
    }
    expect(glances, isNotEmpty);
    for (final g in gaps(glances)) {
      expect(g, greaterThanOrEqualTo(6), reason: 'a glance comes no sooner than 6 s after the last');
    }
  });

  // F1-c3
  test('pupils follow a finger that is down', () {
    final right = sim.pos + Offset(sim.radius * 2.5, 0);
    sim.pointerDown(1, right);
    run(0.5);
    expect(sim.lookX, greaterThan(0.6));
    final left = sim.pos - Offset(sim.radius * 2.5, sim.radius);
    sim.pointerMove(1, left);
    run(0.5);
    expect(sim.lookX, lessThan(-0.6));
    expect(sim.lookY, lessThan(0));
  });

  // F1-c5
  test('Reduce Motion: no idle hops and no celebration jump; breathing and blinking stay', () {
    var blinked = false;
    final breaths = <int>{};
    for (var t = 0.0; t < 40; t += 1 / 60) {
      sim.update(1 / 60);
      expect(sim.mode, MofuMode.rest);
      if (sim.blink > 0) blinked = true;
      breaths.add((sim.breath * 1000).round());
    }
    expect(blinked, isTrue);
    expect(breaths.length, greaterThan(10));
    sim.celebrate();
    run(0.3);
    expect(sim.mode, MofuMode.rest);
    final moving = MofuSim(seed: 1)..layout(room, top: 140, floor: 620);
    moving.update(1 / 60);
    moving.celebrate();
    moving.update(1 / 60);
    expect(moving.mode, MofuMode.air);
  });

  // F2-c5
  test('a fast throw makes Mofu dizzy and it lands squished', () {
    final start = sim.pos;
    sim.pointerDown(1, start);
    run(0.5);
    for (var i = 1; i <= 6; i++) {
      sim.pointerMove(1, start + Offset(i * 15.0, -i * 60.0));
      run(1 / 60);
    }
    sim.pointerUp(1, start + const Offset(90, -360));
    var squished = false;
    final seen = <String>{};
    for (var t = 0.0; t < 6; t += 1 / 60) {
      sim.update(1 / 60);
      if (sim.squash > 0.05) squished = true;
      seen.addAll(reactions());
    }
    expect(seen, containsAll(['toss', 'dizzyToss']));
    expect(squished, isTrue);
    expect(sim.mode, MofuMode.rest);
  });

  // F2-c3 (the parts the first stroke test does not assert)
  test('petting closes the eyes happily and floats hearts', () {
    final p = sim.pos;
    sim.pointerDown(1, p - const Offset(40, 20));
    for (var i = 0; i < 90; i++) {
      sim.pointerMove(1, p + Offset(-40 + (i % 20) * 4.0, -20));
      run(1 / 60);
    }
    expect(sim.expr, Expr.bliss);
    expect(sim.particles.where((x) => x.kind == ParticleKind.heart), isNotEmpty);
    sim.pointerUp(1, p);
  });

  // F2-c8
  test('every interaction gives a haptic', () {
    bool haptic(void Function() act) {
      sim.drainEvents();
      act();
      return sim.drainEvents().any((e) => e.type == SimEventType.haptic);
    }

    void tap() {
      sim.pointerDown(1, sim.pos);
      run(0.05);
      sim.pointerUp(1, sim.pos);
    }

    void stroke() {
      final p = sim.pos;
      sim.pointerDown(1, p);
      for (var i = 0; i < 20; i++) {
        sim.pointerMove(1, p + Offset((i % 10) * 6.0 - 30, 0));
        run(1 / 60);
      }
    }

    expect(haptic(tap), isTrue, reason: 'tap');
    run(2);
    expect(
      haptic(() {
        for (var i = 0; i < 5; i++) {
          tap();
          run(0.1);
        }
      }),
      isTrue,
      reason: 'tickle',
    );
    run(2);
    expect(haptic(stroke), isTrue, reason: 'stroke');
    sim.pointerUp(1, sim.pos);
    run(2);
    sim = fresh();
    expect(
      haptic(() {
        sim.pointerDown(1, sim.pos);
        run(0.5);
      }),
      isTrue,
      reason: 'squish',
    );
    expect(haptic(() => run(1.2)), isTrue, reason: 'hug');
    expect(haptic(() => sim.pointerUp(1, sim.pos)), isTrue, reason: 'release');
    run(2);
    final start = sim.pos;
    sim.pointerDown(1, start);
    run(0.5);
    expect(haptic(() => sim.pointerMove(1, start + const Offset(30, -40))), isTrue, reason: 'pick up');
    sim.pointerMove(1, start + const Offset(60, -80));
    run(1 / 60);
    expect(haptic(() => sim.pointerUp(1, start + const Offset(60, -80))), isTrue, reason: 'throw');
    run(6);
    final eye = sim.eyePos(1);
    sim.pointerDown(1, eye);
    run(0.05);
    sim.pointerUp(1, eye);
    run(0.1);
    sim.drainEvents();
    sim.pointerDown(1, eye);
    run(0.05);
    sim.pointerUp(1, eye);
    final poke = sim.drainEvents();
    expect(poke.any((e) => e.id == 'eyePoke'), isTrue);
    expect(poke.any((e) => e.type == SimEventType.haptic), isTrue, reason: 'eye poke');
    run(1.5);
    expect(haptic(sim.shake), isTrue, reason: 'shake');
    expect(haptic(() => sim.eat(favorite: false)), isTrue, reason: 'eat');
    run(3);
    expect(haptic(sim.refuseFull), isTrue, reason: 'full');
    run(3);
    final c = sim.pos;
    sim.pointerDown(1, c + const Offset(50, 0));
    var spun = false;
    for (var i = 0; i <= 80 && !spun; i++) {
      final a = i / 80 * 2 * math.pi * 1.3;
      sim.pointerMove(1, c + Offset(50 * math.cos(a), 50 * math.sin(a)));
      run(1 / 60);
      final ev = sim.drainEvents();
      if (ev.any((e) => e.id == 'spin')) {
        spun = true;
        expect(ev.any((e) => e.type == SimEventType.haptic), isTrue, reason: 'spin');
      }
    }
    expect(spun, isTrue);
    sim.pointerUp(1, c);
    run(3);
    // A stroke that starts off the body and sweeps across it still buzzes.
    final off = sim.pos - Offset(sim.radius + sim.furLength + 30, 0);
    sim.pointerDown(1, off);
    expect(haptic(() {
      for (var i = 1; i <= 30; i++) {
        sim.pointerMove(1, off + Offset(i * 8.0, 0));
        run(1 / 60);
      }
    }), isTrue, reason: 'stroke from outside');
    sim.pointerUp(1, sim.pos);
    run(3);
    sim = fresh();
    run(46);
    expect(sim.asleep, isTrue);
    expect(haptic(() => sim.pointerDown(1, sim.pos)), isTrue, reason: 'wake');
    sim.pointerUp(1, sim.pos);
  });

  // F3-c1
  test('brushing: brush loop, sparkles, and more fluff than petting', () {
    double strokeFluff({required bool brush}) {
      final s = fresh()..brushMode = brush;
      sim = s;
      final p = s.pos;
      var fluff = 0.0;
      var loop = '';
      s.pointerDown(1, p - const Offset(60, 20));
      for (var i = 0; i < 60; i++) {
        s.pointerMove(1, p + Offset(-60 + (i % 30) * 4.0, -20));
        s.update(1 / 60);
        for (final e in s.drainEvents()) {
          if (e.type == SimEventType.fluff) fluff += e.value;
          if (e.type == SimEventType.loopStart) loop = e.id;
        }
      }
      if (brush) expect(s.particles.where((x) => x.kind == ParticleKind.sparkle), isNotEmpty);
      s.pointerUp(1, p);
      for (final e in s.drainEvents()) {
        if (e.type == SimEventType.fluff) fluff += e.value;
      }
      expect(loop, brush ? 'brush' : 'purr');
      return fluff;
    }

    final pet = strokeFluff(brush: false);
    final brush = strokeFluff(brush: true);
    expect(brush, greaterThan(pet * 2));
  });

  // F4-c2
  test('eating opens and closes the mouth and puffs the cheeks', () {
    sim.eat(favorite: false);
    var maxMouth = 0.0, maxCheek = 0.0;
    for (var t = 0.0; t < 1.2; t += 1 / 60) {
      sim.update(1 / 60);
      maxMouth = math.max(maxMouth, sim.mouthOpen);
      maxCheek = math.max(maxCheek, sim.cheekPuff);
    }
    expect(maxMouth, greaterThan(0.4));
    expect(maxCheek, greaterThan(0.8));
    expect(sim.expr, Expr.eating);
    run(2);
    expect(sim.expr, isNot(Expr.eating));
  });

  // F7-c2
  test('dozing: awake at 44 s, asleep with snore, zzz and slow breathing; a tap wakes it with a sleepy blink', () {
    run(44);
    expect(sim.asleep, isFalse);
    sim.drainEvents();
    run(2);
    expect(sim.asleep, isTrue);
    expect(sim.drainEvents().any((e) => e.type == SimEventType.loopStart && e.id == 'snore'), isTrue);
    expect(sim.blink, 1);
    var hi = 0.0;
    for (var t = 0.0; t < 5; t += 1 / 60) {
      sim.update(1 / 60);
      hi = math.max(hi, sim.breath);
    }
    expect(hi, greaterThan(1.02), reason: 'asleep the breath is deeper (0.03) than awake (0.018)');
    expect(sim.particles.where((x) => x.kind == ParticleKind.zzz), isNotEmpty);
    sim.pointerDown(1, sim.pos);
    run(0.05);
    sim.pointerUp(1, sim.pos);
    final ev = sim.drainEvents();
    expect(ev.any((e) => e.type == SimEventType.loopStop && e.id == 'snore'), isTrue);
    expect(ev.any((e) => e.id == 'boing'), isFalse, reason: 'the waking tap only wakes');
    expect(sim.expr, Expr.sleepy);
    final lids = <double>[];
    for (var t = 0.0; t < MofuSim.sleepyDuration - 0.1; t += 1 / 60) {
      sim.update(1 / 60);
      lids.add(sim.blink);
    }
    expect(lids.first, closeTo(0.55, 0.01), reason: 'heavy lids');
    expect(lids.reduce(math.max), greaterThan(0.95), reason: 'one slow blink');
    expect(lids.last, closeTo(0.55, 0.01));
    var blinkedAgainAt = -1.0;
    final awakeAt = sim.time;
    var prev = sim.blink;
    for (var t = 0.0; t < 2.4 && blinkedAgainAt < 0; t += 1 / 60) {
      sim.update(1 / 60);
      if (sim.expr == Expr.idle && prev == 0 && sim.blink > 0) blinkedAgainAt = sim.time - awakeAt;
      prev = sim.blink;
    }
    expect(sim.expr, Expr.idle);
    expect(blinkedAgainAt, -1, reason: 'no twitchy blink right after the sleepy one');
  });
}
