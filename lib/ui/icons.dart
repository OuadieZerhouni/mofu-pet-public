import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Hand-drawn icons in Mofu's soft style, for the dock and the snack tray.
///
/// Custom painted rather than emoji so they look identical on every iOS
/// version, match the creature's palette, and render in tests (which have no
/// emoji font) — the App Store screenshots are rendered from tests.
enum MofuIcon { brush, snacks, wardrobe, journal, strawberry, dango, cookie, onigiri, pudding, candy }

MofuIcon snackIcon(String id) => switch (id) {
      'strawberry' => MofuIcon.strawberry,
      'dango' => MofuIcon.dango,
      'cookie' => MofuIcon.cookie,
      'onigiri' => MofuIcon.onigiri,
      'pudding' => MofuIcon.pudding,
      _ => MofuIcon.candy,
    };

class MofuIconView extends StatelessWidget {
  const MofuIconView(this.icon, {super.key, this.size = 30, this.tint});
  final MofuIcon icon;
  final double size;

  /// When set, the icon is drawn in a single colour (active dock button).
  final Color? tint;

  @override
  Widget build(BuildContext context) =>
      CustomPaint(size: Size.square(size), painter: _IconPainter(icon, tint));
}

class _IconPainter extends CustomPainter {
  _IconPainter(this.icon, this.tint);
  final MofuIcon icon;
  final Color? tint;

  Color c(Color col) => tint ?? col;

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width / 100; // drawn on a 100×100 grid
    canvas.save();
    canvas.scale(s);
    Paint f(Color col) => Paint()..color = c(col);
    Paint line(Color col, double w) => Paint()
      ..color = c(col)
      ..style = PaintingStyle.stroke
      ..strokeWidth = w
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    switch (icon) {
      case MofuIcon.brush:
        // A round pet brush: wooden handle, pink head, soft bristles.
        canvas.save();
        canvas.translate(50, 50);
        canvas.rotate(-math.pi / 4);
        canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(-9, 6, 18, 42), const Radius.circular(9)),
            f(const Color(0xFFE2B48C)));
        canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(-26, -40, 52, 48), const Radius.circular(22)),
            f(const Color(0xFFFF9EBF)));
        for (var x = -16; x <= 16; x += 8) {
          for (var y = -30; y <= -4; y += 9) {
            canvas.drawCircle(Offset(x.toDouble(), y.toDouble()), 2.6, f(Colors.white));
          }
        }
        canvas.restore();
      case MofuIcon.snacks:
      case MofuIcon.strawberry:
        final body = Path()
          ..moveTo(50, 92)
          ..cubicTo(18, 70, 14, 40, 30, 32)
          ..cubicTo(40, 27, 46, 30, 50, 33)
          ..cubicTo(54, 30, 60, 27, 70, 32)
          ..cubicTo(86, 40, 82, 70, 50, 92)
          ..close();
        canvas.drawPath(body, f(const Color(0xFFFF5D73)));
        for (final p in const [Offset(38, 48), Offset(50, 44), Offset(62, 48), Offset(44, 62), Offset(56, 62), Offset(50, 76)]) {
          canvas.drawOval(Rect.fromCenter(center: p, width: 3.5, height: 5), f(const Color(0xFFFFE08A)));
        }
        final leaf = Path()
          ..moveTo(50, 34)
          ..lineTo(34, 22)
          ..lineTo(44, 30)
          ..lineTo(50, 14)
          ..lineTo(56, 30)
          ..lineTo(66, 22)
          ..close();
        canvas.drawPath(leaf, f(const Color(0xFF5FBF6F)));
      case MofuIcon.wardrobe:
        for (final side in const [-1, 1]) {
          final p = Path()
            ..moveTo(50, 50)
            ..cubicTo(50 + side * 18, 22, 50 + side * 44, 26, 50 + side * 40, 50)
            ..cubicTo(50 + side * 44, 74, 50 + side * 18, 78, 50, 50)
            ..close();
          canvas.drawPath(p, f(const Color(0xFFFF7FA8)));
          canvas.drawPath(
              Path()
                ..moveTo(50, 52)
                ..lineTo(50 + side * 14, 86),
              line(const Color(0xFFFF7FA8), 9));
        }
        canvas.drawCircle(const Offset(50, 50), 11, f(const Color(0xFFE85C8A)));
      case MofuIcon.journal:
        canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(20, 14, 62, 74), const Radius.circular(12)),
            f(const Color(0xFF9FC6F0)));
        canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(20, 14, 14, 74), const Radius.circular(8)),
            f(const Color(0xFF7FAEE0)));
        final h = Path()
          ..moveTo(57, 64)
          ..cubicTo(40, 52, 44, 36, 57, 44)
          ..cubicTo(70, 36, 74, 52, 57, 64)
          ..close();
        canvas.drawPath(h, f(Colors.white));
      case MofuIcon.dango:
        canvas.drawLine(const Offset(50, 6), const Offset(50, 96), line(const Color(0xFFD9A066), 5));
        canvas.drawCircle(const Offset(50, 24), 15, f(const Color(0xFFFFA9C4)));
        canvas.drawCircle(const Offset(50, 50), 15, f(const Color(0xFFFFF4E6)));
        canvas.drawCircle(const Offset(50, 76), 15, f(const Color(0xFFA8DDB0)));
      case MofuIcon.cookie:
        canvas.drawCircle(const Offset(50, 52), 36, f(const Color(0xFFE5B27A)));
        for (final p in const [Offset(38, 40), Offset(60, 38), Offset(50, 58), Offset(34, 64), Offset(66, 62)]) {
          canvas.drawCircle(p, 5, f(const Color(0xFF6E4630)));
        }
      case MofuIcon.onigiri:
        final tri = Path()
          ..moveTo(50, 14)
          ..cubicTo(60, 14, 92, 72, 86, 82)
          ..cubicTo(80, 90, 20, 90, 14, 82)
          ..cubicTo(8, 72, 40, 14, 50, 14)
          ..close();
        canvas.drawPath(tri, f(Colors.white));
        canvas.drawPath(tri, line(const Color(0xFFE8DCD0), 2.5));
        canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(34, 58, 32, 30), const Radius.circular(4)),
            f(const Color(0xFF34465A)));
      case MofuIcon.pudding:
        final p = Path()
          ..moveTo(26, 82)
          ..lineTo(34, 34)
          ..quadraticBezierTo(50, 26, 66, 34)
          ..lineTo(74, 82)
          ..close();
        canvas.drawPath(p, f(const Color(0xFFFFD873)));
        canvas.drawPath(
            Path()
              ..moveTo(33, 40)
              ..quadraticBezierTo(50, 26, 67, 40)
              ..lineTo(66, 34)
              ..quadraticBezierTo(50, 22, 34, 34)
              ..close(),
            f(const Color(0xFFB0662E)));
        canvas.drawOval(const Rect.fromLTWH(18, 78, 64, 12), f(const Color(0xFFF1E6F0)));
      case MofuIcon.candy:
        canvas.drawCircle(const Offset(50, 50), 20, f(const Color(0xFF9FD8FF)));
        for (final side in const [-1, 1]) {
          final w = Path()
            ..moveTo(50 + side * 18.0, 50)
            ..lineTo(50 + side * 42.0, 34)
            ..lineTo(50 + side * 42.0, 66)
            ..close();
          canvas.drawPath(w, f(const Color(0xFFFFB3D1)));
        }
        canvas.drawLine(const Offset(42, 38), const Offset(58, 62), line(Colors.white, 4));
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(_IconPainter old) => old.icon != icon || old.tint != tint;
}
