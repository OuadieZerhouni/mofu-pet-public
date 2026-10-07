// SPEC F1-c4: the frame budget, measured where a test can measure it.
//
// Times one home-screen frame of UI-thread work — sim.update + recording every
// fur strand at full fluff — and asserts the median stays under 8 ms. The test
// runs in debug/JIT, which is slower than a release build, so passing here is
// conservative. Rasterisation is not timed: flutter_test only has Skia's CPU
// rasteriser (~10 ms for this frame incl. pixel readback on an M-series Mac),
// which says nothing about the iPhone GPU. On-device smoothness (60 fps) is
// /test-drive's and GATE-DEVICE-QA's to observe.
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mofu_pet/model/catalog.dart';
import 'package:mofu_pet/sim/mofu_sim.dart';
import 'package:mofu_pet/ui/mofu_painter.dart';

void main() {
  test('a full-fluff frame (all strands) records in under 8 ms', () {
    const room = Size(440, 956);
    final sim = MofuSim(seed: 5)
      ..fluff = 1
      ..layout(room, top: 140, floor: 800);
    sim.shake(); // messy fur takes the jitter path too
    expect(sim.strands.length, greaterThanOrEqualTo(600));
    final color = Catalog.color('cream');

    double frameMs() {
      final sw = Stopwatch()..start();
      sim.update(1 / 60);
      final rec = ui.PictureRecorder();
      paintMofu(Canvas(rec), sim, color, 'crown');
      rec.endRecording().dispose();
      return sw.elapsedMicroseconds / 1000;
    }

    for (var i = 0; i < 30; i++) {
      frameMs(); // warm up the JIT
    }
    final samples = [for (var i = 0; i < 120; i++) frameMs()]..sort();
    final median = samples[samples.length ~/ 2];
    // ignore: avoid_print
    print(
      'frame median ${median.toStringAsFixed(2)} ms, p90 ${samples[(samples.length * 0.9).floor()].toStringAsFixed(2)} ms, ${sim.strands.length} strands',
    );
    expect(median, lessThan(8));
  });
}
