import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:mofu_pet/creatures/creature.dart';
import 'package:mofu_pet/creatures/mofu/mofu_art.dart';
import 'package:mofu_pet/creatures/mofu/mofu_creature.dart';
import 'package:mofu_pet/model/catalog.dart';

import 'contract.dart';

void main() {
  runCreatureContract('mofu', () => MofuCreature(friendId: 'm1', seed: 3));

  MofuCreature placed() {
    final c = MofuCreature(friendId: 'm1', seed: 3)..layout(const Rect.fromLTWH(0, 0, 400, 800), floorY: 620);
    for (var i = 0; i < 60; i++) {
      c.update(1 / 60);
    }
    return c;
  }

  test('event ids are species-scoped', () {
    final c = placed()..drainEvents();
    c.pointerDown(1, c.position);
    c.update(0.05);
    c.pointerUp(1, c.position);
    c.update(1 / 60);
    final evs = c.drainEvents();
    final sounds = evs.where((e) => e.type == CreatureEventType.sound);
    expect(sounds, isNotEmpty);
    expect(sounds.every((e) => e.id.startsWith('mofu.')), isTrue);
  });

  test('the dryer grows fluff', () {
    final c = placed()..pinned = true;
    c.drainEvents();
    var fluff = 0.0;
    for (var i = 0; i < 240; i++) {
      c.groom(c.position + Offset(0, -c.radius * 0.5), 800, tool: 'dryer');
      c.update(1 / 60);
      for (final e in c.drainEvents()) {
        if (e.type == CreatureEventType.progress && e.id == 'fluff') fluff += e.value;
      }
    }
    expect(fluff, greaterThan(0.5));
  });

  test('a friend landing on Mofu wakes it and it reacts', () {
    final c = placed()..sleep();
    c.update(1 / 60);
    expect(c.asleep, isTrue);
    c.drainEvents();
    c.react(SocialCue.landedOnMe, from: c.position - const Offset(0, 80));
    c.update(1 / 60);
    expect(c.asleep, isFalse);
    expect(c.drainEvents().any((e) => e.id == 'mofu.bumped'), isTrue);
  });

  test('every fur colour paints', () {
    final c = placed();
    for (final f in Catalog.furColors) {
      final rec = PictureRecorder();
      const MofuArt().paint(Canvas(rec), c, CreatureLook(variant: f.id, accessories: const ['bow']));
      rec.endRecording();
    }
  });
}
