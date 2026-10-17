import 'package:flutter/material.dart';

import '../../creatures/creature.dart';
import '../../model/house_store.dart';
import '../../world/creature_factory.dart';
import '../../world/house_controller.dart';
import '../../world/overlays.dart';
import '../theme.dart';

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
                child: IgnorePointer(child: Center(child: SpeechTag(text: bubbleText(b.friendId, b.key)))),
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
    for (final c in scene.paintOrder) {
      final f = house.store.friend(c.friendId);
      if (f == null) continue;
      final look = house.lookFor(f);
      artFor(c.species).paint(canvas, c, look);
      for (final acc in look.accessories) {
        // Mofu draws its hat inside its own squash transform.
        if (c.species == Species.mofu && slotOf(acc) == AccessorySlot.head) continue;
        paintAccessoryOn(canvas, c, acc);
      }
      paintCare(canvas, c, house.time);
    }
  }

  @override
  bool shouldRepaint(ScenePainter old) => old.room != room || old.house != house;
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
