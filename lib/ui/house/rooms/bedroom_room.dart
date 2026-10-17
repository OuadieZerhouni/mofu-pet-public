import 'dart:async';

import 'package:flutter/material.dart';

import '../../../audio/sound_bank.dart';
import '../../../l10n/app_localizations.dart';
import '../../../model/house_store.dart';
import '../../../world/house_controller.dart';
import '../../theme.dart';
import '../room_context.dart';

/// Bedroom: tuck friends in, a night light, and the sleep-sound mixer.
class BedroomRoom extends RoomModule {
  BedroomRoom();

  static final ValueNotifier<bool> lampOn = ValueNotifier(true);

  @override
  double get shelfExtra => 64;

  @override
  void onEnter(RoomContext rc) {
    if (rc.house.daypart == Daypart.night) rc.house.bedtime(true);
  }

  static String channelName(AppLocalizations l, String ch) => switch (ch) {
        'rain' => l.sleepRain,
        'purr' => l.sleepPurr,
        'fire' => l.sleepFire,
        'ocean' => l.sleepOcean,
        'chimes' => l.sleepChimes,
        _ => l.sleepNoise,
      };

  @override
  Widget? tools(BuildContext context, RoomContext rc) {
    final l = rc.l;
    final audio = rc.house.audio;
    return ListenableBuilder(
      listenable: Listenable.merge([audio, lampOn, rc.store]),
      builder: (context, _) {
        final allAsleep = rc.house.scenes[Room.bedroom]!.creatures.every((c) => c.asleep) && rc.house.scenes[Room.bedroom]!.creatures.isNotEmpty;
        return Row(
          children: [
            _ShelfButton(
              icon: lampOn.value ? Icons.lightbulb_rounded : Icons.lightbulb_outline_rounded,
              label: l.bedLamp,
              selected: lampOn.value,
              onTap: () {
                lampOn.value = !lampOn.value;
                audio.play('ui.tap');
                audio.haptic('selection');
              },
            ),
            const SizedBox(width: 8),
            _ShelfButton(
              icon: allAsleep ? Icons.wb_sunny_rounded : Icons.bedtime_rounded,
              label: allAsleep ? l.bedWakeUp : l.bedTuckIn,
              onTap: () {
                rc.house.bedtime(!allAsleep);
                if (!allAsleep) lampOn.value = false;
                audio.haptic('light');
              },
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _ShelfButton(
                icon: audio.mixerOn ? Icons.stop_circle_rounded : Icons.play_circle_rounded,
                label: audio.mixerOn
                    ? (audio.sleepEndsAt == null ? l.sleepStop : l.sleepEndsIn(audio.sleepEndsAt!.difference(DateTime.now()).inMinutes.clamp(0, 999) + 1))
                    : l.sleepSounds,
                selected: audio.mixerOn,
                wide: true,
                onTap: () {
                  if (audio.mixerOn) {
                    unawaited(audio.mixerStop());
                  } else {
                    unawaited(audio.mixerStart(rc.store.sleepMix, timerMinutes: rc.store.sleepTimerMin));
                    rc.store.discover('house.sleepSounds');
                  }
                },
              ),
            ),
            const SizedBox(width: 8),
            _ShelfButton(icon: Icons.tune_rounded, label: l.sleepMix, onTap: () => unawaited(showSleepMixer(context, rc))),
          ],
        );
      },
    );
  }
}

class _ShelfButton extends StatelessWidget {
  const _ShelfButton({required this.icon, required this.label, required this.onTap, this.selected = false, this.wide = false});
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool selected;
  final bool wide;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      excludeSemantics: true,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 54,
          constraints: BoxConstraints(minWidth: wide ? 0 : 64),
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: selected ? House.woodText : Colors.white.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: House.woodText.withValues(alpha: selected ? 1 : 0.55), width: 2.5),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 22, color: selected ? House.ink : House.woodText),
              Text(label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: selected ? House.ink : House.woodText)),
            ],
          ),
        ),
      ),
    );
  }
}

/// Mixer sheet: per-channel volume and the sleep timer.
Future<void> showSleepMixer(BuildContext context, RoomContext rc) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: const Color(0xFFF7F3FF),
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
    builder: (context) {
      final l = rc.l;
      final audio = rc.house.audio;
      return ListenableBuilder(
        listenable: Listenable.merge([rc.store, audio]),
        builder: (context, _) => SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(child: Text(l.sleepSounds, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: House.ink))),
                    Text(l.sleepScreenOff, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: House.lilac)),
                  ],
                ),
                const SizedBox(height: 8),
                for (final ch in sleepChannels)
                  Row(
                    children: [
                      SizedBox(width: 104, child: Text(BedroomRoom.channelName(l, ch), style: const TextStyle(fontWeight: FontWeight.w800, color: House.ink))),
                      Expanded(
                        child: Semantics(
                          label: l.sleepVolume(BedroomRoom.channelName(l, ch)),
                          child: Slider(
                            value: rc.store.sleepMix[ch] ?? 0,
                            activeColor: House.lilac,
                            onChanged: (v) {
                              rc.store.setMix(ch, v);
                              audio.mixerSet(ch, v);
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(l.sleepTimer, style: const TextStyle(fontWeight: FontWeight.w900, color: House.ink)),
                    const SizedBox(width: 10),
                    for (final m in const [0, 15, 30, 60])
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 3),
                          child: ChoiceChip(
                            label: Text(m == 0 ? l.sleepTimerOff : l.sleepMinutes(m)),
                            selected: rc.store.sleepTimerMin == m,
                            selectedColor: House.lilac,
                            labelStyle: TextStyle(fontWeight: FontWeight.w900, color: rc.store.sleepTimerMin == m ? Colors.white : House.ink),
                            showCheckmark: false,
                            onSelected: (_) {
                              rc.store.setSleepTimer(m);
                              if (audio.mixerOn) unawaited(audio.mixerStart(rc.store.sleepMix, timerMinutes: m));
                            },
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}
