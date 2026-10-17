/// Static data for the piglet: coat tints, snacks, journal reactions and the
/// sound bank. English names are the source strings; the app localises them by
/// id (`oink.reaction.<id>.name` etc.).
library;

/// A coat colour. The palette itself lives in `oink_art.dart`.
class OinkTint {
  const OinkTint(this.id, this.englishName);
  final String id;
  final String englishName;
}

const oinkTints = <OinkTint>[
  OinkTint('classic', 'Classic pink'),
  OinkTint('peach', 'Peach'),
  OinkTint('spotted', 'Spotted'),
  OinkTint('chocolate', 'Chocolate'),
  OinkTint('lavender', 'Lavender'),
  OinkTint('golden', 'Golden'),
  OinkTint('mint', 'Mint'),
  OinkTint('snow', 'Snow'),
];

/// A snack the piglet likes. Basic fruit and veg; the room decides which is
/// today's favourite.
class OinkSnack {
  const OinkSnack(this.id, this.englishName);
  final String id;
  final String englishName;
}

const oinkSnacks = <OinkSnack>[
  OinkSnack('apple', 'Apple'),
  OinkSnack('carrot', 'Carrot'),
  OinkSnack('corn', 'Corn'),
  OinkSnack('lettuce', 'Lettuce'),
  OinkSnack('watermelon', 'Watermelon'),
  OinkSnack('strawberry', 'Strawberry'),
];

/// A journal entry the piglet can unlock. [id] is exactly what the simulation
/// emits in a `CreatureEventType.reaction` event.
class OinkReaction {
  const OinkReaction(this.id, this.englishName, this.englishHint);
  final String id;
  final String englishName;
  final String englishHint;
}

const oinkReactions = <OinkReaction>[
  OinkReaction('oink.snout', 'Snout boop', 'Tap the snout.'),
  OinkReaction('oink.head', 'Happy pats', 'Tap the head.'),
  OinkReaction('oink.pat', 'Head scritches', 'Rub the head back and forth.'),
  OinkReaction('oink.belly', 'Belly giggle', 'Tap the round belly.'),
  OinkReaction('oink.rub', 'Belly rub', 'Rub the belly back and forth.'),
  OinkReaction('oink.ear', 'Ear flop', 'Tap an ear.'),
  OinkReaction('oink.tail', 'Tail spin', 'Tap the curly tail.'),
  OinkReaction('oink.tickle', 'Tickle frenzy', 'Tap again and again, really fast.'),
  OinkReaction('oink.squish', 'Squish', 'Press and hold on the pig.'),
  OinkReaction('oink.pickup', 'Up we go', 'Hold, then drag the pig up.'),
  OinkReaction('oink.landing', 'Plop landing', 'Toss the pig and watch it land.'),
  OinkReaction('oink.hop', 'Little hop', 'Wait a while: the pig hops for joy.'),
  OinkReaction('oink.munch', 'Yum', 'Feed the pig a snack.'),
  OinkReaction('oink.favorite', 'Favourite snack', 'Feed the pig its favourite snack.'),
  OinkReaction('oink.full', 'Too full', 'Offer a snack when the pig is stuffed.'),
  OinkReaction('oink.sleep', 'Sweet snores', 'Let the pig fall asleep.'),
  OinkReaction('oink.wake', 'Rise and shine', 'Wake the pig up.'),
  OinkReaction('oink.grumble', 'Grumpy pig', 'Poke the pig while it sleeps.'),
  OinkReaction('oink.groom', 'Bubble bath', 'Scrub the pig with foam.'),
  OinkReaction('oink.towel', 'Towel rub', 'Dry the pig with the towel.'),
  OinkReaction('oink.dryer', 'Blow dry', 'Use the dryer and watch the ears flap.'),
  OinkReaction('oink.cheer', 'Party pig', 'Join in a celebration.'),
  OinkReaction('oink.nuzzle', 'Friend cuddle', 'Let a friend nuzzle the pig.'),
  OinkReaction('oink.peek', 'Nosy pig', 'Touch a friend while the pig watches.'),
  OinkReaction('oink.bumped', 'Oof!', 'Land a friend on top of the pig.'),
];

/// Sound id → asset path. Every id the simulation can emit is in here. Several
/// ids may share a file (`oink.grumble` is a low snort).
const oinkSounds = <String, String>{
  'oink.oink1': 'assets/sounds/oink/oink_1.mp3',
  'oink.oink2': 'assets/sounds/oink/oink_2.mp3',
  'oink.oink3': 'assets/sounds/oink/oink_3.mp3',
  'oink.oink4': 'assets/sounds/oink/oink_4.mp3',
  'oink.oink5': 'assets/sounds/oink/oink_5.mp3',
  'oink.oink6': 'assets/sounds/oink/oink_6.mp3',
  'oink.snort1': 'assets/sounds/oink/snort_1.mp3',
  'oink.snort2': 'assets/sounds/oink/snort_2.mp3',
  'oink.grumble': 'assets/sounds/oink/snort_2.mp3',
  'oink.giggle1': 'assets/sounds/oink/giggle_1.mp3',
  'oink.giggle2': 'assets/sounds/oink/giggle_2.mp3',
  'oink.squeal': 'assets/sounds/oink/squeal_happy.mp3',
  'oink.whimper': 'assets/sounds/oink/whimper.mp3',
  'oink.yawn': 'assets/sounds/oink/yawn.mp3',
  'oink.snore': 'assets/sounds/oink/snore.wav',
  'oink.munch1': 'assets/sounds/oink/munch_1.mp3',
  'oink.munch2': 'assets/sounds/oink/munch_2.mp3',
  'oink.munch3': 'assets/sounds/oink/munch_3.mp3',
  'oink.gulp': 'assets/sounds/oink/gulp.mp3',
  'oink.sparkle': 'assets/sounds/oink/sparkle.mp3',
  'oink.pop': 'assets/sounds/oink/pop.mp3',
  'oink.tap': 'assets/sounds/oink/tap.mp3',
  'oink.wake': 'assets/sounds/oink/wake.mp3',
  'oink.levelup': 'assets/sounds/oink/levelup.mp3',
  'oink.scrub': 'assets/sounds/oink/scrub.mp3',
  'oink.bubbles': 'assets/sounds/oink/bubbles.mp3',
};

/// The sound ids that are loops (start with `loopStart`, stop with `loopStop`).
const oinkLoops = <String>{'oink.snore'};
