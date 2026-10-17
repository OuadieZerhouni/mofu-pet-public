import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../l10n/app_localizations.dart';
import '../../model/house_store.dart';
import '../../world/house_controller.dart';
import '../theme.dart';
import 'backdrops.dart';
import 'house_text.dart';
import 'parts.dart';

Future<void> showPhotoBooth(BuildContext context, {required HouseController house}) {
  return Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => PhotoBooth(house: house), fullscreenDialog: true));
}

enum StickerKind { heart, star, sparkle, cloud, bow, flower }

class _Placed {
  _Placed(this.id, this.pos);
  final String id; // friend id or sticker kind name
  Offset pos; // 0..1 within the frame

}

/// Pose friends on a backdrop, add stickers, share a 4:5 picture.
class PhotoBooth extends StatefulWidget {
  const PhotoBooth({super.key, required this.house});
  final HouseController house;

  @override
  State<PhotoBooth> createState() => _PhotoBoothState();
}

class _PhotoBoothState extends State<PhotoBooth> {
  final GlobalKey _frame = GlobalKey();
  Room _backdrop = Room.garden;
  final List<_Placed> _friends = [];
  final List<_Placed> _stickers = [];
  bool _sharing = false;

  HouseStore get store => widget.house.store;

  @override
  void initState() {
    super.initState();
    final first = store.friends.take(3).toList();
    for (var i = 0; i < first.length; i++) {
      _friends.add(_Placed(first[i].id, Offset((i + 1) / (first.length + 1), 0.72)));
    }
  }

  void _toggleFriend(Friend f) {
    setState(() {
      final at = _friends.indexWhere((p) => p.id == f.id);
      if (at >= 0) {
        _friends.removeAt(at);
      } else if (_friends.length < 4) {
        _friends.add(_Placed(f.id, Offset(0.3 + 0.4 * math.Random().nextDouble(), 0.7)));
      }
    });
    widget.house.audio.play('ui.tap');
  }

  void _addSticker(StickerKind k) {
    setState(() => _stickers.add(_Placed(k.name, Offset(0.2 + 0.6 * math.Random().nextDouble(), 0.15 + 0.3 * math.Random().nextDouble()))));
    widget.house.audio.play('ui.pop');
  }

