/// Every sound the house can play, keyed by a namespaced id
/// (`mofu.squeak`, `wuff.bark2`, `boop.boop_04`, `spa.foam`, `sleep.rain`,
/// `ui.unlock`). Species ids come straight from their catalogues, so a
/// creature event's id is always playable as-is.
library;

import '../creatures/boop/boop_catalog.dart';
import '../creatures/oink/oink_catalog.dart';
import '../creatures/wuff/wuff_catalog.dart';

class SoundDef {
  const SoundDef(this.asset, {this.loop = false, this.gain = 0.85});
  final String asset;
  final bool loop;
  final double gain;
}

/// Sleep-mixer channels in display order (ids `sleep.<channel>`).
const sleepChannels = ['rain', 'purr', 'fire', 'ocean', 'chimes', 'noise'];

/// Spa loops (follow the finger's speed) and one-shots.
const spaLoops = ['foam', 'water', 'towel', 'dryer'];

class SoundBank {
  SoundBank._();

  static const _mofuOneShots = [
    'squeak', 'squeak2', 'squeak3', 'giggle', 'hmph', 'pop', 'wee', 'whee', 'wobble', 'chew', 'yum',
    'nope', 'fanfare', 'sparkle', 'yawn', 'squish', 'coo', 'bonk', 'boing', 'unlock', 'hatch',
  ];
  static const _mofuLoops = {'purr': 0.55, 'brush': 0.45, 'snore': 0.35};
  static const _mofuGains = {'bonk': 0.6, 'boing': 0.7, 'sparkle': 0.6};

  static final Map<String, SoundDef> all = _build();

  /// Extra species registered at runtime (keeps this file free of imports
  /// from species that are still being added).
  static void register(Map<String, String> sounds, {Set<String> loops = const {}, Map<String, double> gains = const {}}) {
    for (final e in sounds.entries) {
      all[e.key] = SoundDef(e.value, loop: loops.contains(e.key), gain: gains[e.key] ?? (loops.contains(e.key) ? 0.5 : 0.85));
    }
  }

  static Map<String, SoundDef> _build() {
    final m = <String, SoundDef>{};
    for (final id in _mofuOneShots) {
      m['mofu.$id'] = SoundDef('assets/sounds/$id.mp3', gain: _mofuGains[id] ?? 0.85);
    }
    for (final e in _mofuLoops.entries) {
      m['mofu.${e.key}'] = SoundDef('assets/sounds/${e.key}.wav', loop: true, gain: e.value);
    }
    for (final e in wuffSounds.entries) {
      final loop = wuffLoops.contains(e.key);
      m[e.key] = SoundDef(e.value, loop: loop, gain: wuffSoundGains[e.key] ?? (loop ? 0.5 : 0.85));
    }
    for (final e in oinkSounds.entries) {
      final loop = oinkLoops.contains(e.key);
      m[e.key] = SoundDef(e.value, loop: loop, gain: loop ? 0.35 : 0.85);
    }
    for (final e in boopSounds.entries) {
      m[e.key] = SoundDef(e.value, gain: 0.8);
    }
    // UI (shared, reuse Mofu's crafted one-shots).
    for (final id in ['unlock', 'hatch', 'fanfare', 'sparkle', 'pop', 'boing']) {
      m['ui.$id'] = SoundDef('assets/sounds/$id.mp3', gain: 0.8);
    }
    m['ui.tap'] = const SoundDef('assets/sounds/pop.mp3', gain: 0.35);
    m['ui.land'] = const SoundDef('assets/sounds/squish.mp3', gain: 0.45);
    // Spa and sleep (assets/sounds/spa, assets/sounds/sleep).
    for (final id in spaLoops) {
      m['spa.$id'] = SoundDef('assets/sounds/spa/$id.ogg', loop: true, gain: 0.7);
    }
    m['spa.bubble'] = const SoundDef('assets/sounds/spa/bubble.mp3', gain: 0.6);
    m['spa.done'] = const SoundDef('assets/sounds/spa/done.mp3', gain: 0.75);
    for (final ch in sleepChannels) {
      m['sleep.$ch'] = SoundDef('assets/sounds/sleep/$ch.ogg', loop: true, gain: 1);
    }
    return m;
  }

  static SoundDef? def(String id) => all[id];
}
