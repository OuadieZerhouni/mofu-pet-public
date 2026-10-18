import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../creatures/creature.dart';
import '../../world/fx.dart';
import '../theme.dart';

final Paint _p = Paint()..isAntiAlias = true;

/// Paints one effect at [now] (see `world/fx.dart` for the motion).
void paintFx(Canvas canvas, Fx fx, double now) {
  final parts = particlesOf(fx, now);
  if (parts.isEmpty) return;
  switch (fx.kind) {
    case FxKind.dust:
      for (final q in parts) {
        _p
          ..color = const Color(0xFFF3E6D6).withValues(alpha: q.alpha)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);
        canvas.drawCircle(q.pos, q.size, _p);
      }
      _p.maskFilter = null;
    case FxKind.burst:
      for (final q in parts) {
        if (q.index.isEven) {
          _heart(canvas, q.pos, q.size, House.rose.withValues(alpha: q.alpha), q.angle);
        } else {
          _star(canvas, q.pos, q.size, House.star.withValues(alpha: q.alpha), q.angle);
        }
      }
    case FxKind.ring:
      final q = parts.first;
      _p
        ..style = PaintingStyle.stroke
        ..strokeWidth = 6 * (0.4 + q.alpha)
        ..color = (fx.color ?? const Color(0xFFFFE7A8)).withValues(alpha: q.alpha)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
      canvas.drawCircle(q.pos, q.size, _p);
      _p
        ..style = PaintingStyle.fill
        ..maskFilter = null;
    case FxKind.confetti:
      const colors = [Color(0xFFC2386A), Color(0xFFF2B632), Color(0xFF7FC6E8), Color(0xFF9FD18B), Color(0xFFB79BE6)];
      for (final q in parts) {
        canvas.save();
        canvas.translate(q.pos.dx, q.pos.dy);
        canvas.rotate(q.angle);
        // A paper strip turning in the air: its width flips with the spin.
        final w = q.size * (0.35 + 0.65 * math.cos(q.angle * 1.7).abs());
        _p.color = colors[q.index % colors.length].withValues(alpha: q.alpha);
        canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: Offset.zero, width: w, height: q.size * 1.6), const Radius.circular(1.5)), _p);
        canvas.restore();
      }
    case FxKind.pop:
      for (final q in parts) {
        _p
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.2
          ..color = Colors.white.withValues(alpha: q.alpha);
        canvas.drawCircle(q.pos, q.size, _p);
        _p.style = PaintingStyle.fill;
      }
  }
}

void _heart(Canvas canvas, Offset c, double s, Color color, double angle) {
  canvas.save();
  canvas.translate(c.dx, c.dy);
  canvas.rotate(angle);
  final path = Path()
    ..moveTo(0, s * 0.35)
    ..cubicTo(-s * 1.1, -s * 0.35, -s * 0.45, -s * 1.05, 0, -s * 0.45)
    ..cubicTo(s * 0.45, -s * 1.05, s * 1.1, -s * 0.35, 0, s * 0.35)
    ..close();
  _p.color = color;
  canvas.drawPath(path, _p);
  canvas.restore();
}

void _star(Canvas canvas, Offset c, double s, Color color, double angle) {
  final path = Path();
  for (var i = 0; i < 10; i++) {
    final r = i.isEven ? s : s * 0.45;
    final a = angle - math.pi / 2 + i * math.pi / 5;
    final p = c + Offset(math.cos(a), math.sin(a)) * r;
    i == 0 ? path.moveTo(p.dx, p.dy) : path.lineTo(p.dx, p.dy);
  }
  _p.color = color;
  canvas.drawPath(path..close(), _p);
}

/// Applies an entrance pose around [foot]; returns true when a layer was
/// saved (the caller restores after painting the friend).
bool applyEntrance(Canvas canvas, EntrancePose pose, Offset foot) {
  if (identical(pose, EntrancePose.rest)) return false;
  if (pose.alpha < 1) {
    canvas.saveLayer(null, Paint()..color = Colors.white.withValues(alpha: pose.alpha));
  } else {
    canvas.save();
  }
  canvas.translate(foot.dx + pose.dx, foot.dy + pose.dy);
  canvas.scale(pose.sx, pose.sy);
  canvas.translate(-foot.dx, -foot.dy);
  return true;
}


/// A soft floor shadow under [c], [k] = 0 (tiny, far above) .. 1 (standing).
void paintFloorShadow(Canvas canvas, Creature c, double k) {
  final t = k.clamp(0.0, 1.0);
  final w = c.radius * (0.7 + 0.9 * t);
  _p
    ..color = const Color(0xFF3A2A2E).withValues(alpha: 0.05 + 0.13 * t)
    ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
  canvas.drawOval(Rect.fromCenter(center: c.footPoint + const Offset(0, 2), width: w * 2, height: w * 0.38), _p);
  _p.maskFilter = null;
}
