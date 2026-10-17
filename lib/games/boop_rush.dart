/// Boop Rush rules: a 3x3 meadow of holes, critters pop up for a moment, boop
/// them before they duck back down.
///
/// Pure Dart (no Flutter, no timers, no I/O). Time is injected through
/// [BoopRushGame.update], randomness is seeded, and every spawn is decided at
/// its own scheduled time, so a round replays identically whatever the frame
/// rate. Ported from the Boop! prototype's `RushGame` with the household's
/// scoring: boop +1, golden +5, sleepy -1 (never below 0).
library;

import 'dart:collection';
import 'dart:math' as math;

/// What pops out of a hole.
enum RushKind { awake, sleepy, golden }

/// One critter currently out of its hole. Times are round seconds.
class RushPopup {
  const RushPopup({
    required this.serial,
    required this.kind,
    required this.critter,
    required this.bornAt,
    required this.lifetime,
  });

  /// Unique per spawn, so a view can key an animation to one appearance.
  final int serial;
  final RushKind kind;

  /// Which critter look to use, `0 <= critter < critterCount`.
  final int critter;
  final double bornAt;
  final double lifetime;

  double get diesAt => bornAt + lifetime;
}

enum RushEventType { spawn, boop, golden, sleepy, miss, expire, end }

/// Something the UI should react to (sound, float text, animation).
class RushEvent {
  const RushEvent(this.type, {this.cell = -1, this.kind, this.critter = 0, this.points = 0, this.streak = 0});
  final RushEventType type;
  final int cell;
  final RushKind? kind;
  final int critter;

  /// Signed score change this event caused (0 for spawn / miss / expire / end).
  final int points;
  final int streak;

  @override
  String toString() => 'RushEvent($type, cell: $cell, points: $points, streak: $streak)';
}

class BoopRushGame {
  BoopRushGame({this.seed = 1, this.duration = 30, this.critterCount = 3})
      : assert(duration > 0),
        assert(critterCount > 0),
        _rng = math.Random(seed) {
    _view = UnmodifiableListView(_slots);
  }

  static const cells = 9;
  static const goldenPoints = 5;
  static const boopPoints = 1;
  static const sleepyPenalty = 1;

  final int seed;
  final double duration;
  final int critterCount;
  final math.Random _rng;

  final List<RushPopup?> _slots = List<RushPopup?>.filled(cells, null);
  late final List<RushPopup?> _view;
  final List<RushEvent> _events = [];

  double _elapsed = 0;
  double _nextSpawn = 0.35;
  int _serial = 0;
  bool _ended = false;

  int score = 0;
  int streak = 0;
  int bestStreak = 0;

  /// Awake + golden critters booped (sleepy taps never count).
  int goodBoops = 0;

  /// Round seconds played so far.
  double get elapsed => _elapsed;
  double get timeLeft => math.max(0, duration - _elapsed);
  bool get finished => _elapsed >= duration;

  /// 0 at the start of the round, 1 at the end: drives the speed ramp.
  double get progress => (_elapsed / duration).clamp(0.0, 1.0);

  /// The critters currently out (index = cell). Read-only live view.
  List<RushPopup?> get slots => _view;

  int get liveCount {
    var n = 0;
    for (final p in _slots) {
      if (p != null) n++;
    }
    return n;
  }

  // The ramp, all functions of round progress `t` (0..1).
  static double spawnGapAt(double t) => 0.9 - 0.45 * t;
  static double lifetimeAt(double t) => 1.65 - 0.75 * t;
  static int maxLiveAt(double t) => 2 + (t * 2.5).floor(); // 2 -> 4

  /// Hands the UI what happened since the last call.
  List<RushEvent> drainEvents() {
    if (_events.isEmpty) return const [];
    final out = List<RushEvent>.of(_events);
    _events.clear();
    return out;
  }

