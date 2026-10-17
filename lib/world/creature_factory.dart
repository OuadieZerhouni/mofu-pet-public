/// Species → simulation and painter, and the per-species data the rooms
/// need (snack menus, variants), in one place.
library;

import '../creatures/boop/boop_art.dart';
import '../creatures/boop/boop_catalog.dart';
import '../creatures/boop/boop_creature.dart';
import '../creatures/creature.dart';
import '../creatures/mofu/mofu_art.dart';
import '../creatures/mofu/mofu_creature.dart';
import '../creatures/oink/oink_art.dart';
import '../creatures/oink/oink_catalog.dart';
import '../creatures/oink/oink_creature.dart';
import '../creatures/wuff/wuff_art.dart';
import '../creatures/wuff/wuff_catalog.dart';
import '../creatures/wuff/wuff_creature.dart';
import '../model/catalog.dart';
import '../model/house_store.dart';

/// A stable seed per friend so a friend's fur and quirks never change.
int seedFor(String friendId) {
  var h = 0x811C9DC5;
  for (final c in friendId.codeUnits) {
    h = ((h ^ c) * 0x01000193) & 0x7FFFFFFF;
  }
  return h;
}

Creature makeCreature(Friend f) {
  final seed = seedFor(f.id);
  return switch (f.species) {
    Species.mofu => MofuCreature(friendId: f.id, seed: seed)..fluff = f.fluff / 100,
    Species.oink => OinkCreature(friendId: f.id, seed: seed),
    Species.wuff => WuffCreature(friendId: f.id, seed: seed),
    Species.boop => BoopCreature(friendId: f.id, seed: seed, variant: f.variant),
  };
}

CreatureArt artFor(Species s) => switch (s) {
      Species.mofu => const MofuArt(),
      Species.oink => const OinkArt(),
      Species.wuff => const WuffArt(),
      Species.boop => const BoopArt(),
    };

/// Snack ids a species eats (order = tray order). Names are localised by id.
List<String> snacksFor(Species s) => switch (s) {
      Species.mofu => Catalog.snacks.map((x) => x.id).toList(),
      Species.oink => oinkSnacks.map((x) => x.id).toList(),
      Species.wuff => const ['bone', 'bacon', 'cheese', 'carrot', 'cupcake', 'cookie'],
      Species.boop => const ['blueberry', 'cherry', 'grape', 'peach', 'strawberry', 'candy'],
    };

/// Each friend's secret favourite snack: stable per name, varies across names.
String favoriteSnack(Friend f) {
  final menu = snacksFor(f.species);
  var h = 0x811C9DC5;
  for (final c in f.name.trim().toLowerCase().codeUnits) {
    h = ((h ^ c) * 0x01000193) & 0x7FFFFFFF;
  }
  return menu[h % menu.length];
}

/// Colour / coat variants per species, in wardrobe order.
List<String> variantsFor(Species s) => switch (s) {
      Species.mofu => Catalog.furColors.map((c) => c.id).toList(),
      Species.oink => oinkTints.map((t) => t.id).toList(),
      Species.wuff => wuffCoats.map((c) => c.id).toList(),
      Species.boop => boopVariants.map((v) => v.id).toList(),
    };
