/// Everything the household remembers: friends, stars, friendship, unlocks,
/// rooms, sleep sounds and settings. One JSON blob in SharedPreferences
/// (`mofu.house.v2`), saved debounced, loaded field by field so a damaged
/// value only loses itself. Migrates the v1 single-Mofu blob on first load.
///
/// Calm by design: stars are a lifetime total (never spent, never lost),
/// nothing decays, daily caps keep earning gentle.
library;

import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart' show StringCharacters;
import 'package:shared_preferences/shared_preferences.dart';

import '../creatures/creature.dart';

enum Room { living, spa, kitchen, bedroom, playroom, garden }

/// Why stars were earned; each source has its own daily cap.
enum StarSource { firstTouch, spa, favoriteSnack, boopRush, snackCatch, gift, hatch }

class Friend {
  Friend({
    required this.id,
    required this.species,
    required this.name,
    required this.variant,
    required this.hatchedDay,
  });

  final String id;
  final Species species;
  String name;
  String variant;
  final String hatchedDay;

  /// slot name → accessory id.
  final Map<String, String> wear = {};
  int xp = 0;
  double fluff = 8; // Mofu only, 0..100
  String lastTouchDay = '';
  String lastSpaDay = '';
  final List<int> recentSnacks = []; // epoch ms
  final Set<String> tricks = {}; // Wuff: mastered trick ids
  final Map<String, int> trickPractice = {}; // trick id → practice days
  final Map<String, String> trickLastDay = {};
  Room? room = Room.living;

  int get level => HouseStore.levelForXp(xp);

  Map<String, dynamic> toJson() => {
        'id': id,
        'species': species.name,
        'name': name,
        'variant': variant,
        'hatched': hatchedDay,
        'wear': wear,
        'xp': xp,
        'fluff': double.parse(fluff.toStringAsFixed(2)),
        'touch': lastTouchDay,
        'spa': lastSpaDay,
        'snacks': recentSnacks,
        'tricks': tricks.toList()..sort(),
        'practice': trickPractice,
        'practiceDay': trickLastDay,
        'room': room?.name,
      };

  static Friend? fromJson(Object? raw) {
    if (raw is! Map) return null;
    T pick<T>(Object? v, T fallback) => v is T ? v : fallback;
    final species = Species.values.where((s) => s.name == raw['species']).firstOrNull;
    final id = pick<String>(raw['id'], '');
    if (species == null || id.isEmpty) return null;
    final f = Friend(
      id: id,
      species: species,
      name: HouseStore.sanitizeName(pick<String>(raw['name'], ''), fallback: HouseStore.defaultName(species)),
      variant: pick<String>(raw['variant'], HouseStore.defaultVariant(species)),
      hatchedDay: pick<String>(raw['hatched'], ''),
    );
    final wear = raw['wear'];
    if (wear is Map) {
      for (final e in wear.entries) {
        if (e.key is String && e.value is String) f.wear[e.key as String] = e.value as String;
      }
    }
    f.xp = pick<int>(raw['xp'], 0).clamp(0, 1 << 30);
    f.fluff = pick<num>(raw['fluff'], 8).toDouble().clamp(0, 100).toDouble();
    f.lastTouchDay = pick<String>(raw['touch'], '');
    f.lastSpaDay = pick<String>(raw['spa'], '');
    final snacks = raw['snacks'];
    if (snacks is List) f.recentSnacks.addAll(snacks.whereType<int>());
    final tricks = raw['tricks'];
    if (tricks is List) f.tricks.addAll(tricks.whereType<String>());
    final practice = raw['practice'];
    if (practice is Map) {
      for (final e in practice.entries) {
        if (e.key is String && e.value is int) f.trickPractice[e.key as String] = e.value as int;
      }
    }
    final practiceDay = raw['practiceDay'];
    if (practiceDay is Map) {
      for (final e in practiceDay.entries) {
        if (e.key is String && e.value is String) f.trickLastDay[e.key as String] = e.value as String;
      }
    }
    final room = raw['room'];
    f.room = room is String ? Room.values.where((r) => r.name == room).firstOrNull : null;
    return f;
  }
}

