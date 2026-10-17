import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../icons.dart';

/// Hand-drawn snack icon for any species' menu (no emoji: they must render
/// identically everywhere and in screenshot tests).
class SnackIcon extends StatelessWidget {
  const SnackIcon(this.id, {super.key, this.size = 40});
  final String id;
  final double size;

  static const _mofu = {'strawberry', 'dango', 'cookie', 'onigiri', 'pudding', 'candy'};

  @override
  Widget build(BuildContext context) {
    if (_mofu.contains(id)) return MofuIconView(snackIcon(id), size: size);
    return CustomPaint(size: Size.square(size), painter: _SnackPainter(id));
  }
}

class _SnackPainter extends CustomPainter {
  _SnackPainter(this.id);
  final String id;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / 100);
    Paint f(Color c) => Paint()..color = c;
    Paint line(Color c, double w) => Paint()
      ..color = c
      ..style = PaintingStyle.stroke
      ..strokeWidth = w
      ..strokeCap = StrokeCap.round;
    switch (id) {
      case 'apple':
        final p = Path()
          ..moveTo(50, 30)
          ..cubicTo(70, 18, 92, 30, 88, 56)
          ..cubicTo(84, 82, 64, 92, 50, 86)
          ..cubicTo(36, 92, 16, 82, 12, 56)
          ..cubicTo(8, 30, 30, 18, 50, 30)
          ..close();
        canvas.drawPath(p, f(const Color(0xFFE2504F)));
        canvas.drawOval(const Rect.fromLTWH(26, 38, 14, 22), f(const Color(0x55FFFFFF)));
        canvas.drawLine(const Offset(50, 30), const Offset(54, 12), line(const Color(0xFF6B3E25), 6));
        canvas.drawOval(const Rect.fromLTWH(54, 10, 24, 12), f(const Color(0xFF6BB46A)));
      case 'carrot':
        final p = Path()
          ..moveTo(22, 88)
          ..lineTo(66, 30)
          ..quadraticBezierTo(80, 28, 82, 42)
          ..close();
        canvas.drawPath(p, f(const Color(0xFFF08A3E)));
        for (final a in const [-0.9, -0.5, -0.1]) {
          canvas.drawLine(const Offset(74, 34), Offset(74 + 22 * math.cos(a), 34 - 26 * math.sin(-a + 1.2)), line(const Color(0xFF5FA35B), 7));
        }
        for (var i = 0; i < 3; i++) {
          canvas.drawLine(Offset(44 + i * 9.0, 62 - i * 11.0), Offset(52 + i * 9.0, 64 - i * 11.0), line(const Color(0xFFC86A2A), 3));
        }
      case 'corn':
        canvas.drawOval(const Rect.fromLTWH(32, 12, 36, 70), f(const Color(0xFFF6CF4C)));
        for (var y = 22.0; y < 76; y += 10) {
          canvas.drawLine(Offset(38, y), Offset(62, y), line(const Color(0xFFE2B33A), 2));
        }
        final husk = Path()
          ..moveTo(30, 54)
          ..quadraticBezierTo(18, 82, 50, 92)
          ..quadraticBezierTo(82, 82, 70, 54)
          ..quadraticBezierTo(60, 84, 50, 86)
          ..quadraticBezierTo(40, 84, 30, 54)
          ..close();
        canvas.drawPath(husk, f(const Color(0xFF7CBF62)));
      case 'lettuce':
        for (var i = 0; i < 7; i++) {
          final a = i / 7 * 2 * math.pi;
          canvas.drawCircle(Offset(50 + 24 * math.cos(a), 54 + 20 * math.sin(a)), 20, f(i.isEven ? const Color(0xFF8FD27A) : const Color(0xFF7CC266)));
        }
        canvas.drawCircle(const Offset(50, 54), 18, f(const Color(0xFFB8E6A0)));
      case 'watermelon':
        canvas.drawArc(const Rect.fromLTWH(10, 10, 80, 80), 0, math.pi, true, f(const Color(0xFF6BB46A)));
        canvas.drawArc(const Rect.fromLTWH(16, 16, 68, 68), 0, math.pi, true, f(const Color(0xFFF0606E)));
        for (final d in const [Offset(38, 60), Offset(50, 68), Offset(62, 60)]) {
          canvas.drawOval(Rect.fromCenter(center: d, width: 5, height: 8), f(const Color(0xFF3A2A2E)));
        }
      case 'bone':
        final bone = Path()..addRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(26, 42, 48, 16), const Radius.circular(8)));
        for (final c in const [Offset(24, 40), Offset(24, 60), Offset(76, 40), Offset(76, 60)]) {
          bone.addOval(Rect.fromCircle(center: c, radius: 12));
        }
        canvas.drawPath(bone, line(const Color(0xFFB98F5E), 6));
        canvas.drawPath(bone, f(const Color(0xFFFFF4E0)));
        canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(12, 28, 76, 44), const Radius.circular(22)), line(const Color(0xFFE6D3B8), 2.5));
      case 'bacon':
        for (var k = 0; k < 2; k++) {
          final y0 = 30.0 + k * 26;
          final wave = Path()..moveTo(12, y0);
          for (var x = 12.0; x <= 88; x += 4) {
            wave.lineTo(x, y0 + math.sin(x / 8) * 5);
          }
          canvas.drawPath(wave, line(const Color(0xFFB8402F), 16));
          canvas.drawPath(wave, line(const Color(0xFFF7C9B4), 5));
        }
      case 'cheese':
        final p = Path()
          ..moveTo(14, 70)
          ..lineTo(86, 70)
          ..lineTo(86, 38)
          ..lineTo(14, 56)
          ..close();
        canvas.drawPath(p, f(const Color(0xFFF6D27A)));
        for (final h in const [Offset(36, 60), Offset(62, 52), Offset(74, 62)]) {
          canvas.drawCircle(h, 5, f(const Color(0xFFE2B455)));
        }
      case 'cupcake':
        final cup = Path()
          ..moveTo(26, 52)
          ..lineTo(74, 52)
          ..lineTo(66, 88)
          ..lineTo(34, 88)
          ..close();
        canvas.drawPath(cup, f(const Color(0xFF9FC6F0)));
        canvas.drawCircle(const Offset(36, 46), 15, f(const Color(0xFFFFC3D5)));
        canvas.drawCircle(const Offset(64, 46), 15, f(const Color(0xFFFFC3D5)));
        canvas.drawCircle(const Offset(50, 36), 17, f(const Color(0xFFFFD3E0)));
        canvas.drawCircle(const Offset(50, 18), 6, f(const Color(0xFFE2504F)));
      case 'blueberry':
        for (final c in const [Offset(38, 58), Offset(62, 58), Offset(50, 38)]) {
          canvas.drawCircle(c, 18, f(const Color(0xFF5B6FC9)));
          canvas.drawCircle(c + const Offset(-5, -6), 4, f(const Color(0x66FFFFFF)));
        }
      case 'cherry':
        canvas.drawLine(const Offset(36, 62), const Offset(56, 18), line(const Color(0xFF5FA35B), 4));
        canvas.drawLine(const Offset(66, 66), const Offset(56, 18), line(const Color(0xFF5FA35B), 4));
        canvas.drawCircle(const Offset(34, 68), 16, f(const Color(0xFFD7263D)));
        canvas.drawCircle(const Offset(68, 72), 16, f(const Color(0xFFD7263D)));
      case 'grape':
        for (var row = 0; row < 3; row++) {
          for (var i = 0; i <= 2 - row; i++) {
            canvas.drawCircle(Offset(30 + i * 20.0 + row * 10, 40 + row * 18.0), 12, f(const Color(0xFF9B6AD6)));
          }
        }
        canvas.drawLine(const Offset(50, 30), const Offset(54, 12), line(const Color(0xFF6B3E25), 4));
      case 'peach':
        canvas.drawCircle(const Offset(50, 56), 34, f(const Color(0xFFFFB38A)));
        canvas.drawArc(const Rect.fromLTWH(20, 24, 56, 64), -1.2, 1.4, false, line(const Color(0xFFF08F6A), 3));
        canvas.drawOval(const Rect.fromLTWH(50, 12, 24, 12), f(const Color(0xFF6BB46A)));
      default:
        canvas.drawCircle(const Offset(50, 50), 30, f(const Color(0xFFF6D27A)));
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(_SnackPainter old) => old.id != id;
}
