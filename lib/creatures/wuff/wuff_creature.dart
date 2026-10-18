/// Wuff, the puppy: gestures, springs (ears, tail, head), poses, tricks, barks,
/// expressions and particles, as a [Creature] of the house.
///
/// Pure Dart: only `dart:math`, `dart:typed_data` and `dart:ui` value types
/// (Offset, Rect, Path). Seeded randomness and an explicit `update(dt)`, so
/// every behaviour is unit-testable without a device or a frame scheduler.
///
/// Coordinates. Everything the [Creature] interface exposes (position, mouth,
/// silhouette, bounds, anchors, particles, pointer input) is in *room*
/// coordinates. The puppy is built in an unposed *local* frame (the one the
/// prototype used: floor at [floorY], head radius [radius]); [toRoom] /
/// [fromRoom] / [poseMatrix] map between the two so the whole-body squash,
/// spin and play-dead roll are honoured by hit-tests, the silhouette and the
/// painter alike. [WuffArt] paints in the local frame under `poseMatrix`.
library;

import 'dart:math' as math;
import 'dart:typed_data' show Float64List;
import 'dart:ui' show Offset, Path, Rect;

import '../creature.dart';
import 'wuff_catalog.dart';

enum WuffExpr {
  idle,
  happy,
  bliss,
  excited,
  winkL,
  winkR,
  sniff,
  sneeze,
  love,
  dizzy,
  confused,
  puppyEyes,
  howl,
  sleepy,
  asleep,
  eating,
  nope,
  proud,
  playDead,
  speak,
  growl,
  startled,
}

enum WuffParticleKind { heart, sparkle, star, zzz, crumb, question, note, drop }

/// What a pointer went down on.
enum WuffRegion { none, nose, eyeL, eyeR, earL, earR, chin, head, body }

/// One short-lived effect (room coordinates), painted by [WuffArt].
class WuffParticle {
  WuffParticle(this.kind, this.pos, this.vel, this.life, this.size, this.spin);
  final WuffParticleKind kind;
  Offset pos;
  Offset vel;
  final double life;
  final double size;
  final double spin;
  double age = 0;
  double get t => (age / life).clamp(0.0, 1.0);
}

/// A critically-ish damped spring on one number.
class WuffSpring {
  WuffSpring(this.stiffness, this.damping);
  final double stiffness;
  final double damping;
  double value = 0;
  double vel = 0;
  double target = 0;

  void step(double dt) {
    vel += (-stiffness * (value - target) - damping * vel) * dt;
    value += vel * dt;
  }
}

class WuffCreature extends Creature {
  WuffCreature({required super.friendId, required super.seed}) {
    _nextBlink = 2 + _rng.nextDouble() * 3;
    _nextGlance = 3 + _rng.nextDouble() * 4;
    _nextIdleAct = 6 + _rng.nextDouble() * 8;
  }

  late final math.Random _rng = math.Random(seed);

  // ── tunables (seconds, logical pixels) ────────────────────────────────
  static const holdDelay = 0.5;
  static const loveDelay = 1.8;
  static const tapMaxDuration = 0.32;
  static const tapSlop = 10.0;
  static const strokeSlop = 9.0;
  static const zoomieTaps = 5;
  static const zoomieWindow = 1.5;
  static const noseTapWindow = 2.0;
  static const eyeDoubleTapWindow = 0.42;
  static const idleSleepAfter = 45.0;
  static const nightSleepAfter = 12.0;
  static const gravity = 2400.0;

  /// Width of the puppy as a fraction of the room: radius = this × width.
  static const radiusFraction = 0.15;

  /// Height of the visual centre ([position]) above the floor, in radii.
  static const _centre = 1.2;

  /// Sound takes picked at random so a spammed bark never sounds like a loop.
  static const _takes = <String, List<String>>{
    'bark': ['bark', 'bark2', 'bark3'],
    'yip': ['yip', 'yip2'],
  };

  // ── world ─────────────────────────────────────────────────────────────
  Rect _area = const Rect.fromLTWH(0, 0, 390, 800);
  double floorY = 620;
  double cx = 195;
  double _radius = 58.5;
  double sizeScale = 1;
  bool _placed = false;
  double time = 0;

  // ── body state ────────────────────────────────────────────────────────
  double jump = 0; // px above the floor
  double _jumpV = 0;
  double _vx = 0;
  final WuffSpring squash = WuffSpring(160, 14); // + flattened
  final WuffSpring tilt = WuffSpring(70, 9); // head tilt, radians
  final WuffSpring lean = WuffSpring(60, 10); // head lean, px
  final WuffSpring earL = WuffSpring(55, 5); // ear swing, radians
  final WuffSpring earR = WuffSpring(55, 5);
  final WuffSpring pawR = WuffSpring(90, 12); // right paw lift 0..1
  final WuffSpring pawL = WuffSpring(90, 12);
  double spin = 0; // 0..2π while spinning (scaleX = cos)
  double _spinV = 0;
  double roll = 0; // 0 sitting … 1 lying on its side (play dead)
  double _rollTarget = 0;
  double tailPhase = 0;
  double tailSpeed = 5;
  double _tailTarget = 5;
  double thump = 0; // back-leg thump oscillation 0..1
  double _shake = 0; // 0..1 shake-off amplitude
  double _flutter = 0; // 0..1 dryer ear flutter

  // ── face ──────────────────────────────────────────────────────────────
  WuffExpr expr = WuffExpr.idle;
  double _exprTimer = 0;
  double lookX = 0, lookY = 0;
  double _lookTX = 0, _lookTY = 0;
  Offset? _lookTarget;
  double blink = 0;
  double _blinkT = -1;
  double _nextBlink = 3;
  double _nextGlance = 4;
  double _nextIdleAct = 9;
  double mouthOpen = 0;
  double _mouthTarget = 0;
  double tongue = 0; // panting tongue 0..1
  double _tongueTarget = 0;
  double blep = 0; // tongue tip out
  double _blepTarget = 0;
  double noseWiggle = 0;
  double blush = 0;
  bool treatHover = false;
  bool _asleep = false;
  double idleTime = 0;
  double _pantTimer = 0;

  /// Speech bubble: which line to show (`bark`, a pad id, `achoo`) and for how long.
  String bubble = '';
  double bubbleTimer = 0;

  // ── particles & events ────────────────────────────────────────────────
  final List<WuffParticle> particles = [];
  final List<CreatureEvent> _events = [];

  // ── gesture state ─────────────────────────────────────────────────────
  int? _pointer;
  Offset _downPos = Offset.zero;
  Offset _lastPos = Offset.zero;
  Offset? finger;
  double _downTime = 0;
  WuffRegion _downRegion = WuffRegion.none;
  bool _stroking = false;
  WuffRegion _strokeRegion = WuffRegion.none;
  int _hold = 0; // 0 none, 1 snuggle, 2 love
  final List<double> _tapTimes = [];
  final List<double> _noseTimes = [];
  double _lastEyeTap = -10;
  WuffRegion _lastEyeRegion = WuffRegion.none;
  double _strokeTime = 0;
  double _heartTimer = 0;
  double _pendingBond = 0;
  double _strokeBudget = 1.5;
  bool _thumping = false;
  bool _snoring = false;
  bool _wokeThisGesture = false;
  double _zzzTimer = 0;
  final Set<String> _onceThisGesture = {};
  double _sinceTrick = 99;
  double _lastWatch = -99;

  // ── grooming ──────────────────────────────────────────────────────────
  bool _grooming = false;
  String _groomTool = '';
  double _lastGroomAt = -99;
  double _groomTime = 0;
  double _groomHaptic = 0;
  double _groomBond = 0;
  double _shakeCountdown = 4;
  bool _groomedEmitted = false;
  double _lastGroomX = 0;

