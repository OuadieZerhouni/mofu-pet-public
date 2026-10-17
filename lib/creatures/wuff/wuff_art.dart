/// Paints the Wuff puppy for a [CreatureLook.variant] coat id.
///
/// Everything is procedural, in the puppy's local frame under
/// `WuffCreature.poseMatrix`: soft radial shading on head and body, a subtle
/// rim light, a contact shadow on the floor, glossy eyes and blush.
/// Accessories are NOT painted here (the shared accessory painter draws them
/// at `Creature.anchor`), and neither are foam or wet fur (the room paints
/// those with `Creature.silhouette`).
library;

import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/painting.dart' show Alignment, LinearGradient, RadialGradient;

import '../creature.dart';
import 'wuff_catalog.dart';
import 'wuff_creature.dart';

const _ink = Color(0xFF2B1D14);
const _iris = Color(0xFF7A5238);
const _tongueC = Color(0xFFFF7A8A);
const _tongueDark = Color(0xFFE25D70);
const _mouthIn = Color(0xFF7A2E32);
const _blushC = Color(0xFFFF8FA3);
const _pad = Color(0xFFFFA9B8);
const _white = Color(0xFFFFFFFF);

Color _a(Color c, double alpha) => c.withValues(alpha: alpha.clamp(0.0, 1.0));

class WuffArt extends CreatureArt {
  const WuffArt();

  @override
  void paint(Canvas canvas, Creature c, CreatureLook look, {bool shadow = true}) {
    if (c is! WuffCreature) return;
    final w = c;
    final r = w.radius;
    if (r <= 0 || !r.isFinite) return;
    final coat = wuffCoat(look.variant);

    if (shadow) _shadow(canvas, w);

    canvas.save();
    canvas.transform(w.poseMatrix);
    final body = w.body;
    final head = w.head;
    _tail(canvas, w, coat, r);
    _body(canvas, w, coat, body, r);
    _neckShade(canvas, head, r);
    _paws(canvas, w, coat, body, r, front: false);

    // Head group, rotated by the tilt around the neck.
    canvas.save();
    final neck = head + Offset(0, r * 0.8);
    canvas.translate(neck.dx, neck.dy);
    canvas.rotate(w.headTilt);
    canvas.translate(-neck.dx, -neck.dy);
    _head(canvas, w, coat, head, r);
    _face(canvas, w, coat, head, r);
    _ears(canvas, w, coat, r);
    canvas.restore();

    _paws(canvas, w, coat, body, r, front: true);
    canvas.restore();

    _particles(canvas, w);
  }
}

// ── shadow ────────────────────────────────────────────────────────────────
void _shadow(Canvas canvas, WuffCreature w) {
  final r = w.radius;
  final lift = (w.jump / (r * 2)).clamp(0.0, 1.0);
  final k = 1 - lift * 0.35;
  final alpha = 1 - lift * 0.5;
  canvas.save();
  canvas.translate(w.cx, w.floorY + r * 0.05);
  canvas.scale(1, 0.14);
  // Wide soft falloff…
  final wide = r * 1.25 * k;
  canvas.drawCircle(
    Offset.zero,
    wide,
    Paint()
      ..shader = RadialGradient(
        colors: [_a(const Color(0xFF000000), 0.20 * alpha), _a(const Color(0xFF000000), 0.09 * alpha), _a(const Color(0xFF000000), 0)],
        stops: const [0.0, 0.55, 1.0],
      ).createShader(Rect.fromCircle(center: Offset.zero, radius: wide)),
  );
  // …and a tighter, darker contact patch under the paws.
  final tight = r * 0.82 * k;
  canvas.drawCircle(
    Offset.zero,
    tight,
    Paint()
      ..shader = RadialGradient(
        colors: [_a(const Color(0xFF000000), 0.22 * alpha), _a(const Color(0xFF000000), 0)],
      ).createShader(Rect.fromCircle(center: Offset.zero, radius: tight)),
  );
  canvas.restore();
}

// ── shared bits ───────────────────────────────────────────────────────────
Paint _rim(WuffCoat coat, double r) => Paint()
  ..color = _a(Color.lerp(coat.shade, _ink, 0.25)!, 0.55)
  ..style = PaintingStyle.stroke
  ..strokeWidth = r * 0.035;

/// A soft light along the upper-left edge, drawn inside [clip] only.
void _rimLight(Canvas canvas, Path clip, Rect box, double r, {double strength = 0.5}) {
  canvas.save();
  canvas.clipPath(clip);
  canvas.drawPath(
    clip,
    Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = r * 0.16
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [_a(_white, strength), _a(_white, strength * 0.15), _a(_white, 0)],
        stops: const [0.0, 0.38, 0.7],
      ).createShader(box),
  );
  canvas.restore();
}

