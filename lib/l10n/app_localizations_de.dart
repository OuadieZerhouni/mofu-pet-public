// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appTitle => 'Mofu';

  @override
  String get dockBrush => 'Bürste';

  @override
  String get dockSnacks => 'Snacks';

  @override
  String get dockWardrobe => 'Outfits';

  @override
  String get dockJournal => 'Album';

  @override
  String fluffPercent(int percent) {
    return '$percent % flauschig';
  }

  @override
  String daysTogether(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Tag $count zusammen',
      one: 'Tag 1 zusammen',
    );
    return '$_temp0';
  }

  @override
  String get coachPetMe => 'Streichel mich!';

  @override
  String coachBrush(String name) {
    return 'Bürste sanft, damit $name flauschiger wird';
  }

  @override
  String snacksHint(String name) {
    return 'Zieh einen Snack zu ${name}s Mund';
  }

  @override
  String get firstRunTapSeed => 'Tippe auf den Flauschsamen';

  @override
  String get firstRunHello => 'Hallo! Ich bin dein Mofu';

  @override
  String get firstRunNameTitle => 'Wie soll dein Mofu heißen?';

  @override
  String get nameFieldHint => 'Name';

  @override
  String get actionSave => 'Speichern';

  @override
  String get actionSkip => 'Überspringen';

  @override
  String get actionCancel => 'Abbrechen';

  @override
  String get actionClose => 'Schließen';

  @override
  String get actionOk => 'OK';

  @override
  String toastNewReaction(String name) {
    return 'Neu im Album: $name';
  }

  @override
  String toastUnlocked(String item) {
    return 'Freigeschaltet: $item';
  }

  @override
  String get toastDailyBrush => 'Erstes Bürsten heute ✨';

  @override
  String toastFluffMilestone(int percent) {
    return 'Mofu mofu! $percent % flauschig';
  }

  @override
  String get toastMaxFluff => 'MAX MOFU! So flauschig wie nie';

  @override
  String toastFull(String name) {
    return '$name ist satt. Vielleicht später!';
  }

  @override
  String toastSeasonal(String item) {
    return 'Ein Saisongeschenk ist da: $item';
  }

  @override
  String get snacksTitle => 'Snacks';

  @override
  String get wardrobeTitle => 'Outfits';

  @override
  String get tabFur => 'Fell';

  @override
  String get tabAccessories => 'Accessoires';

  @override
  String get badgeNew => 'Neu!';

  @override
  String lockedDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'An $count Tagen besuchen',
      one: 'An 1 Tag besuchen',
    );
    return '$_temp0';
  }

  @override
  String lockedFluff(int percent) {
    return '$percent % Flausch erreichen';
  }

  @override
  String lockedJournal(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Reaktionen entdecken',
      one: '1 Reaktion entdecken',
    );
    return '$_temp0';
  }

  @override
  String lockedSnacks(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Snacks teilen',
      one: '1 Snack teilen',
    );
    return '$_temp0';
  }

  @override
  String lockedSeasonal(String season) {
    return 'Saisonal: $season';
  }

  @override
  String get seasonHalloween => 'Halloween';

  @override
  String get seasonWinter => 'Winterferien';

  @override
  String get journalTitle => 'Album';

  @override
  String journalProgress(int found, int total) {
    return '$found von $total entdeckt';
  }

  @override
  String get journalUnknown => '???';

  @override
  String get settingsTitle => 'Einstellungen';

  @override
  String get settingsSound => 'Töne';

  @override
  String get settingsHaptics => 'Vibration';

  @override
  String get settingsRename => 'Umbenennen';

  @override
  String get settingsPrivacy => 'Datenschutz';

  @override
  String get settingsSupport => 'Hilfe & Feedback';

  @override
  String get settingsRate => 'Mofu bewerten';

  @override
  String settingsVersion(String version) {
    return 'Version $version';
  }

  @override
  String get settingsReset => 'Neu anfangen';

  @override
  String get resetTitle => 'Neu anfangen?';

  @override
  String resetBody(String name) {
    return 'Damit werden ${name}s Flausch, Outfits und Album gelöscht. Das lässt sich nicht rückgängig machen.';
  }

  @override
  String get resetConfirm => 'Neu anfangen';

  @override
  String get updateTitle => 'Ein neues Mofu-Update';

  @override
  String get updateBody => 'Eine neue Version ist im App Store bereit.';

  @override
  String get updateRequiredBody =>
      'Diese Version ist zu alt. Bitte aktualisiere, um weiterzuspielen.';

  @override
  String get updateAction => 'Aktualisieren';

  @override
  String get updateLater => 'Später';

  @override
  String semanticsMofu(String name) {
    return '$name, dein Mofu';
  }

  @override
  String get semanticsHug => 'Umarmen';

  @override
  String get semanticsBrushOn => 'Bürste an';

  @override
  String get semanticsSettings => 'Einstellungen';

  @override
  String get colorCream => 'Creme';

  @override
  String get colorPeach => 'Pfirsich';

  @override
  String get colorMint => 'Minze';

  @override
  String get colorSky => 'Himmel';

  @override
  String get colorLavender => 'Lavendel';

  @override
  String get colorSakura => 'Sakura';

  @override
  String get colorLemon => 'Zitrone';

  @override
  String get colorCocoa => 'Kakao';

  @override
  String get colorSnow => 'Schnee';

  @override
  String get colorStarry => 'Sternennacht';

  @override
  String get accNone => 'Nichts';

  @override
  String get accBow => 'Schleife';

  @override
  String get accSprout => 'Sprössling';

  @override
  String get accFlower => 'Gänseblümchen';

  @override
  String get accBeanie => 'Mütze';

  @override
  String get accStarclip => 'Sternspange';

  @override
  String get accChef => 'Kochmütze';

  @override
  String get accHeadphones => 'Kopfhörer';

  @override
  String get accParty => 'Partyhut';

  @override
  String get accGlasses => 'Brille';

  @override
  String get accCrown => 'Krone';

  @override
  String get accWitch => 'Hexenhut';

  @override
  String get accSanta => 'Weihnachtsmütze';

  @override
  String get snackStrawberry => 'Erdbeere';

  @override
  String get snackDango => 'Dango';

  @override
  String get snackCookie => 'Keks';

  @override
  String get snackOnigiri => 'Onigiri';

  @override
  String get snackPudding => 'Pudding';

  @override
  String get snackCandy => 'Bonbon';

  @override
  String get rxBoing => 'Boing';

  @override
  String get rxBoingHint => 'Tippe sanft';

  @override
  String get rxTickle => 'Kicheranfall';

  @override
  String get rxTickleHint => 'Tipp, tipp, tipp, tipp, tipp!';

  @override
  String get rxPet => 'Streicheleinheit';

  @override
  String get rxPetHint => 'Streich übers Fell';

  @override
  String get rxPurr => 'Schnurr schnurr';

  @override
  String get rxPurrHint => 'Streichle eine Weile';

  @override
  String get rxSquish => 'Mochi-Knautsch';

  @override
  String get rxSquishHint => 'Drücken und halten';

  @override
  String get rxHug => 'Große Umarmung';

  @override
  String get rxHugHint => 'Etwas länger halten';

  @override
  String get rxToss => 'Juhuu!';

  @override
  String get rxTossHint => 'Halten, hochheben, loslassen';

  @override
  String get rxDizzyToss => 'Hüpf-Bonk';

  @override
  String get rxDizzyTossHint => 'Wirf es hoch';

  @override
  String get rxEyePoke => 'Hey!';

  @override
  String get rxEyePokeHint => 'Doppeltippe auf ein Auge';

  @override
  String get rxShake => 'Erdbeben';

  @override
  String get rxShakeHint => 'Schüttle dein Handy';

  @override
  String get rxBrush => 'Bürstzeit';

  @override
  String get rxBrushHint => 'Benutze die Bürste';

  @override
  String get rxTidy => 'Ganz ordentlich';

  @override
  String get rxTidyHint => 'Bürste zerzaustes Fell glatt';

  @override
  String get rxYum => 'Lecker!';

  @override
  String get rxYumHint => 'Teile einen Snack';

  @override
  String get rxFavorite => 'Lieblingssnack';

  @override
  String get rxFavoriteHint => 'Jedes Mofu hat einen';

  @override
  String get rxFull => 'Pappsatt';

  @override
  String get rxFullHint => 'Zu viele Snacks';

  @override
  String get rxSleep => 'Schlafmütze';

  @override
  String get rxSleepHint => 'Lass es ausruhen';

  @override
  String get rxWake => 'Guten Morgen';

  @override
  String get rxWakeHint => 'Weck es sanft';

  @override
  String get rxNightOwl => 'Nachteule';

  @override
  String get rxNightOwlHint => 'Besuch nach Mitternacht';

  @override
  String get rxEarlyBird => 'Frühaufsteher';

  @override
  String get rxEarlyBirdHint => 'Besuch bei Sonnenaufgang';

  @override
  String get rxFluffy => 'Flauschig';

  @override
  String get rxFluffyHint => 'Erreiche 25 % Flausch';

  @override
  String get rxMaxFluff => 'Max Mofu';

  @override
  String get rxMaxFluffHint => 'Erreiche 100 % Flausch';

  @override
  String get rxDressUp => 'Herausputzen';

  @override
  String get rxDressUpHint => 'Probier ein Accessoire';

  @override
  String get rxNewLook => 'Neuer Look';

  @override
  String get rxNewLookHint => 'Wechsle die Fellfarbe';

  @override
  String get rxSpin => 'Schleudergang';

  @override
  String get rxSpinHint => 'Streichle im Kreis';

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
      'Some sound effects made with Stable Audio · Powered by Stability AI';

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
}
