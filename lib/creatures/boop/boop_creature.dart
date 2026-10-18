/// The living part of a Boop: springs, gestures, combos, expressions and its
/// own particles. Pure Dart (dart:math + dart:ui value types), seeded
/// randomness, no timers: the room feeds it pointer events and `update(dt)`.
///
/// Behaviour follows the Boop! prototype SPEC F1–F3:
/// - tap the nose = boop (squash, happy face, pitched squeak, light haptic,
///   floating heart); boops <1.0 s apart chain into a combo (tiers at 10/25/50,
///   a sneeze on every 30th);
/// - tap the body = wobble + giggle; drag = stretch toward the finger and
///   spring back; hold ≥0.6 s = hug (eyes closed, hearts stream);
/// - breathes and blinks when idle, gets sleepy after 30 s, falls asleep.
library;

import 'dart:math' as math;
import 'dart:ui' show Color, Offset, Path, Rect;

import '../creature.dart';
import 'boop_catalog.dart';

/// Which face the painter draws.
enum BoopFace { open, happy, hug, sleepy, asleep, surprised, munch }

enum BoopParticleKind { heart, sparkle, confetti, zzz }

/// A fire-and-forget effect, in room coordinates, owned by the simulation.
class BoopParticle {
  BoopParticle({
    required this.kind,
    required this.pos,
    required this.vel,
    required this.life,
    required this.size,
    required this.color,
    this.spin = 0,
    this.gravity = 0,
  });

  final BoopParticleKind kind;
  Offset pos;
  Offset vel;
  final double life;
  final double size;
  final Color color;
  final double spin;
  final double gravity;
  double age = 0;
  double angle = 0;

  double get t => (age / life).clamp(0.0, 1.0);
  bool get dead => age >= life;
}

/// Everything the painter needs about the body this frame.
class BoopPose {
  const BoopPose({
    this.squashX = 1,
    this.squashY = 1,
    this.tilt = 0,
    this.shear = Offset.zero,
    this.face = BoopFace.open,
    this.look = Offset.zero,
    this.blink = 0,
    this.squint = 0,
    this.blush = 0,
    this.noseFlash = 0,
    this.earSwing = 0,
    this.mouthOpen = 0,
    this.hop = 0,
  });

  /// Scale about the feet.
  final double squashX;
  final double squashY;

  /// Rotation about the feet, radians.
  final double tilt;

  /// Drag deformation (−1…1 per axis), as a fraction of body size.
  final Offset shear;
  final BoopFace face;

  /// Where the eyes look, −1…1 per axis.
  final Offset look;

  /// 0 = eyes open … 1 = shut (open face only).
  final double blink;

  /// 0..1 half-closed contented eyes (grooming).
  final double squint;
  final double blush;
  final double noseFlash;

  /// Ears swing opposite to the body's motion, radians.
  final double earSwing;

  /// 0..1 how far the mouth is open (snack hover, munching, giggling).
  final double mouthOpen;

  /// Height above the ground in px (≥ 0), for the contact shadow.
  final double hop;
}

/// A damped spring toward [target]. Semi-implicit Euler, advanced in small
/// substeps by the simulation so frame times up to 0.1 s stay stable.
class BoopSpring {
  BoopSpring(this.value, {this.stiffness = 420, this.damping = 16}) : target = value;
  double value;
  double target;
  double velocity = 0;
  final double stiffness;
  final double damping;

  void step(double dt) {
    final a = -stiffness * (value - target) - damping * velocity;
    velocity += a * dt;
    value += velocity * dt;
  }
}

class _Ptr {
  _Ptr(this.start, this.downT) : last = start;
  final Offset start;
  final double downT;
  Offset last;
  bool onNose = false;
  bool dragging = false;
  bool hugging = false;
  double hugT = 0;
  double heartT = 0;
}

class BoopCreature extends Creature {
  BoopCreature({required super.friendId, required super.seed, required this.variant})
      : _rng = math.Random(seed),
        spec = boopVariantById(variant) {
    _nextBlink = 2 + _rng.nextDouble() * 3;
    _nextGlance = 3 + _rng.nextDouble() * 4;
    _wanderTimer = 7 + _rng.nextDouble() * 6;
    _applyLayout();
  }

  /// Critter id (`CreatureLook.variant`).
  final String variant;
  final BoopVariant spec;
  final math.Random _rng;

  // ── tunables ──────────────────────────────────────────────────────────
  static const comboWindow = 1.0;
  static const hugAfter = 0.6;
  static const sneezeEvery = 30;
  static const comboTiers = [10, 25, 50];
  static const sleepyAfter = 30.0;
  static const asleepAfter = 60.0;
  static const nightSleepyAfter = 10.0;
  static const nightAsleepAfter = 22.0;
  static const _gravity = 2600.0;
  static const _maxParticles = 70;
  static const _heartColors = [Color(0xFFFF6F8E), Color(0xFFFF9FB6), Color(0xFFFF7FB0)];
  static const _confettiColors = [
    Color(0xFFFF6F8E),
    Color(0xFFFFD36B),
    Color(0xFF7FD8B6),
    Color(0xFF8EC9FF),
    Color(0xFFC7A6FF),
  ];

