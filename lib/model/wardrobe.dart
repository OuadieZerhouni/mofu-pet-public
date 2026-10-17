/// Shared accessories every friend can wear, and how each unlocks. All free,
/// earned by care: a friend's own friendship level, the household's lifetime
/// stars, or a season (remote config opens the season window).
library;

import '../creatures/creature.dart';
import '../world/creature_factory.dart';
import 'house_store.dart';

enum WearRuleKind { start, level, stars, seasonal }

class WearRule {
  const WearRule(this.kind, [this.amount = 0, this.season = '']);
  final WearRuleKind kind;
  final int amount;
  final String season;
}

class WearItem {
  const WearItem(this.id, this.rule);
  final String id;
  final WearRule rule;
  AccessorySlot get slot => slotOf(id);
}

const wardrobeItems = <WearItem>[
  WearItem('bow', WearRule(WearRuleKind.start)),
  WearItem('scarf', WearRule(WearRuleKind.start)),
  WearItem('sprout', WearRule(WearRuleKind.level, 2)),
  WearItem('bandana', WearRule(WearRuleKind.level, 2)),
  WearItem('flower', WearRule(WearRuleKind.level, 3)),
  WearItem('beanie', WearRule(WearRuleKind.level, 4)),
  WearItem('bell', WearRule(WearRuleKind.level, 4)),
  WearItem('party', WearRule(WearRuleKind.level, 5)),
  WearItem('bowtie', WearRule(WearRuleKind.level, 5)),
  WearItem('headphones', WearRule(WearRuleKind.level, 6)),
  WearItem('glasses', WearRule(WearRuleKind.level, 7)),
  WearItem('starclip', WearRule(WearRuleKind.stars, 120)),
  WearItem('chef', WearRule(WearRuleKind.stars, 250)),
  WearItem('crown', WearRule(WearRuleKind.level, 10)),
  WearItem('witch', WearRule(WearRuleKind.seasonal, 0, 'halloween')),
  WearItem('santa', WearRule(WearRuleKind.seasonal, 0, 'winter')),
];

bool itemUnlocked(HouseStore store, Friend f, WearItem item) => switch (item.rule.kind) {
      WearRuleKind.start => true,
      WearRuleKind.level => f.level >= item.rule.amount,
      WearRuleKind.stars => store.stars >= item.rule.amount,
      WearRuleKind.seasonal => store.seasonalEarned.contains(item.rule.season),
    };

/// Coats this friend can switch between. A Boop's variant is who it is (each
/// critter hatches separately), so Boops keep their own look.
List<String> coatOptions(Friend f) => f.species == Species.boop ? [f.variant] : variantsFor(f.species);

/// The first two coats of each species are free; the rest open one per
/// friendship level (coat index n needs level n, capped at 10).
int variantLevel(Species s, String variant) {
  if (s == Species.boop) return 0;
  final i = variantsFor(s).indexOf(variant);
  return i < 2 ? 0 : (i > 10 ? 10 : i);
}

bool variantUnlocked(Friend f, String variant) => f.level >= variantLevel(f.species, variant);
