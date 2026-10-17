/// Paints one [OinkCreature] pose. Stateless: the same pose and tint always
/// give the same pixels. Accessories, foam, wet fur and mud are NOT drawn here
/// (the shared painters do that, using [Creature.anchor], [Creature.silhouette]
/// and [Creature.care]).
library;

import 'dart:math' as math;
import 'dart:ui';

import '../creature.dart';
import 'oink_creature.dart';

/// A full coat palette.
class OinkPalette {
  const OinkPalette({
    required this.body,
    required this.light,
    required this.shade,
    required this.outline,
    required this.snout,
    required this.snoutShade,
    required this.nostril,
    required this.innerEar,
    required this.hoof,
    required this.blush,
    this.eye = const Color(0xFF3A2430),
    this.spot,
  });

  final Color body;
  final Color light;
  final Color shade;
  final Color outline;
  final Color snout;
  final Color snoutShade;
  final Color nostril;
  final Color innerEar;
  final Color hoof;
  final Color blush;
  final Color eye;

  /// Non-null = patches of this colour on body, head and one ear.
  final Color? spot;
}

const oinkPalettes = <String, OinkPalette>{
  'classic': OinkPalette(
    body: Color(0xFFFFB8CB),
    light: Color(0xFFFFD6E1),
    shade: Color(0xFFF59AB4),
    outline: Color(0xFFD9698F),
    snout: Color(0xFFFF97B5),
    snoutShade: Color(0xFFF07FA2),
    nostril: Color(0xFFB4436C),
    innerEar: Color(0xFFFF8DB0),
    hoof: Color(0xFFE97F9F),
    blush: Color(0xFFFF6F98),
  ),
  'peach': OinkPalette(
    body: Color(0xFFFFC9A3),
    light: Color(0xFFFFE3CF),
    shade: Color(0xFFF0A878),
    outline: Color(0xFFD27D50),
    snout: Color(0xFFFFA88A),
    snoutShade: Color(0xFFEE8C6A),
    nostril: Color(0xFFA9553A),
    innerEar: Color(0xFFFF9E80),
    hoof: Color(0xFFE58A62),
    blush: Color(0xFFFF7F66),
  ),
  'spotted': OinkPalette(
    body: Color(0xFFFFD4DC),
    light: Color(0xFFFFEEF1),
    shade: Color(0xFFF1A9BC),
    outline: Color(0xFFD2708E),
    snout: Color(0xFFFF9DB8),
    snoutShade: Color(0xFFF383A5),
    nostril: Color(0xFFB4436C),
    innerEar: Color(0xFFFF9DB8),
    hoof: Color(0xFFD98A72),
    blush: Color(0xFFFF6F98),
    spot: Color(0xFF7E5A6E),
  ),
  'chocolate': OinkPalette(
    body: Color(0xFFA87350),
    light: Color(0xFFCB9874),
    shade: Color(0xFF855238),
    outline: Color(0xFF55301F),
    snout: Color(0xFFC98C6C),
    snoutShade: Color(0xFFAF7352),
    nostril: Color(0xFF45240F),
    innerEar: Color(0xFFD99B7C),
    hoof: Color(0xFF6F432C),
    blush: Color(0xFFE8826C),
    eye: Color(0xFF1F1015),
  ),
  'lavender': OinkPalette(
    body: Color(0xFFCDB9F2),
    light: Color(0xFFE8DDFB),
    shade: Color(0xFFAE97DD),
    outline: Color(0xFF7E62B5),
    snout: Color(0xFFDDA9EA),
    snoutShade: Color(0xFFCA8CDB),
    nostril: Color(0xFF86488F),
    innerEar: Color(0xFFD8A3EA),
    hoof: Color(0xFFA68CD2),
    blush: Color(0xFFF58BC8),
  ),
  'golden': OinkPalette(
    body: Color(0xFFFFD878),
    light: Color(0xFFFFEDB4),
    shade: Color(0xFFF2BA4B),
    outline: Color(0xFFC98A24),
    snout: Color(0xFFFFB864),
    snoutShade: Color(0xFFF0A04A),
    nostril: Color(0xFFA35D26),
    innerEar: Color(0xFFFFB070),
    hoof: Color(0xFFE29B3C),
    blush: Color(0xFFFF9A5C),
  ),
  'mint': OinkPalette(
    body: Color(0xFFB6EBCB),
    light: Color(0xFFDDF8E8),
    shade: Color(0xFF8FD3AC),
    outline: Color(0xFF55A07C),
    snout: Color(0xFF93DDB6),
    snoutShade: Color(0xFF74C79C),
    nostril: Color(0xFF3B8262),
    innerEar: Color(0xFFA2E3BF),
    hoof: Color(0xFF7BC49C),
    blush: Color(0xFFFF9AA8),
  ),
  'snow': OinkPalette(
    body: Color(0xFFF3F0F8),
    light: Color(0xFFFFFFFF),
    shade: Color(0xFFD7D0E3),
    outline: Color(0xFFA195B6),
    snout: Color(0xFFFFC7D4),
    snoutShade: Color(0xFFF2A9BC),
    nostril: Color(0xFFB05C78),
    innerEar: Color(0xFFFFCCD8),
    hoof: Color(0xFFD8C6D6),
    blush: Color(0xFFFF9DB4),
  ),
};

