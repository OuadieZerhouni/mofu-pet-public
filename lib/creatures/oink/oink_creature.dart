/// The piglet: a pure-Dart simulation implementing [Creature].
///
/// Ported from the Oink prototype (`PigView` + `PigPose` + `PigGeometry`).
/// Everything animated lives in [pose]; `OinkArt` paints a pose and nothing
/// else. The simulation owns its particles, its timers (advanced by
/// `update(dt)`, never by `Timer`) and an event queue the room drains once a
/// frame.
///
/// Design space: 1 unit = 1/86 of [radius]; origin = [position], which sits in
/// the overlap between head and body so it is always inside the [silhouette].
/// +y is down, the feet rest at y = [OinkGeo.footY].
///
/// Gestures (SPEC "Pig interactions"):
/// - snout tap: one of six oinks, snout squish, speech bubble
/// - head tap: happy eyes, ears perk, hearts
/// - belly tap, or a back-and-forth rub on belly/head: giggle, legs kick, hearts
/// - ear tap: that ear flops, snort
/// - tail tap: tail spins, surprised "oink?"
/// - press: squash and stretch; hold then drag: pick up; release: toss
/// A sleeping pig grumbles when poked and stays asleep (three pokes wake it).
library;

import 'dart:math' as math;
import 'dart:ui' show Offset, Path, Rect;

import '../creature.dart';

/// Where on the pig a touch landed.
enum OinkZone { snout, ear, tail, head, belly }

enum OinkEyes { open, happy, closed, sleepy, surprised, sad, squint }

enum OinkMouth { smile, oink, munch, frown, open }

enum OinkParticleKind { heart, sparkle, zzz, crumb, drop }

/// Fixed geometry in design units (origin = [Creature.position]).
class OinkGeo {
  OinkGeo._();

  /// Design units per "radius" of the creature.
  static const unitRadius = 86.0;

  static const headR = 90.0;
  static const headC = Offset(0, -46.8);
  static const bodyRx = 84.0;
  static const bodyRy = 66.0;
  static const bodyC = Offset(0, 48);

  /// Ground contact (bottom of the body).
  static const footY = 118.5;

  static const snoutC = Offset(0, -12.6);
  static const snoutRx = 37.8;
  static const snoutRy = 26.1;
  static const mouthC = Offset(0, 25.2);
  static const eyeL = Offset(-37.8, -45.0);
  static const eyeR = Offset(37.8, -45.0);
  static const earBaseL = Offset(-52.2, -108.0);
  static const earBaseR = Offset(52.2, -108.0);
  static const earHitL = Offset(-68.4, -133.2);
  static const earHitR = Offset(68.4, -133.2);
  static const tailBase = Offset(81.5, 40.1);
  static const tailHit = Offset(93.5, 34.1);
  static const crown = Offset(0, -122.4);
  static const neck = Offset(0, 30.6);

  /// Head group pivots around the neck.
  static const headPivot = Offset(0, 29.7);

  /// Loose extents for [Creature.bounds].
  static const boundsLeft = -118.0;
  static const boundsRight = 118.0;
  static const boundsTop = -176.0;
}

/// Every animated parameter [OinkArt] reads. Rebuilt each step.
class OinkPose {
  double breath = 0; // 0..1 eased
  double blink = 0; // 0 open .. 1 shut
  OinkEyes eyes = OinkEyes.open;
  OinkMouth mouth = OinkMouth.smile;
  double mouthOpen = 0;
  double earLeft = 0; // radians, + = flop outward
  double earRight = 0;
  double tail = 0;
  double snoutSquish = 0;
  double headTilt = 0;
  double shake = 0;

  /// Vertical hop in design units (negative = up).
  double bounce = 0;
  double legKick = 0;
  Offset look = Offset.zero;
  double blush = 0.45;

  /// + = flattened (wider, shorter), - = stretched.
  double squash = 0;

  /// Whole-body lean around the feet, radians.
  double lean = 0;
}

class OinkParticle {
  OinkParticle(this.kind, this.pos, this.vel, this.life, this.size, this.spin) : maxLife = life;
  final OinkParticleKind kind;
  Offset pos; // room coordinates
  Offset vel;
  double life;
  final double maxLife;
  final double size; // px
  double spin;
  double get t => 1 - (life / maxLife).clamp(0.0, 1.0);
}

enum _Action { oink, happy, giggle, earFlop, tailSpin, munch, refuse, sparkle, surprised, grumble, cheer, yawn, peek }

const _actionDuration = <_Action, double>{
  _Action.oink: 0.45,
  _Action.happy: 1.1,
  _Action.giggle: 1.0,
  _Action.earFlop: 0.6,
  _Action.tailSpin: 0.8,
  _Action.munch: 1.3,
  _Action.refuse: 0.9,
  _Action.sparkle: 1.0,
  _Action.surprised: 0.6,
  _Action.grumble: 0.7,
  _Action.cheer: 1.4,
  _Action.yawn: 1.2,
  _Action.peek: 0.9,
};

enum _Mode { rest, held, air }

class _Later {
  _Later(this.at, this.fn);
  final double at;
  final void Function() fn;
}

class OinkCreature extends Creature {
  OinkCreature({required super.friendId, required super.seed}) : _rng = math.Random(seed) {
    _nextBlink = 1.5 + _rng.nextDouble() * 2.5;
    _nextTwitch = 3 + _rng.nextDouble() * 4;
    _wanderIn = 4 + _rng.nextDouble() * 5;
    _hopIn = 8 + _rng.nextDouble() * 8;
    _pos = Offset(_area.center.dx, _restY);
  }

  final math.Random _rng;

  // ── tunables ──────────────────────────────────────────────────────────
  static const tapMaxDuration = 0.35;
  static const tapSlop = 10.0;
  static const strokeSlop = 8.0;
  static const holdDelay = 0.45;
  static const pickupSlop = 12.0;
  static const gravity = 2400.0;
  static const hitMargin = 8.0;
  static const rubStroke = 14.0; // design units of travel per rub stroke
  static const tickleTaps = 5;
  static const tickleWindow = 1.4;
  static const pokesToWake = 3;

  // ── world ─────────────────────────────────────────────────────────────
  Rect _area = const Rect.fromLTWH(0, 0, 390, 700);
  double _floorY = 560;
  double _radius = 0.15 * 390;
  Offset _pos = Offset.zero;
  Offset _vel = Offset.zero;
  _Mode _mode = _Mode.rest;
  double time = 0;