/// One step of the hatch schedule: an egg of [species] ([variant] for Boops)
/// becomes available when lifetime stars reach [stars].
class EggStep {
  const EggStep(this.species, this.variant, this.stars);
  final Species species;
  final String variant;
  final int stars;
}

enum FeedOutcome { eaten, favorite, full }

class HouseStore extends ChangeNotifier {
  HouseStore({DateTime Function()? clock}) : _clock = clock ?? DateTime.now;

  static const prefsKey = 'mofu.house.v2';
  static const legacyKey = 'mofu.state.v1';
  static const maxNameLength = 16;
  static const maxFriendsPerRoom = 4;
  static const snacksPerHour = 6;

  /// Friendship level thresholds (xp to reach level index+1). Level 10 max.
  static const levelXp = [0, 20, 50, 90, 140, 200, 270, 350, 440, 540];

  /// Daily star caps per source.
  static const dailyCap = {
    StarSource.firstTouch: 8,
    StarSource.spa: 9,
    StarSource.favoriteSnack: 3,
    StarSource.boopRush: 12,
    StarSource.snackCatch: 12,
    StarSource.gift: 12,
    StarSource.hatch: 1 << 20,
  };

  /// Boop variants in hatch order (ids match lib/creatures/boop/boop_catalog.dart).
  static const boopOrder = ['mochi', 'pip', 'bao', 'kiwi', 'momo', 'puff', 'nori', 'taro', 'coco', 'jelly', 'sprout', 'star'];

  static List<EggStep> eggSchedule([List<String> boops = boopOrder]) => [
        const EggStep(Species.oink, 'pink', 40),
        const EggStep(Species.wuff, 'golden', 90),
        for (var i = 0; i < boops.length; i++) EggStep(Species.boop, boops[i], 150 + 60 * i),
      ];

  final DateTime Function() _clock;
  SharedPreferences? _prefs;
  Timer? _saveTimer;

  // ── state ─────────────────────────────────────────────────────────────
  final List<Friend> friends = [];
  int stars = 0;
  String starDay = '';
  final Map<StarSource, int> starsToday = {};
  int eggsHatched = 0;
  final Set<String> discovered = {};
  final Set<String> seenUnlocks = {};
  final Set<String> seasonalEarned = {};
  int visitDays = 0;
  String lastVisitDay = '';
  String lastGiftDay = '';
  int giftStreak = 0;
  int bestBoopRush = 0;
  int bestSnackCatch = 0;
  int bestCombo = 0;
  Room lastRoom = Room.living;
  final Map<String, double> sleepMix = {'rain': 0.6, 'purr': 0.4, 'fire': 0, 'ocean': 0, 'chimes': 0, 'noise': 0};
  int sleepTimerMin = 30;
  bool firstRunDone = false;
  final Set<String> coachDone = {};
  bool soundOn = true;
  bool hapticsOn = true;
  bool reduceMotion = false;
  String lastAnnouncementId = '';
  int _nextId = 1;

  DateTime get now => _clock();

  static String dayKey(DateTime t) =>
      '${t.year.toString().padLeft(4, '0')}-${t.month.toString().padLeft(2, '0')}-${t.day.toString().padLeft(2, '0')}';

  String get today => dayKey(now);

  static String defaultName(Species s) => switch (s) {
        Species.mofu => 'Mofu',
        Species.oink => 'Oinky',
        Species.wuff => 'Biscuit',
        Species.boop => 'Mochi',
      };

  static String defaultVariant(Species s) => switch (s) {
        Species.mofu => 'peach',
        Species.oink => 'pink',
        Species.wuff => 'golden',
        Species.boop => 'mochi',
      };

  static int levelForXp(int xp) {
    var lvl = 1;
    for (var i = 0; i < levelXp.length; i++) {
      if (xp >= levelXp[i]) lvl = i + 1;
    }
    return lvl;
  }