  // ── world ─────────────────────────────────────────────────────────────
  Rect _area = const Rect.fromLTWH(0, 0, 400, 800);
  double _floorY = 620;
  double _radius = 52;
  bool _placed = false;
  double _x = 200;
  double _yRest = 570;
  double _hopY = 0; // ≤ 0 above rest
  double _hopVy = 0;
  double _vx = 0;

  // ── springs ───────────────────────────────────────────────────────────
  final _squashX = BoopSpring(1, stiffness: 520, damping: 14);
  final _squashY = BoopSpring(1, stiffness: 520, damping: 14);
  final _tilt = BoopSpring(0, stiffness: 260, damping: 7);
  final _shearX = BoopSpring(0, stiffness: 300, damping: 12);
  final _shearY = BoopSpring(0, stiffness: 300, damping: 12);
  final _lookX = BoopSpring(0, stiffness: 90, damping: 14);
  final _lookY = BoopSpring(0, stiffness: 90, damping: 14);
  final _ear = BoopSpring(0, stiffness: 190, damping: 6);

  // ── state ─────────────────────────────────────────────────────────────
  double _t = 0;
  double _idle = 0;
  bool _asleep = false;
  bool _dozeAnnounced = false;
  double _happyUntil = 0;
  double _surprisedUntil = 0;
  double _squintUntil = 0;
  double _blush = 0;
  double _noseFlash = 0;
  double _mouthOpen = 0;
  double _blinkStart = -10;
  double _nextBlink = 3;
  double _nextGlance = 4;
  double _glanceUntil = 0;
  Offset _glance = Offset.zero;
  Offset? _lookTarget;
  Offset? _fingerLook;
  double _fingerLookUntil = 0;
  Offset? _reactLook;
  double _reactLookUntil = 0;
  Offset? _snackAt;
  bool _snackHover = false;
  double _eatT = 0;
  bool _eatFavorite = false;
  double _shakeT = 0;
  double _wanderTimer = 8;
  int _hopsLeft = 0;
  double _hopCooldown = 0;
  double _hopDir = 1;
  double _zzzT = 0;
  double _groomHaptic = -10;
  double _groomGiggle = -10;
  double _groomReaction = -10;
  double _groomHeart = -10;
  final List<double> _bodyTaps = [];

  // ── combo ─────────────────────────────────────────────────────────────
  int _comboCount = 0;
  double _lastBoopT = -100;
  int _bestCombo = 0;
  int _totalBoops = 0;

  final Map<int, _Ptr> _pointers = {};
  final List<CreatureEvent> _events = [];

  /// Effects owned by the sim; the painter draws them.
  final List<BoopParticle> particles = [];

  // ── public API beyond the interface ───────────────────────────────────
  /// The live combo length: 0 once the 1.0 s window has lapsed.
  int get combo => (_comboCount > 0 && _t - _lastBoopT <= comboWindow) ? _comboCount : 0;

  /// The best combo reached this session.
  int get bestCombo => _bestCombo;

  /// Boops landed this session (combos or not).
  int get totalBoops => _totalBoops;

  /// True if [p] (room coordinates) is on the nose.
  bool hitNose(Offset p) => (p - nosePos).distance <= _noseHitRadius;

  /// Where the nose is right now (follows squash and stretch).
  Offset get nosePos => _xf(Offset(0, b * 0.14));

  /// Simulation clock in seconds.
  double get time => _t;

  // ── geometry ──────────────────────────────────────────────────────────
  /// Source-box equivalent: the prototype lays everything out in a square of
  /// side s (body half-width 0.33 s, half-height 0.29 s).
  double get s => _radius * 3.18;
  double get a => s * 0.33 * math.sqrt(spec.aspect);
  double get b => s * 0.29 / math.sqrt(spec.aspect);

  /// Centre → ground contact.
  double get footDrop => b * (spec.ears == BoopEars.jelly ? 1.3 : 1.0);

  double get _noseHitRadius => math.max(a * 0.3, 20);

  /// How far ears and limbs reach, as (side in a, top in b).
  (double, double) get _reach => switch (spec.ears) {
        BoopEars.bunny => (1.15, 1.98),
        BoopEars.round => (1.2, 1.2),
        BoopEars.tuft => (1.1, 1.4),
        BoopEars.bumps => (1.1, 1.15),
        BoopEars.pig => (1.3, 1.3),
        BoopEars.cloud => (1.15, 1.45),
        BoopEars.none => (1.1, 1.05),
        BoopEars.floppy => (1.3, 1.05),
        BoopEars.jelly => (1.1, 1.08),
        BoopEars.leaf => (1.1, 1.7),
        BoopEars.horns => (1.5, 1.28),
      };

