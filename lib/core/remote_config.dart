import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'test_env.dart';

/// Where the live config lives: a public, JSON-only GitHub repo shared by the
/// owner's apps (`OuadieZerhouni/app-configs`). It contains no secrets by
/// design — anyone can read it. Schema: docs/REMOTE_CONFIG.md.
const kRemoteConfigUrl =
    'https://raw.githubusercontent.com/OuadieZerhouni/app-configs/main/mofu-pet/config.json';

/// A localized string map: {"en": "...", "ja": "..."} → best match.
@immutable
class LocalizedText {
  const LocalizedText(this.values);
  final Map<String, String> values;

  String resolve(String languageCode) =>
      values[languageCode] ?? values['en'] ?? (values.isEmpty ? '' : values.values.first);

  bool get isEmpty => values.values.every((v) => v.trim().isEmpty);

  factory LocalizedText.fromJson(Object? j) {
    if (j is String) return LocalizedText({'en': j});
    if (j is Map) return LocalizedText(j.map((k, v) => MapEntry('$k', '$v')));
    return const LocalizedText({});
  }
}

@immutable
class Announcement {
  const Announcement({required this.id, required this.title, required this.body, this.url = ''});
  final String id;
  final LocalizedText title;
  final LocalizedText body;
  final String url;
}

/// A yearly date window (month/day, local time) during which a seasonal
/// accessory can be earned. `end` may be before `start` to wrap the new year.
@immutable
class SeasonWindow {
  const SeasonWindow({required this.id, required this.startMonth, required this.startDay, required this.endMonth, required this.endDay});
  final String id;
  final int startMonth;
  final int startDay;
  final int endMonth;
  final int endDay;

  bool contains(DateTime t) {
    final v = t.month * 100 + t.day;
    final s = startMonth * 100 + startDay;
    final e = endMonth * 100 + endDay;
    return s <= e ? (v >= s && v <= e) : (v >= s || v <= e);
  }

  /// Parses `{"id":"halloween","start":"10-20","end":"11-02"}`; null when malformed.
  static SeasonWindow? fromJson(Object? j) {
    if (j is! Map) return null;
    final id = (j['id'] ?? '').toString();
    final s = _md(j['start']);
    final e = _md(j['end']);
    if (id.isEmpty || s == null || e == null) return null;
    return SeasonWindow(id: id, startMonth: s.$1, startDay: s.$2, endMonth: e.$1, endDay: e.$2);
  }

  static (int, int)? _md(Object? v) {
    if (v is! String) return null;
    final m = RegExp(r'^(\d{1,2})-(\d{1,2})$').firstMatch(v.trim());
    if (m == null) return null;
    final mo = int.parse(m.group(1)!), d = int.parse(m.group(2)!);
    if (mo < 1 || mo > 12 || d < 1 || d > 31) return null;
    return (mo, d);
  }
}

/// Everything the app can be tuned with remotely.
///
/// Rules (docs/REMOTE_CONFIG.md): config tunes behaviour, it never invents
/// it; every key has a safe code default; malformed values fall back rather
/// than crash. The very first launch has no fetched config at all, so
/// [RemoteConfig.defaults] must be a complete, shippable app on its own.
@immutable
class RemoteConfig {
  const RemoteConfig({
    this.schemaVersion = 1,
    this.minSupportedVersion = '1.0.0',
    this.latestVersion = '1.0.0',
    this.updateUrlIos = '',
    this.announcement,
    this.shakeEnabled = true,
    this.tossEnabled = true,
    this.soundsEnabled = true,
    this.seasons = defaultSeasons,
    this.reviewPromptEnabled = false,
    this.adsEnabled = false,
    this.iapEnabled = false,
    this.privacyUrl = 'https://github.com/OuadieZerhouni/app-configs/blob/main/mofu-pet/PRIVACY.md',
    this.supportUrl = 'https://github.com/OuadieZerhouni/app-configs/blob/main/mofu-pet/SUPPORT.md',
    this.storeUrl = '',
  });

  static const defaults = RemoteConfig();

  /// Shipped windows, so seasonal items work even if the config is never
  /// fetched. The remote list replaces this one entirely when present.
  static const defaultSeasons = [
    SeasonWindow(id: 'halloween', startMonth: 10, startDay: 20, endMonth: 11, endDay: 2),
    SeasonWindow(id: 'winter', startMonth: 12, startDay: 15, endMonth: 1, endDay: 6),
  ];

  final int schemaVersion;
  final String minSupportedVersion;
  final String latestVersion;
  final String updateUrlIos;
  final Announcement? announcement;
  final bool shakeEnabled;
  final bool tossEnabled;
  final bool soundsEnabled;
  final List<SeasonWindow> seasons;

  /// Reserved: v1 has no review-prompt code.
  final bool reviewPromptEnabled;

  /// Reserved: v1 ships with no ad or purchase code at all, so these can only
  /// ever be read, never acted on. Present so the schema is stable later.
  final bool adsEnabled;
  final bool iapEnabled;
  final String privacyUrl;
  final String supportUrl;

  /// App Store page (filled once the app has an Apple ID). Empty = no "Rate" row.
  final String storeUrl;

  /// The season open on [t], if any.
  SeasonWindow? openSeason(DateTime t) {
    for (final s in seasons) {
      if (s.contains(t)) return s;
    }
    return null;
  }

