// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'Mofu';

  @override
  String get dockBrush => 'Brosse';

  @override
  String get dockSnacks => 'Goûters';

  @override
  String get dockWardrobe => 'Looks';

  @override
  String get dockJournal => 'Journal';

  @override
  String fluffPercent(int percent) {
    return '$percent % moelleux';
  }

  @override
  String daysTogether(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Jour $count ensemble',
      one: 'Jour 1 ensemble',
    );
    return '$_temp0';
  }

  @override
  String get coachPetMe => 'Caresse-moi !';

  @override
  String coachBrush(String name) {
    return 'Brosse doucement pour rendre $name plus moelleux';
  }

  @override
  String snacksHint(String name) {
    return 'Glisse un goûter jusqu\'à la bouche de $name';
  }

  @override
  String get firstRunTapSeed => 'Touche la graine de duvet';

  @override
  String get firstRunHello => 'Coucou ! Je suis ton Mofu';

  @override
  String get firstRunNameTitle => 'Comment s\'appellera ton Mofu ?';

  @override
  String get nameFieldHint => 'Nom';

  @override
  String get actionSave => 'Enregistrer';

  @override
  String get actionSkip => 'Passer';

  @override
  String get actionCancel => 'Annuler';

  @override
  String get actionClose => 'Fermer';

  @override
  String get actionOk => 'OK';

  @override
  String toastNewReaction(String name) {
    return 'Nouveau dans le journal : $name';
  }

  @override
  String toastUnlocked(String item) {
    return 'Débloqué : $item';
  }

  @override
  String get toastDailyBrush => 'Premier brossage du jour ✨';

  @override
  String toastFluffMilestone(int percent) {
    return 'Mofu mofu ! $percent % moelleux';
  }

  @override
  String get toastMaxFluff => 'MOFU MAX ! Le plus moelleux de tous';

  @override
  String toastFull(String name) {
    return '$name n\'a plus faim. Plus tard !';
  }

  @override
  String toastSeasonal(String item) {
    return 'Un cadeau de saison est arrivé : $item';
  }

  @override
  String get snacksTitle => 'Goûters';

  @override
  String get wardrobeTitle => 'Looks';

  @override
  String get tabFur => 'Pelage';

  @override
  String get tabAccessories => 'Accessoires';

  @override
  String get badgeNew => 'Nouveau !';

  @override
  String lockedDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Viens $count jours',
      one: 'Viens 1 jour',
    );
    return '$_temp0';
  }

  @override
  String lockedFluff(int percent) {
    return 'Atteins $percent % de moelleux';
  }

  @override
  String lockedJournal(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Découvre $count réactions',
      one: 'Découvre 1 réaction',
    );
    return '$_temp0';
  }

  @override
  String lockedSnacks(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Partage $count goûters',
      one: 'Partage 1 goûter',
    );
    return '$_temp0';
  }

  @override
  String lockedSeasonal(String season) {
    return 'Saisonnier : $season';
  }

  @override
  String get seasonHalloween => 'Halloween';

  @override
  String get seasonWinter => 'Fêtes d\'hiver';

  @override
  String get journalTitle => 'Journal';

  @override
  String journalProgress(int found, int total) {
    return '$found sur $total découvertes';
  }

  @override
  String get journalUnknown => '???';

  @override
  String get settingsTitle => 'Réglages';

  @override
  String get settingsSound => 'Sons';

  @override
  String get settingsHaptics => 'Vibrations';

  @override
  String get settingsRename => 'Renommer';

  @override
  String get settingsPrivacy => 'Confidentialité';

  @override
  String get settingsSupport => 'Aide et avis';

  @override
  String get settingsRate => 'Noter Mofu';

  @override
  String settingsVersion(String version) {
    return 'Version $version';
  }

  @override
  String get settingsReset => 'Recommencer';

  @override
  String get resetTitle => 'Recommencer ?';

  @override
  String resetBody(String name) {
    return 'Le moelleux, les looks et le journal de $name seront effacés. C\'est définitif.';
  }

  @override
  String get resetConfirm => 'Recommencer';

  @override
  String get updateTitle => 'Une mise à jour de Mofu';

  @override
  String get updateBody => 'Une nouvelle version t\'attend sur l\'App Store.';

  @override
  String get updateRequiredBody =>
      'Cette version est trop ancienne. Mets à jour pour continuer.';

  @override
  String get updateAction => 'Mettre à jour';

  @override
  String get updateLater => 'Plus tard';

  @override
  String semanticsMofu(String name) {
    return '$name, ton Mofu';
  }

  @override
  String get semanticsHug => 'Câlin';

  @override
  String get semanticsBrushOn => 'Brosse activée';

  @override
  String get semanticsSettings => 'Réglages';

  @override
  String get colorCream => 'Crème';

  @override
  String get colorPeach => 'Pêche';

  @override
  String get colorMint => 'Menthe';

  @override
  String get colorSky => 'Ciel';

  @override
  String get colorLavender => 'Lavande';

  @override
  String get colorSakura => 'Sakura';

  @override
  String get colorLemon => 'Citron';

  @override
  String get colorCocoa => 'Cacao';

  @override
  String get colorSnow => 'Neige';

  @override
  String get colorStarry => 'Nuit étoilée';

  @override
  String get accNone => 'Rien';

  @override
  String get accBow => 'Nœud';

  @override
  String get accSprout => 'Pousse';

  @override
  String get accFlower => 'Pâquerette';

  @override
  String get accBeanie => 'Bonnet';

  @override
  String get accStarclip => 'Barrette étoile';

  @override
  String get accChef => 'Toque';

  @override
  String get accHeadphones => 'Casque';

  @override
  String get accParty => 'Chapeau de fête';

  @override
  String get accGlasses => 'Lunettes';

  @override
  String get accCrown => 'Couronne';

  @override
  String get accWitch => 'Chapeau de sorcière';

  @override
  String get accSanta => 'Bonnet de Noël';

  @override
  String get snackStrawberry => 'Fraise';

  @override
  String get snackDango => 'Dango';

  @override
  String get snackCookie => 'Cookie';

  @override
  String get snackOnigiri => 'Onigiri';

  @override
  String get snackPudding => 'Flan';

  @override
  String get snackCandy => 'Bonbon';

  @override
  String get rxBoing => 'Boing';

  @override
  String get rxBoingHint => 'Touche-le doucement';

  @override
  String get rxTickle => 'Fou rire';

  @override
  String get rxTickleHint => 'Tap, tap, tap, tap, tap !';

  @override
  String get rxPet => 'Câlins';

  @override
  String get rxPetHint => 'Caresse son pelage';

  @override
  String get rxPurr => 'Ronron';

  @override
  String get rxPurrHint => 'Continue un moment';

  @override
  String get rxSquish => 'Écrasé de mochi';

  @override
  String get rxSquishHint => 'Appuie longuement';

  @override
  String get rxHug => 'Gros câlin';

  @override
  String get rxHugHint => 'Garde le doigt un peu plus';

  @override
  String get rxToss => 'Youpiii !';

  @override
  String get rxTossHint => 'Tiens, soulève et lâche';

  @override
  String get rxDizzyToss => 'Rebond étourdi';

  @override
  String get rxDizzyTossHint => 'Lance-le haut';

  @override
  String get rxEyePoke => 'Hé !';

  @override
  String get rxEyePokeHint => 'Touche deux fois un œil';

  @override
  String get rxShake => 'Tremblement de terre';

  @override
  String get rxShakeHint => 'Secoue ton téléphone';

  @override
  String get rxBrush => 'L\'heure de la brosse';

  @override
  String get rxBrushHint => 'Utilise la brosse';

  @override
  String get rxTidy => 'Tout lisse';

  @override
  String get rxTidyHint => 'Brosse le pelage ébouriffé';

  @override
  String get rxYum => 'Miam !';

  @override
  String get rxYumHint => 'Partage un goûter';

  @override
  String get rxFavorite => 'Goûter préféré';

  @override
  String get rxFavoriteHint => 'Chaque Mofu a le sien';

  @override
  String get rxFull => 'Repu';

  @override
  String get rxFullHint => 'Trop de goûters';

  @override
  String get rxSleep => 'Marmotte';

  @override
  String get rxSleepHint => 'Laisse-le se reposer';

  @override
  String get rxWake => 'Bonjour';

  @override
  String get rxWakeHint => 'Réveille-le doucement';

  @override
  String get rxNightOwl => 'Oiseau de nuit';

  @override
  String get rxNightOwlHint => 'Viens après minuit';

  @override
  String get rxEarlyBird => 'Lève-tôt';

  @override
  String get rxEarlyBirdHint => 'Viens au lever du soleil';

  @override
  String get rxFluffy => 'Moelleux';

  @override
  String get rxFluffyHint => 'Atteins 25 % de moelleux';

  @override
  String get rxMaxFluff => 'Mofu max';

  @override
  String get rxMaxFluffHint => 'Atteins 100 % de moelleux';

  @override
  String get rxDressUp => 'Sur son 31';

  @override
  String get rxDressUpHint => 'Essaie un accessoire';

  @override
  String get rxNewLook => 'Nouveau look';

  @override
  String get rxNewLookHint => 'Change de pelage';

  @override
  String get rxSpin => 'Essorage';

  @override
  String get rxSpinHint => 'Caresse en cercles';

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
