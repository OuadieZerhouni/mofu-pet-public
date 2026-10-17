/// Snack Catch rules: slide your friend left and right, catch the falling
/// snacks, dodge the bees.
///
/// Pure Dart, in normalised screen units (x and y both 0..1, y down), so the
/// rules run without a widget tree or a clock. Time comes in through
/// [SnackCatchGame.update], randomness is seeded. Ported from the Oink
/// prototype's `AppleCatchGame` with the household's rules: snack +1,
/// golden snack +3, bee -3 (never below 0) and a short stun in which the
/// catcher cannot catch anything.
library;

import 'dart:math' as math;

enum FallKind { snack, golden, bee }

class FallItem {
  FallItem({required this.serial, required this.kind, required this.snack, required this.x, required this.speed, this.y = -0.06});

  final int serial;
  final FallKind kind;

  /// Snack id from the friend's menu (empty for bees).
  final String snack;

  /// 0..1 across the screen.
  double x;

  /// 0..1 down the screen (centre of the item).
  double y;

  /// Screen heights per second.
  final double speed;
}

enum SnackEventType { caught, golden, stung, missed }

class SnackCatchEvent {
  const SnackCatchEvent(this.type, {required this.x, required this.y, this.points = 0, this.snack = ''});
  final SnackEventType type;

  /// Where it happened, in normalised screen units.
  final double x;
  final double y;

  /// Signed score change (a bee that hits at score 0 changes nothing).
  final int points;
  final String snack;

  @override
  String toString() => 'SnackCatchEvent($type, x: ${x.toStringAsFixed(2)}, points: $points)';
}

class SnackCatchGame {
  SnackCatchGame({
    required List<String> snacks,
    this.seed = 1,
    this.duration = 45,
    this.catchRadius = 0.12,
    this.catchY = 0.8,
    this.minX = 0.08,
    this.maxX = 0.92,
  })  : assert(snacks.isNotEmpty),
        assert(duration > 0),
        snacks = List.unmodifiable(snacks),
        _rng = math.Random(seed);

  static const snackPoints = 1;
  static const goldenPoints = 3;
  static const beePenalty = 3;
  static const stunSeconds = 1.0;

  /// No bees for the first seconds, so the round starts friendly.
  static const beeGrace = 2.0;

  /// A falling item is catchable while its centre is within this band
  /// around [catchY] (screen heights): a little above, a little below.
  static const bandAbove = 0.05;
  static const bandBelow = 0.03;

  final int seed;
  final double duration;
  final List<String> snacks;
  final math.Random _rng;

  /// Horizontal catch half-width, in screen widths.
  double catchRadius;

  /// Height of the mouth (screen heights): where catching happens.
  double catchY;

  /// The catcher can reach [minX]..[maxX]; snacks fall inside that range.
  double minX;
  double maxX;

  final List<FallItem> items = [];
  final List<SnackCatchEvent> _events = [];

  double _catcherX = 0.5;
  double _elapsed = 0;
  double _spawnIn = 0.5;
  double _stun = 0;
  int _serial = 0;

  int score = 0;
  int caught = 0;
  int stings = 0;
  int missedSnacks = 0;

  double get catcherX => _catcherX;
  set catcherX(double x) => _catcherX = x.isFinite ? x.clamp(minX, maxX).toDouble() : _catcherX;

  double get elapsed => _elapsed;
  double get timeLeft => math.max(0, duration - _elapsed);
  bool get finished => _elapsed >= duration;

  /// 0 at the start, 1 at the end.
  double get progress => (_elapsed / duration).clamp(0.0, 1.0);

  /// Seconds of stun left; the catcher catches nothing while > 0.
  double get stunLeft => _stun;
  bool get stunned => _stun > 0;

  // The ramp, all functions of round progress `t` (0..1).
  static double fallSpeedAt(double t) => 0.30 + 0.32 * t;
  static double spawnGapAt(double t) => 0.85 - 0.45 * t;
  static double beeChanceAt(double t) => 0.12 + 0.16 * t;

  /// Base fall speed right now (screen heights per second).
  double get fallSpeed => fallSpeedAt(progress);

  List<SnackCatchEvent> drainEvents() {
    if (_events.isEmpty) return const [];
    final out = List<SnackCatchEvent>.of(_events);
    _events.clear();
    return out;
  }

  /// Advances the round by [dt] seconds (in sub-steps, so a long frame can
  /// never let an item skip past the catch band).
  void update(double dt) {
    if (finished || !dt.isFinite || dt <= 0) return;
    final steps = math.max(1, (dt / 0.02).ceil());
    final h = dt / steps;
    for (var i = 0; i < steps && !finished; i++) {
      _step(h);
    }
  }

  void _step(double h) {
    _elapsed = math.min(duration, _elapsed + h);
    if (_stun > 0) _stun = math.max(0, _stun - h);
    _spawnIn -= h;
    if (_spawnIn <= 0 && _elapsed < duration) {
      _spawn();
      _spawnIn = spawnGapAt(progress) + _rng.nextDouble() * 0.25;
    }
    for (var i = items.length - 1; i >= 0; i--) {
      final it = items[i];
      it.y += it.speed * h;
      if (_inBand(it) && (it.x - _catcherX).abs() <= catchRadius && _stun <= 0) {
        items.removeAt(i);
        _caught(it);
      } else if (it.y > 1.08) {
        items.removeAt(i);
        if (it.kind != FallKind.bee) {
          missedSnacks++;
          _events.add(SnackCatchEvent(SnackEventType.missed, x: it.x, y: 1, snack: it.snack));
        }
      }
    }
    if (finished) items.clear();
  }

  bool _inBand(FallItem it) => it.y >= catchY - bandAbove && it.y <= catchY + bandBelow;

  void _caught(FallItem it) {
    switch (it.kind) {
      case FallKind.bee:
        final before = score;
        score = math.max(0, score - beePenalty);
        stings++;
        _stun = stunSeconds;
        _events.add(SnackCatchEvent(SnackEventType.stung, x: it.x, y: it.y, points: score - before));
      case FallKind.snack:
        score += snackPoints;
        caught++;
        _events.add(SnackCatchEvent(SnackEventType.caught, x: it.x, y: it.y, points: snackPoints, snack: it.snack));
      case FallKind.golden:
        score += goldenPoints;
        caught++;
        _events.add(SnackCatchEvent(SnackEventType.golden, x: it.x, y: it.y, points: goldenPoints, snack: it.snack));
    }
  }

  void _spawn() {
    final t = progress;
    final r = _rng.nextDouble();
    final beeChance = _elapsed < beeGrace ? 0.0 : beeChanceAt(t);
    final kind = r < beeChance ? FallKind.bee : (r < beeChance + 0.08 ? FallKind.golden : FallKind.snack);
    final x = minX + _rng.nextDouble() * (maxX - minX);
    final speed = fallSpeedAt(t) + _rng.nextDouble() * 0.06;
    final snack = kind == FallKind.bee ? '' : snacks[_rng.nextInt(snacks.length)];
    items.add(FallItem(serial: _serial++, kind: kind, snack: snack, x: x, speed: speed));
  }

  /// Test / replay hook: drops an item right now.
  FallItem drop(FallKind kind, double x, {String? snack, double y = -0.06, double? speed}) {
    final it = FallItem(
      serial: _serial++,
      kind: kind,
      snack: kind == FallKind.bee ? '' : (snack ?? snacks.first),
      x: x,
      speed: speed ?? fallSpeedAt(progress),
      y: y,
    );
    items.add(it);
    return it;
  }
}