  // ── action timeline (tricks, barks, eating…) ──────────────────────────
  String action = '';
  double actionT = 0;
  double _actionLen = 0;
  bool _actionSuccess = true;
  bool _favorite = false;

  bool get busy => action.isNotEmpty;

  // ══════════════════════════════════════════════════════════════════════
  // Creature interface — placement
  // ══════════════════════════════════════════════════════════════════════
  @override
  Species get species => Species.wuff;

  /// Head radius in px; the whole puppy is about 2.9 radii tall.
  @override
  double get radius => _radius;
  double get r => _radius;

  /// Visual centre of the whole puppy (between head and body).
  @override
  Offset get position => Offset(cx, floorY - jump - _centre * r);

  @override
  set position(Offset p) {
    cx = p.dx;
    floorY = p.dy + _centre * r + jump;
    _clampX();
  }

  @override
  Offset get footPoint => Offset(cx, floorY - jump);

  @override
  void layout(Rect area, {required double floorY, double sizeScale = 1}) {
    final old = _area;
    final frac = _placed && old.width > 0 ? (cx - old.left) / old.width : 0.5;
    _area = area;
    this.floorY = floorY;
    this.sizeScale = sizeScale;
    _radius = math.max(24.0, area.width * radiusFraction * sizeScale);
    cx = area.left + frac * area.width;
    _placed = true;
    _clampX();
  }

  /// Keeps the ears and cheeks inside the walls. True if the wall was hit.
  @override
  void shiftX(double dx) {
    if (pinned) return;
    cx += dx;
    _clampX();
  }

  bool _clampX() {
    final m = 1.5 * r;
    final lo = _area.left + m, hi = _area.right - m;
    if (lo >= hi) {
      cx = _area.center.dx;
      return false;
    }
    if (cx < lo) {
      cx = lo;
      return true;
    }
    if (cx > hi) {
      cx = hi;
      return true;
    }
    return false;
  }

  // ══════════════════════════════════════════════════════════════════════
  // Geometry — local (unposed) frame, the prototype's coordinates
  // ══════════════════════════════════════════════════════════════════════
  double get breath {
    final speed = _asleep ? 0.22 : 0.36;
    final amp = _asleep ? 0.035 : 0.02;
    return 1 + amp * math.sin(time * 2 * math.pi * speed);
  }

  /// Head tilt including the shake-off jitter.
  double get headTilt => tilt.value + math.sin(time * 48) * _shake * 0.12;

  /// Head centre (before tilt), including jump, lean and squash.
  Offset get head => Offset(
        cx + lean.value + math.sin(time * 55) * _shake * r * 0.06,
        floorY - 1.95 * r - jump + squash.value * r * 0.18,
      );
  Offset get body => Offset(cx, floorY - 0.73 * r - jump);
  Offset get nose => head + Offset(0, 0.22 * r);
  Offset get localMouth => head + Offset(0, 0.46 * r);
  Offset get chin => head + Offset(0, 0.70 * r);
  Offset eye(int side) => head + Offset(side * 0.42 * r, -0.08 * r);
  double get eyeRadius => 0.19 * r;
  Offset earPivot(int side) => head + Offset(side * 0.70 * r, -0.70 * r);

  /// Ear angle from vertical, outward positive (rest 0.22 rad). The dryer
  /// flutters it directly: a spring would filter a 6 Hz buzz away.
  double earAngle(int side) =>
      0.22 + (side < 0 ? earL.value : earR.value) + math.sin(time * 38 + (side < 0 ? 0 : 1.7)) * 0.3 * _flutter;
  double get earLength => 1.0 * r;

  Offset earTip(int side) {
    final a = earAngle(side);
    return earPivot(side) + Offset(side * math.sin(a) * earLength, math.cos(a) * earLength);
  }

  Offset get tailRoot => body + Offset(r * 0.62, r * 0.28);
  double get _tailDir => -math.pi / 3.2 + math.sin(tailPhase) * 0.55;
  Offset get tailMid {
    final d = _tailDir - 0.4, len = r * 0.72;
    return tailRoot + Offset(math.cos(d) * len * 0.55, math.sin(d) * len * 0.55);
  }

  Offset get tailTip {
    final d = _tailDir, len = r * 0.72;
    return tailRoot + Offset(math.cos(d) * len, math.sin(d) * len);
  }

  /// Centre of the raised right forepaw (valid while `pawR.value > 0.05`).
  Offset get raisedPawCentre {
    final shoulder = body + Offset(r * 0.32, -r * 0.2);
    final t = pawR.value.clamp(0.0, 1.4);
    final ang = -math.pi / 2 * (0.25 + 0.55 * t);
    final len = r * (0.75 + 0.15 * t);
    return shoulder + Offset(math.cos(ang) * len + r * 0.35 * t, math.sin(ang) * len);
  }

  Offset get _neck => head + Offset(0, 0.8 * r);

  Offset _rot(Offset p, Offset about, double a) {
    final c = math.cos(a), s = math.sin(a);
    final d = p - about;
    return about + Offset(d.dx * c - d.dy * s, d.dx * s + d.dy * c);
  }

  /// Applies the head tilt (local head-frame point → local frame).
  Offset _tiltPt(Offset p) => _rot(p, _neck, headTilt);
  Offset _untilt(Offset p) => _rot(p, _neck, -headTilt);

  // ── pose: whole-body squash, spin and play-dead roll ──────────────────
  double get _poseSx {
    final c = math.cos(spin);
    // Never scale to exactly 0 mid-spin: a zero scale makes the canvas singular.
    final s = c.abs() < 0.08 ? (c >= 0 ? 0.08 : -0.08) : c;
    return (1 + squash.value * 0.10) * s;
  }

  double get _poseSy => 1 - squash.value * 0.10;
  Offset get _poseBase => Offset(cx, floorY - jump);
  double get _rollAngle => -math.pi / 2 * roll;

  /// Local (unposed) → room.
  Offset toRoom(Offset p) {
    final base = _poseBase;
    var q = p - base;
    if (roll > 0.001) {
      q = _rot(q + Offset(0, r * 0.9), Offset.zero, _rollAngle) + Offset(r * 0.55 * roll, -r * 0.9 - r * 0.1 * roll);
    }
    return base + Offset(q.dx * _poseSx, q.dy * _poseSy);
  }

  /// Room → local (unposed).
  Offset fromRoom(Offset p) {
    final base = _poseBase;
    var q = Offset((p.dx - base.dx) / _poseSx, (p.dy - base.dy) / _poseSy);
    if (roll > 0.001) {
      q = _rot(q - Offset(r * 0.55 * roll, -r * 0.9 - r * 0.1 * roll), Offset.zero, -_rollAngle) - Offset(0, r * 0.9);
    }
    return base + q;
  }

  /// The affine transform [WuffArt] applies before painting in the local frame.
  Float64List get poseMatrix {
    final o = toRoom(Offset.zero);
    final ex = toRoom(const Offset(1, 0)) - o;
    final ey = toRoom(const Offset(0, 1)) - o;
    return Float64List.fromList([ex.dx, ex.dy, 0, 0, ey.dx, ey.dy, 0, 0, 0, 0, 1, 0, o.dx, o.dy, 0, 1]);
  }

  Float64List _tiltMatrix() {
    final n = _neck, a = headTilt, c = math.cos(a), s = math.sin(a);
    final tx = n.dx - (c * n.dx - s * n.dy);
    final ty = n.dy - (s * n.dx + c * n.dy);
    return Float64List.fromList([c, s, 0, 0, -s, c, 0, 0, 0, 0, 1, 0, tx, ty, 0, 1]);
  }

  Offset _headRoom(Offset localHeadPoint) => toRoom(_tiltPt(localHeadPoint));

  /// Head centre in room coordinates.
  Offset get headCentre => _headRoom(head);