// ── tail ──────────────────────────────────────────────────────────────────
void _tail(Canvas canvas, WuffCreature w, WuffCoat coat, double r) {
  final root = w.tailRoot, mid = w.tailMid, tip = w.tailTip;
  final path = Path()
    ..moveTo(root.dx, root.dy)
    ..quadraticBezierTo(mid.dx, mid.dy, tip.dx, tip.dy);
  canvas.drawPath(
    path,
    Paint()
      ..color = coat.shade
      ..style = PaintingStyle.stroke
      ..strokeWidth = r * 0.25
      ..strokeCap = StrokeCap.round,
  );
  canvas.drawPath(
    path,
    Paint()
      ..color = coat.base
      ..style = PaintingStyle.stroke
      ..strokeWidth = r * 0.17
      ..strokeCap = StrokeCap.round,
  );
  // Sunlit streak along the top of the tail.
  canvas.drawPath(
    path,
    Paint()
      ..color = _a(coat.light, 0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = r * 0.06
      ..strokeCap = StrokeCap.round,
  );
  final tipColor = coat.pattern == WuffPattern.saddle || coat.pattern == WuffPattern.blaze ? coat.muzzle : coat.light;
  canvas.drawCircle(tip, r * 0.105, Paint()..color = tipColor);
  canvas.drawCircle(tip, r * 0.105, _rim(coat, r)..strokeWidth = r * 0.02);
}

// ── body ──────────────────────────────────────────────────────────────────
void _body(Canvas canvas, WuffCreature w, WuffCoat coat, Offset body, double r) {
  final breath = w.breath;
  final rect = Rect.fromCenter(center: body, width: r * 1.56 * breath, height: r * 1.36);
  // Haunches peeking out at the sides.
  for (final side in const [-1, 1]) {
    final hr = Rect.fromCenter(center: body + Offset(side * r * 0.56, r * 0.34), width: r * 0.62, height: r * 0.72);
    canvas.drawOval(
      hr,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.3, -0.5),
          radius: 1.0,
          colors: [Color.lerp(coat.shade, coat.base, 0.45)!, coat.shade],
        ).createShader(hr),
    );
    canvas.drawOval(hr, _rim(coat, r)..strokeWidth = r * 0.025);
  }
  final bodyPath = Path()..addOval(rect);
  canvas.drawOval(
    rect,
    Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.3, -0.6),
        radius: 1.05,
        colors: [coat.light, coat.base, Color.lerp(coat.base, coat.shade, 0.8)!],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(rect),
  );
  // Chest / belly: feathered so it melts into the fur.
  final chest = Rect.fromCenter(center: body + Offset(0, r * 0.12), width: r * 0.9, height: r * 1.02);
  canvas.save();
  canvas.clipPath(bodyPath);
  canvas.drawOval(
    chest,
    Paint()
      ..shader = RadialGradient(
        colors: [coat.muzzle, coat.muzzle, _a(coat.muzzle, 0.0)],
        stops: const [0.0, 0.78, 1.0],
      ).createShader(chest.inflate(r * 0.03)),
  );
  switch (coat.pattern) {
    case WuffPattern.spots:
      final rng = math.Random(41);
      for (var i = 0; i < 7; i++) {
        final p = body + Offset((rng.nextDouble() - 0.5) * r * 1.3, (rng.nextDouble() - 0.5) * r * 1.1);
        canvas.drawOval(
          Rect.fromCenter(center: p, width: r * (0.12 + rng.nextDouble() * 0.1), height: r * (0.1 + rng.nextDouble() * 0.08)),
          Paint()..color = coat.mark,
        );
      }
    case WuffPattern.saddle:
      for (final side in const [-1, 1]) {
        canvas.drawOval(
          Rect.fromCenter(center: body + Offset(side * r * 0.5, -r * 0.2), width: r * 0.9, height: r * 0.9),
          Paint()..color = coat.mark,
        );
      }
      canvas.drawOval(chest, Paint()..color = coat.muzzle);
    default:
      break;
  }
  canvas.restore();
  canvas.drawOval(rect, _rim(coat, r));
  _rimLight(canvas, bodyPath, rect, r, strength: 0.38);
}

/// Soft shadow the head casts on the shoulders.
void _neckShade(Canvas canvas, Offset head, double r) {
  final c = head + Offset(0, r * 0.98);
  final rect = Rect.fromCenter(center: c, width: r * 1.5, height: r * 0.5);
  canvas.drawOval(
    rect,
    Paint()
      ..shader = RadialGradient(colors: [_a(const Color(0xFF000000), 0.16), _a(const Color(0xFF000000), 0)])
          .createShader(Rect.fromCircle(center: c, radius: r * 0.75)),
  );
}

