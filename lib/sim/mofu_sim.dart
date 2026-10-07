/// The living part of Mofu: physics, gestures, fur, expressions, particles.
///
/// Pure Dart with an injected clock and seeded randomness, so every behaviour
/// in SPEC F1–F7 is unit-testable without a device or a frame scheduler.
/// The widget layer feeds it pointer events and `update(dt)`, and drains
/// [events] each frame to play sounds, fire haptics and persist progress.
library;

import 'dart:math' as math;
import 'dart:ui' show Offset, Size;


enum MofuMode { rest, held, air }

enum Expr { idle, happy, bliss, giggle, surprised, protest, dizzy, love, sleepy, asleep, eating, content, proud }

enum ParticleKind { heart, sparkle, zzz, crumb, star }

enum SimEventType { sound, loopStart, loopStop, haptic, reaction, fluff, brushed, coach }

class SimEvent {
  const SimEvent(this.type, [this.id = '', this.value = 0]);
  final SimEventType type;
  final String id;
  final double value;

  @override
  String toString() => 'SimEvent($type, $id, $value)';
}

/// One hair of fur. Angle around the body, radial position (1 = outline),
/// length factor, natural curl, and the two dynamic quantities: [bend]
/// (sprung back to rest) and [mess] (only brushing removes it).
class Strand {
  Strand(this.angle, this.radial, this.length, this.curl, this.seed);
  final double angle;
  final double radial;
  final double length;
  final double curl;
  final double seed;
  double bend = 0;
  double bendVel = 0;
  double mess = 0;
}

class Particle {
  Particle(this.kind, this.pos, this.vel, this.life, this.size, this.spin);
  final ParticleKind kind;
  Offset pos;
  Offset vel;
  double life;
  final double size;
  final double spin;
  double age = 0;
  double get t => (age / life).clamp(0.0, 1.0);
}

class MofuSim {
  MofuSim({int seed = 7, this.reduceMotion = false}) : _rng = math.Random(seed) {
    _buildFur();
    _nextBlink = 2.5 + _rng.nextDouble() * 3.5;
    _nextGlance = 6 + _rng.nextDouble() * 8;
    _nextHop = 7 + _rng.nextDouble() * 7;
  }

  final math.Random _rng;
  bool reduceMotion;

  // ── tunables (seconds, logical pixels) ────────────────────────────────
  static const holdDelay = 0.45;
  static const hugDelay = 1.6;
  static const tapMaxDuration = 0.32;
  static const tapSlop = 9.0;
  static const strokeSlop = 8.0;
  static const tickleTaps = 5;
  static const tickleWindow = 1.5;
  static const eyeDoubleTapWindow = 0.42;
  static const idleSleepAfter = 45.0;
  static const nightSleepAfter = 12.0;
  static const gravity = 2600.0;
  static const sleepyDuration = 1.4;

  /// Set by the UI while something covers the room (first run, a sheet, a dialog):
  /// idle time stops counting, so Mofu is not found asleep when it closes.
  bool idleFrozen = false;

  // ── world ─────────────────────────────────────────────────────────────
  Size room = const Size(390, 700);
  double floorY = 560;
  double topY = 120;
  bool night = false;
  bool tossEnabled = true;
  bool brushMode = false;

  // ── body ──────────────────────────────────────────────────────────────
  double baseRadius = 92;
  double fluff = 0.1; // 0..1, fed from the store
  Offset pos = const Offset(195, 468);
  Offset vel = Offset.zero;
  MofuMode mode = MofuMode.rest;
  double squash = 0; // + = flattened, - = stretched
  double squashVel = 0;
  double squashTarget = 0;
  double rot = 0;
  double rotVel = 0;
  double time = 0;
  bool placed = false;

  // ── face ──────────────────────────────────────────────────────────────
  Expr expr = Expr.idle;
  double _exprTimer = 0;
  double lookX = 0, lookY = 0;
  double _lookTX = 0, _lookTY = 0;
  double blink = 0; // 0 open … 1 shut
  double _blinkT = -1;
  double _nextBlink = 3;
  double _nextGlance = 4;
  double _nextHop = 9;
  double mouthOpen = 0;
  double _mouthTarget = 0;
  double cheekPuff = 0;
  bool snackHover = false;
  bool asleep = false;
  double idleTime = 0;

  // ── fur & particles ───────────────────────────────────────────────────
  final List<Strand> strands = [];
  final List<Particle> particles = [];
  final List<SimEvent> events = [];

