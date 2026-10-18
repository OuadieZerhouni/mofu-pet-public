// Dev tool, skipped by default: renders every room, sheet and game of the real
// app to PNG for visual QA (design-vs-build review on the canvas).
//
//   flutter test test/ux_dump_test.dart --run-skipped
//
// Output: build/ux/<lang>_<state>.png at 440×956 @2x with the real fonts.
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mofu_pet/core/app_scope.dart';
import 'package:mofu_pet/core/remote_config.dart';
import 'package:mofu_pet/creatures/creature.dart';
import 'package:mofu_pet/main.dart';
import 'package:mofu_pet/model/house_store.dart';
import 'package:mofu_pet/ui/games/boop_rush_screen.dart';
import 'package:mofu_pet/ui/games/snack_catch_screen.dart';
import 'package:mofu_pet/ui/house/house_screen.dart';
import 'package:mofu_pet/ui/house/photo_booth.dart';
import 'package:mofu_pet/ui/house/rooms.dart';
import 'package:mofu_pet/world/spa_session.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _langs = String.fromEnvironment('LANGS', defaultValue: 'en');

Future<void> _font(String family, String path) async {
  final bytes = File(path).readAsBytesSync();
  final loader = FontLoader(family)..addFont(Future.value(ByteData.sublistView(Uint8List.fromList(bytes))));
  await loader.load();
}

Future<void> loadRealFonts() async {
  await _font('Nunito', 'assets/fonts/Nunito.ttf');
  await _font('BalooBhaijaan2', 'assets/fonts/BalooBhaijaan2.ttf');
  final sdk = File(Platform.resolvedExecutable).parent.parent.parent.parent.parent.parent.path;
  final icons = '$sdk/bin/cache/artifacts/material_fonts/materialicons-regular.otf';
  if (File(icons).existsSync()) await _font('MaterialIcons', icons);
  // Without a Japanese font every ja string renders as tofu boxes.
  const jp = [
    '/System/Library/Fonts/ヒラギノ丸ゴ ProN W4.ttc', // macOS: the font iOS falls back to
    r'C:\Windows\Fonts\YuGothB.ttc',
  ];
  final jpFont = jp.where((p) => File(p).existsSync()).firstOrNull;
  if (jpFont == null) throw StateError('no Japanese font found; ja renders would be tofu');
  await _font('Hiragino Maru Gothic ProN', jpFont);
}

Future<void> _wait(WidgetTester tester, int ms) async {
  for (var i = 0; i < ms ~/ 16; i++) {
    await tester.pump(const Duration(milliseconds: 16));
  }
}

Future<void> _shot(WidgetTester tester, GlobalKey key, String name) async {
  final boundary = key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
  final png = await tester.runAsync(() async {
    final img = await boundary.toImage(pixelRatio: 2);
    final data = await img.toByteData(format: ui.ImageByteFormat.png);
    return data!.buffer.asUint8List();
  });
  File('build/ux/$name.png')
    ..createSync(recursive: true)
    ..writeAsBytesSync(png!);
}

/// A household with every species, some progress and a ready egg.
Future<HouseStore> seededHouse(DateTime clock) async {
  SharedPreferences.setMockInitialValues({});
  final store = HouseStore(clock: () => clock);
  await store.load();
  final m = store.adopt(Species.mofu, name: 'Mofu')..fluff = 72;
  m.xp = 300;
  store.stars = 160;
  store.hatch(name: 'Truffle');
  store.hatch(name: 'Biscuit');
  store.hatch(name: 'Mochi');
  store.stars = 210;
  for (final f in store.friends) {
    f.xp = 160;
  }
  store.friends[1].wear['head'] = 'flower';
  store.friends[2].wear['neck'] = 'bandana';
  store.discovered.addAll(['mofu.boing', 'mofu.hug', 'oink.belly', 'oink.snout', 'wuff.earScratch', 'boop.boop', 'house.pileUp']);
  store.completeFirstRun();
  for (final s in ['pet', 'rooms', 'spa']) {
    store.completeCoach(s);
  }
  return store;
}