// ── paws ──────────────────────────────────────────────────────────────────
void _paws(Canvas canvas, WuffCreature w, WuffCoat coat, Offset body, double r, {required bool front}) {
  final pawColor = coat.pattern == WuffPattern.blaze || coat.pattern == WuffPattern.mask || coat.pattern == WuffPattern.saddle
      ? coat.muzzle
      : coat.base;
  final y = body.dy + r * 0.64;
  for (final side in const [-1, 1]) {
    final raised = side > 0 ? w.pawR.value : 0.0;
    // Raised paws are drawn in front of the head, resting ones behind it.
    if ((raised > 0.05) != front) continue;
    final lift = side < 0 ? w.thump * r * 0.12 : 0.0;
    if (raised > 0.05) {
      // Foreleg lifted toward the viewer's right, paw pad showing.
      final shoulder = body + Offset(r * 0.32, -r * 0.2);
      final pawC = w.raisedPawCentre;
      canvas.drawLine(
        shoulder,
        pawC,
        Paint()
          ..color = coat.shade
          ..strokeWidth = r * 0.36
          ..strokeCap = StrokeCap.round,
      );
      canvas.drawLine(
        shoulder,
        pawC,
        Paint()
          ..color = coat.base
          ..strokeWidth = r * 0.3
          ..strokeCap = StrokeCap.round,
      );
      final pr = Rect.fromCircle(center: pawC, radius: r * 0.21);
      canvas.drawCircle(
        pawC,
        r * 0.21,
        Paint()
          ..shader = RadialGradient(
            center: const Alignment(-0.3, -0.4),
            colors: [Color.lerp(pawColor, _white, 0.25)!, pawColor],
          ).createShader(pr),
      );
      canvas.drawCircle(pawC + Offset(0, r * 0.04), r * 0.1, Paint()..color = _pad);
      for (final dx in const [-0.11, 0.0, 0.11]) {
        canvas.drawCircle(pawC + Offset(dx * r, -r * 0.1), r * 0.045, Paint()..color = _pad);
      }
      continue;
    }
    final c = Offset(body.dx + side * r * 0.36, y - lift);
    final pr = Rect.fromCenter(center: c, width: r * 0.56, height: r * 0.34);
    canvas.drawOval(
      pr,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color.lerp(pawColor, _white, 0.2)!, pawColor, Color.lerp(pawColor, coat.shade, 0.35)!],
          stops: const [0.0, 0.55, 1.0],
        ).createShader(pr),
    );
    canvas.drawOval(pr, _rim(coat, r)..strokeWidth = r * 0.02);
    final toe = Paint()
      ..color = coat.shade
      ..style = PaintingStyle.stroke
      ..strokeWidth = r * 0.03
      ..strokeCap = StrokeCap.round;
    for (final dx in const [-0.1, 0.1]) {
      canvas.drawLine(c + Offset(dx * r, r * 0.04), c + Offset(dx * r, r * 0.13), toe);
    }
  }
}

// ── head ──────────────────────────────────────────────────────────────────
/// Head + cheek tufts as one outline, built around the origin. Path.combine
/// is too slow to run every frame, and the shape only changes with the size.
final Map<double, Path> _outlineCache = {};
Path _headOutline(double r) {
  final hit = _outlineCache[r];
  if (hit != null) return hit;
  if (_outlineCache.length > 8) _outlineCache.clear();
  var outline = Path()..addOval(Rect.fromCenter(center: Offset.zero, width: r * 2.12, height: r * 1.94));
  for (final side in const [-1, 1]) {
    outline = Path.combine(
      PathOperation.union,
      outline,
      Path()..addOval(Rect.fromCircle(center: Offset(side * r * 0.88, r * 0.32), radius: r * 0.28)),
    );
  }
  return _outlineCache[r] = outline;
}