  @override
  Offset get mouth => _headRoom(localMouth);

  @override
  bool nearMouth(Offset p) => (p - mouth).distance <= 0.7 * r;

  @override
  Path get silhouette {
    final headPath = Path()..addOval(Rect.fromCenter(center: head, width: r * 2.12, height: r * 1.94));
    for (final side in const [-1, 1]) {
      headPath.addOval(Rect.fromCircle(center: head + Offset(side * r * 0.88, r * 0.32), radius: r * 0.28));
    }
    final bodyPath = Path()..addOval(Rect.fromCenter(center: body, width: r * 1.56 * breath, height: r * 1.36));
    for (final side in const [-1, 1]) {
      bodyPath.addOval(Rect.fromCenter(center: body + Offset(side * r * 0.56, r * 0.34), width: r * 0.62, height: r * 0.72));
    }
    final pose = poseMatrix;
    return Path()
      ..addPath(bodyPath.transform(pose), Offset.zero)
      ..addPath(headPath.transform(_tiltMatrix()).transform(pose), Offset.zero);
  }

  @override
  Rect get bounds {
    Rect? box;
    void add(Offset room) {
      box = box == null ? Rect.fromLTRB(room.dx, room.dy, room.dx, room.dy) : box!.expandToInclude(Rect.fromLTRB(room.dx, room.dy, room.dx, room.dy));
    }

    void addLocal(Offset p) => add(toRoom(p));
    void addHead(Offset p) => add(_headRoom(p));
    final h = head;
    for (final dx in const [-1.2, 1.2]) {
      addHead(h + Offset(dx * r, -1.0 * r));
      addHead(h + Offset(dx * r, 0.65 * r));
    }
    for (final side in const [-1, 1]) {
      final tip = earTip(side);
      addHead(tip + Offset(side * 0.45 * r, 0.1 * r));
      addHead(tip + Offset(-side * 0.2 * r, 0.1 * r));
    }
    final b = body;
    for (final dx in const [-0.95, 0.95]) {
      addLocal(Offset(b.dx + dx * r, b.dy - 0.7 * r));
      addLocal(Offset(b.dx + dx * r, floorY - jump + 0.1 * r));
    }
    addLocal(tailTip + Offset(0.1 * r, 0));
    if (pawR.value > 0.05) addLocal(raisedPawCentre + Offset(0.25 * r, -0.25 * r));
    return box!.inflate(0.06 * r);
  }

  /// Classifies a *room* point on the puppy. Order matters: small parts first.
  /// [slack] > 1 grows every part (a little margin for fingers).
  WuffRegion regionAt(Offset room, {double slack = 1}) {
    final lp = fromRoom(room);
    final hp = _untilt(lp);
    final h = head;
    if ((hp - nose).distance <= 0.24 * r * slack) return WuffRegion.nose;
    if ((hp - eye(-1)).distance <= eyeRadius * 1.5 * slack) return WuffRegion.eyeL;
    if ((hp - eye(1)).distance <= eyeRadius * 1.5 * slack) return WuffRegion.eyeR;
    for (final side in const [-1, 1]) {
      final c = (earPivot(side) + earTip(side)) / 2;
      if (_inEllipse(hp, c, 0.42 * r * slack, 0.62 * r * slack) && !_inEllipse(hp, h, 0.66 * r, 0.82 * r)) {
        return side < 0 ? WuffRegion.earL : WuffRegion.earR;
      }
    }
    if (_inEllipse(hp, chin, 0.42 * r * slack, 0.26 * r * slack)) return WuffRegion.chin;
    if (_inEllipse(hp, h, 1.08 * r * slack, 0.98 * r * slack)) return WuffRegion.head;
    if (_inEllipse(lp, body, 0.86 * r * slack, 0.80 * r * slack)) return WuffRegion.body;
    return WuffRegion.none;
  }

  bool _inEllipse(Offset p, Offset c, double rx, double ry) {
    final dx = (p.dx - c.dx) / rx, dy = (p.dy - c.dy) / ry;
    return dx * dx + dy * dy <= 1;
  }

  @override
  bool hitTest(Offset p) => regionAt(p, slack: 1.1) != WuffRegion.none;

  // ══════════════════════════════════════════════════════════════════════
  // Events
  // ══════════════════════════════════════════════════════════════════════
  void _emit(CreatureEventType t, [String id = '', double v = 0]) => _events.add(CreatureEvent(t, id, v));

  /// One-shot sound by short name (`bark`, `chomp`). Barks and yips pick a
  /// random take and vary pitch so repeated taps never sound like a loop.
  void _sfx(String name, [double pitch = 1]) {
    var id = name;
    var p = pitch;
    final takes = _takes[name];
    if (takes != null) {
      id = takes[_rng.nextInt(takes.length)];
      p = 0.93 + _rng.nextDouble() * 0.16;
    } else if (name == 'boop' || name == 'toy' || name == 'chomp') {
      p = 0.92 + _rng.nextDouble() * 0.16;
    }
    _emit(CreatureEventType.sound, 'wuff.$id', p);
  }

  void _haptic(String kind) => _emit(CreatureEventType.haptic, kind);
  void _reaction(String id) => _emit(CreatureEventType.reaction, 'wuff.$id');
  void _coach(String step) => _emit(CreatureEventType.coach, step);

  void _say(String line, [double seconds = 1.3]) {
    bubble = line;
    bubbleTimer = seconds;
    _emit(CreatureEventType.bubble, 'bubble.wuff.$line');
  }

  @override
  List<CreatureEvent> drainEvents() {
    if (_events.isEmpty) return const [];
    final out = List<CreatureEvent>.of(_events);
    _events.clear();
    return out;
  }

  void _setExpr(WuffExpr e, double seconds) {
    expr = e;
    _exprTimer = seconds;
  }

  void _resetIdle() => idleTime = 0;

  void _bond(double v) => _pendingBond += v;

  void _flushBond() {
    if (_pendingBond > 0.05) {
      _emit(CreatureEventType.progress, 'bond', _pendingBond);
      _pendingBond = 0;
    }
  }

  void _hop(double v) {
    if (!reduceMotion && !pinned && jump <= 0) _jumpV = v;
  }

  void _spinFor(double seconds) {
    if (!reduceMotion && !pinned) _spinV = 2 * math.pi / seconds;
  }

  // ══════════════════════════════════════════════════════════════════════
  // Input (room coordinates)
  // ══════════════════════════════════════════════════════════════════════
  @override
  int? get activePointer => _pointer;

  @override
  bool pointerDown(int pointer, Offset p) {
    if (_pointer != null) return false; // one finger drives the puppy
    final region = regionAt(p, slack: 1.1);
    if (region == WuffRegion.none) return false;
    _pointer = pointer;
    _downPos = p;
    _lastPos = p;
    finger = p;
    _downTime = time;
    _downRegion = region;
    _stroking = false;
    _hold = 0;
    _strokeTime = 0;
    _onceThisGesture.clear();
    _resetIdle();
    _wokeThisGesture = _asleep;
    if (_wokeThisGesture) _wake();
    return true;
  }

  @override
  void pointerMove(int pointer, Offset p) {
    if (pointer != _pointer) return;
    finger = p;
    _resetIdle();
    final moved = (p - _downPos).distance;
    if (_hold == 0 && !_stroking && moved > strokeSlop && !busy) {
      _stroking = true;
      _strokeRegion = switch (_downRegion) {
        WuffRegion.earL || WuffRegion.earR => _downRegion,
        WuffRegion.chin => WuffRegion.chin,
        _ => WuffRegion.head,
      };
      _coach('pet');
      _haptic('light');
    }
    if (_stroking) _stroke(_lastPos, p);
    _lastPos = p;
  }

