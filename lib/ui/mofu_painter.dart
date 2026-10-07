import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../model/catalog.dart';
import '../sim/mofu_sim.dart';

/// Draws Mofu, its shadow, accessory and particles from a [MofuSim].
///
/// Everything is procedural, so the creature scales to any screen and every
/// fur colour is just a palette. Strands are batched into one path per
/// (layer, light bucket) — about nine draw calls for ~700 hairs — which is
/// what keeps a full-fluff Mofu inside the frame budget.
class MofuPainter extends CustomPainter {
  MofuPainter({required this.sim, required this.color, required this.accessory, required Listenable repaint})
      : super(repaint: repaint);

  final MofuSim sim;
  final FurColor color;
  final String accessory;

  static const _lightDir = Offset(-0.55, -0.83);

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;
    paintMofu(canvas, sim, color, accessory);
    paintParticles(canvas, sim);
  }

  @override
  bool shouldRepaint(MofuPainter old) =>
      old.color != color || old.accessory != accessory || old.sim != sim;
}

/// Exposed for the icon/screenshot renderer and the pixel tests.
void paintMofu(Canvas canvas, MofuSim sim, FurColor c, String accessory, {bool shadow = true}) {
  final r = sim.radius;
  final center = sim.pos;
  final pivot = center + Offset(0, r);

  if (shadow) _paintShadow(canvas, sim);

  final breath = sim.breath;
  final sx = (1 + sim.squash * 0.55) / math.pow(breath, 0.5);
  final sy = breath * (1 - sim.squash);

  canvas.save();
  canvas.translate(pivot.dx, pivot.dy);
  canvas.rotate((sim.rot * 0.16).clamp(-0.6, 0.6));
  canvas.scale(sx, sy);
  canvas.translate(-pivot.dx, -pivot.dy);

  _paintFur(canvas, sim, c, outer: true);
  _paintBody(canvas, center, r, c);
  _paintFur(canvas, sim, c, outer: false);
  _paintFace(canvas, sim, c);
  if (accessory != 'none') paintAccessory(canvas, accessory, center, r, sim.furLength);

  canvas.restore();
}

void _paintShadow(Canvas canvas, MofuSim sim) {
  final r = sim.radius;
  final height = (sim.floorY - (sim.pos.dy + r)).clamp(0.0, 400.0);
  final k = 1 - height / 500;
  final w = r * 1.7 * (0.6 + 0.4 * k) * (1 + sim.squash * 0.5);
  final paint = Paint()
    ..color = Colors.black.withValues(alpha: 0.10 * k)
    ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
  canvas.drawOval(Rect.fromCenter(center: Offset(sim.pos.dx, sim.floorY + 2), width: w, height: r * 0.22), paint);
}

void _paintBody(Canvas canvas, Offset c, double r, FurColor col) {
  final rect = Rect.fromCircle(center: c, radius: r);
  final shader = RadialGradient(
    center: const Alignment(-0.35, -0.45),
    radius: 1.05,
    colors: [col.light, col.base, col.shade],
    stops: const [0.0, 0.55, 1.0],
  ).createShader(rect);
  canvas.drawCircle(c, r * 0.98, Paint()..shader = shader);
}