  /// Advances the round by [dt] seconds: expires critters, spawns new ones.
  void update(double dt) {
    if (_ended || !dt.isFinite || dt <= 0) return;
    _elapsed = math.min(duration, _elapsed + dt);
    // Spawns are decided at their own scheduled instant, never at "now", so
    // a coarse frame gives the same round as a fine one.
    while (_nextSpawn <= _elapsed && _nextSpawn < duration) {
      _expire(_nextSpawn);
      _spawn(_nextSpawn);
      _nextSpawn += spawnGapAt(_nextSpawn / duration);
    }
    _expire(_elapsed);
    if (finished) {
      _ended = true;
      for (var i = 0; i < cells; i++) {
        _slots[i] = null;
      }
      _events.add(const RushEvent(RushEventType.end));
    }
  }

  void _expire(double at) {
    for (var i = 0; i < cells; i++) {
      final p = _slots[i];
      if (p != null && at >= p.diesAt) {
        _slots[i] = null;
        _events.add(RushEvent(RushEventType.expire, cell: i, kind: p.kind, critter: p.critter));
      }
    }
  }

  void _spawn(double at) {
    final t = (at / duration).clamp(0.0, 1.0);
    if (liveCount >= maxLiveAt(t)) return;
    var free = 0;
    for (final p in _slots) {
      if (p == null) free++;
    }
    if (free == 0) return;
    var pick = _rng.nextInt(free);
    var cell = 0;
    for (var i = 0; i < cells; i++) {
      if (_slots[i] != null) continue;
      if (pick == 0) {
        cell = i;
        break;
      }
      pick--;
    }
    final r = _rng.nextDouble();
    // Sleepy ones only after a 3 s grace so the first boops are all good ones.
    final kind = r < 0.07 ? RushKind.golden : (r < 0.25 && at > 3 ? RushKind.sleepy : RushKind.awake);
    final life = lifetimeAt(t) + (kind == RushKind.sleepy ? 0.3 : 0);
    final popup = RushPopup(
      serial: _serial++,
      kind: kind,
      critter: _rng.nextInt(critterCount),
      bornAt: at,
      lifetime: life,
    );
    _slots[cell] = popup;
    _events.add(RushEvent(RushEventType.spawn, cell: cell, kind: kind, critter: popup.critter));
  }

  /// A finger on [cell]. Returns the event it caused (also queued for the UI).
  RushEvent tap(int cell) {
    if (_ended || finished || cell < 0 || cell >= cells) return const RushEvent(RushEventType.miss);
    final p = _slots[cell];
    if (p == null) {
      final miss = RushEvent(RushEventType.miss, cell: cell, streak: streak);
      _events.add(miss);
      return miss;
    }
    _slots[cell] = null;
    final RushEvent e;
    if (p.kind == RushKind.sleepy) {
      final before = score;
      score = math.max(0, score - sleepyPenalty);
      streak = 0;
      e = RushEvent(RushEventType.sleepy, cell: cell, kind: p.kind, critter: p.critter, points: score - before);
    } else {
      streak++;
      bestStreak = math.max(bestStreak, streak);
      goodBoops++;
      final points = p.kind == RushKind.golden ? goldenPoints : boopPoints;
      score += points;
      e = RushEvent(
        p.kind == RushKind.golden ? RushEventType.golden : RushEventType.boop,
        cell: cell,
        kind: p.kind,
        critter: p.critter,
        points: points,
        streak: streak,
      );
    }
    _events.add(e);
    return e;
  }

  /// Test / replay hook: puts a critter in [cell] right now.
  RushPopup place(int cell, RushKind kind, {int critter = 0, double? lifetime}) {
    final popup = RushPopup(
      serial: _serial++,
      kind: kind,
      critter: critter % critterCount,
      bornAt: _elapsed,
      lifetime: lifetime ?? lifetimeAt(progress),
    );
    _slots[cell] = popup;
    _events.add(RushEvent(RushEventType.spawn, cell: cell, kind: kind, critter: popup.critter));
    return popup;
  }
}
