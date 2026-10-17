/// Static data for the Boops: the twelve critters (each one a variant), the
/// journal reactions and the sound bank. Pure data; drawing lives in
/// `boop_art.dart`, behaviour in `boop_creature.dart`.
library;

import 'dart:ui' show Color;

/// How a critter's ears (or ear-equivalent) are drawn.
enum BoopEars { bunny, round, tuft, bumps, pig, cloud, none, floppy, jelly, leaf, horns }

/// The thing you boop.
enum BoopNose { button, heart, beak, snout, triangle, star }

/// One critter. Id is the stable `CreatureLook.variant` string.
class BoopVariant {
  const BoopVariant({
    required this.id,
    required this.englishName,
    required this.body,
    required this.belly,
    required this.accent,
    required this.nose,
    required this.cheek,
    required this.ears,
    required this.noseStyle,
    required this.pitch,
    this.aspect = 1.0,
    this.patches = false,
    this.freckles = false,
    this.whiskers = false,
    this.glossy = false,
  });

  final String id;
  final String englishName;
  final Color body;
  final Color belly;
  final Color accent;
  final Color nose;
  final Color cheek;
  final BoopEars ears;
  final BoopNose noseStyle;

  /// Base squeak pitch step (0–6); combos add up to 7 more (files 00–13).
  final int pitch;

  /// Body width / height. >1 is a wider, squatter critter.
  final double aspect;
  final bool patches;
  final bool freckles;
  final bool whiskers;

  /// Translucent jelly sheen.
  final bool glossy;
}

const List<BoopVariant> boopVariants = [
  BoopVariant(
    id: 'mochi', englishName: 'Mochi', pitch: 3, ears: BoopEars.bunny, noseStyle: BoopNose.heart,
    body: Color(0xFFFFD9E3), belly: Color(0xFFFFF1F4), accent: Color(0xFFFFB3C7), nose: Color(0xFFFF6F8E), cheek: Color(0xFFFF9FB6),
  ),
  BoopVariant(
    id: 'pip', englishName: 'Pip', pitch: 6, ears: BoopEars.tuft, noseStyle: BoopNose.beak, aspect: 0.96,
    body: Color(0xFFFFE07A), belly: Color(0xFFFFF3C2), accent: Color(0xFFFFC94A), nose: Color(0xFFFF9A3D), cheek: Color(0xFFFFA98A),
  ),
  BoopVariant(
    id: 'bao', englishName: 'Bao', pitch: 1, ears: BoopEars.round, noseStyle: BoopNose.button, patches: true, aspect: 1.06,
    body: Color(0xFFFAF7F2), belly: Color(0xFFFFFFFF), accent: Color(0xFF3B2A2A), nose: Color(0xFF3B2A2A), cheek: Color(0xFFFFB0C0),
  ),
  BoopVariant(
    id: 'kiwi', englishName: 'Kiwi', pitch: 2, ears: BoopEars.bumps, noseStyle: BoopNose.button, aspect: 1.14, freckles: true,
    body: Color(0xFF8EDB8A), belly: Color(0xFFD9F5C9), accent: Color(0xFF5DBB63), nose: Color(0xFF3F9A55), cheek: Color(0xFFFF9FA8),
  ),
  BoopVariant(
    id: 'momo', englishName: 'Momo', pitch: 0, ears: BoopEars.round, noseStyle: BoopNose.snout, aspect: 1.12,
    body: Color(0xFFD9C7E6), belly: Color(0xFFF1E7F7), accent: Color(0xFFFFB7C9), nose: Color(0xFFE6A9C4), cheek: Color(0xFFFF9FBA),
  ),
  BoopVariant(
    id: 'puff', englishName: 'Puff', pitch: 4, ears: BoopEars.cloud, noseStyle: BoopNose.triangle,
    body: Color(0xFFF4EEFF), belly: Color(0xFFFFFFFF), accent: Color(0xFFD9CCFF), nose: Color(0xFFB79CF5), cheek: Color(0xFFFFB5D0),
  ),
  BoopVariant(
    id: 'nori', englishName: 'Nori', pitch: 1, ears: BoopEars.none, noseStyle: BoopNose.button, whiskers: true, aspect: 1.12,
    body: Color(0xFFB9CCDD), belly: Color(0xFFE6EEF5), accent: Color(0xFF8FA9C0), nose: Color(0xFF3B2A2A), cheek: Color(0xFFFFB3C2),
  ),
  BoopVariant(
    id: 'taro', englishName: 'Taro', pitch: 5, ears: BoopEars.round, noseStyle: BoopNose.triangle, whiskers: true, aspect: 1.1,
    body: Color(0xFFF2C38F), belly: Color(0xFFFFF0DC), accent: Color(0xFFE0A066), nose: Color(0xFFFF8F9E), cheek: Color(0xFFFF9C8A),
  ),
  BoopVariant(
    id: 'coco', englishName: 'Coco', pitch: 2, ears: BoopEars.floppy, noseStyle: BoopNose.button, aspect: 1.02,
    body: Color(0xFFE2B48A), belly: Color(0xFFFFEBD6), accent: Color(0xFFA9734A), nose: Color(0xFF3B2A2A), cheek: Color(0xFFFF9F9F),
  ),
  BoopVariant(
    id: 'jelly', englishName: 'Jelly', pitch: 5, ears: BoopEars.jelly, noseStyle: BoopNose.heart, glossy: true, aspect: 1.04,
    body: Color(0xFFD3B8FF), belly: Color(0xFFEFE4FF), accent: Color(0xFFB08BFF), nose: Color(0xFFFF7FB0), cheek: Color(0xFFFF9FD0),
  ),
  BoopVariant(
    id: 'sprout', englishName: 'Sprout', pitch: 4, ears: BoopEars.leaf, noseStyle: BoopNose.button, freckles: true,
    body: Color(0xFFC4EBA0), belly: Color(0xFFEFFADF), accent: Color(0xFF6DC06A), nose: Color(0xFFFF9F7A), cheek: Color(0xFFFFA8A0),
  ),
  BoopVariant(
    id: 'star', englishName: 'Star', pitch: 3, ears: BoopEars.horns, noseStyle: BoopNose.star, aspect: 1.04,
    body: Color(0xFF9FD3FF), belly: Color(0xFFE2F2FF), accent: Color(0xFFFFD36B), nose: Color(0xFFFFB84D), cheek: Color(0xFFFFA6C9),
  ),
];