  /// The animated pose; read by `OinkArt`.
  final OinkPose pose = OinkPose();
  final List<OinkParticle> _particles = [];
  final List<CreatureEvent> _events = [];
  final List<_Later> _later = [];

  // ── springs & timers ──────────────────────────────────────────────────
  double _sq = 0, _sqVel = 0, _sqTarget = 0;
  double _hopY = 0, _hopV = 0;
  double _lean = 0;
  double _breathPhase = 0;
  double _blinkT = -1, _nextBlink = 2;
  double _twitchT = -1, _nextTwitch = 4;
  bool _twitchLeft = true;
  Offset _look = Offset.zero;
  double _anticipation = 0;
  bool _hover = false;
  Offset? _hoverAt;

  _Action? _action;
  double _actionT = 0, _actionDur = 1;
  int _actionSide = -1;

  // ── life ──────────────────────────────────────────────────────────────
  bool _sleeping = false;
  bool _autoSlept = false;
  double _sleptFor = 0;
  bool _snoring = false;
  double _zzzT = 0;
  double _eatT = 0;
  double _idle = 0;
  double _wanderIn = 6, _hopIn = 10;
  bool _walking = false;
  double _walkTarget = 0;
  double _walkAmp = 0;
  double _walkPhase = 0;
  double _pokeWindow = 0;
  int _pokes = 0;

  // ── look ──────────────────────────────────────────────────────────────
  Offset? _lookTarget;
  Offset? _cueLook;
  double _cueLookT = 0;

  // ── gesture state ─────────────────────────────────────────────────────
  int? _pointer;
  Offset _downPos = Offset.zero;
  Offset _lastPos = Offset.zero;
  Offset? _finger;
  double _downTime = 0;
  OinkZone? _downZone;
  int _earSide = -1;
  int _downEarSide = -1;
  bool _stroking = false;
  int _hold = 0;
  Offset _grabOffset = Offset.zero;
  final List<(double, Offset)> _dragSamples = [];
  final List<double> _tapTimes = [];
  int _rubDir = 0;
  double _rubTravel = 0;
  double _lastRub = -10;
  double _lastRubSound = -10;
  double _lastHeadRubSound = -10;
  double _lastHaptic = -10;
  bool _thrown = false;
  int _lastOink = -1;
  int _lastGiggle = -1;
  final Map<String, double> _lastSound = {};

  // ── grooming ──────────────────────────────────────────────────────────
  double _groomT = 0;
  String _groomTool = '';
  double _groomSpeed = 0;
  double _groomGiggle = 0;
  double _groomScrub = 0;
  double _groomTotal = 0;

  // ── derived geometry ──────────────────────────────────────────────────
  double get _s => _radius / OinkGeo.unitRadius;
  double get _restY => _floorY - OinkGeo.footY * _s;
  double get _margin => 100 * _s;
  double get _minX => _area.left + _margin;
  double get _maxX => _area.right - _margin;
  double get _minY => _area.top + 130 * _s;

  /// Design units → room pixels.
  double get scale => _s;

  /// Where the floor is (shadow level), in room coordinates.
  double get groundY => _floorY;

  /// 0 when standing on the floor, grows with height (px).
  double get liftPx => math.max(0.0, _restY - _pos.dy) + math.max(0.0, -pose.bounce) * _s;

  /// Head tilt + shake, the angle the head group (and head accessories) wear.
  double get headAngle => pose.headTilt + pose.shake;

  List<OinkParticle> get particles => _particles;

  @override
  Species get species => Species.oink;

  @override
  Offset get position => _pos;
  @override
  set position(Offset p) {
    if (!p.dx.isFinite || !p.dy.isFinite) return;
    _pos = p;
    if (_mode == _Mode.rest && p.dy < _restY - 1.5) {
      _mode = _Mode.air;
      _vel = Offset.zero;
    }
  }

  @override
  double get radius => _radius;

  @override
  Offset get footPoint => Offset(_pos.dx, _pos.dy + OinkGeo.footY * _s);

  @override
  Offset get mouth => _headToRoom(OinkGeo.mouthC);

  @override
  bool nearMouth(Offset p) => (p - mouth).distance <= OinkGeo.headR * 0.62 * _s;

  @override
  int? get activePointer => _pointer;

  @override
  LifeState get life {
    if (_sleeping) return LifeState.asleep;
    if (_mode == _Mode.held) return LifeState.held;
    if (_mode == _Mode.air) return LifeState.airborne;
    if (_eatT > 0) return LifeState.eating;
    return LifeState.awake;
  }

  // ── transforms ────────────────────────────────────────────────────────
  /// Design point (squash, lean and hop applied) → room coordinates.
  Offset designToRoom(Offset q) {
    final sx = 1 + 0.16 * pose.squash;
    final sy = 1 - 0.18 * pose.squash;
    final x = q.dx * sx;
    final y = (q.dy - OinkGeo.footY) * sy;
    final c = math.cos(pose.lean), sn = math.sin(pose.lean);
    final rx = x * c - y * sn;
    final ry = x * sn + y * c;
    return Offset(_pos.dx + rx * _s, _pos.dy + (OinkGeo.footY + ry + pose.bounce) * _s);
  }

  /// Room coordinates → design point (inverse of [designToRoom]).
  Offset roomToDesign(Offset p) {
    final d = (p - _pos) / _s;
    final x0 = d.dx;
    final y0 = d.dy - pose.bounce - OinkGeo.footY;
    final c = math.cos(-pose.lean), sn = math.sin(-pose.lean);
    final x = (x0 * c - y0 * sn) / (1 + 0.16 * pose.squash);
    final y = (x0 * sn + y0 * c) / (1 - 0.18 * pose.squash);
    return Offset(x, y + OinkGeo.footY);
  }

  Offset _headPoint(Offset q) {
    final v = q - OinkGeo.headPivot;
    final a = headAngle;
    final c = math.cos(a), sn = math.sin(a);
    return OinkGeo.headPivot + Offset(v.dx * c - v.dy * sn, v.dx * sn + v.dy * c) + Offset(0, -2.2 * pose.breath);
  }

  Offset _headToRoom(Offset q) => designToRoom(_headPoint(q));

  Offset get _headCenterRoom => _headToRoom(OinkGeo.headC);

  Path _ellipsePath(Offset c, double rx, double ry, Offset Function(Offset) xf) {
    const n = 40;
    final pts = <Offset>[];
    for (var i = 0; i < n; i++) {
      final a = i / n * 2 * math.pi;
      pts.add(xf(c + Offset(math.cos(a) * rx, math.sin(a) * ry)));
    }
    return Path()..addPolygon(pts, true);
  }

