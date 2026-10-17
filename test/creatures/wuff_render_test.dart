// Writes build/render/wuff_<coat>.png for every coat so the art can be eyeballed.
// Skipped by default:  flutter test test/creatures/wuff_render_test.dart --run-skipped
import 'dart:io';
import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:mofu_pet/creatures/creature.dart';
import 'package:mofu_pet/creatures/wuff/wuff_art.dart';
import 'package:mofu_pet/creatures/wuff/wuff_catalog.dart';
import 'package:mofu_pet/creatures/wuff/wuff_creature.dart';

const _size = 300.0;
const _art = WuffArt();

WuffCreature _pup() {
  // radius = 0.15 × width × sizeScale: fill the 300px frame.
  final pup = WuffCreature(friendId: 'r', seed: 3)
    ..layout(const Rect.fromLTWH(0, 0, _size, _size), floorY: _size * 0.9, sizeScale: 1.55);
  for (var i = 0; i < 90; i++) {
    pup.update(1 / 60);
  }
  return pup;
}

Future<void> _write(WidgetTester tester, Creature pup, String coat, String file) async {
  final rec = PictureRecorder();
  final canvas = Canvas(rec, const Rect.fromLTWH(0, 0, _size, _size));
  canvas.drawRect(const Rect.fromLTWH(0, 0, _size, _size), Paint()..color = const Color(0xFFFFF3DF));
  _art.paint(canvas, pup, CreatureLook(variant: coat));
  final pic = rec.endRecording();
  await tester.runAsync(() async {
    final img = await pic.toImage(_size.toInt(), _size.toInt());
    final bytes = await img.toByteData(format: ImageByteFormat.png);
    File('build/render/$file').writeAsBytesSync(bytes!.buffer.asUint8List());
  });
}

void main() {
  testWidgets('render every wuff coat and a few poses', (tester) async {
    Directory('build/render').createSync(recursive: true);
    for (final coat in wuffCoats) {
      await _write(tester, _pup(), coat.id, 'wuff_${coat.id}.png');
    }
    for (final pose in ['sit', 'highFive', 'playDead']) {
      final pup = _pup();
      pup.poseTrick(pose, pose == 'playDead' ? 1.2 : 0.7);
      for (var i = 0; i < 20; i++) {
        pup.update(1 / 60);
      }
      await _write(tester, pup, 'golden', 'wuff_pose_$pose.png');
    }
  }, skip: true);
}
