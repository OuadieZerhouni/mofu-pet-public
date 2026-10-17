// Dev tool, skipped by default: renders flagship ("Mofu & Friends") app-icon
// candidates from the app's own painter — Mofu at home, in the house palette.
//
//   flutter test test/icon_flagship_test.dart --run-skipped
//   python <build-app skill>/scripts/icon_review.py build/icon/flagship/*.png -o build/icon/review.png
//
// Output: build/icon/flagship/<name>.png, 1024×1024, opaque.
import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mofu_pet/model/catalog.dart';
import 'package:mofu_pet/sim/mofu_sim.dart';
import 'package:mofu_pet/ui/mofu_painter.dart';

const s = 1024.0;
const rect = Rect.fromLTWH(0, 0, s, s);

enum Frame { none, window, house }

class Variant {
  const Variant(this.name, this.fur, this.top, this.bottom, this.expr,
      {this.frame = Frame.none, this.night = false, this.scale = 0.30, this.inside = const Color(0xFFCFE8FF)});
  final String name;
  final String fur;
  final Color top;
  final Color bottom;
  final Expr expr;
  final Frame frame;
  final bool night;
  final double scale;
  final Color inside;
}

const variants = [
  Variant('a_rose_plain', 'peach', Color(0xFFF59AB4), Color(0xFFFFD9C7), Expr.happy, scale: 0.215),
  Variant('b_night_plain', 'peach', Color(0xFF241F45), Color(0xFF4A3F86), Expr.happy, night: true, scale: 0.215),
  Variant('b2_night_cream', 'cream', Color(0xFF241F45), Color(0xFF4A3F86), Expr.happy, night: true, scale: 0.215),
  Variant('c_window_day', 'peach', Color(0xFFC2386A), Color(0xFFE76B92), Expr.happy, frame: Frame.window, scale: 0.19, inside: Color(0xFFBFE0FF)),
  Variant('d_window_night', 'peach', Color(0xFF241F45), Color(0xFF3A3470), Expr.happy,
      frame: Frame.window, night: true, scale: 0.19, inside: Color(0xFFF7B36B)),
  Variant('e_house_rose', 'peach', Color(0xFFFFD9C7), Color(0xFFFBF3E8), Expr.happy, frame: Frame.house, scale: 0.17, inside: Color(0xFFF2B26A)),
  Variant('f_house_night', 'peach', Color(0xFF241F45), Color(0xFF3A3470), Expr.happy,
      frame: Frame.house, night: true, scale: 0.17, inside: Color(0xFFF2B26A)),
  Variant('g_house_night_big', 'peach', Color(0xFF241F45), Color(0xFF3A3470), Expr.happy,
      frame: Frame.house, night: true, scale: 0.205, inside: Color(0xFFF2B26A)),
];

void _stars(Canvas c) {
  final rng = math.Random(7);
  final p = Paint()..color = const Color(0xFFFFF3D6);
  for (var i = 0; i < 26; i++) {
    final o = Offset(rng.nextDouble() * s, rng.nextDouble() * s * 0.45);
    c.drawCircle(o, 3 + rng.nextDouble() * 5, p..color = p.color.withValues(alpha: 0.5 + rng.nextDouble() * 0.5));
  }
  // Crescent moon, top right.
  const m = Offset(s * 0.80, s * 0.17);
  c.saveLayer(rect, Paint());
  c.drawCircle(m, 70, Paint()..color = const Color(0xFFFFE7A8));
  c.drawCircle(m + const Offset(-30, -18), 62, Paint()..blendMode = BlendMode.clear);
  c.restore();
}

/// An arched window; returns the clip path of its glass.
Path _window(Canvas c, Variant v) {
  const w = s * 0.70, h = s * 0.80;
  final r = Rect.fromLTWH((s - w) / 2, s * 0.13, w, h);
  Path arch(Rect r) => Path()
    ..moveTo(r.left, r.bottom)
    ..lineTo(r.left, r.top + r.width / 2)
    ..arcToPoint(Offset(r.right, r.top + r.width / 2), radius: Radius.circular(r.width / 2))
    ..lineTo(r.right, r.bottom)
    ..close();
  c.drawPath(arch(r.inflate(34)).shift(const Offset(0, 14)), Paint()..color = Colors.black.withValues(alpha: 0.18)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 24));
  c.drawPath(arch(r.inflate(34)), Paint()..color = v.night ? const Color(0xFF94603D) : const Color(0xFFFBF3E8));
  final glass = arch(r);
  c.drawPath(glass, Paint()..shader = RadialGradient(colors: [const Color(0xFFFFF6E6), v.inside], radius: 0.8, center: const Alignment(0, 0.2)).createShader(r));
  return glass;
}

