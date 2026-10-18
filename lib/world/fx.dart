/// One-shot scene effects (dust puffs, celebration bursts, rings, confetti)
/// and friend entrances. Pure Dart and deterministic: every particle's path is
/// a closed-form function of (seed, age), so painting needs no per-frame state
/// and the effects are unit-tested in `test/world/fx_test.dart`.
library;

import 'dart:math' as math;
import 'dart:ui';

enum FxKind {
  /// Soft dust puffs either side of a landing.
  dust,

  /// Hearts and stars flung up and out (level-up, favourite snack).
  burst,

  /// An expanding glow ring (level-up, hatch flash).
  ring,

  /// Paper confetti with gravity and spin (hatch).
  confetti,

  /// Tiny bubbles flicking off when foam is rinsed.
  pop,
}

class Fx {
  Fx(this.kind, this.at, this.born, {this.seed = 1, this.scale = 1, this.color});
  final FxKind kind;
  final Offset at;
  final double born;
  final int seed;
  final double scale;
  final Color? color;

  double get duration => switch (kind) {
        FxKind.dust => 0.55,
        FxKind.burst => 1.1,
        FxKind.ring => 0.7,
        FxKind.confetti => 1.6,
        FxKind.pop => 0.45,
      };

  /// 0..1 through the effect, or null when it has not started / is over.
  double? progress(double now) {
    final t = (now - born) / duration;
    return t < 0 || t > 1 ? null : t;
  }
}

/// One particle at a moment: where, how big, how opaque, which way up.
class Particle {
  const Particle(this.pos, this.size, this.alpha, this.angle, this.index);
  final Offset pos;
  final double size;
  final double alpha;
  final double angle;
  final int index;
}

/// How a friend enters a room.
enum EntranceStyle {
  /// Falls in from above, squashes on landing, settles.
  drop,

  /// Pops up out of an egg with an overshoot.
  pop,

  /// A quick springy squish when touched (for species without their own).
  squish,
}

class Entrance {
  const Entrance(this.style, this.born, {this.from});
  final EntranceStyle style;
  final double born;

  /// For [EntranceStyle.pop]: where it emerges (the egg), in room space.
  final Offset? from;

  static const duration = 0.62;

  /// The landing moment for [EntranceStyle.drop] (seconds after [born]).
  static const impact = 0.26;
}

/// The transform an entrance applies around a friend's foot point.
class EntrancePose {
  const EntrancePose({this.dy = 0, this.dx = 0, this.sx = 1, this.sy = 1, this.alpha = 1});
  final double dx, dy, sx, sy, alpha;
  static const rest = EntrancePose();
}

double _easeOutCubic(double t) => 1 - math.pow(1 - t, 3).toDouble();

/// Damped spring from 1 toward rest: [amp] at t=0, ringing at [freq] Hz.
double _ring(double t, double amp, {double freq = 3.2, double decay = 7}) =>
    amp * math.exp(-decay * t) * math.cos(2 * math.pi * freq * t);

/// Pose of an entrance [age] seconds in, for a friend of [radius].
EntrancePose entrancePose(Entrance e, double age, double radius, Offset foot) {
  if (age >= Entrance.duration) return EntrancePose.rest;
  switch (e.style) {
    case EntranceStyle.drop:
      const fall = Entrance.impact;
      if (age < fall) {
        // Accelerating fall (gravity), slightly stretched, fading in at the top.
        final u = age / fall;
        return EntrancePose(dy: -radius * 2.4 * (1 - u * u), sx: 0.94, sy: 1.08, alpha: math.min(1, age / 0.08));
      }
      // Impact squash, then a damped wobble back to round.
      final s = _ring(age - fall, 0.2, freq: 3.4, decay: 8);
      return EntrancePose(sx: 1 + s, sy: 1 - s);
    case EntranceStyle.squish:
      final s = _ring(age, 0.08, freq: 4.2, decay: 9);
      return EntrancePose(sx: 1 + s, sy: 1 - s);
    case EntranceStyle.pop:
      final from = e.from ?? foot;
      if (age < 0.18) {
        // Rising out of the shell, small and tight.
        final u = _easeOutCubic(age / 0.18);
        final start = from - foot;
        return EntrancePose(dx: start.dx * (1 - u), dy: start.dy * (1 - u) - radius * 0.6 * u, sx: 0.35 + 0.75 * u, sy: 0.35 + 0.85 * u);
      }
      // Hop down with an overshooting stretch, then settle.
      final t = age - 0.18;
      final hop = t < 0.22 ? -radius * 0.6 * (1 - _easeOutCubic(t / 0.22)) : 0.0;
      final s = _ring(t, 0.16, freq: 3, decay: 6.5);
      return EntrancePose(dy: hop, sx: 1 - s, sy: 1 + s);
  }
}

