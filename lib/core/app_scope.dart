import 'package:flutter/widgets.dart';

import '../model/pet_store.dart';
import 'remote_config.dart';
import 'sfx.dart';

/// The app's services, handed down the tree once.
///
/// Tests build their own scope with an in-memory store and a config whose
/// fetch never runs, so no widget reaches for a global.
class AppServices {
  AppServices({required this.store, required this.config, required this.sfx, DateTime Function()? clock})
      : clock = clock ?? DateTime.now;

  final PetStore store;
  final RemoteConfigService config;
  final Sfx sfx;
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
