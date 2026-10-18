import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../creatures/creature.dart';
import '../../model/house_store.dart';
import '../../world/creature_factory.dart';
import '../../world/fx.dart';
import '../../world/house_controller.dart';
import '../../world/overlays.dart';
import '../theme.dart';
import 'fx_painter.dart';

/// Draws one room's friends (depth-sorted, with accessories, spa overlays
/// and speech bubbles) and, when [interactive], routes touches to them.
class RoomStage extends StatelessWidget {
  const RoomStage({
    super.key,
    required this.house,
    required this.room,
    required this.frame,
    required this.interactive,
    required this.bubbleText,
  });

  final HouseController house;
  final Room room;
  final ValueNotifier<int> frame;
  final bool interactive;
  final String Function(String friendId, String key) bubbleText;

  @override
  Widget build(BuildContext context) {
    final paint = RepaintBoundary(
      child: CustomPaint(
        size: Size.infinite,
        painter: ScenePainter(house: house, room: room, repaint: frame),
      ),
    );
    final bubbles = ValueListenableBuilder<int>(
      valueListenable: frame,
      builder: (context, _, _) {
        final scene = house.scenes[room]!;
        final items = <Widget>[
          for (final b in house.bubbles)
            if (scene.byId(b.friendId) case final c?)
              Positioned(
                left: c.position.dx - 110,
                width: 220,
                top: c.bounds.top - 54,
                child: IgnorePointer(child: Center(child: _bubbleMotion(b, house.time, SpeechTag(text: bubbleText(b.friendId, b.key))))),
              ),
        ];
        // Always a Positioned child: a bare one would size the Stack to itself.
        return Stack(clipBehavior: Clip.none, children: items.isEmpty ? const [Positioned(left: 0, top: 0, child: SizedBox.shrink())] : items);
      },
    );
    return Stack(
      fit: StackFit.expand,
      children: [
        if (interactive)
          Listener(
            behavior: HitTestBehavior.translucent,
            onPointerDown: (e) => house.pointerDown(e.pointer, e.localPosition),
            onPointerMove: (e) => house.pointerMove(e.pointer, e.localPosition),
            onPointerUp: (e) => house.pointerUp(e.pointer, e.localPosition),
            onPointerCancel: (e) => house.pointerCancel(e.pointer),
            child: paint,
          )
        else
          IgnorePointer(child: paint),
        IgnorePointer(child: bubbles),
      ],
    );
  }
}

class ScenePainter extends CustomPainter {
  ScenePainter({required this.house, required this.room, super.repaint});
  final HouseController house;
  final Room room;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;
    final scene = house.scenes[room]!;
    final now = house.time;
    for (final c in scene.paintOrder) {
      final f = house.store.friend(c.friendId);
      if (f == null) continue;
      final look = house.lookFor(f);
      final e = house.entrances[c.friendId];
      final pose = e == null ? EntrancePose.rest : entrancePose(e, now - e.born, c.radius, c.footPoint);
      // While falling in, the shadow waits on the floor and grows as the friend nears it.
      final airborne = pose.dy < -1;
      if (airborne) paintFloorShadow(canvas, c, 1 + pose.dy / (c.radius * 2.6));
      final layered = applyEntrance(canvas, pose, c.footPoint);
      artFor(c.species).paint(canvas, c, look, shadow: !airborne);
      for (final acc in look.accessories) {
        // Mofu draws its hat inside its own squash transform.
        if (c.species == Species.mofu && slotOf(acc) == AccessorySlot.head) continue;
        paintAccessoryOn(canvas, c, acc);
      }
      paintCare(canvas, c, now);
      if (layered) canvas.restore();
    }
    for (final f in house.fx[room]!) {
      paintFx(canvas, f, now);
    }
  }

  @override
  bool shouldRepaint(ScenePainter old) => old.room != room || old.house != house;
}

/// A speech tag pops in from its tail with a small overshoot, drifts up a
/// little while it is shown, and fades out instead of vanishing.
Widget _bubbleMotion(Bubble b, double now, Widget child) {
  final age = now - b.born;
  final left = b.until - now;
  final inT = (age / 0.28).clamp(0.0, 1.0);
  final scale = Curves.easeOutBack.transform(inT);
  final alpha = math.min(1.0, math.min(age / 0.12, left / 0.25)).clamp(0.0, 1.0);
  return Opacity(
    opacity: alpha,
    child: Transform.translate(
      offset: Offset(0, 6 - 6 * inT - 4 * math.min(1.0, age / 1.8)),
      child: Transform.scale(scale: 0.6 + 0.4 * scale, alignment: Alignment.bottomCenter, child: child),
    ),
  );
}

/// The little white tag a friend "says".
class SpeechTag extends StatelessWidget {
  const SpeechTag({super.key, required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: House.ink.withValues(alpha: 0.12), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800, color: House.ink),
      ),
    );
  }
}