  // ── gesture state ─────────────────────────────────────────────────────
  int? _pointer;
  Offset _downPos = Offset.zero;
  Offset _lastPos = Offset.zero;
  Offset? finger;
  double _downTime = 0;
  bool _downOnBody = false;
  bool _stroking = false;
  int _hold = 0; // 0 none, 1 squish, 2 hug
  Offset _grabOffset = Offset.zero;
  final List<(double, Offset)> _dragSamples = [];
  final List<double> _tapTimes = [];
  double _lastEyeTap = -10;
  int _lastEyeSide = 0;
  double _petTime = 0;
  bool _purring = false;
  double _heartTimer = 0;
  double _spinAccum = 0;
  double _spinStart = 0;
  double? _lastAngle;
  double _pendingFluff = 0;
  bool _tossPending = false;
  bool _dizzyPending = false;
  double _brushSparkle = 0;
  bool _snoring = false;
  double _zzzTimer = 0;
  double _eatTimer = 0;
  bool _eatFavorite = false;

  // ── geometry ──────────────────────────────────────────────────────────
  /// Visual radius: fluffier Mofus are a little bigger.
  double get radius => baseRadius * (1 + 0.10 * fluff);

  /// The fur's reach beyond the body outline at this fluff level.
  double get furLength => baseRadius * (0.15 + 0.30 * fluff);

  double get breath {
    final speed = asleep ? 0.22 : 0.34;
    final amp = asleep ? 0.03 : 0.018;
    return 1 + amp * math.sin(time * 2 * math.pi * speed);
  }

  Offset get mouthPos => pos + Offset(0, radius * 0.24);

  Offset eyePos(int side) => pos + Offset(side * radius * 0.34, -radius * 0.06);

  double get eyeRadius => radius * 0.12;

  /// Horizontal keep-out from the walls: the body plus most of the fur.
  double get wallMargin => radius + furLength + 6;

  bool hitBody(Offset p) => (p - pos).distance <= radius + furLength * 0.8;

  bool nearMouth(Offset p) => (p - mouthPos).distance <= radius * 0.65;

  double get messLevel {
    if (strands.isEmpty) return 0;
    var s = 0.0;
    for (final st in strands) {
      s += st.mess;
    }
    return s / strands.length;
  }

  void _buildFur() {
    strands.clear();
    // Outline layer carries the silhouette; the inner layers give texture.
    const outer = 420, mid = 260, inner = 140;
    for (var i = 0; i < outer; i++) {
      final a = (i / outer) * 2 * math.pi + (_rng.nextDouble() - 0.5) * 0.03;
      strands.add(Strand(a, 1.0, 0.75 + _rng.nextDouble() * 0.55, _rng.nextDouble() * 2 - 1, _rng.nextDouble()));
    }
    for (var i = 0; i < mid; i++) {
      final a = _rng.nextDouble() * 2 * math.pi;
      strands.add(Strand(a, 0.84 + _rng.nextDouble() * 0.1, 0.45 + _rng.nextDouble() * 0.4, _rng.nextDouble() * 2 - 1, _rng.nextDouble()));
    }
    for (var i = 0; i < inner; i++) {
      final a = _rng.nextDouble() * 2 * math.pi;
      final r = 0.25 + math.sqrt(_rng.nextDouble()) * 0.5;
      strands.add(Strand(a, r, 0.18 + _rng.nextDouble() * 0.2, _rng.nextDouble() * 2 - 1, _rng.nextDouble()));
    }
  }

  // ── layout ────────────────────────────────────────────────────────────
  /// Called whenever the room is (re)measured. Keeps Mofu inside it.
  void layout(Size size, {required double top, required double floor}) {
    final oldWidth = room.width;
    final changed = size != room || top != topY || floor != floorY;
    room = size;
    topY = top;
    floorY = floor;
    baseRadius = math.min(size.width * 0.27, 130).toDouble();
    if (!placed || oldWidth < 1) {
      pos = Offset(size.width / 2, floorY - radius);
      placed = size.width > 1;
    } else if (changed && size.width != oldWidth) {
      // Keep Mofu at the same relative spot when the screen size changes
      // (first frames on some platforms report a transient tiny size).
      pos = Offset(pos.dx / oldWidth * size.width, pos.dy);
    }
    _clampToRoom();
  }

  void _clampToRoom() {
    final r = radius;
    final m = wallMargin;
    final x = pos.dx.clamp(m, math.max(m, room.width - m)).toDouble();
    var y = pos.dy;
    if (mode == MofuMode.rest) y = floorY - r;
    y = y.clamp(topY + r, math.max(topY + r, floorY - r)).toDouble();
    pos = Offset(x, y);
  }