/// A rounded little house (roof + body); returns the clip of its doorway.
Path _house(Canvas c, Variant v) {
  const bw = s * 0.74, bh = s * 0.50;
  final body = RRect.fromRectAndRadius(Rect.fromLTWH((s - bw) / 2, s * 0.44, bw, bh), const Radius.circular(70));
  final roof = Path()
    ..moveTo(s * 0.08, s * 0.50)
    ..quadraticBezierTo(s * 0.06, s * 0.45, s * 0.12, s * 0.41)
    ..lineTo(s * 0.45, s * 0.14)
    ..quadraticBezierTo(s * 0.50, s * 0.10, s * 0.55, s * 0.14)
    ..lineTo(s * 0.88, s * 0.41)
    ..quadraticBezierTo(s * 0.94, s * 0.45, s * 0.92, s * 0.50)
    ..close();
  final shadow = Paint()..color = Colors.black.withValues(alpha: 0.18)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 24);
  c.drawRRect(body.shift(const Offset(0, 14)), shadow);
  c.drawRRect(body, Paint()..color = v.night ? const Color(0xFFFBF3E8) : const Color(0xFFFFFFFF));
  c.drawPath(roof.shift(const Offset(0, 10)), shadow);
  c.drawPath(roof, Paint()..color = v.night ? const Color(0xFF7E4F31) : const Color(0xFFC2386A));
  final door = RRect.fromRectAndCorners(Rect.fromLTWH(s * 0.25, s * 0.36, s * 0.50, s * 0.58),
      topLeft: const Radius.circular(s * 0.25), topRight: const Radius.circular(s * 0.25));
  c.drawRRect(door, Paint()..shader = RadialGradient(colors: [const Color(0xFFFFF6E6), v.inside], radius: 0.75, center: const Alignment(0, 0.1)).createShader(door.outerRect));
  return Path()..addRRect(door);
}

void main() {
  testWidgets('render flagship icon candidates', (tester) async {
    await tester.runAsync(() async {
      for (final v in variants) {
        final rec = ui.PictureRecorder();
        final canvas = Canvas(rec);
        canvas.drawRect(rect, Paint()..shader = LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [v.top, v.bottom]).createShader(rect));
        if (v.night) _stars(canvas);
        Path? clip;
        switch (v.frame) {
          case Frame.window:
            clip = _window(canvas, v);
          case Frame.house:
            clip = _house(canvas, v);
          case Frame.none:
            canvas.drawCircle(const Offset(s / 2, s * 0.55), s * 0.42,
                Paint()..color = (v.night ? const Color(0xFFFFE3A8) : Colors.white).withValues(alpha: v.night ? 0.28 : 0.5)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 70));
        }
        final sim = MofuSim(seed: 5, reduceMotion: true)
          ..fluff = 0.6
          ..layout(const Size(s, s), top: 0, floor: s);
        sim.baseRadius = s * v.scale;
        sim.pos = Offset(s / 2, switch (v.frame) { Frame.none => s * 0.54, Frame.window => s * 0.62, Frame.house => s * 0.72 });
        sim.expr = v.expr;
        if (clip != null) {
          canvas.save();
          canvas.clipPath(clip);
        }
        paintMofu(canvas, sim, Catalog.color(v.fur), 'none', shadow: false);
        if (clip != null) canvas.restore();
        final img = await rec.endRecording().toImage(s.toInt(), s.toInt());
        final bytes = await img.toByteData(format: ui.ImageByteFormat.png);
        File('build/icon/flagship/${v.name}.png')
          ..createSync(recursive: true)
          ..writeAsBytesSync(bytes!.buffer.asUint8List());
      }
    });
  }, skip: true);
}