  static String sanitizeName(String raw, {String fallback = 'Mofu'}) {
    final cleaned = raw.replaceAll(RegExp(r'[\u0000-\u001F\u007F]'), '').trim();
    if (cleaned.isEmpty) return fallback;
    final chars = cleaned.characters;
    return chars.length <= maxNameLength ? cleaned : chars.take(maxNameLength).toString();
  }

  // ── persistence ───────────────────────────────────────────────────────
  Future<void> load([SharedPreferences? prefs]) async {
    _prefs = prefs ?? await SharedPreferences.getInstance();
    final raw = _prefs!.getString(prefsKey);
    if (raw != null) {
      try {
        _apply(jsonDecode(raw) as Map<String, dynamic>);
      } catch (e) {
        debugPrint('house state unreadable, starting fresh: $e');
      }
    } else {
      final legacy = _prefs!.getString(legacyKey);
      if (legacy != null) {
        try {
          _migrateV1(jsonDecode(legacy) as Map<String, dynamic>);
        } catch (e) {
          debugPrint('v1 state unreadable: $e');
        }
      }
    }
  }

  void _migrateV1(Map<String, dynamic> j) {
    T pick<T>(Object? v, T fallback) => v is T ? v : fallback;
    if (!pick<bool>(j['firstRunDone'], false)) return;
    final mofu = Friend(
      id: _newId(),
      species: Species.mofu,
      name: sanitizeName(pick<String>(j['name'], 'Mofu')),
      variant: pick<String>(j['color'], 'peach'),
      hatchedDay: today,
    )..fluff = pick<num>(j['fluff'], 8).toDouble().clamp(0, 100).toDouble();
    final acc = pick<String>(j['accessory'], 'none');
    if (acc != 'none') mofu.wear['head'] = acc;
    friends.add(mofu);
    final disc = j['discovered'];
    if (disc is List) discovered.addAll(disc.whereType<String>().map((d) => 'mofu.$d'));
    visitDays = pick<int>(j['visitDays'], 0).clamp(0, 100000);
    soundOn = pick<bool>(j['soundOn'], true);
    hapticsOn = pick<bool>(j['hapticsOn'], true);
    firstRunDone = true;
    // A welcome-back head start so a v1 owner meets a new friend soon.
    stars = math.min(39, visitDays * 3 + discovered.length);
    _changed(immediate: true);
  }

  void _apply(Map<String, dynamic> j) {
    T pick<T>(Object? v, T fallback) => v is T ? v : fallback;
    Iterable<String> strings(Object? v) => v is List ? v.whereType<String>() : const [];
    friends
      ..clear()
      ..addAll((j['friends'] is List ? j['friends'] as List : const []).map(Friend.fromJson).whereType<Friend>());
    stars = pick<int>(j['stars'], 0).clamp(0, 1 << 30);
    starDay = pick<String>(j['starDay'], '');
    starsToday.clear();
    final st = j['starsToday'];
    if (st is Map) {
      for (final s in StarSource.values) {
        final v = st[s.name];
        if (v is int) starsToday[s] = v;
      }
    }
    eggsHatched = pick<int>(j['eggs'], 0).clamp(0, 1000);
    discovered
      ..clear()
      ..addAll(strings(j['discovered']));
    seenUnlocks
      ..clear()
      ..addAll(strings(j['seen']));
    seasonalEarned
      ..clear()
      ..addAll(strings(j['seasonal']));
    visitDays = pick<int>(j['visitDays'], 0).clamp(0, 100000);
    lastVisitDay = pick<String>(j['lastVisitDay'], '');
    lastGiftDay = pick<String>(j['lastGiftDay'], '');
    giftStreak = pick<int>(j['giftStreak'], 0).clamp(0, 7);
    bestBoopRush = pick<int>(j['bestBoopRush'], 0).clamp(0, 100000);
    bestSnackCatch = pick<int>(j['bestSnackCatch'], 0).clamp(0, 100000);
    bestCombo = pick<int>(j['bestCombo'], 0).clamp(0, 100000);
    final room = j['lastRoom'];
    lastRoom = Room.values.where((r) => r.name == room).firstOrNull ?? Room.living;
    final mix = j['sleepMix'];
    if (mix is Map) {
      for (final k in sleepMix.keys.toList()) {
        final v = mix[k];
        if (v is num) sleepMix[k] = v.toDouble().clamp(0, 1).toDouble();
      }
    }
    final timer = pick<int>(j['sleepTimer'], 30);
    sleepTimerMin = const [0, 15, 30, 60].contains(timer) ? timer : 30;
    firstRunDone = pick<bool>(j['firstRunDone'], false);
    coachDone
      ..clear()
      ..addAll(strings(j['coach']));
    soundOn = pick<bool>(j['soundOn'], true);
    hapticsOn = pick<bool>(j['hapticsOn'], true);
    reduceMotion = pick<bool>(j['reduceMotion'], false);
    lastAnnouncementId = pick<String>(j['lastAnnouncement'], '');
    _nextId = pick<int>(j['nextId'], friends.length + 1).clamp(friends.length + 1, 1 << 30);
  }

