/// Everything collectible in Mofu, and the one rule that unlocks each item.
///
/// Items are data, not code paths: the wardrobe, the unlock checker and the
/// tests all read these lists, so adding an item is a one-line change here
/// plus its strings in the base `.arb`.
library;

import 'dart:ui' show Color;


/// How an item is earned. All free: v1 has no purchases.
enum UnlockKind { start, days, fluff, journal, snacks, seasonal }

class UnlockRule {
  const UnlockRule(this.kind, [this.amount = 0, this.seasonId = '']);
  const UnlockRule.start() : this(UnlockKind.start);
  const UnlockRule.days(int n) : this(UnlockKind.days, n);
  const UnlockRule.fluff(int n) : this(UnlockKind.fluff, n);
  const UnlockRule.journal(int n) : this(UnlockKind.journal, n);
  const UnlockRule.snacks(int n) : this(UnlockKind.snacks, n);
  const UnlockRule.seasonal(String id) : this(UnlockKind.seasonal, 0, id);

  final UnlockKind kind;
  final int amount;
  final String seasonId;
}

/// Fur palette. [base] is the body, [light] the sunlit fur tips, [shade] the
/// underside, [cheek] the blush. Colours were chosen to stay readable against
/// every time-of-day room, including the night one.
class FurColor {
  const FurColor({
    required this.id,
    required this.base,
    required this.light,
    required this.shade,
    required this.cheek,
    required this.rule,
  });
  final String id;
  final Color base;
  final Color light;
  final Color shade;
  final Color cheek;
  final UnlockRule rule;
}

class Accessory {
  const Accessory({required this.id, required this.rule});
  final String id;
  final UnlockRule rule;
}

class Snack {
  const Snack({required this.id, required this.emoji});
  final String id;
  final String emoji;
}

/// A discoverable reaction for the journal.
class Reaction {
  const Reaction({required this.id, required this.emoji});
  final String id;
  final String emoji;
}

class Catalog {
  const Catalog._();

  static const furColors = <FurColor>[
    FurColor(
      id: 'cream',
      base: Color(0xFFFFF1DE),
      light: Color(0xFFFFFBF3),
      shade: Color(0xFFEBD3B4),
      cheek: Color(0xFFFFA7B5),
      rule: UnlockRule.start(),
    ),
    FurColor(
      id: 'peach',
      base: Color(0xFFFFD3C2),
      light: Color(0xFFFFEDE4),
      shade: Color(0xFFF2AE99),
      cheek: Color(0xFFFF8BA0),
      rule: UnlockRule.start(),
    ),
    FurColor(
      id: 'mint',
      base: Color(0xFFCDF1DF),
      light: Color(0xFFEDFBF4),
      shade: Color(0xFF9FD9BD),
      cheek: Color(0xFFFF9EB3),
      rule: UnlockRule.days(2),
    ),
    FurColor(
      id: 'sky',
      base: Color(0xFFCFE6FF),
      light: Color(0xFFEEF6FF),
      shade: Color(0xFF9FC6F0),
      cheek: Color(0xFFFF9EBB),
      rule: UnlockRule.days(3),
    ),
    FurColor(
      id: 'lavender',
      base: Color(0xFFE3D6FF),
      light: Color(0xFFF4EEFF),
      shade: Color(0xFFBFA9EE),
      cheek: Color(0xFFFF94B8),
      rule: UnlockRule.fluff(25),
    ),
    FurColor(
      id: 'sakura',
      base: Color(0xFFFFD6E6),
      light: Color(0xFFFFEEF5),
      shade: Color(0xFFF3A9C6),
      cheek: Color(0xFFFF7FA3),
      rule: UnlockRule.journal(6),
    ),
    FurColor(
      id: 'lemon',
      base: Color(0xFFFFF0A8),
      light: Color(0xFFFFFAD9),
      shade: Color(0xFFEFD670),
      cheek: Color(0xFFFF9C8A),
      rule: UnlockRule.fluff(50),
    ),
    FurColor(
      id: 'cocoa',
      base: Color(0xFFC79E85),
      light: Color(0xFFE5C8B4),
      shade: Color(0xFF9E765F),
      cheek: Color(0xFFFF9C9C),
      rule: UnlockRule.days(5),
    ),
    FurColor(
      id: 'snow',
      base: Color(0xFFF7FAFF),
      light: Color(0xFFFFFFFF),
      shade: Color(0xFFD6DEEC),
      cheek: Color(0xFFFFB0C4),
      rule: UnlockRule.fluff(75),
    ),
    FurColor(
      id: 'starry',
      base: Color(0xFF6E6AC9),
      light: Color(0xFFA9A4F2),
      shade: Color(0xFF4A4596),
      cheek: Color(0xFFFF9FD0),
      rule: UnlockRule.fluff(100),
    ),
  ];