void _head(Canvas canvas, WuffCreature w, WuffCoat coat, Offset h, double r) {
  final rect = Rect.fromCenter(center: h, width: r * 2.12, height: r * 1.94);
  final fur = Paint()
    ..shader = RadialGradient(
      center: const Alignment(-0.25, -0.5),
      radius: 0.98,
      colors: [coat.light, coat.base, coat.base, Color.lerp(coat.base, coat.shade, 0.6)!],
      stops: const [0.0, 0.48, 0.78, 1.0],
    ).createShader(rect);
  final outline = _headOutline(r).shift(h);
  // Cheek tufts and skull share one shader, so they read as one head.
  canvas.drawPath(outline, fur);
  canvas.drawPath(outline, _rim(coat, r));

  canvas.save();
  canvas.clipPath(Path()..addOval(rect));
  switch (coat.pattern) {
    case WuffPattern.eyePatch:
      canvas.drawOval(
        Rect.fromCenter(center: w.eye(-1) + Offset(-r * 0.04, -r * 0.02), width: r * 0.78, height: r * 0.7),
        Paint()..color = coat.mark,
      );
    case WuffPattern.blaze:
      final blaze = Path()
        ..moveTo(h.dx - r * 0.1, h.dy - r * 1.0)
        ..quadraticBezierTo(h.dx - r * 0.16, h.dy - r * 0.3, h.dx - r * 0.42, h.dy + r * 0.2)
        ..lineTo(h.dx + r * 0.42, h.dy + r * 0.2)
        ..quadraticBezierTo(h.dx + r * 0.16, h.dy - r * 0.3, h.dx + r * 0.1, h.dy - r * 1.0)
        ..close();
      canvas.drawPath(blaze, Paint()..color = coat.mark);
      if (coat.id == 'blackTan') {
        // Tan eyebrow dots.
        for (final side in const [-1, 1]) {
          canvas.drawCircle(w.eye(side) + Offset(0, -r * 0.3), r * 0.09, Paint()..color = coat.mark);
        }
      }
    case WuffPattern.mask:
      final mask = Path()
        ..moveTo(h.dx, h.dy - r * 0.55)
        ..cubicTo(h.dx - r * 0.25, h.dy - r * 0.45, h.dx - r * 0.2, h.dy - r * 0.05, h.dx - r * 0.75, h.dy + r * 0.05)
        ..quadraticBezierTo(h.dx - r * 1.1, h.dy + r * 0.9, h.dx, h.dy + r * 1.0)
        ..quadraticBezierTo(h.dx + r * 1.1, h.dy + r * 0.9, h.dx + r * 0.75, h.dy + r * 0.05)
        ..cubicTo(h.dx + r * 0.2, h.dy - r * 0.05, h.dx + r * 0.25, h.dy - r * 0.45, h.dx, h.dy - r * 0.55)
        ..close();
      canvas.drawPath(mask, Paint()..color = coat.mark);
      for (final side in const [-1, 1]) {
        canvas.drawCircle(w.eye(side) + Offset(side * r * 0.02, -r * 0.3), r * 0.1, Paint()..color = coat.mark);
      }
    case WuffPattern.spots:
      final rng = math.Random(17);
      for (var i = 0; i < 4; i++) {
        final p = h + Offset((rng.nextDouble() - 0.5) * r * 1.6, -r * 0.4 - rng.nextDouble() * r * 0.5);
        canvas.drawCircle(p, r * (0.07 + rng.nextDouble() * 0.06), Paint()..color = coat.mark);
      }
    default:
      break;
  }
  canvas.restore();
  _rimLight(canvas, outline, rect, r, strength: 0.5);
}

// ── face ──────────────────────────────────────────────────────────────────
void _face(Canvas canvas, WuffCreature w, WuffCoat coat, Offset h, double r) {
  final e = w.expr;
  // Muzzle: feathered edge so it sits in the fur.
  final mz = Rect.fromCenter(center: h + Offset(0, r * 0.36), width: r * 1.08, height: r * 0.8);
  canvas.drawOval(
    mz,
    Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.1, -0.3),
        colors: [coat.muzzle, coat.muzzle, Color.lerp(coat.muzzle, coat.shade, 0.22)!],
        stops: const [0.0, 0.7, 1.0],
      ).createShader(mz),
  );

  // Blush: soft radial puffs.
  final blushA = 0.38 + 0.4 * w.blush + (e == WuffExpr.love || e == WuffExpr.bliss ? 0.25 : 0);
  for (final side in const [-1, 1]) {
    final c = h + Offset(side * r * 0.64, r * 0.27);
    final box = Rect.fromCenter(center: c, width: r * 0.42, height: r * 0.26);
    canvas.drawOval(
      box,
      Paint()
        ..shader = RadialGradient(colors: [_a(_blushC, blushA.clamp(0.0, 0.9)), _a(_blushC, 0)])
            .createShader(Rect.fromCenter(center: c, width: r * 0.42, height: r * 0.42)),
    );
  }

  _eyes(canvas, w, h, r);
  _brows(canvas, w, coat, r);

  // Nose (wiggles before a sneeze).
  final wig = math.sin(w.time * 42) * w.noseWiggle * r * 0.025;
  final n = w.nose + Offset(wig, 0);
  final nosePath = Path()
    ..moveTo(n.dx - r * 0.19, n.dy - r * 0.05)
    ..quadraticBezierTo(n.dx, n.dy - r * 0.14, n.dx + r * 0.19, n.dy - r * 0.05)
    ..quadraticBezierTo(n.dx + r * 0.17, n.dy + r * 0.13, n.dx, n.dy + r * 0.16)
    ..quadraticBezierTo(n.dx - r * 0.17, n.dy + r * 0.13, n.dx - r * 0.19, n.dy - r * 0.05)
    ..close();
  canvas.drawPath(
    nosePath,
    Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.3, -0.5),
        colors: [const Color(0xFF5A4332), _ink],
      ).createShader(Rect.fromCenter(center: n, width: r * 0.4, height: r * 0.32)),
  );
  canvas.drawOval(
    Rect.fromCenter(center: n + Offset(-r * 0.06, -r * 0.035), width: r * 0.13, height: r * 0.065),
    Paint()..color = _a(_white, 0.7),
  );

  _mouth(canvas, w, h, r);
}

