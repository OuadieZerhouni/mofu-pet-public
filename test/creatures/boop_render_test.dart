// Renders each Boop to build/render/boop_<variant>.png (300x300, cream
// background) so the art can be inspected by eye.
// Run: flutter test test/creatures/boop_render_test.dart --run-skipped
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter_test/flutter_test.dart';
import 'package:mofu_pet/creatures/boop/boop_art.dart';
import 'package:mofu_pet/creatures/boop/boop_catalog.dart';
import 'package:mofu_pet/creatures/boop/boop_creature.dart';
import 'package:mofu_pet/creatures/creature.dart';

void main() {
  testWidgets('render every Boop to a PNG', (tester) async {
    const size = 300.0;
    const art = BoopArt();
    Directory('build/render').createSync(recursive: true);
    for (final v in boopVariants) {
      // A 400-wide room gives radius 52; crop around the creature and scale
      // up so the detail is visible.
      final c = BoopCreature(friendId: 'r', seed: 1, variant: v.id)..layout(const ui.Rect.fromLTWH(0, 0, 400, 800), floorY: 620);
      for (var i = 0; i < 60; i++) {
        c.update(1 / 60);
      }
      c.pointerDown(1, c.nosePos);
      c.pointerUp(1, c.nosePos);
      for (var i = 0; i < 30; i++) {
        c.update(1 / 60);
      }
      final recorder = ui.PictureRecorder();
      final canvas = ui.Canvas(recorder, const ui.Rect.fromLTWH(0, 0, size, size));
      canvas.drawRect(const ui.Rect.fromLTWH(0, 0, size, size), ui.Paint()..color = const ui.Color(0xFFFFF6E8));
      canvas.save();
      canvas.scale(size / 190);
      canvas.translate(-(c.position.dx - 95), -(c.position.dy - 112));
      art.paint(canvas, c, CreatureLook(variant: v.id));
      canvas.restore();
      final picture = recorder.endRecording();
      await tester.runAsync(() async {
        final image = await picture.toImage(size.toInt(), size.toInt());
        final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
        File('build/render/boop_${v.id}.png').writeAsBytesSync(bytes!.buffer.asUint8List());
      });
    }
  }, skip: true);
}
