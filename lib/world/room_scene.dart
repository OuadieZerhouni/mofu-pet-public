/// Several creatures sharing one room: pointer routing, soft separation,
/// "who is looking at whom", landings on each other, idle nuzzles, and a
/// single event stream tagged with the friend id. Pure Dart (no widgets),
/// so every group behaviour is unit-tested in `test/world/room_scene_test.dart`.
library;

import 'dart:math' as math;
import 'dart:ui';

import '../creatures/creature.dart';

class SceneEvent {
  const SceneEvent(this.friendId, this.event);
  final String friendId;
  final CreatureEvent event;

  @override
  String toString() => 'SceneEvent($friendId, $event)';
}

/// Group moments the room reports alongside creature events.
enum GroupMoment { pileUp, nuzzle }

class RoomScene {
  RoomScene({int seed = 11}) : _rng = math.Random(seed);

  final math.Random _rng;
  final List<Creature> creatures = [];
  final List<SceneEvent> events = [];
  final List<(GroupMoment, String, String)> moments = [];

  Rect area = const Rect.fromLTWH(0, 0, 390, 700);
  double floorY = 560;
  double sizeScale = 1;
  bool night = false;
  bool reduceMotion = false;

  /// When false (spa, kitchen) idle friends do not nuzzle each other.
  bool socialIdle = true;

  /// Horizontal floor spans (as fractions of the room width) friends keep
  /// clear of, e.g. the garden nest.
  List<(double, double)> keepOut = const [];

  final Map<int, Creature> _owners = {};

  /// Each friend's resting width: rises slowly, falls at once, so a momentary
  /// burst (fur boing, a stretch, a jump pose) never shoves the neighbours.
  final Map<Creature, double> _restW = {};
  double restWidth(Creature c) => _restW[c] ?? c.bounds.width;

  /// Fastest a friend is pushed aside, px/s: a nudge you see, never a jolt.
  static const maxPush = 140.0;
  final Map<Creature, LifeState> _lastLife = {};
  double _time = 0;
  double _nextNuzzle = 6;
  (Creature, Creature)? _gazePair;
  double _gazeEnds = 0;
  double _touchCueCooldown = 0;

  double get time => _time;

  // ── membership ────────────────────────────────────────────────────────
  /// Friends shrink as the room fills so everyone still fits side by side.
  /// Measured from their real visual widths, so it holds on every screen.
  double get crowdScale => _crowd;
  double _crowd = 1;

  void _relayoutAll() {
    final xs = {for (final c in creatures) c: c.position.dx};
    for (final c in creatures) {
      c.layout(area, floorY: floorY, sizeScale: sizeScale);
    }
    _crowd = 1;
    if (creatures.length > 1) {
      final total = creatures.fold<double>(0, (s, c) => s + c.bounds.width);
      // Neighbours may overlap 18% (see _separate), plus a little wall slack.
      // Floor kept clear (the garden nest) is not standing room.
      final usable = area.width * (1 - keepOut.fold<double>(0, (s, k) => s + (k.$2 - k.$1)));
      _crowd = math.min(1.0, usable * 0.96 / (total * 0.86));
      if (_crowd < 1) {
        for (final c in creatures) {
          c.layout(area, floorY: floorY, sizeScale: sizeScale * _crowd);
        }
      }
    }
    for (final c in creatures) {
      _restW[c] = c.bounds.width;
      final half = c.bounds.width / 2;
      final x = xs[c]!;
      c.position = Offset(x.clamp(area.left + half, math.max(area.left + half, area.right - half)).toDouble(), c.position.dy);
    }
  }

  void add(Creature c, {double? atX}) {
    if (creatures.contains(c)) return;
    creatures.add(c);
    _relayoutAll();
    final x = atX ?? _freeSpotX(c);
    final half = c.bounds.width / 2;
    c.position = Offset(x.clamp(area.left + half, math.max(area.left + half, area.right - half)).toDouble(), c.position.dy);
    _lastLife[c] = c.life;
  }

  void remove(Creature c) {
    if (!creatures.remove(c)) return;
    _relayoutAll();
    _owners.removeWhere((_, v) => v == c);
    _lastLife.remove(c);
    _restW.remove(c);
  }

  Creature? byId(String friendId) => creatures.where((c) => c.friendId == friendId).firstOrNull;

  /// Spreads friends evenly when they arrive so nobody spawns inside another.
  double _freeSpotX(Creature c) {
    final n = creatures.length;
    if (n <= 1 && keepOut.isEmpty) return area.center.dx;
    final slots = [
      for (var i = 0; i < 6; i++) area.left + area.width * (i + 0.5) / 6,
    ]..removeWhere((x) => keepOut.any((k) => x > area.left + k.$1 * area.width - 30 && x < area.left + k.$2 * area.width + 30));
    if (slots.isEmpty) return area.center.dx;
    final taken = creatures.where((o) => o != c).map((o) => o.position.dx).toList();
    slots.sort((a, b) {
      double gap(double x) => taken.isEmpty ? 1e9 : taken.map((t) => (t - x).abs()).reduce(math.min);
      return gap(b).compareTo(gap(a));
    });
    return slots.first;
  }