/// Particles of [fx] at [now]. Deterministic in (seed, age).
List<Particle> particlesOf(Fx fx, double now) {
  final p = fx.progress(now);
  if (p == null) return const [];
  final age = now - fx.born;
  final rng = math.Random(fx.seed);
  final s = fx.scale;
  final out = <Particle>[];
  switch (fx.kind) {
    case FxKind.dust:
      for (var i = 0; i < 8; i++) {
        final side = i.isEven ? -1.0 : 1.0;
        final speed = (60 + rng.nextDouble() * 70) * s;
        final up = (8 + rng.nextDouble() * 22) * s;
        final x = side * speed * _easeOutCubic(p) * 0.55;
        final y = -up * math.sin(p * math.pi) - 4 * s;
        out.add(Particle(fx.at + Offset(x, y), (5 + rng.nextDouble() * 7) * s * (0.6 + p * 0.8), (1 - p) * 0.7, 0, i));
      }
    case FxKind.burst:
      const n = 12;
      for (var i = 0; i < n; i++) {
        final a = -math.pi / 2 + (i / (n - 1) - 0.5) * 2.4 + (rng.nextDouble() - 0.5) * 0.3;
        final v = (150 + rng.nextDouble() * 120) * s;
        final g = 260 * s;
        final pos = fx.at + Offset(math.cos(a) * v * age, math.sin(a) * v * age + 0.5 * g * age * age);
        final grow = math.min(1.0, age / 0.12);
        out.add(Particle(pos, (9 + rng.nextDouble() * 6) * s * grow, p < 0.6 ? 1 : (1 - p) / 0.4, (rng.nextDouble() - 0.5) * 0.8, i));
      }
    case FxKind.ring:
      final r = (30 + 110 * _easeOutCubic(p)) * s;
      out.add(Particle(fx.at, r, (1 - p) * 0.8, 0, 0));
    case FxKind.confetti:
      const n = 26;
      for (var i = 0; i < n; i++) {
        final a = -math.pi / 2 + (rng.nextDouble() - 0.5) * 2.8;
        final v = (220 + rng.nextDouble() * 200) * s;
        // Paper falls with drag: fast out, then a slow flutter down.
        final drag = 2.2;
        final k = (1 - math.exp(-drag * age)) / drag;
        final sway = math.sin(age * (5 + rng.nextDouble() * 4) + i) * 10 * s * p;
        final pos = fx.at + Offset(math.cos(a) * v * k + sway, math.sin(a) * v * k + 90 * s * age * age);
        out.add(Particle(pos, (5 + rng.nextDouble() * 4) * s, p < 0.7 ? 1 : (1 - p) / 0.3, age * (6 + rng.nextDouble() * 8) + i, i));
      }
    case FxKind.pop:
      for (var i = 0; i < 6; i++) {
        final a = rng.nextDouble() * math.pi * 2;
        final v = (40 + rng.nextDouble() * 50) * s;
        out.add(Particle(fx.at + Offset(math.cos(a), math.sin(a)) * v * age, (2.5 + rng.nextDouble() * 2.5) * s * (1 - p * 0.5), 1 - p, 0, i));
      }
  }
  return out;
}