void _eyes(Canvas canvas, WuffCreature w, Offset h, double r) {
  final e = w.expr;
  final line = Paint()
    ..color = _ink
    ..style = PaintingStyle.stroke
    ..strokeWidth = r * 0.07
    ..strokeCap = StrokeCap.round;
  for (final side in const [-1, 1]) {
    final c = w.eye(side);
    final ew = r * 0.19;
    final winkThis = (e == WuffExpr.winkL && side < 0) || (e == WuffExpr.winkR && side > 0);
    if (e == WuffExpr.asleep || e == WuffExpr.howl) {
      // Peaceful closed curves.
      canvas.drawArc(Rect.fromCenter(center: c + Offset(0, -r * 0.02), width: ew * 2, height: ew * 1.2), 0.15, math.pi - 0.3, false, line);
      continue;
    }
    if (e == WuffExpr.happy || e == WuffExpr.excited || e == WuffExpr.proud || e == WuffExpr.love || winkThis || e == WuffExpr.eating) {
      // ^ happy arcs.
      canvas.drawArc(Rect.fromCenter(center: c + Offset(0, r * 0.06), width: ew * 2, height: ew * 1.6), math.pi + 0.2, math.pi - 0.4, false, line);
      if (e == WuffExpr.love) {
        _heart(canvas, c + Offset(side * r * 0.02, -r * 0.24), r * 0.13, const Color(0xFFFF5A78));
      }
      continue;
    }
    if (e == WuffExpr.bliss) {
      // Melting: low, wide, relaxed lids (the happy squint of grooming).
      canvas.drawArc(Rect.fromCenter(center: c + Offset(0, r * 0.04), width: ew * 2.1, height: ew * 1.0), 0.1, math.pi - 0.2, false, line);
      continue;
    }
    if (e == WuffExpr.dizzy) {
      final p = Path();
      for (var i = 0; i < 36; i++) {
        final a = i / 36 * 4 * math.pi + w.time * 8 * side;
        final rad = ew * (0.15 + 0.85 * i / 36);
        final pt = c + Offset(math.cos(a) * rad, math.sin(a) * rad);
        if (i == 0) {
          p.moveTo(pt.dx, pt.dy);
        } else {
          p.lineTo(pt.dx, pt.dy);
        }
      }
      canvas.drawPath(p, Paint()
        ..color = _ink
        ..style = PaintingStyle.stroke
        ..strokeWidth = r * 0.045
        ..strokeCap = StrokeCap.round);
      continue;
    }
    if (e == WuffExpr.playDead) {
      final d = ew * 0.7;
      canvas.drawLine(c + Offset(-d, -d), c + Offset(d, d), line);
      canvas.drawLine(c + Offset(-d, d), c + Offset(d, -d), line);
      continue;
    }
    if (e == WuffExpr.sneeze || e == WuffExpr.nope) {
      // > <  squeezed shut.
      final d = ew * 0.75;
      canvas.drawLine(c + Offset(-d * side, -d * 0.7), c + Offset(d * side * 0.2, 0), line);
      canvas.drawLine(c + Offset(d * side * 0.2, 0), c + Offset(-d * side, d * 0.7), line);
      continue;
    }
    // Open eyes. Big round ones for puppy eyes and surprise; half-lidded when sleepy.
    final big = e == WuffExpr.puppyEyes ? 1.22 : (e == WuffExpr.startled ? 1.3 : 1.0);
    final rx = ew * 1.02 * big, ry = ew * 1.18 * big;
    final lid = e == WuffExpr.sleepy ? 0.5 : w.blink;
    final eyeRect = Rect.fromCenter(center: c, width: rx * 2, height: ry * 2 * (1 - lid * 0.92));
    if (eyeRect.height < r * 0.04) {
      canvas.drawLine(c + Offset(-rx, 0), c + Offset(rx, 0), line);
      continue;
    }
    final look = Offset(w.lookX * rx * 0.28, w.lookY * ry * 0.22);
    final eyePath = Path()..addOval(eyeRect);
    canvas.drawOval(eyeRect, Paint()..color = _ink);
    canvas.save();
    canvas.clipPath(eyePath);
    // Warm glow low in the eye, so it reads as wet and deep.
    final glowC = c + look + Offset(0, ry * 0.42);
    canvas.drawCircle(
      glowC,
      rx * 1.05,
      Paint()
        ..shader = RadialGradient(colors: [_a(_iris, 0.85), _a(_iris, 0)]).createShader(Rect.fromCircle(center: glowC, radius: rx * 1.05)),
    );
    // Glossy highlights.
    canvas.drawCircle(c + look + Offset(rx * 0.32, -ry * 0.38), rx * (big > 1.1 ? 0.42 : 0.36), Paint()..color = _white);
    canvas.drawCircle(c + look + Offset(-rx * 0.34, ry * 0.36), rx * 0.17, Paint()..color = _a(_white, 0.8));
    canvas.drawCircle(c + look + Offset(rx * 0.05, ry * 0.12), rx * 0.07, Paint()..color = _a(_white, 0.6));
    canvas.restore();
  }
}

