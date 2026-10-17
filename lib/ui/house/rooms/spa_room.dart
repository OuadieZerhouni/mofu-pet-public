import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../../../model/house_store.dart';
import '../../../world/spa_session.dart';
import '../../theme.dart';
import '../room_context.dart';

/// The ASMR spa: one friend on the mat, four tools in order.
class SpaRoom extends RoomModule {
  SpaRoom();

  SpaSession? session;
  String? _friendId;
  Offset? finger;
  Offset? _lastPos;
  DateTime? _lastTime;
  double speed = 0;
  bool _rewarded = false;

  @override
  double get shelfExtra => 86;

  String get _loopKey => 'spa/${session?.step.tool ?? ''}';

  void _ensureSession(RoomContext rc) {
    final scene = rc.house.scenes[Room.spa]!;
    final here = scene.creatures;
    if (here.isEmpty) {
      session?.abandon(); // unpins a friend moved out mid-routine
      session = null;
      _friendId = null;
      return;
    }
    final c = here.first;
    // Same friend AND the same creature: after a rebuild (Start over, a new house) the id can
    // repeat while the creature is new, and an old session would scrub a discarded body.
    if (session != null && identical(session!.creature, c)) return;
    session?.abandon();
    _friendId = c.friendId;
    session = SpaSession(c, seed: c.seed);
    _rewarded = false;
    c.position = Offset(scene.area.center.dx, c.position.dy);
    rc.house.say(c.friendId, 'bubble.hi');
  }

  void restart(RoomContext rc) {
    _friendId = null;
    session = null;
    _ensureSession(rc);
  }

  @override
  void onLeave(RoomContext rc) {
    rc.house.audio.stopAllLoops(prefix: 'spa/');
    final s = session;
    if (s != null && !s.finished) s.abandon();
    session = null;
    _friendId = null;
  }

  void _down(RoomContext rc, Offset p) {
    rc.lockPaging(true);
    finger = p;
    _lastPos = p;
    _lastTime = DateTime.now();
    final s = session;
    if (s == null || s.finished) return;
    rc.house.audio.loopStart(_loopKey, 'spa.${s.step.tool}', gain: 0.2);
  }

  void _move(RoomContext rc, Offset p) {
    final s = session;
    final now = DateTime.now();
    final dt = _lastTime == null ? 1 / 60 : (now.difference(_lastTime!).inMicroseconds / 1e6).clamp(1 / 240, 0.1);
    final d = _lastPos == null ? 0.0 : (p - _lastPos!).distance;
    speed = speed * 0.6 + (d / dt) * 0.4;
    finger = p;
    _lastPos = p;
    _lastTime = now;
    if (s == null || s.finished) return;
    final before = s.step;
    s.rub(p, speed, dt);
    final audio = rc.house.audio;
    audio.loopGain(_loopKey, 'spa.${before.tool}', (0.25 + speed / 1400).clamp(0.2, 1.0));
    for (final cue in s.drainCues()) {
      audio.play(cue);
      audio.haptic(cue == 'spa.done' ? 'success' : 'selection');
    }
    if (s.step != before) {
      audio.loopStop('spa/${before.tool}');
      if (!s.finished) audio.loopStart(_loopKey, 'spa.${s.step.tool}', gain: 0.4);
    }
    if (s.finished && !_rewarded) {
      _rewarded = true;
      final got = rc.store.finishSpa(s.creature.friendId);
      if (got > 0) rc.toast(rc.l.toastStars(got));
      rc.house.say(s.creature.friendId, 'bubble.fresh', seconds: 2.4);
      if (rc.store.discover('house.spa')) rc.toast(rc.l.spaFreshToast);
    }
  }

  void _up(RoomContext rc) {
    rc.lockPaging(false);
    finger = null;
    speed = 0;
    rc.house.audio.stopAllLoops(prefix: 'spa/');
  }

