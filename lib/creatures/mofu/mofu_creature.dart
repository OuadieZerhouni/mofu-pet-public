/// Mofu (the fluff puff) behind the shared [Creature] interface.
///
/// The physics, fur and gestures live in [MofuSim] (the v1 simulation, kept
/// whole and unit-tested in `test/sim_test.dart`). This class adapts it:
/// room layout, pointer claiming, event ids prefixed `mofu.`, and the care /
/// social hooks the house needs.
library;

import 'dart:math' as math;
import 'dart:ui';

import '../../sim/mofu_sim.dart';
import '../creature.dart';

class MofuCreature extends Creature {
  MofuCreature({required super.friendId, required super.seed}) : sim = MofuSim(seed: seed);

  final MofuSim sim;

  /// Fluff level 0..1, fed from the household store.
  double get fluff => sim.fluff;
  set fluff(double v) => sim.fluff = v.clamp(0, 1);

  bool get brushMode => sim.brushMode;
  set brushMode(bool v) => sim.brushMode = v;

  @override
  Species get species => Species.mofu;

  @override
  Offset get position => sim.pos;

  @override
  set position(Offset p) => sim.pos = p;

  @override
  double get radius => sim.radius;

  @override
  Offset get footPoint => sim.pos + Offset(0, sim.radius);

  @override
  Path get silhouette => Path()..addOval(Rect.fromCircle(center: sim.pos, radius: sim.radius + sim.furLength * 0.6));

  @override
  Rect get bounds => Rect.fromCircle(center: sim.pos, radius: sim.radius + sim.furLength);

  @override
  void layout(Rect area, {required double floorY, double sizeScale = 1}) {
    sim.layout(Size(area.right, area.bottom), top: area.top, floor: floorY);
    // In a shared room Mofu is smaller than when it had the screen alone.
    sim.baseRadius = math.min(area.width * 0.17, 92) * sizeScale;
    if (sim.mode == MofuMode.rest) sim.pos = Offset(sim.pos.dx, floorY - sim.radius);
  }

  @override
  void update(double dt) {
    sim.reduceMotion = reduceMotion;
    sim.night = night;
    sim.pinned = pinned;
    sim.update(dt);
  }

  @override
  LifeState get life {
    if (sim.asleep) return LifeState.asleep;
    return switch (sim.mode) {
      MofuMode.held => LifeState.held,
      MofuMode.air => LifeState.airborne,
      MofuMode.rest => sim.expr == Expr.eating ? LifeState.eating : LifeState.awake,
    };
  }

  @override
  bool get asleep => sim.asleep;

  @override
  void sleep() => sim.sleepNow();

  @override
  void wake() => sim.wakeUp();

  @override
  bool hitTest(Offset p) => sim.hitBody(p);

  @override
  bool pointerDown(int pointer, Offset p) {
    if (sim.activePointer != null || !sim.hitBody(p)) return false;
    sim.pointerDown(pointer, p);
    return true;
  }

  @override
  void pointerMove(int pointer, Offset p) => sim.pointerMove(pointer, p);

  @override
  void pointerUp(int pointer, Offset p) => sim.pointerUp(pointer, p);

  @override
  void pointerCancel(int pointer) => sim.pointerCancel(pointer);

  @override
  int? get activePointer => sim.activePointer;

  @override
  void lookAt(Offset? target) => sim.lookTarget = target;

  @override
  void nudge(Offset impulse) => sim.nudge(impulse);

  @override
  void shiftX(double dx) => sim.nudge(Offset(dx * 60, 0));

  @override
  void react(SocialCue cue, {Offset? from}) => sim.socialCue(switch (cue) {
        SocialCue.friendTouched => 0,
        SocialCue.landedOnMe => 1,
        SocialCue.nuzzled => 2,
        SocialCue.celebrate => 3,
      }, from);

  @override
  void celebrate() => sim.celebrate();

  @override
  void shake() => sim.shake();

  @override
  Offset get mouth => sim.mouthPos;

  @override
  bool nearMouth(Offset p) => sim.nearMouth(p);

  @override
  void setSnackHover(bool hovering, [Offset? at]) => sim.setSnackHover(hovering, at);

  @override
  void eat({required bool favorite}) => sim.eat(favorite: favorite);

  @override
  void refuseFull() => sim.refuseFull();

  @override
  void groom(Offset p, double speed, {required String tool}) => sim.groom(p, speed, tool);

  @override
  Anchor anchor(AccessorySlot slot) {
    final r = sim.radius;
    final c = sim.pos;
    final u = r / 92;
    return switch (slot) {
      AccessorySlot.head => Anchor(Offset(c.dx, c.dy - r * 0.9 - sim.furLength * 0.15), u, sim.rot * 0.16),
      AccessorySlot.face => Anchor(c + Offset(0, -r * 0.06), u, sim.rot * 0.16),
      AccessorySlot.neck => Anchor(c + Offset(0, r * 0.62), u, sim.rot * 0.16),
    };
  }

  @override
  List<CreatureEvent> drainEvents() {
    final raw = sim.drainEvents();
    if (raw.isEmpty) return const [];
    final out = <CreatureEvent>[];
    for (final e in raw) {
      switch (e.type) {
        case SimEventType.sound:
          out.add(CreatureEvent(CreatureEventType.sound, 'mofu.${e.id}', e.value == 0 ? 1 : e.value));
        case SimEventType.loopStart:
          out.add(CreatureEvent(CreatureEventType.loopStart, 'mofu.${e.id}', 1));
        case SimEventType.loopStop:
          out.add(CreatureEvent(CreatureEventType.loopStop, 'mofu.${e.id}'));
        case SimEventType.haptic:
          out.add(CreatureEvent(CreatureEventType.haptic, e.id));
        case SimEventType.reaction:
          out.add(CreatureEvent(CreatureEventType.reaction, 'mofu.${e.id}'));
        case SimEventType.fluff:
          out.add(CreatureEvent(CreatureEventType.progress, 'fluff', e.value));
        case SimEventType.brushed:
          out.add(const CreatureEvent(CreatureEventType.progress, 'brushed', 1));
        case SimEventType.coach:
          out.add(const CreatureEvent(CreatureEventType.coach, 'pet'));
      }
    }
    return out;
  }
}
