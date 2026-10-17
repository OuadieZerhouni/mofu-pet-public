/// The live house: one [Creature] per friend, one [RoomScene] per room, the
/// active room ticking, and every creature event turned into sound, haptics,
/// journal entries, stars, friendship and speech bubbles.
///
/// Widgets render it and forward pointers; rooms (spa, kitchen…) call its
/// methods. No widget code in here, so the whole loop is testable.
library;

import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/foundation.dart';

import '../audio/audio_engine.dart';
import '../creatures/creature.dart';
import '../creatures/mofu/mofu_creature.dart';
import '../model/house_store.dart';
import 'creature_factory.dart';
import 'room_scene.dart';
import 'spa_session.dart';

enum Daypart { morning, day, evening, night }

Daypart daypartFor(DateTime t) {
  final h = t.hour;
  if (h >= 22 || h < 6) return Daypart.night;
  if (h < 10) return Daypart.morning;
  if (h < 18) return Daypart.day;
  return Daypart.evening;
}

/// A short line shown above a friend.
class Bubble {
  Bubble(this.friendId, this.key, this.until);
  final String friendId;
  final String key;
  final double until;
}

/// Something the UI should announce once (toast).
class HouseNotice {
  const HouseNotice(this.kind, [this.a = '', this.b = '', this.amount = 0]);
  final String kind; // discovered | stars | levelUp | eggReady | fluffMilestone
  final String a;
  final String b;
  final int amount;
}

class HouseController extends ChangeNotifier {
  HouseController({required this.store, AudioEngine? audio, DateTime Function()? clock})
      : audio = audio ?? AudioEngine.instance,
        clock = clock ?? DateTime.now {
    for (final r in Room.values) {
      scenes[r] = RoomScene(seed: r.index + 3)..socialIdle = r == Room.living || r == Room.garden || r == Room.playroom;
    }
    // The hatchery nest sits mid-garden: friends play either side of it.
    scenes[Room.garden]!.keepOut = const [(0.36, 0.64)];
    sync();
  }

  final HouseStore store;
  final AudioEngine audio;
  final DateTime Function() clock;

  final Map<String, Creature> creatures = {};
  final Map<Room, RoomScene> scenes = {};
  final List<Bubble> bubbles = [];
  final List<HouseNotice> notices = [];
  Room active = Room.living;

  /// The friend last touched in each room (kitchen menus, spa mat).
  final Map<Room, String> lastTouched = {};
  Daypart daypart = Daypart.day;
  final math.Random _rng = math.Random(7);
  double _time = 0;
  double _lastDayCheck = -100;
  bool _eggAnnounced = false;

  RoomScene get scene => scenes[active]!;
  double get time => _time;

  Creature? creature(String friendId) => creatures[friendId];

  CreatureLook lookFor(Friend f) => CreatureLook(
        variant: f.variant,
        accessories: [
          for (final slot in const ['head', 'face', 'neck'])
            if (f.wear[slot] != null) f.wear[slot]!,
        ],
      );

  // ── keeping creatures in step with the store ──────────────────────────
  void sync() {
    for (final f in store.friends) {
      final c = creatures.putIfAbsent(f.id, () => makeCreature(f));
      if (c is MofuCreature) c.fluff = f.fluff / 100;
      for (final entry in scenes.entries) {
        final there = entry.value.creatures.contains(c);
        if (f.room == entry.key && !there) {
          entry.value.add(c);
        } else if (f.room != entry.key && there) {
          entry.value.remove(c);
          audio.stopAllLoops(prefix: '${f.id}/');
        }
      }
    }
    final ids = store.friends.map((f) => f.id).toSet();
    for (final gone in creatures.keys.where((id) => !ids.contains(id)).toList()) {
      final c = creatures.remove(gone)!;
      for (final s in scenes.values) {
        s.remove(c);
      }
    }
    notifyListeners();
  }

  /// Lays every room out with its own floor line (each room's shelf has its
  /// own height, so each floor sits just above its own shelf).
  void layoutRooms({required double top, required double width, required double Function(Room) floorFor, double sizeScale = 1}) {
    for (final e in scenes.entries) {
      final floor = floorFor(e.key);
      e.value.layout(Rect.fromLTWH(0, top, width, floor - top), floorY: floor, sizeScale: sizeScale);
    }
  }

  void setActive(Room r) {
    if (r == active) return;
    // Loops belong to the room you are in.
    for (final c in scene.creatures) {
      audio.stopAllLoops(prefix: '${c.friendId}/');
    }
    active = r;
    store.setRoom(r);
    notifyListeners();
  }

  /// Moves a friend between rooms (friend bar drag). False when full.
  bool moveFriend(String friendId, Room? to) {
    if (!store.moveTo(friendId, to)) return false;
    sync();
    return true;
  }

