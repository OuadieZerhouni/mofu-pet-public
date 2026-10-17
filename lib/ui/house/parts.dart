/// The paper-craft building blocks from the design canvas: felt tags,
/// the wooden shelf, friend coins with live portraits, the egg coin.
library;

import 'package:flutter/material.dart';

import '../../creatures/creature.dart';
import '../../model/house_store.dart';
import '../../world/creature_factory.dart';
import '../../world/overlays.dart';
import '../theme.dart';

/// A stitched felt tag (rounded, dashed border, hard offset shadow).
class FeltTag extends StatelessWidget {
  const FeltTag({super.key, required this.child, this.radius = 16, this.padding = EdgeInsets.zero, this.height = 48, this.dark = false});
  final Widget child;
  final double radius;
  final EdgeInsets padding;
  final double height;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _Stitch(radius: radius, color: dark ? const Color(0x80CFC6FF) : House.stitch),
      child: Container(
        height: height,
        padding: padding,
        decoration: BoxDecoration(
          color: dark ? Colors.white.withValues(alpha: 0.10) : House.tag,
          borderRadius: BorderRadius.circular(radius),
          boxShadow: dark ? null : const [BoxShadow(color: House.tagShadow, offset: Offset(0, 3))],
        ),
        child: child,
      ),
    );
  }
}

class _Stitch extends CustomPainter {
  _Stitch({required this.radius, required this.color});
  final double radius;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final rr = RRect.fromRectAndRadius((Offset.zero & size).deflate(1.5), Radius.circular(radius));
    final path = Path()..addRRect(rr);
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    for (final m in path.computeMetrics()) {
      for (var d = 0.0; d < m.length; d += 9) {
        canvas.drawPath(m.extractPath(d, d + 5), paint);
      }
    }
  }

  @override
  bool shouldRepaint(_Stitch old) => old.color != color || old.radius != radius;
}

/// A round icon button inside a felt tag (settings, arrows, lamp).
class FeltIconButton extends StatelessWidget {
  const FeltIconButton({super.key, required this.icon, required this.label, required this.onTap, this.dark = false, this.size = 48});
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool dark;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: SizedBox(
          width: size,
          child: FeltTag(
            height: size,
            dark: dark,
            child: Icon(icon, color: dark ? House.nightText : House.ink, size: size * 0.48),
          ),
        ),
      ),
    );
  }
}

/// The wooden tool shelf at the bottom of every room.
class WoodShelf extends StatelessWidget {
  const WoodShelf({super.key, required this.child, this.bottomInset = 0});
  final Widget child;
  final double bottomInset;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [House.wood, House.woodDeep]),
        border: Border(top: BorderSide(color: House.woodEdge, width: 6)),
        boxShadow: [BoxShadow(color: Color(0x2E3A2A2E), blurRadius: 18, offset: Offset(0, -6))],
      ),
      padding: EdgeInsets.fromLTRB(16, 12, 16, 12 + bottomInset),
      child: child,
    );
  }
}

/// A small live portrait of a friend (its real painter, posed still).
class FriendPortrait extends StatefulWidget {
  const FriendPortrait({super.key, required this.friend, this.size = 52});
  final Friend friend;
  final double size;

  @override
  State<FriendPortrait> createState() => _FriendPortraitState();
}

class _FriendPortraitState extends State<FriendPortrait> {
  late Creature _c = _make();

  Creature _make() {
    final s = widget.size;
    final c = makeCreature(widget.friend)..reduceMotion = true;
    c.layout(Rect.fromLTWH(0, 0, s, s), floorY: s * 0.94, sizeScale: c.species == Species.wuff ? 1.45 : 1.9);
    c.position = Offset(s / 2, c.position.dy);
    for (var i = 0; i < 4; i++) {
      c.update(1 / 60);
    }
    return c;
  }

  @override
  void didUpdateWidget(FriendPortrait old) {
    super.didUpdateWidget(old);
    if (old.friend.id != widget.friend.id || old.friend.variant != widget.friend.variant || old.size != widget.size) _c = _make();
  }

  @override
  Widget build(BuildContext context) {
    final f = widget.friend;
    return SizedBox.square(
      dimension: widget.size,
      child: CustomPaint(painter: _PortraitPainter(_c, f.variant, [for (final a in f.wear.values) a])),
    );
  }
}

class _PortraitPainter extends CustomPainter {
  _PortraitPainter(this.c, this.variant, this.accessories);
  final Creature c;
  final String variant;
  final List<String> accessories;