/// Strand drawing. `outer` = the silhouette layer drawn behind the body;
/// otherwise the mid layer (soft edge over the body) and the inner tufts.
///
/// Each layer is drawn twice: a wide translucent pass that reads as soft
/// volume, then a thin crisp pass that reads as individual hairs. One pass
/// alone looks either like a blur or like a sea urchin.
void _paintFur(Canvas canvas, MofuSim sim, FurColor col, {required bool outer}) {
  final r = sim.radius;
  final c = sim.pos;
  final furLen = sim.furLength;
  final buckets = List<Path>.generate(5, (_) => Path());
  final tufts = Path();

  if (outer) {
    // The puff: a blurred disc just beyond the body gives the fur its depth.
    canvas.drawCircle(
      c,
      r + furLen * 0.45,
      Paint()
        ..color = col.base.withValues(alpha: 0.9)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, math.max(2, furLen * 0.35)),
    );
  }

  for (final s in sim.strands) {
    final isOuter = s.radial >= 1.0;
    if (isOuter != outer) continue;
    final isTuft = s.radial < 0.8;
    final cosA = math.cos(s.angle), sinA = math.sin(s.angle);
    final root = c + Offset(cosA, sinA) * (r * (isOuter ? 0.90 : s.radial));
    final jitter = (s.seed - 0.5) * 2 * s.mess;
    final len = isTuft ? r * 0.09 * s.length * 2 : furLen * s.length * (isOuter ? 1.0 : 0.7) + r * 0.08;
    // Gravity: hairs on the lower half droop a little, more when fluffy.
    final droop = sinA > 0 ? sinA * 0.16 * sim.fluff : 0.0;
    final side = cosA >= 0 ? droop : -droop;
    final midA = s.angle + s.bend * 0.32 + s.curl * 0.12 + jitter * 0.8 + side;
    final tipA = s.angle + s.bend * 0.6 + s.curl * 0.24 + jitter * 1.4 + side * 1.6;
    final ctrl = root + Offset(math.cos(midA), math.sin(midA)) * (len * 0.55);
    final tip = ctrl + Offset(math.cos(tipA), math.sin(tipA)) * (len * 0.5);
    final path = isTuft ? tufts : buckets[_bucket(cosA, sinA, s.seed)];
    path
      ..moveTo(root.dx, root.dy)
      ..quadraticBezierTo(ctrl.dx, ctrl.dy, tip.dx, tip.dy);
  }

  // Five tones from sunlit to shaded, so the light falls off smoothly.
  final from = outer ? col.light : col.light;
  final to = outer ? Color.lerp(col.base, col.shade, 0.6)! : col.base;
  final colors = [for (var i = 0; i < 5; i++) Color.lerp(from, to, i / 4)!];
  final thin = r * (outer ? 0.026 : 0.022);
  for (var i = 0; i < 5; i++) {
    final soft = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = thin * 2.6
      ..color = colors[i].withValues(alpha: 0.35);
    canvas.drawPath(buckets[i], soft);
  }
  for (var i = 0; i < 5; i++) {
    canvas.drawPath(
      buckets[i],
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = thin
        ..color = colors[i],
    );
  }
  if (!outer) {
    canvas.drawPath(
      tufts,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = r * 0.022
        ..color = col.light.withValues(alpha: 0.5),
    );
  }
}

/// Light bucket 0 (sunlit) … 4 (shade), dithered per strand by its seed so
/// bucket boundaries never show as a straight seam in the fur.
int _bucket(double cosA, double sinA, double seed) {
  final lit = cosA * MofuPainter._lightDir.dx + sinA * MofuPainter._lightDir.dy + (seed - 0.5) * 0.5;
  final v = ((1 - lit) / 2 * 5).floor();
  return v.clamp(0, 4);
}

