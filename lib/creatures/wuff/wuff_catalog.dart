/// Static data for the Wuff puppy: coats, tricks, bark pads, journal
/// reactions and the sound bank. Pure data (dart:ui `Color` only).
library;

import 'dart:ui' show Color;

/// How a coat's second colour is laid out.
enum WuffPattern { solid, eyePatch, blaze, spots, mask, saddle }

/// A coat. `base` is the fur, `light` the sunlit top, `shade` the shadow
/// side, `ear` the (usually darker) ears, `muzzle` the muzzle/chest and `mark`
/// the pattern colour.
class WuffCoat {
  const WuffCoat({
    required this.id,
    required this.base,
    required this.light,
    required this.shade,
    required this.ear,
    required this.muzzle,
    this.pattern = WuffPattern.solid,
    this.mark = const Color(0x00000000),
  });
  final String id;
  final Color base;
  final Color light;
  final Color shade;
  final Color ear;
  final Color muzzle;
  final WuffPattern pattern;
  final Color mark;
}

const wuffCoats = <WuffCoat>[
  WuffCoat(
    id: 'golden',
    base: Color(0xFFF2B35E),
    light: Color(0xFFFFD995),
    shade: Color(0xFFC9853B),
    ear: Color(0xFFB9732E),
    muzzle: Color(0xFFFFF1D6),
  ),
  WuffCoat(
    id: 'cream',
    base: Color(0xFFF7E3C3),
    light: Color(0xFFFFF6E6),
    shade: Color(0xFFD9BC92),
    ear: Color(0xFFD1A779),
    muzzle: Color(0xFFFFFBF2),
  ),
  WuffCoat(
    id: 'chocolate',
    base: Color(0xFF8A5A3C),
    light: Color(0xFFB07E5C),
    shade: Color(0xFF5E3A24),
    ear: Color(0xFF4A2C1A),
    muzzle: Color(0xFFE8CBB0),
  ),
  WuffCoat(
    id: 'blackTan',
    base: Color(0xFF3E302A),
    light: Color(0xFF5F4A40),
    shade: Color(0xFF2A1F1A),
    ear: Color(0xFF241A15),
    muzzle: Color(0xFFD99B5C),
    pattern: WuffPattern.blaze,
    mark: Color(0xFFD99B5C),
  ),
  WuffCoat(
    id: 'snow',
    base: Color(0xFFF4F1EC),
    light: Color(0xFFFFFFFF),
    shade: Color(0xFFCFC7BC),
    ear: Color(0xFFE2D8CB),
    muzzle: Color(0xFFFFFFFF),
  ),
  WuffCoat(
    id: 'corgi',
    base: Color(0xFFE8954C),
    light: Color(0xFFFFB774),
    shade: Color(0xFFBF6F2E),
    ear: Color(0xFFD27B36),
    muzzle: Color(0xFFFFFFFF),
    pattern: WuffPattern.blaze,
    mark: Color(0xFFFFFFFF),
  ),
  WuffCoat(
    id: 'dalmatian',
    base: Color(0xFFFCFAF7),
    light: Color(0xFFFFFFFF),
    shade: Color(0xFFD9D3CB),
    ear: Color(0xFF2E2622),
    muzzle: Color(0xFFFFFFFF),
    pattern: WuffPattern.spots,
    mark: Color(0xFF2E2622),
  ),
  WuffCoat(
    id: 'husky',
    base: Color(0xFF8D98A6),
    light: Color(0xFFB4BDC8),
    shade: Color(0xFF66717F),
    ear: Color(0xFF5B6573),
    muzzle: Color(0xFFFFFFFF),
    pattern: WuffPattern.mask,
    mark: Color(0xFFFFFFFF),
  ),
  WuffCoat(
    id: 'beagle',
    base: Color(0xFFC98B4F),
    light: Color(0xFFE6AE75),
    shade: Color(0xFF9E6633),
    ear: Color(0xFF8A5527),
    muzzle: Color(0xFFFFFFFF),
    pattern: WuffPattern.saddle,
    mark: Color(0xFF3A2C24),
  ),
  WuffCoat(
    id: 'cottonCandy',
    base: Color(0xFFF7B8D2),
    light: Color(0xFFFFDCEB),
    shade: Color(0xFFD98BAE),
    ear: Color(0xFFB7E3F7),
    muzzle: Color(0xFFFFF4FA),
    pattern: WuffPattern.eyePatch,
    mark: Color(0xFFB7E3F7),
  ),
];