  /// Maps a point given relative to the body centre (undeformed) to room
  /// coordinates, applying squash, shear and tilt about the feet exactly as
  /// the painter does.
  Offset _xf(Offset local) {
    final p = pose;
    final pv = Offset(0, footDrop);
    final v = local - pv;
    final x1 = v.dx - p.shear.dx * 0.45 * v.dy;
    final y1 = v.dy * (1 + p.shear.dy * 0.25);
    final x2 = x1 * p.squashX;
    final y2 = y1 * p.squashY;
    final c = math.cos(p.tilt), sn = math.sin(p.tilt);
    return position + pv + Offset(x2 * c - y2 * sn, x2 * sn + y2 * c);
  }

  // ── Creature: placement ───────────────────────────────────────────────
  @override
  Species get species => Species.boop;

  @override
  Offset get position => Offset(_x, _yRest + _hopY);

  @override
  set position(Offset p) {
    _x = p.dx;
    _yRest = p.dy;
    _hopY = 0;
    _hopVy = 0;
    _vx = 0;
  }

  @override
  double get radius => _radius;

  @override
  Offset get footPoint => position + Offset(0, footDrop);

  @override
  Path get silhouette {
    const n = 2.5;
    const steps = 48;
    final path = Path();
    for (var i = 0; i < steps; i++) {
      final t = i / steps * 2 * math.pi;
      final ct = math.cos(t), st = math.sin(t);
      var x = a * ct.sign * math.pow(ct.abs(), 2 / n);
      var y = b * st.sign * math.pow(st.abs(), 2 / n);
      if (y > 0) y *= 0.97;
      x *= 1 + 0.06 * (y / b);
      final q = _xf(Offset(x, y));
      i == 0 ? path.moveTo(q.dx, q.dy) : path.lineTo(q.dx, q.dy);
    }
    path.close();
    return path;
  }

  @override
  Rect get bounds {
    final (side, top) = _reach;
    final pts = [
      _xf(Offset(-a * side, -b * top)),
      _xf(Offset(a * side, -b * top)),
      _xf(Offset(a * side, footDrop + b * 0.08)),
      _xf(Offset(-a * side, footDrop + b * 0.08)),
    ];
    var l = pts.first.dx, r = l, tp = pts.first.dy, bt = tp;
    for (final q in pts) {
      l = math.min(l, q.dx);
      r = math.max(r, q.dx);
      tp = math.min(tp, q.dy);
      bt = math.max(bt, q.dy);
    }
    return Rect.fromLTRB(l, tp, r, bt).inflate(2);
  }

  double get _wallMargin => math.min(a * math.max(1.05, _reach.$1 - 0.1), math.max(1.0, _area.width / 2 - 1));

  @override
  void layout(Rect area, {required double floorY, double sizeScale = 1}) {
    final old = _area;
    final hadPlace = _placed;
    _area = area;
    _floorY = floorY;
    _radius = area.width * 0.13 * (sizeScale <= 0 ? 1 : sizeScale);
    if (!hadPlace || old.width < 1) {
      _x = area.center.dx;
      _placed = area.width > 1;
    } else if (old.width != area.width) {
      _x = area.left + (_x - old.left) / old.width * area.width;
    }
    _applyLayout();
  }

  void _applyLayout() {
    _yRest = _floorY - footDrop;
    _clampX();
  }

  @override
  void shiftX(double dx) {
    if (pinned) return;
    _x += dx;
    _clampX();
  }

  void _clampX() {
    final m = _wallMargin;
    final lo = _area.left + m;
    final hi = math.max(lo, _area.right - m);
    if (!_x.isFinite) _x = _area.center.dx;
    _x = _x.clamp(lo, hi).toDouble();
  }

  // ── Creature: life ────────────────────────────────────────────────────
  @override
  LifeState get life {
    if (_eatT > 0) return LifeState.eating;
    if (_asleep) return LifeState.asleep;
    return LifeState.awake;
  }

  double get _sleepyAfter => night ? nightSleepyAfter : sleepyAfter;
  double get _asleepAfter => night ? nightAsleepAfter : asleepAfter;
  bool get _dozing => _asleep || _idle > _sleepyAfter;

  @override
  void sleep() {
    _asleep = true;
    _dozeAnnounced = true;
    _hopsLeft = 0;
    _eatT = 0;
  }

  @override
  void wake() {
    final was = _asleep || _idle > _sleepyAfter;
    _asleep = false;
    _idle = 0;
    _dozeAnnounced = false;
    if (was && !reduceMotion) {
      _squashY.value = 1.08;
      _squashX.value = 0.95;
    }
  }

  void _touch() {
    _idle = 0;
    _dozeAnnounced = false;
  }

  // ── events ────────────────────────────────────────────────────────────
  void _emit(CreatureEventType type, [String id = '', double value = 0]) => _events.add(CreatureEvent(type, id, value));
  void _sound(String id, [double pitch = 1]) => _emit(CreatureEventType.sound, id, pitch);
  void _haptic(String id) => _emit(CreatureEventType.haptic, id);
  void _reaction(String id) => _emit(CreatureEventType.reaction, id);

  @override
  List<CreatureEvent> drainEvents() {
    if (_events.isEmpty) return const [];
    final out = List<CreatureEvent>.of(_events);
    _events.clear();
    return out;
  }

