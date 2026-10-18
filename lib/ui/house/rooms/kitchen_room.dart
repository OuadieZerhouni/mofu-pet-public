import 'package:flutter/material.dart';

import '../../../creatures/creature.dart';
import '../../../model/house_store.dart';
import '../../../world/creature_factory.dart';
import '../../names.dart';
import '../../theme.dart';
import '../parts.dart';
import '../room_context.dart';
import '../snack_icons.dart';

/// Kitchen: each friend has its own menu; drag a snack onto a mouth.
class KitchenRoom extends RoomModule {
  KitchenRoom();

  @override
  double get shelfExtra => 158;

  /// The dragged snack is drawn 20 px above the finger so it stays visible;
  /// that point is where it lands.
  static const _lift = Offset(0, -20);

  Friend? _diner(RoomContext rc) {
    final here = rc.store.inRoom(Room.kitchen);
    if (here.isEmpty) return null;
    final picked = rc.house.lastTouched[Room.kitchen];
    return here.where((f) => f.id == picked).firstOrNull ?? here.first;
  }

  Creature? _creatureAt(RoomContext rc, Offset p) {
    final scene = rc.house.scenes[Room.kitchen]!;
    Creature? best;
    var bestD = double.infinity;
    for (final c in scene.creatures) {
      if (!(c.nearMouth(p) || c.hitTest(p))) continue;
      final d = (c.mouth - p).distance;
      if (d < bestD) {
        bestD = d;
        best = c;
      }
    }
    return best;
  }

  void _hover(RoomContext rc, Offset? p) {
    final scene = rc.house.scenes[Room.kitchen]!;
    final target = p == null ? null : _creatureAt(rc, p);
    for (final c in scene.creatures) {
      c.setSnackHover(c == target, p);
    }
  }

  void _drop(RoomContext rc, String snack, Offset p) {
    _hover(rc, null);
    final c = _creatureAt(rc, p);
    if (c == null) return;
    final f = rc.store.friend(c.friendId);
    if (f == null) return;
    rc.house.lastTouched[Room.kitchen] = f.id;
    // Each species only eats from its own menu; others get a polite "no".
    if (!snacksFor(f.species).contains(snack)) {
      c.refuseFull();
      return;
    }
    final fav = favoriteSnack(f);
    switch (rc.store.feed(f.id, snack, favorite: fav)) {
      case FeedOutcome.full:
        c.refuseFull();
      case FeedOutcome.favorite:
        c.eat(favorite: true);
        rc.house.audio.play('ui.sparkle');
        rc.toast(rc.l.kitchenFavoriteToast(f.name, rc.l.snackName(snack)));
        rc.store.discover('house.favorite.${f.species.name}');
      case FeedOutcome.eaten:
        c.eat(favorite: false);
    }
  }

  Offset _local(BuildContext context, Offset global) {
    final box = context.findRenderObject() as RenderBox?;
    final local = box?.globalToLocal(global) ?? global;
    return local + _lift;
  }

  @override
  Widget overlay(BuildContext context, RoomContext rc) {
    return Builder(
      builder: (roomContext) => DragTarget<String>(
        onMove: (d) => _hover(rc, _local(roomContext, d.offset)),
        onLeave: (_) => _hover(rc, null),
        onAcceptWithDetails: (d) => _drop(rc, d.data, _local(roomContext, d.offset)),
        builder: (context, candidates, rejected) => IgnorePointer(
          child: rc.store.inRoom(Room.kitchen).isEmpty
              ? Center(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 32),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18)),
                    child: Text(rc.l.kitchenEmptyHint, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.w800, color: House.ink)),
                  ),
                )
              : const SizedBox.expand(),
        ),
      ),
    );
  }

  @override
  Widget? tools(BuildContext context, RoomContext rc) {
    final l = rc.l;
    return ListenableBuilder(
      listenable: rc.store,
      builder: (context, _) {
        final f = _diner(rc);
        if (f == null) {
          return SizedBox(
            height: 148,
            child: Center(child: Text(l.kitchenPickHint, style: const TextStyle(color: House.woodText, fontWeight: FontWeight.w800))),
          );
        }
        final menu = snacksFor(f.species);
        final left = rc.store.snacksLeft(f.id);
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(l.kitchenMenuFor(f.name),
                      maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: House.woodText, fontWeight: FontWeight.w800, fontSize: 13)),
                ),
                Text(l.kitchenLeft(left), style: const TextStyle(color: House.woodText, fontWeight: FontWeight.w800, fontSize: 13)),
              ],
            ),
            const SizedBox(height: 8),
            GridView.count(
              padding: EdgeInsets.zero,
              crossAxisCount: 3,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childAspectRatio: 2.4,
              children: [
                for (final s in menu)
                  Draggable<String>(
                    data: s,
                    dragAnchorStrategy: pointerDragAnchorStrategy,
                    onDragStarted: () {
                      rc.lockPaging(true);
                      rc.house.audio.haptic('selection');
                    },
                    onDragEnd: (_) {
                      rc.lockPaging(false);
                      _hover(rc, null);
                    },
                    feedback: Transform.translate(
                      offset: const Offset(-28, -28) + _lift,
                      child: Material(color: Colors.transparent, child: SnackIcon(s, size: 56)),
                    ),
                    childWhenDragging: Opacity(opacity: 0.4, child: _SnackChip(id: s, name: l.snackName(s))),
                    child: _SnackChip(id: s, name: l.snackName(s)),
                  ),
              ],
            ),
          ],
        );
      },
    );
  }
}

class _SnackChip extends StatelessWidget {
  const _SnackChip({required this.id, required this.name});
  final String id;
  final String name;

  @override
  Widget build(BuildContext context) => Squish(child: _build(context));

  Widget _build(BuildContext context) {
    return Semantics(
      label: name,
      child: Container(
        decoration: BoxDecoration(
          color: House.woodText,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [BoxShadow(color: House.coinShadow, offset: Offset(0, 4))],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 6),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SnackIcon(id, size: 28),
            const SizedBox(width: 4),
            Flexible(
              child: Text(name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12, color: House.ink)),
            ),
          ],
        ),
      ),
    );
  }
}
