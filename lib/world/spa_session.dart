/// One friend's spa routine: Foam → Rinse → Towel → Dry → done.
///
/// Pure Dart. The spa overlay feeds it finger positions and speeds; it edits
/// the creature's [CareState] (foam, mud, wet, shine), tells the creature it
/// is being groomed, and reports progress and step changes.
library;

import 'dart:math' as math;
import 'dart:ui';

import '../creatures/creature.dart';

enum SpaStep { foam, rinse, towel, dry, done }

extension SpaStepTool on SpaStep {
  String get tool => switch (this) {
        SpaStep.foam => 'foam',
        SpaStep.rinse => 'water',
        SpaStep.towel => 'towel',
        SpaStep.dry => 'dryer',
        SpaStep.done => '',
      };
}

class SpaSession {
  SpaSession(this.creature, {int seed = 5}) : _rng = math.Random(seed) {
    creature.pinned = true;
    creature.care
      ..foam.clear()
      ..wet = 0
      ..shine = 0;
  }

  final Creature creature;
  final math.Random _rng;
  SpaStep step = SpaStep.foam;
  double progress = 0;
  static const foamTarget = 24;
  int _foamAtRinse = 0;
  double _dryAccum = 0;
  double _travel = 0;
  double _popTimer = 0;

  /// Sounds/haptics the UI should play this frame (ids from the sound bank).
  final List<String> cues = [];

  bool get finished => step == SpaStep.done;
  CareState get care => creature.care;

  bool _onBody(Offset p) => (p - creature.position).distance <= creature.radius * 1.3;

  /// The finger (holding the current step's tool) moved to [p] at [speed] px/s.
  void rub(Offset p, double speed, double dt) {
    if (finished || dt <= 0) return;
    final r = creature.radius;
    final c = creature.position;
    final onBody = _onBody(p);
    switch (step) {
      case SpaStep.foam:
        if (!onBody) return;
        creature.groom(p, speed, tool: 'foam');
        _travel += speed * dt;
        // Scrub mud away under the sponge.
        final before = care.mud.length;
        care.mud.removeWhere((m) => (c + m.at * r - p).distance < r * (m.radius + 0.25));
        if (care.mud.length < before) cues.add('spa.bubble');
        while (_travel > r * 0.9 && care.foam.length < foamTarget + 10) {
          _travel -= r * 0.9;
          final at = (p - c) / r + Offset((_rng.nextDouble() - 0.5) * 0.3, (_rng.nextDouble() - 0.5) * 0.3);
          final len = at.distance;
          final clamped = len > 1.1 ? at / len * 1.1 : at;
          care.foam.add(FoamBlob(clamped, 0.12 + _rng.nextDouble() * 0.1, _rng.nextDouble()));
        }
        progress = math.min(1, care.foam.length / foamTarget) * (care.mud.isEmpty ? 1 : 0.9);
        if (care.foam.length >= foamTarget && care.mud.isEmpty) _advance();
      case SpaStep.rinse:
        // Water rains down from the shower head at the finger.
        final stream = Rect.fromCenter(center: p + Offset(0, r * 0.6), width: r * 0.8, height: r * 1.6);
        var hit = false;
        for (final f in care.foam) {
          final fp = c + f.at * r;
          if (stream.inflate(r * f.radius).contains(fp)) {
            f.radius -= dt * 0.25;
            f.at = f.at + Offset(0, dt * 0.6); // foam slides down as it melts
            hit = true;
          }
        }
        care.foam.removeWhere((f) => f.radius < 0.04);
        if (stream.overlaps(Rect.fromCircle(center: c, radius: r))) {
          care.wet = math.min(1, care.wet + dt * 0.35);
          creature.groom(p + Offset(0, r * 0.5), speed, tool: 'water');
        }
        _popTimer += dt;
        if (hit && _popTimer > 0.25) {
          _popTimer = 0;
          cues.add('spa.bubble');
        }
        final foamLeft = _foamAtRinse == 0 ? 0.0 : care.foam.length / _foamAtRinse;
        progress = 0.6 * (1 - foamLeft) + 0.4 * care.wet;
        if (care.foam.isEmpty && care.wet >= 0.85) _advance();
      case SpaStep.towel:
        if (!onBody) return;
        creature.groom(p, speed, tool: 'towel');
        care.wet = math.max(0, care.wet - dt * (0.08 + speed / 2800));
        progress = 1 - care.wet;
        if (care.wet <= 0.03) {
          care.wet = 0;
          _advance();
        }
      case SpaStep.dry:
        if ((p - c).distance > r * 2.2) return;
        creature.groom(p, speed, tool: 'dryer');
        _dryAccum += dt * (0.06 + speed / 5000);
        progress = math.min(1, _dryAccum);
        if (_dryAccum >= 1) _advance();
      case SpaStep.done:
        break;
    }
  }

  void _advance() {
    step = SpaStep.values[step.index + 1];
    progress = 0;
    cues.add(step == SpaStep.done ? 'spa.done' : 'ui.pop');
    if (step == SpaStep.rinse) _foamAtRinse = care.foam.length;
    if (step == SpaStep.done) {
      care.shine = 1;
      creature.pinned = false;
      creature.celebrate();
    }
  }

  /// Leaving mid-routine: rinse everything off, unpin, no reward.
  void abandon() {
    care
      ..foam.clear()
      ..wet = 0;
    creature.pinned = false;
  }

  List<String> drainCues() {
    if (cues.isEmpty) return const [];
    final out = List<String>.of(cues);
    cues.clear();
    return out;
  }

  /// Shine fades slowly over a couple of minutes after the spa.
  static void fadeShine(Creature c, double dt) {
    if (c.care.shine > 0) c.care.shine = math.max(0, c.care.shine - dt / 150);
  }
}