  // ── pose ──────────────────────────────────────────────────────────────
  BoopFace get _face {
    if (_pointers.values.any((p) => p.hugging)) return BoopFace.hug;
    if (_eatT > 0) return BoopFace.munch;
    if (_t < _surprisedUntil) return BoopFace.surprised;
    if (_t < _happyUntil) return BoopFace.happy;
    if (_asleep) return BoopFace.asleep;
    if (_idle > _sleepyAfter) return BoopFace.sleepy;
    return BoopFace.open;
  }

  double get _blinkAmount {
    final d = _t - _blinkStart;
    if (d < 0 || d > 0.16) return 0;
    return d < 0.08 ? d / 0.08 : (0.16 - d) / 0.08;
  }

  BoopPose get pose {
    var sx = _squashX.value, sy = _squashY.value;
    final dozing = _dozing;
    if (!reduceMotion) {
      final breath = math.sin(_t * (dozing ? 1.6 : 2.6));
      sy *= 1 + breath * (dozing ? 0.022 : 0.014);
      sx *= 1 - breath * 0.006;
    }
    if (_eatT > 0 && !reduceMotion) sx *= 1 + 0.045 * math.sin(_t * 17);
    final squint = _t < _squintUntil ? math.min(1.0, (_squintUntil - _t) * 8) : 0.0;
    return BoopPose(
      squashX: sx,
      squashY: sy,
      tilt: _tilt.value,
      shear: Offset(_shearX.value, _shearY.value),
      face: _face,
      look: Offset(_lookX.value, _lookY.value),
      blink: _blinkAmount,
      squint: squint,
      blush: _blush,
      noseFlash: _noseFlash,
      earSwing: _ear.value,
      mouthOpen: _mouthOpen,
      hop: -_hopY,
    );
  }

  // ── update ────────────────────────────────────────────────────────────
  @override
  void update(double dt) {
    if (!dt.isFinite || dt <= 0) return;
    dt = math.min(dt, 0.1);
    final steps = math.max(1, (dt * 120).ceil());
    final h = dt / steps;
    for (var i = 0; i < steps; i++) {
      _earDrive();
      for (final sp in [_squashX, _squashY, _tilt, _shearX, _shearY, _lookX, _lookY, _ear]) {
        sp.step(h);
      }
    }
    _t += dt;
    _idle += dt;

    _blush = math.max(0, _blush - dt * 1.4);
    _noseFlash = math.max(0, _noseFlash - dt * 4);

    _updateSleep();
    _updatePointers(dt);
    _updateEating(dt);
    _updateShake(dt);
    _updateWander(dt);
    _updateMotion(dt);
    _updateMouth(dt);
    _updateEyes();
    _updateZzz(dt);
    _stepParticles(dt);
  }

  void _earDrive() {
    // Ears lag behind the body: they swing against its tilt and vertical motion.
    final t = (-_tilt.velocity * 0.1 - _squashY.velocity * 0.05 - _shearX.value * 0.35).clamp(-0.55, 0.55);
    _ear.target = t.toDouble();
  }

  void _updateSleep() {
    if (!_asleep && _idle > _asleepAfter) {
      _asleep = true;
    }
    if (!_asleep && _idle > _sleepyAfter && !_dozeAnnounced) {
      _dozeAnnounced = true;
      _reaction('boop.sleepy');
    }
    if (_asleep) _hopsLeft = 0;
  }

  void _updatePointers(double dt) {
    for (final e in _pointers.entries) {
      final i = e.value;
      if (!i.onNose && !i.dragging && !i.hugging && _t - i.downT >= hugAfter) {
        i.hugging = true;
        _blush = 1;
        _startHug(i);
      }
      if (i.hugging) {
        _blush = 1;
        i.hugT += dt;
        i.heartT -= dt;
        if (i.heartT <= 0) {
          i.heartT = 0.26 + _rng.nextDouble() * 0.12;
          final at = position + Offset((_rng.nextDouble() - 0.5) * a * 1.1, -b * (0.2 + _rng.nextDouble() * 0.5));
          _heart(at);
        }
        if (i.hugT >= 3) {
          i.hugT -= 3;
          _emit(CreatureEventType.progress, 'bond', 1);
        }
      }
    }
  }

  void _startHug(_Ptr i) {
    i.heartT = 0;
    _sound('boop.hug');
    _haptic('light');
    _reaction('boop.hug');
    _emit(CreatureEventType.progress, 'bond', 1);
    if (!reduceMotion) {
      _squashY.value = 0.94;
      _squashX.value = 1.05;
    }
  }

  void _updateEating(double dt) {
    if (_eatT <= 0) return;
    _eatT -= dt;
    if (_eatT <= 0) {
      _eatT = 0;
      _happyUntil = _t + 0.8;
      _blush = 1;
      if (_eatFavorite) {
        _sound('boop.giggle');
        _haptic('success');
        for (var k = 0; k < 3; k++) {
          _heart(position + Offset((_rng.nextDouble() - 0.5) * a, -b * 0.7));
        }
      } else {
        _haptic('selection');
      }
    }
  }