  @override
  Widget overlay(BuildContext context, RoomContext rc) {
    final top = MediaQuery.of(context).padding.top + 64;
    return ValueListenableBuilder<int>(
      valueListenable: rc.frame,
      builder: (context, _, _) {
        _ensureSession(rc);
        final s = session;
        final l = rc.l;
        final friend = _friendId == null ? null : rc.store.friend(_friendId!);
        final active = s != null && !s.finished;
        return Stack(
          fit: StackFit.expand,
          children: [
            if (active)
              Listener(
                behavior: HitTestBehavior.opaque,
                onPointerDown: (e) => _down(rc, e.localPosition),
                onPointerMove: (e) => _move(rc, e.localPosition),
                onPointerUp: (_) => _up(rc),
                onPointerCancel: (_) => _up(rc),
                child: CustomPaint(painter: _ToolPainter(finger: finger, step: s.step, time: rc.house.time, speed: speed)),
              ),
            Positioned(
              top: top,
              left: 16,
              right: 16,
              child: IgnorePointer(
                ignoring: active,
                child: _Ribbon(
                  title: friend == null ? l.spaEmptyTitle : l.spaTitle(friend.name),
                  step: s?.step,
                  progress: s?.progress ?? 0,
                  hint: s == null ? l.spaEmptyHint : _hint(l, s.step),
                  onAgain: s != null && s.finished ? () => restart(rc) : null,
                  againLabel: l.spaAgain,
                  stepLabels: [l.spaStepFoam, l.spaStepRinse, l.spaStepTowel, l.spaStepDry],
                  stepOf: (i, n) => l.spaStepOf(i, n),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  String _hint(AppLocalizations l, SpaStep step) => switch (step) {
        SpaStep.foam => l.spaHintFoam,
        SpaStep.rinse => l.spaHintRinse,
        SpaStep.towel => l.spaHintTowel,
        SpaStep.dry => l.spaHintDry,
        SpaStep.done => l.spaHintDone,
      };

  @override
  Widget? tools(BuildContext context, RoomContext rc) {
    final l = rc.l;
    return ValueListenableBuilder<int>(
      valueListenable: rc.frame,
      builder: (context, _, _) {
        final step = session?.step;
        Widget tool(SpaStep s, IconData icon, String label) {
          final current = step == s;
          final done = step != null && step.index > s.index;
          return Expanded(
            child: Semantics(
              label: label,
              selected: current,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                height: 74,
                margin: const EdgeInsets.symmetric(horizontal: 5),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: current ? House.woodText : Colors.white.withValues(alpha: 0.10),
                  border: Border.all(color: current ? House.woodText : House.woodText.withValues(alpha: 0.5), width: 3),
                  boxShadow: current ? const [BoxShadow(color: House.coinShadow, offset: Offset(0, 4))] : null,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(done ? Icons.check_circle_rounded : icon, size: 28, color: current ? House.ink : House.woodText),
                    const SizedBox(height: 2),
                    Text(label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: current ? House.ink : House.woodText)),
                  ],
                ),
              ),
            ),
          );
        }

        return Row(
          children: [
            tool(SpaStep.foam, Icons.bubble_chart_rounded, l.spaStepFoam),
            tool(SpaStep.rinse, Icons.shower_rounded, l.spaStepRinse),
            tool(SpaStep.towel, Icons.dry_cleaning_rounded, l.spaStepTowel),
            tool(SpaStep.dry, Icons.air_rounded, l.spaStepDry),
          ],
        );
      },
    );
  }
}

class _Ribbon extends StatelessWidget {
  const _Ribbon({
    required this.title,
    required this.step,
    required this.progress,
    required this.hint,
    required this.onAgain,
    required this.againLabel,
    required this.stepLabels,
    required this.stepOf,
  });
  final String title;
  final SpaStep? step;
  final double progress;
  final String hint;
  final VoidCallback? onAgain;
  final String againLabel;
  final List<String> stepLabels;
  final String Function(int, int) stepOf;

  @override
  Widget build(BuildContext context) {
    final idx = step?.index ?? -1;
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: House.ink.withValues(alpha: 0.10), blurRadius: 14, offset: const Offset(0, 4))],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(child: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: House.ink))),
              if (step != null && step != SpaStep.done)
                Text(stepOf(idx + 1, 4), style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: House.sky)),
            ],
          ),
          if (step != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                for (var i = 0; i < 4; i++)
                  Expanded(
                    child: Container(
                      height: 8,
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(4), color: const Color(0xFFD6EAF0)),
                      child: FractionallySizedBox(
                        alignment: AlignmentDirectional.centerStart,
                        widthFactor: i < idx || step == SpaStep.done ? 1 : (i == idx ? progress.clamp(0.0, 1.0) : 0),
                        child: Container(decoration: BoxDecoration(borderRadius: BorderRadius.circular(4), color: House.sky)),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                for (var i = 0; i < 4; i++)
                  Expanded(
                    child: Text(stepLabels[i],
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12, color: i == idx ? House.sky : const Color(0xFF5D6B70))),
                  ),
              ],
            ),
          ],
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: Text(hint, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: House.inkSoft))),
              if (onAgain != null)
                TextButton(onPressed: onAgain, child: Text(againLabel, style: const TextStyle(fontWeight: FontWeight.w900))),
            ],
          ),
        ],
      ),
    );
  }
}

