import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mofu_pet/core/sfx.dart';
import 'package:mofu_pet/l10n/app_localizations.dart';
import 'package:mofu_pet/model/catalog.dart';
import 'package:mofu_pet/ui/names.dart';

/// Data integrity: every id the app can show has a name in every locale,
/// every sound the simulation asks for exists on disk, and every unlock rule
/// is reachable.
void main() {
  test('24 unique journal reactions', () {
    final ids = Catalog.reactions.map((r) => r.id).toList();
    expect(ids.length, 24);
    expect(ids.toSet().length, 24);
  });

  // F5-c1: 10 colours, 10 year-round accessories (plus "none" and the seasonal extras).
  test('10 fur colours and 10 accessories', () {
    expect(Catalog.furColors.map((c) => c.id).toSet().length, 10);
    final yearRound = Catalog.accessories.where((a) => a.id != 'none' && a.rule.kind != UnlockKind.seasonal);
    expect(yearRound.map((a) => a.id).toSet().length, 10);
  });

  test('unlock rules are reachable', () {
    for (final r in [...Catalog.furColors.map((c) => c.rule), ...Catalog.accessories.map((a) => a.rule)]) {
      switch (r.kind) {
        case UnlockKind.fluff:
          expect(r.amount, inInclusiveRange(1, 100));
        case UnlockKind.journal:
          expect(r.amount, lessThanOrEqualTo(Catalog.reactions.length));
        case UnlockKind.seasonal:
          expect(['halloween', 'winter'], contains(r.seasonId));
        default:
          expect(r.amount, greaterThanOrEqualTo(0));
      }
    }
  });

  test('every catalog id has a real name in every locale', () async {
    for (final locale in AppLocalizations.supportedLocales) {
      final l = await AppLocalizations.delegate.load(locale);
      for (final c in Catalog.furColors) {
        expect(l.colorName(c.id), isNot(c.id), reason: '${locale.languageCode} colour ${c.id}');
      }
      for (final a in Catalog.accessories) {
        expect(l.accessoryName(a.id), isNot(a.id), reason: '${locale.languageCode} accessory ${a.id}');
      }
      for (final s in Catalog.snacks) {
        expect(l.snackName(s.id), isNot(s.id), reason: '${locale.languageCode} snack ${s.id}');
      }
      for (final r in Catalog.reactions) {
        final (name, hint) = l.reaction(r.id);
        expect(name, isNot(r.id), reason: '${locale.languageCode} reaction ${r.id}');
        expect(hint, isNotEmpty);
      }
    }
  });

  test('every sound the sim emits is declared and on disk', () {
    final src = File('lib/sim/mofu_sim.dart').readAsStringSync();
    final used = {
      for (final m in RegExp(r"SimEventType\.(?:sound|loopStart|loopStop), '(\w+)'").allMatches(src)) m.group(1)!,
    };
    expect(used, isNotEmpty);
    final declared = {...Sfx.oneShots, ...Sfx.loops};
    for (final id in used) {
      expect(declared, contains(id), reason: 'sim plays "$id" but Sfx does not load it');
    }
    // Sounds played directly by the UI.
    for (final id in ['unlock', 'hatch', 'sparkle']) {
      expect(declared, contains(id));
    }
    for (final id in Sfx.oneShots) {
      expect(File('assets/sounds/$id.mp3').existsSync(), isTrue, reason: 'missing assets/sounds/$id.mp3');
    }
    for (final id in Sfx.loops) {
      expect(File('assets/sounds/$id.wav').existsSync(), isTrue, reason: 'missing assets/sounds/$id.wav');
    }
  });

  test('every Arabic plural message carries all six categories', () {
    final arb = File('lib/l10n/app_ar.arb').readAsStringSync();
    for (final m in RegExp(r'"(\w+)": "(\{count, plural,[^"]*)"').allMatches(arb)) {
      for (final cat in ['zero{', 'one{', 'two{', 'few{', 'many{', 'other{']) {
        expect(m.group(2), contains(cat), reason: '${m.group(1)} lacks $cat');
      }
    }
  });

  test('locale list in the app matches the manifest', () {
    expect(
      AppLocalizations.supportedLocales.map((l) => l.languageCode).toSet(),
      {'en', 'ja', 'de', 'pt', 'es', 'fr', 'ar'},
    );
    expect(const Locale('ar').languageCode, 'ar');
  });
}