  Map<String, dynamic> toJson() => {
        'friends': friends.map((f) => f.toJson()).toList(),
        'stars': stars,
        'starDay': starDay,
        'starsToday': {for (final e in starsToday.entries) e.key.name: e.value},
        'eggs': eggsHatched,
        'discovered': discovered.toList()..sort(),
        'seen': seenUnlocks.toList()..sort(),
        'seasonal': seasonalEarned.toList()..sort(),
        'visitDays': visitDays,
        'lastVisitDay': lastVisitDay,
        'lastGiftDay': lastGiftDay,
        'giftStreak': giftStreak,
        'bestBoopRush': bestBoopRush,
        'bestSnackCatch': bestSnackCatch,
        'bestCombo': bestCombo,
        'lastRoom': lastRoom.name,
        'sleepMix': sleepMix,
        'sleepTimer': sleepTimerMin,
        'firstRunDone': firstRunDone,
        'coach': coachDone.toList()..sort(),
        'soundOn': soundOn,
        'hapticsOn': hapticsOn,
        'reduceMotion': reduceMotion,
        'lastAnnouncement': lastAnnouncementId,
        'nextId': _nextId,
      };

  void _changed({bool immediate = false}) {
    notifyListeners();
    _saveTimer?.cancel();
    if (immediate) {
      unawaited(flush());
    } else {
      _saveTimer = Timer(const Duration(milliseconds: 600), () => unawaited(flush()));
    }
  }

  Future<void> flush() async {
    _saveTimer?.cancel();
    final p = _prefs;
    if (p == null) return;
    await p.setString(prefsKey, jsonEncode(toJson()));
  }

  Future<void> reset() async {
    _saveTimer?.cancel();
    _apply(HouseStore(clock: _clock).toJson());
    friends.clear();
    _nextId = 1;
    await _prefs?.remove(prefsKey);
    await _prefs?.remove(legacyKey);
    notifyListeners();
  }

  @override
  void dispose() {
    _saveTimer?.cancel();
    unawaited(flush());
    super.dispose();
  }

  // ── friends ───────────────────────────────────────────────────────────
  String _newId() => 'f${_nextId++}';

  Friend? friend(String id) => friends.where((f) => f.id == id).firstOrNull;

  List<Friend> inRoom(Room r) => friends.where((f) => f.room == r).toList();

  Friend adopt(Species species, {String? variant, String? name}) {
    final f = Friend(
      id: _newId(),
      species: species,
      name: sanitizeName(name ?? defaultName(species), fallback: defaultName(species)),
      variant: variant ?? defaultVariant(species),
      hatchedDay: today,
    );
    // New friends join the living room if there is space.
    f.room = inRoom(Room.living).length < maxFriendsPerRoom ? Room.living : null;
    friends.add(f);
    _changed(immediate: true);
    return f;
  }