  @override
  Path get silhouette {
    final body = _ellipsePath(OinkGeo.bodyC, OinkGeo.bodyRx, OinkGeo.bodyRy, designToRoom);
    final head = _ellipsePath(OinkGeo.headC, OinkGeo.headR * 1.06, OinkGeo.headR * 0.96, _headToRoom);
    return body..addPath(head, Offset.zero);
  }

  @override
  Rect get bounds {
    final top = OinkGeo.boundsTop + math.min(0.0, pose.bounce);
    return Rect.fromLTRB(
      _pos.dx + OinkGeo.boundsLeft * _s,
      _pos.dy + top * _s,
      _pos.dx + OinkGeo.boundsRight * _s,
      _pos.dy + OinkGeo.footY * _s,
    );
  }

  // ── layout ────────────────────────────────────────────────────────────
  @override
  void layout(Rect area, {required double floorY, double sizeScale = 1}) {
    final oldW = _area.width;
    final first = !_placed;
    _area = area;
    _floorY = floorY;
    _radius = math.max(24.0, 0.15 * area.width * sizeScale);
    if (first || oldW < 1) {
      _pos = Offset(area.center.dx, _restY);
      _placed = true;
    } else if (oldW != area.width) {
      _pos = Offset(_pos.dx / oldW * area.width, _pos.dy);
    }
    _walking = false;
    _clampToArea();
  }

  bool _placed = false;

  double _clampX(double x) {
    final lo = _minX, hi = _maxX;
    if (lo > hi) return _area.center.dx;
    return x.clamp(lo, hi).toDouble();
  }

  void _clampToArea() {
    var y = _pos.dy;
    if (_mode == _Mode.rest) {
      y = _restY;
    } else {
      y = math.min(y, _restY);
      y = math.max(y, math.min(_minY, _restY));
    }
    _pos = Offset(_clampX(_pos.dx), y);
  }

  // ── events ────────────────────────────────────────────────────────────
  @override
  List<CreatureEvent> drainEvents() {
    if (_events.isEmpty) return const [];
    final out = List<CreatureEvent>.of(_events);
    _events.clear();
    return out;
  }

  void _sound(String id, [double pitch = 1, double minGap = 0]) {
    if (minGap > 0) {
      final last = _lastSound[id];
      if (last != null && time - last < minGap) return;
    }
    _lastSound[id] = time;
    _events.add(CreatureEvent(CreatureEventType.sound, id, pitch));
  }

  void _haptic(String kind) {
    _lastHaptic = time;
    _events.add(CreatureEvent(CreatureEventType.haptic, kind));
  }

  void _reaction(String id) => _events.add(CreatureEvent(CreatureEventType.reaction, id));

  void _bubble(String key) => _events.add(CreatureEvent(CreatureEventType.bubble, key));

  void _progress(String id, double v) => _events.add(CreatureEvent(CreatureEventType.progress, id, v));

  double get _pitchJitter => 0.95 + _rng.nextDouble() * 0.12;

  void _after(double seconds, void Function() fn) => _later.add(_Later(time + seconds, fn));

  // ── particles ─────────────────────────────────────────────────────────
  void _burst(OinkParticleKind kind, Offset at, {int count = 5, double speed = 60, double size = 12}) {
    final s = _s;
    for (var i = 0; i < count; i++) {
      final a = -math.pi / 2 + (_rng.nextDouble() - 0.5) * 2.2;
      final v = speed * (0.6 + _rng.nextDouble() * 0.7) * s;
      _addParticle(OinkParticle(
        kind,
        at + Offset((_rng.nextDouble() - 0.5) * 30 * s, (_rng.nextDouble() - 0.5) * 16 * s),
        Offset(math.cos(a) * v, math.sin(a) * v),
        0.9 + _rng.nextDouble() * 0.6,
        size * (0.7 + _rng.nextDouble() * 0.6) * s,
        (_rng.nextDouble() - 0.5) * 3,
      ));
    }
  }

  void _addParticle(OinkParticle p) {
    if (_particles.length >= 70) _particles.removeAt(0);
    _particles.add(p);
  }

  void _stepParticles(double dt) {
    final s = _s;
    for (final p in _particles) {
      p.life -= dt;
      p.pos += p.vel * dt;
      final g = switch (p.kind) {
        OinkParticleKind.crumb || OinkParticleKind.drop => 420.0,
        _ => -10.0,
      };
      p.vel = Offset(p.vel.dx * (1 - 1.2 * dt), p.vel.dy + g * s * dt);
      p.spin += dt;
    }
    _particles.removeWhere((p) => p.life <= 0);
  }

  // ── hit testing & zones ───────────────────────────────────────────────
  @override
  bool hitTest(Offset p) => zoneAt(p, margin: hitMargin) != null;

  /// Which zone of the pig is at room point [p], or null.
  OinkZone? zoneAt(Offset p, {double margin = 0}) {
    final q = roomToDesign(p);
    final m = margin / _s;
    bool inEllipse(Offset c, double rx, double ry) {
      final d = q - c;
      final ax = rx + m, ay = ry + m;
      return (d.dx * d.dx) / (ax * ax) + (d.dy * d.dy) / (ay * ay) <= 1;
    }

    if (inEllipse(OinkGeo.snoutC, OinkGeo.snoutRx * 1.25, OinkGeo.snoutRy * 1.4)) return OinkZone.snout;
    final r = OinkGeo.headR * 0.32 + m;
    final dl = (q - OinkGeo.earHitL).distance, dr = (q - OinkGeo.earHitR).distance;
    if (dl < r || dr < r) {
      _earSide = dl < dr ? -1 : 1;
      return OinkZone.ear;
    }
    if ((q - OinkGeo.tailHit).distance < 26 + m) return OinkZone.tail;
    if (inEllipse(OinkGeo.headC, OinkGeo.headR * 1.06, OinkGeo.headR * 0.98)) return OinkZone.head;
    if (inEllipse(OinkGeo.bodyC, OinkGeo.bodyRx * 1.05, OinkGeo.bodyRy * 1.1)) return OinkZone.belly;
    return null;
  }

  // ── input ─────────────────────────────────────────────────────────────
  @override
  bool pointerDown(int pointer, Offset p) {
    if (_pointer != null) return false;
    final z = zoneAt(p, margin: hitMargin);
    if (z == null) return false;
    _pointer = pointer;
    _downPos = _lastPos = p;
    _finger = p;
    _downTime = time;
    _downZone = z;
    _downEarSide = _earSide;
    _stroking = false;
    _hold = 0;
    _rubDir = 0;
    _rubTravel = 0;
    _dragSamples.clear();
    _idle = 0;
    return true;
  }

