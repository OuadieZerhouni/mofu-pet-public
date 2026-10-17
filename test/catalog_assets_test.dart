import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mofu_pet/audio/sound_bank.dart';
import 'package:mofu_pet/creatures/creature.dart';
import 'package:mofu_pet/l10n/app_localizations.dart';
import 'package:mofu_pet/model/catalog.dart';
import 'package:mofu_pet/model/house_store.dart';
import 'package:mofu_pet/model/wardrobe.dart';
import 'package:mofu_pet/ui/house/house_text.dart';
import 'package:mofu_pet/ui/names.dart';
import 'package:mofu_pet/world/creature_factory.dart';

/// Data integrity: every id the app can show has a name in every locale,
/// every sound the bank promises exists on disk, and every unlock is
/// reachable.
void main() {
  test('every sound in the bank exists on disk in a declared asset folder', () {
    final pubspec = File('pubspec.yaml').readAsStringSync();
    for (final e in SoundBank.all.entries) {
      expect(File(e.value.asset).existsSync(), isTrue, reason: '${e.key} → ${e.value.asset}');
      final dir = e.value.asset.substring(0, e.value.asset.lastIndexOf('/') + 1);
      expect(pubspec, contains('- $dir'), reason: 'asset folder $dir declared');
      if (e.value.loop) {
        expect(e.value.asset.endsWith('.mp3'), isFalse, reason: '${e.key}: loops must be gapless (wav/ogg)');
      }
    }
  });

  test('every room, snack, coat and accessory has a name in every locale', () async {
    for (final locale in AppLocalizations.supportedLocales) {
      final l = await AppLocalizations.delegate.load(locale);
      for (final r in Room.values) {
        expect(l.roomName(r), isNotEmpty);
      }
      for (final s in Species.values) {
        for (final snack in snacksFor(s)) {
          expect(l.snackName(snack), isNot(snack), reason: '${locale.languageCode} snack $snack');
        }
      }
      for (final item in wardrobeItems) {
        expect(l.accessoryName(item.id), isNot(item.id), reason: '${locale.languageCode} accessory ${item.id}');
      }
      for (final c in Catalog.furColors) {
        expect(l.colorName(c.id), isNot(c.id));
      }
      for (final r in Catalog.reactions) {
        final (name, hint) = l.reaction(r.id);
        expect(name, isNot(r.id), reason: '${locale.languageCode} reaction ${r.id}');
        expect(hint, isNotEmpty);
      }
    }
  });

  test('the hatch schedule covers every species and every Boop variant once', () {
    final schedule = HouseStore.eggSchedule();
    expect(schedule.map((e) => e.species).toSet(), {Species.oink, Species.wuff, Species.boop});
    final boops = schedule.where((e) => e.species == Species.boop).map((e) => e.variant).toList();
    expect(boops.toSet(), variantsFor(Species.boop).toSet(), reason: 'hatch order matches the Boop catalogue');
    for (var i = 1; i < schedule.length; i++) {
      expect(schedule[i].stars, greaterThan(schedule[i - 1].stars));
    }
  });

  test('wardrobe unlocks are reachable', () {
    for (final item in wardrobeItems) {
      switch (item.rule.kind) {
        case WearRuleKind.level:
          expect(item.rule.amount, inInclusiveRange(1, 10));
        case WearRuleKind.stars:
          expect(item.rule.amount, lessThanOrEqualTo(HouseStore.eggSchedule().last.stars + 200));
        case WearRuleKind.seasonal:
          expect(['halloween', 'winter'], contains(item.rule.season));
        case WearRuleKind.start:
          break;
      }
    }
    for (final s in Species.values) {
      for (final v in variantsFor(s)) {
        expect(variantLevel(s, v), lessThanOrEqualTo(10), reason: '$s $v reachable by level 10');
      }
    }
  });
}