  void _updateShake(double dt) {
    if (_shakeT <= 0) return;
    _shakeT -= dt;
    if (_shakeT > 0 && !reduceMotion && !_pointers.values.any((p) => p.dragging)) {
      _shearX.target = 0.22 * math.sin(_t * 24) * math.min(1.0, _shakeT * 3);
    } else if (_shakeT <= 0 && !_pointers.values.any((p) => p.dragging)) {
      _shearX.target = 0;
    }
  }

  void _updateWander(double dt) {
    if (_hopCooldown > 0) _hopCooldown -= dt;
    final canWander = !pinned && !_asleep && !reduceMotion && _pointers.isEmpty && _eatT <= 0 && _idle > 5;
    if (!canWander) {
      _wanderTimer = math.max(_wanderTimer, 2);
      return;
    }
    _wanderTimer -= dt;
    if (_wanderTimer <= 0) {
      _wanderTimer = 8 + _rng.nextDouble() * 8;
      _hopsLeft = 1 + _rng.nextInt(3);
      _hopDir = _rng.nextBool() ? 1.0 : -1.0;
      final lo = _area.left + _wallMargin, hi = _area.right - _wallMargin;
      if (_x - lo < a * 1.5) _hopDir = 1;
      if (hi - _x < a * 1.5) _hopDir = -1;
      _reaction('boop.hop');
    }
    if (_hopsLeft > 0 && _hopY == 0 && _hopVy == 0 && _hopCooldown <= 0) {
      _hopsLeft--;
      _hopCooldown = 0.4;
      _launch(math.sqrt(2 * _gravity * b * 0.32), _hopDir * _radius * 2.4);
      _squashY.value = 0.88;
      _squashX.value = 1.07;
    }
  }

  void _launch(double upSpeed, double vx) {
    _hopVy = -upSpeed;
    _hopY = -0.01;
    _vx = vx;
  }

  void _updateMotion(double dt) {
    final airborne = _hopY < 0 || _hopVy != 0;
    if (airborne) {
      _hopVy += _gravity * dt;
      _hopY += _hopVy * dt;
      if (_hopY >= 0) {
        final impact = _hopVy;
        _hopY = 0;
        _hopVy = 0;
        _vx *= 0.25;
        if (impact > 60 && !reduceMotion) {
          _squashY.value = 0.86;
          _squashX.value = 1.1;
          _squashY.velocity = 0;
        }
      }
    }
    if (_vx != 0) {
      _x += _vx * dt;
      _vx *= math.exp(-dt * (airborne ? 0.5 : 9));
      if (_vx.abs() < 1) _vx = 0;
    }
    final before = _x;
    _clampX();
    if (_x != before) _vx = 0;
    if (pinned) {
      _vx = 0;
    }
  }

  void _updateMouth(double dt) {
    double target = 0;
    if (_eatT > 0) {
      target = 0.45 + 0.4 * math.sin(_t * 17);
    } else if (_snackHover) {
      target = 0.9;
    }
    _mouthOpen += (target - _mouthOpen) * math.min(1.0, dt * 16);
  }

  void _updateEyes() {
    // Blink and glance only while the eyes are plain open.
    if (_face == BoopFace.open && _t >= _nextBlink) {
      _blinkStart = _t;
      _nextBlink = _t + 2 + _rng.nextDouble() * 3;
    }
    Offset? target;
    if (_t < _fingerLookUntil && _fingerLook != null) {
      target = _fingerLook;
    } else if (_t < _reactLookUntil && _reactLook != null) {
      target = _reactLook;
    } else if (_snackHover && _snackAt != null) {
      target = _snackAt;
    } else if (_lookTarget != null) {
      target = _lookTarget;
    }
    if (target != null) {
      final c = position;
      _lookX.target = ((target.dx - c.dx) / a).clamp(-1.0, 1.0).toDouble();
      _lookY.target = ((target.dy - c.dy) / b).clamp(-1.0, 1.0).toDouble();
      return;
    }
    if (_dozing || _face != BoopFace.open) {
      _lookX.target = 0;
      _lookY.target = 0;
      return;
    }
    if (_t >= _nextGlance) {
      _glance = Offset((_rng.nextDouble() - 0.5) * 1.4, (_rng.nextDouble() - 0.5) * 0.8);
      _glanceUntil = _t + 1.2;
      _nextGlance = _t + 3 + _rng.nextDouble() * 4;
    }
    if (_t < _glanceUntil) {
      _lookX.target = _glance.dx;
      _lookY.target = _glance.dy;
    } else {
      _lookX.target = 0;
      _lookY.target = 0;
    }
  }

  void _updateZzz(double dt) {
    if (!_dozing) {
      _zzzT = 0;
      return;
    }
    _zzzT -= dt;
    if (_zzzT <= 0) {
      _zzzT = 1.5;
      _addParticle(BoopParticle(
        kind: BoopParticleKind.zzz,
        pos: _xf(Offset(a * 0.7, -b * 0.95)),
        vel: reduceMotion ? Offset.zero : Offset(_radius * 0.22, -_radius * 0.5),
        life: 2.0,
        size: _radius * 0.3,
        color: const Color(0xFF7A6363),
      ));
    }
  }

