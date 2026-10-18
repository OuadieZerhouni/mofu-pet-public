// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Mofu';

  @override
  String get dockBrush => 'Brush';

  @override
  String get dockSnacks => 'Snacks';

  @override
  String get dockWardrobe => 'Wardrobe';

  @override
  String get dockJournal => 'Journal';

  @override
  String fluffPercent(int percent) {
    return '$percent% fluffy';
  }

  @override
  String daysTogether(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Day $count together',
      one: 'Day 1 together',
    );
    return '$_temp0';
  }

  @override
  String get coachPetMe => 'Pet me!';

  @override
  String coachBrush(String name) {
    return 'Brush gently to make $name fluffier';
  }

  @override
  String snacksHint(String name) {
    return 'Drag a snack to $name\'s mouth';
  }

  @override
  String get firstRunTapSeed => 'Tap the fluff seed';

  @override
  String get firstRunHello => 'Hi! I\'m your Mofu';

  @override
  String get firstRunNameTitle => 'What should we call your Mofu?';

  @override
  String get nameFieldHint => 'Name';

  @override
  String get actionSave => 'Save';

  @override
  String get actionSkip => 'Skip';

  @override
  String get actionCancel => 'Cancel';

  @override
  String get actionClose => 'Close';

  @override
  String get actionOk => 'OK';

  @override
  String toastNewReaction(String name) {
    return 'New! $name';
  }

  @override
  String toastUnlocked(String item) {
    return 'Unlocked: $item';
  }

  @override
  String get toastDailyBrush => 'First brush of the day ✨';

  @override
  String toastFluffMilestone(int percent) {
    return 'Mofu mofu! $percent% fluffy';
  }

  @override
  String get toastMaxFluff => 'MAX MOFU! The fluffiest ever';

  @override
  String toastFull(String name) {
    return '$name is full. Maybe later!';
  }

  @override
  String toastSeasonal(String item) {
    return 'A seasonal gift arrived: $item';
  }

  @override
  String get snacksTitle => 'Snacks';

  @override
  String get wardrobeTitle => 'Wardrobe';

  @override
  String get tabFur => 'Fur';

  @override
  String get tabAccessories => 'Accessories';

  @override
  String get badgeNew => 'New!';

  @override
  String lockedDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Visit on $count days',
      one: 'Visit on 1 day',
    );
    return '$_temp0';
  }

  @override
  String lockedFluff(int percent) {
    return 'Reach $percent% fluff';
  }

  @override
  String lockedJournal(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Discover $count reactions',
      one: 'Discover 1 reaction',
    );
    return '$_temp0';
  }

  @override
  String lockedSnacks(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Share $count snacks',
      one: 'Share 1 snack',
    );
    return '$_temp0';
  }

  @override
  String lockedSeasonal(String season) {
    return 'Seasonal: $season';
  }

  @override
  String get seasonHalloween => 'Halloween';

  @override
  String get seasonWinter => 'Winter holidays';

  @override
  String get journalTitle => 'Journal';

  @override
  String journalProgress(int found, int total) {
    return '$found of $total discovered';
  }

  @override
  String get journalUnknown => '???';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsSound => 'Sounds';

  @override
  String get settingsHaptics => 'Haptics';

  @override
  String get settingsRename => 'Rename';

  @override
  String get settingsPrivacy => 'Privacy policy';

  @override
  String get settingsSupport => 'Help & feedback';

  @override
  String get settingsRate => 'Rate Mofu';

  @override
  String settingsVersion(String version) {
    return 'Version $version';
  }

  @override
  String get settingsReset => 'Start over';

  @override
  String get resetTitle => 'Start over?';

  @override
  String resetBody(String name) {
    return 'This clears $name\'s fluff, wardrobe and journal. It can\'t be undone.';
  }

  @override
  String get resetConfirm => 'Start over';

  @override
  String get updateTitle => 'A new Mofu update';

  @override
  String get updateBody => 'A fresh version is ready on the App Store.';

  @override
  String get updateRequiredBody =>
      'This version is too old to keep going. Please update to continue.';

  @override
  String get updateAction => 'Update';

  @override
  String get updateLater => 'Later';

  @override
  String semanticsMofu(String name) {
    return '$name, your Mofu';
  }

  @override
  String get semanticsHug => 'Hug';

  @override
  String get semanticsBrushOn => 'Brush on';

  @override
  String get semanticsSettings => 'Settings';

  @override
  String get colorCream => 'Cream';

  @override
  String get colorPeach => 'Peach';

  @override
  String get colorMint => 'Mint';

  @override
  String get colorSky => 'Sky';

  @override
  String get colorLavender => 'Lavender';

  @override
  String get colorSakura => 'Sakura';

  @override
  String get colorLemon => 'Lemon';

  @override
  String get colorCocoa => 'Cocoa';

  @override
  String get colorSnow => 'Snow';

  @override
  String get colorStarry => 'Starry night';

  @override
  String get accNone => 'Nothing';

  @override
  String get accBow => 'Bow';

  @override
  String get accSprout => 'Sprout';

  @override
  String get accFlower => 'Daisy';

  @override
  String get accBeanie => 'Beanie';

  @override
  String get accStarclip => 'Star clip';

  @override
  String get accChef => 'Chef hat';

  @override
  String get accHeadphones => 'Headphones';

  @override
  String get accParty => 'Party hat';

  @override
  String get accGlasses => 'Glasses';

  @override
  String get accCrown => 'Crown';

  @override
  String get accWitch => 'Witch hat';

  @override
  String get accSanta => 'Santa hat';

  @override
  String get snackStrawberry => 'Strawberry';

  @override
  String get snackDango => 'Dango';

  @override
  String get snackCookie => 'Cookie';

  @override
  String get snackOnigiri => 'Onigiri';

  @override
  String get snackPudding => 'Pudding';

  @override
  String get snackCandy => 'Candy';

  @override
  String get rxBoing => 'Boing';

  @override
  String get rxBoingHint => 'Give it a little tap';

  @override
  String get rxTickle => 'Tickle fit';

  @override
  String get rxTickleHint => 'Tap, tap, tap, tap, tap!';

  @override
  String get rxPet => 'Happy pets';

  @override
  String get rxPetHint => 'Stroke its fur';

  @override
  String get rxPurr => 'Purr purr';

  @override
  String get rxPurrHint => 'Keep petting for a while';

  @override
  String get rxSquish => 'Mochi squish';

  @override
  String get rxSquishHint => 'Press and hold';

  @override
  String get rxHug => 'Big hug';

  @override
  String get rxHugHint => 'Hold a little longer';

  @override
  String get rxToss => 'Wheee!';

  @override
  String get rxTossHint => 'Hold, lift and let go';

  @override
  String get rxDizzyToss => 'Bouncy bonk';

  @override
  String get rxDizzyTossHint => 'Throw it high';

  @override
  String get rxEyePoke => 'Hey!';

  @override
  String get rxEyePokeHint => 'Double-tap an eye';

  @override
  String get rxShake => 'Earthquake';

  @override
  String get rxShakeHint => 'Shake your phone';

  @override
  String get rxBrush => 'Brushing time';

  @override
  String get rxBrushHint => 'Use the brush';

  @override
  String get rxTidy => 'All tidy';

  @override
  String get rxTidyHint => 'Brush away messy fur';

  @override
  String get rxYum => 'Yum!';

  @override
  String get rxYumHint => 'Share a snack';

  @override
  String get rxFavorite => 'Favourite snack';

  @override
  String get rxFavoriteHint => 'Every Mofu has one';

  @override
  String get rxFull => 'So full';

  @override
  String get rxFullHint => 'Too many snacks';

  @override
  String get rxSleep => 'Sleepyhead';

  @override
  String get rxSleepHint => 'Let it rest';

  @override
  String get rxWake => 'Good morning';

  @override
  String get rxWakeHint => 'Wake it gently';

  @override
  String get rxNightOwl => 'Night owl';

  @override
  String get rxNightOwlHint => 'Visit after midnight';

  @override
  String get rxEarlyBird => 'Early bird';

  @override
  String get rxEarlyBirdHint => 'Visit at sunrise';

  @override
  String get rxFluffy => 'Fluffy';

  @override
  String get rxFluffyHint => 'Reach 25% fluff';

  @override
  String get rxMaxFluff => 'Max mofu';

  @override
  String get rxMaxFluffHint => 'Reach 100% fluff';

  @override
  String get rxDressUp => 'Dress up';

  @override
  String get rxDressUpHint => 'Try an accessory';

  @override
  String get rxNewLook => 'New look';

  @override
  String get rxNewLookHint => 'Change its fur';

  @override
  String get rxSpin => 'Spin cycle';

  @override
  String get rxSpinHint => 'Pet in circles';

  @override
  String get roomLiving => 'Living room';

  @override
  String get roomSpa => 'Spa';

  @override
  String get roomKitchen => 'Kitchen';

  @override
  String get roomBedroom => 'Bedroom';

  @override
  String get roomPlayroom => 'Playroom';

  @override
  String get roomGarden => 'Garden';

  @override
  String get navPrevRoom => 'Previous room';

  @override
  String get navNextRoom => 'Next room';

  @override
  String get navSettings => 'Settings';

  @override
  String starsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count stars',
      one: '1 star',
    );
    return '$_temp0';
  }

  @override
  String friendsHere(int count, int max) {
    return '$count of $max here';
  }

  @override
  String get shelfTapHint => 'Tap a friend to bring them here';

  @override
  String get roomFull => 'This room is full — 4 friends at most';

  @override
  String friendHereLabel(String name) {
    return '$name, in this room. Double-tap for their card.';
  }

  @override
  String friendElsewhereLabel(String name) {
    return '$name. Double-tap to bring them here.';
  }

  @override
  String eggCoinLabel(int stars) {
    return 'Next egg hatches at $stars stars';
  }

  @override
  String toastStars(int count) {
    return '+$count ★';
  }

  @override
  String toastLevelUp(String name, int level) {
    return '$name reached friendship level $level!';
  }

  @override
  String get toastEggReady => 'An egg is ready in the garden!';

  @override
  String toastFluffy(String name, int percent) {
    return '$name is $percent% fluffy!';
  }

  @override
  String get bubbleFull => 'I\'m full!';

  @override
  String get bubbleOink => 'Oink!';

  @override
  String get bubbleOinkQuestion => 'Oink?';

  @override
  String get bubbleWoof => 'Woof!';

  @override
  String get bubbleAchoo => 'Achoo!';

  @override
  String get bubbleYip => 'Yip!';

  @override
  String get bubbleHowl => 'Awooo!';

  @override
  String get bubbleWhimper => 'Whimper…';

  @override
  String get bubbleGrrr => 'Grrr!';

  @override
  String get bubbleSqueak => 'Squeak!';

  @override
  String get bubblePant => 'Hah-hah!';

  @override
  String get bubblePlay => 'Let\'s play!';

  @override
  String get bubbleCombo10 => 'Boop-a-doop!';

  @override
  String get bubbleCombo25 => 'Snoot storm!';

  @override
  String get bubbleCombo50 => 'Mega boop!';

  @override
  String get bubbleHi => 'Hi!';

  @override
  String get spaEmptyTitle => 'The spa is ready';

  @override
  String get spaEmptyHint => 'Tap a friend below to bring them to the spa';

  @override
  String spaTitle(String name) {
    return '$name\'s spa day';
  }

  @override
  String spaStepOf(int step, int total) {
    return 'Step $step of $total';
  }

  @override
  String get spaStepFoam => 'Foam';

  @override
  String get spaStepRinse => 'Rinse';

  @override
  String get spaStepTowel => 'Towel';

  @override
  String get spaStepDry => 'Dry';

  @override
  String get spaHintFoam => 'Rub to make bubbles';

  @override
  String get spaHintRinse => 'Drag the shower over the foam';

  @override
  String get spaHintTowel => 'Rub gently until dry';

  @override
  String get spaHintDry => 'Blow-dry for extra fluff';

  @override
  String get spaHintDone => 'All fresh! Play, or start again';

  @override
  String get spaAgain => 'Spa again';

  @override
  String get spaFreshToast => 'New in the journal: Spa day';

  @override
  String get bubbleFresh => 'Fresh!';

  @override
  String get snackApple => 'Apple';

  @override
  String get snackCarrot => 'Carrot';

  @override
  String get snackCorn => 'Corn';

  @override
  String get snackLettuce => 'Lettuce';

  @override
  String get snackWatermelon => 'Melon';

  @override
  String get snackBone => 'Bone';

  @override
  String get snackBacon => 'Bacon bite';

  @override
  String get snackCheese => 'Cheese';

  @override
  String get snackCupcake => 'Cupcake';

  @override
  String get snackBlueberry => 'Blueberries';

  @override
  String get snackCherry => 'Cherries';

  @override
  String get snackGrape => 'Grapes';

  @override
  String get snackPeach => 'Peach';

  @override
  String kitchenMenuFor(String name) {
    return '$name\'s menu · drag to the mouth';
  }

  @override
  String kitchenLeft(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count more this hour',
      one: '1 more this hour',
      zero: 'Full for now',
    );
    return '$_temp0';
  }

  @override
  String get kitchenEmptyHint =>
      'Tap a friend below to invite them for a snack';

  @override
  String kitchenFavoriteToast(String name, String snack) {
    return '$name loves $snack! +1 ★';
  }

  @override
  String get kitchenPickHint => 'Tap a friend to choose who eats';

  @override
  String get bedLamp => 'Night light';

  @override
  String get bedTuckIn => 'Tuck in';

  @override
  String get bedWakeUp => 'Wake up';

  @override
  String get sleepSounds => 'Sleep sounds';

  @override
  String get sleepPlay => 'Play';

  @override
  String get sleepStop => 'Stop';

  @override
  String get sleepMix => 'Mix';

  @override
  String get sleepTimer => 'Timer';

  @override
  String get sleepTimerOff => 'Off';

  @override
  String sleepMinutes(int minutes) {
    return '$minutes min';
  }

  @override
  String get sleepRain => 'Rain';

  @override
  String get sleepPurr => 'Purr';

  @override
  String get sleepFire => 'Fireplace';

  @override
  String get sleepOcean => 'Ocean';

  @override
  String get sleepChimes => 'Wind chimes';

  @override
  String get sleepNoise => 'Soft noise';

  @override
  String get sleepScreenOff => 'Keeps playing with the screen off';

  @override
  String sleepEndsIn(int minutes) {
    return 'Stops in $minutes min';
  }

  @override
  String sleepVolume(String channel) {
    return '$channel volume';
  }

  @override
  String get gameBoopRush => 'Boop Rush';

  @override
  String get gameBoopRushDesc => 'Boop every snoot that pops up. 30 seconds.';

  @override
  String get gameSnackCatch => 'Snack Catch';

  @override
  String get gameSnackCatchDesc =>
      'Slide a friend to catch snacks, dodge the bees. 45 seconds.';

  @override
  String gameBest(int score) {
    return 'Best $score';
  }

  @override
  String gameStarsCap(int count) {
    return 'Up to $count ★ a day';
  }

  @override
  String gamePlay(String game) {
    return 'Play $game';
  }

  @override
  String get gameReady => 'Ready?';

  @override
  String get gameGo => 'Go!';

  @override
  String gameScore(int score) {
    return 'Score $score';
  }

  @override
  String gameTime(int seconds) {
    return '${seconds}s';
  }

  @override
  String get gamePause => 'Pause';

  @override
  String get gameResume => 'Resume';

  @override
  String get gameQuit => 'Quit';

  @override
  String get gameTimesUp => 'Time\'s up!';

  @override
  String get gameNewBest => 'New best!';

  @override
  String gameStarsEarned(int count) {
    return '+$count ★';
  }

  @override
  String get gamePlayAgain => 'Play again';

  @override
  String get gameDone => 'Done';

  @override
  String get gameCatcherHint => 'Drag left and right';

  @override
  String get gameBoopHint => 'Boop the snoots! Don\'t wake the sleepy ones.';

  @override
  String get gardenEggReadyTitle => 'A new egg is ready!';

  @override
  String get gardenEggReadyHint => 'Tap the egg to welcome a new friend';

  @override
  String gardenNextEgg(int stars) {
    return 'Next friend at $stars ★';
  }

  @override
  String gardenProgress(int have, int need) {
    return '$have of $need ★';
  }

  @override
  String get gardenEggHint => 'Care for your friends to earn stars';

  @override
  String get gardenAllHatched => 'Everyone has hatched!';

  @override
  String gardenEggNotYet(int stars) {
    return 'This egg needs $stars ★';
  }

  @override
  String hatchNameTitle(String species) {
    return 'Name your new $species';
  }

  @override
  String get gardenGift => 'Daily gift';

  @override
  String gardenGiftDay(int day) {
    return 'Daily gift · day $day';
  }

  @override
  String get gardenGiftClaimed => 'Come back tomorrow';

  @override
  String get gardenPhotoBooth => 'Photo booth';

  @override
  String toastGift(int count) {
    return '+$count ★ · see you tomorrow!';
  }

  @override
  String toastNewFriend(String name) {
    return 'Say hi to $name!';
  }

  @override
  String get speciesMofu => 'fluff puff';

  @override
  String get speciesOink => 'piglet';

  @override
  String get speciesWuff => 'puppy';

  @override
  String get speciesBoop => 'boop';

  @override
  String eggLabel(String state) {
    return 'Egg. $state';
  }

  @override
  String get cardTabPlay => 'Play';

  @override
  String get cardTabWardrobe => 'Wardrobe';

  @override
  String get cardTabJournal => 'Journal';

  @override
  String cardHatched(String date) {
    return 'Hatched $date';
  }

  @override
  String cardLoves(String snack) {
    return 'Loves $snack';
  }

  @override
  String get cardLovesSecret => 'Favourite snack: a secret!';

  @override
  String cardLevel(int level) {
    return 'Friendship level $level';
  }

  @override
  String get cardRename => 'Rename';

  @override
  String get cardMoveTo => 'Move to…';

  @override
  String get cardTricks => 'Tricks';

  @override
  String get cardVoice => 'Voice';

  @override
  String get trickMastered => 'Mastered';

  @override
  String trickPractice(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count more days',
      one: '1 more day',
    );
    return '$_temp0';
  }

  @override
  String get trickTryIt => 'Try it!';

  @override
  String get trickDoneToday => 'Practised today';

  @override
  String get trickSit => 'Sit';

  @override
  String get trickPaw => 'Paw';

  @override
  String get trickSpin => 'Spin';

  @override
  String get trickSpeak => 'Speak';

  @override
  String get trickPlayDead => 'Play dead';

  @override
  String get trickHighFive => 'High five';

  @override
  String get wardrobeCoats => 'Coats';

  @override
  String get wardrobeAccessories => 'Accessories';

  @override
  String unlockLevel(int level) {
    return 'Friendship level $level';
  }

  @override
  String unlockStars(int stars) {
    return '$stars ★ in total';
  }

  @override
  String get unlockSeasonal => 'Seasonal';

  @override
  String journalCount(int have, int total) {
    return '$have of $total found';
  }

  @override
  String get journalHidden => '???';

  @override
  String get accScarf => 'Scarf';

  @override
  String get accBandana => 'Bandana';

  @override
  String get accBell => 'Bell collar';

  @override
  String get accBowtie => 'Bow tie';

  @override
  String voicePad(String name) {
    return 'Play $name\'s voice';
  }

  @override
  String toastTrickMastered(String name, String trick) {
    return '$name mastered $trick!';
  }

  @override
  String toastMoved(String name, String room) {
    return '$name went to the $room';
  }

  @override
  String get wearNone => 'None';

  @override
  String get settingsReduceMotion => 'Reduce motion';

  @override
  String get settingsCredits => 'Credits';

  @override
  String get creditsBody =>
      'Made with love by Ouadie Zerhouni. Every friend, room and sound in this app is original.';

  @override
  String get creditsAudio =>
      'Some sounds made with Stable Audio · Powered by Stability AI';

  @override
  String get resetHouseBody =>
      'This clears every friend, all stars, the wardrobe and the journal. It can\'t be undone.';

  @override
  String get photoTitle => 'Photo booth';

  @override
  String get photoBackdrop => 'Backdrop';

  @override
  String get photoFriends => 'Friends';

  @override
  String get photoStickers => 'Stickers';

  @override
  String get photoShare => 'Share';

  @override
  String get photoHint => 'Drag friends and stickers into place';

  @override
  String get photoClose => 'Close';

  @override
  String get photoShareText => 'My friends in Mofu';

  @override
  String get photoRemoveSticker => 'Double-tap a sticker to remove it';

  @override
  String get sleepSoundOff => 'Sounds are off. Turn them on in Settings.';
}
