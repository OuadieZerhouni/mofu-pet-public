/// Painters every species shares: accessories at the creature's anchors, and
/// the care overlays (wet fur, foam, mud, post-spa shine) clipped to its
/// silhouette so they follow any body shape.
library;

import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../creatures/creature.dart';

export '../creatures/creature.dart' show slotOf;
import '../ui/mofu_painter.dart' show paintAccessory;

/// Which slot an accessory id uses.
/// Draws [id] on [c] at its anchor. Mofu draws its own (inside its squash
/// transform), so callers skip this for Mofu.
void paintAccessoryOn(Canvas canvas, Creature c, String id) {
  if (id == 'none' || id.isEmpty) return;
  final slot = slotOf(id);
  final a = c.anchor(slot);
  final r = 92 * a.scale;
  canvas.save();
  canvas.translate(a.at.dx, a.at.dy);
  canvas.rotate(a.angle);
  canvas.translate(-a.at.dx, -a.at.dy);
  switch (slot) {
    case AccessorySlot.head:
      paintAccessory(canvas, id, a.at + Offset(0, r * 0.9), r, 0);
    case AccessorySlot.face:
      paintAccessory(canvas, id, a.at + Offset(0, r * 0.06), r, 0);
    case AccessorySlot.neck:
      _paintNeck(canvas, id, a.at, a.scale);
  }
  canvas.restore();
}

void _paintNeck(Canvas canvas, String id, Offset at, double u) {
  final outline = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 2.2 * u
    ..color = const Color(0x33000000);
  switch (id) {
    case 'scarf':
      final band = RRect.fromRectAndRadius(Rect.fromCenter(center: at, width: 96 * u, height: 22 * u), Radius.circular(11 * u));
      canvas.drawRRect(band, Paint()..color = const Color(0xFFE5484D));
      for (var i = -2; i <= 2; i++) {
        canvas.drawLine(at + Offset(i * 18 * u, -9 * u), at + Offset(i * 18 * u, 9 * u),
            Paint()
              ..color = const Color(0xFFFFFFFF)
              ..strokeWidth = 5 * u);
      }
      final tail = RRect.fromRectAndRadius(Rect.fromLTWH(at.dx + 18 * u, at.dy + 4 * u, 20 * u, 38 * u), Radius.circular(8 * u));
      canvas.drawRRect(tail, Paint()..color = const Color(0xFFD13B40));
      canvas.drawRRect(band, outline);
    case 'bandana':
      final p = Path()
        ..moveTo(at.dx - 46 * u, at.dy - 8 * u)
        ..lineTo(at.dx + 46 * u, at.dy - 8 * u)
        ..lineTo(at.dx, at.dy + 34 * u)
        ..close();
      canvas.drawPath(p, Paint()..color = const Color(0xFF3B82C4));
      for (final d in const [Offset(-18, 2), Offset(14, 0), Offset(0, 16)]) {
        canvas.drawCircle(at + d * u, 3.2 * u, Paint()..color = const Color(0xFFFFFFFF));
      }
      canvas.drawPath(p, outline);
    case 'bell':
      canvas.drawLine(at + Offset(-44 * u, -4 * u), at + Offset(44 * u, -4 * u),
          Paint()
            ..color = const Color(0xFFC2386A)
            ..strokeWidth = 8 * u
            ..strokeCap = StrokeCap.round);
      canvas.drawCircle(at + Offset(0, 10 * u), 12 * u, Paint()..color = const Color(0xFFF2B632));
      canvas.drawCircle(at + Offset(-4 * u, 6 * u), 3.5 * u, Paint()..color = const Color(0x99FFFFFF));
      canvas.drawCircle(at + Offset(0, 10 * u), 12 * u, outline);
    case 'bowtie':
      for (final side in const [-1, 1]) {
        final p = Path()
          ..moveTo(at.dx, at.dy)
          ..lineTo(at.dx + side * 26 * u, at.dy - 14 * u)
          ..lineTo(at.dx + side * 26 * u, at.dy + 14 * u)
          ..close();
        canvas.drawPath(p, Paint()..color = const Color(0xFF5A4E8E));
        canvas.drawPath(p, outline);
      }
      canvas.drawCircle(at, 7 * u, Paint()..color = const Color(0xFF433873));
  }
}