  void _stepParticles(double dt) {
    for (final p in particles) {
      p.age += dt;
      final damp = 1 - 1.2 * dt;
      p.vel = Offset(p.vel.dx * damp, p.vel.dy * damp + p.gravity * dt);
      p.pos += p.vel * dt;
      p.angle += p.spin * dt;
    }
    particles.removeWhere((p) => p.dead);
  }

  void _addParticle(BoopParticle p) {
    if (particles.length >= _maxParticles) particles.removeAt(0);
    particles.add(p);
  }

  // ── particle recipes ──────────────────────────────────────────────────
  void _heart(Offset at, {double scale = 1}) {
    if (reduceMotion) return;
    final ang = -math.pi / 2 + (_rng.nextDouble() - 0.5) * 1.6;
    final speed = (_radius * 1.8 + _rng.nextDouble() * _radius * 1.5);
    _addParticle(BoopParticle(
      kind: BoopParticleKind.heart,
      pos: at,
      vel: Offset(math.cos(ang), math.sin(ang)) * speed,
      life: 0.9 + _rng.nextDouble() * 0.4,
      size: (_radius * 0.32 + _rng.nextDouble() * _radius * 0.2) * scale,
      color: _heartColors[_rng.nextInt(_heartColors.length)],
      gravity: -40,
    ));
  }

  void _sparkles(Offset at, int count) {
    if (reduceMotion) return;
    for (var i = 0; i < count; i++) {
      final ang = _rng.nextDouble() * math.pi * 2;
      final speed = _radius * 1.2 + _rng.nextDouble() * _radius * 2.4;
      _addParticle(BoopParticle(
        kind: BoopParticleKind.sparkle,
        pos: at,
        vel: Offset(math.cos(ang), math.sin(ang)) * speed,
        life: 0.5 + _rng.nextDouble() * 0.3,
        size: _radius * 0.16 + _rng.nextDouble() * _radius * 0.14,
        color: const Color(0xFFFFD36B),
      ));
    }
  }

  void _confetti(Offset at, int count) {
    if (reduceMotion) return;
    for (var i = 0; i < count; i++) {
      final ang = -math.pi / 2 + (_rng.nextDouble() - 0.5) * 2.4;
      final speed = _radius * 4 + _rng.nextDouble() * _radius * 5;
      _addParticle(BoopParticle(
        kind: BoopParticleKind.confetti,
        pos: at,
        vel: Offset(math.cos(ang), math.sin(ang)) * speed,
        life: 1.2 + _rng.nextDouble() * 0.5,
        size: _radius * 0.13 + _rng.nextDouble() * _radius * 0.11,
        color: _confettiColors[_rng.nextInt(_confettiColors.length)],
        spin: (_rng.nextDouble() - 0.5) * 14,
        gravity: 520,
      ));
    }
  }

  // ── input ─────────────────────────────────────────────────────────────
  bool _hitBody(Offset p) {
    final c = position;
    final dx = (p.dx - c.dx) / (a * 1.08 + 5);
    final dy = (p.dy - c.dy) / (b * 1.12 + 5);
    return dx * dx + dy * dy <= 1;
  }

  @override
  bool hitTest(Offset p) => hitNose(p) || _hitBody(p);

  @override
  bool pointerDown(int pointer, Offset p) {
    if (_pointers.containsKey(pointer)) return true;
    final onNose = hitNose(p);
    if (!onNose && !_hitBody(p)) return false;
    final wasDozing = _dozing;
    final info = _Ptr(p, _t)..onNose = onNose;
    _pointers[pointer] = info;
    _wakeForTouch();
    _fingerLook = p;
    _fingerLookUntil = _t + 2;
    if (onNose) {
      _boop();
      return true;
    }
    if (wasDozing) _wobble(p, sound: false);
    return true;
  }

  void _wakeForTouch() {
    _asleep = false;
    _touch();
  }

  @override
  void pointerMove(int pointer, Offset p) {
    final info = _pointers[pointer];
    if (info == null) return;
    info.last = p;
    _touch();
    _fingerLook = p;
    _fingerLookUntil = _t + 2;
    if (info.onNose || info.hugging) return;
    final delta = p - info.start;
    final slop = math.max(8.0, _radius * 0.2);
    if (!info.dragging && delta.distance > slop) info.dragging = true;
    if (info.dragging && !reduceMotion) {
      _shakeT = 0;
      _shearX.target = (delta.dx / (_radius * 1.3)).clamp(-0.6, 0.6).toDouble();
      _shearY.target = (delta.dy / (_radius * 1.6)).clamp(-0.35, 0.35).toDouble();
    }
  }

