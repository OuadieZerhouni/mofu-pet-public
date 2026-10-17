/// Sound and haptics for the whole house.
///
/// - One-shots and loops from [SoundBank], loaded in the background after
///   launch (a sound not loaded yet is simply skipped).
/// - Loops are keyed by an owner key (`<friendId>/<soundId>`), so two friends
///   can purr at once and each stops its own.
/// - Spa loops follow the finger: [loopGain] fades to the speed-derived gain.
/// - The sleep mixer switches the audio session to **playback** (keeps going
///   with the screen locked, needs `UIBackgroundModes audio`) and back to
///   **ambient + mixWithOthers** when it stops, so day-to-day squeaks never
///   interrupt the user's music and obey the silent switch.
///
/// A silent no-op wherever audio is unavailable (tests, web, failed init).
library;

import 'dart:async';
import 'dart:io' show Platform;
import 'dart:math' as math;

import 'package:audio_session/audio_session.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_soloud/flutter_soloud.dart';

import '../core/test_env.dart';
import 'sound_bank.dart';

class AudioEngine extends ChangeNotifier {
  AudioEngine._();
  static final AudioEngine instance = AudioEngine._();

  SoLoud get _soloud => SoLoud.instance;
  final Map<String, AudioSource> _sources = {};
  final Map<String, SoundHandle> _loops = {};
  final Map<String, SoundHandle> _mixer = {};
  final math.Random _rng = math.Random();

  bool soundOn = true;
  bool hapticsOn = true;
  bool remoteSoundsEnabled = true;
  bool _ready = false;
  Future<void>? _initFuture;
  AudioSession? _session;

  bool get isReady => _ready;
  bool get _audible => _ready && soundOn && remoteSoundsEnabled;

  // ── setup ─────────────────────────────────────────────────────────────
  Future<void> init({List<String> priority = const []}) => _initFuture ??= _init(priority);

  Future<void> _init(List<String> priority) async {
    if (skipDeviceOnlyWork || kIsWeb) return;
    try {
      _session = await AudioSession.instance;
      await _ambient();
      _session!.interruptionEventStream.listen((e) {
        if (e.begin) {
          stopAllLoops();
          _pauseMixer(true);
        } else {
          _pauseMixer(false);
        }
      });
      if (!_soloud.isInitialized) await _soloud.init(bufferSize: 1024);
      _ready = true;
      // Load the sounds people hear first, then everything else.
      final ids = [...priority, ...SoundBank.all.keys.where((k) => !priority.contains(k))];
      unawaited(_loadAll(ids));
    } catch (e) {
      debugPrint('audio init failed: $e');
      _ready = false;
    }
  }

  Future<void> _loadAll(List<String> ids) async {
    for (final id in ids) {
      await _load(id);
    }
  }

  Future<AudioSource?> _load(String id) async {
    final have = _sources[id];
    if (have != null) return have;
    final def = SoundBank.def(id);
    if (def == null) return null;
    try {
      final src = await _soloud.loadAsset(def.asset);
      _sources[id] = src;
      return src;
    } catch (e) {
      debugPrint('audio: missing $id (${def.asset})');
      return null;
    }
  }

  Future<void> _ambient() async {
    await _session?.configure(const AudioSessionConfiguration(
      avAudioSessionCategory: AVAudioSessionCategory.ambient,
      avAudioSessionCategoryOptions: AVAudioSessionCategoryOptions.mixWithOthers,
      avAudioSessionMode: AVAudioSessionMode.defaultMode,
      androidAudioAttributes: AndroidAudioAttributes(
        contentType: AndroidAudioContentType.sonification,
        usage: AndroidAudioUsage.game,
      ),
      androidAudioFocusGainType: AndroidAudioFocusGainType.gainTransientMayDuck,
    ));
    if (!kIsWeb && Platform.isIOS) await _session?.setActive(true);
  }

  Future<void> _playback() async {
    await _session?.configure(const AudioSessionConfiguration(
      avAudioSessionCategory: AVAudioSessionCategory.playback,
      avAudioSessionCategoryOptions: AVAudioSessionCategoryOptions.mixWithOthers,
      avAudioSessionMode: AVAudioSessionMode.defaultMode,
      androidAudioAttributes: AndroidAudioAttributes(
        contentType: AndroidAudioContentType.music,
        usage: AndroidAudioUsage.media,
      ),
      androidAudioFocusGainType: AndroidAudioFocusGainType.gain,
    ));
    if (!kIsWeb && Platform.isIOS) await _session?.setActive(true);
  }

  // ── one-shots ─────────────────────────────────────────────────────────
  /// Plays [id] at [pitch] (playback speed) and [gain] (× the bank gain).
  /// `mofu.squeak` picks one of three takes with a little pitch variation.
  void play(String id, {double pitch = 1, double gain = 1}) {
    if (!_audible) return;
    var key = id;
    var speed = pitch <= 0 ? 1.0 : pitch;
    if (id == 'mofu.squeak') {
      key = const ['mofu.squeak', 'mofu.squeak2', 'mofu.squeak3'][_rng.nextInt(3)];
      speed *= 0.92 + _rng.nextDouble() * 0.2;
    } else if (id == 'mofu.boing' || id == 'mofu.pop' || id == 'mofu.bonk') {
      speed *= 0.9 + _rng.nextDouble() * 0.2;
    }
    final src = _sources[key];
    final def = SoundBank.def(key);
    if (src == null || def == null) {
      if (def != null) unawaited(_load(key));
      return;
    }
    try {
      final h = _soloud.play(src, volume: def.gain * gain);
      if (speed != 1.0) _soloud.setRelativePlaySpeed(h, speed.clamp(0.5, 2.0));
    } catch (e) {
      debugPrint('audio play $id: $e');
    }
  }

