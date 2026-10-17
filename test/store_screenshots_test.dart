// Dev tool, skipped by default: renders the App Store screenshots of the real
// app (Mofu & Friends) for every language, plus the caption PNGs.
//
//   flutter test test/store_screenshots_test.dart --run-skipped [--dart-define=LANGS=en,ja]
//   python tools/screenshots/compose.py
//
// Output: build/screenshots/raw/<lang>/<scene>.png at 1320×2868 (6.9" iPhone)
// and build/screenshots/raw/<lang>/caption_<n>.png. Scenes and captions live in
// tools/screenshots/captions.json.
import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mofu_pet/core/app_scope.dart';
import 'package:mofu_pet/core/remote_config.dart';
import 'package:mofu_pet/games/snack_catch.dart';
import 'package:mofu_pet/l10n/app_localizations.dart';
import 'package:mofu_pet/main.dart';
import 'package:mofu_pet/model/house_store.dart';
import 'package:mofu_pet/ui/games/snack_catch_screen.dart';
import 'package:mofu_pet/ui/house/house_screen.dart';
import 'package:mofu_pet/ui/house/rooms.dart';
import 'package:mofu_pet/world/spa_session.dart';

import 'ux_dump_test.dart' show loadRealFonts, seededHouse;

const _langsArg = String.fromEnvironment('LANGS', defaultValue: 'en,ja,de,pt,es,fr,ar');
final _langs = _langsArg.split(',');

Future<void> _wait(WidgetTester tester, int ms) async {
  for (var i = 0; i < ms ~/ 16; i++) {
    await tester.pump(const Duration(milliseconds: 16));
  }
}

class _Scene {
  const _Scene(this.id, {this.hour = 14, this.eggReady = false, required this.pose});
  final String id; // must match captions.json "scenes"
  final int hour;
  final bool eggReady;
  final Future<void> Function(WidgetTester tester, HouseScreenState home, HouseStore store) pose;
}

final _scenes = <_Scene>[
  _Scene('1_house', pose: (tester, home, store) async {
    home.goTo(Room.living);
    await _wait(tester, 2500);
  }),
  _Scene('2_spa', pose: (tester, home, store) async {
    home.house.moveFriend(store.friends[1].id, Room.spa);
    home.goTo(Room.spa);
    await _wait(tester, 900);
    final c = home.house.scenes[Room.spa]!.creatures.first;
    final s = (roomModule(Room.spa) as dynamic).session as SpaSession?;
    if (s != null) {
      // Mid-foam: a soapy friend, not a finished routine.
      for (var i = 0; i < 100; i++) {
        final t = i / 60;
        s.rub(c.position + Offset(c.radius * 0.7 * (t * 3 % 2 - 1), c.radius * 0.5 * ((t * 1.7) % 2 - 1)), 700, 1 / 60);
      }
    }
    await _wait(tester, 600);
  }),
  _Scene('3_sleep', hour: 23, pose: (tester, home, store) async {
    for (final f in store.friends.take(3)) {
      home.house.moveFriend(f.id, Room.bedroom);
    }
    home.goTo(Room.bedroom);
    await _wait(tester, 900);
    home.house.bedtime(true);
    await _wait(tester, 2400);
  }),
  _Scene('4_kitchen', pose: (tester, home, store) async {
    home.house.moveFriend(store.friends[2].id, Room.kitchen);
    home.goTo(Room.kitchen);
    await _wait(tester, 900);
    home.house.scenes[Room.kitchen]!.creatures.first.eat(favorite: true);
    await _wait(tester, 500);
  }),
  _Scene('5_hatch', eggReady: true, pose: (tester, home, store) async {
    home.house.moveFriend(store.friends[3].id, Room.garden);
    home.goTo(Room.garden);
    await _wait(tester, 1500);
    // Tap the ready egg and catch it mid-crack, before the naming dialog.
    final l = AppLocalizations.of(tester.element(find.byType(HouseScreen)));
    final label = l.eggLabel(l.gardenEggReadyHint);
    await tester.tap(find.byWidgetPredicate((w) => w is Semantics && w.properties.label == label).last);
    await _wait(tester, 1250);
  }),
  _Scene('6_dress', pose: (tester, home, store) async {
    home.goTo(Room.living);
    await _wait(tester, 700);
    store.friends[1].wear['neck'] = 'bowtie';
    // ignore: unawaited_futures
    home.openFriend(store.friends[1].id);
    await _wait(tester, 800);
    final l = AppLocalizations.of(tester.element(find.byType(HouseScreen)));
    await tester.tap(find.text(l.cardTabWardrobe).last);
    await _wait(tester, 600);
  }),
  _Scene('7_games', pose: (tester, home, store) async {
    // ignore: unawaited_futures
    playSnackCatch(tester.element(find.byType(HouseScreen)), store: store, friend: store.friends[1]);
    await _wait(tester, 600);
    // Play like a person: slide under the lowest snack, away from bees.
    final st = tester.state(find.byType(SnackCatchScreen)) as dynamic;
    final game = st.game as SnackCatchGame;
    for (var i = 0; i < 70; i++) {
      final snacks = game.items.where((it) => it.kind != FallKind.bee).toList()..sort((a, b) => b.y.compareTo(a.y));
      if (snacks.isNotEmpty) st.steer(snacks.first.x);
      await _wait(tester, 130);
    }
    await _wait(tester, 300);
  }),
];

