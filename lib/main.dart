import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'audio/audio_engine.dart';
import 'core/app_scope.dart';
import 'core/debug_flags.dart';
import 'core/remote_config.dart';
import 'creatures/creature.dart';
import 'l10n/app_localizations.dart';
import 'model/house_store.dart';
import 'ui/house/house_screen.dart';
import 'ui/theme.dart';

/// Startup order:
///  1. the household store loads first (and migrates a v1 save) — everything
///     on screen reads it;
///  2. remote config serves its cache immediately and refreshes in the
///     background (launch never waits on the network);
///  3. audio initialises in the background — the first frame does not wait
///     for sound files to decode.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  final store = HouseStore();
  await store.load();
  if (DebugFlags.resetFirstRun) await store.reset();
  applyDebugSeed(store);
  final config = RemoteConfigService();
  await config.init();
  final audio = AudioEngine.instance
    ..soundOn = store.soundOn
    ..hapticsOn = store.hapticsOn;
  unawaited(audio.init(priority: const ['ui.tap', 'ui.pop', 'mofu.squeak', 'mofu.boing', 'mofu.giggle', 'mofu.purr']));
  runApp(MofuApp(services: AppServices(store: store, config: config, audio: audio)));
}

/// Screenshot / QA seam: a household with every friend, stars and progress.
void applyDebugSeed(HouseStore store) {
  if (DebugFlags.seedFluff < 0) return;
  if (store.friends.isEmpty) {
    store.adopt(Species.mofu).fluff = DebugFlags.seedFluff.clamp(0, 100).toDouble();
    store.stars = 400;
    while (store.eggReady && store.friends.length < 6) {
      store.hatch();
    }
  }
  store.completeFirstRun();
  for (final s in ['pet', 'rooms', 'spa']) {
    store.completeCoach(s);
  }
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
        home: const HouseScreen(),
      ),
    );
  }
}