  @override
  void pointerUp(int pointer, Offset p) {
    if (pointer != _pointer) return;
    _pointer = null;
    finger = null;
    final dur = time - _downTime;
    if (_stroking) {
      _endStroke();
    } else if (_hold > 0) {
      lean.target = 0;
      _setExpr(WuffExpr.happy, 0.9);
      blush = math.max(blush, 0.4);
    } else if (dur <= tapMaxDuration && (p - _downPos).distance <= tapSlop && !_wokeThisGesture) {
      _tap(_downRegion, p);
    }
    _hold = 0;
    _stroking = false;
    _flushBond();
  }

  @override
  void pointerCancel(int pointer) {
    if (pointer != _pointer) return;
    _pointer = null;
    finger = null;
    if (_stroking) _endStroke();
    if (_hold > 0) {
      lean.target = 0;
      _setExpr(WuffExpr.happy, 0.6);
    }
    _hold = 0;
    _stroking = false;
    _flushBond();
  }

  /// Aim the eyes at a room point for [seconds].
  void _glanceAt(Offset p, double seconds) {
    final d = p - headCentre;
    final len = d.distance;
    if (len < 1) return;
    _lookTX = (d.dx / len) * math.min(1, len / (r * 2));
    _lookTY = (d.dy / len) * math.min(1, len / (r * 2));
    _nextGlance = time + seconds;
  }

  @override
  void lookAt(Offset? target) {
    _lookTarget = target;
    if (target != null) _glanceAt(target, 0.4);
  }

  void _tap(WuffRegion region, Offset p) {
    // Boops during a sneeze wind-up count toward the big sneeze (three boops
    // within 2 s); every other tap waits for the action to end.
    final escalating = region == WuffRegion.nose && action == 'sneeze';
    if (busy && action != 'zoomies' && !escalating) return;
    if (region == WuffRegion.nose) {
      _noseTap();
      return;
    }
    if (region == WuffRegion.eyeL || region == WuffRegion.eyeR) {
      if (_lastEyeRegion == region && time - _lastEyeTap <= eyeDoubleTapWindow) {
        _lastEyeTap = -10;
        _setExpr(region == WuffRegion.eyeL ? WuffExpr.winkL : WuffExpr.winkR, 1.2);
        tilt.vel += region == WuffRegion.eyeL ? -2 : 2;
        _sfx('wink');
        _haptic('light');
        _reaction('wink');
        return;
      }
      _lastEyeRegion = region;
      _lastEyeTap = time;
    }
    _tapTimes.add(time);
    _tapTimes.removeWhere((t) => time - t > zoomieWindow);
    if (_tapTimes.length >= zoomieTaps) {
      _tapTimes.clear();
      zoomies();
      return;
    }
    // A happy yip: ears flop up, tail goes wild for a moment.
    earL.vel += 6;
    earR.vel += 6;
    if (!reduceMotion) squash.vel += 5;
    _tailTarget = 16;
    if (expr != WuffExpr.excited && expr != WuffExpr.dizzy) _setExpr(WuffExpr.happy, 0.9);
    _burst(WuffParticleKind.sparkle, p, 3);
    _sfx('yip');
    _haptic('light');
    _reaction('yip');
    _bond(0.3);
  }

  void _noseTap() {
    _noseTimes.add(time);
    _noseTimes.removeWhere((t) => time - t > noseTapWindow);
    final big = _noseTimes.length >= 3;
    if (big) _noseTimes.clear();
    _startAction(big ? 'bigSneeze' : 'sneeze', big ? 1.5 : 1.1);
    _setExpr(WuffExpr.sniff, 0.5);
    noseWiggle = 1;
    // The boop itself answers within one frame; the sneeze follows.
    _sfx('boop');
    _haptic('light');
  }

  void _stroke(Offset a, Offset b) {
    final seg = b - a;
    final segLen = seg.distance;
    if (segLen < 0.5) return;
    final earSide = _strokeRegion == WuffRegion.earL ? -1 : 1;
    final onEar = (_strokeRegion == WuffRegion.earL || _strokeRegion == WuffRegion.earR) &&
        (b - _headRoom((earPivot(earSide) + earTip(earSide)) / 2)).distance < r * 1.4;
    if (!hitTest(b) && !onEar) return;
    _glanceAt(b, 0.8);
    final len = math.min(segLen, 40.0);
    switch (_strokeRegion) {
      case WuffRegion.earL:
      case WuffRegion.earR:
        (earSide < 0 ? earL : earR).vel += seg.dy.sign * len * 0.05;
        _strokeBond(len * 0.006);
        if (!_thumping) {
          _thumping = true;
          _emit(CreatureEventType.loopStart, 'wuff.thump', wuffSoundGains['wuff.thump'] ?? 0.5);
        }
      case WuffRegion.chin:
        _blepTarget = 1;
        _strokeBond(len * 0.004);
      default:
        tilt.vel += seg.dx * 0.006;
        _strokeBond(len * 0.004);
    }
  }

  /// Petting bond is rate-limited (≈1 point/s sustained), so scrubbing the
  /// screen fast earns no more than a calm stroke.
  void _strokeBond(double v) {
    final b = math.min(v, _strokeBudget);
    _strokeBudget -= b;
    _bond(b);
  }

  void _endStroke() {
    if (_thumping) {
      _thumping = false;
      _emit(CreatureEventType.loopStop, 'wuff.thump');
    }
    _blepTarget = 0;
    _flushBond();
    if (expr == WuffExpr.bliss) _setExpr(WuffExpr.happy, 0.8);
    _strokeTime = 0;
  }

  void _emitOnce(String id) {
    if (_onceThisGesture.add('$id@$_downTime')) _reaction(id);
  }

  // ══════════════════════════════════════════════════════════════════════
  // The rest of the world
  // ══════════════════════════════════════════════════════════════════════
  @override
  void nudge(Offset impulse) {
    if (pinned) return;
    if (_asleep && impulse.distance > 600) _wake();
    _vx = (_vx + impulse.dx).clamp(-1200.0, 1200.0);
    earL.vel += impulse.dx * 0.002;
    earR.vel += impulse.dx * 0.002;
    tilt.vel += (impulse.dx * 0.0015).clamp(-3.0, 3.0);
    if (impulse.dy < -400) _hop(math.min(520.0, -impulse.dy * 0.4));
  }

  @override
  void react(SocialCue cue, {Offset? from}) {
    switch (cue) {
      case SocialCue.friendTouched:
        if (from != null) _glanceAt(from, 1.6);
        earL.vel += 3;
        earR.vel += 3;
        if (time - _lastWatch > 30) {
          _lastWatch = time;
          _reaction('watchFriend');
        }
      case SocialCue.landedOnMe:
        if (_asleep) _wake();
        if (!busy) _setExpr(WuffExpr.startled, 0.9);
        _hop(400);
        if (!reduceMotion) squash.vel += 6;
        earL.vel += 9;
        earR.vel += 9;
        _tailTarget = 14;
        if (from != null) _glanceAt(from, 1.2);
        _sfx('yip');
        _haptic('light');
        _reaction('startled');
      case SocialCue.nuzzled:
        if (_asleep) _wake();
        if (!busy) _setExpr(WuffExpr.happy, 1.4);
        _tailTarget = 20;
        blush = math.max(blush, 0.7);
        if (from != null) {
          _glanceAt(from, 1.2);
          lean.vel += (from.dx - cx).sign * 40;
        }
        earL.vel += 4;
        earR.vel += 4;
        _burst(WuffParticleKind.heart, _headRoom(head - Offset(0, r)), 2);
        _sfx('aww');
        _haptic('light');
        _reaction('nuzzled');
        _bond(0.4);
        _flushBond();
      case SocialCue.celebrate:
        celebrate();
    }
    _resetIdle();
  }