void _brows(Canvas canvas, WuffCreature w, WuffCoat coat, double r) {
  final e = w.expr;
  final browColor = Color.lerp(coat.shade, _ink, coat.base.computeLuminance() < 0.15 ? 0.0 : 0.35)!;
  final p = Paint()
    ..color = coat.base.computeLuminance() < 0.12 ? coat.light : browColor
    ..style = PaintingStyle.stroke
    ..strokeWidth = r * 0.07
    ..strokeCap = StrokeCap.round;
  for (final side in const [-1, 1]) {
    final c = w.eye(side) + Offset(0, -r * 0.34);
    double inner = 0, outer = 0;
    switch (e) {
      case WuffExpr.puppyEyes:
        inner = -0.12;
        outer = 0.04;
      case WuffExpr.confused:
        inner = side > 0 ? -0.14 : 0.0;
        outer = side > 0 ? -0.14 : 0.0;
      case WuffExpr.growl:
      case WuffExpr.nope:
        inner = 0.08;
        outer = -0.04;
      case WuffExpr.excited:
      case WuffExpr.proud:
        inner = -0.06;
        outer = -0.06;
      case WuffExpr.startled:
        inner = -0.12;
        outer = -0.12;
      default:
        break;
    }
    canvas.drawLine(c + Offset(-side * r * 0.14, inner * r), c + Offset(side * r * 0.14, outer * r), p);
  }
}

void _mouth(Canvas canvas, WuffCreature w, Offset h, double r) {
  final m = h + Offset(0, r * 0.46);
  final line = Paint()
    ..color = _ink
    ..style = PaintingStyle.stroke
    ..strokeWidth = r * 0.055
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round;
  // Philtrum from nose down.
  canvas.drawLine(w.nose + Offset(0, r * 0.14), m, line);
  final open = math.max(w.mouthOpen, w.expr == WuffExpr.startled ? 0.45 : 0.0).clamp(0.0, 1.0);
  if (open > 0.06) {
    final mouthRect = Rect.fromCenter(center: m + Offset(0, r * 0.12 * open), width: r * (0.34 + 0.12 * open), height: r * 0.36 * open);
    canvas.drawOval(mouthRect, Paint()..color = _mouthIn);
    canvas.save();
    canvas.clipPath(Path()..addOval(mouthRect));
    canvas.drawOval(
      Rect.fromCenter(center: mouthRect.bottomCenter + Offset(0, -r * 0.02), width: mouthRect.width * 0.8, height: mouthRect.height * 0.7),
      Paint()..color = _tongueC,
    );
    canvas.restore();
    canvas.drawOval(
      mouthRect,
      Paint()
        ..color = _ink
        ..style = PaintingStyle.stroke
        ..strokeWidth = r * 0.04,
    );
  } else {
    // The classic "w".
    final wp = Path()
      ..moveTo(m.dx - r * 0.22, m.dy - r * 0.02)
      ..quadraticBezierTo(m.dx - r * 0.11, m.dy + r * 0.12, m.dx, m.dy)
      ..quadraticBezierTo(m.dx + r * 0.11, m.dy + r * 0.12, m.dx + r * 0.22, m.dy - r * 0.02);
    canvas.drawPath(wp, line);
  }
  // Panting tongue / blep.
  final t = math.max(w.tongue * (open > 0.06 ? 0 : 1), w.blep);
  if (t > 0.04) {
    final len = r * (w.blep > w.tongue ? 0.14 : 0.26) * t;
    final pant = math.sin(w.time * 14) * r * 0.012 * w.tongue;
    final tr = Rect.fromLTWH(m.dx - r * 0.1, m.dy + r * 0.02 + pant, r * 0.2, len + r * 0.06);
    final rr = RRect.fromRectAndCorners(tr, bottomLeft: Radius.circular(r * 0.1), bottomRight: Radius.circular(r * 0.1));
    canvas.drawRRect(
      rr,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [_tongueDark, _tongueC],
        ).createShader(tr),
    );
    canvas.drawLine(
      Offset(m.dx, tr.top + r * 0.03),
      Offset(m.dx, tr.bottom - r * 0.05),
      Paint()
        ..color = _tongueDark
        ..strokeWidth = r * 0.02
        ..strokeCap = StrokeCap.round,
    );
  }
}

