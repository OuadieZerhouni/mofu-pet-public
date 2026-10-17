/// The contract every species implements, so the house, the rooms and the
/// care tools can treat Mofu, Oink, Wuff and the Boops the same way.
///
/// A creature is two halves:
/// - a pure-Dart **simulation** ([Creature]) that owns physics, gestures,
///   expressions and its own particles, fed pointer events and `update(dt)`
///   in room coordinates, emitting [CreatureEvent]s;
/// - a **painter** ([CreatureArt]) that draws one simulation onto a canvas.
///
/// Rules every implementation keeps (tests in `test/creatures/contract_test.dart`):
/// - No Flutter widgets, no timers, no I/O in the simulation. `dart:ui` value
///   types (Offset, Size, Rect, Path) only. Seeded randomness.
/// - `update(dt)` must tolerate dt in 0..0.1 and never produce NaN positions.
/// - All gestures start with [pointerDown] returning whether the creature
///   claimed the pointer (hit-test inside [silhouette] plus a small margin).
/// - Events are drained once per frame by the room ([drainEvents]).
library;

import 'dart:ui' show Canvas, Offset, Path, Rect;

/// Every species in the house. Order = hatch order.
enum Species { mofu, oink, wuff, boop }

/// What a creature asks the app to do. Ids are species-scoped strings so the
/// sound bank and the journal can key on them (`'oink.snout'`, `'mofu.boing'`).
enum CreatureEventType {
  /// Play a one-shot: [CreatureEvent.id] = sound id, [CreatureEvent.value] = pitch (1 = normal).
  sound,

  /// Start/stop a loop (purr, brush, snore). [CreatureEvent.value] = gain 0..1.
  loopStart,
  loopStop,

  /// Haptic: id = `selection` | `light` | `medium` | `heavy` | `success`.
  haptic,

  /// A journal-worthy reaction happened for the first time or again: id = reaction id.
  reaction,

  /// Care progress worth persisting: id = `fluff` | `bond` | `combo` | `trick`, value = amount.
  progress,

  /// A short speech bubble (localisation key), e.g. `bubble.full`.
  bubble,

  /// The first-run coach step was satisfied: id = step id.
  coach,
}

class CreatureEvent {
  const CreatureEvent(this.type, [this.id = '', this.value = 0]);
  final CreatureEventType type;
  final String id;
  final double value;

  @override
  String toString() => 'CreatureEvent($type, $id, $value)';
}

/// Something another creature or the room did that this creature may react to.
enum SocialCue {
  /// A friend nearby is being touched (look at them, maybe jealous peek).
  friendTouched,

  /// A thrown friend landed on/near me.
  landedOnMe,

  /// A friend booped/nuzzled me.
  nuzzled,

  /// The room asks for a group reaction (celebration, hatch).
  celebrate,
}

/// Coarse life state every species has.
enum LifeState { awake, held, airborne, eating, asleep }

/// Care overlays painted on top of any species by the room (spa, garden).
/// Positions are relative to the creature centre, in units of its radius, so
/// they follow the body when it moves or squashes.
class CareState {
  /// 0 = dry, 1 = soaked (darker, flatter fur, droplets).
  double wet = 0;

  /// Foam blobs: (unit offset, unit radius, wobble phase).
  final List<FoamBlob> foam = [];

  /// Mud splats from the garden, removed by foam.
  final List<FoamBlob> mud = [];

  /// 0..1 post-spa shine (sparkles, glossy rim) that fades over minutes.
  double shine = 0;

  void reset() {
    wet = 0;
    foam.clear();
    mud.clear();
    shine = 0;
  }
}

class FoamBlob {
  FoamBlob(this.at, this.radius, this.phase);
  Offset at;
  double radius;
  double phase;
}

/// Where an accessory sits on this creature this frame.
enum AccessorySlot { head, face, neck }