  /// A bond milestone or a group celebration.
  @override
  void celebrate() {
    if (_asleep) _wake();
    _startAction('celebrate', 1.6);
    _setExpr(WuffExpr.proud, 2.0);
    _burst(WuffParticleKind.sparkle, _headRoom(head - Offset(0, r * 0.3)), 14, spread: 1.6);
    _burst(WuffParticleKind.heart, _headRoom(head - Offset(0, r)), 5);
    _sfx('fanfare');
    _haptic('success');
    _reaction('cheer');
    _resetIdle();
  }

  /// A small happy hop and sparkles (new outfit, first run).
  void celebrateSmall() {
    if (_asleep) _wake();
    _setExpr(WuffExpr.happy, 1.2);
    _burst(WuffParticleKind.sparkle, _headRoom(head - Offset(0, r * 0.4)), 8, spread: 1.3);
    _hop(520);
    _tailTarget = 16;
    _sfx('sparkle');
    _haptic('light');
  }

  /// Shake gesture from the accelerometer: dizzy.
  @override
  void shake() {
    if (_asleep) _wake();
    _cancelAction();
    _setExpr(WuffExpr.dizzy, 2.0);
    earL.vel += 14;
    earR.vel += 14;
    tilt.vel += (_rng.nextBool() ? 1 : -1) * (reduceMotion ? 2 : 6);
    if (!reduceMotion) squash.vel += 6;
    _burst(WuffParticleKind.star, _headRoom(head - Offset(0, r * 0.9)), 4);
    _sfx('wobble');
    _haptic('heavy');
    _reaction('dizzy');
    _resetIdle();
  }

  /// VoiceOver activation: a pet on the head.
  void petCentre() {
    if (_pointer != null) return;
    _setExpr(WuffExpr.bliss, 1.0);
    _burst(WuffParticleKind.heart, _headRoom(head - Offset(0, r)), 2);
    _reaction('pet');
    _coach('pet');
    _bond(0.5);
    _flushBond();
  }

  /// Five quick taps, or the daily hello: a spin, stars and an excited bark.
  void zoomies() {
    if (_asleep) _wake();
    _startAction('zoomies', reduceMotion ? 0.9 : 1.2);
    _setExpr(WuffExpr.excited, 1.6);
    _tailTarget = 22;
    _burst(WuffParticleKind.star, _headRoom(head - Offset(0, r)), 6, spread: 1.4);
    _sfx('bark');
    _haptic('medium');
    _reaction('zoomies');
    _say('bark');
    _bond(0.6);
    _resetIdle();
  }

  // ══════════════════════════════════════════════════════════════════════
  // Feeding
  // ══════════════════════════════════════════════════════════════════════
  @override
  void setSnackHover(bool hovering, [Offset? at]) {
    treatHover = hovering;
    if (hovering && _asleep) _wake();
    if (at != null) _glanceAt(at, 0.6);
    _resetIdle();
  }

  @override
  void eat({required bool favorite}) {
    if (_asleep) _wake();
    treatHover = false;
    _favorite = favorite;
    _startAction('eat', favorite ? 2.0 : 1.5);
    _setExpr(WuffExpr.eating, 1e9);
    _sfx('chomp');
    _haptic('light');
    _burst(WuffParticleKind.crumb, mouth, 5);
    // A treat soon after a trick is the "good pup" reward.
    if (_sinceTrick < 10) {
      _sinceTrick = 99;
      _burst(WuffParticleKind.sparkle, _headRoom(head - Offset(0, r * 0.6)), 10, spread: 1.4);
      _reaction('goodPup');
    }
    _resetIdle();
  }

  /// Too many treats this hour: head turned away, a polite huff.
  @override
  void refuseFull() {
    treatHover = false;
    _startAction('full', 1.8);
    _setExpr(WuffExpr.nope, 1.8);
    lean.target = 0;
    tilt.vel -= 5;
    _sfx('huff');
    _reaction('full');
    _emit(CreatureEventType.bubble, 'bubble.full');
    _resetIdle();
  }

  // ══════════════════════════════════════════════════════════════════════
  // Species API: tricks and the bark board
  // ══════════════════════════════════════════════════════════════════════
  /// A trick request resolved by the store. [success] decides the animation.
  /// Ids: `sit`, `paw`, `spin`, `speak`, `playDead`, `highFive`.
  void doTrick(String trickId, {required bool success}) {
    if (_asleep) _wake();
    final known = wuffTricks.any((t) => t.id == trickId);
    _actionSuccess = success && known;
    if (!_actionSuccess) {
      _startAction('confused', 1.4);
      _setExpr(WuffExpr.confused, 1.4);
      tilt.target = 0.32;
      _burst(WuffParticleKind.question, _headRoom(head - Offset(-r * 0.6, r * 1.0)), 1, spread: 0.1);
      _sfx('huh');
      _resetIdle();
      return;
    }
    final len = switch (trickId) {
      'spin' => reduceMotion ? 1.0 : 1.3,
      'playDead' => 2.6,
      'speak' => 1.2,
      _ => 1.4,
    };
    _startAction('trick:$trickId', len);
    _setExpr(trickId == 'playDead' ? WuffExpr.playDead : WuffExpr.proud, len);
    _resetIdle();
  }

  /// A bark-board pad was pressed (ids in [wuffBarkPads]). Every pad is safe
  /// to spam: it restarts the pad animation and emits its sound.
  void bark(String padId) {
    if (_asleep) _wake();
    final pad = wuffBarkPads.firstWhere((p) => p.id == padId, orElse: () => wuffBarkPads.first);
    final id = pad.id;
    final len = switch (id) {
      'howl' => 2.0,
      'whimper' => 1.6,
      'growl' => 1.4,
      'pant' => 1.4,
      _ => 0.9,
    };
    _startAction('pad:$id', len);
    final e = switch (id) {
      'howl' => WuffExpr.howl,
      'whimper' => WuffExpr.puppyEyes,
      'growl' => WuffExpr.growl,
      'sneeze' => WuffExpr.sniff,
      'squeak' => WuffExpr.excited,
      'play' => WuffExpr.excited,
      _ => WuffExpr.speak,
    };
    _setExpr(e, len);
    _sfx(pad.sound.substring('wuff.'.length));
    if (id != 'sneeze') _say(id, math.max(1.0, len));
    if (id == 'play') _tailTarget = 20;
    if (id == 'howl') _reaction('howl');
    _resetIdle();
  }

  // ══════════════════════════════════════════════════════════════════════
  // Care tools
  // ══════════════════════════════════════════════════════════════════════
  @override
  void groom(Offset p, double speed, {required String tool}) {
    if (_asleep) _wake();
    final session = !_grooming;
    _grooming = true;
    _groomTool = tool;
    _lastGroomAt = time;
    _resetIdle();
    final sp = (speed / 600).clamp(0.0, 2.0);
    if (session) {
      _groomTime = 0;
      _groomHaptic = 0;
      _groomedEmitted = false;
      _shakeCountdown = 3 + _rng.nextDouble() * 3;
      _lastGroomX = p.dx;
      _haptic('selection');
      _coach('groom');
    }
    if (expr != WuffExpr.dizzy && !busy) _setExpr(WuffExpr.bliss, 0.45);
    _glanceAt(p, 0.5);
    _tailTarget = math.max(_tailTarget, tool == 'dryer' ? 9 : 13);
    final head0 = headCentre;
    lean.target = ((p.dx - head0.dx) * 0.2).clamp(-r * 0.2, r * 0.2).toDouble();
    tilt.vel += ((p.dx - _lastGroomX) * 0.004).clamp(-0.6, 0.6);
    _lastGroomX = p.dx;
    switch (tool) {
      case 'dryer':
        _flutter = math.max(_flutter, (0.35 + 0.65 * sp).clamp(0.0, 1.0));
      case 'towel':
        earL.vel += (p.dx - head0.dx).sign * 0.5;
        earR.vel += (p.dx - head0.dx).sign * 0.5;
        blush = math.max(blush, 0.5);
      default: // foam, brush…
        blush = math.max(blush, 0.35);
    }
  }