// ── ears ──────────────────────────────────────────────────────────────────
void _ears(Canvas canvas, WuffCreature w, WuffCoat coat, double r) {
  final len = w.earLength;
  for (final side in const [-1, 1]) {
    final pivot = w.earPivot(side);
    // Local frame: origin at the root, +y down the ear, +x outward.
    canvas.save();
    canvas.translate(pivot.dx, pivot.dy);
    canvas.scale(side.toDouble(), 1);
    canvas.rotate(-w.earAngle(side));
    // A floppy teardrop: narrow root, fat rounded lobe.
    final p = Path()
      ..moveTo(-r * 0.2, -r * 0.04)
      ..quadraticBezierTo(r * 0.02, -r * 0.2, r * 0.24, -r * 0.06)
      ..cubicTo(r * 0.46, len * 0.24, r * 0.44, len * 0.78, r * 0.16, len * 1.0)
      ..quadraticBezierTo(-r * 0.02, len * 1.1, -r * 0.18, len * 0.92)
      ..cubicTo(-r * 0.3, len * 0.7, -r * 0.24, len * 0.3, -r * 0.2, -r * 0.04)
      ..close();
    final box = Rect.fromLTRB(-r * 0.3, -r * 0.2, r * 0.46, len * 1.1);
    canvas.drawPath(
      p,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color.lerp(coat.ear, coat.light, 0.2)!, coat.ear, Color.lerp(coat.ear, _ink, 0.22)!],
          stops: const [0.0, 0.5, 1.0],
        ).createShader(box),
    );
    // Inner fold shadow so the ear reads as a flap lying on the cheek.
    canvas.save();
    canvas.clipPath(p);
    canvas.drawPath(
      Path()
        ..moveTo(-r * 0.2, len * 0.12)
        ..quadraticBezierTo(-r * 0.04, len * 0.55, -r * 0.1, len * 0.98),
      Paint()
        ..color = _a(const Color(0xFF000000), 0.12)
        ..style = PaintingStyle.stroke
        ..strokeWidth = r * 0.12
        ..strokeCap = StrokeCap.round,
    );
    canvas.restore();
    // Soft sheen down the outer edge.
    canvas.drawPath(
      Path()
        ..moveTo(r * 0.16, len * 0.08)
        ..quadraticBezierTo(r * 0.32, len * 0.45, r * 0.18, len * 0.82),
      Paint()
        ..color = _a(_white, 0.2)
        ..style = PaintingStyle.stroke
        ..strokeWidth = r * 0.07
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawPath(
      p,
      Paint()
        ..color = _a(const Color(0xFF000000), 0.14)
        ..style = PaintingStyle.stroke
        ..strokeWidth = r * 0.028,
    );
    canvas.restore();
  }
}

// ── particles (room coordinates) ──────────────────────────────────────────
void _particles(Canvas canvas, WuffCreature w) {
  for (final p in w.particles) {
    final a = (1 - p.t).clamp(0.0, 1.0);
    switch (p.kind) {
      case WuffParticleKind.heart:
        _heart(canvas, p.pos, p.size * (0.7 + 0.3 * a), _a(const Color(0xFFFF6F86), a));
      case WuffParticleKind.sparkle:
        _sparkle(canvas, p.pos, p.size, _a(const Color(0xFFFFD15C), a));
      case WuffParticleKind.star:
        _star(canvas, p.pos, p.size, _a(const Color(0xFFFFC94D), a));
      case WuffParticleKind.crumb:
        canvas.drawCircle(p.pos, p.size, Paint()..color = _a(const Color(0xFFD9A066), a));
      case WuffParticleKind.zzz:
        _zText(canvas, p.pos, p.size, a);
      case WuffParticleKind.question:
        _question(canvas, p.pos, p.size, a);
      case WuffParticleKind.note:
        _note(canvas, p.pos, p.size, a);
      case WuffParticleKind.drop:
        _drop(canvas, p.pos, p.size, a);
    }
  }
}