  void layout(Rect area, {required double floorY, double sizeScale = 1}) {
    // The screen relays out on every rebuild; an unchanged room must not reset creatures
    // (Oink's layout ends its walk).
    if (area == this.area && floorY == this.floorY && sizeScale == this.sizeScale) return;
    final old = this.area;
    this.area = area;
    this.floorY = floorY;
    this.sizeScale = sizeScale;
    if ((area.width - old.width).abs() > 1 && old.width > 1) {
      for (final c in creatures) {
        c.position = Offset(area.left + (c.position.dx - old.left) / old.width * area.width, c.position.dy);
      }
    }
    _relayoutAll();
  }

  // ── input ─────────────────────────────────────────────────────────────
  /// Front-most (lowest on screen, i.e. nearest) creature under [p] claims it.
  Creature? pointerDown(int pointer, Offset p) {
    for (final c in paintOrder.reversed) {
      if (c.pointerDown(pointer, p)) {
        _owners[pointer] = c;
        _touched(c);
        return c;
      }
    }
    return null;
  }

  void pointerMove(int pointer, Offset p) => _owners[pointer]?.pointerMove(pointer, p);

  void pointerUp(int pointer, Offset p) {
    final c = _owners.remove(pointer);
    c?.pointerUp(pointer, p);
    for (final o in creatures) {
      if (o != c) o.lookAt(null);
    }
  }

  void pointerCancel(int pointer) {
    final c = _owners.remove(pointer);
    c?.pointerCancel(pointer);
    for (final o in creatures) {
      if (o != c) o.lookAt(null);
    }
  }

  void _touched(Creature c) {
    for (final o in creatures) {
      if (o == c) continue;
      o.lookAt(c.position);
      if (_touchCueCooldown <= 0 && !o.asleep) o.react(SocialCue.friendTouched, from: c.position);
    }
    _touchCueCooldown = 2.5;
  }

  // ── simulation ────────────────────────────────────────────────────────
  void update(double dt) {
    if (dt <= 0) return;
    dt = math.min(dt, 0.1);
    _time += dt;
    _touchCueCooldown -= dt;
    for (final c in creatures) {
      c.night = night;
      c.reduceMotion = reduceMotion;
      c.update(dt);
      final w = c.bounds.width;
      final prev = _restW[c] ?? w;
      _restW[c] = w < prev ? w : prev + (w - prev) * math.min(1.0, dt * 0.8);
    }
    _separate(dt);
    _keepInside(dt);
    _keepClear(dt);
    _landings();
    if (socialIdle && !reduceMotion) _idleSocial();
    final pair = _gazePair;
    if (pair != null && _time >= _gazeEnds) {
      _gazePair = null;
      for (final c in [pair.$1, pair.$2]) {
        if (c.activePointer == null) c.lookAt(null);
      }
    }
    for (final c in creatures) {
      for (final e in c.drainEvents()) {
        events.add(SceneEvent(c.friendId, e));
      }
    }
  }

  bool _grounded(Creature c) => c.life == LifeState.awake || c.life == LifeState.eating || c.life == LifeState.asleep;

  /// Friends standing side by side push apart gently instead of overlapping.
  void _separate(double dt) {
    for (var i = 0; i < creatures.length; i++) {
      for (var j = i + 1; j < creatures.length; j++) {
        final a = creatures[i], b = creatures[j];
        if (!_grounded(a) || !_grounded(b)) continue;
        final dx = b.position.dx - a.position.dx;
        // Visual widths (ears, fur, tails) — not just the body — so faces never hide.
        final minGap = (restWidth(a) + restWidth(b)) * 0.5 * 0.82;
        final overlap = minGap - dx.abs();
        if (overlap <= 0) continue;
        final dir = dx == 0 ? (i.isEven ? 1.0 : -1.0) : dx.sign;
        // A gentle slide, capped: never a velocity kick (species' nudge semantics differ).
        final push = math.min(overlap * 6, maxPush) * dt;
        if (!a.pinned) a.shiftX(-dir * push);
        if (!b.pinned) b.shiftX(dir * push);
      }
    }
  }

  /// Ears and tails stay on screen: a soft wall push on the visual bounds.
  void _keepInside(double dt) {
    for (final c in creatures) {
      if (!_grounded(c) || c.pinned) continue;
      final half = restWidth(c) / 2;
      final left = c.position.dx - half, right = c.position.dx + half;
      if (left < area.left) c.shiftX(math.min((area.left - left) * 8, maxPush) * dt);
      if (right > area.right) c.shiftX(-math.min((right - area.right) * 8, maxPush) * dt);
    }
  }

