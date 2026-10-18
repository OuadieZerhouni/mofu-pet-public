import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../creatures/creature.dart';
import '../../../l10n/app_localizations.dart';
import '../../../model/house_store.dart';
import '../../../world/fx.dart';
import '../../name_dialog.dart';
import '../../theme.dart';
import '../photo_booth.dart';
import '../parts.dart';
import '../room_context.dart';

/// Garden: the hatchery egg on its nest, the daily gift and the photo booth.
class GardenRoom extends RoomModule {
  @override
  bool get hasTopCard => true;

  GardenRoom();

  /// Hatch animation clock (seconds since the tap), null when idle.
  double? _hatchT;

  /// The species of the egg being hatched (the store moves on to the next egg at the burst).
  Species? _hatchSpecies;
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
    _hatchSpecies = egg.species;
    rc.house.quiet = true;
    rc.lockPaging(true);
    // The garden page can be paged away during the animation; the dialog lives on the root
    // navigator so the hatch always completes, and the finally block never leaves it stuck.
    final host = Navigator.of(context, rootNavigator: true).context;
    final audio = rc.house.audio;
    final reduce = store.reduceMotion;
    Future<void> at(double s) {
      final wait = _hatchT == null ? 0.0 : s - (rc.house.time - _hatchT!);
      return Future<void>.delayed(Duration(milliseconds: (math.max(0.0, wait) * 1000).round()));
    }