  // ── events ────────────────────────────────────────────────────────────
  void _emit(SimEventType t, [String id = '', double v = 0]) => events.add(SimEvent(t, id, v));

  List<SimEvent> drainEvents() {
    if (events.isEmpty) return const [];
    final out = List<SimEvent>.of(events);
    events.clear();
    return out;
  }

  void _setExpr(Expr e, double seconds) {
    expr = e;
    _exprTimer = seconds;
  }

  void _resetIdle() {
    idleTime = 0;
  }

  // ── input ─────────────────────────────────────────────────────────────
  void pointerDown(int pointer, Offset p) {
    if (_pointer != null) return; // one finger drives Mofu; extra fingers are ignored
    _pointer = pointer;
    _downPos = p;
    _lastPos = p;
    finger = p;
    _downTime = time;
    _downOnBody = hitBody(p);
    _stroking = false;
    _strokeBuzzed = false;
    _hold = 0;
    _petTime = 0;
    _lastAngle = null;
    _spinAccum = 0;
    _onceThisGesture.clear();
    _resetIdle();
    _wokeOnDown = asleep && _downOnBody;
    if (_wokeOnDown) _wake();
  }

  void pointerMove(int pointer, Offset p) {
    if (pointer != _pointer) return;
    finger = p;
    _resetIdle();
    final moved = (p - _downPos).distance;
    if (mode == MofuMode.held) {
      _dragSamples.add((time, p));
      while (_dragSamples.length > 6) {
        _dragSamples.removeAt(0);
      }
      pos = p + _grabOffset;
      _clampHeld();
    } else if (_hold > 0 && moved > 12 && tossEnabled && mode == MofuMode.rest) {
      _pickUp(p);
    } else if (_hold == 0 && !_stroking && moved > strokeSlop) {
      _stroking = true;
      _spinStart = time;
      // Any stroke on the body answers the first-run "Pet me!" hint.
      if (_downOnBody) _emit(SimEventType.coach);
    }
    if (_stroking) _stroke(_lastPos, p);
    _lastPos = p;
  }

  void pointerUp(int pointer, Offset p) {
    if (pointer != _pointer) return;
    _pointer = null;
    finger = null;
    final dur = time - _downTime;
    if (mode == MofuMode.held) {
      _throw();
    } else if (_stroking) {
      _endStroke();
    } else if (_hold > 0) {
      squashTarget = 0;
      squashVel -= 4;
      _setExpr(Expr.happy, 0.9);
      _emit(SimEventType.sound, 'pop');
      _emit(SimEventType.haptic, 'light');
    } else if (dur <= tapMaxDuration && (p - _downPos).distance <= tapSlop && !_wokeOnDown) {
      // (The tap that wakes Mofu only wakes it, so the sleepy blink plays out.)
      if (_downOnBody) {
        _tap(p);
      } else {
        _lookAt(p, 1.2);
      }
    }
    _hold = 0;
    _stroking = false;
  }

  void pointerCancel(int pointer) {
    if (pointer != _pointer) return;
    _pointer = null;
    finger = null;
    if (mode == MofuMode.held) {
      mode = MofuMode.air;
      vel = Offset.zero;
    }
    if (_stroking) _endStroke();
    if (_hold > 0) _setExpr(Expr.happy, 0.6);
    _hold = 0;
    _stroking = false;
    squashTarget = 0;
  }

  bool _wokeOnDown = false;
  bool _strokeBuzzed = false;

  void _lookAt(Offset p, double seconds) {
    final d = p - pos;
    final len = d.distance;
    if (len < 1) return;
    _lookTX = (d.dx / len) * math.min(1, len / (radius * 2));
    _lookTY = (d.dy / len) * math.min(1, len / (radius * 2));
    _nextGlance = time + seconds;
  }