  @override
  void pointerMove(int pointer, Offset p) {
    if (pointer != _pointer) return;
    _finger = p;
    _idle = 0;
    final moved = (p - _downPos).distance;
    if (_mode == _Mode.held) {
      _dragSamples.add((time, p));
      while (_dragSamples.length > 6) {
        _dragSamples.removeAt(0);
      }
      _pos = Offset(_clampX(p.dx + _grabOffset.dx), math.min(p.dy + _grabOffset.dy, _restY));
      _pos = Offset(_pos.dx, math.max(_pos.dy, math.min(_minY, _restY)));
    } else if (_hold > 0 && moved > pickupSlop && !pinned && _mode == _Mode.rest && !_sleeping) {
      _pickUp(p);
    } else if (_hold == 0 && !_stroking && moved > strokeSlop) {
      _stroking = true;
    }
    if (_stroking && _mode == _Mode.rest) _stroke(_lastPos, p);
    _lastPos = p;
  }

  @override
  void pointerUp(int pointer, Offset p) {
    if (pointer != _pointer) return;
    _pointer = null;
    _finger = null;
    final dur = time - _downTime;
    if (_mode == _Mode.held) {
      _throw();
    } else if (_stroking) {
      _rubDir = 0;
      _rubTravel = 0;
    } else if (_hold > 0) {
      _sqVel -= 5;
      _sound('oink.pop', 0.95);
      _playAction(_Action.happy);
    } else if (dur <= tapMaxDuration && (p - _downPos).distance <= tapSlop) {
      _tap(_downZone ?? zoneAt(p, margin: hitMargin));
    }
    _hold = 0;
    _stroking = false;
  }

  @override
  void pointerCancel(int pointer) {
    if (pointer != _pointer) return;
    _pointer = null;
    _finger = null;
    if (_mode == _Mode.held) {
      _mode = _Mode.air;
      _vel = Offset.zero;
    }
    _hold = 0;
    _stroking = false;
  }

  // ── the touch zones ───────────────────────────────────────────────────
  void _tap(OinkZone? z) {
    if (z == null) return;
    _idle = 0;
    if (_sleeping) {
      _poke();
      return;
    }
    _sqVel += 9;
    _events.add(const CreatureEvent(CreatureEventType.coach, 'pet'));
    _tapTimes.add(time);
    _tapTimes.removeWhere((t) => time - t > tickleWindow);
    if (_tapTimes.length >= tickleTaps) {
      _tapTimes.clear();
      _playAction(_Action.giggle);
      _burst(OinkParticleKind.heart, designToRoom(OinkGeo.bodyC + const Offset(0, -OinkGeo.bodyRy * 0.2)), count: 4, size: 10);
      _giggleSound();
      _haptic('medium');
      _reaction('oink.tickle');
      _progress('combo', 1);
      return;
    }
    switch (z) {
      case OinkZone.snout:
        _playAction(_Action.oink);
        _oinkSound(_pitchJitter);
        _haptic('light');
        _bubble('bubble.oink');
        _reaction('oink.snout');
        _progress('bond', 0.5);
      case OinkZone.head:
        _playAction(_Action.happy);
        if (_rng.nextDouble() < 0.3) {
          _sound('oink.squeal', _pitchJitter);
        } else {
          _sound(_rng.nextBool() ? 'oink.snort1' : 'oink.snort2', _pitchJitter);
        }
        _haptic('light');
        _reaction('oink.head');
        _progress('bond', 1);
      case OinkZone.belly:
        _playAction(_Action.giggle);
        _giggleSound();
        _haptic('medium');
        _reaction('oink.belly');
        _progress('bond', 1);
      case OinkZone.ear:
        _playAction(_Action.earFlop, side: _downEarSide);
        _sound(_rng.nextBool() ? 'oink.snort1' : 'oink.snort2', _pitchJitter);
        _haptic('light');
        _reaction('oink.ear');
        _progress('bond', 0.5);
      case OinkZone.tail:
        _playAction(_Action.tailSpin);
        _oinkSound(1.15);
        _haptic('light');
        _bubble('bubble.oinkq');
        _reaction('oink.tail');
        _progress('bond', 0.5);
    }
  }

  void _oinkSound(double pitch) {
    var i = _rng.nextInt(6);
    if (i == _lastOink) i = (i + 1) % 6;
    _lastOink = i;
    _sound('oink.oink${i + 1}', pitch);
  }

  void _giggleSound({double minGap = 0, double pitch = 0}) {
    var i = _rng.nextInt(2);
    if (i == _lastGiggle) i = 1 - i;
    _lastGiggle = i;
    _sound('oink.giggle${i + 1}', pitch == 0 ? _pitchJitter : pitch, minGap);
  }

  /// A poke on a sleeping pig: grumble, stay asleep; the third poke in a row wakes it.
  void _poke() {
    _pokeWindow = 2.5;
    _pokes++;
    _playAction(_Action.grumble);
    _sound('oink.grumble', 0.9, 0.3);
    _haptic('light');
    _reaction('oink.grumble');
    if (_pokes >= pokesToWake) {
      _pokes = 0;
      wake();
    }
  }

  void _stroke(Offset a, Offset b) {
    final delta = (b - a) / _s;
    if (delta.distance < 0.3) return;
    final z = zoneAt(b, margin: 4);
    if (z != OinkZone.belly && z != OinkZone.head) return;
    if (_sleeping) return;
    _rubTravel += delta.dx.abs();
    final dir = delta.dx.abs() < 0.3 ? 0 : (delta.dx > 0 ? 1 : -1);
    if (dir != 0 && dir != _rubDir) {
      if (_rubDir != 0 && _rubTravel > rubStroke) {
        _rubTravel = 0;
        _rub(z!);
      }
      _rubDir = dir;
    }
  }

  void _rub(OinkZone z) {
    _idle = 0;
    if (time - _lastHaptic > 0.2) _haptic('selection');
    if (z == OinkZone.belly) {
      _playAction(_Action.giggle);
      if (time - _lastRub > 0.6) {
        _burst(OinkParticleKind.heart, designToRoom(OinkGeo.bodyC + const Offset(0, -OinkGeo.bodyRy * 0.2)), count: 2, size: 10);
        _reaction('oink.rub');
        _progress('bond', 0.5);
        _lastRub = time;
      }
      if (time - _lastRubSound > 0.9) {
        _lastRubSound = time;
        _giggleSound(pitch: _pitchJitter);
      }
    } else {
      _playAction(_Action.happy);
      if (time - _lastRub > 0.6) {
        _reaction('oink.pat');
        _progress('bond', 0.5);
        _lastRub = time;
      }
      if (time - _lastHeadRubSound > 1.4) {
        _lastHeadRubSound = time;
        _sound('oink.squeal', _pitchJitter);
      }
    }
    _events.add(const CreatureEvent(CreatureEventType.coach, 'pet'));
  }

