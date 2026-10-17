import 'package:flutter/widgets.dart';

import '../audio/audio_engine.dart';
import '../model/house_store.dart';
import 'remote_config.dart';

/// The app's services, handed down the tree once.
///
/// Tests build their own scope with an in-memory store and a config whose
/// fetch never runs, so no widget reaches for a global.
class AppServices {
  AppServices({required this.store, required this.config, AudioEngine? audio, DateTime Function()? clock})
      : audio = audio ?? AudioEngine.instance,
        clock = clock ?? DateTime.now;

  final HouseStore store;
  final RemoteConfigService config;
  final AudioEngine audio;
  final DateTime Function() clock;
}

class AppScope extends InheritedWidget {
  const AppScope({super.key, required this.services, required super.child});

  final AppServices services;

  static AppServices of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppScope>();
    assert(scope != null, 'AppScope missing above $context');
    return scope!.services;
  }

  @override
  bool updateShouldNotify(AppScope oldWidget) => oldWidget.services != services;
}