  // ── input from the room view ──────────────────────────────────────────
  Creature? pointerDown(int pointer, Offset p) {
    final c = scene.pointerDown(pointer, p);
    if (c != null) {
      lastTouched[active] = c.friendId;
      // Garden play gets friends a little muddy — the spa washes it off.
      if (active == Room.garden && c.care.mud.length < 4 && _rng.nextDouble() < 0.35) {
        final a = _rng.nextDouble() * math.pi * 2;
        final d = 0.2 + _rng.nextDouble() * 0.5;
        c.care.mud.add(FoamBlob(Offset(math.cos(a) * d, math.sin(a) * d * 0.8 + 0.2), 0.1 + _rng.nextDouble() * 0.08, 0));
      }
    }
    if (c != null && store.registerTouch(c.friendId)) {
      notices.add(const HouseNotice('stars', 'touch', '', 1));
    }
    return c;
  }

  void pointerMove(int pointer, Offset p) => scene.pointerMove(pointer, p);
  void pointerUp(int pointer, Offset p) => scene.pointerUp(pointer, p);
  void pointerCancel(int pointer) => scene.pointerCancel(pointer);

  // ── the loop ──────────────────────────────────────────────────────────
  void tick(double dt) {
    _time += dt;
    if (_time - _lastDayCheck > 30) {
      _lastDayCheck = _time;
      final d = daypartFor(clock());
      if (d != daypart) {
        daypart = d;
        notifyListeners();
      }
      for (final s in scenes.values) {
        s.night = daypart == Daypart.night;
      }
    }
    final s = scene;
    s.reduceMotion = store.reduceMotion;
    s.update(dt);
    for (final c in s.creatures) {
      SpaSession.fadeShine(c, dt);
    }
    for (final e in s.drainEvents()) {
      _handle(e);
    }
    for (final m in s.drainMoments()) {
      final id = m.$1 == GroupMoment.pileUp ? 'house.pileUp' : 'house.nuzzle';
      if (store.discover(id)) notices.add(HouseNotice('discovered', id));
    }
    bubbles.removeWhere((b) => b.until < _time);
    if (store.eggReady && !_eggAnnounced) {
      _eggAnnounced = true;
      notices.add(const HouseNotice('eggReady'));
    } else if (!store.eggReady) {
      _eggAnnounced = false;
    }
  }

  void say(String friendId, String key, {double seconds = 1.8}) {
    bubbles.removeWhere((b) => b.friendId == friendId);
    bubbles.add(Bubble(friendId, key, _time + seconds));
  }

  void _handle(SceneEvent se) {
    final e = se.event;
    final id = se.friendId;
    switch (e.type) {
      case CreatureEventType.sound:
        audio.play(e.id, pitch: e.value <= 0 ? 1 : e.value);
      case CreatureEventType.loopStart:
        audio.loopStart('$id/${e.id}', e.id, gain: e.value <= 0 ? 1 : math.min(1, e.value * 2));
      case CreatureEventType.loopStop:
        audio.loopStop('$id/${e.id}');
      case CreatureEventType.haptic:
        audio.haptic(e.id);
      case CreatureEventType.reaction:
        if (store.discover(e.id)) {
          notices.add(HouseNotice('discovered', e.id, id));
          audio.play('ui.sparkle', gain: 0.6);
        }
      case CreatureEventType.progress:
        _progress(id, e.id, e.value);
      case CreatureEventType.bubble:
        say(id, e.id);
      case CreatureEventType.coach:
        store.completeCoach(e.id.isEmpty ? 'pet' : e.id);
    }
  }

  void _progress(String friendId, String kind, double value) {
    switch (kind) {
      case 'fluff':
        final f = store.friend(friendId);
        if (f == null) return;
        final before = f.fluff;
        store.addFluff(friendId, value);
        final c = creatures[friendId];
        if (c is MofuCreature) c.fluff = f.fluff / 100;
        for (final m in const [25, 50, 75, 100]) {
          if (before < m && f.fluff >= m) {
            notices.add(HouseNotice('fluffMilestone', friendId, '', m));
            c?.celebrate();
            audio.play('ui.fanfare', gain: 0.7);
          }
        }
      case 'bond':
        final lvl = store.addXp(friendId, value.round().clamp(1, 5));
        if (lvl != null) {
          notices.add(HouseNotice('levelUp', friendId, '', lvl));
          creatures[friendId]?.celebrate();
          audio.play('ui.unlock');
        }
      case 'combo':
        store.recordCombo(value.round());
      case 'trick':
        final lvl = store.addXp(friendId, 2);
        if (lvl != null) notices.add(HouseNotice('levelUp', friendId, '', lvl));
      default:
        break;
    }
  }

  List<HouseNotice> drainNotices() {
    if (notices.isEmpty) return const [];
    final out = List<HouseNotice>.of(notices);
    notices.clear();
    return out;
  }

  /// Everyone in the bedroom curls up; leaving the bedroom wakes them gently.
  void bedtime(bool on) {
    final s = scenes[Room.bedroom]!;
    if (on) {
      s.sleepAll();
    } else {
      s.wakeAll();
    }
  }

  @override
  void dispose() {
    audio.stopAllLoops();
    super.dispose();
  }
}