void _paintFace(Canvas canvas, MofuSim sim, FurColor col) {
  final r = sim.radius;
  final c = sim.pos;
  final ink = col.id == 'starry' ? const Color(0xFF1E1A3A) : const Color(0xFF3A2A33);
  final e = sim.expr;

  // Cheeks first so eyes sit on top.
  final blush = switch (e) {
    Expr.love || Expr.bliss => 0.75,
    Expr.giggle || Expr.happy || Expr.proud || Expr.eating => 0.6,
    _ => 0.45,
  };
  final puff = sim.cheekPuff;
  final cheekPaint = Paint()
    ..color = col.cheek.withValues(alpha: blush)
    ..maskFilter = MaskFilter.blur(BlurStyle.normal, r * 0.05);
  for (final side in const [-1, 1]) {
    canvas.drawOval(
      Rect.fromCenter(
        center: c + Offset(side * r * (0.52 + puff * 0.04), r * 0.16),
        width: r * (0.26 + puff * 0.1),
        height: r * (0.15 + puff * 0.06),
      ),
      cheekPaint,
    );
  }

  final stroke = Paint()
    ..color = ink
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round
    ..strokeWidth = r * 0.045;
  final fill = Paint()..color = ink;

  for (final side in const [-1, 1]) {
    final eye = c + Offset(side * r * 0.34, -r * 0.06);
    switch (e) {
      case Expr.happy || Expr.giggle || Expr.proud || Expr.eating:
        _arc(canvas, eye, r * 0.10, up: true, paint: stroke);
      case Expr.bliss || Expr.asleep || Expr.content:
        _arc(canvas, eye + Offset(0, -r * 0.02), r * 0.10, up: false, paint: stroke);
      case Expr.love:
        _heart(canvas, eye, r * 0.13, Paint()..color = const Color(0xFFFF5C8A));
      case Expr.protest:
        _chevron(canvas, eye, r * 0.09, side, stroke);
      case Expr.dizzy:
        _spiral(canvas, eye, r * 0.10, stroke..strokeWidth = r * 0.032);
        stroke.strokeWidth = r * 0.045;
      case Expr.sleepy:
        _openEye(canvas, sim, eye, r, ink, lid: 0.55);
      case Expr.surprised:
        _openEye(canvas, sim, eye, r, ink, scale: 1.18);
      case Expr.idle:
        _openEye(canvas, sim, eye, r, ink, lid: sim.blink);
    }
  }

  // Mouth.
  final m = c + Offset(0, r * 0.2);
  final open = sim.mouthOpen;
  if (open > 0.08 || e == Expr.giggle) {
    final h = r * (0.08 + 0.16 * math.max(open, e == Expr.giggle ? 0.7 : 0));
    final w = r * (0.13 + 0.05 * open);
    final rect = Rect.fromCenter(center: m + Offset(0, h * 0.25), width: w, height: h);
    canvas.drawOval(rect, fill);
    canvas.save();
    canvas.clipPath(Path()..addOval(rect));
    canvas.drawOval(
      Rect.fromCenter(center: rect.bottomCenter - Offset(0, h * 0.15), width: w * 0.8, height: h * 0.6),
      Paint()..color = const Color(0xFFFF7E9A),
    );
    canvas.restore();
  } else {
    switch (e) {
      case Expr.protest:
        final p = Path()
          ..moveTo(m.dx - r * 0.08, m.dy + r * 0.02)
          ..quadraticBezierTo(m.dx - r * 0.04, m.dy - r * 0.03, m.dx, m.dy + r * 0.02)
          ..quadraticBezierTo(m.dx + r * 0.04, m.dy + r * 0.07, m.dx + r * 0.08, m.dy + r * 0.02);
        canvas.drawPath(p, stroke..strokeWidth = r * 0.035);
      case Expr.dizzy || Expr.surprised:
        canvas.drawOval(Rect.fromCenter(center: m + Offset(0, r * 0.03), width: r * 0.08, height: r * 0.1), fill);
      case Expr.asleep:
        final s = 0.5 + 0.5 * math.sin(sim.time * 2 * math.pi * 0.22);
        canvas.drawOval(
          Rect.fromCenter(center: m + Offset(0, r * 0.03), width: r * (0.05 + 0.03 * s), height: r * (0.05 + 0.04 * s)),
          fill,
        );
      default:
        // The "ω" mouth: two little arcs meeting in the middle.
        final p = Path()
          ..moveTo(m.dx - r * 0.11, m.dy)
          ..quadraticBezierTo(m.dx - r * 0.055, m.dy + r * 0.085, m.dx, m.dy + r * 0.005)
          ..quadraticBezierTo(m.dx + r * 0.055, m.dy + r * 0.085, m.dx + r * 0.11, m.dy);
        canvas.drawPath(p, stroke..strokeWidth = r * 0.038);
    }
  }
}