/// Lookup by id; unknown ids fall back to the first critter.
BoopVariant boopVariantById(String id) =>
    boopVariants.firstWhere((v) => v.id == id, orElse: () => boopVariants.first);

/// A journal-worthy thing a Boop did (event ids are `boop.<name>`).
class BoopReaction {
  const BoopReaction(this.id, this.englishName, this.englishHint);
  final String id;
  final String englishName;
  final String englishHint;
}

const List<BoopReaction> boopReactions = [
  BoopReaction('boop.boop', 'Boop!', 'Tap the nose.'),
  BoopReaction('boop.combo10', 'Boop-a-doop', 'Boop the nose 10 times in a row, less than a second apart.'),
  BoopReaction('boop.combo25', 'Snoot storm', 'Keep a boop combo going to 25.'),
  BoopReaction('boop.combo50', 'Mega boop', 'Reach a boop combo of 50.'),
  BoopReaction('boop.sneeze', 'Achoo!', 'Boop so much that the nose tickles: every 30th boop in a combo.'),
  BoopReaction('boop.hug', 'Snuggle', 'Rest a finger on the body for a moment.'),
  BoopReaction('boop.wobble', 'Wobble giggle', 'Tap the squishy body.'),
  BoopReaction('boop.stretch', 'Stretchy', 'Drag the body and let go.'),
  BoopReaction('boop.tickle', 'Tickle spin', 'Tap the body again and again, quickly.'),
  BoopReaction('boop.jelly', 'Jelly wobble', 'Scrub it clean in the spa.'),
  BoopReaction('boop.munch', 'Munch', 'Give it a snack.'),
  BoopReaction('boop.yum', 'Yum!', 'Give it its favourite snack.'),
  BoopReaction('boop.full', 'Too full', 'Offer a snack when it is full.'),
  BoopReaction('boop.boopBack', 'Boop back', 'Let a friend nuzzle it.'),
  BoopReaction('boop.cheer', 'Cheer', 'Celebrate together.'),
  BoopReaction('boop.hop', 'Little hop', 'Leave it alone for a while and it hops about.'),
  BoopReaction('boop.sleepy', 'Dozing off', 'Leave it alone for half a minute.'),
  BoopReaction('boop.surprise', 'Plop!', 'Let a friend land on it.'),
];

/// Sound id → asset path. Squeaks `boop.boop_00`…`boop.boop_13` are pre-pitched.
const Map<String, String> boopSounds = {
  'boop.boop_00': 'assets/sounds/boop/boop_00.wav',
  'boop.boop_01': 'assets/sounds/boop/boop_01.wav',
  'boop.boop_02': 'assets/sounds/boop/boop_02.wav',
  'boop.boop_03': 'assets/sounds/boop/boop_03.wav',
  'boop.boop_04': 'assets/sounds/boop/boop_04.wav',
  'boop.boop_05': 'assets/sounds/boop/boop_05.wav',
  'boop.boop_06': 'assets/sounds/boop/boop_06.wav',
  'boop.boop_07': 'assets/sounds/boop/boop_07.wav',
  'boop.boop_08': 'assets/sounds/boop/boop_08.wav',
  'boop.boop_09': 'assets/sounds/boop/boop_09.wav',
  'boop.boop_10': 'assets/sounds/boop/boop_10.wav',
  'boop.boop_11': 'assets/sounds/boop/boop_11.wav',
  'boop.boop_12': 'assets/sounds/boop/boop_12.wav',
  'boop.boop_13': 'assets/sounds/boop/boop_13.wav',
  'boop.boing': 'assets/sounds/boop/boing.wav',
  'boop.chime': 'assets/sounds/boop/chime.wav',
  'boop.fanfare': 'assets/sounds/boop/fanfare.wav',
  'boop.giggle': 'assets/sounds/boop/giggle.wav',
  'boop.hug': 'assets/sounds/boop/hug.wav',
  'boop.oops': 'assets/sounds/boop/oops.wav',
  'boop.pop': 'assets/sounds/boop/pop.wav',
  'boop.sneeze': 'assets/sounds/boop/sneeze.wav',
  'boop.whoosh': 'assets/sounds/boop/whoosh.wav',
};

/// Squeak sound id for a critter's [base] pitch at combo [count]: rises one
/// semitone every 3 boops, capped at +7 (files 00–13).
String boopSqueakId(int base, int count) {
  final rise = ((count - 1) ~/ 3).clamp(0, 7);
  final idx = (base + rise).clamp(0, 13);
  return 'boop.boop_${idx.toString().padLeft(2, '0')}';
}
