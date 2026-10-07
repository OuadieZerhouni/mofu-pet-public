// Dev tool, skipped by default: renders the raw App Store screenshots.
//
//   flutter test test/store_screenshots_test.dart --run-skipped
//   .venv python tools/screenshots/compose.py
//
// Every frame is the real app (real HomeScreen, real sheets, real painters)
// posed through public state, rendered at 440×956 @3x = 1320×2868, the 6.9"
// iPhone size App Store Connect asks for. Output: build/screenshots/raw/<lang>/.
//
// Fonts: flutter_test renders text in a placeholder font, so the real ones are
// loaded first. Japanese falls back to Hiragino on device; here Yu Gothic Bold
// (Windows) stands in under that family name. Emoji have no test font, which
// is why the scenes avoid the journal.
import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mofu_pet/core/app_scope.dart';
import 'package:mofu_pet/core/remote_config.dart';
import 'package:mofu_pet/core/sfx.dart';
import 'package:mofu_pet/main.dart';
import 'package:mofu_pet/model/catalog.dart';
import 'package:mofu_pet/model/pet_store.dart';
import 'package:mofu_pet/sim/mofu_sim.dart';
import 'package:mofu_pet/ui/home_screen.dart';
import 'package:mofu_pet/ui/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _langs = ['en', 'ja', 'de', 'pt', 'es', 'fr', 'ar'];

Future<void> _font(String family, String path) async {
  final bytes = File(path).readAsBytesSync();
  final loader = FontLoader(family)..addFont(Future.value(ByteData.sublistView(Uint8List.fromList(bytes))));
  await loader.load();
}

Future<void> _loadFonts() async {
  await _font('Nunito', 'assets/fonts/Nunito.ttf');
  await _font('BalooBhaijaan2', 'assets/fonts/BalooBhaijaan2.ttf');
  final sdk = File(Platform.resolvedExecutable).parent.parent.parent.parent.parent.parent.path;
  final icons = '$sdk/bin/cache/artifacts/material_fonts/materialicons-regular.otf';
  if (File(icons).existsSync()) await _font('MaterialIcons', icons);
  const jp = r'C:\Windows\Fonts\YuGothB.ttc';
  if (File(jp).existsSync()) await _font('Hiragino Maru Gothic ProN', jp);
}

class _Scene {
  const _Scene(this.id, {required this.hour, required this.setup, required this.pose});
  final String id;
  final int hour;
  final void Function(PetStore) setup;
  final Future<void> Function(WidgetTester, HomeScreenState) pose;
}

Future<void> _wait(WidgetTester tester, int ms) async {
  for (var i = 0; i < ms ~/ 16; i++) {
    await tester.pump(const Duration(milliseconds: 16));
  }
}

/// Park Mofu mid-room so every frame has the same composition.
Future<void> _centre(WidgetTester tester, HomeScreenState home) async {
  await _wait(tester, 700);
  final w = tester.view.physicalSize.width / tester.view.devicePixelRatio;
  home.sim.pos = Offset(w / 2, home.sim.pos.dy);
  await _wait(tester, 200);
}

void _progress(PetStore s, {double fluff = 70}) {
  s
    ..firstRunDone = true
    ..coachDone = true
    ..name = 'Mofu'
    ..fluff = fluff
    ..visitDays = 8
    ..snacksFed = 20
    ..lastVisitDay = PetStore.dayKey(s.now)
    ..lastBrushDay = PetStore.dayKey(s.now);
  s.discovered.addAll(Catalog.reactions.take(17).map((r) => r.id));
  s.markSeen(s.unseenUnlocks);
}