void _openEye(Canvas canvas, MofuSim sim, Offset eye, double r, Color ink, {double lid = 0, double scale = 1}) {
  final w = r * 0.165 * scale;
  final h = r * 0.215 * scale * (1 - lid * 0.92);
  if (h < r * 0.02) {
    canvas.drawLine(eye - Offset(w * 0.6, 0), eye + Offset(w * 0.6, 0),
        Paint()
          ..color = ink
          ..strokeWidth = r * 0.04
          ..strokeCap = StrokeCap.round);
    return;
  }
  final look = Offset(sim.lookX * r * 0.035, sim.lookY * r * 0.03);
  final rect = Rect.fromCenter(center: eye + look, width: w, height: h);
  canvas.drawOval(rect, Paint()..color = ink);
  final hl = Paint()..color = Colors.white.withValues(alpha: 0.95);
  canvas.drawCircle(rect.center + Offset(-w * 0.18, -h * 0.2), w * 0.2, hl);
  canvas.drawCircle(rect.center + Offset(w * 0.2, h * 0.18), w * 0.09, hl);
}

void _arc(Canvas canvas, Offset c, double s, {required bool up, required Paint paint}) {
  final p = Path()..moveTo(c.dx - s, c.dy + (up ? s * 0.35 : -s * 0.15));
  p.quadraticBezierTo(c.dx, c.dy + (up ? -s * 0.75 : s * 0.75), c.dx + s, c.dy + (up ? s * 0.35 : -s * 0.15));
  canvas.drawPath(p, paint);
}

void _chevron(Canvas canvas, Offset c, double s, int side, Paint paint) {
  // ">" on the left eye and "<" on the right, so together they read "><".
  final d = -side.toDouble();
  final p = Path()
    ..moveTo(c.dx - s * d * 0.7, c.dy - s * 0.8)
    ..lineTo(c.dx + s * d * 0.7, c.dy)
    ..lineTo(c.dx - s * d * 0.7, c.dy + s * 0.8);
  canvas.drawPath(p, paint);
}

void _spiral(Canvas canvas, Offset c, double s, Paint paint) {
  final p = Path();
  for (var i = 0; i <= 28; i++) {
    final t = i / 28;
    final a = t * math.pi * 3.2;
    final rr = s * t;
    final pt = c + Offset(math.cos(a), math.sin(a)) * rr;
    if (i == 0) {
      p.moveTo(pt.dx, pt.dy);
    } else {
      p.lineTo(pt.dx, pt.dy);
    }
  }
  canvas.drawPath(p, paint);
}

void _heart(Canvas canvas, Offset c, double s, Paint paint) {
  final p = Path()
    ..moveTo(c.dx, c.dy + s * 0.9)
    ..cubicTo(c.dx - s * 1.4, c.dy - s * 0.1, c.dx - s * 0.7, c.dy - s * 1.1, c.dx, c.dy - s * 0.4)
    ..cubicTo(c.dx + s * 0.7, c.dy - s * 1.1, c.dx + s * 1.4, c.dy - s * 0.1, c.dx, c.dy + s * 0.9)
    ..close();
  canvas.drawPath(p, paint);
}

