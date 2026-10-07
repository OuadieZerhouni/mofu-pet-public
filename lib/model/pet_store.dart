import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart' show StringCharacters;
import 'package:shared_preferences/shared_preferences.dart';

import 'catalog.dart';

/// Result of offering a snack.
enum FeedResult { eaten, favorite, full }

/// Everything about *this* Mofu that survives a relaunch, plus the
/// progression rules that read it.
///
/// One store, one prefs key: the whole state is a single JSON blob, so a reset
/// cannot miss a key (OuO's reset once missed two keys owned by a screen and
/// left its coach marks permanently spent) and a schema change is one place.
class PetStore extends ChangeNotifier {
  PetStore({DateTime Function()? clock}) : _clock = clock ?? DateTime.now;

  static const prefsKey = 'mofu.state.v1';
  static const maxNameLength = 16;
  static const snackLimitPerHour = 6;

  final DateTime Function() _clock;
  SharedPreferences? _prefs;
  Timer? _saveTimer;

  // ── persisted state ───────────────────────────────────────────────────
  String name = 'Mofu';
  String colorId = 'peach';
  String accessoryId = 'none';
  double fluff = 8;
  final Set<String> discovered = {};
  final Set<String> seenUnlocks = {};
  final Set<String> seasonalEarned = {};
  final Set<int> celebrated = {};
  int visitDays = 0;
  String lastVisitDay = '';
  String lastBrushDay = '';
  int snacksFed = 0;
  final List<int> recentSnackTimes = [];
  bool firstRunDone = false;
  bool coachDone = false;
  bool soundOn = true;
  bool hapticsOn = true;
  String lastAnnouncementId = '';

  DateTime get now => _clock();

  static String dayKey(DateTime t) =>
      '${t.year.toString().padLeft(4, '0')}-${t.month.toString().padLeft(2, '0')}-${t.day.toString().padLeft(2, '0')}';

  // ── persistence ───────────────────────────────────────────────────────
  Future<void> load([SharedPreferences? prefs]) async {
    _prefs = prefs ?? await SharedPreferences.getInstance();
    final raw = _prefs!.getString(prefsKey);
    if (raw != null) {
      try {
        _apply(jsonDecode(raw) as Map<String, dynamic>);
      } catch (e) {
        debugPrint('mofu state unreadable, starting fresh: $e');
      }
    }
  }

  void _apply(Map<String, dynamic> j) {
    T pick<T>(Object? v, T fallback) => v is T ? v : fallback;
    name = sanitizeName(pick<String>(j['name'], name));
    final color = pick<String>(j['color'], colorId);
    if (Catalog.furColors.any((c) => c.id == color)) colorId = color;
    final acc = pick<String>(j['accessory'], accessoryId);
    if (Catalog.accessories.any((a) => a.id == acc)) accessoryId = acc;
    fluff = pick<num>(j['fluff'], fluff).toDouble().clamp(0, 100).toDouble();
    Iterable<String> strings(Object? v) => v is List ? v.map((e) => '$e') : const [];
    discovered
      ..clear()
      ..addAll(strings(j['discovered']).where(Catalog.isReaction));
    seenUnlocks
      ..clear()
      ..addAll(strings(j['seen']));
    seasonalEarned
      ..clear()
      ..addAll(strings(j['seasonal']));
    celebrated
      ..clear()
      ..addAll(strings(j['celebrated']).map(int.tryParse).whereType<int>());
    visitDays = pick<int>(j['visitDays'], 0).clamp(0, 100000);
    lastVisitDay = pick<String>(j['lastVisitDay'], '');
    lastBrushDay = pick<String>(j['lastBrushDay'], '');
    snacksFed = pick<int>(j['snacksFed'], 0).clamp(0, 1 << 30);
    recentSnackTimes
      ..clear()
      ..addAll(j['recentSnacks'] is List ? (j['recentSnacks'] as List).whereType<int>() : const <int>[]);
    firstRunDone = pick<bool>(j['firstRunDone'], false);
    coachDone = pick<bool>(j['coachDone'], false);
    soundOn = pick<bool>(j['soundOn'], true);
    hapticsOn = pick<bool>(j['hapticsOn'], true);
    lastAnnouncementId = pick<String>(j['lastAnnouncement'], '');
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'color': colorId,
        'accessory': accessoryId,
        'fluff': double.parse(fluff.toStringAsFixed(2)),
        'discovered': discovered.toList()..sort(),
        'seen': seenUnlocks.toList()..sort(),
        'seasonal': seasonalEarned.toList()..sort(),
        'celebrated': celebrated.map((e) => '$e').toList()..sort(),
        'visitDays': visitDays,
        'lastVisitDay': lastVisitDay,
        'lastBrushDay': lastBrushDay,
        'snacksFed': snacksFed,
        'recentSnacks': recentSnackTimes,
        'firstRunDone': firstRunDone,
        'coachDone': coachDone,
        'soundOn': soundOn,
        'hapticsOn': hapticsOn,
        'lastAnnouncement': lastAnnouncementId,
      };

  /// Debounced: fluff changes many times per second while petting.
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