  @override
  void paint(Canvas canvas, Size size) {
    artFor(c.species).paint(canvas, c, CreatureLook(variant: variant, accessories: accessories), shadow: false);
    for (final a in accessories) {
      if (c.species == Species.mofu && slotOf(a) == AccessorySlot.head) continue;
      paintAccessoryOn(canvas, c, a);
    }
  }

  @override
  bool shouldRepaint(_PortraitPainter old) => old.c != c || old.variant != variant || old.accessories.join() != accessories.join();
}

/// A friend's round coin on the shelf.
class FriendCoin extends StatelessWidget {
  const FriendCoin({super.key, required this.friend, required this.here, required this.label, required this.onTap});
  final Friend friend;
  final bool here;
  final String label;
  final VoidCallback onTap;

  static const _tint = {
    Species.mofu: Color(0xFFFFE3D6),
    Species.oink: Color(0xFFFFD3DE),
    Species.wuff: Color(0xFFFFE5C6),
    Species.boop: Color(0xFFE3F0FF),
  };

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      excludeSemantics: true,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: here ? _tint[friend.species] : _tint[friend.species]!.withValues(alpha: 0.45),
            border: Border.all(color: House.woodText, width: here ? 3 : 2),
            boxShadow: here ? const [BoxShadow(color: House.coinShadow, offset: Offset(0, 4))] : null,
          ),
          child: ClipOval(
            child: Opacity(opacity: here ? 1 : 0.7, child: FriendPortrait(friend: friend, size: 56)),
          ),
        ),
      ),
    );
  }
}

/// The next egg, with how many stars it needs.
class EggCoin extends StatelessWidget {
  const EggCoin({super.key, required this.stars, required this.ready, required this.label, required this.onTap});
  final int stars;
  final bool ready;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      excludeSemantics: true,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: ready ? House.star : Colors.white.withValues(alpha: 0.12),
            border: Border.all(color: House.woodText, width: 2),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CustomPaint(size: const Size(22, 26), painter: _EggPainter(ready)),
              Text('$stars',
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11, color: ready ? House.ink : House.woodText, height: 1.1)),
            ],
          ),
        ),
      ),
    );
  }
}

class _EggPainter extends CustomPainter {
  _EggPainter(this.ready);
  final bool ready;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    final p = Path()
      ..moveTo(w / 2, 0)
      ..cubicTo(w * 0.1, 0, 0, h * 0.55, 0, h * 0.66)
      ..cubicTo(0, h * 0.9, w * 0.25, h, w / 2, h)
      ..cubicTo(w * 0.75, h, w, h * 0.9, w, h * 0.66)
      ..cubicTo(w, h * 0.55, w * 0.9, 0, w / 2, 0)
      ..close();
    canvas.drawPath(p, Paint()..color = ready ? Colors.white : House.woodText.withValues(alpha: 0.9));
    if (ready) {
      canvas.drawPath(
          Path()
            ..moveTo(w * 0.2, h * 0.5)
            ..lineTo(w * 0.4, h * 0.4)
            ..lineTo(w * 0.55, h * 0.52)
            ..lineTo(w * 0.8, h * 0.42),
          Paint()
            ..color = House.starEdge
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2);
    }
  }

  @override
  bool shouldRepaint(_EggPainter old) => old.ready != ready;
}

/// Gold star + count, as in the top bar.
class StarTag extends StatelessWidget {
  const StarTag({super.key, required this.count, required this.label, this.dark = false});
  final int count;
  final String label;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: label,
      excludeSemantics: true,
      child: FeltTag(
        dark: dark,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomPaint(size: const Size(18, 18), painter: StarPainter()),
            const SizedBox(width: 6),
            Text('$count', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: dark ? House.nightText : House.ink)),
          ],
        ),
      ),
    );
  }
}

class StarPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width / 24;
    final p = Path()
      ..moveTo(12 * s, 3 * s)
      ..lineTo(14.6 * s, 8.6 * s)
      ..lineTo(20.6 * s, 9.3 * s)
      ..lineTo(16.1 * s, 13.4 * s)
      ..lineTo(17.4 * s, 19.4 * s)
      ..lineTo(12 * s, 16.4 * s)
      ..lineTo(6.6 * s, 19.4 * s)
      ..lineTo(7.9 * s, 13.4 * s)
      ..lineTo(3.4 * s, 9.3 * s)
      ..lineTo(9.4 * s, 8.6 * s)
      ..close();
    canvas.drawPath(p, Paint()..color = House.star);
    canvas.drawPath(
        p,
        Paint()
          ..color = House.starEdge
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5 * s
          ..strokeJoin = StrokeJoin.round);
  }

  @override
  bool shouldRepaint(StarPainter oldDelegate) => false;
}