/// Accessories, drawn in the creature's local space (already squashed).
void paintAccessory(Canvas canvas, String id, Offset c, double r, double furLen) {
  final top = c.dy - r * 0.9 - furLen * 0.15;
  final u = r / 92; // design unit: the shapes were drawn at r = 100
  Paint fill(Color col) => Paint()..color = col;
  final outline = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 2.2 * u
    ..strokeJoin = StrokeJoin.round
    ..color = const Color(0x33000000);

  switch (id) {
    case 'bow':
      canvas.save();
      final b = Offset(c.dx + 40 * u, top + 12 * u);
      canvas.translate(b.dx, b.dy);
      canvas.scale(1.35);
      canvas.translate(-b.dx, -b.dy);
      for (final side in const [-1, 1]) {
        final p = Path()
          ..moveTo(b.dx, b.dy)
          ..quadraticBezierTo(b.dx + side * 22 * u, b.dy - 22 * u, b.dx + side * 30 * u, b.dy - 2 * u)
          ..quadraticBezierTo(b.dx + side * 24 * u, b.dy + 18 * u, b.dx, b.dy)
          ..close();
        canvas.drawPath(p, fill(const Color(0xFFFF7FA8)));
        canvas.drawPath(p, outline);
      }
      canvas.drawCircle(b, 7 * u, fill(const Color(0xFFFF5C8E)));
      canvas.restore();
    case 'sprout':
      final base = Offset(c.dx, top + 8 * u);
      canvas.drawLine(base, base - Offset(0, 22 * u),
          Paint()
            ..color = const Color(0xFF5FAE62)
            ..strokeWidth = 4 * u
            ..strokeCap = StrokeCap.round);
      for (final side in const [-1, 1]) {
        final leaf = Path()
          ..moveTo(base.dx, base.dy - 20 * u)
          ..quadraticBezierTo(base.dx + side * 10 * u, base.dy - 40 * u, base.dx + side * 26 * u, base.dy - 30 * u)
          ..quadraticBezierTo(base.dx + side * 12 * u, base.dy - 16 * u, base.dx, base.dy - 20 * u)
          ..close();
        canvas.drawPath(leaf, fill(const Color(0xFF7ED17F)));
        canvas.drawPath(leaf, outline);
      }
    case 'flower':
      final f = Offset(c.dx - 40 * u, top + 16 * u);
      for (var i = 0; i < 6; i++) {
        final a = i * 2 * math.pi / 6 - math.pi / 2;
        canvas.drawCircle(f + Offset(math.cos(a), math.sin(a)) * 14 * u, 11 * u, fill(const Color(0xFFFFFFFF)));
      }
      canvas.drawCircle(f, 10 * u, fill(const Color(0xFFFFCF4D)));
    case 'beanie':
      final rect = Rect.fromCenter(center: Offset(c.dx, top + 26 * u), width: 120 * u, height: 92 * u);
      final dome = Path()..addArc(rect, math.pi, math.pi);
      canvas.drawPath(dome, fill(const Color(0xFF7FB7FF)));
      canvas.drawRRect(
          RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(c.dx, top + 26 * u), width: 124 * u, height: 18 * u),
              Radius.circular(9 * u)),
          fill(const Color(0xFF5E9BEB)));
      canvas.drawCircle(Offset(c.dx, top - 22 * u), 11 * u, fill(const Color(0xFFFFFFFF)));
    case 'starclip':
      _star(canvas, Offset(c.dx + 44 * u, top + 18 * u), 22 * u, fill(const Color(0xFFFFD84D)));
    case 'chef':
      // One silhouette (puffs + band) so the outline reads on pale fur.
      final base = RRect.fromRectAndRadius(
          Rect.fromCenter(center: Offset(c.dx, top + 18 * u), width: 70 * u, height: 22 * u), Radius.circular(7 * u));
      var hat = Path()..addRRect(base);
      for (final o in const [Offset(-24, -4), Offset(0, -16), Offset(24, -4)]) {
        hat = Path.combine(PathOperation.union, hat,
            Path()..addOval(Rect.fromCircle(center: Offset(c.dx + o.dx * u, top + o.dy * u), radius: 20 * u)));
      }
      canvas.drawPath(hat.shift(Offset(0, 3 * u)), fill(Colors.black.withValues(alpha: 0.10)));
      canvas.drawPath(hat, fill(Colors.white));
      canvas.drawPath(hat, outline);
      canvas.drawRRect(base, fill(const Color(0xFFF4EEF2)));
      canvas.drawRRect(base, outline);
      for (final dx in const [-14.0, 0.0, 14.0]) {
        canvas.drawLine(Offset(c.dx + dx * u, top + 12 * u), Offset(c.dx + dx * u, top + 24 * u), outline);
      }
    case 'headphones':
      final band = Rect.fromCenter(center: Offset(c.dx, c.dy - 8 * u), width: 2 * r + 16 * u, height: 2 * r + 28 * u);
      canvas.drawArc(band, math.pi * 1.08, math.pi * 0.84, false,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 9 * u
            ..strokeCap = StrokeCap.round
            ..color = const Color(0xFFB59CFF));
      for (final side in const [-1, 1]) {
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(center: Offset(c.dx + side * (r + 4 * u), c.dy - 8 * u), width: 24 * u, height: 40 * u),
            Radius.circular(11 * u),
          ),
          fill(const Color(0xFF8E72F0)),
        );
      }
    case 'party':
      final tip = Offset(c.dx - 6 * u, top - 46 * u);
      final hat = Path()
        ..moveTo(c.dx - 30 * u, top + 16 * u)
        ..lineTo(tip.dx, tip.dy)
        ..lineTo(c.dx + 26 * u, top + 16 * u)
        ..close();
      canvas.drawPath(hat, fill(const Color(0xFFFF9EC7)));
      canvas.save();
      canvas.clipPath(hat);
      for (var i = -3; i < 4; i++) {
        canvas.drawLine(Offset(c.dx + i * 18 * u - 30 * u, top + 20 * u), Offset(c.dx + i * 18 * u + 10 * u, top - 50 * u),
            Paint()
              ..color = const Color(0xFFFFE58A)
              ..strokeWidth = 6 * u);
      }
      canvas.restore();
      canvas.drawCircle(tip, 7 * u, fill(const Color(0xFF8ED8FF)));
    case 'glasses':
      final y = c.dy - r * 0.06;
      final p = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4 * u
        ..color = const Color(0xFF3A2A33);
      for (final side in const [-1, 1]) {
        canvas.drawCircle(Offset(c.dx + side * r * 0.34, y), r * 0.17, p);
        canvas.drawCircle(Offset(c.dx + side * r * 0.34, y), r * 0.17, Paint()..color = const Color(0x33FFFFFF));
      }
      canvas.drawLine(Offset(c.dx - r * 0.17, y), Offset(c.dx + r * 0.17, y), p);
    case 'crown':
      final base = top + 14 * u;
      final crown = Path()
        ..moveTo(c.dx - 34 * u, base)
        ..lineTo(c.dx - 38 * u, base - 30 * u)
        ..lineTo(c.dx - 18 * u, base - 14 * u)
        ..lineTo(c.dx, base - 38 * u)
        ..lineTo(c.dx + 18 * u, base - 14 * u)
        ..lineTo(c.dx + 38 * u, base - 30 * u)
        ..lineTo(c.dx + 34 * u, base)
        ..close();
      canvas.drawPath(crown, fill(const Color(0xFFFFCC3D)));
      canvas.drawPath(crown, outline);
      canvas.drawCircle(Offset(c.dx, base - 10 * u), 5 * u, fill(const Color(0xFFFF5C8A)));
    case 'witch':
      final brim = Rect.fromCenter(center: Offset(c.dx, top + 18 * u), width: 130 * u, height: 26 * u);
      canvas.drawOval(brim, fill(const Color(0xFF5B3F8F)));
      final cone = Path()
        ..moveTo(c.dx - 36 * u, top + 16 * u)
        ..quadraticBezierTo(c.dx - 10 * u, top - 40 * u, c.dx + 30 * u, top - 64 * u)
        ..quadraticBezierTo(c.dx + 10 * u, top - 20 * u, c.dx + 36 * u, top + 16 * u)
        ..close();
      canvas.drawPath(cone, fill(const Color(0xFF6D4BAA)));
      canvas.drawRect(Rect.fromLTWH(c.dx - 34 * u, top + 2 * u, 68 * u, 10 * u), fill(const Color(0xFFFF9E3D)));
    case 'santa':
      final hat = Path()
        ..moveTo(c.dx - 48 * u, top + 18 * u)
        ..quadraticBezierTo(c.dx - 10 * u, top - 50 * u, c.dx + 52 * u, top - 18 * u)
        ..lineTo(c.dx + 48 * u, top + 18 * u)
        ..close();
      canvas.drawPath(hat, fill(const Color(0xFFE5484D)));
      canvas.drawRRect(
          RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(c.dx, top + 18 * u), width: 112 * u, height: 22 * u),
              Radius.circular(11 * u)),
          fill(Colors.white));
      canvas.drawCircle(Offset(c.dx + 56 * u, top - 14 * u), 11 * u, fill(Colors.white));
  }
}

