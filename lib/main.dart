import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'core/app_scope.dart';
import 'core/debug_flags.dart';
import 'core/remote_config.dart';
import 'core/sfx.dart';
import 'l10n/app_localizations.dart';
import 'model/catalog.dart';
import 'model/pet_store.dart';
import 'ui/home_screen.dart';
import 'ui/theme.dart';

/// Startup order:
///  1. the store loads first — everything on screen reads it;
///  2. remote config serves its cache immediately and refreshes in the
///     background (launch never waits on the network);
///  3. audio initialises in the background — the first frame does not wait
///     for sound files to decode.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  final store = PetStore();
  await store.load();
  if (DebugFlags.resetFirstRun) await store.reset();
  _applyDebugSeed(store);
  final config = RemoteConfigService();
  await config.init();
  final sfx = Sfx.instance
    ..soundOn = store.soundOn
    ..hapticsOn = store.hapticsOn;
  unawaited(sfx.init());
  runApp(MofuApp(services: AppServices(store: store, config: config, sfx: sfx)));
}

/// Screenshot seam: a seeded fluff level with the wardrobe fully open.
void _applyDebugSeed(PetStore store) {
  if (DebugFlags.seedFluff < 0) return;
  store
    ..firstRunDone = true
    ..coachDone = true
    ..fluff = DebugFlags.seedFluff.clamp(0, 100).toDouble()
    ..visitDays = 30
    ..snacksFed = 20;
  store.discovered.addAll(Catalog.reactions.take(18).map((r) => r.id));
}

class MofuApp extends StatelessWidget {
  const MofuApp({super.key, required this.services, this.locale});

  final AppServices services;

  /// Forces a locale (tests, screenshots); null = follow the device.
  final Locale? locale;

  @override
  Widget build(BuildContext context) {
    return AppScope(
      services: services,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
        locale: locale ?? DebugFlags.forcedLocale,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        builder: (context, child) {
          final loc = Localizations.localeOf(context);
          return Theme(data: mofuTheme(loc), child: child!);
        },
        theme: mofuTheme(const Locale('en')),
        home: const HomeScreen(),
      ),
    );
  }
}