  void _tap(Offset p) {
    // Eye double-tap → protest.
    for (final side in const [-1, 1]) {
      if ((p - eyePos(side)).distance <= eyeRadius * 1.7) {
        if (_lastEyeSide == side && time - _lastEyeTap <= eyeDoubleTapWindow) {
          _lastEyeTap = -10;
          _setExpr(Expr.protest, 1.3);
          squashVel += 5;
          rotVel += 3 * side;
          _emit(SimEventType.sound, 'hmph');
          _emit(SimEventType.haptic, 'medium');
          _emit(SimEventType.reaction, 'eyePoke');
          return;
        }
        _lastEyeSide = side;
        _lastEyeTap = time;
      }
    }
    _tapTimes.add(time);
    _tapTimes.removeWhere((t) => time - t > tickleWindow);
    if (_tapTimes.length >= tickleTaps) {
      _tapTimes.clear();
      _setExpr(Expr.giggle, 1.8);
      _mouthTarget = 0.7;
      rotVel += (_rng.nextBool() ? 1 : -1) * 6;
      squashVel += 7;
      _burst(ParticleKind.heart, pos - Offset(0, radius * 0.9), 4);
      _emit(SimEventType.sound, 'giggle');
      _emit(SimEventType.haptic, 'medium');
      _emit(SimEventType.reaction, 'tickle');
      return;
    }
    squashVel += 9;
    if (expr != Expr.giggle) _setExpr(Expr.happy, 0.9);
    _burst(ParticleKind.sparkle, p, 3);
    _emit(SimEventType.sound, 'squeak');
    _emit(SimEventType.haptic, 'light');
    _emit(SimEventType.reaction, 'boing');
  }

  void _stroke(Offset a, Offset b) {
    final seg = b - a;
    final segLen = seg.distance;
    if (segLen < 0.5) return;
    final onBody = hitBody(b);
    if (!onBody) return;
    if (!_strokeBuzzed) {
      _strokeBuzzed = true;
      _emit(SimEventType.haptic, 'light');
    }
    final dir = seg / segLen;
    final r = radius;
    final reach = r * 0.55;
    var tidied = 0.0;
    for (final s in strands) {
      final tip = strandTip(s);
      final d = (tip - b).distance;
      if (d > reach) continue;
      final w = 1 - d / reach;
      // Bend sideways along the stroke: the tangential component of the
      // stroke direction relative to this strand's outward direction.
      final out = Offset(math.cos(s.angle), math.sin(s.angle));
      final tangential = out.dx * dir.dy - out.dy * dir.dx;
      s.bendVel += tangential * w * math.min(segLen, 40) * 0.9;
      if (brushMode && s.mess > 0) {
        final before = s.mess;
        s.mess = math.max(0, s.mess - 0.09 * w);
        tidied += before - s.mess;
      }
    }
    // Brushing also smooths the whole coat a little, so no hard-to-reach
    // strand can keep Mofu messy forever.
    if (brushMode) {
      final global = math.min(segLen, 40) * 0.0016;
      for (final s in strands) {
        if (s.mess > 0) {
          final before = s.mess;
          s.mess = math.max(0, s.mess - global);
          tidied += before - s.mess;
        }
      }
    }
    _lookAt(b, 0.8);
    final gain = segLen * (brushMode ? 0.010 : 0.0035);
    _pendingFluff += gain;
    if (brushMode) {
      _brushSparkle += segLen;
      if (_brushSparkle > 28) {
        _brushSparkle = 0;
        _burst(ParticleKind.sparkle, b, 1);
      }
      _emit(SimEventType.brushed);
      if (tidied > 0 && messLevel < 0.03 && _wasMessy) {
        _wasMessy = false;
        _emit(SimEventType.reaction, 'tidy');
        _emit(SimEventType.sound, 'sparkle');
      }
    }
    // Spin: angle of the finger around the body centre, accumulated.
    final ang = math.atan2(b.dy - pos.dy, b.dx - pos.dx);
    if (_lastAngle != null) {
      var da = ang - _lastAngle!;
      if (da > math.pi) da -= 2 * math.pi;
      if (da < -math.pi) da += 2 * math.pi;
      _spinAccum += da;
      if (time - _spinStart > 2.5) {
        _spinStart = time;
        _spinAccum = 0;
      }
      if (_spinAccum.abs() > 2 * math.pi * 1.05) {
        final sign = _spinAccum.sign;
        _spinAccum = 0;
        _spinStart = time;
        rotVel += sign * 26;
        _setExpr(Expr.dizzy, 1.6);
        _emit(SimEventType.sound, 'whee');
        _emit(SimEventType.haptic, 'light');
        _emit(SimEventType.reaction, 'spin');
      }
    }
    _lastAngle = ang;
    if (!_purring) {
      _purring = true;
      _emit(SimEventType.loopStart, brushMode ? 'brush' : 'purr');
    }
  }

  bool _wasMessy = false;

  void _endStroke() {
    if (_purring) {
      _purring = false;
      _emit(SimEventType.loopStop, 'purr');
      _emit(SimEventType.loopStop, 'brush');
    }
    _flushFluff();
    if (expr == Expr.bliss) _setExpr(Expr.happy, 0.8);
    _petTime = 0;
  }