/// Where a wardrobe item sits on any species.
AccessorySlot slotOf(String accessoryId) => switch (accessoryId) {
      'glasses' || 'shades' || 'monocle' => AccessorySlot.face,
      'scarf' || 'bandana' || 'bell' || 'bowtie' => AccessorySlot.neck,
      _ => AccessorySlot.head,
    };

class Anchor {
  const Anchor(this.at, this.scale, this.angle);
  final Offset at; // room coordinates
  final double scale; // 1 = sized for a creature of radius 92
  final double angle; // radians
}

abstract class Creature {
  Creature({required this.friendId, required this.seed});

  /// The household id of this friend (stable across launches).
  final String friendId;
  final int seed;

  Species get species;

  // ── placement ──────────────────────────────────────────────────────────
  /// Body centre in room coordinates.
  Offset get position;
  set position(Offset p);

  /// Body radius in logical px (the creature's size class).
  double get radius;

  /// Ground contact point (feet / bottom of body) for shadows and stacking.
  Offset get footPoint;

  /// Outline used for hit-testing and for clipping foam / wet overlays.
  Path get silhouette;

  /// Loose bounds (incl. fur, ears, tail) for separation and culling.
  Rect get bounds;

  /// Called when the room size changes. [floorY] = where feet rest; [area] =
  /// where the creature may move.
  void layout(Rect area, {required double floorY, double sizeScale = 1});

  // ── life ───────────────────────────────────────────────────────────────
  void update(double dt);
  LifeState get life;
  bool get asleep => life == LifeState.asleep;
  void sleep();
  void wake();
  bool reduceMotion = false;

  /// Night makes creatures sleepy sooner.
  bool night = false;

  // ── input (room coordinates) ──────────────────────────────────────────
  bool hitTest(Offset p);

  /// Returns true if this creature claimed the pointer.
  bool pointerDown(int pointer, Offset p);
  void pointerMove(int pointer, Offset p);
  void pointerUp(int pointer, Offset p);
  void pointerCancel(int pointer);
  int? get activePointer;

  // ── the rest of the world ─────────────────────────────────────────────
  /// Eyes follow this point (a finger, a friend, a toy); null = free look.
  void lookAt(Offset? target);

  /// Push from separation or a collision (px/s).
  void nudge(Offset impulse);
  void react(SocialCue cue, {Offset? from});
  void celebrate();

  /// The phone was shaken: every species reacts in its own way (dizzy, surprised, wobble).
  void shake() {
    if (asleep) wake();
    nudge(Offset(seed.isEven ? 220 : -220, 0));
  }

  // ── feeding ───────────────────────────────────────────────────────────
  Offset get mouth;
  bool nearMouth(Offset p);
  void setSnackHover(bool hovering, [Offset? at]);
  void eat({required bool favorite});
  void refuseFull();

  // ── care tools (spa) ──────────────────────────────────────────────────
  final CareState care = CareState();

  /// The spa holds the creature still (no hops, no pickup) while true.
  bool pinned = false;

  /// A tool is rubbing at [p] with speed [speed] px/s (foam, towel, dryer).
  /// Implementations wiggle/ squint/ giggle as their species does.
  void groom(Offset p, double speed, {required String tool});

  // ── accessories ───────────────────────────────────────────────────────
  Anchor anchor(AccessorySlot slot);

  // ── events ────────────────────────────────────────────────────────────
  List<CreatureEvent> drainEvents();
}

/// Draws one creature. Stateless: everything comes from the simulation and
/// the look (colour variant + accessory ids), so one painter instance can
/// draw many friends.
abstract class CreatureArt {
  const CreatureArt();

  /// [look.variant] is a species colour/coat id; [look.accessories] are
  /// catalogue ids drawn at [Creature.anchor] by the shared accessory painter.
  void paint(Canvas canvas, Creature c, CreatureLook look, {bool shadow = true});
}

class CreatureLook {
  const CreatureLook({required this.variant, this.accessories = const []});
  final String variant;
  final List<String> accessories;
}