  /// Resolves overlaps instantly (no visible shuffle): for placing friends
  /// before the first frame, e.g. when the house loads.
  void settle() {
    for (var it = 0; it < 40; it++) {
      var moved = false;
      final sorted = List<Creature>.of(creatures)..sort((a, b) => a.position.dx.compareTo(b.position.dx));
      for (var i = 0; i + 1 < sorted.length; i++) {
        final a = sorted[i], b = sorted[i + 1];
        final overlap = (restWidth(a) + restWidth(b)) * 0.5 * 0.82 - (b.position.dx - a.position.dx);
        if (overlap <= 0.5) continue;
        moved = true;
        a.position = Offset(a.position.dx - overlap / 2, a.position.dy);
        b.position = Offset(b.position.dx + overlap / 2, b.position.dy);
      }
      for (final c in creatures) {
        final half = restWidth(c) / 2;
        var x = c.position.dx.clamp(area.left + half, math.max(area.left + half, area.right - half)).toDouble();
        // Off kept-clear floor (the garden nest), to the nearer side.
        for (final (lo, hi) in keepOut) {
          final a = area.left + lo * area.width - restWidth(c) * 0.42;
          final b = area.left + hi * area.width + restWidth(c) * 0.42;
          if (x > a && x < b) x = (x - a < b - x) ? a : b;
        }
        if (x != c.position.dx) {
          c.position = Offset(x, c.position.dy);
          moved = true;
        }
      }
      if (!moved) break;
    }
  }

  void _keepClear(double dt) {
    if (keepOut.isEmpty) return;
    for (final c in creatures) {
      if (!_grounded(c) || c.pinned) continue;
      final half = c.bounds.width * 0.42;
      for (final (lo, hi) in keepOut) {
        final a = area.left + lo * area.width - half;
        final b = area.left + hi * area.width + half;
        final x = c.position.dx;
        if (x <= a || x >= b) continue;
        final toLeft = x - a, toRight = b - x;
        c.shiftX((toLeft < toRight ? -1 : 1) * maxPush * 1.5 * dt);
      }
    }
  }

  /// A thrown friend coming down on (or right next to) another one.
  void _landings() {
    for (final c in creatures) {
      final before = _lastLife[c];
      final now = c.life;
      _lastLife[c] = now;
      if (before != LifeState.airborne || now == LifeState.airborne || now == LifeState.held) continue;
      for (final o in creatures) {
        if (o == c) continue;
        final close = (o.position.dx - c.position.dx).abs() < (o.radius + c.radius) * 1.05;
        if (!close) continue;
        o.react(SocialCue.landedOnMe, from: c.position);
        moments.add((GroupMoment.pileUp, c.friendId, o.friendId));
      }
    }
  }

  void _idleSocial() {
    if (_time < _nextNuzzle) return;
    _nextNuzzle = _time + 8 + _rng.nextDouble() * 9;
    final awake = creatures.where((c) => c.life == LifeState.awake && c.activePointer == null && !c.pinned).toList();
    if (awake.length < 2) return;
    final a = awake[_rng.nextInt(awake.length)];
    awake.sort((x, y) => (x.position.dx - a.position.dx).abs().compareTo((y.position.dx - a.position.dx).abs()));
    final b = awake[1];
    if ((b.position.dx - a.position.dx).abs() > (a.radius + b.radius) * 2.2) return;
    a.lookAt(b.position);
    b.lookAt(a.position);
    _gazePair = (a, b);
    _gazeEnds = _time + 1.8;
    b.react(SocialCue.nuzzled, from: a.position);
    moments.add((GroupMoment.nuzzle, a.friendId, b.friendId));
  }

  /// Drop the current gaze targets (after a nuzzle settles, or a room change).
  void clearGaze() {
    for (final c in creatures) {
      c.lookAt(null);
    }
  }

  void sleepAll() {
    for (final c in creatures) {
      c.sleep();
    }
  }

  void wakeAll() {
    for (final c in creatures) {
      c.wake();
    }
  }

  List<SceneEvent> drainEvents() {
    if (events.isEmpty) return const [];
    final out = List<SceneEvent>.of(events);
    events.clear();
    return out;
  }

  List<(GroupMoment, String, String)> drainMoments() {
    if (moments.isEmpty) return const [];
    final out = List.of(moments);
    moments.clear();
    return out;
  }

  /// Back to front: higher on screen first, the held/airborne friend last.
  List<Creature> get paintOrder {
    final list = List<Creature>.of(creatures);
    list.sort((a, b) {
      int lift(Creature c) => c.life == LifeState.held || c.life == LifeState.airborne ? 1 : 0;
      final l = lift(a).compareTo(lift(b));
      if (l != 0) return l;
      return a.footPoint.dy.compareTo(b.footPoint.dy);
    });
    return list;
  }
}