  void _pickUp(Offset p) {
    _mode = _Mode.held;
    _grabOffset = _pos - p;
    _vel = Offset.zero;
    _dragSamples
      ..clear()
      ..add((time, p));
    _thrown = false;
    _sound('oink.oink${1 + _rng.nextInt(6)}', 1.2);
    _haptic('medium');
    _reaction('oink.pickup');
    _playAction(_Action.surprised);
  }

  void _throw() {
    var v = Offset.zero;
    if (_dragSamples.length >= 2) {
      final a = _dragSamples.first, b = _dragSamples.last;
      final dt = b.$1 - a.$1;
      if (dt > 0.001) v = (b.$2 - a.$2) / dt;
    }
    final len = v.distance;
    if (len > 1800) v = v / len * 1800;
    _vel = v;
    _thrown = v.distance > 500;
    _mode = _Mode.air;
    _dragSamples.clear();
  }

  // ── care tools ────────────────────────────────────────────────────────
  @override
  void groom(Offset p, double speed, {required String tool}) {
    if (!bounds.inflate(_radius * 0.3).contains(p)) return;
    if (_sleeping) wake();
    _idle = 0;
    final fresh = _groomT <= 0 || tool != _groomTool;
    _groomT = 0.3;
    _groomTool = tool;
    _groomSpeed = speed.isFinite ? speed : 0;
    if (fresh) {
      _haptic('selection');
      final id = switch (tool) {
        'towel' => 'oink.towel',
        'dryer' => 'oink.dryer',
        _ => 'oink.groom',
      };
      _reaction(id);
      _progress('bond', 1);
      if (tool == 'dryer') {
        _sound('oink.snort1', 1.1);
      } else {
        _giggleSound(pitch: tool == 'towel' ? 1.05 : _pitchJitter);
      }
      _groomGiggle = 1.1;
    }
  }

  // ── life ──────────────────────────────────────────────────────────────
  @override
  void sleep() {
    if (_sleeping) return;
    _sleeping = true;
    _sleptFor = 0;
    _snoring = false;
    _walking = false;
    _eatT = 0;
    _pokes = 0;
    _sound('oink.yawn', 0.95);
    _playAction(_Action.yawn);
    _reaction('oink.sleep');
    _after(1.1, () {
      if (_sleeping && !_snoring) {
        _snoring = true;
        _events.add(const CreatureEvent(CreatureEventType.loopStart, 'oink.snore', 0.4));
      }
    });
  }

  @override
  void wake() {
    if (!_sleeping) return;
    _sleeping = false;
    _autoSlept = false;
    _idle = 0;
    if (_snoring) {
      _snoring = false;
      _events.add(const CreatureEvent(CreatureEventType.loopStop, 'oink.snore'));
    }
    _sound('oink.wake', _pitchJitter);
    _playAction(_Action.happy);
    _reaction('oink.wake');
    _haptic('light');
    _nextBlink = 0.6;
  }

  // ── the rest of the world ─────────────────────────────────────────────
  @override
  void lookAt(Offset? target) => _lookTarget = target;

  @override
  void nudge(Offset impulse) {
    if (!impulse.dx.isFinite || !impulse.dy.isFinite) return;
    if (_mode == _Mode.held) return;
    _vel += impulse;
    const lim = 2400.0;
    if (_vel.dx.abs() > lim) _vel = Offset(lim * _vel.dx.sign, _vel.dy);
    if (_mode == _Mode.rest) {
      if (_vel.dy < -200) {
        _mode = _Mode.air;
        _vel = Offset(_vel.dx, math.max(_vel.dy, -1500.0));
      } else {
        _vel = Offset(_vel.dx, 0);
      }
    }
  }

  /// A shaken phone startles Oink into a surprised little hop.
  @override
  void shake() {
    if (_sleeping) wake();
    react(SocialCue.landedOnMe);
  }

  @override
  void react(SocialCue cue, {Offset? from}) {
    if (_sleeping) return;
    switch (cue) {
      case SocialCue.friendTouched:
        if (from != null) {
          _cueLook = from;
          _cueLookT = 1.6;
        }
        if (time - _lastPeek > 8) {
          _lastPeek = time;
          _playAction(_Action.peek);
          if (_rng.nextDouble() < 0.5) _sound('oink.snort1', 1.2);
          _reaction('oink.peek');
        }
      case SocialCue.landedOnMe:
        _sqVel += 7;
        _playAction(_Action.surprised);
        _sound('oink.whimper', 1.1);
        _haptic('light');
        _reaction('oink.bumped');
        if (!reduceMotion) _startHop(180);
      case SocialCue.nuzzled:
        _playAction(_Action.happy);
        _burst(OinkParticleKind.heart, designToRoom(OinkGeo.headC + const Offset(0, -OinkGeo.headR * 0.9)), count: 4);
        _giggleSound();
        _haptic('light');
        _reaction('oink.nuzzle');
        _progress('bond', 1);
      case SocialCue.celebrate:
        celebrate();
    }
  }

  double _lastPeek = -20;

  @override
  void celebrate() {
    if (_sleeping) return;
    _playAction(_Action.cheer);
    _sound('oink.levelup', 1);
    _haptic('success');
    _reaction('oink.cheer');
    if (!reduceMotion) _startHop(300);
  }

  // ── feeding ───────────────────────────────────────────────────────────
  Offset get hoverTarget => _hoverAt ?? mouth;

  @override
  void setSnackHover(bool hovering, [Offset? at]) {
    _hover = hovering && !_sleeping;
    _hoverAt = hovering ? at : null;
  }

  @override
  void eat({required bool favorite}) {
    if (_sleeping) wake();
    _idle = 0;
    _eatT = 1.4;
    _playAction(_Action.munch);
    _sound('oink.munch${1 + _rng.nextInt(3)}', _pitchJitter);
    _haptic('light');
    _reaction(favorite ? 'oink.favorite' : 'oink.munch');
    _progress('bond', favorite ? 3 : 2);
    _after(0.5, () => _sound('oink.munch${1 + _rng.nextInt(3)}', _pitchJitter));
    _after(1.0, () {
      _sound('oink.gulp');
      _playAction(_Action.happy);
      if (favorite) {
        _burst(OinkParticleKind.heart, designToRoom(OinkGeo.headC + const Offset(0, -OinkGeo.headR * 0.9)), count: 4);
        _haptic('success');
        if (!reduceMotion) _startHop(220);
      }
    });
  }

