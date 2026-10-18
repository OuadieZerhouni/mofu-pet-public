/// Draws the Boops: twelve squishy critters from one parametric painter.
///
/// Everything is procedural. The layout is the Boop! prototype's (body
/// superellipse, ears, nose, face) with a richer finish: soft-body jelly
/// shading (radial gradient plus a glossy top highlight), a back-light rim, a
/// blurred contact shadow, ears that swing with the body and glossy eyes.
/// Accessories and foam / wet overlays are painted by shared painters.
library;

import 'dart:math' as math;
import 'dart:typed_data' show Float64List;
import 'dart:ui';

import '../creature.dart';
import 'boop_catalog.dart';
import 'boop_creature.dart';

const _ink = Color(0xFF3B2A2A);
const _white = Color(0xFFFFFFFF);
const _inkSoft = Color(0xFF7A6363);
const _mouthRed = Color(0xFF8C3B4A);
const _heartRed = Color(0xFFFF6F8E);

class BoopArt extends CreatureArt {
  const BoopArt();

  @override
  void paint(Canvas canvas, Creature c, CreatureLook look, {bool shadow = true}) {
    if (c is! BoopCreature) return;
    final v = boopVariantById(look.variant.isEmpty ? c.variant : look.variant);
    _BoopPainter(canvas, c, v).paint(shadow: shadow);
  }
}

class _BoopPainter {
  _BoopPainter(this.canvas, this.c, this.v)
      : pose = c.pose,
        cx = c.position.dx,
        cy = c.position.dy,
        a = c.a,
        b = c.b,
        s = c.s,
        footDrop = c.footDrop;

  final Canvas canvas;
  final BoopCreature c;
  final BoopVariant v;
  final BoopPose pose;
  final double cx, cy, a, b, s, footDrop;

  double get baseY => cy + b;
  Offset get center => Offset(cx, cy);
  Offset get nose => Offset(cx, cy + b * 0.14);
  double get eyeY => cy - b * 0.06;
  double get eyeDx => a * 0.37;
  double get eyeR => a * 0.105;
  double get stroke => s * 0.022;

  late final Paint outline = Paint()
    ..color = _ink
    ..style = PaintingStyle.stroke
    ..strokeWidth = stroke
    ..strokeJoin = StrokeJoin.round
    ..strokeCap = StrokeCap.round;

  Color get deep => Color.lerp(v.body, _ink, 0.16)!;
  Color get light => Color.lerp(v.body, const Color(0xFFFFFFFF), 0.42)!;

  void paint({required bool shadow}) {
    if (shadow) _shadow();

    canvas.save();
    final pivot = Offset(cx, cy + footDrop);
    canvas.translate(pivot.dx, pivot.dy);
    canvas.rotate(pose.tilt);
    canvas.scale(pose.squashX, pose.squashY);
    if (pose.shear != Offset.zero) {
      canvas.transform(Float64List.fromList([
        1, 0, 0, 0, //
        -pose.shear.dx * 0.45, 1 + pose.shear.dy * 0.25, 0, 0, //
        0, 0, 1, 0, //
        0, 0, 0, 1,
      ]));
    }
    canvas.translate(-pivot.dx, -pivot.dy);

    final body = _bodyPath();
    _earsBehind();
    if (v.ears == BoopEars.jelly) _tentacles();
    _bodyFill(body);
    canvas.drawPath(body, outline);
    _earsFront();
    _limbs();
    _face();
    canvas.restore();

    _particles();
  }