/// The tool under the finger, plus its effect (water rain, dryer air).
class _ToolPainter extends CustomPainter {
  _ToolPainter({required this.finger, required this.step, required this.time, required this.speed});
  final Offset? finger;
  final SpaStep step;
  final double time;
  final double speed;

  @override
  void paint(Canvas canvas, Size size) {
    final f = finger;
    if (f == null) return;
    switch (step) {
      case SpaStep.foam:
        final r = RRect.fromRectAndRadius(Rect.fromCenter(center: f + const Offset(0, -34), width: 64, height: 40), const Radius.circular(14));
        canvas.drawRRect(r.shift(const Offset(0, 4)), Paint()..color = const Color(0x33000000));
        canvas.drawRRect(r, Paint()..color = const Color(0xFFF6D27A));
        for (final d in const [Offset(-16, -6), Offset(4, 4), Offset(16, -8), Offset(-4, -10)]) {
          canvas.drawCircle(f + const Offset(0, -34) + d, 3, Paint()..color = const Color(0xFFD9AE45));
        }
      case SpaStep.rinse:
        final head = f + const Offset(0, -60);
        final rng = math.Random((time * 30).floor());
        for (var i = 0; i < 18; i++) {
          final x = head.dx + (rng.nextDouble() - 0.5) * 50;
          final y0 = head.dy + 18 + ((time * 900 + i * 37) % 120);
          canvas.drawLine(Offset(x, y0), Offset(x, y0 + 12),
              Paint()
                ..color = const Color(0xAA6FB6D8)
                ..strokeWidth = 3
                ..strokeCap = StrokeCap.round);
        }
        final p = Path()..addArc(Rect.fromCircle(center: head + const Offset(0, 14), radius: 30), math.pi, math.pi);
        canvas.drawPath(p, Paint()..color = const Color(0xFFB8C6CF));
        canvas.drawRect(Rect.fromCenter(center: head + const Offset(26, -12), width: 10, height: 30), Paint()..color = const Color(0xFF8FA1AC));
      case SpaStep.towel:
        final r = RRect.fromRectAndRadius(Rect.fromCenter(center: f + const Offset(0, -30), width: 78, height: 54), const Radius.circular(10));
        canvas.drawRRect(r.shift(const Offset(0, 4)), Paint()..color = const Color(0x33000000));
        canvas.drawRRect(r, Paint()..color = const Color(0xFFF4C6CF));
        for (var i = 0; i < 4; i++) {
          canvas.drawLine(r.outerRect.topLeft + Offset(8 + i * 18.0, 0), r.outerRect.bottomLeft + Offset(8 + i * 18.0, 0),
              Paint()
                ..color = const Color(0xFFE9A9B7)
                ..strokeWidth = 2);
        }
      case SpaStep.dry:
        final n = f + const Offset(0, -44);
        for (var i = 0; i < 5; i++) {
          final t = (time * 2.5 + i / 5) % 1;
          final y = n.dy + 24 + t * 70;
          final x = n.dx + (i - 2) * 9 + math.sin(time * 12 + i) * 4;
          canvas.drawLine(Offset(x, y), Offset(x, y + 14),
              Paint()
                ..color = Colors.white.withValues(alpha: 0.8 * (1 - t))
                ..strokeWidth = 3
                ..strokeCap = StrokeCap.round);
        }
        canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: n, width: 70, height: 36), const Radius.circular(18)), Paint()..color = const Color(0xFF8E72F0));
        canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: n + const Offset(-18, 30), width: 16, height: 40), const Radius.circular(6)), Paint()..color = const Color(0xFF6E52D0));
      case SpaStep.done:
        break;
    }
  }

  @override
  bool shouldRepaint(_ToolPainter old) => true;
}