OinkPalette oinkPalette(String variant) => oinkPalettes[variant] ?? oinkPalettes['classic']!;

class OinkArt extends CreatureArt {
  const OinkArt();

  @override
  void paint(Canvas canvas, Creature c, CreatureLook look, {bool shadow = true}) {
    if (c is! OinkCreature) return;
    final pal = oinkPalette(look.variant);
    final s = c.scale;
    if (!s.isFinite || s <= 0) return;

    canvas.save();
    canvas.translate(c.position.dx, c.position.dy);
    canvas.scale(s);
    if (shadow) _shadow(canvas, c);

    final pose = c.pose;
    canvas.translate(0, pose.bounce);
    canvas.translate(0, OinkGeo.footY);
    canvas.rotate(pose.lean);
    canvas.scale(1 + 0.16 * pose.squash, 1 - 0.18 * pose.squash);
    canvas.translate(0, -OinkGeo.footY);

    final p = _Pig(canvas, pal, pose);
    p.tail();
    p.backLegs();
    p.body();
    p.frontLegs();
    p.head();
    canvas.restore();

    _paintParticles(canvas, c);
  }

  void _shadow(Canvas canvas, OinkCreature c) {
    final groundLocal = (c.groundY - c.position.dy) / c.scale;
    final lift = (c.liftPx / c.scale).clamp(0.0, 120.0);
    final k = 1 - 0.45 * (lift / 120);
    final w = OinkGeo.bodyRx * 1.0 * k;
    canvas.save();
    canvas.translate(0, groundLocal - 1);
    canvas.scale(1, 0.17);
    canvas.drawCircle(
      Offset.zero,
      w * 1.18,
      Paint()
        ..shader = Gradient.radial(
          Offset.zero,
          w * 1.18,
          [const Color(0x2E000000).withValues(alpha: 0.18 * k), const Color(0x00000000)],
          const [0.55, 1.0],
        ),
    );
    canvas.drawCircle(
      Offset.zero,
      w * 0.72,
      Paint()
        ..shader = Gradient.radial(
          Offset.zero,
          w * 0.72,
          [const Color(0xFF000000).withValues(alpha: 0.26 * k), const Color(0x00000000)],
          const [0.0, 1.0],
        ),
    );
    canvas.restore();
  }