  @override
  void pointerUp(int pointer, Offset p) {
    final info = _pointers.remove(pointer);
    if (info == null) return;
    _touch();
    if (info.dragging) {
      final stretched = _shearX.value.abs() > 0.12 || _shearY.value.abs() > 0.08;
      _releaseShear();
      if (stretched && !reduceMotion) {
        _sound('boop.boing');
        _haptic('light');
        _reaction('boop.stretch');
      }
    } else if (info.hugging) {
      _squashY.velocity -= 2;
      _happyUntil = _t + 0.9;
    } else if (!info.onNose) {
      _wobble(info.last);
      _bodyTap();
    }
  }

  @override
  void pointerCancel(int pointer) {
    final info = _pointers.remove(pointer);
    if (info == null) return;
    if (info.dragging) _releaseShear();
  }

  void _releaseShear() {
    if (_pointers.values.any((p) => p.dragging)) return;
    _shearX.target = 0;
    _shearY.target = 0;
    _shearX.velocity -= _shearX.value * 4;
  }

  @override
  int? get activePointer => _pointers.isEmpty ? null : _pointers.keys.first;

  // ── gestures ──────────────────────────────────────────────────────────
  void _boopAnim() {
    if (reduceMotion) {
      _squashX.value = 0.96;
      _squashY.value = 0.96;
    } else {
      _squashX.value = 1.16;
      _squashY.value = 0.8;
      _squashY.velocity = -1.5;
      _ear.velocity += (_rng.nextBool() ? 1 : -1) * 3;
    }
    _happyUntil = _t + 0.28;
    _blush = 1;
    _noseFlash = 1;
  }

  void _boop() {
    final chained = combo > 0;
    _comboCount = chained ? _comboCount + 1 : 1;
    _lastBoopT = _t;
    _totalBoops++;
    if (_comboCount > _bestCombo) _bestCombo = _comboCount;
    _boopAnim();
    final n = _comboCount;
    _sound(boopSqueakId(spec.pitch, n));
    _haptic('light');
    if (n == 1) _reaction('boop.boop');
    _heart(nosePos + Offset(0, -b * 0.1));

    if (comboTiers.contains(n)) {
      _reaction('boop.combo$n');
      _emit(CreatureEventType.progress, 'combo', n.toDouble());
      _emit(CreatureEventType.bubble, 'bubble.combo$n');
      _haptic('medium');
      _sound(n == 50 ? 'boop.fanfare' : 'boop.chime');
      _sparkles(position + Offset(0, -b * 0.6), n == 10 ? 8 : 12);
      if (n >= 25) _confetti(position + Offset(0, -b * 0.7), n == 50 ? 40 : 24);
    }
    if (n % sneezeEvery == 0) _sneeze();
  }

  void _sneeze() {
    _surprisedUntil = _t + 0.65;
    if (!reduceMotion) {
      _squashY.value = 1.18;
      _squashX.value = 0.88;
      _tilt.velocity += (_rng.nextBool() ? 1 : -1) * 2.0;
    }
    _sound('boop.sneeze');
    _reaction('boop.sneeze');
    _emit(CreatureEventType.bubble, 'bubble.sneeze');
    _confetti(nosePos, 28);
  }

  /// A shaken phone sets the jelly body wobbling.
  @override
  void shake() {
    if (asleep) wake();
    _wobble(Offset(_x + radius, 0));
    _reaction('boop.wobble');
  }

  void _wobble(Offset p, {bool sound = true}) {
    if (!reduceMotion) {
      final dir = (p.dx - _x).sign;
      _tilt.velocity += -(dir == 0 ? 1 : dir) * 3.2;
      _squashY.value = 0.93;
      _ear.velocity += dir * 2;
    }
    _happyUntil = _t + 0.4;
    if (sound) {
      _sound('boop.giggle');
      _haptic('light');
    }
  }

  void _bodyTap() {
    _reaction('boop.wobble');
    _bodyTaps.add(_t);
    _bodyTaps.removeWhere((t) => _t - t > 1.5);
    if (_bodyTaps.length >= 4) {
      _bodyTaps.clear();
      _happyUntil = _t + 1.4;
      if (!reduceMotion) {
        _tilt.velocity += (_rng.nextBool() ? 1 : -1) * 6;
        _squashY.velocity += 4;
      }
      _heart(position + Offset(0, -b * 0.9));
      _heart(position + Offset(a * 0.3, -b * 0.8));
      _haptic('medium');
      _reaction('boop.tickle');
    }
  }

  // ── Creature: the rest of the world ───────────────────────────────────
  @override
  void lookAt(Offset? target) => _lookTarget = target;

  @override
  void nudge(Offset impulse) {
    if (!impulse.dx.isFinite || !impulse.dy.isFinite) return;
    if (pinned) return;
    _vx = (_vx + impulse.dx).clamp(-900.0, 900.0).toDouble();
    if (impulse.dx.abs() > 150 && !reduceMotion) {
      _tilt.velocity += (impulse.dx * 0.0016).clamp(-2.0, 2.0);
    }
    if (impulse.dy < -300 && _hopY == 0 && _hopVy == 0) {
      _hopVy = math.max(-420.0, impulse.dy * 0.5);
      _hopY = -0.01;
    }
    if (impulse.distance > 900 && _asleep) wake();
  }

