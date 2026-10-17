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
  final Map<Creature, LifeState> _lastLife = {};
  double _time = 0;
  double _nextNuzzle = 6;
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
  }

  Creature? byId(String friendId) => creatures.where((c) => c.friendId == friendId).firstOrNull;

  /// Spreads friends evenly when they arrive so nobody spawns inside another.
  double _freeSpotX(Creature c) {
    final n = creatures.length;
    if (n <= 1) return area.center.dx;
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
    }
    _separate(dt);
    _keepInside();
    _keepClear();
    _landings();
    if (socialIdle && !reduceMotion) _idleSocial();
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
        final minGap = (a.bounds.width + b.bounds.width) * 0.5 * 0.82;
        final overlap = minGap - dx.abs();
        if (overlap <= 0) continue;
        final dir = dx == 0 ? (i.isEven ? 1.0 : -1.0) : dx.sign;
        final push = overlap * 6; // px/s per px of overlap
        if (!a.pinned) a.nudge(Offset(-dir * push, 0));
        if (!b.pinned) b.nudge(Offset(dir * push, 0));
      }
    }
  }

  /// Ears and tails stay on screen: a soft wall push on the visual bounds.
  void _keepInside() {
    for (final c in creatures) {
      if (!_grounded(c) || c.pinned) continue;
      final b = c.bounds;
      if (b.left < area.left) c.nudge(Offset((area.left - b.left) * 8, 0));
      if (b.right > area.right) c.nudge(Offset(-(b.right - area.right) * 8, 0));
    }
  }

  void _keepClear() {
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
        c.nudge(Offset((toLeft < toRight ? -1 : 1) * 900, 0));
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