  void rename(String id, String raw) {
    final f = friend(id);
    if (f == null) return;
    f.name = sanitizeName(raw, fallback: f.name);
    _changed();
  }

  /// Moves a friend into [room] (null = off stage). Returns false when the
  /// room is full.
  bool moveTo(String id, Room? room) {
    final f = friend(id);
    if (f == null) return false;
    if (room != null && f.room != room && inRoom(room).length >= maxFriendsPerRoom) return false;
    f.room = room;
    _changed();
    return true;
  }

  void setVariant(String id, String variant) {
    friend(id)?.variant = variant;
    _changed();
  }

  void wear(String id, String slot, String? accessory) {
    final f = friend(id);
    if (f == null) return;
    if (accessory == null || accessory == 'none') {
      f.wear.remove(slot);
    } else {
      f.wear[slot] = accessory;
    }
    _changed();
  }

  // ── friendship & care ─────────────────────────────────────────────────
  /// Returns the new level when this xp crossed a level boundary.
  int? addXp(String id, int amount) {
    final f = friend(id);
    if (f == null || amount <= 0) return null;
    final before = f.level;
    f.xp += amount;
    _changed();
    return f.level > before ? f.level : null;
  }

  /// First touch of the day per friend: +1 ★ and some friendship.
  bool registerTouch(String id) {
    final f = friend(id);
    if (f == null || f.lastTouchDay == today) return false;
    f.lastTouchDay = today;
    addXp(id, 3);
    earn(StarSource.firstTouch, 1);
    return true;
  }

  /// Finished a full spa routine. Stars once per friend per day.
  int finishSpa(String id) {
    final f = friend(id);
    if (f == null) return 0;
    addXp(id, 6);
    if (f.lastSpaDay == today) return 0;
    f.lastSpaDay = today;
    return earn(StarSource.spa, 3);
  }

  void addFluff(String id, double amount) {
    final f = friend(id);
    if (f == null || f.species != Species.mofu) return;
    f.fluff = (f.fluff + amount).clamp(0, 100);
    _changed();
  }

  FeedOutcome feed(String id, String snackId, {required String favorite}) {
    final f = friend(id);
    if (f == null) return FeedOutcome.full;
    final t = now.millisecondsSinceEpoch;
    f.recentSnacks.removeWhere((s) => t - s > const Duration(hours: 1).inMilliseconds);
    if (f.recentSnacks.length >= snacksPerHour) return FeedOutcome.full;
    f.recentSnacks.add(t);
    addXp(id, 2);
    if (snackId == favorite) {
      earn(StarSource.favoriteSnack, 1);
      return FeedOutcome.favorite;
    }
    _changed();
    return FeedOutcome.eaten;
  }

  int snacksLeft(String id) {
    final f = friend(id);
    if (f == null) return 0;
    final t = now.millisecondsSinceEpoch;
    final recent = f.recentSnacks.where((s) => t - s <= const Duration(hours: 1).inMilliseconds).length;
    return math.max(0, snacksPerHour - recent);
  }

  // ── stars ─────────────────────────────────────────────────────────────
  /// Adds up to [amount] stars from [source], respecting its daily cap.
  /// Returns what was actually added.
  int earn(StarSource source, int amount) {
    if (amount <= 0) return 0;
    if (starDay != today) {
      starDay = today;
      starsToday.clear();
    }
    final used = starsToday[source] ?? 0;
    final room = (dailyCap[source] ?? 0) - used;
    final add = math.min(amount, math.max(0, room));
    if (add <= 0) return 0;
    starsToday[source] = used + add;
    stars += add;
    _changed();
    return add;
  }

  /// Visit bookkeeping; returns true on the first visit of a day.
  bool registerVisit() {
    if (lastVisitDay == today) return false;
    lastVisitDay = today;
    visitDays++;
    _changed();
    return true;
  }

  bool get giftReady => lastGiftDay != today;

