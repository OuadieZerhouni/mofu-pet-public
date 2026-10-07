import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mofu_pet/core/remote_config.dart';

/// One test per config section (docs/REMOTE_CONFIG.md): malformed values fall
/// back to safe defaults, never crash.
void main() {
  test('the committed live + proposed configs parse and are valid JSON', () {
    for (final name in ['remote_config_current.json', 'remote_config_proposed.json', 'remote_config_template.json']) {
      final j = jsonDecode(File('config/$name').readAsStringSync()) as Map<String, dynamic>;
      final c = RemoteConfig.fromJson(j);
      expect(c.adsEnabled, isFalse, reason: '$name: v1 ships without ads');
      expect(c.iapEnabled, isFalse, reason: '$name: v1 ships without purchases');
      expect(c.privacyUrl, startsWith('https://'));
      expect(c.seasons, isNotEmpty);
    }
  });

  test('empty object = defaults', () {
    final c = RemoteConfig.fromJson({});
    expect(c.minSupportedVersion, '1.0.0');
    expect(c.shakeEnabled && c.tossEnabled && c.soundsEnabled, isTrue);
    expect(c.announcement, isNull);
    expect(c.seasons.length, RemoteConfig.defaultSeasons.length);
  });

  test('wrong types fall back per key', () {
    final c = RemoteConfig.fromJson({
      'minSupportedVersion': 7,
      'latestVersion': 'banana',
      'features': {'shake': 'yes', 'toss': false},
      'links': {'privacyPolicy': 'http://insecure.example', 'support': 12, 'appStore': 'javascript:alert(1)'},
      'seasons': 'halloween',
      'ads': {'enabled': true},
    });
    expect(c.minSupportedVersion, '1.0.0');
    expect(c.latestVersion, '1.0.0');
    expect(c.shakeEnabled, isTrue);
    expect(c.tossEnabled, isFalse);
    expect(c.privacyUrl, RemoteConfig.defaults.privacyUrl, reason: 'only https links are accepted');
    expect(c.storeUrl, RemoteConfig.defaults.storeUrl);
    expect(c.seasons.length, RemoteConfig.defaultSeasons.length);
    expect(c.adsEnabled, isTrue, reason: 'reserved flag is read (and ignored by v1 code)');
  });

  test('announcement needs enabled, an id and some text', () {
    expect(RemoteConfig.fromJson({'announcement': {'enabled': true, 'id': '', 'title': 'Hi'}}).announcement, isNull);
    expect(RemoteConfig.fromJson({'announcement': {'enabled': false, 'id': 'a', 'title': 'Hi'}}).announcement, isNull);
    expect(RemoteConfig.fromJson({'announcement': {'enabled': true, 'id': 'a', 'title': {'en': ''}}}).announcement, isNull);
    final a = RemoteConfig.fromJson({
      'announcement': {'enabled': true, 'id': 'halloween26', 'title': {'en': 'Boo', 'ja': 'ばあ'}, 'body': 'Spooky'},
    }).announcement!;
    expect(a.title.resolve('ja'), 'ばあ');
    expect(a.title.resolve('de'), 'Boo', reason: 'falls back to English');
    expect(a.body.resolve('ar'), 'Spooky');
  });

  test('season windows parse, drop malformed entries, and wrap the new year', () {
    final c = RemoteConfig.fromJson({
      'seasons': [
        {'id': 'halloween', 'start': '10-20', 'end': '11-02'},
        {'id': 'winter', 'start': '12-15', 'end': '01-06'},
        {'id': 'broken', 'start': '13-40', 'end': '01-01'},
        {'start': '01-01', 'end': '02-02'},
      ],
    });
    expect(c.seasons.map((s) => s.id), ['halloween', 'winter']);
    expect(c.openSeason(DateTime(2026, 10, 31))?.id, 'halloween');
    expect(c.openSeason(DateTime(2026, 12, 25))?.id, 'winter');
    expect(c.openSeason(DateTime(2027, 1, 3))?.id, 'winter');
    expect(c.openSeason(DateTime(2026, 7, 1)), isNull);
    expect(RemoteConfig.fromJson({'seasons': []}).openSeason(DateTime(2026, 10, 31)), isNull,
        reason: 'an empty remote list switches seasons off');
  });

  test('version compare', () {
    expect(compareVersions('1.2.10', '1.2.9'), 1);
    expect(compareVersions('1.0', '1.0.0'), 0);
    expect(compareVersions('0.9.9', '1.0.0'), -1);
    expect(compareVersions('2.0.0+14', '2.0.0'), 0);
  });

  test('update prompts never show without a store URL', () {
    final s = RemoteConfigService()
      ..appVersion = '1.0.0'
      ..value = RemoteConfig.fromJson({'minSupportedVersion': '2.0.0', 'latestVersion': '2.0.0'});
    expect(s.updateRequired, isFalse);
    s.value = RemoteConfig.fromJson({
      'minSupportedVersion': '2.0.0',
      'updateUrlIos': 'https://apps.apple.com/app/id1',
    });
    expect(s.updateRequired, isTrue);
  });
}
