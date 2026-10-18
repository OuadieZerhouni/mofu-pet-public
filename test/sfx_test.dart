import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mofu_pet/audio/audio_engine.dart';

/// SPEC F2-c8 / F10-c1 (from v1, ported to the flagship's AudioEngine):
/// haptics reach the OS only while the setting is on.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('haptics fire when on and are silent when off', () async {
    final calls = <String>[];
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async {
        if (call.method == 'HapticFeedback.vibrate') calls.add(call.arguments as String);
        return null;
      },
    );
    addTearDown(() => TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, null));
    final audio = AudioEngine.instance;
    final before = audio.hapticsOn;
    audio.forceDeviceWork = true;
    addTearDown(() {
      audio
        ..hapticsOn = before
        ..forceDeviceWork = false;
    });

    audio.hapticsOn = true;
    audio.haptic('light');
    await Future<void>.delayed(Duration.zero);
    expect(calls, ['HapticFeedbackType.lightImpact']);

    calls.clear();
    audio.hapticsOn = false;
    for (final k in ['light', 'medium', 'heavy', 'success']) {
      audio.haptic(k);
    }
    await Future<void>.delayed(Duration.zero);
    expect(calls, isEmpty);
  });
}
