import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../creatures/creature.dart';
import '../../../l10n/app_localizations.dart';
import '../../../model/house_store.dart';
import '../../name_dialog.dart';
import '../../theme.dart';
import '../photo_booth.dart';
import '../room_context.dart';

/// Garden: the hatchery egg on its nest, the daily gift and the photo booth.
class GardenRoom extends RoomModule {
  GardenRoom();

  /// Hatch animation clock (seconds since the tap), null when idle.
  double? _hatchT;
  double _nudgeT = -10;

  @override
  double get shelfExtra => 64;

  static String speciesName(AppLocalizations l, Species s) => switch (s) {
        Species.mofu => l.speciesMofu,
        Species.oink => l.speciesOink,
        Species.wuff => l.speciesWuff,
        Species.boop => l.speciesBoop,
      };

  Future<void> _tapEgg(BuildContext context, RoomContext rc) async {
    final store = rc.store;
    final egg = store.nextEgg;
    if (egg == null || _hatchT != null) return;
    if (!store.eggReady) {
      _nudgeT = rc.house.time;
      rc.house.audio.play('mofu.wobble');
      rc.house.audio.haptic('light');
      rc.toast(rc.l.gardenEggNotYet(egg.stars));
      return;
    }
    _hatchT = rc.house.time;
    rc.lockPaging(true);
    rc.house.audio.play('mofu.wobble');
    rc.house.audio.haptic('medium');
    await Future<void>.delayed(const Duration(milliseconds: 1500));
    rc.house.audio.play('ui.fanfare');
    rc.house.audio.haptic('success');
    await Future<void>.delayed(const Duration(milliseconds: 500));
    if (!context.mounted) return;
    final name = await askName(
      context,
      initial: HouseStore.defaultName(egg.species),
      firstRun: true,
      title: rc.l.hatchNameTitle(speciesName(rc.l, egg.species)),
    );
    final f = store.hatch(name: name);
    _hatchT = null;
    rc.lockPaging(false);
    if (f == null) return;
    // The newcomer arrives here in the garden so you can say hi right away.
    if (!rc.house.moveFriend(f.id, Room.garden)) rc.house.sync();
    rc.house.creature(f.id)?.celebrate();
    rc.toast(rc.l.toastNewFriend(f.name));
    store.discover('house.hatch.${f.species.name}');
  }