  /// Claims the daily gift: 5 + streak (streak grows on consecutive days,
  /// capped at 7; a missed day restarts it at 1, nothing else is lost).
  int claimGift() {
    if (!giftReady) return 0;
    final yesterday = dayKey(now.subtract(const Duration(days: 1)));
    giftStreak = lastGiftDay == yesterday ? math.min(7, giftStreak + 1) : 1;
    lastGiftDay = today;
    return earn(StarSource.gift, 5 + giftStreak);
  }

  // ── hatchery ──────────────────────────────────────────────────────────
  /// The next egg in the schedule, or null when every friend has hatched.
  EggStep? get nextEgg {
    final schedule = eggSchedule();
    return eggsHatched < schedule.length ? schedule[eggsHatched] : null;
  }

  bool get eggReady {
    final e = nextEgg;
    return e != null && stars >= e.stars;
  }

  /// Hatches the ready egg. Returns the new friend, or null if none is ready.
  Friend? hatch({String? name}) {
    final e = nextEgg;
    if (e == null || stars < e.stars) return null;
    eggsHatched++;
    return adopt(e.species, variant: e.variant, name: name);
  }

  // ── games ─────────────────────────────────────────────────────────────
  /// Records a mini-game result; returns stars earned.
  int finishGame(StarSource game, int score) {
    if (game == StarSource.boopRush) {
      bestBoopRush = math.max(bestBoopRush, score);
      return earn(game, score ~/ 5);
    }
    bestSnackCatch = math.max(bestSnackCatch, score);
    return earn(StarSource.snackCatch, score ~/ 4);
  }

  void recordCombo(int combo) {
    if (combo > bestCombo) {
      bestCombo = combo;
      _changed();
    }
  }

  // ── journal ───────────────────────────────────────────────────────────
  bool discover(String reactionId) {
    if (!discovered.add(reactionId)) return false;
    _changed();
    return true;
  }

  // ── wuff tricks (practice once per day, mastered after 3 days) ────────
  /// Returns true when this practice mastered the trick.
  bool practiceTrick(String id, String trick) {
    final f = friend(id);
    if (f == null || f.tricks.contains(trick)) return false;
    if (f.trickLastDay[trick] == today) return false;
    f.trickLastDay[trick] = today;
    final n = (f.trickPractice[trick] ?? 0) + 1;
    f.trickPractice[trick] = n;
    addXp(id, 4);
    if (n >= 3) {
      f.tricks.add(trick);
      _changed(immediate: true);
      return true;
    }
    _changed();
    return false;
  }

  // ── settings & misc ───────────────────────────────────────────────────
  void setRoom(Room r) {
    if (lastRoom == r) return;
    lastRoom = r;
    _changed();
  }

  void setSound(bool on) {
    soundOn = on;
    _changed(immediate: true);
  }

  void setHaptics(bool on) {
    hapticsOn = on;
    _changed(immediate: true);
  }

  void setReduceMotion(bool on) {
    reduceMotion = on;
    _changed(immediate: true);
  }

  void setMix(String channel, double v) {
    if (!sleepMix.containsKey(channel)) return;
    sleepMix[channel] = v.clamp(0, 1);
    _changed();
  }

  void setSleepTimer(int minutes) {
    if (!const [0, 15, 30, 60].contains(minutes)) return;
    sleepTimerMin = minutes;
    _changed();
  }

  void completeFirstRun() {
    firstRunDone = true;
    _changed(immediate: true);
  }

  void completeCoach(String step) {
    if (coachDone.add(step)) _changed();
  }

  bool earnSeasonal(String seasonId) {
    if (!seasonalEarned.add(seasonId)) return false;
    _changed(immediate: true);
    return true;
  }

  void markSeen(Iterable<String> keys) {
    final before = seenUnlocks.length;
    seenUnlocks.addAll(keys);
    if (seenUnlocks.length != before) _changed();
  }

  void markAnnouncementSeen(String id) {
    lastAnnouncementId = id;
    _changed();
  }
}
