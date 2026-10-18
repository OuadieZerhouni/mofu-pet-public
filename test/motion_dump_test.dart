// Dev tool, skipped by default: records the app's motion frame by frame for
// animation review (I can't watch the app run, so motion is judged on strips).
//
//   flutter test test/motion_dump_test.dart --run-skipped [--dart-define=ONLY=hatch]
//   python tools/motion/strips.py            # -> build/motion/<scenario>.gif + _strip.png
//
// Output: build/motion/<scenario>/<nnn>.png at 30 fps, 440×956 pt rendered at 1x.
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mofu_pet/core/app_scope.dart';
import 'package:mofu_pet/core/remote_config.dart';
import 'package:mofu_pet/l10n/app_localizations.dart';
import 'package:mofu_pet/main.dart';
import 'package:mofu_pet/model/house_store.dart';
import 'package:mofu_pet/ui/house/house_screen.dart';
import 'package:mofu_pet/ui/house/rooms.dart';
import 'package:mofu_pet/world/spa_session.dart';

import 'ux_dump_test.dart' show loadRealFonts, seededHouse;

const _only = String.fromEnvironment('ONLY');

class _Ctx {
  _Ctx(this.tester, this.home, this.store, this.key);
  final WidgetTester tester;
  final HouseScreenState home;
  final HouseStore store;
  final GlobalKey key;
  int frame = 0;
  String name = '';

  /// Advance [ms] in 1/60 s steps, saving every other frame (30 fps).
  Future<void> record(int ms, {void Function(int step)? each}) async {
    final steps = ms ~/ 16;
    for (var i = 0; i < steps; i++) {
      each?.call(i);
      await tester.pump(const Duration(microseconds: 16667));
      if (i.isEven) await _save();
    }
  }

  Future<void> _save() async {
    final boundary = key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
    final png = await tester.runAsync(() async {
      final img = await boundary.toImage(pixelRatio: 1);
      final data = await img.toByteData(format: ui.ImageByteFormat.png);
      return data!.buffer.asUint8List();
    });
    File('build/motion/$name/${(frame++).toString().padLeft(3, '0')}.png')
      ..createSync(recursive: true)
      ..writeAsBytesSync(png!);
  }

  Offset at(int friendIndex, {Offset delta = Offset.zero}) {
    final id = store.friends[friendIndex].id;
    final c = home.house.creature(id)!;
    return c.position + delta;
  }
}

typedef _Scenario = Future<void> Function(_Ctx x);

final _scenarios = <String, (int hour, bool eggReady, _Scenario)>{
  // Four friends idling: breathing, blinks, glances, nuzzles.
  'idle': (14, false, (x) async {
    await x.record(3000);
  }),
  // A tap on each friend in turn.
  'taps': (14, false, (x) async {
    for (var i = 0; i < 4; i++) {
      await x.tester.tapAt(x.at(i));
      await x.record(900);
    }
  }),
  // A friend arrives in a room from the shelf.
  'arrive': (14, false, (x) async {
    x.home.goTo(Room.kitchen);
    await x.tester.pump(const Duration(milliseconds: 900));
    x.home.house.moveFriend(x.store.friends[2].id, Room.kitchen);
    await x.record(1200);
  }),
  // Swiping to the next room.
  'swipe': (14, false, (x) async {
    await x.tester.timedDrag(find.byType(PageView), const Offset(-300, 0), const Duration(milliseconds: 220));
    await x.record(900);
  }),
  // Rubbing foam in the spa.
  'spa': (14, false, (x) async {
    x.home.house.moveFriend(x.store.friends[1].id, Room.spa);
    x.home.goTo(Room.spa);
    await x.tester.pump(const Duration(milliseconds: 1000));
    final c = x.home.house.scenes[Room.spa]!.creatures.first;
    final s = (roomModule(Room.spa) as dynamic).session as SpaSession?;
    await x.record(2000, each: (i) {
      final t = i / 60;
      s?.rub(c.position + Offset(c.radius * 0.7 * (t * 3 % 2 - 1), c.radius * 0.4 * ((t * 1.7) % 2 - 1)), 700, 1 / 60);
    });
  }),
  // The egg hatches.
  'hatch': (14, true, (x) async {
    x.home.goTo(Room.garden);
    await x.tester.pump(const Duration(milliseconds: 1000));
    final l = AppLocalizations.of(x.tester.element(find.byType(HouseScreen)));
    final label = l.eggLabel(l.gardenEggReadyHint);
    await x.tester.tap(find.byWidgetPredicate((w) => w is Semantics && w.properties.label == label).last);
    await x.record(2300);
  }),
  // Stars earned and a level-up.
  'reward': (14, false, (x) async {
    x.store.earn(StarSource.gift, 6);
    x.store.addXp(x.store.friends[0].id, 200);
    await x.record(1800);
  }),
  // Tapping shelf coins and a tool button (press feedback).
  'press': (14, false, (x) async {
    final coins = find.byType(GestureDetector);
    await x.tester.tapAt(x.tester.getCenter(coins.at(coins.evaluate().length - 2)));
    await x.record(700);
  }),
};

void main() {
  testWidgets('motion dump', (tester) async {
    await tester.runAsync(loadRealFonts);
    tester.view
      ..physicalSize = const Size(440, 956)
      ..devicePixelRatio = 1
      ..padding = const FakeViewPadding(top: 62, bottom: 34)
      ..viewPadding = const FakeViewPadding(top: 62, bottom: 34);
    addTearDown(tester.view.reset);
    for (final MapEntry(key: name, value: (hour, eggReady, run)) in _scenarios.entries) {
      if (_only.isNotEmpty && !_only.split(',').contains(name)) continue;
      final clock = DateTime(2026, 10, 17, hour, 5);
      final store = await seededHouse(clock);
      store.stars = eggReady ? 400 : 120;
      final key = GlobalKey();
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpWidget(RepaintBoundary(
        key: key,
        child: MofuApp(services: AppServices(store: store, config: RemoteConfigService(), clock: () => clock), locale: const Locale('en')),
      ));
      await tester.pump(const Duration(milliseconds: 600));
      final home = tester.state<HouseScreenState>(find.byType(HouseScreen));
      home.clearToasts();
      final dir = Directory('build/motion/$name');
      if (dir.existsSync()) dir.deleteSync(recursive: true);
      final x = _Ctx(tester, home, store, key)..name = name;
      await run(x);
      final nav = Navigator.of(tester.element(find.byType(HouseScreen, skipOffstage: false)));
      while (nav.canPop()) {
        nav.pop();
        await tester.pump(const Duration(milliseconds: 300));
      }
    }
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(seconds: 1));
  }, skip: true);
}