  /// Ends a grooming session: the occasional shake-off flings the water.
  void _endGroom() {
    _grooming = false;
    lean.target = 0;
    if (_groomTime > 0.8 && _groomTool != 'dryer' && care.wet > 0.25) _shakeOff();
  }

  void _shakeOff() {
    _shake = 1;
    earL.vel += 16;
    earR.vel -= 16;
    if (!reduceMotion) squash.vel += 4;
    final h = headCentre;
    for (var i = 0; i < 9; i++) {
      final a = (i / 9) * 2 * math.pi + _rng.nextDouble() * 0.5;
      final sp = 160 + _rng.nextDouble() * 160;
      _addParticle(WuffParticleKind.drop, h + Offset(math.cos(a), math.sin(a)) * r * 0.8, Offset(math.cos(a), math.sin(a) - 0.3) * sp, 0.8, 4 + _rng.nextDouble() * 3);
    }
    _sfx('wobble', 1.15);
    _haptic('light');
    _reaction('shakeOff');
  }

  // ══════════════════════════════════════════════════════════════════════
  // Accessories
  // ══════════════════════════════════════════════════════════════════════
  @override
  Anchor anchor(AccessorySlot slot) {
    final s = r / 92; // accessories are authored for a creature of radius 92
    final roll0 = _rollAngle;
    switch (slot) {
      case AccessorySlot.head:
        // Between the ears, on top of the skull, riding the head tilt.
        return Anchor(_headRoom(head + Offset(0, -0.9 * r)), s, headTilt + roll0);
      case AccessorySlot.face:
        // The eye line: glasses sit across both eyes (eyes are 0.42r apart).
        return Anchor(_headRoom(head + Offset(0, -0.08 * r)), s * 1.2, headTilt + roll0);
      case AccessorySlot.neck:
        // The collar line just under the chin.
        return Anchor(toRoom(Offset(cx, floorY - 1.02 * r - jump)), s * 0.95, roll0);
    }
  }

  // ══════════════════════════════════════════════════════════════════════
  // Life
  // ══════════════════════════════════════════════════════════════════════
  @override
  LifeState get life {
    if (_asleep) return LifeState.asleep;
    if (action == 'eat') return LifeState.eating;
    if (jump > 4) return LifeState.airborne;
    if (_hold > 0) return LifeState.held;
    return LifeState.awake;
  }

  @override
  void sleep() {
    if (_asleep) return;
    _cancelAction();
    _fallAsleep();
  }

  @override
  void wake() {
    if (_asleep) _wake();
  }

  void _wake() {
    _asleep = false;
    if (_snoring) {
      _snoring = false;
      _emit(CreatureEventType.loopStop, 'wuff.snore');
    }
    _setExpr(WuffExpr.sleepy, 1.4);
    _sfx('yawn');
    _reaction('wake');
    _resetIdle();
  }

  void _fallAsleep() {
    _asleep = true;
    _setExpr(WuffExpr.asleep, 1e9);
    _reaction('nap');
    if (!_snoring) {
      _snoring = true;
      _emit(CreatureEventType.loopStart, 'wuff.snore', wuffSoundGains['wuff.snore'] ?? 0.35);
    }
  }

  // ══════════════════════════════════════════════════════════════════════
  // Action timeline
  // ══════════════════════════════════════════════════════════════════════
  void _startAction(String id, double seconds) {
    _cancelAction();
    action = id;
    actionT = 0;
    _actionLen = seconds;
  }

  void _cancelAction() {
    if (action == 'trick:playDead') _rollTarget = 0;
    squash.target = 0;
    action = '';
    actionT = 0;
    pawR.target = 0;
    pawL.target = 0;
    tilt.target = 0;
    _mouthTarget = 0;
  }

  /// Fires the one-shot moments of each action at fixed points of its timeline.
  void _runAction(double dt) {
    if (!busy) return;
    final before = actionT;
    actionT += dt;
    bool at(double s) => before < s && actionT >= s;
    final kind = action;
    if (kind == 'sneeze' || kind == 'bigSneeze') {
      final big = kind == 'bigSneeze';
      if (at(big ? 0.75 : 0.45)) {
        _setExpr(WuffExpr.sneeze, 0.5);
        squash.vel -= big ? 10 : 6;
        earL.vel += 8;
        earR.vel += 8;
        _burst(WuffParticleKind.sparkle, _headRoom(nose), big ? 8 : 4, spread: 0.7);
        _sfx(big ? 'bigsneeze' : 'sneeze');
        _haptic(big ? 'medium' : 'light');
        _reaction(big ? 'bigSneeze' : 'achoo');
        _say('achoo', 1.0);
      }
      _mouthTarget = 0;
    } else if (kind == 'zoomies') {
      if (at(0.05)) _spinFor(0.7);
      if (at(0.02)) _hop(620);
    } else if (kind == 'eat') {
      _mouthTarget = 0.35 + 0.45 * math.sin(actionT * 16).abs();
    } else if (kind == 'celebrate') {
      if (at(0.05)) _hop(760);
    } else if (kind == 'confused') {
      tilt.target = 0.32;
    } else if (kind == 'full') {
      // Pats its round belly twice with a front paw.
      pawR.target = actionT > 0.4 && actionT < 1.6 ? 0.22 + 0.14 * math.sin((actionT - 0.4) * 14).abs() : 0;
    } else if (kind.startsWith('trick:')) {
      _runTrick(kind.substring(6), before);
    } else if (kind.startsWith('pad:')) {
      _runPad(kind.substring(4), before);
    }
    if (actionT >= _actionLen) _finishAction(kind);
  }

  void _runTrick(String id, double before) {
    bool at(double s) => before < s && actionT >= s;
    switch (id) {
      case 'sit':
        if (at(0.1)) {
          if (!reduceMotion) squash.vel += 9;
          _sfx('boop');
        }
        if (at(0.55)) _cheer();
      case 'paw':
        pawR.target = actionT < 1.0 ? 1 : 0;
        if (at(0.35)) _cheer();
      case 'spin':
        if (at(0.05)) {
          if (reduceMotion) {
            tilt.vel += 4;
          } else {
            _spinFor(0.8);
          }
          _sfx('whoosh');
        }
        if (at(0.85)) _cheer();
      case 'speak':
        if (at(0.15)) {
          _mouthTarget = 1;
          _sfx('bark');
          _say('bark', 1.1);
        }
        if (at(0.6)) {
          _mouthTarget = 0;
          _cheer();
        }
      case 'playDead':
        _rollTarget = actionT < 1.9 ? 1 : 0;
        if (at(0.1)) _sfx('flop');
        if (at(1.95)) {
          _hop(520);
          _setExpr(WuffExpr.excited, 0.7);
          _cheer();
        }
      case 'highFive':
        pawR.target = actionT < 1.0 ? 1.35 : 0;
        if (at(0.4)) {
          _burst(WuffParticleKind.sparkle, _headRoom(head + Offset(r * 1.1, -r * 0.1)), 8, spread: 1.2);
          _sfx('clap');
          _cheer();
        }
    }
  }

  void _cheer() {
    _tailTarget = 18;
    _burst(WuffParticleKind.star, _headRoom(head - Offset(0, r * 1.1)), 3, spread: 1.2);
    _sfx('cheer');
    _haptic('success');
  }