  @override
  void refuseFull() {
    if (_sleeping) return;
    _idle = 0;
    _playAction(_Action.refuse);
    _sound('oink.grumble', 0.95);
    _haptic('medium');
    _bubble('bubble.full');
    _reaction('oink.full');
  }

  // ── actions (one-shot expressions) ────────────────────────────────────
  void _playAction(_Action a, {int side = -1}) {
    _action = a;
    _actionT = 0;
    _actionDur = _actionDuration[a]!;
    _actionSide = side;
    _idle = 0;
    switch (a) {
      case _Action.happy:
        _burst(OinkParticleKind.heart, designToRoom(OinkGeo.headC + const Offset(0, -OinkGeo.headR * 0.9)), count: 4);
      case _Action.giggle:
        _burst(OinkParticleKind.heart, designToRoom(OinkGeo.bodyC + const Offset(0, -OinkGeo.bodyRy * 0.2)), count: 3, size: 10);
      case _Action.munch:
        _burst(OinkParticleKind.crumb, designToRoom(OinkGeo.mouthC), count: 7, speed: 70, size: 10);
      case _Action.sparkle:
        _burst(OinkParticleKind.sparkle, designToRoom(OinkGeo.headC), count: 9, speed: 110, size: 13);
      case _Action.cheer:
        final top = designToRoom(OinkGeo.headC + const Offset(0, -OinkGeo.headR));
        _burst(OinkParticleKind.sparkle, top, count: 12, speed: 130, size: 14);
        _burst(OinkParticleKind.heart, top, count: 5, speed: 90);
      default:
        break;
    }
  }

  void _startHop(double v) {
    if (_mode != _Mode.rest || pinned) return;
    _hopV = -v;
    _hopY = -0.01;
  }

  // ── update ────────────────────────────────────────────────────────────
  @override
  void update(double dt) {
    if (!dt.isFinite || dt <= 0) return;
    final total = dt > 0.1 ? 0.1 : dt;
    var left = total;
    while (left > 1e-6) {
      final h = math.min(left, 1 / 90);
      _step(h);
      left -= h;
    }
    _stepParticles(total);
  }

  void _step(double h) {
    time += h;

    for (var i = _later.length - 1; i >= 0; i--) {
      if (time >= _later[i].at) {
        final f = _later.removeAt(i);
        f.fn();
      }
    }
    if (_pokeWindow > 0) {
      _pokeWindow -= h;
      if (_pokeWindow <= 0) _pokes = 0;
    }
    if (_eatT > 0) _eatT -= h;
    if (_groomT > 0) {
      _groomT -= h;
      _groomTotal += h;
    } else if (_groomTotal > 0) {
      // A scrub or a blow-dry just ended: a little post-spa sparkle.
      if (_groomTotal > 2.5 && !_sleeping) {
        _playAction(_Action.sparkle);
        _sound('oink.sparkle');
      }
      _groomTotal = 0;
    }
    if (_cueLookT > 0) _cueLookT -= h;
    if (_sleeping) _sleptFor += h;

    // press / hold bookkeeping
    if (_pointer != null && _mode == _Mode.rest && !_stroking && _hold == 0 && time - _downTime > holdDelay && !_sleeping) {
      _hold = 1;
      _sound('oink.tap', 0.8);
      _haptic('medium');
      _reaction('oink.squish');
    }
    _sqTarget = (_pointer != null && _mode == _Mode.rest) ? (_hold > 0 ? 0.7 : (_sleeping ? 0.15 : 0.32)) : 0;

    _stepBody(h);
    _stepSprings(h);
    _stepLife(h);
    _compose(h);
  }

  void _stepBody(double h) {
    switch (_mode) {
      case _Mode.rest:
        _pos = Offset(_pos.dx, _restY);
        var vx = _vel.dx;
        if (vx.abs() > 1) {
          var nx = _pos.dx + vx * h;
          if (nx < _minX || nx > _maxX) {
            nx = _clampX(nx);
            vx = 0;
          }
          _pos = Offset(nx, _pos.dy);
          vx *= math.exp(-5 * h);
        } else {
          vx = 0;
        }
        _vel = Offset(vx, 0);
        if (_walking) {
          final dx = _walkTarget - _pos.dx;
          final step = 56 * _s * h;
          if (dx.abs() <= step) {
            _pos = Offset(_walkTarget, _pos.dy);
            _walking = false;
          } else {
            _pos = Offset(_pos.dx + dx.sign * step, _pos.dy);
          }
        }
      case _Mode.held:
        break;
      case _Mode.air:
        _vel = Offset(_vel.dx, _vel.dy + gravity * h);
        var nx = _pos.dx + _vel.dx * h;
        var ny = _pos.dy + _vel.dy * h;
        var vx = _vel.dx, vy = _vel.dy;
        if (nx < _minX) {
          nx = _clampX(nx);
          vx = vx.abs() * 0.5;
        } else if (nx > _maxX) {
          nx = _clampX(nx);
          vx = -vx.abs() * 0.5;
        }
        final top = math.min(_minY, _restY);
        if (ny < top) {
          ny = top;
          vy = vy.abs() * 0.3;
        }
        if (ny >= _restY) {
          ny = _restY;
          _land(vy);
          vy = _mode == _Mode.air ? -vy * 0.3 : 0;
          vx *= 0.6;
        }
        _pos = Offset(nx, ny);
        _vel = Offset(vx, vy);
    }
  }

  void _land(double vy) {
    if (vy > 280) {
      _sqVel += 4 + vy * 0.004;
      _sound('oink.pop', 0.9, 0.12);
      _haptic('light');
      if (_thrown && vy > 500) {
        _reaction('oink.landing');
        _playAction(_Action.surprised);
        _thrown = false;
      }
    }
    if (vy > 400) {
      _mode = _Mode.air; // one small bounce
    } else {
      _mode = _Mode.rest;
      _thrown = false;
    }
  }

  void _stepSprings(double h) {
    // squash spring
    const k = 300.0, c = 18.0;
    _sqVel += (-k * (_sq - _sqTarget) - c * _sqVel) * h;
    _sq += _sqVel * h;
    _sq = _sq.clamp(-0.7, 1.0).toDouble();

    // hop
    if (_hopV != 0 || _hopY < 0) {
      _hopV += 1500 * h;
      _hopY += _hopV * h;
      if (_hopY >= 0) {
        _hopY = 0;
        if (_hopV > 100) _sqVel += _hopV * 0.012;
        _hopV = 0;
      }
    }

    // lean follows sliding speed
    final leanTarget = (_vel.dx / 1500).clamp(-0.16, 0.16).toDouble();
    _lean += (leanTarget - _lean) * math.min(1.0, h * 10);
  }