void main() {
  testWidgets('ux dump', (tester) async {
    await tester.runAsync(loadRealFonts);
    tester.view
      ..physicalSize = const Size(880, 1912)
      ..devicePixelRatio = 2
      ..padding = const FakeViewPadding(top: 62 * 2, bottom: 34 * 2)
      ..viewPadding = const FakeViewPadding(top: 62 * 2, bottom: 34 * 2);
    addTearDown(tester.view.reset);

    for (final lang in _langs.split(',')) {
      for (final hour in [14, 23]) {
        final clock = DateTime(2026, 10, 17, hour, 5);
        final store = await seededHouse(clock);
        final key = GlobalKey();
        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pumpWidget(RepaintBoundary(
          key: key,
          child: MofuApp(services: AppServices(store: store, config: RemoteConfigService(), clock: () => clock), locale: Locale(lang)),
        ));
        await _wait(tester, 400);
        final home = tester.state<HouseScreenState>(find.byType(HouseScreen));
        final tag = '${lang}_${hour < 20 ? 'day' : 'night'}';
        Future<void> room(Room r, String name, {Future<void> Function()? pose}) async {
          home.goTo(r);
          await _wait(tester, 700);
          if (pose != null) await pose();
          await _wait(tester, 500);
          await _shot(tester, key, '${tag}_$name');
        }

        await room(Room.living, '1_living');
        if (hour == 23) {
          await room(Room.bedroom, '4_bedroom', pose: () async {
            for (final f in store.friends.take(3)) {
              home.house.moveFriend(f.id, Room.bedroom);
            }
            await _wait(tester, 300);
            home.house.bedtime(true);
            await _wait(tester, 2200);
          });
          continue;
        }
        await room(Room.spa, '2_spa', pose: () async {
          home.house.moveFriend(store.friends[1].id, Room.spa);
          await _wait(tester, 300);
          final c = home.house.scenes[Room.spa]!.creatures.first;
          final s = (roomModule(Room.spa) as dynamic).session as SpaSession?;
          if (s != null) {
            for (var i = 0; i < 360; i++) {
              final t = i / 60;
              s.rub(c.position + Offset(c.radius * 0.7 * (t * 3 % 2 - 1), c.radius * 0.4 * ((t * 1.7) % 2 - 1)), 700, 1 / 60);
            }
          }
        });
        await room(Room.kitchen, '3_kitchen', pose: () async {
          home.house.moveFriend(store.friends[2].id, Room.kitchen);
          await _wait(tester, 300);
          home.house.scenes[Room.kitchen]!.creatures.first.eat(favorite: true);
        });
        await room(Room.bedroom, '4_bedroom');
        await room(Room.playroom, '5_playroom');
        await room(Room.garden, '6_garden', pose: () async {
          home.house.moveFriend(store.friends[3].id, Room.garden);
        });
        // Friend card tabs.
        home.goTo(Room.living);
        await _wait(tester, 700);
        final open = home.openFriend(store.friends[2].id);
        await _wait(tester, 700);
        await _shot(tester, key, '${tag}_7_card_play');
        for (final (i, label) in ['Wardrobe', 'Journal'].indexed) {
          final finder = find.text(label);
          if (finder.evaluate().isNotEmpty) {
            await tester.tap(finder.last);
            await _wait(tester, 400);
            await _shot(tester, key, '${tag}_${8 + i}_card_${label.toLowerCase()}');
          }
        }
        Navigator.of(tester.element(find.byType(HouseScreen))).pop();
        await _wait(tester, 500);
        await open;
        // Settings.
        await tester.tap(find.bySemanticsLabel(RegExp('Settings|設定|Einstellungen|Ajustes|Configurações|Réglages|الإعدادات')).first);
        await _wait(tester, 700);
        await _shot(tester, key, '${tag}_9_settings');
        Navigator.of(tester.element(find.byType(HouseScreen))).pop();
        await _wait(tester, 500);
        // Photo booth.
        final ctx = tester.element(find.byType(HouseScreen));
        // ignore: unawaited_futures
        showPhotoBooth(ctx, house: home.house);
        await _wait(tester, 900);
        await _shot(tester, key, '${tag}_10_photo');
        Navigator.of(ctx).pop();
        await _wait(tester, 500);
        // Games (mid-round).
        // ignore: unawaited_futures
        playBoopRush(ctx, store: store);
        await _wait(tester, 4500);
        await _shot(tester, key, '${tag}_11_boop_rush');
        Navigator.of(ctx).pop();
        await _wait(tester, 500);
        // ignore: unawaited_futures
        playSnackCatch(ctx, store: store, friend: store.friends[1]);
        await _wait(tester, 5000);
        await _shot(tester, key, '${tag}_12_snack_catch');
        Navigator.of(ctx).pop();
        await _wait(tester, 500);
      }
    }
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(seconds: 1));
  }, skip: true);
}
