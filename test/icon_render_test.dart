// Dev tool, skipped by default: renders the 1024×1024 App Store icon from
// the app's own painter, so the icon is always the creature users meet.
//
// Not the shipped icon: since 2026-10-18 the App Store icon is the night house drawn by
// test/icon_flagship_test.dart (master icon/icon-1024.png). Running this + make_icons.py replaces it.
//
//   flutter test test/icon_render_test.dart --run-skipped
//   python tools/icon/make_icons.py
//
// Output: build/icon/icon_1024.png (opaque — App Store rejects alpha).
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mofu_pet/model/catalog.dart';
import 'package:mofu_pet/sim/mofu_sim.dart';
import 'package:mofu_pet/ui/mofu_painter.dart';

void main() {
  const variants = [
    // name, fur, bg top, bg bottom, expression
    ('icon_1024', 'peach', Color(0xFFBFE0FF), Color(0xFFEAF5FF), Expr.idle),
    ('variant_cream_lilac', 'cream', Color(0xFFD9CCFF), Color(0xFFF3EDFF), Expr.idle),
    ('variant_sakura_mint', 'sakura', Color(0xFFBFEBD6), Color(0xFFEFFBF5), Expr.happy),
    ('variant_cream_pink', 'cream', Color(0xFFFFD6E6), Color(0xFFFFEFE2), Expr.happy),
  ];
  testWidgets('render app icon', (tester) async {
    await tester.runAsync(() async {
     for (final v in variants) {
      const s = 1024.0;
      final rec = ui.PictureRecorder();
      final canvas = Canvas(rec);
      const rect = Rect.fromLTWH(0, 0, s, s);
      canvas.drawRect(
        rect,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [v.$3, v.$4],
          ).createShader(rect),
      );
      // A soft halo behind the creature lifts it off the background.
      canvas.drawCircle(const Offset(s / 2, s * 0.53), s * 0.42,
          Paint()
            ..color = Colors.white.withValues(alpha: 0.55)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 60));
      final sim = MofuSim(seed: 5, reduceMotion: true)
        ..fluff = 0.55
        ..layout(const Size(s, s), top: 0, floor: s);
      sim.baseRadius = s * 0.27;
      sim.pos = const Offset(s / 2, s * 0.55);
      sim.expr = v.$5;
      paintMofu(canvas, sim, Catalog.color(v.$2), 'none', shadow: false);
      final img = await rec.endRecording().toImage(s.toInt(), s.toInt());
      final bytes = await img.toByteData(format: ui.ImageByteFormat.png);
      File('build/icon/${v.$1}.png')
        ..createSync(recursive: true)
        ..writeAsBytesSync(bytes!.buffer.asUint8List());
     }
    });
  }, skip: true);
}