void _drop(Canvas canvas, Offset c, double s, double a) {
  final path = Path()
    ..moveTo(c.dx, c.dy - s * 1.5)
    ..quadraticBezierTo(c.dx + s, c.dy, c.dx, c.dy + s * 0.9)
    ..quadraticBezierTo(c.dx - s, c.dy, c.dx, c.dy - s * 1.5)
    ..close();
  canvas.drawPath(path, Paint()..color = _a(const Color(0xFF9FD3F5), 0.9 * a));
  canvas.drawCircle(c + Offset(-s * 0.3, -s * 0.1), s * 0.22, Paint()..color = _a(_white, 0.8 * a));
}

void _heart(Canvas canvas, Offset c, double s, Color color) {
  final p = Path()
    ..moveTo(c.dx, c.dy + s * 0.45)
    ..cubicTo(c.dx - s * 0.9, c.dy - s * 0.1, c.dx - s * 0.45, c.dy - s * 0.75, c.dx, c.dy - s * 0.3)
    ..cubicTo(c.dx + s * 0.45, c.dy - s * 0.75, c.dx + s * 0.9, c.dy - s * 0.1, c.dx, c.dy + s * 0.45)
    ..close();
  canvas.drawPath(p, Paint()..color = color);
}

void _sparkle(Canvas canvas, Offset c, double s, Color color) {
  final p = Path()
    ..moveTo(c.dx, c.dy - s)
    ..quadraticBezierTo(c.dx + s * 0.15, c.dy - s * 0.15, c.dx + s, c.dy)
    ..quadraticBezierTo(c.dx + s * 0.15, c.dy + s * 0.15, c.dx, c.dy + s)
    ..quadraticBezierTo(c.dx - s * 0.15, c.dy + s * 0.15, c.dx - s, c.dy)
    ..quadraticBezierTo(c.dx - s * 0.15, c.dy - s * 0.15, c.dx, c.dy - s)
    ..close();
  canvas.drawPath(p, Paint()..color = color);
}

void _star(Canvas canvas, Offset c, double s, Color color) {
  final p = Path();
  for (var i = 0; i < 10; i++) {
    final rad = i.isEven ? s : s * 0.45;
    final a = -math.pi / 2 + i * math.pi / 5;
    final pt = c + Offset(math.cos(a) * rad, math.sin(a) * rad);
    if (i == 0) {
      p.moveTo(pt.dx, pt.dy);
    } else {
      p.lineTo(pt.dx, pt.dy);
    }
  }
  p.close();
  canvas.drawPath(p, Paint()..color = color);
}

void _zText(Canvas canvas, Offset c, double s, double a) {
  final paint = Paint()
    ..color = _a(const Color(0xFFB9C3FF), a)
    ..style = PaintingStyle.stroke
    ..strokeWidth = s * 0.16
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round;
  final h = s * 0.4;
  final p = Path()
    ..moveTo(c.dx - h, c.dy - h)
    ..lineTo(c.dx + h, c.dy - h)
    ..lineTo(c.dx - h, c.dy + h)
    ..lineTo(c.dx + h, c.dy + h);
  canvas.drawPath(p, paint);
}

void _question(Canvas canvas, Offset c, double s, double a) {
  final col = _a(const Color(0xFF3B2A1E), a);
  final paint = Paint()
    ..color = col
    ..style = PaintingStyle.stroke
    ..strokeWidth = s * 0.16
    ..strokeCap = StrokeCap.round;
  final p = Path()
    ..moveTo(c.dx - s * 0.28, c.dy - s * 0.2)
    ..cubicTo(c.dx - s * 0.28, c.dy - s * 0.6, c.dx + s * 0.32, c.dy - s * 0.6, c.dx + s * 0.3, c.dy - s * 0.2)
    ..cubicTo(c.dx + s * 0.28, c.dy + s * 0.02, c.dx, c.dy, c.dx, c.dy + s * 0.18);
  canvas.drawPath(p, paint);
  canvas.drawCircle(c + Offset(0, s * 0.42), s * 0.09, Paint()..color = col);
}

void _note(Canvas canvas, Offset c, double s, double a) {
  final col = _a(const Color(0xFF6E64D6), a);
  canvas.drawOval(Rect.fromCenter(center: c, width: s * 0.7, height: s * 0.5), Paint()..color = col);
  canvas.drawLine(
    c + Offset(s * 0.33, 0),
    c + Offset(s * 0.33, -s * 1.0),
    Paint()
      ..color = col
      ..strokeWidth = s * 0.12,
  );
}