/// Wet fur, foam, mud and shine for one creature. [time] animates wobble.
void paintCare(Canvas canvas, Creature c, double time) {
  final care = c.care;
  if (care.wet <= 0.01 && care.foam.isEmpty && care.mud.isEmpty && care.shine <= 0.01) return;
  final r = c.radius;
  final centre = c.position;
  canvas.save();
  canvas.clipPath(c.silhouette);
  if (care.wet > 0.01) {
    canvas.drawRect(c.bounds, Paint()..color = const Color(0xFF2B5A78).withValues(alpha: 0.2 * care.wet));
    // Droplets trickle down the fur, each on its own slow loop, catching the light.
    final rng = math.Random(c.seed);
    final n = (16 * care.wet).round();
    for (var i = 0; i < n; i++) {
      final a = rng.nextDouble() * 2 * math.pi;
      final d = math.sqrt(rng.nextDouble()) * r * 0.95;
      final speed = 0.08 + rng.nextDouble() * 0.12;
      final slide = ((time * speed + rng.nextDouble()) % 1.0) * r * 0.5;
      final p = centre + Offset(math.cos(a) * d, math.sin(a) * d * 0.9 + slide - r * 0.2);
      final dw = r * (0.045 + rng.nextDouble() * 0.03);
      final drop = Rect.fromCenter(center: p, width: dw, height: dw * 1.45);
      canvas.drawOval(drop.shift(Offset(dw * 0.12, dw * 0.18)), Paint()..color = const Color(0xFF2B5A78).withValues(alpha: 0.18 * care.wet));
      canvas.drawOval(drop, Paint()..color = const Color(0xFFEAF6FF).withValues(alpha: 0.55 * care.wet));
      canvas.drawCircle(drop.topLeft + Offset(dw * 0.32, dw * 0.38), dw * 0.16, Paint()..color = Colors.white.withValues(alpha: 0.9 * care.wet));
    }
  }
  for (final m in care.mud) {
    final p = centre + m.at * r;
    final rad = m.radius * r;
    canvas.drawCircle(p, rad, Paint()..color = const Color(0xFF7A5134).withValues(alpha: 0.85));
    canvas.drawCircle(p + Offset(rad * 0.5, rad * 0.3), rad * 0.45, Paint()..color = const Color(0xFF6A452B).withValues(alpha: 0.85));
  }
  canvas.restore();

  // Foam sits on top of the outline, not clipped: it puffs past the body edge.
  if (care.foam.isNotEmpty) _paintFoam(canvas, care.foam, centre, r, time);

  if (care.shine > 0.01) {
    final rng = math.Random(c.seed + 9);
    for (var i = 0; i < 6; i++) {
      final a = rng.nextDouble() * 2 * math.pi;
      final p = centre + Offset(math.cos(a), math.sin(a)) * r * (0.75 + 0.25 * rng.nextDouble());
      final tw = 0.5 + 0.5 * math.sin(time * 4 + i * 1.7);
      _glint(canvas, p, r * 0.09 * tw, const Color(0xFFFFF6C8).withValues(alpha: care.shine));
    }
  }
}

/// Lather: a soft cohesive mass first (so blobs read as one foam, not
/// separate balls), then translucent rim-lit bubbles of mixed sizes on top,
/// each breathing on its own phase, with a glossy highlight.
void _paintFoam(Canvas canvas, List<FoamBlob> foam, Offset centre, double r, double time) {
  final base = Paint()
    ..color = const Color(0xFFF7FBFD)
    ..maskFilter = MaskFilter.blur(BlurStyle.normal, r * 0.035);
  final shade = Paint()
    ..color = const Color(0xFFB9D3E1).withValues(alpha: 0.5)
    ..maskFilter = MaskFilter.blur(BlurStyle.normal, r * 0.05);
  for (final f in foam) {
    final rad = f.radius * r * (1 + 0.05 * math.sin(time * 4 + f.phase * 7));
    canvas.drawCircle(centre + f.at * r + Offset(0, rad * 0.22), rad * 0.95, shade);
  }
  for (final f in foam) {
    final rad = f.radius * r * (1 + 0.05 * math.sin(time * 4 + f.phase * 7));
    canvas.drawCircle(centre + f.at * r, rad * 0.92, base);
  }
  final rim = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = math.max(0.8, r * 0.008);
  final body = Paint();
  final hi = Paint()..color = Colors.white.withValues(alpha: 0.95);
  for (final f in foam) {
    final p0 = centre + f.at * r;
    final rng = math.Random((f.phase * 100000).round());
    final count = 3 + rng.nextInt(3);
    for (var k = 0; k < count; k++) {
      final a = rng.nextDouble() * math.pi * 2;
      final d = rng.nextDouble() * f.radius * r * 0.6;
      final size = f.radius * r * (0.22 + rng.nextDouble() * 0.36) * (1 + 0.08 * math.sin(time * (3 + k) + f.phase * 11 + k));
      final p = p0 + Offset(math.cos(a) * d, math.sin(a) * d * 0.8);
      final rect = Rect.fromCircle(center: p, radius: size);
      // Mostly clear with a pale fill, an iridescent rim and a bright spec.
      body.shader = RadialGradient(
        center: const Alignment(-0.25, -0.3),
        colors: [Colors.white.withValues(alpha: 0.75), const Color(0xFFEAF4FA).withValues(alpha: 0.55), const Color(0xFFD7E9F3).withValues(alpha: 0.4)],
        stops: const [0, 0.7, 1],
      ).createShader(rect);
      canvas.drawCircle(p, size, body);
      rim.shader = SweepGradient(
        transform: GradientRotation(time * 0.6 + f.phase * 5),
        colors: const [Color(0x99F7B9D9), Color(0x99B9DCF7), Color(0x99D5F7C9), Color(0x99F7E3B9), Color(0x99F7B9D9)],
      ).createShader(rect);
      canvas.drawCircle(p, size, rim);
      canvas.drawCircle(p + Offset(-size * 0.38, -size * 0.4), size * 0.2, hi);
    }
  }
}

void _glint(Canvas canvas, Offset c, double s, Color color) {
  if (s <= 0.5) return;
  final p = Path()
    ..moveTo(c.dx, c.dy - s)
    ..quadraticBezierTo(c.dx, c.dy, c.dx + s, c.dy)
    ..quadraticBezierTo(c.dx, c.dy, c.dx, c.dy + s)
    ..quadraticBezierTo(c.dx, c.dy, c.dx - s, c.dy)
    ..quadraticBezierTo(c.dx, c.dy, c.dx, c.dy - s)
    ..close();
  canvas.drawPath(p, Paint()..color = color);
}