  void _pickUp(Offset p) {
    mode = MofuMode.held;
    _grabOffset = pos - p;
    _dragSamples
      ..clear()
      ..add((time, p));
    squashTarget = -0.10; // dangles, a little stretched
    _hold = 0;
    _setExpr(Expr.surprised, 0.5);
    _emit(SimEventType.sound, 'wee');
    _emit(SimEventType.haptic, 'light');
  }

  void _clampHeld() {
    final r = radius;
    final m = wallMargin;
    pos = Offset(
      pos.dx.clamp(m, math.max(m, room.width - m)).toDouble(),
      pos.dy.clamp(topY + r, math.max(topY + r, floorY - r)).toDouble(),
    );
  }

  void _throw() {
    mode = MofuMode.air;
    squashTarget = 0;
    var v = Offset.zero;
    if (_dragSamples.length >= 2) {
      final a = _dragSamples.first, b = _dragSamples.last;
      final dt = b.$1 - a.$1;
      if (dt > 0.001) v = (b.$2 - a.$2) / dt;
    }
    final speed = v.distance;
    if (speed > 4200) v = v / speed * 4200;
    vel = v;
    _tossPending = speed > 700;
    _dizzyPending = speed > 2300;
    if (_tossPending) _emit(SimEventType.sound, 'wee');
    _emit(SimEventType.haptic, 'light');
  }

  /// Shake gesture from the accelerometer (UI applies the kill switch).
  void shake() {
    if (asleep) _wake();
    for (final s in strands) {
      s.mess = math.min(1, s.mess + 0.45 + _rng.nextDouble() * 0.4);
      s.bendVel += (_rng.nextDouble() - 0.5) * 30;
    }
    _wasMessy = true;
    _setExpr(Expr.dizzy, 2.2);
    rotVel += (_rng.nextBool() ? 1 : -1) * 12;
    squashVel += 8;
    _burst(ParticleKind.star, pos - Offset(0, radius), 4);
    _emit(SimEventType.sound, 'wobble');
    _emit(SimEventType.haptic, 'heavy');
    _emit(SimEventType.reaction, 'shake');
    _resetIdle();
  }

  /// A snack is being dragged over Mofu: anticipation.
  void setSnackHover(bool hovering, [Offset? at]) {
    snackHover = hovering;
    if (hovering && asleep) _wake();
    if (at != null) _lookAt(at, 0.6);
    _resetIdle();
  }

  /// The UI resolved a drop on the mouth through the store: play it out.
  void eat({required bool favorite}) {
    snackHover = false;
    _eatTimer = favorite ? 2.2 : 1.6;
    _eatFavorite = favorite;
    _setExpr(Expr.eating, _eatTimer);
    _emit(SimEventType.sound, 'chew');
    _emit(SimEventType.haptic, 'light');
    _burst(ParticleKind.crumb, mouthPos, 5);
    _resetIdle();
  }

  /// Too many snacks this hour: polite refusal (a head shake, a content face).
  void refuseFull() {
    snackHover = false;
    _setExpr(Expr.content, 1.8);
    rotVel += 7;
    _emit(SimEventType.sound, 'nope');
    _emit(SimEventType.haptic, 'light');
    _emit(SimEventType.reaction, 'full');
    _resetIdle();
  }

  /// A fluff milestone was crossed (the store decides which).
  void celebrate() {
    _setExpr(Expr.proud, 2.0);
    _burst(ParticleKind.sparkle, pos - Offset(0, radius * 0.4), 14, spread: 1.6);
    _burst(ParticleKind.heart, pos - Offset(0, radius), 5);
    if (!reduceMotion && mode == MofuMode.rest) {
      mode = MofuMode.air;
      vel = const Offset(0, -760);
    }
    _emit(SimEventType.sound, 'fanfare');
    _emit(SimEventType.haptic, 'success');
  }

  /// A small happy hop + sparkles (new outfit, first run, VoiceOver hug).
  void celebrateSmall() {
    _setExpr(Expr.happy, 1.2);
    _burst(ParticleKind.sparkle, pos - Offset(0, radius * 0.5), 8, spread: 1.3);
    squashVel += 6;
    _emit(SimEventType.sound, 'sparkle');
    _emit(SimEventType.haptic, 'light');
  }

  /// The pointer currently driving Mofu, if any.
  int? get activePointer => _pointer;

  /// VoiceOver activation: a tap on the centre of the body.
  void tapCentre() {
    if (_pointer != null) return;
    pointerDown(-1, pos);
    pointerUp(-1, pos);
  }