  /// Wipes everything, including one-shot flags.
  Future<void> reset() async {
    _saveTimer?.cancel();
    final fresh = PetStore(clock: _clock);
    _apply(fresh.toJson());
    final p = _prefs;
    if (p != null) {
      // Every key the app writes is under `mofu.`, the remote-config cache included.
      for (final k in p.getKeys().where((k) => k.startsWith('mofu.')).toList()) {
        await p.remove(k);
      }
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _saveTimer?.cancel();
    unawaited(flush());
    super.dispose();
  }

  // ── identity ──────────────────────────────────────────────────────────
  static String sanitizeName(String raw) {
    final cleaned = raw.replaceAll(RegExp(r'[\u0000-\u001F\u007F]'), '').trim();
    if (cleaned.isEmpty) return 'Mofu';
    final chars = cleaned.characters;
    return chars.length > maxNameLength ? chars.take(maxNameLength).toString() : cleaned;
  }

  void rename(String raw) {
    name = sanitizeName(raw);
    _changed(immediate: true);
  }

  Snack get favoriteSnack => Catalog.favoriteSnackFor(name);

  void completeFirstRun() {
    firstRunDone = true;
    _changed(immediate: true);
  }

  void completeCoach() {
    if (coachDone) return;
    coachDone = true;
    _changed(immediate: true);
  }

  void setSound(bool on) {
    soundOn = on;
    _changed(immediate: true);
  }

  void setHaptics(bool on) {
    hapticsOn = on;
    _changed(immediate: true);
  }

  void markAnnouncementSeen(String id) {
    lastAnnouncementId = id;
    _changed(immediate: true);
  }

  // ── visits ────────────────────────────────────────────────────────────
  /// Counts a visit day. Returns true the first time it is called on a new
  /// local day. Visit days never decrease: absence is not punished.
  bool registerVisit() {
    final today = dayKey(now);
    if (today == lastVisitDay) return false;
    lastVisitDay = today;
    visitDays += 1;
    _changed(immediate: true);
    return true;
  }

  /// The first brush of each local day earns a bonus. Returns true when this
  /// brush is that first one.
  bool registerBrush() {
    final today = dayKey(now);
    if (today == lastBrushDay) return false;
    lastBrushDay = today;
    _changed(immediate: true);
    return true;
  }

  // ── fluff ─────────────────────────────────────────────────────────────
  /// Adds fluff and returns any milestones crossed for the first time.
  List<int> addFluff(double amount) {
    if (amount <= 0) return const [];
    final before = fluff;
    fluff = (fluff + amount).clamp(0, 100).toDouble();
    final crossed = <int>[];
    for (final m in Catalog.fluffMilestones) {
      if (before < m && fluff >= m && !celebrated.contains(m)) {
        celebrated.add(m);
        crossed.add(m);
      }
    }
    _changed(immediate: crossed.isNotEmpty);
    return crossed;
  }

  /// 0..1, the value the painter uses.
  double get fluffFraction => fluff / 100;

  // ── journal ───────────────────────────────────────────────────────────
  /// Returns true when [id] is newly discovered.
  bool discover(String id) {
    if (!Catalog.isReaction(id) || discovered.contains(id)) return false;
    discovered.add(id);
    _changed(immediate: true);
    return true;
  }

  // ── snacks ────────────────────────────────────────────────────────────
  FeedResult feed(String snackId) {
    final t = now.millisecondsSinceEpoch;
    recentSnackTimes.removeWhere((e) => t - e > const Duration(hours: 1).inMilliseconds || e > t);
    if (recentSnackTimes.length >= snackLimitPerHour) {
      notifyListeners();
      return FeedResult.full;
    }
    recentSnackTimes.add(t);
    snacksFed += 1;
    _changed();
    return snackId == favoriteSnack.id ? FeedResult.favorite : FeedResult.eaten;
  }

  // ── wardrobe ──────────────────────────────────────────────────────────
  bool isUnlocked(UnlockRule rule) {
    switch (rule.kind) {
      case UnlockKind.start:
        return true;
      case UnlockKind.days:
        return visitDays >= rule.amount;
      case UnlockKind.fluff:
        return fluff >= rule.amount;
      case UnlockKind.journal:
        return discovered.length >= rule.amount;
      case UnlockKind.snacks:
        return snacksFed >= rule.amount;
      case UnlockKind.seasonal:
        return seasonalEarned.contains(rule.seasonId);
    }
  }

  bool colorUnlocked(String id) => isUnlocked(Catalog.color(id).rule);
  bool accessoryUnlocked(String id) => isUnlocked(Catalog.accessory(id).rule);

  void setColor(String id) {
    if (!colorUnlocked(id) || id == colorId) return;
    colorId = id;
    _changed(immediate: true);
  }

  void setAccessory(String id) {
    if (!accessoryUnlocked(id) || id == accessoryId) return;
    accessoryId = id;
    _changed(immediate: true);
  }

  /// Keys of unlocked items the user has not looked at yet ("New!" dots).
  /// Start items are never "new" — they were never locked.
  Set<String> get unseenUnlocks {
    final out = <String>{};
    for (final c in Catalog.furColors) {
      if (c.rule.kind != UnlockKind.start && isUnlocked(c.rule) && !seenUnlocks.contains('color:${c.id}')) {
        out.add('color:${c.id}');
      }
    }
    for (final a in Catalog.accessories) {
      if (a.rule.kind != UnlockKind.start && isUnlocked(a.rule) && !seenUnlocks.contains('acc:${a.id}')) {
        out.add('acc:${a.id}');
      }
    }
    return out;
  }

  void markSeen(Iterable<String> keys) {
    final before = seenUnlocks.length;
    seenUnlocks.addAll(keys);
    if (seenUnlocks.length != before) _changed();
  }

  /// Earns a seasonal accessory. Returns true when newly earned.
  bool earnSeasonal(String seasonId) {
    if (seasonId.isEmpty || seasonalEarned.contains(seasonId)) return false;
    if (!Catalog.accessories.any((a) => a.rule.kind == UnlockKind.seasonal && a.rule.seasonId == seasonId)) {
      return false;
    }
    seasonalEarned.add(seasonId);
    _changed(immediate: true);
    return true;
  }
}
