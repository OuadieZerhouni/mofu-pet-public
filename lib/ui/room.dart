import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Time-of-day periods; the room follows local time (SPEC F7).
enum RoomPeriod { morning, day, evening, night }

RoomPeriod periodFor(DateTime t) {
  final h = t.hour;
  if (h >= 6 && h < 11) return RoomPeriod.morning;
  if (h >= 11 && h < 17) return RoomPeriod.day;
  if (h >= 17 && h < 21) return RoomPeriod.evening;
  return RoomPeriod.night;
}

bool isNight(DateTime t) => t.hour >= 22 || t.hour < 6;

class RoomPalette {
  const RoomPalette(this.top, this.bottom, this.floor, this.floorEdge, this.mote, this.ink);
  final Color top;
  final Color bottom;
  final Color floor;
  final Color floorEdge;
  final Color mote;

  /// Text/icon colour that reads on this room.
  final Color ink;

  static RoomPalette of(RoomPeriod p) => switch (p) {
        RoomPeriod.morning => const RoomPalette(
            Color(0xFFFFE7D6), Color(0xFFFFF6EC), Color(0xFFFFE1C7), Color(0xFFFFD0AE), Color(0xFFFFFFFF), Color(0xFF5A3F4C)),
        RoomPeriod.day => const RoomPalette(
            Color(0xFFD9EEFF), Color(0xFFF2FAFF), Color(0xFFDDF3E4), Color(0xFFC3E8CF), Color(0xFFFFFFFF), Color(0xFF3F4A5C)),
        RoomPeriod.evening => const RoomPalette(
            Color(0xFFE9D9FF), Color(0xFFFFE6EE), Color(0xFFF7D7E6), Color(0xFFEDC1D7), Color(0xFFFFF4FA), Color(0xFF55405E)),
        RoomPeriod.night => const RoomPalette(
            Color(0xFF2B2A5C), Color(0xFF4A3F7A), Color(0xFF3B356B), Color(0xFF332D5E), Color(0xFFBFB6FF), Color(0xFFF2EEFF)),
      };
}

/// The backdrop: a soft gradient sky, a rounded floor, drifting fluff motes,
/// and a moon with stars at night. Motes are deterministic in time so the
/// painter needs no state of its own.
class RoomPainter extends CustomPainter {
  RoomPainter({required this.period, required this.floorY, required this.time, super.repaint});

  final RoomPeriod period;
  final double floorY;
  final ValueGetter<double> time;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;
    final pal = RoomPalette.of(period);
    final rect = Offset.zero & size;
    canvas.drawRect(
      rect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [pal.top, pal.bottom],
        ).createShader(rect),
    );

    final t = time();
    if (period == RoomPeriod.night) {
      final rng = math.Random(11);
      for (var i = 0; i < 46; i++) {
        final p = Offset(rng.nextDouble() * size.width, rng.nextDouble() * floorY * 0.85);
        final tw = 0.5 + 0.5 * math.sin(t * (0.8 + rng.nextDouble()) + i);
        canvas.drawCircle(p, 0.8 + rng.nextDouble() * 1.4, Paint()..color = Colors.white.withValues(alpha: 0.35 + 0.5 * tw));
      }
      final moon = Offset(size.width * 0.80, size.height * 0.16);
      canvas.drawCircle(moon, 26, Paint()..color = const Color(0x22FFF6C9)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18));
      canvas.drawCircle(moon, 20, Paint()..color = const Color(0xFFFFF6C9));
      canvas.drawCircle(moon + const Offset(8, -5), 17, Paint()..color = pal.top);
    } else {
      final sun = Offset(size.width * 0.82, size.height * 0.14);
      final glow = period == RoomPeriod.evening ? const Color(0x55FFB3C7) : const Color(0x55FFE9A8);
      canvas.drawCircle(sun, 70, Paint()..color = glow..maskFilter = const MaskFilter.blur(BlurStyle.normal, 40));
    }

    // Floor: a wide soft hill so Mofu stands *in* the room, not on a line.
    final floor = Path()
      ..moveTo(0, floorY + 18)
      ..quadraticBezierTo(size.width / 2, floorY - 26, size.width, floorY + 18)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(
      floor,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [pal.floor, pal.floorEdge],
        ).createShader(Rect.fromLTWH(0, floorY - 26, size.width, size.height - floorY + 26)),
    );

    // Drifting fluff motes.
    final rng = math.Random(3);
    for (var i = 0; i < 14; i++) {
      final speed = 6 + rng.nextDouble() * 10;
      final x = (rng.nextDouble() * size.width + math.sin(t * 0.3 + i) * 24) % size.width;
      final span = floorY + 40;
      final y = span - ((rng.nextDouble() * span + t * speed) % span);
      final r = 2 + rng.nextDouble() * 3.5;
      canvas.drawCircle(
        Offset(x, y),
        r,
        Paint()
          ..color = pal.mote.withValues(alpha: 0.55)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, r * 0.6),
      );
    }
  }

  @override
  bool shouldRepaint(RoomPainter old) => old.period != period || old.floorY != floorY;
}
