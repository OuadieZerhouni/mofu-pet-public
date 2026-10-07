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
}

