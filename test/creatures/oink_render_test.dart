// Dev tool, skipped by default: renders the piglet in every tint (and a few
// poses) to PNG for looking at.
//
//   flutter test test/creatures/oink_render_test.dart --run-skipped
//
// Output: build/render/oink_<tint>.png and oink_pose_<name>.png (300x300).
// Uses tester.runAsync because Picture.toImage hangs inside the widget
// tester's fake-async zone.
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter_test/flutter_test.dart';
import 'package:mofu_pet/creatures/creature.dart';
import 'package:mofu_pet/creatures/oink/oink_art.dart';
import 'package:mofu_pet/creatures/oink/oink_catalog.dart';
import 'package:mofu_pet/creatures/oink/oink_creature.dart';

const _size = 300.0;

OinkCreature _pig() {
  final c = OinkCreature(friendId: 'r', seed: 9)
    ..reduceMotion = true
    ..pinned = true
    ..layout(const ui.Rect.fromLTWH(0, 0, _size, _size), floorY: _size - 18, sizeScale: 1.6);
  for (var i = 0; i < 90; i++) {
    c.update(1 / 60);
  }
  c.drainEvents();
  return c;
}

Future<void> _dump(String name, void Function(ui.Canvas) paint) async {
  final rec = ui.PictureRecorder();
  final canvas = ui.Canvas(rec);
  canvas.drawRect(const ui.Rect.fromLTWH(0, 0, _size, _size), ui.Paint()..color = const ui.Color(0xFFFFF1E6));
  paint(canvas);
  final img = await rec.endRecording().toImage(_size.toInt(), _size.toInt());
  final bytes = await img.toByteData(format: ui.ImageByteFormat.png);
  final f = File('build/render/$name.png')..createSync(recursive: true);
  f.writeAsBytesSync(bytes!.buffer.asUint8List());
}

void main() {
  testWidgets('render oink tints and poses', (tester) async {
    await tester.runAsync(() async {
      for (final t in oinkTints) {
        final c = _pig();
        await _dump('oink_${t.id}', (cv) => const OinkArt().paint(cv, c, CreatureLook(variant: t.id)));
      }

      Future<void> pose(String name, void Function(OinkCreature) setup, {String tint = 'classic', int frames = 20}) async {
        final c = _pig();
        setup(c);
        for (var i = 0; i < frames; i++) {
          c.update(1 / 60);
        }
        await _dump('oink_pose_$name', (cv) => const OinkArt().paint(cv, c, CreatureLook(variant: tint)));
      }

      void tap(OinkCreature c, ui.Offset q) {
        final p = c.designToRoom(q);
        c.pointerDown(1, p);
        c.update(0.05);
        c.pointerUp(1, p);
      }

      await pose('head_happy', (c) => tap(c, OinkGeo.headC + const ui.Offset(0, -30)), frames: 18);
      await pose('belly_giggle', (c) => tap(c, OinkGeo.bodyC + const ui.Offset(0, 40)), tint: 'peach', frames: 12);
      await pose('snout_oink', (c) => tap(c, OinkGeo.snoutC), tint: 'spotted', frames: 8);
      await pose('ear_flop', (c) => tap(c, OinkGeo.earHitL), tint: 'lavender', frames: 14);
      await pose('tail_spin', (c) => tap(c, OinkGeo.tailHit), tint: 'golden', frames: 20);
      await pose('sleeping', (c) => c.sleep(), tint: 'snow', frames: 200);
      await pose('eating', (c) => c.eat(favorite: false), tint: 'chocolate', frames: 24);
      await pose('refuse', (c) => c.refuseFull(), tint: 'mint', frames: 16);
      await pose('hover_snack', (c) => c.setSnackHover(true, c.mouth), frames: 30);
    });
  }, skip: true);
}