  void _runPad(String pad, double before) {
    bool at(double s) => before < s && actionT >= s;
    if (at(0.02)) {
      _haptic('light');
      switch (pad) {
        case 'howl':
          tilt.target = -0.05;
        case 'pant':
          _tongueTarget = 1;
          _pantTimer = 1.4;
        case 'sneeze':
          noseWiggle = 1;
        case 'squeak':
          earL.vel += 8;
          earR.vel += 8;
          _burst(WuffParticleKind.note, _headRoom(head + Offset(r * 0.9, -r * 0.6)), 2, spread: 0.5);
        default:
          earL.vel += 4;
          earR.vel += 4;
      }
    }
    if (pad == 'sneeze' && at(0.3)) {
      _setExpr(WuffExpr.sneeze, 0.5);
      squash.vel -= 6;
      _say('achoo', 0.9);
    }
    // Mouth follows the sound's envelope roughly.
    _mouthTarget = switch (pad) {
      'howl' => actionT < 1.7 ? 0.9 : 0,
      'whimper' => 0.15,
      'growl' => 0.35,
      'pant' => 0.6,
      'squeak' => 0,
      'sneeze' => 0,
      _ => actionT < 0.4 ? 1 : 0,
    };
    if (pad == 'howl') {
      tilt.target = -0.05;
      // Head up: stretch tall (negative squash lifts the head) while it sings.
      squash.target = actionT < 1.7 ? -0.28 : 0;
    }
  }

  void _finishAction(String kind) {
    squash.target = 0;
    action = '';
    actionT = 0;
    pawR.target = 0;
    pawL.target = 0;
    tilt.target = 0;
    _rollTarget = 0;
    _mouthTarget = 0;
    if (kind == 'eat') {
      if (_favorite) {
        _setExpr(WuffExpr.love, 1.6);
        _spinFor(0.7);
        _burst(WuffParticleKind.heart, _headRoom(head - Offset(0, r)), 6);
        _reaction('favorite');
      } else {
        _setExpr(WuffExpr.happy, 1.2);
      }
      _tailTarget = 16;
      _sfx('yum');
      _reaction('yum');
      _emit(CreatureEventType.progress, 'bond', _favorite ? 2 : 1);
    } else if (kind.startsWith('trick:') && _actionSuccess) {
      final id = kind.substring(6);
      _setExpr(WuffExpr.happy, 1.0);
      _sinceTrick = 0;
      // The "good pup" reward window opens when the trick is over, not at the request.
      _reaction('trick.$id');
      _emit(CreatureEventType.progress, 'trick', 1);
      _coach('trick');
    }
  }

  // ══════════════════════════════════════════════════════════════════════
  // Particles
  // ══════════════════════════════════════════════════════════════════════
  void _addParticle(WuffParticleKind k, Offset at, Offset vel, double life, double size, [double spin = 0]) {
    if (particles.length > 160) return;
    particles.add(WuffParticle(k, at, vel, life, size, spin));
  }

  void _burst(WuffParticleKind k, Offset at, int n, {double spread = 1}) {
    if (particles.length > 160) return;
    for (var i = 0; i < n; i++) {
      final a = -math.pi / 2 + (_rng.nextDouble() - 0.5) * 2.2 * spread;
      final sp = switch (k) {
        WuffParticleKind.heart => 70 + _rng.nextDouble() * 60,
        WuffParticleKind.sparkle => 90 + _rng.nextDouble() * 140,
        WuffParticleKind.zzz => 30.0,
        WuffParticleKind.crumb => 80 + _rng.nextDouble() * 80,
        WuffParticleKind.star => 60 + _rng.nextDouble() * 50,
        WuffParticleKind.question => 24.0,
        WuffParticleKind.note => 50 + _rng.nextDouble() * 30,
        WuffParticleKind.drop => 120.0,
      };
      final life = switch (k) {
        WuffParticleKind.heart => 1.4 + _rng.nextDouble() * 0.5,
        WuffParticleKind.sparkle => 0.7 + _rng.nextDouble() * 0.4,
        WuffParticleKind.zzz => 2.2,
        WuffParticleKind.crumb => 0.7,
        WuffParticleKind.star => 1.2,
        WuffParticleKind.question => 1.3,
        WuffParticleKind.note => 1.4,
        WuffParticleKind.drop => 0.8,
      };
      final size = switch (k) {
        WuffParticleKind.heart => 14 + _rng.nextDouble() * 8,
        WuffParticleKind.sparkle => 6 + _rng.nextDouble() * 6,
        WuffParticleKind.zzz => 16.0,
        WuffParticleKind.crumb => 3 + _rng.nextDouble() * 3,
        WuffParticleKind.star => 10.0,
        WuffParticleKind.question => 26.0,
        WuffParticleKind.note => 14.0,
        WuffParticleKind.drop => 4.0,
      };
      // Particle sizes are authored for a ~120px head; keep them in proportion.
      final k2 = (r / 60).clamp(0.6, 1.8);
      _addParticle(k, at, Offset(math.cos(a), math.sin(a)) * sp, life, size * k2, (_rng.nextDouble() - 0.5) * 4);
    }
  }

  // ══════════════════════════════════════════════════════════════════════
  // Simulation step
  // ══════════════════════════════════════════════════════════════════════
  @override
  void update(double dt) {
    if (!dt.isFinite || dt <= 0) return;
    dt = math.min(dt, 0.1);
    final n = (dt / (1 / 30)).ceil();
    final h = dt / n;
    for (var i = 0; i < n; i++) {
      _step(h);
    }
  }