  static const accessories = <Accessory>[
    Accessory(id: 'none', rule: UnlockRule.start()),
    Accessory(id: 'bow', rule: UnlockRule.start()),
    Accessory(id: 'sprout', rule: UnlockRule.days(2)),
    Accessory(id: 'flower', rule: UnlockRule.journal(4)),
    Accessory(id: 'beanie', rule: UnlockRule.days(4)),
    Accessory(id: 'starclip', rule: UnlockRule.fluff(50)),
    Accessory(id: 'chef', rule: UnlockRule.snacks(15)),
    Accessory(id: 'headphones', rule: UnlockRule.journal(10)),
    Accessory(id: 'party', rule: UnlockRule.days(7)),
    Accessory(id: 'glasses', rule: UnlockRule.journal(16)),
    Accessory(id: 'crown', rule: UnlockRule.fluff(100)),
    // Seasonal: offered only while the matching remote-config window is open,
    // and kept forever once earned.
    Accessory(id: 'witch', rule: UnlockRule.seasonal('halloween')),
    Accessory(id: 'santa', rule: UnlockRule.seasonal('winter')),
  ];

  static const snacks = <Snack>[
    Snack(id: 'strawberry', emoji: '🍓'),
    Snack(id: 'dango', emoji: '🍡'),
    Snack(id: 'cookie', emoji: '🍪'),
    Snack(id: 'onigiri', emoji: '🍙'),
    Snack(id: 'pudding', emoji: '🍮'),
    Snack(id: 'candy', emoji: '🍬'),
  ];

  /// The 24 journal entries. Order is the journal's display order.
  static const reactions = <Reaction>[
    Reaction(id: 'boing', emoji: '🫧'),
    Reaction(id: 'tickle', emoji: '🤭'),
    Reaction(id: 'pet', emoji: '🤲'),
    Reaction(id: 'purr', emoji: '🎶'),
    Reaction(id: 'squish', emoji: '🍡'),
    Reaction(id: 'hug', emoji: '🫶'),
    Reaction(id: 'toss', emoji: '🎈'),
    Reaction(id: 'dizzyToss', emoji: '😵'),
    Reaction(id: 'eyePoke', emoji: '😣'),
    Reaction(id: 'shake', emoji: '🌪️'),
    Reaction(id: 'brush', emoji: '🪮'),
    Reaction(id: 'tidy', emoji: '✨'),
    Reaction(id: 'yum', emoji: '😋'),
    Reaction(id: 'favorite', emoji: '💖'),
    Reaction(id: 'full', emoji: '😌'),
    Reaction(id: 'sleep', emoji: '😴'),
    Reaction(id: 'wake', emoji: '🥱'),
    Reaction(id: 'nightOwl', emoji: '🦉'),
    Reaction(id: 'earlyBird', emoji: '🌅'),
    Reaction(id: 'fluffy', emoji: '☁️'),
    Reaction(id: 'maxFluff', emoji: '👑'),
    Reaction(id: 'dressUp', emoji: '🎀'),
    Reaction(id: 'newLook', emoji: '🎨'),
    Reaction(id: 'spin', emoji: '🌀'),
  ];

  static FurColor color(String id) =>
      furColors.firstWhere((c) => c.id == id, orElse: () => furColors.first);

  static Accessory accessory(String id) =>
      accessories.firstWhere((a) => a.id == id, orElse: () => accessories.first);

  static Snack snack(String id) =>
      snacks.firstWhere((s) => s.id == id, orElse: () => snacks.first);

  static bool isReaction(String id) => reactions.any((r) => r.id == id);

  /// Fluff milestones that celebrate (and that the `fluff` unlock rules use).
  static const fluffMilestones = [25, 50, 75, 100];

  /// The favourite snack is derived from the name, so it is stable across
  /// launches and reinstalls, differs between friends' Mofus, and needs no
  /// stored state. A simple FNV-1a hash: `String.hashCode` is not guaranteed
  /// stable across Dart versions.
  static Snack favoriteSnackFor(String name) {
    var h = 0x811C9DC5;
    for (final unit in name.trim().toLowerCase().codeUnits) {
      h ^= unit;
      h = (h * 0x01000193) & 0xFFFFFFFF;
    }
    return snacks[h % snacks.length];
  }
}
