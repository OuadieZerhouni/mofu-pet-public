// Dev tool, skipped by default: renders Mofu poses to PNG for looking at.
//
//   flutter test test/render_dump_test.dart --run-skipped
//
// Output: build/render/*.png. Uses tester.runAsync because Picture.toImage
// hangs inside the widget tester's fake-async zone (factory TRAPS.md).
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mofu_pet/model/catalog.dart';
import 'package:mofu_pet/sim/mofu_sim.dart';
import 'package:mofu_pet/ui/mofu_painter.dart';

Future<void> _dump(String name, Size size, void Function(Canvas) paint) async {
  final rec = ui.PictureRecorder();
  final canvas = Canvas(rec);
  canvas.drawRect(Offset.zero & size, Paint()..color = const Color(0xFFFFF1E6));
  paint(canvas);
  final img = await rec.endRecording().toImage(size.width.toInt(), size.height.toInt());
  final bytes = await img.toByteData(format: ui.ImageByteFormat.png);
  final f = File('build/render/$name.png')..createSync(recursive: true);
  f.writeAsBytesSync(bytes!.buffer.asUint8List());
}

MofuSim posed({double fluff = 0.5, Expr expr = Expr.idle, double size = 360}) {
  final sim = MofuSim(seed: 5, reduceMotion: true)
    ..fluff = fluff
    ..layout(Size(size, size), top: 0, floor: size * 0.92);
  sim.expr = expr;
  return sim;
}

void main() {
  testWidgets('render poses', (tester) async {
    await tester.runAsync(() async {
      for (final f in [0.0, 0.08, 0.5, 1.0]) {
        await _dump('fluff_${(f * 100).round()}', const Size(360, 360), (c) {
          paintMofu(c, posed(fluff: f, expr: Expr.happy), Catalog.color('cream'), 'none');
        });
      }
      for (final col in Catalog.furColors) {
        await _dump('color_${col.id}', const Size(240, 240), (c) {
          paintMofu(c, posed(fluff: 0.6, size: 240), col, 'none');
        });
      }
      for (final a in Catalog.accessories) {
        await _dump('acc_${a.id}', const Size(240, 240), (c) {
          paintMofu(c, posed(fluff: 0.6, size: 240), Catalog.color('peach'), a.id);
        });
      }
      for (final e in Expr.values) {
        await _dump('expr_${e.name}', const Size(240, 240), (c) {
          paintMofu(c, posed(fluff: 0.5, expr: e, size: 240), Catalog.color('sakura'), 'none');
        });
      }
    });
  }, skip: true);
}