  @override
  Widget overlay(BuildContext context, RoomContext rc) {
    final media = MediaQuery.of(context);
    return ValueListenableBuilder<int>(
      valueListenable: rc.frame,
      builder: (context, _, _) {
        final l = rc.l;
        final store = rc.store;
        final egg = store.nextEgg;
        final scene = rc.house.scenes[Room.garden]!;
        final floor = scene.floorY;
        final ready = store.eggReady;
        final t = rc.house.time;
        final hatchT = _hatchT == null ? null : t - _hatchT!;
        return Stack(
          fit: StackFit.expand,
          children: [
            Positioned(
              top: media.padding.top + 64,
              left: 16,
              right: 16,
              child: IgnorePointer(child: _EggCard(l: l, store: store)),
            ),
            if (egg != null)
              Positioned(
                left: scene.area.center.dx - 60,
                top: floor - 118,
                width: 120,
                height: 120,
                child: Semantics(
                  button: true,
                  label: l.eggLabel(ready ? l.gardenEggReadyHint : l.gardenEggNotYet(egg.stars)),
                  child: GestureDetector(
                    onTap: () => unawaited(_tapEgg(context, rc)),
                    child: CustomPaint(
                      painter: _EggPainter(
                        time: t,
                        ready: ready,
                        hatch: hatchT,
                        nudge: t - _nudgeT,
                        species: egg.species,
                        reduceMotion: store.reduceMotion,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  @override
  Widget? tools(BuildContext context, RoomContext rc) {
    final l = rc.l;
    return ListenableBuilder(
      listenable: rc.store,
      builder: (context, _) {
        final store = rc.store;
        final giftReady = store.giftReady;
        return Row(
          children: [
            Expanded(
              child: _BigButton(
                icon: Icons.card_giftcard_rounded,
                label: giftReady ? l.gardenGiftDay(store.giftStreak + 1 > 7 ? 7 : store.giftStreak + 1) : l.gardenGiftClaimed,
                enabled: giftReady,
                onTap: () {
                  final got = store.claimGift();
                  if (got > 0) {
                    rc.house.audio.play('ui.unlock');
                    rc.house.audio.haptic('success');
                    rc.toast(l.toastGift(got));
                  }
                },
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _BigButton(
                icon: Icons.photo_camera_rounded,
                label: l.gardenPhotoBooth,
                enabled: store.friends.isNotEmpty,
                onTap: () => unawaited(showPhotoBooth(context, house: rc.house)),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _EggCard extends StatelessWidget {
  const _EggCard({required this.l, required this.store});
  final AppLocalizations l;
  final HouseStore store;

  @override
  Widget build(BuildContext context) {
    final egg = store.nextEgg;
    final ready = store.eggReady;
    final prevStars = store.eggsHatched == 0 ? 0 : HouseStore.eggSchedule()[store.eggsHatched - 1].stars;
    final progress = egg == null ? 1.0 : ((store.stars - prevStars) / math.max(1, egg.stars - prevStars)).clamp(0.0, 1.0);
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [BoxShadow(color: House.ink.withValues(alpha: 0.10), blurRadius: 14, offset: const Offset(0, 4))],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  egg == null ? l.gardenAllHatched : (ready ? l.gardenEggReadyTitle : l.gardenNextEgg(egg.stars)),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 17, color: House.ink),
                ),
              ),
              if (egg != null) Text(l.gardenProgress(math.min(store.stars, egg.stars), egg.stars), style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: House.leaf)),
            ],
          ),
          if (egg != null) ...[
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(5),
              child: LinearProgressIndicator(value: progress, minHeight: 10, color: const Color(0xFF4F8F5A), backgroundColor: const Color(0xFFE6F3DF)),
            ),
            const SizedBox(height: 8),
            Text(ready ? l.gardenEggReadyHint : l.gardenEggHint, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: House.inkSoft)),
          ],
        ],
      ),
    );
  }
}

/// The hatchery egg: wobbles when ready, cracks open when hatching. Its
/// spots hint at who is inside.
class _EggPainter extends CustomPainter {
  _EggPainter({required this.time, required this.ready, required this.hatch, required this.nudge, required this.species, required this.reduceMotion});
  final double time;
  final bool ready;
  final double? hatch;
  final double nudge;
  final Species species;
  final bool reduceMotion;

  static const _spot = {
    Species.mofu: Color(0xFFFFCDB8),
    Species.oink: Color(0xFFF7A9BD),
    Species.wuff: Color(0xFFE3A15F),
    Species.boop: Color(0xFF9FD3F0),
  };

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    var angle = 0.0;
    var scale = 1.0;
    if (!reduceMotion) {
      if (hatch != null) {
        angle = math.sin(hatch! * 30) * 0.18 * math.min(1, hatch! / 0.6);
        scale = 1 + math.min(0.15, hatch! * 0.08);
      } else if (nudge < 0.6) {
        angle = math.sin(nudge * 28) * 0.1 * (1 - nudge / 0.6);
      } else if (ready) {
        final t = time % 2.4;
        angle = t < 0.5 ? math.sin(t * 25) * 0.08 : 0;
      }
    }
    canvas.save();
    canvas.translate(w / 2, h * 0.92);
    canvas.rotate(angle);
    canvas.scale(scale);
    canvas.translate(-w / 2, -h * 0.92);
    final egg = Path()
      ..moveTo(w / 2, h * 0.08)
      ..cubicTo(w * 0.18, h * 0.08, w * 0.12, h * 0.55, w * 0.12, h * 0.66)
      ..cubicTo(w * 0.12, h * 0.86, w * 0.3, h * 0.94, w / 2, h * 0.94)
      ..cubicTo(w * 0.7, h * 0.94, w * 0.88, h * 0.86, w * 0.88, h * 0.66)
      ..cubicTo(w * 0.88, h * 0.55, w * 0.82, h * 0.08, w / 2, h * 0.08)
      ..close();
    canvas.drawPath(egg.shift(const Offset(0, 4)), Paint()..color = const Color(0x22000000));
    canvas.drawPath(
        egg,
        Paint()
          ..shader = const RadialGradient(center: Alignment(-0.3, -0.4), colors: [Color(0xFFFFFFFF), Color(0xFFFFF0DC)])
              .createShader(Offset.zero & size));
    final spot = Paint()..color = _spot[species]!;
    for (final d in const [Offset(0.38, 0.5), Offset(0.62, 0.42), Offset(0.55, 0.7), Offset(0.32, 0.72)]) {
      canvas.drawCircle(Offset(w * d.dx, h * d.dy), w * 0.06, spot);
    }
    canvas.drawPath(
        egg,
        Paint()
          ..color = const Color(0xFFE7CFAE)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.5);
    if (ready || hatch != null) {
      final crack = Path()
        ..moveTo(w * 0.3, h * 0.42)
        ..lineTo(w * 0.42, h * 0.36)
        ..lineTo(w * 0.5, h * 0.46)
        ..lineTo(w * 0.6, h * 0.36)
        ..lineTo(w * 0.7, h * 0.44);
      canvas.drawPath(
          crack,
          Paint()
            ..color = const Color(0xFFC9A879)
            ..style = PaintingStyle.stroke
            ..strokeWidth = hatch == null ? 2 : 3.5
            ..strokeJoin = StrokeJoin.round);
    }
    canvas.restore();
    if (hatch != null && hatch! > 1.2) {
      final a = ((hatch! - 1.2) / 0.5).clamp(0.0, 1.0);
      canvas.drawCircle(Offset(w / 2, h * 0.55), w * (0.3 + a), Paint()..color = Colors.white.withValues(alpha: 0.8 * (1 - (a - 0.5).abs() * 2).clamp(0, 1)));
    }
  }

  @override
  bool shouldRepaint(_EggPainter old) => true;
}

class _BigButton extends StatelessWidget {
  const _BigButton({required this.icon, required this.label, required this.onTap, this.enabled = true});
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      enabled: enabled,
      label: label,
      excludeSemantics: true,
      child: GestureDetector(
        onTap: enabled ? onTap : null,
        child: Container(
          height: 54,
          decoration: BoxDecoration(
            color: enabled ? House.woodText : Colors.white.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: House.woodText.withValues(alpha: enabled ? 1 : 0.5), width: 2.5),
            boxShadow: enabled ? const [BoxShadow(color: House.coinShadow, offset: Offset(0, 4))] : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: enabled ? House.rose : House.woodText, size: 22),
              const SizedBox(width: 8),
              Flexible(
                child: Text(label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: enabled ? House.ink : House.woodText)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