  void _stepLife(double h) {
    final restingFree = _mode == _Mode.rest && _pointer == null && !_sleeping && !pinned && _groomT <= 0 && _eatT <= 0;

    // idle clock → auto sleep
    if (_pointer == null && _action == null && _groomT <= 0 && !_sleeping && !pinned && _mode == _Mode.rest) {
      _idle += h;
      final limit = night ? 14.0 : 75.0;
      if (_idle > limit) {
        sleep();
        _autoSlept = true;
      }
    }
    if (_sleeping && _autoSlept && !night && _sleptFor > 40) wake();

    // wander
    if (restingFree && !reduceMotion && _action == null) {
      _wanderIn -= h;
      if (!_walking && _wanderIn <= 0) {
        _wanderIn = 5 + _rng.nextDouble() * 9;
        final lo = _minX, hi = _maxX;
        if (hi > lo) {
          final target = lo + _rng.nextDouble() * (hi - lo);
          if ((target - _pos.dx).abs() > 40 * _s) {
            _walking = true;
            _walkTarget = target;
          }
        }
      }
      _hopIn -= h;
      if (_hopIn <= 0) {
        _hopIn = 9 + _rng.nextDouble() * 10;
        if (!_walking) {
          _startHop(250);
          _reaction('oink.hop');
        }
      }
    } else if (!restingFree) {
      _walking = false;
    }
    final walkGoal = _walking ? 1.0 : 0.0;
    _walkAmp += (walkGoal - _walkAmp) * math.min(1.0, h * 8);
    _walkPhase += h * 10 * _walkAmp;

    // Zzz
    if (_sleeping) {
      _zzzT -= h;
      if (_zzzT <= 0) {
        _zzzT = 1.1;
        _addParticle(OinkParticle(
          OinkParticleKind.zzz,
          _headToRoom(OinkGeo.headC + const Offset(OinkGeo.headR * 0.7, -OinkGeo.headR * 0.6)),
          Offset((18 + _rng.nextDouble() * 10) * _s, -38 * _s),
          2.4,
          (9 + _rng.nextDouble() * 5) * _s,
          0,
        ));
      }
    }
  }

