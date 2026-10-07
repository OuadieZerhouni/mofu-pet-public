import 'dart:async';
import 'dart:io' show Platform;
import 'dart:math' as math;

import 'package:audio_session/audio_session.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_soloud/flutter_soloud.dart';

import 'test_env.dart';

/// Mofu's sound effects and haptics.
///
/// Becomes a silent no-op wherever audio is unavailable (`flutter test`, the
/// web preview, a failed init) — a pet that cannot squeak must still work.
///
/// Audio session: **ambient + mixWithOthers**. A pet's squeaks should obey
/// the silent switch and never stop the user's music; that is the opposite
/// trade from an instrument (see Ocarina Pocket), and deliberate.
class Sfx {
  Sfx._();
  static final Sfx instance = Sfx._();

  /// Every one-shot and loop the app plays. File: `assets/sounds/<id>.mp3` (loops: `.wav`, gapless).
  static const oneShots = [
    'squeak', 'squeak2', 'squeak3', 'giggle', 'hmph', 'pop', 'wee', 'whee', 'wobble', 'chew', 'yum',
    'nope', 'fanfare', 'sparkle', 'yawn', 'squish', 'coo', 'bonk', 'boing', 'unlock', 'hatch',
  ];
  static const loops = ['purr', 'brush', 'snore'];

  static const _volume = <String, double>{
    'purr': 0.55, 'brush': 0.45, 'snore': 0.35, 'bonk': 0.6, 'boing': 0.7, 'sparkle': 0.6,
  };

  SoLoud get _soloud => SoLoud.instance;
  final Map<String, AudioSource> _sources = {};
  final Map<String, SoundHandle> _loops = {};
  final math.Random _rng = math.Random();
  bool soundOn = true;
  bool hapticsOn = true;
  bool remoteSoundsEnabled = true;
  bool _ready = false;
  Future<void>? _initFuture;

  bool get isReady => _ready;
  bool get _audible => _ready && soundOn && remoteSoundsEnabled;

  Future<void> init() => _initFuture ??= _init();

  Future<void> _init() async {
    if (skipDeviceOnlyWork || kIsWeb) return;
    try {
      final session = await AudioSession.instance;
      await session.configure(const AudioSessionConfiguration(
        avAudioSessionCategory: AVAudioSessionCategory.ambient,
        avAudioSessionCategoryOptions: AVAudioSessionCategoryOptions.mixWithOthers,
        avAudioSessionMode: AVAudioSessionMode.defaultMode,
        androidAudioAttributes: AndroidAudioAttributes(
          contentType: AndroidAudioContentType.sonification,
          usage: AndroidAudioUsage.game,
        ),
        androidAudioFocusGainType: AndroidAudioFocusGainType.gainTransientMayDuck,
      ));
      if (Platform.isIOS) await session.setActive(true);
      session.interruptionEventStream.listen((e) {
        if (e.begin) stopAllLoops();
      });
      if (!_soloud.isInitialized) await _soloud.init(bufferSize: 1024);
      for (final id in [...oneShots, ...loops]) {
        final ext = loops.contains(id) ? 'wav' : 'mp3';
        try {
          _sources[id] = await _soloud.loadAsset('assets/sounds/$id.$ext');
        } catch (e) {
          debugPrint('sfx: missing $id ($e)');
        }
      }
      _ready = true;
    } catch (e) {
      debugPrint('sfx init failed: $e');
      _ready = false;
    }
  }

  /// Plays a one-shot. `squeak` picks one of three takes and varies pitch so
  /// repeated taps never sound like a loop.
  void play(String id) {
    if (!_audible) return;
    var key = id;
    var speed = 1.0;
    if (id == 'squeak') {
      key = const ['squeak', 'squeak2', 'squeak3'][_rng.nextInt(3)];
      speed = 0.92 + _rng.nextDouble() * 0.2;
    } else if (id == 'boing' || id == 'pop' || id == 'bonk') {
      speed = 0.9 + _rng.nextDouble() * 0.2;
    }
    final src = _sources[key];
    if (src == null) return;
    try {
      final h = _soloud.play(src, volume: _volume[key] ?? 0.85);
      if (speed != 1.0) _soloud.setRelativePlaySpeed(h, speed);
    } catch (e) {
      debugPrint('sfx play $id: $e');
    }
  }

  void startLoop(String id) {
    if (!_audible || _loops.containsKey(id)) return;
    final src = _sources[id];
    if (src == null) return;
    try {
      final h = _soloud.play(src, volume: 0, looping: true);
      _loops[id] = h;
      _soloud.fadeVolume(h, _volume[id] ?? 0.5, const Duration(milliseconds: 180));
    } catch (e) {
      debugPrint('sfx loop $id: $e');
    }
  }

  void stopLoop(String id) {
    final h = _loops.remove(id);
    if (h == null || !_ready) return;
    try {
      _soloud.fadeVolume(h, 0, const Duration(milliseconds: 220));
      _soloud.scheduleStop(h, const Duration(milliseconds: 240));
    } catch (_) {}
  }

  void stopAllLoops() {
    for (final id in List<String>.of(_loops.keys)) {
      stopLoop(id);
    }
  }

  void haptic(String kind) {
    if (!hapticsOn || kIsWeb) return;
    switch (kind) {
      case 'light':
        HapticFeedback.lightImpact();
      case 'medium':
        HapticFeedback.mediumImpact();
      case 'heavy':
        HapticFeedback.heavyImpact();
      case 'success':
        HapticFeedback.mediumImpact();
        Future<void>.delayed(const Duration(milliseconds: 120), HapticFeedback.lightImpact);
      default:
        HapticFeedback.selectionClick();
    }
  }
}