  /// Screenshot/debug seam: keep an expression until something else happens.
  void holdExpression(Expr e) => _setExpr(e, 1e9);

  /// Daily first brush bonus.
  void sparkleBurst() {
    _burst(ParticleKind.sparkle, pos, 10, spread: 1.3);
    _emit(SimEventType.sound, 'sparkle');
  }

  void _wake() {
    asleep = false;
    if (_snoring) {
      _snoring = false;
      _emit(SimEventType.loopStop, 'snore');
    }
    _setExpr(Expr.sleepy, sleepyDuration);
    _emit(SimEventType.sound, 'yawn');
    _emit(SimEventType.haptic, 'light');
    _emit(SimEventType.reaction, 'wake');
    _resetIdle();
  }

  void _fallAsleep() {
    asleep = true;
    _setExpr(Expr.asleep, 1e9);
    _emit(SimEventType.reaction, 'sleep');
    if (!_snoring) {
      _snoring = true;
      _emit(SimEventType.loopStart, 'snore');
    }
  }

  void _flushFluff() {
    if (_pendingFluff > 0.05) {
      _emit(SimEventType.fluff, '', _pendingFluff);
      _pendingFluff = 0;
    }
  }

  void _burst(ParticleKind k, Offset at, int n, {double spread = 1}) {
    if (particles.length > 160) return;
    for (var i = 0; i < n; i++) {
      final a = -math.pi / 2 + (_rng.nextDouble() - 0.5) * 2.2 * spread;
      final sp = switch (k) {
        ParticleKind.heart => 70 + _rng.nextDouble() * 60,
        ParticleKind.sparkle => 90 + _rng.nextDouble() * 140,
        ParticleKind.zzz => 30.0,
        ParticleKind.crumb => 80 + _rng.nextDouble() * 80,
        ParticleKind.star => 60 + _rng.nextDouble() * 50,
      };
      final life = switch (k) {
        ParticleKind.heart => 1.4 + _rng.nextDouble() * 0.5,
        ParticleKind.sparkle => 0.7 + _rng.nextDouble() * 0.4,
        ParticleKind.zzz => 2.2,
        ParticleKind.crumb => 0.7,
        ParticleKind.star => 1.2,
      };
      final size = switch (k) {
        ParticleKind.heart => 14 + _rng.nextDouble() * 8,
        ParticleKind.sparkle => 6 + _rng.nextDouble() * 6,
        ParticleKind.zzz => 16.0,
        ParticleKind.crumb => 3 + _rng.nextDouble() * 3,
        ParticleKind.star => 10.0,
      };
      particles.add(Particle(k, at, Offset(math.cos(a), math.sin(a)) * sp, life, size, (_rng.nextDouble() - 0.5) * 4));
    }
  }

  // ── geometry used by painter and tests ────────────────────────────────
  /// World position of a strand's tip (ignores squash; good enough for hits).
  Offset strandTip(Strand s) {
    final r = radius * s.radial;
    final dir = s.angle + s.bend * 0.35;
    final len = furLength * s.length * (s.radial >= 1 ? 1 : 0.6);
    final root = pos + Offset(math.cos(s.angle), math.sin(s.angle)) * r;
    return root + Offset(math.cos(dir), math.sin(dir)) * len;
  }