  Future<void> _share(AppLocalizations l) async {
    if (_sharing) return;
    setState(() => _sharing = true);
    try {
      final boundary = _frame.currentContext!.findRenderObject()! as RenderRepaintBoundary;
      final img = await boundary.toImage(pixelRatio: 1080 / boundary.size.width);
      final bytes = await img.toByteData(format: ui.ImageByteFormat.png);
      if (bytes == null || kIsWeb) return;
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/mofu_friends_${DateTime.now().millisecondsSinceEpoch}.png');
      await file.writeAsBytes(bytes.buffer.asUint8List());
      if (!mounted) return;
      final box = context.findRenderObject() as RenderBox?;
      await SharePlus.instance.share(ShareParams(
        files: [XFile(file.path, mimeType: 'image/png')],
        text: l.photoShareText,
        sharePositionOrigin: box == null ? null : box.localToGlobal(Offset.zero) & box.size,
      ));
      store.discover('house.photo');
    } catch (e) {
      debugPrint('photo share failed: $e');
    } finally {
      if (mounted) setState(() => _sharing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: House.paper,
      appBar: AppBar(
        backgroundColor: House.paper,
        centerTitle: true,
        titleSpacing: 0,
        title: Text(l.photoTitle, style: const TextStyle(fontWeight: FontWeight.w900)),
        leading: IconButton(tooltip: l.photoClose, icon: const Icon(Icons.close_rounded), onPressed: () => Navigator.pop(context)),
        actions: [
          Padding(
            // Directional, so the button keeps the 16 pt gutter on the left in Arabic too.
            padding: const EdgeInsetsDirectional.only(end: 16),
            child: FilledButton.icon(
              style: FilledButton.styleFrom(backgroundColor: House.rose, shape: const StadiumBorder()),
              onPressed: _friends.isEmpty || _sharing ? null : () => _share(l),
              icon: const Icon(Icons.ios_share_rounded, color: Colors.white),
              label: Text(l.photoShare, style: const TextStyle(fontWeight: FontWeight.w900, color: Colors.white)),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: AspectRatio(
                    aspectRatio: 4 / 5,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: RepaintBoundary(key: _frame, child: _stage()),
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Text(l.photoHint, style: const TextStyle(fontWeight: FontWeight.w700, color: House.inkSoft)),
            ),
            _controls(l),
          ],
        ),
      ),
    );
  }

  Widget _stage() {
    return LayoutBuilder(builder: (context, box) {
      final size = box.biggest;
      Widget draggable(_Placed p, Widget child, double w) => Positioned(
            left: p.pos.dx * size.width - w / 2,
            top: p.pos.dy * size.height - w / 2,
            width: w,
            height: w,
            child: GestureDetector(
              onPanUpdate: (d) => setState(() {
                p.pos = Offset(
                  (p.pos.dx + d.delta.dx / size.width).clamp(0.05, 0.95),
                  (p.pos.dy + d.delta.dy / size.height).clamp(0.05, 0.95),
                );
              }),
              onDoubleTap: _stickers.contains(p) ? () => setState(() => _stickers.remove(p)) : null,
              child: child,
            ),
          );
      return Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: RoomBackdrop(room: _backdrop, daypart: widget.house.daypart, floorY: size.height * 0.78, time: 3),
            ),
          ),
          for (final p in _friends)
            if (store.friend(p.id) case final f?) draggable(p, FriendPortrait(friend: f, size: size.width * 0.34), size.width * 0.34),
          for (final s in _stickers) draggable(s, CustomPaint(painter: _StickerPainter(StickerKind.values.byName(s.id))), size.width * 0.16),
        ],
      );
    });
  }

  Widget _controls(AppLocalizations l) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l.photoBackdrop, style: const TextStyle(fontWeight: FontWeight.w900, color: House.ink)),
          const SizedBox(height: 6),
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                for (final r in Room.values)
                  Padding(
                    padding: const EdgeInsetsDirectional.only(end: 8),
                    child: ChoiceChip(
                      label: Text(l.roomName(r)),
                      selected: _backdrop == r,
                      selectedColor: House.rose,
                      showCheckmark: false,
                      labelStyle: TextStyle(fontWeight: FontWeight.w800, color: _backdrop == r ? Colors.white : House.ink),
                      onSelected: (_) => setState(() => _backdrop = r),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Text(l.photoFriends, style: const TextStyle(fontWeight: FontWeight.w900, color: House.ink)),
          const SizedBox(height: 6),
          SizedBox(
            height: 60,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                for (final f in store.friends)
                  Padding(
                    padding: const EdgeInsetsDirectional.only(end: 8),
                    child: GestureDetector(
                      onTap: () => _toggleFriend(f),
                      child: Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                          border: Border.all(color: _friends.any((p) => p.id == f.id) ? House.rose : const Color(0xFFE6D3BE), width: 3),
                        ),
                        child: ClipOval(child: FriendPortrait(friend: f, size: 50)),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Text(l.photoStickers, style: const TextStyle(fontWeight: FontWeight.w900, color: House.ink)),
          const SizedBox(height: 6),
          Row(
            children: [
              for (final (i, k) in StickerKind.values.indexed) ...[
                if (i > 0) const SizedBox(width: 6),
                Expanded(
                  child: GestureDetector(
                    onTap: () => _addSticker(k),
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
                      child: Padding(padding: const EdgeInsets.all(8), child: CustomPaint(painter: _StickerPainter(k))),
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 4),
          Text(l.photoRemoveSticker, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12, color: House.inkSoft)),
        ],
      ),
    );
  }
}

class _StickerPainter extends CustomPainter {
  _StickerPainter(this.kind);
  final StickerKind kind;

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.shortestSide;
    final c = size.center(Offset.zero);
    final outline = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = s * 0.08
      ..strokeJoin = StrokeJoin.round;
    Path path;
    Color color;
    switch (kind) {
      case StickerKind.heart:
        path = Path()
          ..moveTo(c.dx, c.dy + s * 0.38)
          ..cubicTo(c.dx - s * 0.6, c.dy, c.dx - s * 0.32, c.dy - s * 0.48, c.dx, c.dy - s * 0.18)
          ..cubicTo(c.dx + s * 0.32, c.dy - s * 0.48, c.dx + s * 0.6, c.dy, c.dx, c.dy + s * 0.38)
          ..close();
        color = House.rose;
      case StickerKind.star:
        path = Path();
        for (var i = 0; i < 10; i++) {
          final a = -math.pi / 2 + i * math.pi / 5;
          final r = i.isEven ? s * 0.45 : s * 0.2;
          final p = c + Offset(math.cos(a), math.sin(a)) * r;
          i == 0 ? path.moveTo(p.dx, p.dy) : path.lineTo(p.dx, p.dy);
        }
        path.close();
        color = House.star;
      case StickerKind.sparkle:
        path = Path()
          ..moveTo(c.dx, c.dy - s * 0.45)
          ..quadraticBezierTo(c.dx, c.dy, c.dx + s * 0.45, c.dy)
          ..quadraticBezierTo(c.dx, c.dy, c.dx, c.dy + s * 0.45)
          ..quadraticBezierTo(c.dx, c.dy, c.dx - s * 0.45, c.dy)
          ..quadraticBezierTo(c.dx, c.dy, c.dx, c.dy - s * 0.45)
          ..close();
        color = const Color(0xFF9FD8FF);
      case StickerKind.cloud:
        path = Path()
          ..addOval(Rect.fromCircle(center: c + Offset(-s * 0.18, s * 0.06), radius: s * 0.2))
          ..addOval(Rect.fromCircle(center: c + Offset(s * 0.05, -s * 0.06), radius: s * 0.26))
          ..addOval(Rect.fromCircle(center: c + Offset(s * 0.26, s * 0.08), radius: s * 0.18));
        color = Colors.white;
      case StickerKind.bow:
        path = Path()
          ..moveTo(c.dx, c.dy)
          ..lineTo(c.dx - s * 0.45, c.dy - s * 0.28)
          ..lineTo(c.dx - s * 0.45, c.dy + s * 0.28)
          ..close()
          ..moveTo(c.dx, c.dy)
          ..lineTo(c.dx + s * 0.45, c.dy - s * 0.28)
          ..lineTo(c.dx + s * 0.45, c.dy + s * 0.28)
          ..close();
        color = const Color(0xFFFF7FA8);
      case StickerKind.flower:
        path = Path();
        for (var i = 0; i < 5; i++) {
          final a = i * 2 * math.pi / 5;
          path.addOval(Rect.fromCircle(center: c + Offset(math.cos(a), math.sin(a)) * s * 0.22, radius: s * 0.18));
        }
        color = const Color(0xFFFFC3D5);
    }
    canvas.drawPath(path, outline);
    canvas.drawPath(path, Paint()..color = color);
    if (kind == StickerKind.flower) canvas.drawCircle(c, s * 0.13, Paint()..color = House.star);
    if (kind == StickerKind.bow) canvas.drawCircle(c, s * 0.1, Paint()..color = House.rose);
    if (kind == StickerKind.cloud) {
      canvas.drawPath(
          path,
          Paint()
            ..color = const Color(0xFFBFD8E4)
            ..style = PaintingStyle.stroke
            ..strokeWidth = s * 0.03);
    }
  }

  @override
  bool shouldRepaint(_StickerPainter old) => old.kind != kind;
}
