/// The six rooms, painted. Each room has a back wall, furniture and a floor,
/// drawn in three depth layers that slide at different speeds while you
/// swipe ([parallax], -1..1), and a lighting pass for the time of day.
/// Palettes follow the "Mofu & Friends — UI design" canvas tokens.
library;

import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../model/house_store.dart';
import '../../world/house_controller.dart';

class RoomBackdrop extends CustomPainter {
  RoomBackdrop({
    required this.room,
    required this.daypart,
    required this.floorY,
    this.parallax = 0,
    this.time = 0,
    this.lampOn = true,
    super.repaint,
  });

  final Room room;
  final Daypart daypart;
  final double floorY;
  final double parallax;
  final double time;
  final bool lampOn;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;
    final w = size.width;
    switch (room) {
      case Room.living:
        _living(canvas, size, w);
      case Room.spa:
        _spa(canvas, size, w);
      case Room.kitchen:
        _kitchen(canvas, size, w);
      case Room.bedroom:
        _bedroom(canvas, size, w);
      case Room.playroom:
        _playroom(canvas, size, w);
      case Room.garden:
        _garden(canvas, size, w);
    }
    _light(canvas, size);
  }

  // Layer offsets: back wall moves least, floor props most.
  double get _back => parallax * 14;
  double get _mid => parallax * 28;

  Paint _fill(Color c) => Paint()..color = c;

  void _wall(Canvas canvas, Size size, List<Color> colors, {Color? dots, Color? stripes}) {
    final r = Offset.zero & Size(size.width, floorY);
    canvas.drawRect(
        r, Paint()..shader = LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: colors).createShader(r));
    if (dots != null) {
      final p = _fill(dots);
      for (var y = 14.0; y < floorY; y += 22) {
        for (var x = 8.0 + ((y ~/ 22).isOdd ? 11 : 0); x < size.width + 22; x += 22) {
          canvas.drawCircle(Offset(x + _back % 22, y), 1.6, p);
        }
      }
    }
    if (stripes != null) {
      final p = _fill(stripes);
      for (var x = -52.0; x < size.width + 52; x += 52) {
        canvas.drawRect(Rect.fromLTWH(x + _back % 52, 0, 26, floorY), p);
      }
    }
  }

  void _floor(Canvas canvas, Size size, Color top, Color bottom, {Color? lip}) {
    final r = Rect.fromLTWH(0, floorY - 6, size.width, size.height - floorY + 6);
    canvas.drawRect(
        r, Paint()..shader = LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [top, bottom]).createShader(r));
    if (lip != null) canvas.drawRect(Rect.fromLTWH(0, floorY - 8, size.width, 10), _fill(lip));
  }

  void _window(Canvas canvas, Rect r, {required Color frame}) {
    final sky = switch (daypart) {
      Daypart.morning => const [Color(0xFFFFD7B5), Color(0xFFFFF1DC)],
      Daypart.day => const [Color(0xFFBFE3F7), Color(0xFFE8F5FB)],
      Daypart.evening => const [Color(0xFFF7A98F), Color(0xFFFFD7A8)],
      Daypart.night => const [Color(0xFF1C1940), Color(0xFF2E2A63)],
    };
    final rr = RRect.fromRectAndCorners(r,
        topLeft: Radius.circular(r.width / 2), topRight: Radius.circular(r.width / 2), bottomLeft: const Radius.circular(10), bottomRight: const Radius.circular(10));
    canvas.drawRRect(rr.shift(const Offset(0, 6)), _fill(const Color(0x22000000)));
    canvas.drawRRect(rr, Paint()..shader = LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: sky).createShader(r));
    if (daypart == Daypart.night) {
      canvas.drawCircle(r.topLeft + Offset(r.width * 0.68, r.height * 0.3), r.width * 0.13, _fill(const Color(0xFFFFE7A8)));
      canvas.drawCircle(r.topLeft + Offset(r.width * 0.74, r.height * 0.27), r.width * 0.12, _fill(sky.first));
      final rng = math.Random(4);
      for (var i = 0; i < 7; i++) {
        final tw = 0.5 + 0.5 * math.sin(time * 2 + i);
        canvas.drawCircle(r.topLeft + Offset(r.width * (0.15 + rng.nextDouble() * 0.7), r.height * (0.15 + rng.nextDouble() * 0.6)), 1.2 + tw,
            _fill(Colors.white.withValues(alpha: 0.5 + 0.4 * tw)));
      }
    } else {
      final cloud = _fill(Colors.white.withValues(alpha: 0.85));
      final cx = r.left + (r.width * (0.3 + 0.1 * math.sin(time * 0.05)));
      canvas.drawCircle(Offset(cx, r.top + r.height * 0.45), r.width * 0.12, cloud);
      canvas.drawCircle(Offset(cx + r.width * 0.14, r.top + r.height * 0.42), r.width * 0.15, cloud);
    }
    final stroke = Paint()
      ..color = frame
      ..style = PaintingStyle.stroke
      ..strokeWidth = 9;
    canvas.drawRRect(rr, stroke);
    canvas.drawLine(Offset(r.center.dx, r.top + 4), Offset(r.center.dx, r.bottom), stroke..strokeWidth = 7);
  }

  void _shadowEllipse(Canvas canvas, Offset c, double w, double h) {
    canvas.drawOval(Rect.fromCenter(center: c, width: w, height: h),
        Paint()
          ..color = const Color(0x2A3A2A2E)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6));
  }

  // ── rooms ─────────────────────────────────────────────────────────────
  void _living(Canvas canvas, Size size, double w) {
    _wall(canvas, size, const [Color(0xFFFFF8EE), Color(0xFFF2DCC4)], dots: const Color(0x55E9CFB4));
    _window(canvas, Rect.fromLTWH(w * 0.55 + _back, floorY * 0.2, w * 0.33, floorY * 0.34), frame: const Color(0xFFFFF7EC));
    // Picture frame.
    final pic = Rect.fromLTWH(w * 0.09 + _back, floorY * 0.3, w * 0.22, floorY * 0.2);
    canvas.drawRRect(RRect.fromRectAndRadius(pic.shift(const Offset(0, 5)), const Radius.circular(12)), _fill(const Color(0x22000000)));
    canvas.drawRRect(RRect.fromRectAndRadius(pic, const Radius.circular(12)), _fill(const Color(0xFFFFF7EC)));
    // A little painting: sky, sun, rolling hills and a tiny house.
    final art = pic.deflate(8);
    canvas.save();
    canvas.clipRRect(RRect.fromRectAndRadius(art, const Radius.circular(6)));
    canvas.drawRect(art, Paint()..shader = const LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFFFFD9C7), Color(0xFFFFF1E2)]).createShader(art));
    canvas.drawCircle(Offset(art.left + art.width * 0.72, art.top + art.height * 0.3), art.width * 0.13, _fill(const Color(0xFFF6B86B)));
    canvas.drawOval(Rect.fromCenter(center: Offset(art.left + art.width * 0.25, art.bottom), width: art.width * 1.1, height: art.height * 0.7), _fill(const Color(0xFFA9D39A)));
    canvas.drawOval(Rect.fromCenter(center: Offset(art.left + art.width * 0.85, art.bottom + art.height * 0.05), width: art.width * 1.0, height: art.height * 0.6), _fill(const Color(0xFF8CC283)));
    final hw = art.width * 0.2, hx = art.left + art.width * 0.42, hy = art.bottom - art.height * 0.36;
    canvas.drawRect(Rect.fromLTWH(hx, hy, hw, hw * 0.8), _fill(const Color(0xFFFFFBF2)));
    canvas.drawPath(Path()..moveTo(hx - hw * 0.15, hy)..lineTo(hx + hw / 2, hy - hw * 0.6)..lineTo(hx + hw * 1.15, hy)..close(), _fill(const Color(0xFFC2386A)));
    canvas.restore();
    // Plant.
    final pot = Rect.fromLTWH(w * 0.04 + _mid, floorY - 64, 44, 52);
    for (var i = 0; i < 5; i++) {
      final a = -math.pi / 2 + (i - 2) * 0.42 + math.sin(time * 0.8 + i) * 0.03;
      final base = Offset(pot.center.dx, pot.top + 4);
      canvas.drawOval(Rect.fromCenter(center: base + Offset(math.cos(a), math.sin(a)) * 30, width: 22, height: 40),
          _fill(i.isEven ? const Color(0xFF7FB77E) : const Color(0xFF6AA56C)));
    }
    canvas.drawRRect(RRect.fromRectAndRadius(pot, const Radius.circular(10)), _fill(const Color(0xFFE08E6D)));
    _floor(canvas, size, const Color(0xFFD9A877), const Color(0xFFC08D60), lip: const Color(0xFFB98258));
    // Rug.
    final rug = Rect.fromCenter(center: Offset(w / 2 + _mid * 0.5, floorY + 46), width: w * 0.86, height: 104);
    canvas.drawOval(rug, _fill(const Color(0xFFF4C6CF)));
    canvas.drawOval(rug.deflate(9), Paint()
      ..color = const Color(0xFFE9A9B7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3);
  }

  void _spa(Canvas canvas, Size size, double w) {
    final r = Offset.zero & Size(w, floorY);
    canvas.drawRect(r, _fill(const Color(0xFFDDF1EE)));
    final grout = Paint()
      ..color = const Color(0xFFC9E7E2)
      ..strokeWidth = 2;
    for (var x = _back % 39; x < w; x += 39) {
      canvas.drawLine(Offset(x, 0), Offset(x, floorY), grout);
    }
    for (var y = 0.0; y < floorY; y += 39) {
      canvas.drawLine(Offset(0, y), Offset(w, y), grout);
    }
    // Floating bubbles.
    for (var i = 0; i < 6; i++) {
      final t = (time * 0.05 + i * 0.17) % 1;
      final c = Offset(w * (0.12 + 0.15 * i) + math.sin(time + i) * 6 + _back, floorY * (1 - t));
      final rad = 8.0 + (i % 3) * 7;
      canvas.drawCircle(c, rad, Paint()..shader = RadialGradient(colors: [Colors.white.withValues(alpha: 0.9), const Color(0x55CDEAF5)]).createShader(Rect.fromCircle(center: c, radius: rad)));
    }
    _floor(canvas, size, const Color(0xFFBFE0EA), const Color(0xFFA9D1E0));
    // Mat.
    final mat = RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(w / 2 + _mid * 0.4, floorY + 6), width: w * 0.78, height: 64), const Radius.circular(32));
    canvas.drawRRect(mat.shift(const Offset(0, 6)), _fill(const Color(0xFF9CC6D6)));
    canvas.drawRRect(mat, _fill(Colors.white));
    canvas.drawRRect(mat.deflate(10), _fill(const Color(0xFFE2F1F5)));
  }

  void _kitchen(Canvas canvas, Size size, double w) {
    _wall(canvas, size, const [Color(0xFFFFF6E2), Color(0xFFFFEFCB)], stripes: const Color(0x66FFE4A8));
    // Shelf with jars.
    final shelf = Rect.fromLTWH(w * 0.06 + _back, floorY * 0.34, w * 0.42, 14);
    canvas.drawRRect(RRect.fromRectAndRadius(shelf, const Radius.circular(5)), _fill(const Color(0xFFC99A6B)));
    canvas.drawRect(shelf.shift(const Offset(0, 12)).inflate(-2), _fill(const Color(0xFFA87C52)));
    final jars = [const Color(0xFFF28F6B), const Color(0xFFA6D8A0), const Color(0xFFF6D27A)];
    for (var i = 0; i < 3; i++) {
      final j = RRect.fromRectAndRadius(Rect.fromLTWH(shelf.left + 10 + i * 40, shelf.top - 40, 30, 40), const Radius.circular(8));
      canvas.drawRRect(j, _fill(jars[i]));
      canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(j.left - 2, j.top - 6, j.width + 4, 9), const Radius.circular(4)), _fill(const Color(0xFFFFFBF2)));
    }
    // The kitchen floor sits high (tall menu shelf): keep the window clear of the header.
    final winTop = math.max(floorY * 0.18, 150.0);
    _window(canvas, Rect.fromLTWH(w * 0.62 + _back, winTop, w * 0.28, math.min(floorY * 0.3, floorY - winTop - 120)), frame: const Color(0xFFFFFBF2));
    _floor(canvas, size, const Color(0xFFE9C79A), const Color(0xFFDDB688));
    canvas.drawRect(Rect.fromLTWH(0, floorY - 10, w, 14), _fill(Colors.white));
    canvas.drawRect(Rect.fromLTWH(0, floorY + 4, w, 4), _fill(const Color(0xFFE7D3B4)));
  }

  void _bedroom(Canvas canvas, Size size, double w) {
    final r = Offset.zero & size;
    final day = daypart != Daypart.night;
    canvas.drawRect(
        r,
        Paint()
          ..shader = LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: day
                  ? const [Color(0xFFE9E2FF), Color(0xFFD7CCF6)]
                  : const [Color(0xFF2E2858), Color(0xFF1E1A3C)])
              .createShader(r));
    _window(canvas, Rect.fromLTWH(w * 0.08 + _back, floorY * 0.18, w * 0.3, floorY * 0.33), frame: day ? const Color(0xFFF7F3FF) : const Color(0xFF3A3470));
    // Lamp.
    final lamp = Offset(w * 0.8 + _back, floorY * 0.34);
    if (lampOn) {
      canvas.drawCircle(lamp, 90, Paint()..shader = RadialGradient(colors: [const Color(0xFFFFD68C).withValues(alpha: day ? 0.25 : 0.55), const Color(0x00FFD68C)]).createShader(Rect.fromCircle(center: lamp, radius: 90)));
    }
    canvas.drawRRect(RRect.fromRectAndCorners(Rect.fromCenter(center: lamp, width: 46, height: 54), topLeft: const Radius.circular(23), topRight: const Radius.circular(23), bottomLeft: const Radius.circular(6), bottomRight: const Radius.circular(6)),
        _fill(lampOn ? const Color(0xFFFFD68C) : const Color(0xFFB9B1D8)));
    canvas.drawRect(Rect.fromLTWH(lamp.dx - 3, lamp.dy + 27, 6, 60), _fill(const Color(0xFF5A4E8E)));
    _floor(canvas, size, day ? const Color(0xFFBFB2E6) : const Color(0xFF2A2552), day ? const Color(0xFFADA0DA) : const Color(0xFF231F47));
    // Bed (friends sleep on its quilt).
    final bed = RRect.fromRectAndCorners(Rect.fromLTWH(w * 0.06 + _mid * 0.3, floorY - 40, w * 0.88, 96), topLeft: const Radius.circular(30), topRight: const Radius.circular(30), bottomLeft: const Radius.circular(14), bottomRight: const Radius.circular(14));
    canvas.drawRRect(bed.shift(const Offset(0, 8)), _fill(const Color(0x33000000)));
    canvas.drawRRect(bed, _fill(const Color(0xFF5B4FA0)));
    canvas.drawRRect(RRect.fromRectAndCorners(Rect.fromLTWH(bed.left, bed.top, bed.width, 22), topLeft: const Radius.circular(30), topRight: const Radius.circular(30)), _fill(const Color(0xFF6E62B5)));
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(bed.left + 16, bed.top - 18, 80, 32), const Radius.circular(16)), _fill(const Color(0xFFEDE6FF)));
  }

  void _playroom(Canvas canvas, Size size, double w) {
    _wall(canvas, size, const [Color(0xFFF6F2FF), Color(0xFFE9E1FF)], dots: const Color(0x99E1D7FF));
    // Bunting.
    final colors = [const Color(0xFFF2B632), const Color(0xFFC2386A), const Color(0xFF5BA7D9), const Color(0xFF7CBF62)];
    for (var i = 0; i < 8; i++) {
      final x = w * (i / 7) + _back;
      final y = floorY * 0.12 + math.sin(i / 7 * math.pi) * 22;
      final p = Path()
        ..moveTo(x - 14, y)
        ..lineTo(x + 14, y)
        ..lineTo(x, y + 26)
        ..close();
      canvas.drawPath(p, _fill(colors[i % 4]));
    }
    _floor(canvas, size, const Color(0xFFCFE7C9), const Color(0xFFB9DBB1));
    // Toy block and ball on the floor.
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.06 + _mid, floorY - 30, 52, 38), const Radius.circular(8)), _fill(const Color(0xFFF6D27A)));
    final ball = Offset(w * 0.88 + _mid, floorY - 16);
    canvas.drawCircle(ball, 22, Paint()..shader = SweepGradient(colors: [colors[0], colors[1], colors[2], colors[3], colors[0]]).createShader(Rect.fromCircle(center: ball, radius: 22)));
  }

  void _garden(Canvas canvas, Size size, double w) {
    final sky = switch (daypart) {
      Daypart.morning => const [Color(0xFFFFD9B8), Color(0xFFFDF0E2)],
      Daypart.day => const [Color(0xFFCDE9F8), Color(0xFFEAF6FB)],
      Daypart.evening => const [Color(0xFFF4A58C), Color(0xFFFFD9AE)],
      Daypart.night => const [Color(0xFF1E1A3C), Color(0xFF3A3470)],
    };
    final r = Offset.zero & size;
    canvas.drawRect(r, Paint()..shader = LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: sky).createShader(r));
    final sun = Offset(w * 0.8 + _back * 0.5, floorY * 0.22);
    canvas.drawCircle(sun, 34, _fill(daypart == Daypart.night ? const Color(0xFFFFE7A8) : const Color(0xFFFFE59A)));
    for (var i = 0; i < 2; i++) {
      final cx = (w * (0.15 + 0.5 * i) + time * (6 + i * 3) + _back) % (w + 120) - 60;
      final cy = floorY * (0.3 + 0.12 * i);
      final c = _fill(Colors.white.withValues(alpha: daypart == Daypart.night ? 0.25 : 0.9));
      canvas.drawCircle(Offset(cx, cy), 18, c);
      canvas.drawCircle(Offset(cx + 22, cy - 6), 24, c);
      canvas.drawCircle(Offset(cx + 46, cy), 17, c);
    }
    // Rolling hill.
    final hill = Path()
      ..moveTo(0, floorY - 24)
      ..quadraticBezierTo(w / 2 + _mid, floorY - 70, w, floorY - 24)
      ..lineTo(w, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(hill, Paint()..shader = const LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFFA9D88F), Color(0xFF8CC575)]).createShader(r));
    final rng = math.Random(9);
    for (var i = 0; i < 14; i++) {
      final p = Offset(rng.nextDouble() * w + _mid, floorY + rng.nextDouble() * (size.height - floorY) * 0.6);
      canvas.drawCircle(p, 4, _fill(i.isEven ? const Color(0xFFFFFFFF) : const Color(0xFFF7A9BD)));
      canvas.drawCircle(p, 1.6, _fill(const Color(0xFFF2B632)));
    }
    // Nest for the egg.
    _shadowEllipse(canvas, Offset(w / 2 + _mid * 0.4, floorY + 14), 170, 34);
    canvas.drawOval(Rect.fromCenter(center: Offset(w / 2 + _mid * 0.4, floorY), width: 160, height: 56), _fill(const Color(0xFFE9C79A)));
    canvas.drawOval(Rect.fromCenter(center: Offset(w / 2 + _mid * 0.4, floorY - 6), width: 128, height: 30), _fill(const Color(0xFFD7AE7C)));
  }

  /// Time-of-day wash over everything except the bedroom (which has its own).
  void _light(Canvas canvas, Size size) {
    if (room == Room.bedroom) return;
    final tint = switch (daypart) {
      Daypart.morning => const Color(0x14FFB070),
      Daypart.day => null,
      Daypart.evening => const Color(0x26FF8A5C),
      Daypart.night => const Color(0x8C1C1840),
    };
    if (tint != null) canvas.drawRect(Offset.zero & size, Paint()..color = tint);
  }

  @override
  bool shouldRepaint(RoomBackdrop old) =>
      old.room != room || old.daypart != daypart || old.parallax != parallax || old.floorY != floorY || old.lampOn != lampOn || old.time != time;
}
