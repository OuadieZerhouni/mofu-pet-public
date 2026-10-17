import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mofu_pet/l10n/app_localizations.dart';
import 'package:mofu_pet/model/house_store.dart';
import 'package:mofu_pet/ui/theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// An in-memory household, loaded the way the app loads it.
Future<HouseStore> memoryStore() async {
  SharedPreferences.setMockInitialValues({});
  final store = HouseStore(clock: () => DateTime(2026, 10, 17, 14));
  await store.load();
  return store;
}

/// A MaterialApp with the app's localisation, the real theme and a home with
/// one button, so the screen under test is opened (and closed) like in the app.
Widget gameHost(Future<void> Function(BuildContext context) open, {Locale locale = const Locale('en')}) {
  return MaterialApp(
    locale: locale,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    theme: mofuTheme(locale),
    home: Builder(
      builder: (context) => Scaffold(
        body: Center(child: TextButton(onPressed: () => open(context), child: const Text('open-game'))),
      ),
    ),
  );
}

/// A portrait phone, 430 x 900 logical unless told otherwise.
void phone(WidgetTester tester, {double width = 430, double height = 900}) {
  tester.view.physicalSize = Size(width * 3, height * 3);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

/// Pumps [seconds] of game time in fixed 100 ms frames (never pumpAndSettle:
/// the games animate forever), calling [each] after every frame.
Future<void> pumpFor(WidgetTester tester, double seconds, {void Function(int frame)? each}) async {
  final n = (seconds * 10).round();
  for (var i = 0; i < n; i++) {
    await tester.pump(const Duration(milliseconds: 100));
    each?.call(i);
  }
}

/// Pumps until [finder] matches or [maxSeconds] of game time have passed.
Future<bool> pumpUntil(WidgetTester tester, Finder finder, {double maxSeconds = 60, void Function(int frame)? each}) async {
  final n = (maxSeconds * 10).round();
  for (var i = 0; i < n; i++) {
    if (finder.evaluate().isNotEmpty) return true;
    await tester.pump(const Duration(milliseconds: 100));
    each?.call(i);
  }
  return finder.evaluate().isNotEmpty;
}

/// Lets the store's debounced save fire so no timer is left pending.
Future<void> settleStore(WidgetTester tester) async {
  await tester.pump(const Duration(seconds: 2));
}