  // ── simulation step ───────────────────────────────────────────────────
  void update(double dt) {
    if (dt <= 0) return;
    dt = math.min(dt, 1 / 30); // a long frame must not explode the springs
    time += dt;

    // Hold → squish → hug, only while still and on the body.
    if (_pointer != null && _downOnBody && !_stroking && mode == MofuMode.rest) {
      final held = time - _downTime;
      if (_hold == 0 && held >= holdDelay) {
        _hold = 1;
        squashTarget = 0.24;
        _setExpr(Expr.bliss, 1e9);
        _emit(SimEventType.sound, 'squish');
        _emit(SimEventType.haptic, 'light');
        _emit(SimEventType.reaction, 'squish');
      } else if (_hold == 1 && held >= hugDelay) {
        _hold = 2;
        squashTarget = 0.18;
        _setExpr(Expr.love, 1e9);
        _burst(ParticleKind.heart, pos - Offset(0, radius), 5);
        _emit(SimEventType.sound, 'coo');
        _emit(SimEventType.haptic, 'medium');
        _emit(SimEventType.reaction, 'hug');
      }
    } else if (_hold > 0 && _pointer == null) {
      squashTarget = 0;
    }

    // Petting: bliss face, hearts, journal entries.
    if (_stroking && _pointer != null) {
      _petTime += dt;
      if (!brushMode) {
        if (expr != Expr.dizzy) _setExpr(Expr.bliss, 0.4);
        _heartTimer += dt;
        if (_heartTimer > 0.45) {
          _heartTimer = 0;
          _burst(ParticleKind.heart, pos - Offset(0, radius * 0.95), 1);
        }
        if (_petTime > 0.6) _emitOnce('pet');
        if (_petTime > 4) _emitOnce('purr');
      } else {
        _emitOnce('brush');
      }
      if (_pendingFluff > 0.6) _flushFluff();
    }

    // Body physics.
    switch (mode) {
      case MofuMode.rest:
        pos = Offset(pos.dx, floorY - radius);
        if (!asleep && !reduceMotion && _pointer == null && time >= _nextHop && expr != Expr.eating) {
          _nextHop = time + 6 + _rng.nextDouble() * 8;
          mode = MofuMode.air;
          // Idle hops wander a little but drift home towards the centre.
          final home = (room.width / 2 - pos.dx) * 0.8;
          vel = Offset(home + (_rng.nextDouble() - 0.5) * 120, -430);
          squashVel -= 3;
        } else if (time >= _nextHop) {
          _nextHop = time + 6 + _rng.nextDouble() * 8;
        }
      case MofuMode.held:
        break;
      case MofuMode.air:
        vel = vel + Offset(0, gravity * dt);
        pos = pos + vel * dt;
        _collide();
    }

    // Springs: squash, rotation, eyes, mouth.
    squashVel += (-140 * (squash - squashTarget) - 13 * squashVel) * dt;
    squash += squashVel * dt;
    squash = squash.clamp(-0.35, 0.45);
    rotVel += (-90 * rot - 9 * rotVel) * dt;
    rot += rotVel * dt;

    final follow = finger;
    if (follow != null && mode != MofuMode.held) {
      _lookAt(follow, 0.4);
    } else if (time >= _nextGlance && !asleep) {
      _nextGlance = time + 6 + _rng.nextDouble() * 8;
      final glance = _rng.nextDouble();
      if (glance < 0.4) {
        _lookTX = 0;
        _lookTY = 0;
      } else {
        _lookTX = (_rng.nextDouble() - 0.5) * 1.4;
        _lookTY = (_rng.nextDouble() - 0.5) * 0.8;
      }
    }
    final k = math.min(1.0, dt * 9);
    lookX += (_lookTX - lookX) * k;
    lookY += (_lookTY - lookY) * k;

    // Blink. Just woken: heavy lids, one slow sleepy blink.
    if (asleep || expr == Expr.sleepy) {
      // No ordinary blink resumes the moment Mofu is awake again.
      _blinkT = -1;
      _nextBlink = math.max(_nextBlink, time + 2.5);
    }
    if (asleep) {
      blink = 1;
    } else if (expr == Expr.sleepy) {
      final t = sleepyDuration - _exprTimer;
      blink = 0.55 + 0.45 * (t > 0.3 && t < 0.9 ? math.sin((t - 0.3) / 0.6 * math.pi) : 0);
    } else if (_blinkT >= 0) {
      _blinkT += dt;
      blink = _blinkT < 0.07 ? _blinkT / 0.07 : math.max(0, 1 - (_blinkT - 0.07) / 0.08);
      if (_blinkT > 0.15) {
        _blinkT = -1;
        blink = 0;
      }
    } else {
      blink = 0;
      if (time >= _nextBlink) {
        _blinkT = 0;
        _nextBlink = time + 2.5 + _rng.nextDouble() * 3.5;
      }
    }

    // Eating sequence, then the post-meal face.
    if (_eatTimer > 0) {
      _eatTimer -= dt;
      _mouthTarget = 0.5 + 0.5 * math.sin(time * 18).abs();
      cheekPuff = math.min(1, cheekPuff + dt * 4);
      if (_eatTimer <= 0) {
        _mouthTarget = 0;
        if (_eatFavorite) {
          _setExpr(Expr.love, 1.6);
          _burst(ParticleKind.heart, pos - Offset(0, radius), 6);
          _emit(SimEventType.sound, 'yum');
          _emit(SimEventType.reaction, 'favorite');
        } else {
          _setExpr(Expr.happy, 1.2);
          _emit(SimEventType.sound, 'yum');
        }
        _emit(SimEventType.reaction, 'yum');
      }
    } else {
      cheekPuff = math.max(0, cheekPuff - dt * 2);
      if (snackHover) {
        _mouthTarget = 0.65;
      } else if (expr != Expr.giggle) {
        _mouthTarget = 0;
      }
    }
    mouthOpen += (_mouthTarget - mouthOpen) * math.min(1.0, dt * 14);

    // Expression timeout.
    if (_exprTimer < 1e8) {
      _exprTimer -= dt;
      if (_exprTimer <= 0 && expr != Expr.idle && !asleep) {
        expr = Expr.idle;
        if (_mouthTarget > 0 && _eatTimer <= 0 && !snackHover) _mouthTarget = 0;
      }
    }

    // Sleep.
    if (_pointer == null && mode == MofuMode.rest && _eatTimer <= 0 && !snackHover && !idleFrozen) {
      idleTime += dt;
    }
    if (!asleep && mode == MofuMode.rest && _pointer == null &&
        idleTime >= (night ? nightSleepAfter : idleSleepAfter) && expr == Expr.idle) {
      _fallAsleep();
    }
    if (asleep) {
      _zzzTimer += dt;
      if (_zzzTimer > 1.7) {
        _zzzTimer = 0;
        _burst(ParticleKind.zzz, pos + Offset(radius * 0.55, -radius * 0.8), 1, spread: 0.2);
      }
    }

    // Fur springs; mess also fades on its own over a couple of minutes.
    for (final s in strands) {
      if (s.mess > 0) s.mess = math.max(0, s.mess - dt * 0.006);
      s.bendVel += (-60 * s.bend - 7 * s.bendVel) * dt;
      s.bend += s.bendVel * dt;
      if (s.bend > 2.2) s.bend = 2.2;
      if (s.bend < -2.2) s.bend = -2.2;
    }

    // Particles.
    for (final p in particles) {
      p.age += dt;
      switch (p.kind) {
        case ParticleKind.heart:
        case ParticleKind.zzz:
          p.vel = Offset(p.vel.dx * 0.97 + math.sin(p.age * 5 + p.spin) * 6, p.vel.dy * 0.985 - 12 * dt);
        case ParticleKind.sparkle:
        case ParticleKind.star:
          p.vel = p.vel * 0.94;
        case ParticleKind.crumb:
          p.vel = p.vel + Offset(0, 900 * dt);
      }
      p.pos = p.pos + p.vel * dt;
    }
    particles.removeWhere((p) => p.age >= p.life);
  }