    Friend? f;
    try {
      if (!reduce) {
        // Three growing wobbles, each spreading the crack (see _EggPainter.hatchCurve).
        for (final beat in _wobbleBeats) {
          await at(beat);
          audio.play('mofu.wobble', gain: 0.7 + beat * 0.25);
          audio.haptic(beat < 1 ? 'light' : 'medium');
        }
      }
      await at(reduce ? 0.3 : _burstAt);
      // Burst: the shell flies apart and the friend pops out right away.
      f = store.hatch(name: HouseStore.defaultName(egg.species));
      if (f == null) return;
      final scene = rc.house.scenes[Room.garden]!;
      final eggCentre = Offset(scene.area.center.dx, scene.floorY - 118 + 66);
      audio.play('ui.hatch');
      audio.haptic('success');
      rc.house.spawnFx(Room.garden, FxKind.ring, eggCentre, scale: 1.3);
      if (!reduce) rc.house.spawnFx(Room.garden, FxKind.confetti, eggCentre, scale: 1.1);
      if (!rc.house.moveFriend(f.id, Room.garden)) rc.house.sync();
      rc.house.enter(f.id, EntranceStyle.pop, from: eggCentre);
      store.discover('house.hatch.${f.species.name}');
      await at(_burstAt + 0.75);
      rc.house.creature(f.id)?.celebrate();
      audio.play('ui.fanfare');
      // Name the friend you have just met.
      await at(_burstAt + 1.5);
      if (host.mounted) {
        final name = await askName(
          host,
          initial: f.name,
          firstRun: true,
          title: rc.l.hatchNameTitle(speciesName(rc.l, egg.species)),
        );
        if (name != null && name != f.name) store.rename(f.id, name);
      }
      rc.toast(rc.l.toastNewFriend(store.friend(f.id)?.name ?? f.name));
    } finally {
      _hatchT = null;
      rc.house.quiet = false;
      rc.lockPaging(false);
    }
  }

  /// Seconds after the tap: the three wobble beats and the burst.
  static const _wobbleBeats = [0.35, 0.75, 1.1];
  static const _burstAt = 1.55;

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
              top: media.padding.top + 74,
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
                        species: hatchT != null ? (_hatchSpecies ?? egg.species) : egg.species,
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
                label: giftReady ? l.gardenGiftDay(store.nextGiftDay) : l.gardenGiftClaimed,
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

  /// Seconds since the hatch tap, or null.
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

  static const burst = GardenRoom._burstAt;

  /// The zig-zag the shell splits along, as fractions of the egg box.
  static const _crackLine = [
    Offset(0.13, 0.5), Offset(0.24, 0.43), Offset(0.33, 0.52), Offset(0.42, 0.41),
    Offset(0.5, 0.51), Offset(0.58, 0.4), Offset(0.67, 0.5), Offset(0.76, 0.42), Offset(0.87, 0.5),
  ];

  Path _egg(double w, double h) => Path()
    ..moveTo(w / 2, h * 0.08)
    ..cubicTo(w * 0.18, h * 0.08, w * 0.12, h * 0.55, w * 0.12, h * 0.66)
    ..cubicTo(w * 0.12, h * 0.86, w * 0.3, h * 0.94, w / 2, h * 0.94)
    ..cubicTo(w * 0.7, h * 0.94, w * 0.88, h * 0.86, w * 0.88, h * 0.66)
    ..cubicTo(w * 0.88, h * 0.55, w * 0.82, h * 0.08, w / 2, h * 0.08)
    ..close();

  /// Region above (top) or below the crack line, to cut the shell in two.
  Path _side(double w, double h, {required bool top}) {
    final p = Path()..moveTo(-w, _crackLine.first.dy * h);
    for (final c in _crackLine) {
      p.lineTo(c.dx * w, c.dy * h);
    }
    p
      ..lineTo(w * 2, _crackLine.last.dy * h)
      ..lineTo(w * 2, top ? -h : h * 2)
      ..lineTo(-w, top ? -h : h * 2)
      ..close();
    return p;
  }

  /// How far the crack has spread, 0..1: it grows in steps on the three wobble beats.
  double _crackAmount(double t) {
    var a = 0.0;
    for (final b in GardenRoom._wobbleBeats) {
      a += ((t - b) / 0.18).clamp(0.0, 1.0) / GardenRoom._wobbleBeats.length;
    }
    return a.clamp(0.0, 1.0);
  }

  void _paintShell(Canvas canvas, Size size, Path clip) {
    final w = size.width, h = size.height;
    canvas.save();
    canvas.clipPath(clip);
    final egg = _egg(w, h);
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
    canvas.restore();
  }

  void _paintCrack(Canvas canvas, Size size, double amount, double glow) {
    if (amount <= 0) return;
    final w = size.width, h = size.height;
    // Grows from the middle outward.
    final n = _crackLine.length;
    final mid = (n - 1) / 2;
    final reach = amount * mid;
    final pts = <Offset>[
      for (var i = 0; i < n; i++)
        if ((i - mid).abs() <= reach + 0.001) Offset(_crackLine[i].dx * w, _crackLine[i].dy * h),
    ];
    if (pts.length < 2) return;
    final path = Path()..addPolygon(pts, false);
    if (glow > 0) {
      canvas.drawPath(
          path,
          Paint()
            ..color = const Color(0xFFFFE08A).withValues(alpha: glow)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 9
            ..strokeJoin = StrokeJoin.round
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5));
    }
    canvas.drawPath(
        path,
        Paint()
          ..color = const Color(0xFFB98F5E)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3
          ..strokeJoin = StrokeJoin.round
          ..strokeCap = StrokeCap.round);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    final t = hatch;
    final pivot = Offset(w / 2, h * 0.92);
    if (t != null && t >= burst) {
      _paintBurst(canvas, size, t - burst);
      return;
    }
    var angle = 0.0, sx = 1.0, sy = 1.0;
    var crack = ready ? 0.25 : 0.0;
    var glow = 0.0;
    if (t != null) {
      crack = math.max(crack, _crackAmount(t));
      if (!reduceMotion) {
        // Anticipation: settle down into the nest.
        final settle = math.sin((t / 0.35).clamp(0.0, 1.0) * math.pi) * 0.06;
        // Each beat is a quick, decaying shake; later beats are bigger.
        var i = 0;
        for (final b in GardenRoom._wobbleBeats) {
          final u = t - b;
          if (u > 0 && u < 0.32) angle += math.sin(u * 42) * (0.1 + 0.06 * i) * (1 - u / 0.32);
          i++;
        }
        // Swell and glow just before it bursts.
        final swell = ((t - 1.3) / (burst - 1.3)).clamp(0.0, 1.0);
        sx = 1 + settle * 0.6 + swell * 0.1;
        sy = 1 - settle + swell * 0.12;
        glow = 0.25 + swell * 0.75;
      }
    } else if (!reduceMotion) {
      if (nudge < 0.6) {
        angle = math.sin(nudge * 28) * 0.1 * (1 - nudge / 0.6);
      } else if (ready) {
        final u = time % 2.4;
        angle = u < 0.5 ? math.sin(u * 25) * 0.08 : 0;
      }
    }
    canvas.save();
    canvas.translate(pivot.dx, pivot.dy);
    canvas.rotate(angle);
    canvas.scale(sx, sy);
    canvas.translate(-pivot.dx, -pivot.dy);
    canvas.drawPath(_egg(w, h).shift(const Offset(0, 4)), Paint()..color = const Color(0x22000000));
    _paintShell(canvas, size, Path()..addRect(Rect.fromLTWH(-w, -h, w * 3, h * 3)));
    _paintCrack(canvas, size, crack, glow);
    canvas.restore();
  }

  /// After the burst: the bottom cup stays in the nest and fades, the cap flies off spinning.
  void _paintBurst(Canvas canvas, Size size, double u) {
    final w = size.width, h = size.height;
    final fade = (1 - (u - 0.55) / 0.45).clamp(0.0, 1.0);
    if (fade <= 0) {
      _paintNextEgg(canvas, size, u - 1.0);
      return;
    }
    canvas.saveLayer(Rect.fromLTWH(-w, -h * 3, w * 3, h * 5), Paint()..color = Colors.white.withValues(alpha: fade));
    _paintShell(canvas, size, _side(w, h, top: false));
    if (u < 0.05) _paintCrack(canvas, size, 1, 1);
    // The cap: up and to the side, spinning, then falling.
    final k = reduceMotion ? 0.0 : u;
    canvas.save();
    canvas.translate(w * 0.5 - 70 * k, h * 0.45 - 260 * k + 520 * k * k);
    canvas.rotate(-2.6 * k);
    canvas.translate(-w * 0.5, -h * 0.45);
    _paintShell(canvas, size, _side(w, h, top: true));
    canvas.restore();
    canvas.restore();
  }

  /// The next egg pops in once the shell pieces are gone.
  void _paintNextEgg(Canvas canvas, Size size, double u) {
    if (u < 0) return;
    final k = math.min(1.0, u / 0.35);
    final s = 1 - math.pow(1 - k, 3) + math.sin(k * math.pi) * 0.12;
    final pivot = Offset(size.width / 2, size.height * 0.92);
    canvas.save();
    canvas.translate(pivot.dx, pivot.dy);
    canvas.scale(s.toDouble());
    canvas.translate(-pivot.dx, -pivot.dy);
    canvas.drawPath(_egg(size.width, size.height).shift(const Offset(0, 4)), Paint()..color = const Color(0x22000000));
    _paintShell(canvas, size, Path()..addRect(Rect.fromLTWH(-size.width, -size.height, size.width * 3, size.height * 3)));
    canvas.restore();
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
  Widget build(BuildContext context) => Squish(child: _build(context));

  Widget _build(BuildContext context) {
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
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(label, maxLines: 1, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: enabled ? House.ink : House.woodText)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