/// Captions are rendered here rather than in compose.py: Flutter shapes Arabic
/// (HarfBuzz) and has the app's fonts; Pillow without libraqm cannot join
/// Arabic letters. Output: transparent `caption_<n>.png`, max 1180 px wide.
Future<void> _renderCaptions() async {
  final spec = jsonDecode(File('tools/screenshots/captions.json').readAsStringSync()) as Map<String, dynamic>;
  final scenes = (spec['scenes'] as List).cast<String>();
  final dark = (spec['dark'] as List).cast<String>().toSet();
  final captions = (spec['captions'] as Map).cast<String, dynamic>();
  for (final lang in _langs) {
    final lines = (captions[lang] as List).cast<String>();
    for (var i = 0; i < lines.length; i++) {
      final ar = lang == 'ar';
      double size = lang == 'ja' ? 116 : 132;
      late TextPainter tp;
      while (true) {
        tp = TextPainter(
          textAlign: TextAlign.center,
          textDirection: ar ? TextDirection.rtl : TextDirection.ltr,
          text: TextSpan(
            text: lines[i],
            style: TextStyle(
              fontFamily: ar ? 'BalooBhaijaan2' : 'Nunito',
              fontFamilyFallback: const ['Hiragino Maru Gothic ProN'],
              fontSize: size,
              fontWeight: FontWeight.w900,
              fontVariations: [FontVariation('wght', ar ? 800 : 900)],
              height: ar ? 1.25 : 1.12,
              color: dark.contains(scenes[i]) ? Colors.white : const Color(0xFF3A2A2E),
            ),
          ),
        )..layout();
        if (tp.width <= 1180 || size <= 60) break;
        size -= 4;
      }
      final w = tp.width.ceil() + 8;
      final h = tp.height.ceil() + 8;
      final rec = ui.PictureRecorder();
      tp.paint(Canvas(rec), const Offset(4, 4));
      final img = await rec.endRecording().toImage(w, h);
      final data = await img.toByteData(format: ui.ImageByteFormat.png);
      File('build/screenshots/raw/$lang/caption_${i + 1}.png')
        ..createSync(recursive: true)
        ..writeAsBytesSync(data!.buffer.asUint8List());
    }
  }
}

void main() {
  testWidgets('render store screenshots', (tester) async {
    await tester.runAsync(loadRealFonts);
    await tester.runAsync(_renderCaptions);
    tester.view
      ..physicalSize = const Size(1320, 2868)
      ..devicePixelRatio = 3
      ..padding = const FakeViewPadding(top: 62 * 3, bottom: 34 * 3)
      ..viewPadding = const FakeViewPadding(top: 62 * 3, bottom: 34 * 3);
    addTearDown(tester.view.reset);

    for (final lang in _langs) {
      for (final scene in _scenes) {
        final clock = DateTime(2026, 10, 17, scene.hour, 5);
        final store = await seededHouse(clock);
        // Below the next egg's price unless the scene is about hatching: no egg toast.
        store.stars = scene.eggReady ? 400 : 120;
        final key = GlobalKey();
        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pumpWidget(RepaintBoundary(
          key: key,
          child: MofuApp(services: AppServices(store: store, config: RemoteConfigService(), clock: () => clock), locale: Locale(lang)),
        ));
        await _wait(tester, 400);
        final home = tester.state<HouseScreenState>(find.byType(HouseScreen));
        await scene.pose(tester, home, store);
        home.clearToasts();
        await _wait(tester, 400);
        final boundary = key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
        final png = await tester.runAsync(() async {
          final img = await boundary.toImage(pixelRatio: 3);
          final data = await img.toByteData(format: ui.ImageByteFormat.png);
          return data!.buffer.asUint8List();
        });
        File('build/screenshots/raw/$lang/${scene.id}.png')
          ..createSync(recursive: true)
          ..writeAsBytesSync(png!);
        final nav = Navigator.of(tester.element(find.byType(HouseScreen, skipOffstage: false)));
        while (nav.canPop()) {
          nav.pop();
          await _wait(tester, 300);
        }
      }
    }
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(seconds: 1));
  }, skip: true);
}