/// Looks a coat up by `CreatureLook.variant`; unknown ids fall back to golden.
WuffCoat wuffCoat(String id) => wuffCoats.firstWhere((c) => c.id == id, orElse: () => wuffCoats.first);

class WuffTrick {
  const WuffTrick(this.id, this.englishName);
  final String id;
  final String englishName;
}

/// Order matters: each trick opens when the one before it earns a star.
const wuffTricks = <WuffTrick>[
  WuffTrick('sit', 'Sit'),
  WuffTrick('paw', 'Paw'),
  WuffTrick('spin', 'Spin'),
  WuffTrick('speak', 'Speak'),
  WuffTrick('playDead', 'Play dead'),
  WuffTrick('highFive', 'High five'),
];

/// One pad on the bark board. [sound] is a full `wuff.*` sound id.
class WuffBarkPad {
  const WuffBarkPad({required this.id, required this.sound, required this.color, required this.edge});
  final String id;
  final String sound;
  final Color color;
  final Color edge;
}

const wuffBarkPads = <WuffBarkPad>[
  WuffBarkPad(id: 'hello', sound: 'wuff.bark', color: Color(0xFFFFD9A8), edge: Color(0xFFE9B57A)),
  WuffBarkPad(id: 'yip', sound: 'wuff.yip', color: Color(0xFFFFE7A0), edge: Color(0xFFE6C463)),
  WuffBarkPad(id: 'play', sound: 'wuff.playbark', color: Color(0xFFC9EBB7), edge: Color(0xFF97C982)),
  WuffBarkPad(id: 'howl', sound: 'wuff.howl', color: Color(0xFFCFE0FF), edge: Color(0xFF9DB6E8)),
  WuffBarkPad(id: 'whimper', sound: 'wuff.whimper', color: Color(0xFFF6D5F0), edge: Color(0xFFD2A6CC)),
  WuffBarkPad(id: 'growl', sound: 'wuff.growl', color: Color(0xFFFFD0C4), edge: Color(0xFFE3A090)),
  WuffBarkPad(id: 'sneeze', sound: 'wuff.sneeze', color: Color(0xFFD6F2EE), edge: Color(0xFF9ED0C8)),
  WuffBarkPad(id: 'squeak', sound: 'wuff.toy', color: Color(0xFFFFE0EA), edge: Color(0xFFE8A9BD)),
  WuffBarkPad(id: 'pant', sound: 'wuff.pantshot', color: Color(0xFFEFE4D2), edge: Color(0xFFCDB896)),
];

/// A journal-worthy reaction the puppy can emit (`CreatureEventType.reaction`).
class WuffReaction {
  const WuffReaction(this.id, this.englishName, this.englishHint);
  final String id;
  final String englishName;
  final String englishHint;
}

const wuffReactions = <WuffReaction>[
  WuffReaction('wuff.yip', 'Happy yip', 'Give your puppy a quick tap.'),
  WuffReaction('wuff.pet', 'Head pats', 'Stroke the top of its head for a moment.'),
  WuffReaction('wuff.earScratch', 'Ear scratch', 'Rub a floppy ear until a back leg starts thumping.'),
  WuffReaction('wuff.blep', 'Blep', 'Scratch under the chin and watch the tongue peek out.'),
  WuffReaction('wuff.achoo', 'Achoo!', 'Boop the nose once.'),
  WuffReaction('wuff.bigSneeze', 'Big sneeze', 'Boop the nose three times in a row.'),
  WuffReaction('wuff.wink', 'Wink', 'Double-tap one eye.'),
  WuffReaction('wuff.zoomies', 'Zoomies', 'Tap the puppy five times, fast.'),
  WuffReaction('wuff.snuggle', 'Snuggle', 'Press and hold on the puppy.'),
  WuffReaction('wuff.love', 'Total love', 'Keep holding until the hearts appear.'),
  WuffReaction('wuff.dizzy', 'Dizzy', 'Give the phone a gentle shake.'),
  WuffReaction('wuff.yum', 'Yum', 'Feed it a treat.'),
  WuffReaction('wuff.favorite', 'Favourite treat', 'Find the treat it loves most.'),
  WuffReaction('wuff.full', 'Too full', 'Offer one treat too many.'),
  WuffReaction('wuff.goodPup', 'Good pup!', 'Reward a trick with a treat.'),
  WuffReaction('wuff.howl', 'Howl', 'Press the howl pad on the bark board.'),
  WuffReaction('wuff.nap', 'Nap time', 'Leave the puppy alone for a while.'),
  WuffReaction('wuff.wake', 'Big yawn', 'Wake a sleeping puppy.'),
  WuffReaction('wuff.groomed', 'Squeaky clean', 'Give it a bath and a rub down.'),
  WuffReaction('wuff.shakeOff', 'Shake it off', 'Soap it up and let it shake the water off.'),
  WuffReaction('wuff.nuzzled', 'Nuzzled', 'A friend gives it a nuzzle.'),
  WuffReaction('wuff.startled', 'Startled hop', 'A friend lands right next to it.'),
  WuffReaction('wuff.watchFriend', 'Friend watching', 'Touch a friend and see who looks over.'),
  WuffReaction('wuff.cheer', 'Party time', 'Celebrate together with the whole house.'),
  WuffReaction('wuff.trick.sit', 'Sit', 'Teach it to sit.'),
  WuffReaction('wuff.trick.paw', 'Paw', 'Teach it to shake a paw.'),
  WuffReaction('wuff.trick.spin', 'Spin', 'Teach it to spin around.'),
  WuffReaction('wuff.trick.speak', 'Speak', 'Teach it to speak on command.'),
  WuffReaction('wuff.trick.playDead', 'Play dead', 'Teach it to play dead.'),
  WuffReaction('wuff.trick.highFive', 'High five', 'Teach it a high five.'),
];