final _scenes = <_Scene>[
  _Scene('1_hero', hour: 10, setup: (s) {
    _progress(s, fluff: 78);
    s
      ..colorId = 'peach'
      ..accessoryId = 'bow';
  }, pose: (tester, home) async {
    await _centre(tester, home);
    home.sim.holdExpression(Expr.love);
    home.sim.celebrateSmall();
    await _wait(tester, 500);
  }),
  _Scene('2_brush', hour: 15, setup: (s) {
    _progress(s, fluff: 60);
    s
      ..colorId = 'mint'
      ..accessoryId = 'flower';
  }, pose: (tester, home) async {
    await _centre(tester, home);
    await tester.tap(find.byType(DockButton).at(0));
    await _wait(tester, 200);
    final c = home.sim.pos;
    final r = home.sim.radius;
    home.sim.pointerDown(1, c + Offset(-r * 0.7, -r * 0.3));
    for (var i = 0; i < 40; i++) {
      final t = i / 39;
      home.sim.pointerMove(1, c + Offset(-r * 0.7 + r * 1.3 * t, -r * 0.3 + r * 0.35 * (t * (1 - t)) * 4));
      await _wait(tester, 32);
    }
  }),
  _Scene('3_snacks', hour: 12, setup: (s) {
    _progress(s, fluff: 66);
    s
      ..colorId = 'cream'
      ..accessoryId = 'chef';
  }, pose: (tester, home) async {
    await _centre(tester, home);
    await tester.tap(find.byType(DockButton).at(1));
    await _wait(tester, 700);
    home.sim.eat(favorite: true);
    await _wait(tester, 650);
  }),
  _Scene('4_play', hour: 17, setup: (s) {
    _progress(s, fluff: 72);
    s
      ..colorId = 'sky'
      ..accessoryId = 'party';
  }, pose: (tester, home) async {
    await _centre(tester, home);
    home.sim.holdExpression(Expr.giggle);
    final c = home.sim.pos;
    home.sim.pointerDown(1, c);
    await _wait(tester, 520); // hold → ready to pick up
    for (var i = 1; i <= 20; i++) {
      home.sim.pointerMove(1, c + Offset(i * 1.5, -i * 9.0));
      await _wait(tester, 32);
    }
    home.sim.holdExpression(Expr.giggle);
    await _wait(tester, 120);
  }),
  _Scene('5_wardrobe', hour: 11, setup: (s) {
    _progress(s, fluff: 100);
    s
      ..colorId = 'lavender'
      ..accessoryId = 'crown';
  }, pose: (tester, home) async {
    await _wait(tester, 600);
    await tester.tap(find.byType(DockButton).at(2));
    await _centre(tester, home);
  }),
  _Scene('6_night', hour: 23, setup: (s) {
    _progress(s, fluff: 85);
    s
      ..colorId = 'starry'
      ..accessoryId = 'none';
  }, pose: (tester, home) async {
    await _wait(tester, 600);
    home.sim.idleTime = 999;
    await _wait(tester, 2600);
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
              color: dark.contains(scenes[i]) ? Colors.white : const Color(0xFF4A3542),
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
    await tester.runAsync(_loadFonts);
    await tester.runAsync(_renderCaptions);
    tester.view
      ..physicalSize = const Size(1320, 2868)
      ..devicePixelRatio = 3
      ..padding = const FakeViewPadding(top: 62 * 3, bottom: 34 * 3)
      ..viewPadding = const FakeViewPadding(top: 62 * 3, bottom: 34 * 3);
    addTearDown(tester.view.reset);

    for (final lang in _langs) {
      for (final scene in _scenes) {
        SharedPreferences.setMockInitialValues({});
        final clock = DateTime(2026, 10, 7, scene.hour, 5);
        final store = PetStore(clock: () => clock);
        await store.load();
        scene.setup(store);
        final services = AppServices(store: store, config: RemoteConfigService(), sfx: Sfx.instance, clock: () => clock);
        final key = GlobalKey();
        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pumpWidget(RepaintBoundary(key: key, child: MofuApp(services: services, locale: Locale(lang))));
        await tester.pump(const Duration(milliseconds: 50));
        final home = tester.state<HomeScreenState>(find.byType(HomeScreen));
        await scene.pose(tester, home);
        final boundary = key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
        final png = await tester.runAsync(() async {
          final img = await boundary.toImage(pixelRatio: 3);
          final data = await img.toByteData(format: ui.ImageByteFormat.png);
          return data!.buffer.asUint8List();
        });
        File('build/screenshots/raw/$lang/${scene.id}.png')
          ..createSync(recursive: true)
          ..writeAsBytesSync(png!);
        home.sim.pointerCancel(1);
        await store.flush();
      }
    }
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(seconds: 1));
  }, skip: true);
}