  factory RemoteConfig.fromJson(Map<String, dynamic> j) {
    const d = RemoteConfig.defaults;
    T pick<T>(Object? v, T fallback) => v is T ? v : fallback;
    String url(Object? v, String fallback) {
      if (v is! String) return fallback;
      final s = v.trim();
      if (s.isEmpty) return '';
      final u = Uri.tryParse(s);
      return (u != null && u.scheme == 'https') ? s : fallback;
    }

    final features = pick<Map<String, dynamic>>(j['features'], const {});
    final review = pick<Map<String, dynamic>>(j['reviewPrompt'], const {});
    final links = pick<Map<String, dynamic>>(j['links'], const {});
    final ads = pick<Map<String, dynamic>>(j['ads'], const {});
    final iap = pick<Map<String, dynamic>>(j['iap'], const {});

    Announcement? ann;
    final a = j['announcement'];
    if (a is Map<String, dynamic> && a['enabled'] == true && (a['id'] ?? '').toString().trim().isNotEmpty) {
      final title = LocalizedText.fromJson(a['title']);
      final body = LocalizedText.fromJson(a['body']);
      if (!(title.isEmpty && body.isEmpty)) {
        ann = Announcement(id: a['id'].toString().trim(), title: title, body: body, url: url(a['url'], ''));
      }
    }

    var seasons = d.seasons;
    if (j['seasons'] is List) {
      seasons = [
        for (final s in j['seasons'] as List)
          ?SeasonWindow.fromJson(s),
      ];
    }

    String version(Object? v, String fallback) =>
        (v is String && RegExp(r'^\d+(\.\d+){0,2}$').hasMatch(v.trim())) ? v.trim() : fallback;

    return RemoteConfig(
      schemaVersion: pick<int>(j['schemaVersion'], d.schemaVersion),
      minSupportedVersion: version(j['minSupportedVersion'], d.minSupportedVersion),
      latestVersion: version(j['latestVersion'], d.latestVersion),
      updateUrlIos: url(j['updateUrlIos'], d.updateUrlIos),
      announcement: ann,
      shakeEnabled: pick<bool>(features['shake'], d.shakeEnabled),
      tossEnabled: pick<bool>(features['toss'], d.tossEnabled),
      soundsEnabled: pick<bool>(features['sounds'], d.soundsEnabled),
      seasons: seasons,
      reviewPromptEnabled: pick<bool>(review['enabled'], d.reviewPromptEnabled),
      adsEnabled: pick<bool>(ads['enabled'], false),
      iapEnabled: pick<bool>(iap['enabled'], false),
      privacyUrl: url(links['privacyPolicy'], d.privacyUrl),
      supportUrl: url(links['support'], d.supportUrl),
      storeUrl: url(links['appStore'], d.storeUrl),
    );
  }
}

/// Fetches, caches and exposes [RemoteConfig].
///
/// Startup never waits on the network: the cached copy (or the code
/// defaults) is available synchronously, and a fresh fetch replaces it when
/// it lands.
class RemoteConfigService extends ValueNotifier<RemoteConfig> {
  RemoteConfigService() : super(RemoteConfig.defaults);

  static const _cacheKey = 'mofu.remoteConfigCache';
  String appVersion = '1.0.0';

  Future<void> init() async {
    try {
      appVersion = (await PackageInfo.fromPlatform()).version;
    } catch (_) {}
    try {
      final p = await SharedPreferences.getInstance();
      final cached = p.getString(_cacheKey);
      if (cached != null) value = RemoteConfig.fromJson(jsonDecode(cached) as Map<String, dynamic>);
    } catch (_) {}
    if (!skipDeviceOnlyWork) unawaited(refresh());
  }

  Future<void> refresh() async {
    try {
      // Cache-buster changes every 10 minutes: raw.githubusercontent caches ~5.
      final bucket = DateTime.now().millisecondsSinceEpoch ~/ 600000;
      final res = await http.get(Uri.parse('$kRemoteConfigUrl?t=$bucket')).timeout(const Duration(seconds: 6));
      if (res.statusCode != 200) return;
      final text = utf8.decode(res.bodyBytes);
      final j = jsonDecode(text);
      if (j is! Map<String, dynamic>) return;
      value = RemoteConfig.fromJson(j);
      final p = await SharedPreferences.getInstance();
      await p.setString(_cacheKey, text);
    } catch (e) {
      debugPrint('remote config fetch skipped: $e');
    }
  }

  bool get updateRequired =>
      value.updateUrlIos.isNotEmpty && compareVersions(appVersion, value.minSupportedVersion) < 0;
  bool get updateAvailable =>
      value.updateUrlIos.isNotEmpty && compareVersions(appVersion, value.latestVersion) < 0;
}

/// Semantic-ish version compare: "1.2.10" > "1.2.9". Non-numeric parts → 0.
int compareVersions(String a, String b) {
  List<int> parts(String v) => v.split(RegExp(r'[.+-]')).take(3).map((p) => int.tryParse(p) ?? 0).toList();
  final pa = parts(a), pb = parts(b);
  for (var i = 0; i < 3; i++) {
    final x = i < pa.length ? pa[i] : 0;
    final y = i < pb.length ? pb[i] : 0;
    if (x != y) return x.compareTo(y);
  }
  return 0;
}