/// Every sound id the puppy can emit, mapped to its asset path. Loops are
/// `.wav` (gapless), one-shots `.mp3`.
const wuffSounds = <String, String>{
  // Voice
  'wuff.bark': 'assets/sounds/wuff/bark.mp3',
  'wuff.bark2': 'assets/sounds/wuff/bark2.mp3',
  'wuff.bark3': 'assets/sounds/wuff/bark3.mp3',
  'wuff.yip': 'assets/sounds/wuff/yip.mp3',
  'wuff.yip2': 'assets/sounds/wuff/yip2.mp3',
  'wuff.playbark': 'assets/sounds/wuff/playbark.mp3',
  'wuff.howl': 'assets/sounds/wuff/howl.mp3',
  'wuff.whimper': 'assets/sounds/wuff/whimper.mp3',
  'wuff.growl': 'assets/sounds/wuff/growl.mp3',
  'wuff.pantshot': 'assets/sounds/wuff/pantshot.mp3',
  'wuff.sneeze': 'assets/sounds/wuff/sneeze.mp3',
  'wuff.bigsneeze': 'assets/sounds/wuff/bigsneeze.mp3',
  'wuff.huff': 'assets/sounds/wuff/huff.mp3',
  'wuff.huh': 'assets/sounds/wuff/huh.mp3',
  'wuff.aww': 'assets/sounds/wuff/aww.mp3',
  'wuff.love': 'assets/sounds/wuff/love.mp3',
  'wuff.yawn': 'assets/sounds/wuff/yawn.mp3',
  'wuff.yum': 'assets/sounds/wuff/yum.mp3',
  // Foley
  'wuff.chomp': 'assets/sounds/wuff/chomp.mp3',
  'wuff.toy': 'assets/sounds/wuff/toy.mp3',
  'wuff.boop': 'assets/sounds/wuff/boop.mp3',
  'wuff.whoosh': 'assets/sounds/wuff/whoosh.mp3',
  'wuff.flop': 'assets/sounds/wuff/flop.mp3',
  'wuff.clap': 'assets/sounds/wuff/clap.mp3',
  'wuff.wobble': 'assets/sounds/wuff/wobble.mp3',
  'wuff.wink': 'assets/sounds/wuff/wink.mp3',
  'wuff.cheer': 'assets/sounds/wuff/cheer.mp3',
  'wuff.fanfare': 'assets/sounds/wuff/fanfare.mp3',
  'wuff.sparkle': 'assets/sounds/wuff/sparkle.mp3',
  // Loops (CreatureEventType.loopStart / loopStop)
  'wuff.thump': 'assets/sounds/wuff/thump.wav',
  'wuff.snore': 'assets/sounds/wuff/snore.wav',
};

/// Sound ids that are gapless loops.
const wuffLoops = <String>{'wuff.thump', 'wuff.snore'};

/// Suggested playback gain per sound id (default 0.85 for one-shots).
const wuffSoundGains = <String, double>{
  'wuff.thump': 0.5,
  'wuff.snore': 0.35,
  'wuff.howl': 0.75,
  'wuff.growl': 0.7,
  'wuff.sparkle': 0.6,
  'wuff.whoosh': 0.6,
  'wuff.wobble': 0.7,
};