  // ── particles (room coordinates) ───────────────────────────────────────
  void _paintParticles(Canvas canvas, OinkCreature c) {
    for (final p in c.particles) {
      final t = p.t;
      final fade = t < 0.15 ? t / 0.15 : (1 - t).clamp(0.0, 1.0) / 0.85;
      final a = fade.clamp(0.0, 1.0);
      switch (p.kind) {
        case OinkParticleKind.heart:
          canvas.save();
          canvas.translate(p.pos.dx, p.pos.dy);
          canvas.rotate(math.sin(p.spin * 3) * 0.25);
          final path = _heart(p.size);
          canvas.drawPath(path, Paint()..color = const Color(0xFFFF5C8A).withValues(alpha: a));
          canvas.drawCircle(
            Offset(-p.size * 0.35, -p.size * 0.25),
            p.size * 0.14,
            Paint()..color = const Color(0xFFFFFFFF).withValues(alpha: 0.7 * a),
          );
          canvas.restore();
        case OinkParticleKind.sparkle:
          _star(canvas, p.pos, p.size * (0.6 + 0.4 * math.sin(p.spin * 8).abs()), const Color(0xFFFFD54F).withValues(alpha: a));
        case OinkParticleKind.zzz:
          final z = p.size;
          final path = Path()
            ..moveTo(p.pos.dx - z * 0.55, p.pos.dy - z * 0.5)
            ..lineTo(p.pos.dx + z * 0.55, p.pos.dy - z * 0.5)
            ..lineTo(p.pos.dx - z * 0.55, p.pos.dy + z * 0.5)
            ..lineTo(p.pos.dx + z * 0.55, p.pos.dy + z * 0.5);
          canvas.drawPath(
            path,
            Paint()
              ..color = const Color(0xFF8E7CC3).withValues(alpha: a)
              ..style = PaintingStyle.stroke
              ..strokeWidth = z * 0.28
              ..strokeJoin = StrokeJoin.round
              ..strokeCap = StrokeCap.round,
          );
        case OinkParticleKind.crumb:
          canvas.drawCircle(p.pos, p.size * 0.35, Paint()..color = const Color(0xFFE0A15A).withValues(alpha: a));
        case OinkParticleKind.drop:
          final path = Path()
            ..moveTo(p.pos.dx, p.pos.dy - p.size)
            ..quadraticBezierTo(p.pos.dx + p.size * 0.7, p.pos.dy + p.size * 0.2, p.pos.dx, p.pos.dy + p.size * 0.5)
            ..quadraticBezierTo(p.pos.dx - p.size * 0.7, p.pos.dy + p.size * 0.2, p.pos.dx, p.pos.dy - p.size)
            ..close();
          canvas.drawPath(path, Paint()..color = const Color(0xFF64B5F6).withValues(alpha: 0.85 * a));
      }
    }
  }

  static Path _heart(double size) {
    final s = size;
    return Path()
      ..moveTo(0, s * 0.9)
      ..cubicTo(-s * 1.5, -s * 0.1, -s * 0.6, -s * 1.1, 0, -s * 0.35)
      ..cubicTo(s * 0.6, -s * 1.1, s * 1.5, -s * 0.1, 0, s * 0.9)
      ..close();
  }

  static void _star(Canvas canvas, Offset c, double r, Color color) {
    final path = Path();
    for (var i = 0; i < 8; i++) {
      final a = i * math.pi / 4;
      final rr = i.isEven ? r : r * 0.32;
      final pt = c + Offset(math.sin(a) * rr, -math.cos(a) * rr);
      i == 0 ? path.moveTo(pt.dx, pt.dy) : path.lineTo(pt.dx, pt.dy);
    }
    path.close();
    canvas.drawPath(path, Paint()..color = color);
  }
}

/// The pig's parts, drawn in design space.
class _Pig {
  _Pig(this.c, this.pal, this.pose)
      : rim = Color.lerp(pal.light, const Color(0xFFFFFFFF), 0.55)!,
        bounce = Color.lerp(pal.shade, const Color(0xFFFFE3B0), 0.45)!;

  final Canvas c;
  final OinkPalette pal;
  final OinkPose pose;
  final Color rim;
  final Color bounce;

  static const _cx = 0.0;

  Paint get _outline => Paint()
    ..color = pal.outline
    ..style = PaintingStyle.stroke
    ..strokeWidth = 3
    ..strokeJoin = StrokeJoin.round
    ..strokeCap = StrokeCap.round;

  Paint _fill(Color col) => Paint()..color = col;

  Color _clear(Color col) => col.withValues(alpha: 0);