void _star(Canvas canvas, Offset c, double s, Paint paint) {
  final p = Path();
  for (var i = 0; i < 10; i++) {
    final rr = i.isEven ? s : s * 0.45;
    final a = -math.pi / 2 + i * math.pi / 5;
    final pt = c + Offset(math.cos(a), math.sin(a)) * rr;
    if (i == 0) {
      p.moveTo(pt.dx, pt.dy);
    } else {
      p.lineTo(pt.dx, pt.dy);
    }
  }
  p.close();
  canvas.drawPath(p, paint);
}

void _sparkle(Canvas canvas, Offset c, double s, Paint paint) {
  final p = Path()
    ..moveTo(c.dx, c.dy - s)
    ..quadraticBezierTo(c.dx, c.dy, c.dx + s, c.dy)
    ..quadraticBezierTo(c.dx, c.dy, c.dx, c.dy + s)
    ..quadraticBezierTo(c.dx, c.dy, c.dx - s, c.dy)
    ..quadraticBezierTo(c.dx, c.dy, c.dx, c.dy - s)
    ..close();
  canvas.drawPath(p, paint);
}

final Map<String, ui.Paragraph> _zCache = {};

void paintParticles(Canvas canvas, MofuSim sim) {
  for (final p in sim.particles) {
    final fade = p.t < 0.75 ? 1.0 : 1 - (p.t - 0.75) / 0.25;
    final grow = p.t < 0.15 ? p.t / 0.15 : 1.0;
    switch (p.kind) {
      case ParticleKind.heart:
        _heart(canvas, p.pos, p.size * 0.6 * grow, Paint()..color = const Color(0xFFFF6F98).withValues(alpha: fade));
      case ParticleKind.sparkle:
        _sparkle(canvas, p.pos, p.size * grow, Paint()..color = const Color(0xFFFFF4B8).withValues(alpha: fade));
      case ParticleKind.star:
        canvas.save();
        canvas.translate(p.pos.dx, p.pos.dy);
        canvas.rotate(p.age * p.spin);
        _star(canvas, Offset.zero, p.size * grow, Paint()..color = const Color(0xFFFFD447).withValues(alpha: fade));
        canvas.restore();
      case ParticleKind.crumb:
        canvas.drawCircle(p.pos, p.size, Paint()..color = const Color(0xFFE8C08A).withValues(alpha: fade));
      case ParticleKind.zzz:
        // Light on the night sky, lavender on the day room.
        final zColor = sim.night ? const Color(0xFFF1EBFF) : const Color(0xFF8C7CC9);
        final para = _zCache.putIfAbsent('z${p.size.round()}${sim.night}', () {
          final b = ui.ParagraphBuilder(ui.ParagraphStyle(fontSize: p.size, fontWeight: FontWeight.w800, fontFamily: 'Nunito'))
            ..pushStyle(ui.TextStyle(color: zColor, fontFamily: 'Nunito', fontWeight: FontWeight.w900))
            ..addText('z');
          return b.build()..layout(const ui.ParagraphConstraints(width: 40));
        });
        canvas.save();
        canvas.translate(p.pos.dx, p.pos.dy);
        final sc = 0.6 + p.t * 0.6;
        canvas.scale(sc, sc);
        canvas.saveLayer(null, Paint()..color = Color.fromRGBO(0, 0, 0, fade));
        canvas.drawParagraph(para, Offset.zero);
        canvas.restore();
        canvas.restore();
    }
  }
}