  final Set<String> _onceThisGesture = {};
  void _emitOnce(String id) {
    if (_onceThisGesture.add('$id@$_downTime')) _emit(SimEventType.reaction, id);
  }

  void _collide() {
    final r = radius;
    final m = wallMargin;
    var x = pos.dx, y = pos.dy;
    var vx = vel.dx, vy = vel.dy;
    var bonked = false;
    if (x < m) {
      x = m;
      if (vx < 0) {
        bonked = vx.abs() > 450;
        vx = -vx * 0.55;
      }
    } else if (x > room.width - m) {
      x = room.width - m;
      if (vx > 0) {
        bonked = vx.abs() > 450;
        vx = -vx * 0.55;
      }
    }
    if (y < topY + r) {
      y = topY + r;
      if (vy < 0) vy = -vy * 0.4;
    }
    if (bonked) {
      squashVel += 6;
      _emit(SimEventType.sound, 'bonk');
      _emit(SimEventType.haptic, 'light');
    }
    if (y >= floorY - r) {
      y = floorY - r;
      if (vy > 0) {
        final impact = vy;
        if (impact < 160) {
          vy = 0;
          vx = 0;
          mode = MofuMode.rest;
          _landed();
        } else {
          vy = -vy * 0.42;
          vx *= 0.8;
          squashVel += math.min(16, impact / 140);
          if (impact > 500) {
            _emit(SimEventType.sound, 'boing');
            _emit(SimEventType.haptic, impact > 1400 ? 'medium' : 'light');
          }
        }
      }
    }
    pos = Offset(x, y);
    vel = Offset(vx, vy);
  }

  void _landed() {
    if (_tossPending) {
      _tossPending = false;
      _emit(SimEventType.reaction, 'toss');
      if (_dizzyPending) {
        _dizzyPending = false;
        _setExpr(Expr.dizzy, 2.4);
        _burst(ParticleKind.star, pos - Offset(0, radius), 5);
        _emit(SimEventType.reaction, 'dizzyToss');
        _emit(SimEventType.sound, 'wobble');
      } else {
        _setExpr(Expr.happy, 1.0);
      }
    }
  }
}