  // ── shadow ────────────────────────────────────────────────────────────
  void _shadow() {
    final groundY = cy + footDrop + pose.hop;
    final lift = (pose.hop / (b * 0.8)).clamp(0.0, 1.0);
    final w = a * 1.75 * pose.squashX * (1 - lift * 0.3) * (1 + (1 - pose.squashY) * 0.35);
    final h = s * 0.052 * (1 - lift * 0.25);
    final shift = pose.shear.dx * a * 0.3 + pose.tilt * b * 0.5;
    final r = Rect.fromCenter(center: Offset(cx + shift, groundY + s * 0.006), width: w, height: h);
    canvas.drawOval(
      r,
      Paint()
        ..color = _ink.withValues(alpha: 0.2 * (1 - lift * 0.55))
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, s * 0.014),
    );
    canvas.drawOval(
      Rect.fromCenter(center: r.center, width: w * 0.55, height: h * 0.55),
      Paint()..color = _ink.withValues(alpha: 0.14 * (1 - lift * 0.55)),
    );
  }

  // ── body ──────────────────────────────────────────────────────────────
  Path _bodyPath() {
    // A squircle-ish "mochi": superellipse, bottom slightly flattened.
    const n = 2.5;
    const steps = 96;
    final path = Path();
    for (var i = 0; i <= steps; i++) {
      final t = i / steps * 2 * math.pi;
      final ct = math.cos(t), st = math.sin(t);
      var x = a * ct.sign * math.pow(ct.abs(), 2 / n);
      var y = b * st.sign * math.pow(st.abs(), 2 / n);
      if (y > 0) y *= 0.97;
      x *= 1 + 0.06 * (y / b);
      final p = Offset(cx + x, cy + y);
      i == 0 ? path.moveTo(p.dx, p.dy) : path.lineTo(p.dx, p.dy);
    }
    path.close();
    return path;
  }

  void _bodyFill(Path body) {
    final rect = Rect.fromCenter(center: center, width: a * 2, height: b * 2);
    final glossy = v.glossy;
    // Soft-body base: lit from the upper left, darker toward the rim.
    canvas.drawPath(
      body,
      Paint()
        ..shader = Gradient.radial(
          Offset(cx - a * 0.28, cy - b * 0.45),
          a * 1.5,
          [light, v.body, deep],
          const [0.0, 0.55, 1.0],
        ),
    );
    if (glossy) {
      // Translucent jelly: a brighter core that lets the edge read as thicker.
      canvas.drawPath(
        body,
        Paint()
          ..shader = Gradient.radial(center + Offset(a * 0.05, b * 0.1), a * 0.95,
              [_white.withValues(alpha: 0.38), _white.withValues(alpha: 0)], const [0.0, 1.0]),
      );
    }

    canvas.save();
    canvas.clipPath(body);

    // Belly: a soft pool of lighter colour, not a hard oval.
    canvas.save();
    final ra = a * 0.78;
    canvas.translate(cx, cy + b * 0.62);
    canvas.scale(1, (b * 0.62) / ra);
    canvas.drawCircle(
      Offset.zero,
      ra,
      Paint()
        ..shader = Gradient.radial(Offset.zero, ra, [v.belly.withValues(alpha: 0.95), v.belly.withValues(alpha: 0)],
            const [0.55, 1.0]),
    );
    canvas.restore();

    // Ambient occlusion where the body meets the floor.
    canvas.drawRect(
      rect.inflate(2),
      Paint()
        ..shader = Gradient.linear(
          rect.center,
          rect.bottomCenter,
          [deep.withValues(alpha: 0), deep.withValues(alpha: glossy ? 0.18 : 0.3)],
        ),
    );

    // Back-light rim along the lower right, just inside the outline.
    canvas.drawPath(
      body,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = s * 0.05
        ..shader = Gradient.linear(
          rect.topLeft,
          rect.bottomRight,
          [_white.withValues(alpha: 0), _white.withValues(alpha: 0), _white.withValues(alpha: glossy ? 0.75 : 0.55)],
          const [0.0, 0.56, 1.0],
        ),
    );

    // Glossy top highlight.
    canvas.save();
    canvas.translate(cx - a * 0.3, cy - b * 0.62);
    canvas.rotate(-0.32);
    final hr = Rect.fromCenter(center: Offset.zero, width: a * (glossy ? 0.78 : 0.62), height: b * (glossy ? 0.36 : 0.28));
    canvas.drawOval(
      hr,
      Paint()
        ..shader = Gradient.linear(
          hr.topCenter,
          hr.bottomCenter,
          [_white.withValues(alpha: glossy ? 0.95 : 0.8), _white.withValues(alpha: 0.04)],
        ),
    );
    canvas.restore();
    canvas.drawCircle(Offset(cx - a * 0.62, cy - b * 0.34), s * 0.011, Paint()..color = _white.withValues(alpha: 0.9));
    if (glossy) {
      canvas.drawArc(
        Rect.fromCenter(center: center, width: a * 1.62, height: b * 1.62),
        math.pi * 1.12,
        math.pi * 0.62,
        false,
        Paint()
          ..color = _white.withValues(alpha: 0.7)
          ..style = PaintingStyle.stroke
          ..strokeWidth = s * 0.018
          ..strokeCap = StrokeCap.round,
      );
    }
    canvas.restore();
  }

  // ── shaded shapes ─────────────────────────────────────────────────────
  void _fillStroke(Path p, Color fill) {
    final r = p.getBounds();
    canvas.drawPath(
      p,
      Paint()
        ..shader = Gradient.linear(
          r.topLeft,
          r.bottomRight,
          [Color.lerp(fill, _white, 0.3)!, fill, Color.lerp(fill, _ink, 0.1)!],
          const [0.0, 0.5, 1.0],
        ),
    );
    canvas.drawPath(p, outline);
  }

  // ── ears ──────────────────────────────────────────────────────────────
  void _earsBehind() {
    final sw = pose.earSwing;
    switch (v.ears) {
      case BoopEars.bunny:
        for (final side in [-1.0, 1.0]) {
          canvas.save();
          final base = Offset(cx + side * a * 0.36, cy - b * 0.72);
          canvas.translate(base.dx, base.dy);
          canvas.rotate(side * 0.2 + sw * 0.7);
          final ear = RRect.fromRectAndRadius(
              Rect.fromCenter(center: Offset(0, -b * 0.55), width: a * 0.36, height: b * 1.25), Radius.circular(a * 0.18));
          _fillStroke(Path()..addRRect(ear), v.body);
          final inner = Rect.fromCenter(center: Offset(0, -b * 0.6), width: a * 0.16, height: b * 0.85);
          canvas.drawRRect(
            RRect.fromRectAndRadius(inner, Radius.circular(a * 0.08)),
            Paint()
              ..shader = Gradient.linear(inner.topCenter, inner.bottomCenter,
                  [Color.lerp(v.accent, _white, 0.35)!, v.accent]),
          );
          canvas.restore();
        }
      case BoopEars.round:
        for (final side in [-1.0, 1.0]) {
          final ctr = Offset(cx + side * a * 0.66, cy - b * 0.78);
          final r = a * 0.27;
          _fillStroke(Path()..addOval(Rect.fromCircle(center: ctr, radius: r)), v.patches ? v.accent : v.body);
          if (!v.patches) {
            canvas.drawCircle(ctr + Offset(0, r * 0.12), r * 0.55, Paint()..color = v.accent);
          }
        }
      case BoopEars.pig:
        for (final side in [-1.0, 1.0]) {
          final tip = Offset(cx + side * a * 0.78, cy - b * 1.08);
          final p = Path()
            ..moveTo(cx + side * a * 0.34, cy - b * 0.86)
            ..quadraticBezierTo(cx + side * a * 0.62, cy - b * 1.2, tip.dx, tip.dy)
            ..quadraticBezierTo(cx + side * a * 0.98, cy - b * 0.7, cx + side * a * 0.72, cy - b * 0.58)
            ..close();
          _fillStroke(p, v.body);
        }
      case BoopEars.floppy:
        for (final side in [-1.0, 1.0]) {
          canvas.save();
          final root = Offset(cx + side * a * 0.5, cy - b * 0.8);
          canvas.translate(root.dx, root.dy);
          canvas.rotate(side * sw * 0.8);
          canvas.translate(-root.dx, -root.dy);
          final p = Path()
            ..moveTo(cx + side * a * 0.45, cy - b * 0.86)
            ..cubicTo(cx + side * a * 1.15, cy - b * 1.0, cx + side * a * 1.22, cy + b * 0.05, cx + side * a * 0.98, cy + b * 0.12)
            ..cubicTo(cx + side * a * 0.78, cy + b * 0.18, cx + side * a * 0.7, cy - b * 0.4, cx + side * a * 0.62, cy - b * 0.62)
            ..close();
          _fillStroke(p, v.accent);
          canvas.restore();
        }
      case BoopEars.horns:
        // Little wings peek out behind the body.
        for (final side in [-1.0, 1.0]) {
          canvas.save();
          final root = Offset(cx + side * a * 0.86, cy - b * 0.05);
          canvas.translate(root.dx, root.dy);
          canvas.rotate(side * sw * 0.5);
          canvas.translate(-root.dx, -root.dy);
          final p = Path()
            ..moveTo(root.dx, root.dy - b * 0.18)
            ..quadraticBezierTo(root.dx + side * a * 0.55, root.dy - b * 0.55, root.dx + side * a * 0.5, root.dy - b * 0.05)
            ..quadraticBezierTo(root.dx + side * a * 0.42, root.dy + b * 0.05, root.dx + side * a * 0.3, root.dy + b * 0.02)
            ..quadraticBezierTo(root.dx + side * a * 0.22, root.dy + b * 0.12, root.dx, root.dy + b * 0.12)
            ..close();
          _fillStroke(p, Color.lerp(v.body, _white, 0.35)!);
          canvas.restore();
        }
      case BoopEars.tuft:
      case BoopEars.bumps:
      case BoopEars.cloud:
      case BoopEars.none:
      case BoopEars.jelly:
      case BoopEars.leaf:
        break;
    }
  }

  void _earsFront() {
    final sw = pose.earSwing;
    switch (v.ears) {
      case BoopEars.tuft:
        canvas.save();
        final root = Offset(cx, cy - b * 0.94);
        canvas.translate(root.dx, root.dy);
        canvas.rotate(sw * 0.5);
        canvas.translate(-root.dx, -root.dy);
        for (final (dx, h, rot) in [(-0.14, 0.32, -0.45), (0.0, 0.42, 0.0), (0.14, 0.32, 0.45)]) {
          canvas.save();
          canvas.translate(cx + dx * a, cy - b * 0.94);
          canvas.rotate(rot);
          final p = Path()
            ..moveTo(0, 0)
            ..quadraticBezierTo(-a * 0.11, -b * h * 0.6, 0, -b * h)
            ..quadraticBezierTo(a * 0.11, -b * h * 0.6, 0, 0)
            ..close();
          _fillStroke(p, v.accent);
          canvas.restore();
        }
        canvas.restore();
      case BoopEars.bumps:
        // Frog eye-domes: the eyes sit inside them (see _eyeCenters).
        for (final side in [-1.0, 1.0]) {
          final ctr = Offset(cx + side * a * 0.44, cy - b * 0.74);
          final r = a * 0.3;
          final dome = Path()..addOval(Rect.fromCircle(center: ctr, radius: r));
          canvas.drawPath(
            dome,
            Paint()
              ..shader = Gradient.radial(ctr + Offset(-r * 0.3, -r * 0.4), r * 1.5,
                  [light, v.body, deep], const [0.0, 0.6, 1.0]),
          );
          canvas.drawArc(Rect.fromCircle(center: ctr, radius: r), math.pi * 0.98, math.pi * 1.04, false, outline);
        }
      case BoopEars.cloud:
        final puffs = <(Offset, double)>[
          for (var i = 0; i < 7; i++)
            (
              Offset(cx + math.cos(math.pi + i / 6 * math.pi) * a * 0.78, cy - b * 0.52 + math.sin(math.pi + i / 6 * math.pi) * b * 0.5),
              a * (i == 3 ? 0.3 : 0.25),
            ),
        ];
        for (final (p, r) in puffs) {
          canvas.drawCircle(p, r, outline);
        }
        for (final (p, r) in puffs) {
          canvas.drawCircle(
            p,
            r - outline.strokeWidth / 2,
            Paint()
              ..shader = Gradient.radial(p + Offset(-r * 0.3, -r * 0.35), r * 1.4,
                  [_white, v.belly, Color.lerp(v.belly, v.accent, 0.5)!], const [0.0, 0.5, 1.0]),
          );
        }
        // Little horn-curls for a lamb.
        for (final side in [-1.0, 1.0]) {
          final ctr = Offset(cx + side * a * 0.92, cy - b * 0.18);
          _fillStroke(Path()..addOval(Rect.fromCenter(center: ctr, width: a * 0.3, height: b * 0.24)), v.accent);
        }
      case BoopEars.leaf:
        canvas.save();
        final root = Offset(cx, cy - b * 0.96);
        canvas.translate(root.dx, root.dy);
        canvas.rotate(sw * 0.45);
        canvas.translate(-root.dx, -root.dy);
        canvas.drawLine(Offset(cx, cy - b * 0.96), Offset(cx + a * 0.04, cy - b * 1.22), outline);
        for (final side in [-1.0, 1.0]) {
          canvas.save();
          canvas.translate(cx + a * 0.04, cy - b * 1.2);
          canvas.rotate(side * 0.9 - 0.15);
          final leaf = Path()
            ..moveTo(0, 0)
            ..quadraticBezierTo(a * 0.18, -b * 0.18, 0, -b * 0.42)
            ..quadraticBezierTo(-a * 0.18, -b * 0.18, 0, 0)
            ..close();
          _fillStroke(leaf, v.accent);
          canvas.drawLine(Offset.zero, Offset(0, -b * 0.34), Paint()
            ..color = _white.withValues(alpha: 0.45)
            ..strokeWidth = s * 0.006
            ..strokeCap = StrokeCap.round);
          canvas.restore();
        }
        canvas.restore();
      case BoopEars.horns:
        for (final side in [-1.0, 1.0]) {
          // A small curved cone leaning outward; every x mirrored by `side`.
          final bx = cx + side * a * 0.46;
          final by = cy - b * 0.86;
          final p = Path()
            ..moveTo(bx - side * a * 0.11, by + b * 0.05)
            ..quadraticBezierTo(bx - side * a * 0.02, by - b * 0.26, bx + side * a * 0.16, by - b * 0.36)
            ..quadraticBezierTo(bx + side * a * 0.1, by - b * 0.12, bx + side * a * 0.12, by + b * 0.06)
            ..close();
          _fillStroke(p, v.accent);
        }
        // A spiky crest down the middle.
        for (var i = 0; i < 3; i++) {
          final x = cx + (i - 1) * a * 0.14;
          final p = Path()
            ..moveTo(x - a * 0.07, cy - b * 0.93)
            ..lineTo(x, cy - b * (1.12 + (i == 1 ? 0.06 : 0)))
            ..lineTo(x + a * 0.07, cy - b * 0.93)
            ..close();
          _fillStroke(p, Color.lerp(v.body, _white, 0.3)!);
        }
      case BoopEars.bunny:
      case BoopEars.round:
      case BoopEars.pig:
      case BoopEars.none:
      case BoopEars.floppy:
      case BoopEars.jelly:
        break;
    }
  }

  void _tentacles() {
    final sway = pose.earSwing;
    for (var i = 0; i < 4; i++) {
      final x = cx + (i - 1.5) * a * 0.42;
      final dx = -sway * a * 0.35 + math.sin(c.time * 2.2 + i * 1.3) * a * 0.04;
      final p = Path()
        ..moveTo(x - a * 0.1, cy + b * 0.6)
        ..quadraticBezierTo(x - a * 0.2 + dx * 0.5, cy + b * 1.05, x + dx, cy + b * 1.32)
        ..quadraticBezierTo(x + a * 0.2 + dx * 0.5, cy + b * 1.05, x + a * 0.1, cy + b * 0.6)
        ..close();
      _fillStroke(p, v.accent);
    }
  }

  void _limbs() {
    if (v.ears == BoopEars.jelly) return;
    // Two little paws resting on the sides of the body, and two feet.
    final limb = Color.lerp(v.body, _ink, 0.05)!;
    for (final side in [-1.0, 1.0]) {
      canvas.save();
      canvas.translate(cx + side * a * 0.9, cy + b * 0.3);
      canvas.rotate(side * -0.5);
      _fillStroke(Path()..addOval(Rect.fromCenter(center: Offset.zero, width: a * 0.26, height: b * 0.34)), limb);
      canvas.restore();
    }
    if (v.ears == BoopEars.none) {
      // Seal: flippers instead of feet.
      for (final side in [-1.0, 1.0]) {
        canvas.save();
        canvas.translate(cx + side * a * 0.62, baseY - b * 0.06);
        canvas.rotate(side * 0.5);
        _fillStroke(Path()..addOval(Rect.fromCenter(center: Offset.zero, width: a * 0.42, height: b * 0.17)), v.accent);
        canvas.restore();
      }
      return;
    }
    for (final side in [-1.0, 1.0]) {
      final foot = Rect.fromCenter(center: Offset(cx + side * a * 0.38, baseY - b * 0.03), width: a * 0.42, height: b * 0.2);
      _fillStroke(Path()..addOval(foot), limb);
    }
  }

  // ── face ──────────────────────────────────────────────────────────────
  void _face() {
    if (v.patches) _patches();
    _cheeks();
    if (v.freckles) _freckles();
    _eyes();
    _mouth();
    _nose();
    if (v.whiskers) _whiskers();
  }

  List<Offset> _eyeCenters() {
    if (v.ears == BoopEars.bumps) {
      return [Offset(cx - a * 0.44, cy - b * 0.74), Offset(cx + a * 0.44, cy - b * 0.74)];
    }
    return [Offset(cx - eyeDx, eyeY), Offset(cx + eyeDx, eyeY)];
  }

  void _patches() {
    final p = Paint()..color = v.accent;
    for (final e in _eyeCenters()) {
      canvas.save();
      canvas.translate(e.dx, e.dy + b * 0.02);
      canvas.rotate(e.dx < cx ? 0.5 : -0.5);
      final r = Rect.fromCenter(center: Offset.zero, width: a * 0.44, height: b * 0.5);
      canvas.drawOval(r, p);
      canvas.drawOval(
        Rect.fromCenter(center: Offset(-a * 0.05, -b * 0.12), width: a * 0.2, height: b * 0.14),
        Paint()..color = _white.withValues(alpha: 0.14),
      );
      canvas.restore();
    }
  }

  void _blush(Offset at, double w, double h, double alpha) {
    canvas.save();
    canvas.translate(at.dx, at.dy);
    canvas.scale(1, h / w);
    canvas.drawCircle(
      Offset.zero,
      w / 2,
      Paint()
        ..shader = Gradient.radial(Offset.zero, w / 2,
            [v.cheek.withValues(alpha: alpha), v.cheek.withValues(alpha: alpha * 0.55), v.cheek.withValues(alpha: 0)],
            const [0.0, 0.55, 1.0]),
    );
    canvas.restore();
  }

  void _cheeks() {
    final alpha = (0.55 + pose.blush * 0.4).clamp(0.0, 1.0);
    for (final side in [-1.0, 1.0]) {
      _blush(Offset(cx + side * a * 0.6, cy + b * 0.14), a * 0.4 * (1 + pose.blush * 0.15), b * 0.24, alpha);
    }
  }

  void _freckles() {
    final p = Paint()..color = Color.lerp(v.accent, _ink, 0.25)!.withValues(alpha: 0.55);
    for (final side in [-1.0, 1.0]) {
      for (final o in const [Offset(0, 0), Offset(0.09, -0.07), Offset(0.12, 0.07)]) {
        canvas.drawCircle(Offset(cx + side * (a * 0.62 + o.dx * a), cy + b * 0.02 + o.dy * b), s * 0.008, p);
      }
    }
  }

  void _eyes() {
    final r = eyeR;
    final onDark = v.patches;
    final eyeColor = onDark ? _white : _ink;
    final line = Paint()
      ..color = eyeColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = s * 0.024
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final centers = _eyeCenters();
    for (var i = 0; i < 2; i++) {
      final e = centers[i];
      final left = i == 0;
      switch (pose.face) {
        case BoopFace.open:
          final look = Offset(pose.look.dx.clamp(-1.0, 1.0) * r * 0.35, pose.look.dy.clamp(-1.0, 1.0) * r * 0.3);
          final lid = math.max(pose.blink, pose.squint * 0.62);
          final open = (1 - lid).clamp(0.08, 1.0);
          canvas.save();
          canvas.translate(e.dx + look.dx, e.dy + look.dy);
          canvas.scale(1, open);
          final eye = Rect.fromCenter(center: Offset.zero, width: r * 2, height: r * 2.3);
          if (onDark) {
            canvas.drawOval(eye, Paint()..color = _white);
            canvas.drawCircle(Offset(r * 0.1, r * 0.1), r * 0.62, Paint()..color = _ink);
            canvas.drawCircle(Offset(r * 0.32, -r * 0.2), r * 0.24, Paint()..color = _white);
          } else {
            canvas.drawOval(
              eye,
              Paint()
                ..shader = Gradient.radial(Offset(-r * 0.2, -r * 0.45), r * 1.9,
                    [const Color(0xFF6B5050), _ink, const Color(0xFF241717)], const [0.0, 0.5, 1.0]),
            );
            // Warm reflection pooled at the bottom of the eye.
            canvas.drawArc(
              Rect.fromCenter(center: Offset(0, r * 0.2), width: r * 1.45, height: r * 1.55),
              math.pi * 0.15,
              math.pi * 0.7,
              false,
              Paint()
                ..color = _white.withValues(alpha: 0.22)
                ..style = PaintingStyle.stroke
                ..strokeWidth = r * 0.22
                ..strokeCap = StrokeCap.round,
            );
            canvas.drawCircle(Offset(r * 0.35, -r * 0.45), r * 0.42, Paint()..color = _white);
            canvas.drawCircle(Offset(-r * 0.38, r * 0.45), r * 0.18, Paint()..color = _white.withValues(alpha: 0.9));
          }
          canvas.restore();
        case BoopFace.happy:
          // > <
          final dir = left ? 1.0 : -1.0;
          final p = Path()
            ..moveTo(e.dx - dir * r * 0.9, e.dy - r * 0.9)
            ..lineTo(e.dx + dir * r * 0.9, e.dy)
            ..lineTo(e.dx - dir * r * 0.9, e.dy + r * 0.9);
          canvas.drawPath(p, line);
        case BoopFace.hug:
        case BoopFace.munch:
          // ^ ^
          canvas.drawArc(Rect.fromCenter(center: e + Offset(0, r * 0.5), width: r * 2.2, height: r * 2.0), math.pi * 1.1, math.pi * 0.8, false, line);
        case BoopFace.sleepy:
          canvas.drawLine(e + Offset(-r * 1.05, 0), e + Offset(r * 1.05, 0), line);
          canvas.drawArc(Rect.fromCenter(center: e, width: r * 2, height: r * 2), 0, math.pi, true, Paint()..color = eyeColor);
        case BoopFace.asleep:
          canvas.drawArc(Rect.fromCenter(center: e - Offset(0, r * 0.4), width: r * 2.1, height: r * 1.8), math.pi * 0.15, math.pi * 0.7, false, line);
        case BoopFace.surprised:
          canvas.drawCircle(e, r * 1.15, Paint()..color = _white);
          canvas.drawCircle(e, r * 1.15, line);
          canvas.drawCircle(e, r * 0.45, Paint()..color = _ink);
          canvas.drawCircle(e + Offset(r * 0.15, -r * 0.18), r * 0.15, Paint()..color = _white);
      }
    }
  }

  void _mouth() {
    final m = Offset(cx, nose.dy + b * (v.noseStyle == BoopNose.snout ? 0.26 : 0.2));
    final w = a * 0.16;
    final line = Paint()
      ..color = _ink
      ..style = PaintingStyle.stroke
      ..strokeWidth = s * 0.018
      ..strokeCap = StrokeCap.round;
    switch (pose.face) {
      case BoopFace.happy:
        final p = Path()
          ..moveTo(m.dx - w * 1.1, m.dy - w * 0.25)
          ..quadraticBezierTo(m.dx, m.dy + w * 1.6, m.dx + w * 1.1, m.dy - w * 0.25)
          ..close();
        canvas.drawPath(p, Paint()..color = _mouthRed);
        canvas.save();
        canvas.clipPath(p);
        canvas.drawCircle(Offset(m.dx, m.dy + w * 0.95), w * 0.7, Paint()..color = _heartRed);
        canvas.restore();
        canvas.drawPath(p, line);
      case BoopFace.sleepy:
      case BoopFace.asleep:
      case BoopFace.surprised:
        canvas.drawOval(
          Rect.fromCenter(center: m + Offset(0, w * 0.2), width: w * 0.8, height: w * (pose.face == BoopFace.surprised ? 1.0 : 0.6)),
          Paint()..color = _mouthRed,
        );
      case BoopFace.open:
      case BoopFace.hug:
      case BoopFace.munch:
        if (pose.mouthOpen > 0.1) {
          final h = w * (0.5 + pose.mouthOpen * 1.5);
          final o = Rect.fromCenter(center: m + Offset(0, h * 0.35), width: w * 1.5, height: h);
          canvas.drawOval(o, Paint()..color = _mouthRed);
          canvas.save();
          canvas.clipPath(Path()..addOval(o));
          canvas.drawCircle(Offset(m.dx, o.bottom), w * 0.6, Paint()..color = _heartRed);
          canvas.restore();
          canvas.drawOval(o, line);
          return;
        }
        if (v.noseStyle == BoopNose.beak) return; // the beak is the mouth
        canvas.drawArc(Rect.fromCenter(center: m - Offset(w * 0.5, 0), width: w, height: w * 0.9), 0.1, math.pi * 0.85, false, line);
        canvas.drawArc(Rect.fromCenter(center: m + Offset(w * 0.5, 0), width: w, height: w * 0.9), 0.1, math.pi * 0.85, false, line);
    }
  }

  void _nose() {
    final n = nose;
    final col = Color.lerp(v.nose, const Color(0xFFFF3D6E), pose.noseFlash * 0.6)!;
    final thin = Paint()
      ..color = _ink
      ..style = PaintingStyle.stroke
      ..strokeWidth = s * 0.014
      ..strokeJoin = StrokeJoin.round;
    final u = a * 0.1;
    Path p;
    switch (v.noseStyle) {
      case BoopNose.button:
        p = Path()..addOval(Rect.fromCenter(center: n, width: u * 1.9, height: u * 1.35));
      case BoopNose.heart:
        p = Path()
          ..moveTo(n.dx, n.dy + u * 0.8)
          ..cubicTo(n.dx - u * 1.5, n.dy - u * 0.1, n.dx - u * 0.75, n.dy - u * 1.15, n.dx, n.dy - u * 0.35)
          ..cubicTo(n.dx + u * 0.75, n.dy - u * 1.15, n.dx + u * 1.5, n.dy - u * 0.1, n.dx, n.dy + u * 0.8)
          ..close();
      case BoopNose.beak:
        p = Path()
          ..moveTo(n.dx - u * 1.2, n.dy - u * 0.35)
          ..quadraticBezierTo(n.dx, n.dy - u * 0.95, n.dx + u * 1.2, n.dy - u * 0.35)
          ..quadraticBezierTo(n.dx + u * 0.2, n.dy + u * 1.2, n.dx, n.dy + u * 1.25)
          ..quadraticBezierTo(n.dx - u * 0.2, n.dy + u * 1.2, n.dx - u * 1.2, n.dy - u * 0.35)
          ..close();
      case BoopNose.snout:
        p = Path()..addOval(Rect.fromCenter(center: n, width: u * 3.4, height: u * 2.3));
      case BoopNose.triangle:
        p = Path()
          ..moveTo(n.dx - u * 1.0, n.dy - u * 0.55)
          ..quadraticBezierTo(n.dx, n.dy - u * 0.85, n.dx + u * 1.0, n.dy - u * 0.55)
          ..quadraticBezierTo(n.dx + u * 0.3, n.dy + u * 0.75, n.dx, n.dy + u * 0.75)
          ..quadraticBezierTo(n.dx - u * 0.3, n.dy + u * 0.75, n.dx - u * 1.0, n.dy - u * 0.55)
          ..close();
      case BoopNose.star:
        p = Path();
        for (var i = 0; i < 10; i++) {
          final ang = -math.pi / 2 + i * math.pi / 5;
          final rr = i.isEven ? u * 1.25 : u * 0.6;
          final pt = n + Offset(math.cos(ang) * rr, math.sin(ang) * rr);
          i == 0 ? p.moveTo(pt.dx, pt.dy) : p.lineTo(pt.dx, pt.dy);
        }
        p.close();
    }
    final r = p.getBounds();
    canvas.drawPath(
      p,
      Paint()
        ..shader = Gradient.radial(
          r.center + Offset(-r.width * 0.2, -r.height * 0.3),
          math.max(r.width, r.height) * 0.9,
          [Color.lerp(col, _white, 0.4)!, col, Color.lerp(col, _ink, 0.2)!],
          const [0.0, 0.55, 1.0],
        ),
    );
    canvas.drawPath(p, thin);
    if (v.noseStyle == BoopNose.snout) {
      for (final side in [-1.0, 1.0]) {
        canvas.drawOval(Rect.fromCenter(center: n + Offset(side * u * 0.65, 0), width: u * 0.5, height: u * 0.75),
            Paint()..color = const Color(0xFFB0505E));
      }
    }
    // Shine: makes the nose read as the thing to touch.
    canvas.drawOval(Rect.fromCenter(center: n + Offset(-u * 0.35, -u * 0.3), width: u * 0.55, height: u * 0.35),
        Paint()..color = _white.withValues(alpha: 0.8));
  }

  void _whiskers() {
    final p = Paint()
      ..color = _ink.withValues(alpha: 0.55)
      ..strokeWidth = s * 0.009
      ..strokeCap = StrokeCap.round;
    for (final side in [-1.0, 1.0]) {
      for (var k = -1; k <= 1; k++) {
        final from = nose + Offset(side * a * 0.3, b * (0.05 * k));
        final to = nose + Offset(side * a * 0.62, b * (0.1 * k - 0.02));
        canvas.drawLine(from, to, p);
      }
    }
  }

  // ── particles (room coordinates) ──────────────────────────────────────
  void _particles() {
    for (final p in c.particles) {
      final fade = p.t < 0.7 ? 1.0 : 1 - (p.t - 0.7) / 0.3;
      switch (p.kind) {
        case BoopParticleKind.heart:
          final sz = p.size * (0.6 + 0.4 * math.min(1.0, p.t * 5));
          _heartShape(p.pos, sz, p.color.withValues(alpha: fade));
        case BoopParticleKind.sparkle:
          _sparkle(p.pos, p.size * (1 - p.t * 0.6), p.color.withValues(alpha: fade));
        case BoopParticleKind.confetti:
          canvas.save();
          canvas.translate(p.pos.dx, p.pos.dy);
          canvas.rotate(p.angle);
          canvas.drawRRect(
            RRect.fromRectAndRadius(Rect.fromCenter(center: Offset.zero, width: p.size, height: p.size * 0.55), const Radius.circular(2)),
            Paint()..color = p.color.withValues(alpha: fade),
          );
          canvas.restore();
        case BoopParticleKind.zzz:
          _zee(p.pos, p.size * (0.55 + 0.45 * p.t), _inkSoft.withValues(alpha: fade));
        case BoopParticleKind.crumb:
          canvas.drawCircle(p.pos, p.size, Paint()..color = p.color.withValues(alpha: fade));
      }
    }
  }

  void _heartShape(Offset at, double sz, Color color) {
    final path = Path()
      ..moveTo(at.dx, at.dy + sz * 0.35)
      ..cubicTo(at.dx - sz * 0.75, at.dy - sz * 0.15, at.dx - sz * 0.35, at.dy - sz * 0.65, at.dx, at.dy - sz * 0.22)
      ..cubicTo(at.dx + sz * 0.35, at.dy - sz * 0.65, at.dx + sz * 0.75, at.dy - sz * 0.15, at.dx, at.dy + sz * 0.35)
      ..close();
    canvas.drawPath(path, Paint()..color = color);
    canvas.drawPath(
      path,
      Paint()
        ..color = _ink.withValues(alpha: color.a * 0.8)
        ..style = PaintingStyle.stroke
        ..strokeWidth = math.max(1.0, sz * 0.07),
    );
  }

  void _sparkle(Offset at, double r, Color color) {
    final p = Path()
      ..moveTo(at.dx, at.dy - r)
      ..quadraticBezierTo(at.dx, at.dy, at.dx + r, at.dy)
      ..quadraticBezierTo(at.dx, at.dy, at.dx, at.dy + r)
      ..quadraticBezierTo(at.dx, at.dy, at.dx - r, at.dy)
      ..quadraticBezierTo(at.dx, at.dy, at.dx, at.dy - r)
      ..close();
    canvas.drawPath(p, Paint()..color = color);
  }

  void _zee(Offset at, double sz, Color color) {
    final r = sz * 0.4;
    final p = Path()
      ..moveTo(at.dx - r, at.dy - r)
      ..lineTo(at.dx + r, at.dy - r)
      ..lineTo(at.dx - r, at.dy + r)
      ..lineTo(at.dx + r, at.dy + r);
    canvas.drawPath(
      p,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = math.max(1.5, sz * 0.14)
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
  }
}
