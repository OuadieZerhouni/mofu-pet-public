import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mofu_pet/core/remote_config.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  // F9-c3: the sections the tests above leave out, each fed every wrong shape.
  group('every section survives garbage', () {
    const d = RemoteConfig.defaults;
    for (final junk in <Object?>[null, 7, 'x', true, <Object?>[], <String, dynamic>{}]) {
      test('section values = $junk', () {
        final c = RemoteConfig.fromJson({
          'schemaVersion': junk,
          'minSupportedVersion': junk,
          'latestVersion': junk,
          'updateUrlIos': junk,
          'announcement': junk,
          'features': junk,
          'seasons': junk,
          'links': junk,
          'reviewPrompt': junk,
          'ads': junk,
          'iap': junk,
        });
        expect(c.schemaVersion, junk is int ? junk : d.schemaVersion);
        expect(c.minSupportedVersion, d.minSupportedVersion);
        expect(c.latestVersion, d.latestVersion);
        expect(c.updateUrlIos, d.updateUrlIos);
        expect(c.announcement, isNull);
        expect(c.shakeEnabled && c.tossEnabled && c.soundsEnabled, isTrue);
        expect(c.seasons.length, junk is List ? 0 : d.seasons.length);
        expect(c.privacyUrl, d.privacyUrl);
        expect(c.supportUrl, d.supportUrl);
        expect(c.storeUrl, d.storeUrl);
        expect(c.reviewPromptEnabled || c.adsEnabled || c.iapEnabled, isFalse);
      });
    }

    test('keys inside sections with the wrong type', () {
      final c = RemoteConfig.fromJson({
        'updateUrlIos': 'http://apps.apple.com/app/id1',
        'announcement': {'enabled': 'true', 'id': 'a', 'title': 'Hi'},
        'features': {'sounds': 0, 'shake': null, 'toss': 'off'},
        'links': {'privacyPolicy': '', 'support': '   ', 'appStore': 5},
        'reviewPrompt': {'enabled': 'yes'},
        'ads': {'enabled': 1},
        'iap': {'enabled': 'true'},
      });
      expect(c.updateUrlIos, '', reason: 'only https');
      expect(c.announcement, isNull, reason: 'enabled must be a real true');
      expect(c.shakeEnabled && c.tossEnabled && c.soundsEnabled, isTrue);
      expect(c.privacyUrl, d.privacyUrl, reason: 'an empty link falls back instead of blanking the row');
      expect(c.supportUrl, d.supportUrl);
      expect(c.storeUrl, '');
      expect(c.reviewPromptEnabled || c.adsEnabled || c.iapEnabled, isFalse);
    });

    test('announcement url must be https; reserved iap/reviewPrompt flags are read', () {
      final c = RemoteConfig.fromJson({
        'announcement': {'enabled': true, 'id': 'a', 'title': 'Hi', 'url': 'javascript:alert(1)'},
        'iap': {'enabled': true},
        'reviewPrompt': {'enabled': true},
      });
      expect(c.announcement!.url, '');
      expect(c.iapEnabled && c.reviewPromptEnabled, isTrue);
    });
  });

  // F9-c1
  group('fetching', () {
    setUp(() => SharedPreferences.setMockInitialValues({}));

    test('fetches the public URL, applies and caches the result', () async {
      Uri? asked;
      final svc = RemoteConfigService();
      await http.runWithClient(() => svc.refresh(), () => MockClient((req) async {
            asked = req.url;
            return http.Response('{"features":{"toss":false}}', 200);
          }));
      expect(kRemoteConfigUrl, 'https://raw.githubusercontent.com/OuadieZerhouni/app-configs/main/mofu-pet/config.json');
      expect(asked.toString(), startsWith('$kRemoteConfigUrl?t='));
      expect(svc.value.tossEnabled, isFalse);
      final cached = (await SharedPreferences.getInstance()).getString('mofu.remoteConfigCache');
      expect(cached, contains('"toss":false'));
      final next = RemoteConfigService();
      await next.init();
      expect(next.value.tossEnabled, isFalse, reason: 'the next launch starts from the cache, before any network');
    });

    test('a failed, non-200 or non-object response keeps what we had', () async {
      final svc = RemoteConfigService()..value = RemoteConfig.fromJson({'features': {'shake': false}});
      for (final res in [http.Response('nope', 500), http.Response('[1,2]', 200), http.Response('{bad', 200)]) {
        await http.runWithClient(() => svc.refresh(), () => MockClient((_) async => res));
        expect(svc.value.shakeEnabled, isFalse);
      }
      await http.runWithClient(() => svc.refresh(), () => MockClient((_) async => throw const SocketException('offline')));
      expect(svc.value.shakeEnabled, isFalse);
    });

    testWidgets('gives up after 6 s', (tester) async {
      final svc = RemoteConfigService();
      var done = false;
      http.runWithClient(() => svc.refresh(), () => MockClient((_) async {
            await Future<void>.delayed(const Duration(minutes: 1));
            return http.Response('{"features":{"toss":false}}', 200);
          })).then((_) => done = true);
      await tester.pump(const Duration(seconds: 5));
      expect(done, isFalse);
      await tester.pump(const Duration(seconds: 2));
      expect(done, isTrue);
      expect(svc.value.tossEnabled, isTrue);
      await tester.pump(const Duration(minutes: 1)); // drain the mock's slow response
      expect(svc.value.tossEnabled, isTrue, reason: 'a late answer after the timeout is ignored');
    });
  });
}