  void _step(double dt) {
    time += dt;
    _strokeBudget = math.min(1.5, _strokeBudget + dt);
    _sinceTrick += dt;

    // Hold → snuggle → love, only while still on the puppy.
    // A dizzy puppy finishes its wobble first (dizzy for 2 s).
    if (_pointer != null && !_stroking && !busy && expr != WuffExpr.dizzy) {
      final held = time - _downTime;
      if (_hold == 0 && held >= holdDelay) {
        _hold = 1;
        _setExpr(WuffExpr.bliss, 1e9);
        final f = finger ?? headCentre;
        lean.target = ((f.dx - headCentre.dx) * 0.25).clamp(-r * 0.25, r * 0.25).toDouble();
        _sfx('aww');
        _haptic('light');
        _reaction('snuggle');
        _bond(0.8);
      } else if (_hold == 1 && held >= loveDelay) {
        _hold = 2;
        _setExpr(WuffExpr.love, 1e9);
        blush = 1;
        _burst(WuffParticleKind.heart, _headRoom(head - Offset(0, r)), 5);
        _sfx('love');
        _haptic('medium');
        _reaction('love');
        _bond(1.2);
      }
    }

    // Petting: bliss face, hearts, journal moments.
    if (_stroking && _pointer != null) {
      _strokeTime += dt;
      if (expr != WuffExpr.dizzy) _setExpr(WuffExpr.bliss, 0.4);
      _tailTarget = 14;
      _heartTimer += dt;
      if (_heartTimer > 0.45) {
        _heartTimer = 0;
        _burst(WuffParticleKind.heart, _headRoom(head - Offset(0, r * 1.0)), 1);
      }
      if (_strokeTime > 0.5) {
        switch (_strokeRegion) {
          case WuffRegion.earL:
          case WuffRegion.earR:
            _emitOnce('earScratch');
          case WuffRegion.chin:
            _emitOnce('blep');
          default:
            _emitOnce('pet');
        }
      }
      if (_pendingBond > 0.6) _flushBond();
    }

    // Grooming session bookkeeping.
    if (_grooming) {
      if (time - _lastGroomAt > 0.5) {
        _endGroom();
      } else {
        _groomTime += dt;
        _groomHaptic += dt;
        _groomBond += dt;
        if (_groomHaptic >= 0.22) {
          _groomHaptic = 0;
          _haptic('selection');
        }
        if (_groomTime > 1.2 && !_groomedEmitted) {
          _groomedEmitted = true;
          if (_groomTool != 'dryer') _sfx('aww');
          _reaction('groomed');
          _burst(WuffParticleKind.heart, _headRoom(head - Offset(0, r)), 2);
        }
        if (_groomBond >= 1.0) {
          _groomBond = 0;
          _emit(CreatureEventType.progress, 'bond', 0.3);
        }
        _shakeCountdown -= dt;
        if (_shakeCountdown <= 0) {
          _shakeCountdown = 4 + _rng.nextDouble() * 4;
          if (_groomTool != 'dryer' && care.wet > 0.2) _shakeOff();
        }
      }
    }
    _shake = math.max(0, _shake - dt * 1.8);
    _flutter = math.max(0, _flutter - dt * (_grooming && _groomTool == 'dryer' ? 1.2 : 3.0));

    _runAction(dt);

    // Jump (whole puppy) with gravity.
    if (pinned) {
      jump = 0;
      _jumpV = 0;
    } else if (jump > 0 || _jumpV != 0) {
      _jumpV -= gravity * dt;
      jump += _jumpV * dt;
      if (jump <= 0) {
        jump = 0;
        if (_jumpV < -300) {
          squash.vel += math.min(10.0, -_jumpV / 120);
          earL.vel += 5;
          earR.vel += 5;
        }
        _jumpV = 0;
      }
    }

    // Shoved sideways: slide and stop at the walls.
    if (_vx != 0) {
      cx += _vx * dt;
      _vx *= math.exp(-5 * dt);
      if (_vx.abs() < 3) _vx = 0;
      if (_clampX()) _vx = 0;
    }

    // Spin (scaleX = cos(spin) in the pose).
    if (_spinV > 0) {
      spin += _spinV * dt;
      if (spin >= 2 * math.pi) {
        spin = 0;
        _spinV = 0;
      }
    }

    // Play-dead roll.
    roll += (_rollTarget - roll) * math.min(1.0, dt * 6);

    // Springs.
    squash.step(dt);
    squash.value = squash.value.clamp(-0.3, 0.4);
    tilt.step(dt);
    lean.step(dt);
    // Ears hang down; head motion, jumps and the dryer make them swing.
    earL.target = tilt.value * 0.6 + (jump > 0 ? 0.35 : 0);
    earR.target = -tilt.value * 0.6 + (jump > 0 ? 0.35 : 0);
    earL.step(dt);
    earR.step(dt);
    earL.value = earL.value.clamp(-1.2, 1.2);
    earR.value = earR.value.clamp(-1.2, 1.2);
    pawR.step(dt);
    pawL.step(dt);

    // Tail: speed follows mood, decays toward the resting wag.
    final restWag = _asleep ? 0.8 : (reduceMotion ? 3.0 : 5.0);
    _tailTarget += (restWag - _tailTarget) * math.min(1.0, dt * 0.8);
    // Reduce Motion: happy moments wag a little faster, never a frantic blur.
    if (reduceMotion) _tailTarget = math.min(_tailTarget, 7.0);
    tailSpeed += (_tailTarget - tailSpeed) * math.min(1.0, dt * 4);
    tailPhase += tailSpeed * dt;

    // Ear-scratch back-leg thump.
    thump = _thumping ? (math.sin(time * 22) * 0.5 + 0.5) : math.max(0.0, thump - dt * 4);

    // Eyes follow the finger (or a friend), otherwise glance around.
    final follow = finger ?? _lookTarget;
    if (follow != null) {
      _glanceAt(follow, 0.4);
    } else if (time >= _nextGlance && !_asleep) {
      _nextGlance = time + 3 + _rng.nextDouble() * 4;
      if (_rng.nextDouble() < 0.4) {
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

    // Idle life: head tilt, sniff, or a little pant.
    if (!_asleep && !busy && _pointer == null && !_grooming && time >= _nextIdleAct) {
      _nextIdleAct = time + 6 + _rng.nextDouble() * 8;
      final pick = _rng.nextDouble();
      if (pick < 0.4) {
        tilt.vel += (_rng.nextBool() ? 1 : -1) * 3.2;
      } else if (pick < 0.7) {
        noseWiggle = 1;
      } else {
        _pantTimer = 2.5;
      }
    }

    // Blink.
    if (!_asleep) {
      if (_blinkT >= 0) {
        _blinkT += dt;
        blink = _blinkT < 0.07 ? _blinkT / 0.07 : math.max(0.0, 1 - (_blinkT - 0.07) / 0.08);
        if (_blinkT > 0.15) {
          _blinkT = -1;
          blink = 0;
        }
      } else if (time >= _nextBlink) {
        _blinkT = 0;
        _nextBlink = time + 2.5 + _rng.nextDouble() * 3.5;
      }
    } else {
      blink = 1;
    }

    // Mouth, tongue, nose.
    if (treatHover && !busy) _mouthTarget = 0.7;
    if (!busy && !treatHover && expr != WuffExpr.speak) _mouthTarget = 0;
    mouthOpen += (_mouthTarget - mouthOpen) * math.min(1.0, dt * 14);
    if (_pantTimer > 0) {
      _pantTimer -= dt;
      _tongueTarget = 1;
    } else if (!busy) {
      _tongueTarget = (expr == WuffExpr.happy || expr == WuffExpr.excited || expr == WuffExpr.proud) ? 0.7 : 0;
    }
    if (_asleep) _tongueTarget = 0;
    tongue += (_tongueTarget - tongue) * math.min(1.0, dt * 8);
    blep += (_blepTarget - blep) * math.min(1.0, dt * 10);
    noseWiggle = math.max(0.0, noseWiggle - dt * 1.6);
    blush = math.max(0.0, blush - dt * 0.25);

    // Expression timeout.
    if (_exprTimer < 1e8) {
      _exprTimer -= dt;
      if (_exprTimer <= 0 && expr != WuffExpr.idle && !_asleep) expr = WuffExpr.idle;
    }

    // Speech bubble.
    if (bubbleTimer > 0) {
      bubbleTimer -= dt;
      if (bubbleTimer <= 0) bubble = '';
    }

    // Sleep.
    if (_pointer == null && !busy && !treatHover && !_grooming) idleTime += dt;
    if (!_asleep && _pointer == null && !busy && !_grooming &&
        idleTime >= (night ? nightSleepAfter : idleSleepAfter) && expr == WuffExpr.idle) {
      _fallAsleep();
    }
    if (_asleep) {
      _zzzTimer += dt;
      if (_zzzTimer > 1.7) {
        _zzzTimer = 0;
        _burst(WuffParticleKind.zzz, _headRoom(head + Offset(r * 0.7, -r * 0.8)), 1, spread: 0.2);
      }
    }

    // Particles.
    for (final p in particles) {
      p.age += dt;
      switch (p.kind) {
        case WuffParticleKind.heart:
        case WuffParticleKind.zzz:
        case WuffParticleKind.note:
          p.vel = Offset(p.vel.dx * 0.97 + math.sin(p.age * 5 + p.spin) * 6, p.vel.dy * 0.985 - 12 * dt);
        case WuffParticleKind.sparkle:
        case WuffParticleKind.star:
        case WuffParticleKind.question:
          p.vel = p.vel * 0.94;
        case WuffParticleKind.crumb:
          p.vel = p.vel + Offset(0, 900 * dt);
        case WuffParticleKind.drop:
          p.vel = Offset(p.vel.dx * 0.98, p.vel.dy + 700 * dt);
      }
      p.pos = p.pos + p.vel * dt;
    }
    particles.removeWhere((p) => p.age >= p.life);
  }

  // ── screenshot / debug seams ──────────────────────────────────────────
  /// Keep an expression until something else happens.
  void holdExpression(WuffExpr e) => _setExpr(e, 1e9);

  /// Freeze mid-trick at [t] seconds.
  void poseTrick(String trickId, double t) {
    doTrick(trickId, success: true);
    update(t);
    _actionLen = 1e9;
  }
}