  // ── pose composition ──────────────────────────────────────────────────
  void _compose(double h) {
    final p = pose;
    final sleeping = _sleeping;
    final motion = reduceMotion ? 0.35 : 1.0;

    var eyes = sleeping ? OinkEyes.closed : OinkEyes.open;
    var mouth = OinkMouth.smile;
    var mouthOpen = 0.0;
    var snout = 0.0;
    var bounce = 0.0;
    var legKick = 0.0;
    var shake = 0.0;
    var tilt = math.sin(time * 0.7) * 0.03;
    var earL = 0.05 * math.sin(time * 1.3);
    var earR = 0.05 * math.sin(time * 1.3 + 1.2);
    var tail = 0.25 * math.sin(time * (sleeping ? 1.2 : 3.2));
    var blush = sleeping ? 0.3 : 0.45;

    // breathing
    final period = sleeping ? 4.6 : 3.0;
    _breathPhase += h / period;
    final breath = 0.5 - 0.5 * math.cos(2 * math.pi * _breathPhase);

    // blinks
    if (!sleeping) {
      _nextBlink -= h;
      if (_nextBlink <= 0 && _blinkT < 0) {
        _blinkT = 0;
        _nextBlink = 2.2 + _rng.nextDouble() * 3.5;
      }
    }
    var blink = 0.0;
    if (_blinkT >= 0) {
      _blinkT += h;
      const bd = 0.16;
      blink = _blinkT < bd ? math.sin(math.pi * _blinkT / bd) : 0;
      if (_blinkT >= bd) _blinkT = -1;
    }

    // ear twitch
    if (!sleeping) {
      _nextTwitch -= h;
      if (_nextTwitch <= 0 && _twitchT < 0) {
        _twitchT = 0;
        _twitchLeft = _rng.nextBool();
        _nextTwitch = 3 + _rng.nextDouble() * 5;
      }
    }
    if (_twitchT >= 0) {
      _twitchT += h;
      final k = math.sin(math.pi * (_twitchT / 0.3).clamp(0.0, 1.0)) * 0.3;
      if (_twitchLeft) {
        earL += k;
      } else {
        earR += k;
      }
      if (_twitchT >= 0.3) _twitchT = -1;
    }

    // anticipation while a snack hovers
    _anticipation += ((_hover ? 1.0 : 0.0) - _anticipation) * (h * 10).clamp(0.0, 1.0);
    if (_anticipation > 0.05 && !sleeping) {
      mouth = OinkMouth.open;
      mouthOpen = _anticipation;
      eyes = OinkEyes.surprised;
      blush = 0.7;
    }

    // the active action
    final a = _action;
    if (a != null) {
      _actionT += h;
      final k = (_actionT / _actionDur).clamp(0.0, 1.0);
      final env = math.sin(math.pi * k);
      switch (a) {
        case _Action.oink:
          mouth = OinkMouth.oink;
          mouthOpen = env;
          snout = env;
          eyes = OinkEyes.squint;
          bounce = -10 * env;
          earL -= 0.2 * env;
          earR -= 0.2 * env;
        case _Action.happy:
          eyes = OinkEyes.happy;
          blush = 0.95;
          bounce = -8 * math.sin(math.pi * k * 2).abs();
          earL -= 0.25 * env;
          earR -= 0.25 * env;
          tail += 0.6 * math.sin(time * 18);
        case _Action.giggle:
          eyes = OinkEyes.squint;
          mouth = OinkMouth.open;
          mouthOpen = 0.5 + 0.5 * math.sin(time * 28).abs();
          legKick = math.sin(time * 22).abs() * env;
          bounce = -4 * math.sin(time * 24).abs();
          blush = 1;
          tail += 0.8 * math.sin(time * 20);
        case _Action.earFlop:
          final flop = 0.9 * env;
          if (_actionSide < 0) {
            earL += flop;
          } else {
            earR += flop;
          }
          eyes = OinkEyes.surprised;
        case _Action.tailSpin:
          tail += 2 * math.pi * k * 2;
          eyes = OinkEyes.surprised;
          mouth = OinkMouth.oink;
          mouthOpen = env * 0.6;
          bounce = -6 * env;
        case _Action.munch:
          mouth = OinkMouth.munch;
          mouthOpen = 0.5 + 0.5 * math.sin(time * 22);
          eyes = k > 0.6 ? OinkEyes.happy : OinkEyes.squint;
          blush = 0.8;
        case _Action.refuse:
          shake = 0.16 * math.sin(k * math.pi * 6) * (1 - k);
          mouth = OinkMouth.frown;
          eyes = OinkEyes.squint;
        case _Action.sparkle:
          eyes = OinkEyes.happy;
          blush = 0.9;
          bounce = -12 * env;
        case _Action.surprised:
          eyes = OinkEyes.surprised;
          mouth = OinkMouth.open;
          mouthOpen = env * 0.6;
        case _Action.grumble:
          shake = 0.05 * math.sin(k * math.pi * 4);
          blush = 0.5;
          mouth = OinkMouth.frown;
        case _Action.cheer:
          eyes = OinkEyes.happy;
          blush = 1;
          bounce = -26 * math.sin(math.pi * (k * 2).clamp(0.0, 1.0));
          earL -= 0.3 * env;
          earR -= 0.3 * env;
          tail += 0.7 * math.sin(time * 16);
        case _Action.yawn:
          mouth = OinkMouth.open;
          mouthOpen = env;
          eyes = OinkEyes.closed;
          tilt += 0.08 * env;
        case _Action.peek:
          earL -= 0.3 * env;
          earR -= 0.3 * env;
          eyes = OinkEyes.surprised;
          tilt += 0.1 * env * (_actionSide < 0 ? 1 : -1);
      }
      if (_actionT >= _actionDur) _action = null;
    }

    // grooming overlay
    if (_groomT > 0) {
      final amp = (_groomSpeed / 400).clamp(0.35, 1.0);
      _groomGiggle -= h;
      switch (_groomTool) {
        case 'dryer':
          final f = math.sin(time * 34);
          earL += 0.45 + 0.35 * f;
          earR += 0.45 - 0.35 * f;
          eyes = OinkEyes.squint;
          mouth = OinkMouth.open;
          mouthOpen = 0.25 + 0.2 * f.abs();
          tilt += 0.04 * math.sin(time * 9);
          tail += 0.5 * math.sin(time * 26);
          if (_groomGiggle <= 0) {
            _groomGiggle = 1.6;
            _giggleSound(pitch: 1.1);
          }
        case 'towel':
          eyes = OinkEyes.happy;
          tilt += 0.07 * amp * math.sin(time * 12);
          bounce -= 2.5 * amp * math.sin(time * 16).abs();
          tail += 0.6 * math.sin(time * 14);
          blush = 0.8;
          if (_groomGiggle <= 0) {
            _groomGiggle = 1.5;
            _giggleSound(pitch: 1.05);
          }
        default: // foam and anything else
          eyes = OinkEyes.squint;
          mouth = OinkMouth.open;
          mouthOpen = 0.4 + 0.3 * math.sin(time * 20).abs();
          legKick = math.max(legKick, 0.6 * amp * math.sin(time * 18).abs());
          tilt += 0.06 * amp * math.sin(time * 14);
          bounce -= 3 * amp * math.sin(time * 22).abs();
          tail += 0.7 * math.sin(time * 18);
          blush = 0.9;
          if (_groomSpeed > 120) {
            _groomScrub -= h;
            if (_groomScrub <= 0) {
              _groomScrub = 0.5;
              _sound('oink.scrub', _pitchJitter);
            }
          }
          if (_groomGiggle <= 0) {
            _groomGiggle = 1.2;
            _giggleSound();
          }
      }
    }

    // being held
    if (_mode == _Mode.held) {
      eyes = OinkEyes.surprised;
      mouth = OinkMouth.oink;
      mouthOpen = 0.4;
      legKick = 0.5 + 0.5 * math.sin(time * 14).abs();
      tail += 0.6 * math.sin(time * 14);
      tilt += 0.1 * math.sin(time * 9);
    } else if (_mode == _Mode.air && _action == null) {
      eyes = OinkEyes.surprised;
      legKick = 0.6;
    } else if (_hold > 0 && _action == null) {
      eyes = OinkEyes.squint;
      mouth = OinkMouth.oink;
      mouthOpen = 0.3;
      snout = 0.5;
    }

    // walking waddle
    final waddle = _walkAmp * 0.07 * math.sin(_walkPhase);
    bounce -= _walkAmp * 3 * math.sin(_walkPhase * 2).abs();
    legKick = math.max(legKick, _walkAmp * 0.35 * math.sin(_walkPhase).abs());

    // eyes follow a finger, a friend, a toy or drift
    Offset? target = _finger ?? (_hover ? hoverTarget : null) ?? (_cueLookT > 0 ? _cueLook : null) ?? _lookTarget;
    Offset want;
    if (target == null || sleeping) {
      want = sleeping ? Offset.zero : Offset(0.35 * math.sin(time * 0.4), 0.2 * math.sin(time * 0.53));
    } else {
      final d = target - _headCenterRoom;
      final len = d.distance;
      want = len < 1 ? Offset.zero : d / len * (len / (120 * _s)).clamp(0.0, 1.0);
    }
    _look = Offset.lerp(_look, want, (h * 8).clamp(0.0, 1.0))!;

    p
      ..breath = breath
      ..blink = blink
      ..eyes = eyes
      ..mouth = mouth
      ..mouthOpen = mouthOpen
      ..snoutSquish = snout
      ..bounce = bounce * motion + _hopY * motion
      ..legKick = legKick * motion
      ..shake = shake * motion
      ..headTilt = tilt
      ..earLeft = earL
      ..earRight = earR
      ..tail = tail
      ..blush = blush
      ..look = _look
      ..lean = _lean + waddle
      ..squash = _sq - 0.035 * breath;
  }

  // ── accessories ───────────────────────────────────────────────────────
  @override
  Anchor anchor(AccessorySlot slot) {
    final sc = OinkGeo.headR * _s / 92;
    switch (slot) {
      case AccessorySlot.head:
        return Anchor(_headToRoom(OinkGeo.crown), sc, headAngle + pose.lean);
      case AccessorySlot.face:
        return Anchor(_headToRoom(OinkGeo.headC + const Offset(0, OinkGeo.headR * 0.02)), sc, headAngle + pose.lean);
      case AccessorySlot.neck:
        return Anchor(_headToRoom(OinkGeo.neck), sc * 0.9, pose.lean);
    }
  }
}