  /// Soft inner rim light from the upper left and a warm bounce from below.
  void _rimLight(Path clip, Rect box, {double w = 12, double a = 0.6}) {
    c.save();
    c.clipPath(clip);
    c.drawPath(
      clip,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = w
        ..shader = Gradient.linear(box.topLeft, box.bottomRight, [rim.withValues(alpha: a), rim.withValues(alpha: 0)], const [0.0, 0.62]),
    );
    c.drawPath(
      clip,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = w * 0.8
        ..shader = Gradient.linear(box.bottomRight, box.topLeft, [bounce.withValues(alpha: 0.32), bounce.withValues(alpha: 0)], const [0.0, 0.4]),
    );
    c.restore();
  }

  // ── tail ─────────────────────────────────────────────────────────────
  void tail() {
    c.save();
    c.translate(OinkGeo.tailBase.dx, OinkGeo.tailBase.dy);
    c.rotate(-0.55 + pose.tail);
    final path = Path()..moveTo(0, 0);
    const turns = 1.35;
    for (var i = 1; i <= 40; i++) {
      final t = i / 40;
      final a = t * turns * 2 * math.pi;
      final r = 7 + 11 * (1 - t);
      path.lineTo(26 * t + r * math.cos(a) - r, -10 * t + r * math.sin(a));
    }
    c.drawPath(
      path,
      Paint()
        ..color = pal.outline
        ..style = PaintingStyle.stroke
        ..strokeWidth = 8
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
    c.drawPath(
      path,
      Paint()
        ..color = pal.body
        ..style = PaintingStyle.stroke
        ..strokeWidth = 5
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
    c.save();
    c.translate(-0.9, -1.1);
    c.drawPath(
      path,
      Paint()
        ..color = pal.light.withValues(alpha: 0.7)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.8
        ..strokeCap = StrokeCap.round,
    );
    c.restore();
    c.restore();
  }

  // ── legs ─────────────────────────────────────────────────────────────
  void backLegs() {
    for (final side in [-1.0, 1.0]) {
      final center = Offset(_cx + side * OinkGeo.bodyRx * 0.78, OinkGeo.bodyC.dy + OinkGeo.bodyRy * 0.62);
      final r = Rect.fromCenter(center: center, width: OinkGeo.bodyRx * 0.5, height: OinkGeo.bodyRy * 0.62);
      c.drawOval(
        r,
        Paint()
          ..shader = Gradient.radial(
            center + const Offset(-6, -8),
            r.width * 0.8,
            [pal.body, pal.shade],
            const [0.0, 1.0],
          ),
      );
      c.drawOval(r, _outline);
    }
  }

  void frontLegs() {
    for (final side in [-1.0, 1.0]) {
      final kick = pose.legKick * (side < 0 ? 1 : 0.6);
      final base = Offset(_cx + side * OinkGeo.bodyRx * 0.36, OinkGeo.bodyC.dy + OinkGeo.bodyRy * 0.86 - 10 * kick);
      final rect = Rect.fromCenter(center: base, width: OinkGeo.bodyRx * 0.36, height: OinkGeo.bodyRy * 0.42);
      final leg = RRect.fromRectAndRadius(rect, const Radius.circular(16));
      c.drawRRect(
        leg,
        Paint()
          ..shader = Gradient.linear(rect.topLeft, rect.bottomRight, [pal.light, pal.body, pal.shade], const [0.0, 0.5, 1.0]),
      );
      c.drawRRect(leg, _outline);
      final tip = Rect.fromCenter(center: base + Offset(0, OinkGeo.bodyRy * 0.15), width: OinkGeo.bodyRx * 0.3, height: OinkGeo.bodyRy * 0.13);
      final tipR = RRect.fromRectAndRadius(tip, const Radius.circular(8));
      c.drawRRect(tipR, _fill(pal.hoof));
      c.drawRRect(
        RRect.fromRectAndRadius(tip.deflate(1.5).translate(0, -1.5), const Radius.circular(6)),
        Paint()..color = const Color(0x33FFFFFF),
      );
    }
  }

  // ── body ─────────────────────────────────────────────────────────────
  void body() {
    final squish = 1 + 0.025 * pose.breath;
    final w = OinkGeo.bodyRx * 2 / squish;
    final h = OinkGeo.bodyRy * 2 * squish;
    // keep the bottom planted while breathing
    final center = Offset(OinkGeo.bodyC.dx, OinkGeo.bodyC.dy - (h - OinkGeo.bodyRy * 2) / 2);
    final rect = Rect.fromCenter(center: center, width: w, height: h);
    final path = Path()..addOval(rect);

    c.drawOval(
      rect,
      Paint()
        ..shader = Gradient.radial(
          rect.center + Offset(-w * 0.17, -h * 0.25),
          w * 0.78,
          [pal.light, pal.body, pal.shade],
          const [0.0, 0.55, 1.0],
        ),
    );

    c.save();
    c.clipPath(path);
    if (pal.spot != null) _bodySpots(rect);
    // soft belly patch
    final belly = Rect.fromCenter(center: rect.center + Offset(0, h * 0.2), width: w * 0.62, height: h * 0.56);
    c.save();
    c.translate(belly.center.dx, belly.center.dy);
    c.scale(1, belly.height / belly.width);
    c.drawCircle(
      Offset.zero,
      belly.width / 2,
      Paint()
        ..shader = Gradient.radial(
          Offset.zero,
          belly.width / 2,
          [pal.light.withValues(alpha: 0.95), pal.light.withValues(alpha: 0.8), pal.light.withValues(alpha: 0)],
          const [0.0, 0.7, 1.0],
        ),
    );
    c.restore();
    // belly highlight
    c.drawOval(
      Rect.fromCenter(center: rect.center + Offset(-w * 0.08, h * 0.14), width: w * 0.3, height: h * 0.14),
      Paint()..color = const Color(0x40FFFFFF),
    );
    // grounding shade along the bottom edge
    c.drawRect(
      rect,
      Paint()
        ..shader = Gradient.linear(rect.topCenter, rect.bottomCenter, [_clear(pal.shade), _clear(pal.shade), pal.shade.withValues(alpha: 0.38)], const [0.0, 0.62, 1.0]),
    );
    c.restore();
    _rimLight(path, rect, w: 13);
    c.drawOval(rect, _outline);
  }

  void _bodySpots(Rect r) {
    const spots = <(double, double, double)>[
      (-0.5, -0.25, 0.26),
      (0.5, 0.0, 0.2),
      (-0.2, 0.55, 0.17),
      (0.7, -0.5, 0.13),
      (-0.78, 0.3, 0.12),
    ];
    for (final s in spots) {
      _blob(Offset(r.center.dx + s.$1 * r.width / 2, r.center.dy + s.$2 * r.height / 2), s.$3 * r.width / 2, s.$1 * 7);
    }
  }

  void _blob(Offset center, double r, double phase) {
    final path = Path();
    const n = 18;
    for (var i = 0; i <= n; i++) {
      final a = i / n * 2 * math.pi;
      final rr = r * (1 + 0.12 * math.sin(a * 3 + phase) + 0.05 * math.sin(a * 5 + phase * 2));
      final pt = center + Offset(math.cos(a) * rr, math.sin(a) * rr * 0.86);
      i == 0 ? path.moveTo(pt.dx, pt.dy) : path.lineTo(pt.dx, pt.dy);
    }
    path.close();
    final col = pal.spot!;
    c.drawPath(
      path,
      Paint()
        ..shader = Gradient.radial(center + Offset(-r * 0.3, -r * 0.35), r * 1.5, [Color.lerp(col, const Color(0xFFFFFFFF), 0.22)!, col], const [0.0, 1.0]),
    );
  }

  // ── head ─────────────────────────────────────────────────────────────
  void head() {
    final lift = -2.2 * pose.breath;
    final pivot = OinkGeo.headPivot;
    c.save();
    c.translate(pivot.dx, pivot.dy + lift);
    c.rotate(pose.headTilt + pose.shake);
    c.translate(-pivot.dx, -pivot.dy);
    _ears();
    _headShape();
    _cheeks();
    _eyes();
    _snout();
    _mouth();
    c.restore();
  }

  void _ears() {
    for (final side in [-1.0, 1.0]) {
      final base = side < 0 ? OinkGeo.earBaseL : OinkGeo.earBaseR;
      final flop = side < 0 ? pose.earLeft : pose.earRight;
      c.save();
      c.translate(base.dx, base.dy);
      c.rotate(side * (0.38 + flop));
      const w = OinkGeo.headR * 0.62, h = OinkGeo.headR * 0.78;
      Path ear(double scale) {
        final ww = w * scale, hh = h * scale;
        return Path()
          ..moveTo(-ww / 2, 8)
          ..quadraticBezierTo(-ww * 0.5, -hh * 0.55, 0, -hh)
          ..quadraticBezierTo(ww * 0.5, -hh * 0.55, ww / 2, 8)
          ..close();
      }

      final outer = ear(1);
      final spotted = pal.spot != null && side < 0;
      final top = spotted ? Color.lerp(pal.spot!, const Color(0xFFFFFFFF), 0.2)! : pal.light;
      final mid = spotted ? pal.spot! : pal.body;
      final bot = spotted ? Color.lerp(pal.spot!, pal.outline, 0.35)! : pal.shade;
      c.drawPath(
        outer,
        Paint()..shader = Gradient.linear(const Offset(0, -h), const Offset(0, 8), [top, mid, bot], const [0.0, 0.5, 1.0]),
      );
      c.drawPath(outer, _outline);
      c.save();
      c.translate(0, -h * 0.07);
      final inner = ear(0.62);
      c.drawPath(
        inner,
        Paint()
          ..shader = Gradient.linear(
            Offset(0, -h * 0.62),
            const Offset(0, 8),
            [Color.lerp(pal.innerEar, pal.light, 0.45)!, pal.innerEar, Color.lerp(pal.innerEar, pal.shade, 0.5)!],
            const [0.0, 0.5, 1.0],
          ),
      );
      c.restore();
      // tiny edge light
      c.save();
      c.clipPath(outer);
      c.drawPath(
        outer,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 7
          ..shader = Gradient.linear(Offset(-w / 2, -h), Offset(w / 2, 8), [rim.withValues(alpha: 0.5), rim.withValues(alpha: 0)], const [0.0, 0.5]),
      );
      c.restore();
      c.restore();
    }
  }

  void _headShape() {
    final oval = Rect.fromCenter(center: OinkGeo.headC, width: OinkGeo.headR * 2.12, height: OinkGeo.headR * 1.92);
    final path = Path()..addOval(oval);
    c.drawOval(
      oval,
      Paint()
        ..shader = Gradient.radial(
          OinkGeo.headC + const Offset(-OinkGeo.headR * 0.3, -OinkGeo.headR * 0.45),
          OinkGeo.headR * 1.6,
          [pal.light, pal.body, pal.shade],
          const [0.0, 0.58, 1.0],
        ),
    );
    c.save();
    c.clipPath(path);
    if (pal.spot != null) {
      _blob(OinkGeo.headC + const Offset(OinkGeo.headR * 0.5, -OinkGeo.headR * 0.5), OinkGeo.headR * 0.24, 2.1);
      _blob(OinkGeo.headC + const Offset(-OinkGeo.headR * 0.7, OinkGeo.headR * 0.05), OinkGeo.headR * 0.17, 4.2);
    }
    // forehead gloss
    c.save();
    final g = OinkGeo.headC + const Offset(-OinkGeo.headR * 0.34, -OinkGeo.headR * 0.55);
    c.translate(g.dx, g.dy);
    c.rotate(-0.5);
    c.scale(1.6, 1);
    c.drawCircle(
      Offset.zero,
      OinkGeo.headR * 0.2,
      Paint()
        ..shader = Gradient.radial(Offset.zero, OinkGeo.headR * 0.2, [const Color(0x55FFFFFF), const Color(0x00FFFFFF)], const [0.0, 1.0]),
    );
    c.restore();
    // chin shade
    c.drawRect(
      oval,
      Paint()
        ..shader = Gradient.linear(oval.topCenter, oval.bottomCenter, [_clear(pal.shade), _clear(pal.shade), pal.shade.withValues(alpha: 0.3)], const [0.0, 0.7, 1.0]),
    );
    c.restore();
    _rimLight(path, oval, w: 12, a: 0.55);
    c.drawOval(oval, _outline);
  }

  void _cheeks() {
    if (pose.blush <= 0.01) return;
    final a = (0.6 * pose.blush).clamp(0.0, 0.9);
    for (final side in [-1.0, 1.0]) {
      final center = OinkGeo.headC + Offset(side * OinkGeo.headR * 0.68, OinkGeo.headR * 0.36);
      c.save();
      c.translate(center.dx, center.dy);
      c.scale(1, 0.62);
      c.drawCircle(
        Offset.zero,
        OinkGeo.headR * 0.24,
        Paint()
          ..shader = Gradient.radial(Offset.zero, OinkGeo.headR * 0.24, [pal.blush.withValues(alpha: a), pal.blush.withValues(alpha: a * 0.55), pal.blush.withValues(alpha: 0)], const [0.0, 0.55, 1.0]),
      );
      c.restore();
    }
  }

  void _eyes() {
    const r = OinkGeo.headR * 0.12;
    final ink = Paint()..color = pal.eye;
    final line = Paint()
      ..color = pal.eye
      ..style = PaintingStyle.stroke
      ..strokeWidth = r * 0.42
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    for (final side in [-1.0, 1.0]) {
      final e = side < 0 ? OinkGeo.eyeL : OinkGeo.eyeR;
      switch (pose.eyes) {
        case OinkEyes.happy:
          final path = Path()
            ..moveTo(e.dx - r, e.dy + r * 0.35)
            ..quadraticBezierTo(e.dx, e.dy - r * 1.3, e.dx + r, e.dy + r * 0.35);
          c.drawPath(path, line);
        case OinkEyes.closed:
          final path = Path()
            ..moveTo(e.dx - r, e.dy - r * 0.1)
            ..quadraticBezierTo(e.dx, e.dy + r * 0.9, e.dx + r, e.dy - r * 0.1);
          c.drawPath(path, line);
          _lashes(e, r, line);
        case OinkEyes.sleepy:
          final path = Path()
            ..moveTo(e.dx - r, e.dy + r * 0.2)
            ..quadraticBezierTo(e.dx, e.dy + r * 0.85, e.dx + r, e.dy + r * 0.2);
          c.drawPath(path, line);
          _lashes(e, r, line);
        case OinkEyes.squint:
          final s = side;
          final path = Path()
            ..moveTo(e.dx - r * 0.8 * s, e.dy - r * 0.7)
            ..lineTo(e.dx + r * 0.6 * s, e.dy)
            ..lineTo(e.dx - r * 0.8 * s, e.dy + r * 0.7);
          c.drawPath(path, line);
        case OinkEyes.open:
        case OinkEyes.surprised:
        case OinkEyes.sad:
          final big = pose.eyes == OinkEyes.surprised ? 1.25 : 1.0;
          final openAmt = (1 - pose.blink).clamp(0.08, 1.0);
          final ec = e + Offset(pose.look.dx * r * 0.32, pose.look.dy * r * 0.24);
          final rect = Rect.fromCenter(center: ec, width: r * 1.8 * big, height: r * 2.2 * big * openAmt);
          c.drawOval(rect, ink);
          if (openAmt > 0.3) {
            // iris glow from below
            c.save();
            c.clipPath(Path()..addOval(rect));
            c.drawCircle(
              ec + Offset(0, r * 0.7 * big * openAmt),
              r * 1.15 * big,
              Paint()..shader = Gradient.radial(ec + Offset(0, r * 0.7 * big * openAmt), r * 1.15 * big, [Color.lerp(pal.eye, const Color(0xFFB07A8E), 0.5)!, pal.eye.withValues(alpha: 0)], const [0.0, 1.0]),
            );
            c.restore();
            c.drawCircle(ec + Offset(-r * 0.3, -r * 0.45 * openAmt * big), r * 0.4 * big, Paint()..color = const Color(0xFFFFFFFF));
            c.drawCircle(ec + Offset(r * 0.38, r * 0.34 * openAmt * big), r * 0.17 * big, Paint()..color = const Color(0xCCFFFFFF));
          }
          if (pose.eyes == OinkEyes.sad) {
            final brow = Path()
              ..moveTo(e.dx - r * 1.1 * side, e.dy - r * 2.35)
              ..quadraticBezierTo(e.dx - r * 0.1 * side, e.dy - r * 2.2, e.dx + r * 1.0 * side, e.dy - r * 1.6);
            c.drawPath(brow, Paint()..color = pal.eye..style = PaintingStyle.stroke..strokeWidth = r * 0.3..strokeCap = StrokeCap.round);
          }
      }
    }
  }

  void _lashes(Offset e, double r, Paint line) {
    final p = Paint()
      ..color = line.color
      ..style = PaintingStyle.stroke
      ..strokeWidth = r * 0.2
      ..strokeCap = StrokeCap.round;
    for (final k in [-0.6, 0.0, 0.6]) {
      c.drawLine(Offset(e.dx + k * r, e.dy + r * 0.5), Offset(e.dx + k * r * 1.25, e.dy + r * 0.9), p);
    }
  }

  void _snout() {
    final sq = pose.snoutSquish.clamp(0.0, 1.0);
    final w = OinkGeo.snoutRx * 2 * (1 + 0.16 * sq);
    final h = OinkGeo.snoutRy * 2 * (1 - 0.18 * sq);
    final centre = OinkGeo.snoutC;
    final rect = Rect.fromCenter(center: centre, width: w, height: h);
    // soft contact shade under the snout
    c.drawOval(
      rect.translate(0, 3.5).inflate(1.5),
      Paint()..color = pal.shade.withValues(alpha: 0.35),
    );
    c.drawOval(rect, Paint()..shader = Gradient.linear(rect.topCenter, rect.bottomCenter, [Color.lerp(pal.snout, pal.light, 0.25)!, pal.snout, pal.snoutShade], const [0.0, 0.5, 1.0]));
    c.drawOval(
      rect,
      Paint()
        ..color = pal.outline
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.6,
    );
    // glossy shine
    c.drawOval(
      Rect.fromCenter(center: centre + Offset(-w * 0.18, -h * 0.27), width: w * 0.3, height: h * 0.16),
      Paint()..color = const Color(0x77FFFFFF),
    );
    for (final side in [-1.0, 1.0]) {
      final n = centre + Offset(side * w * 0.2, h * 0.04);
      final nr = Rect.fromCenter(center: n, width: w * 0.13, height: h * 0.38 * (1 - 0.25 * sq));
      c.drawOval(nr, _fill(pal.nostril));
      c.drawOval(nr.translate(0, nr.height * 0.28).deflate(nr.width * 0.28), Paint()..color = const Color(0x22FFFFFF));
    }
  }

  void _mouth() {
    final m = OinkGeo.mouthC;
    const r = OinkGeo.headR * 0.1;
    final line = Paint()
      ..color = pal.eye
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.6
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    switch (pose.mouth) {
      case OinkMouth.smile:
        final path = Path()
          ..moveTo(m.dx - r * 1.2, m.dy - r * 0.2)
          ..quadraticBezierTo(m.dx - r * 0.6, m.dy + r * 0.7, m.dx, m.dy - r * 0.05)
          ..quadraticBezierTo(m.dx + r * 0.6, m.dy + r * 0.7, m.dx + r * 1.2, m.dy - r * 0.2);
        c.drawPath(path, line);
      case OinkMouth.frown:
        final path = Path()
          ..moveTo(m.dx - r * 0.9, m.dy + r * 0.45)
          ..quadraticBezierTo(m.dx, m.dy - r * 0.35, m.dx + r * 0.9, m.dy + r * 0.45);
        c.drawPath(path, line);
      case OinkMouth.oink:
      case OinkMouth.open:
      case OinkMouth.munch:
        final open = pose.mouth == OinkMouth.munch ? 0.25 + 0.75 * pose.mouthOpen : 0.45 + 0.55 * pose.mouthOpen;
        final rect = Rect.fromCenter(center: m + const Offset(0, r * 0.25), width: r * (pose.mouth == OinkMouth.oink ? 1.5 : 2.1), height: r * 1.7 * open);
        c.drawOval(rect, _fill(const Color(0xFF6B2340)));
        c.save();
        c.clipPath(Path()..addOval(rect));
        c.drawOval(Rect.fromCenter(center: rect.bottomCenter, width: rect.width * 0.8, height: rect.height * 0.8), _fill(const Color(0xFFFF7F9E)));
        c.restore();
    }
  }
}