  // ── loops ─────────────────────────────────────────────────────────────
  /// Starts loop [soundId] under [key] (e.g. `f3/mofu.purr`).
  void loopStart(String key, String soundId, {double gain = 1}) {
    if (!_audible || _loops.containsKey(key)) return;
    final src = _sources[soundId];
    final def = SoundBank.def(soundId);
    if (src == null || def == null) {
      if (def != null) unawaited(_load(soundId));
      return;
    }
    try {
      final h = _soloud.play(src, volume: 0, looping: true);
      _loops[key] = h;
      _soloud.fadeVolume(h, def.gain * gain, const Duration(milliseconds: 180));
    } catch (e) {
      debugPrint('audio loop $soundId: $e');
    }
  }

  /// Fades a running loop to [gain] (0..1 × bank gain) — spa loops follow the finger.
  void loopGain(String key, String soundId, double gain, {Duration fade = const Duration(milliseconds: 90)}) {
    final h = _loops[key];
    final def = SoundBank.def(soundId);
    if (h == null || def == null || !_ready) return;
    try {
      _soloud.fadeVolume(h, def.gain * gain.clamp(0, 1), fade);
    } catch (_) {}
  }

  bool isLooping(String key) => _loops.containsKey(key);

  void loopStop(String key) {
    final h = _loops.remove(key);
    if (h == null || !_ready) return;
    try {
      _soloud.fadeVolume(h, 0, const Duration(milliseconds: 220));
      _soloud.scheduleStop(h, const Duration(milliseconds: 240));
    } catch (_) {}
  }

  /// Stops every loop, or only those whose key starts with [prefix].
  void stopAllLoops({String prefix = ''}) {
    for (final k in List<String>.of(_loops.keys)) {
      if (k.startsWith(prefix)) loopStop(k);
    }
  }

  // ── sleep mixer ───────────────────────────────────────────────────────
  Timer? _sleepTimer;
  DateTime? _sleepEndsAt;
  bool _mixerOn = false;
  Map<String, double> _mix = {};

  bool get mixerOn => _mixerOn;
  DateTime? get sleepEndsAt => _sleepEndsAt;

  /// Starts (or retunes) the mixer with per-channel volumes 0..1 and an
  /// optional fade-out timer in minutes (0 = no timer).
  Future<void> mixerStart(Map<String, double> volumes, {int timerMinutes = 0}) async {
    _mix = Map.of(volumes);
    _mixerOn = true;
    if (_ready && soundOn) {
      await _playback();
      for (final ch in sleepChannels) {
        mixerSet(ch, _mix[ch] ?? 0);
      }
    }
    _sleepTimer?.cancel();
    if (timerMinutes > 0) {
      _sleepEndsAt = DateTime.now().add(Duration(minutes: timerMinutes));
      _sleepTimer = Timer(Duration(minutes: timerMinutes), () => unawaited(mixerStop(fade: const Duration(seconds: 20))));
    } else {
      _sleepEndsAt = null;
    }
    notifyListeners();
  }

  void mixerSet(String channel, double volume) {
    _mix[channel] = volume;
    if (!_mixerOn || !_ready || !soundOn) return;
    final id = 'sleep.$channel';
    final h = _mixer[channel];
    if (volume <= 0.001) {
      if (h != null) {
        try {
          _soloud.fadeVolume(h, 0, const Duration(milliseconds: 400));
          _soloud.scheduleStop(h, const Duration(milliseconds: 420));
        } catch (_) {}
        _mixer.remove(channel);
      }
      return;
    }
    if (h != null) {
      try {
        _soloud.fadeVolume(h, volume, const Duration(milliseconds: 250));
      } catch (_) {}
      return;
    }
    final src = _sources[id];
    if (src == null) {
      unawaited(_load(id).then((s) {
        if (s != null && _mixerOn && (_mix[channel] ?? 0) > 0.001) mixerSet(channel, _mix[channel]!);
      }));
      return;
    }
    try {
      final nh = _soloud.play(src, volume: 0, looping: true);
      _mixer[channel] = nh;
      _soloud.fadeVolume(nh, volume, const Duration(milliseconds: 900));
    } catch (e) {
      debugPrint('mixer $channel: $e');
    }
  }

  Future<void> mixerStop({Duration fade = const Duration(milliseconds: 800)}) async {
    _sleepTimer?.cancel();
    _sleepEndsAt = null;
    for (final h in _mixer.values) {
      try {
        _soloud.fadeVolume(h, 0, fade);
        _soloud.scheduleStop(h, fade + const Duration(milliseconds: 50));
      } catch (_) {}
    }
    _mixer.clear();
    final wasOn = _mixerOn;
    _mixerOn = false;
    notifyListeners();
    if (wasOn && _ready) {
      await Future<void>.delayed(fade);
      if (!_mixerOn) await _ambient();
    }
  }

  void _pauseMixer(bool pause) {
    if (!_ready) return;
    for (final h in _mixer.values) {
      try {
        _soloud.setPause(h, pause);
      } catch (_) {}
    }
  }

  // ── haptics ───────────────────────────────────────────────────────────
  void haptic(String kind) {
    if (!hapticsOn || kIsWeb || skipDeviceOnlyWork) return;
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