  @override
  void react(SocialCue cue, {Offset? from}) {
    switch (cue) {
      case SocialCue.friendTouched:
        if (from != null) _glanceAt(from, 1.5);
      case SocialCue.landedOnMe:
        _wakeForTouch();
        _surprisedUntil = _t + 0.6;
        if (!reduceMotion) {
          _squashY.value = 0.82;
          _squashX.value = 1.14;
        }
        _sound('boop.boing');
        _haptic('light');
        _reaction('boop.surprise');
        if (from != null) _glanceAt(from, 1.2);
      case SocialCue.nuzzled:
        // Boop-back: a friend's nuzzle is a boop that does not count toward
        // the player's combo.
        _wakeForTouch();
        _boopAnim();
        _sound(boopSqueakId(spec.pitch, 1));
        _haptic('light');
        _reaction('boop.boopBack');
        _heart(nosePos + Offset(0, -b * 0.1));
        if (from != null) _glanceAt(from, 1.5);
      case SocialCue.celebrate:
        celebrate();
    }
  }

  void _glanceAt(Offset p, double seconds) {
    _reactLook = p;
    _reactLookUntil = _t + seconds;
  }

  @override
  void celebrate() {
    _wakeForTouch();
    _happyUntil = _t + 0.9;
    _blush = 1;
    if (!reduceMotion) {
      _squashY.value = 0.78;
      _squashX.value = 1.15;
    }
    _sparkles(position + Offset(0, -b * 0.7), 8);
    _heart(position + Offset(-a * 0.4, -b * 0.8));
    _heart(position + Offset(a * 0.4, -b * 0.8));
    _sound('boop.chime');
    _haptic('success');
    _reaction('boop.cheer');
  }

  // ── Creature: feeding ─────────────────────────────────────────────────
  @override
  Offset get mouth => _xf(Offset(0, b * 0.36));

  @override
  bool nearMouth(Offset p) => (p - mouth).distance <= _radius * 0.9;

  @override
  void setSnackHover(bool hovering, [Offset? at]) {
    _snackHover = hovering;
    _snackAt = hovering ? at : null;
    if (hovering) {
      _touch();
      _asleep = false;
    }
  }

  @override
  void eat({required bool favorite}) {
    _wakeForTouch();
    _snackHover = false;
    _eatFavorite = favorite;
    _eatT = favorite ? 1.7 : 1.2;
    if (!reduceMotion) {
      _squashY.value = 1.1;
      _squashX.value = 0.93;
    }
    _sound('boop.pop');
    _haptic('light');
    _reaction(favorite ? 'boop.yum' : 'boop.munch');
    _emit(CreatureEventType.progress, 'bond', favorite ? 2 : 1);
  }

  @override
  void refuseFull() {
    _wakeForTouch();
    _snackHover = false;
    _shakeT = 0.6;
    _squintUntil = _t + 0.6;
    if (!reduceMotion) _tilt.velocity += (_rng.nextBool() ? 1 : -1) * 5;
    _sound('boop.oops');
    _haptic('light');
    _reaction('boop.full');
    _emit(CreatureEventType.bubble, 'bubble.full');
  }

  // ── Creature: care tools ──────────────────────────────────────────────
  @override
  void groom(Offset p, double speed, {required String tool}) {
    if (!speed.isFinite) speed = 0;
    if (_asleep || _idle > _sleepyAfter) wake();
    _touch();
    _squintUntil = _t + 0.35;
    _blush = math.max(_blush, 0.6);
    if (_t - _groomHaptic > 0.14) {
      _groomHaptic = _t;
      _haptic('selection');
      if (!reduceMotion) {
        // Jelly wobble: alternate sides, harder with speed.
        final k = (speed / 600).clamp(0.2, 1.6);
        final dir = (p.dx - _x) >= 0 ? 1.0 : -1.0;
        _tilt.velocity += dir * k * 1.1 * (_rng.nextBool() ? 1 : -1);
        _squashX.velocity += k * 1.6 * (_rng.nextBool() ? 1 : -1);
        _squashY.velocity += k * 1.2 * (_rng.nextBool() ? 1 : -1);
        _ear.velocity += dir * k * 1.5;
      }
    }
    if (_t - _groomGiggle > 1.4) {
      _groomGiggle = _t;
      _sound('boop.giggle');
      _mouthOpen = 0.6;
    }
    if (_t - _groomReaction > 4) {
      _groomReaction = _t;
      _reaction('boop.jelly');
    }
    if (_t - _groomHeart > 0.7) {
      _groomHeart = _t;
      _heart(position + Offset((_rng.nextDouble() - 0.5) * a, -b * 0.8), scale: 0.8);
    }
  }

  // ── Creature: accessories ─────────────────────────────────────────────
  @override
  Anchor anchor(AccessorySlot slot) {
    final local = switch (slot) {
      AccessorySlot.head => Offset(0, -b * 0.97),
      AccessorySlot.face => Offset(0, -b * 0.06),
      AccessorySlot.neck => Offset(0, b * 0.78),
    };
    final scale = _radius / 92 * 1.05;
    return Anchor(_xf(local), scale, _tilt.value);
  }
}
