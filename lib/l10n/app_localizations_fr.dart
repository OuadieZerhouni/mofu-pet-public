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
  String get roomLiving => 'Salon';

  @override
  String get roomSpa => 'Spa';

  @override
  String get roomKitchen => 'Cuisine';

  @override
  String get roomBedroom => 'Chambre';

  @override
  String get roomPlayroom => 'Jeux';

  @override
  String get roomGarden => 'Jardin';

  @override
  String get navPrevRoom => 'Pièce précédente';

  @override
  String get navNextRoom => 'Pièce suivante';

  @override
  String get navSettings => 'Réglages';

  @override
  String starsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count étoiles',
      one: '$count étoile',
    );
    return '$_temp0';
  }

  @override
  String friendsHere(int count, int max) {
    return '$count sur $max ici';
  }

  @override
  String get shelfTapHint => 'Touche un ami pour le faire venir ici';

  @override
  String get roomFull => 'Cette pièce est pleine : 4 amis maximum';

  @override
  String friendHereLabel(String name) {
    return '$name, dans cette pièce. Touche deux fois pour ouvrir sa fiche.';
  }

  @override
  String friendElsewhereLabel(String name) {
    return '$name. Touche deux fois pour le faire venir ici.';
  }

  @override
  String eggCoinLabel(int stars) {
    return 'Le prochain œuf éclot à $stars étoiles';
  }

  @override
  String toastStars(int count) {
    return '+$count ★';
  }

  @override
  String toastLevelUp(String name, int level) {
    return '$name a atteint le niveau d\'amitié $level !';
  }

  @override
  String get toastEggReady => 'Un œuf est prêt dans le jardin !';

  @override
  String toastFluffy(String name, int percent) {
    return 'Moelleux de $name : $percent % !';
  }

  @override
  String get bubbleFull => 'J\'ai bien mangé !';

  @override
  String get bubbleOink => 'Groin !';

  @override
  String get bubbleOinkQuestion => 'Groin ?';

  @override
  String get bubbleWoof => 'Ouaf !';

  @override
  String get bubbleAchoo => 'Atchoum !';

  @override
  String get bubbleYip => 'Yip !';

  @override
  String get bubbleHowl => 'Aouuu !';

  @override
  String get bubbleWhimper => 'Ouin…';

  @override
  String get bubbleGrrr => 'Grrr !';

  @override
  String get bubbleSqueak => 'Couic !';

  @override
  String get bubblePant => 'Ha-ha !';

  @override
  String get bubblePlay => 'On joue !';

  @override
  String get bubbleCombo10 => 'Boopi-boop !';

  @override
  String get bubbleCombo25 => 'Tempête de truffes !';

  @override
  String get bubbleCombo50 => 'Méga boop !';

  @override
  String get bubbleHi => 'Salut !';

  @override
  String get spaEmptyTitle => 'Le spa est prêt';

  @override
  String get spaEmptyHint => 'Touche un ami en bas pour l\'emmener au spa';

  @override
  String spaTitle(String name) {
    return 'Journée spa de $name';
  }

  @override
  String spaStepOf(int step, int total) {
    return 'Étape $step sur $total';
  }

  @override
  String get spaStepFoam => 'Mousse';

  @override
  String get spaStepRinse => 'Rinçage';

  @override
  String get spaStepTowel => 'Serviette';

  @override
  String get spaStepDry => 'Séchage';

  @override
  String get spaHintFoam => 'Frotte pour faire des bulles';

  @override
  String get spaHintRinse => 'Fais glisser la douche sur la mousse';

  @override
  String get spaHintTowel => 'Frotte doucement jusqu\'à ce que ce soit sec';

  @override
  String get spaHintDry => 'Sèche au sèche-cheveux pour un max de moelleux';

  @override
  String get spaHintDone => 'Tout frais ! Joue ou recommence';

  @override
  String get spaAgain => 'Encore un spa';

  @override
  String get spaFreshToast => 'Nouveau dans le journal : Journée spa';

  @override
  String get bubbleFresh => 'Tout frais !';

  @override
  String get snackApple => 'Pomme';

  @override
  String get snackCarrot => 'Carotte';

  @override
  String get snackCorn => 'Maïs';

  @override
  String get snackLettuce => 'Laitue';

  @override
  String get snackWatermelon => 'Pastèque';

  @override
  String get snackBone => 'Os';

  @override
  String get snackBacon => 'Lardon';

  @override
  String get snackCheese => 'Fromage';

  @override
  String get snackCupcake => 'Cupcake';

  @override
  String get snackBlueberry => 'Myrtilles';

  @override
  String get snackCherry => 'Cerises';

  @override
  String get snackGrape => 'Raisin';

  @override
  String get snackPeach => 'Pêche';

  @override
  String kitchenMenuFor(String name) {
    return 'Menu de $name · glisse vers la bouche';
  }

  @override
  String kitchenLeft(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Encore $count cette heure',
      one: 'Encore $count cette heure',
      zero: 'Plus faim pour l\'instant',
    );
    return '$_temp0';
  }

  @override
  String get kitchenEmptyHint =>
      'Touche un ami en bas pour l\'inviter à goûter';

  @override
  String kitchenFavoriteToast(String name, String snack) {
    return 'Préféré de $name : $snack ! +1 ★';
  }

  @override
  String get kitchenPickHint => 'Touche un ami pour choisir qui mange';

  @override
  String get bedLamp => 'Veilleuse';

  @override
  String get bedTuckIn => 'Border';

  @override
  String get bedWakeUp => 'Réveiller';

  @override
  String get sleepSounds => 'Sons pour dormir';

  @override
  String get sleepPlay => 'Lire';

  @override
  String get sleepStop => 'Stop';

  @override
  String get sleepMix => 'Mix';

  @override
  String get sleepTimer => 'Minuteur';

  @override
  String get sleepTimerOff => 'Aucun';

  @override
  String sleepMinutes(int minutes) {
    return '$minutes min';
  }

  @override
  String get sleepRain => 'Pluie';

  @override
  String get sleepPurr => 'Ronron';

  @override
  String get sleepFire => 'Cheminée';

  @override
  String get sleepOcean => 'Océan';

  @override
  String get sleepChimes => 'Carillon';

  @override
  String get sleepNoise => 'Bruit doux';

  @override
  String get sleepScreenOff => 'Continue de jouer écran éteint';

  @override
  String sleepEndsIn(int minutes) {
    return 'S\'arrête dans $minutes min';
  }

  @override
  String sleepVolume(String channel) {
    return 'Volume : $channel';
  }

  @override
  String get gameBoopRush => 'Boop Rush';

  @override
  String get gameBoopRushDesc =>
      'Fais un boop sur chaque truffe qui apparaît. 30 secondes.';

  @override
  String get gameSnackCatch => 'Snack Catch';

  @override
  String get gameSnackCatchDesc =>
      'Glisse un ami pour attraper les goûters et esquiver les abeilles. 45 secondes.';

  @override
  String gameBest(int score) {
    return 'Record $score';
  }

  @override
  String gameStarsCap(int count) {
    return 'Jusqu\'à $count ★ par jour';
  }

  @override
  String gamePlay(String game) {
    return 'Jouer à $game';
  }

  @override
  String get gameReady => 'Prêt ?';

  @override
  String get gameGo => 'Go !';

  @override
  String gameScore(int score) {
    return 'Score $score';
  }

  @override
  String gameTime(int seconds) {
    return '$seconds s';
  }

  @override
  String get gamePause => 'Pause';

  @override
  String get gameResume => 'Reprendre';

  @override
  String get gameQuit => 'Quitter';

  @override
  String get gameTimesUp => 'Temps écoulé !';

  @override
  String get gameNewBest => 'Nouveau record !';

  @override
  String gameStarsEarned(int count) {
    return '+$count ★';
  }

  @override
  String get gamePlayAgain => 'Rejouer';

  @override
  String get gameDone => 'Terminé';

  @override
  String get gameCatcherHint => 'Glisse à gauche et à droite';

  @override
  String get gameBoopHint =>
      'Fais boop sur les truffes ! Ne réveille pas les dormeurs.';

  @override
  String get gardenEggReadyTitle => 'Un nouvel œuf est prêt !';

  @override
  String get gardenEggReadyHint =>
      'Touche l\'œuf pour accueillir un nouvel ami';

  @override
  String gardenNextEgg(int stars) {
    return 'Prochain ami à $stars ★';
  }

  @override
  String gardenProgress(int have, int need) {
    return '$have sur $need ★';
  }

  @override
  String get gardenEggHint => 'Prends soin de tes amis pour gagner des étoiles';

  @override
  String get gardenAllHatched => 'Tout le monde a éclos !';

  @override
  String gardenEggNotYet(int stars) {
    return 'Cet œuf demande $stars ★';
  }

  @override
  String hatchNameTitle(String species) {
    return 'Ton nouvel ami : $species. Donne-lui un nom';
  }

  @override
  String get gardenGift => 'Cadeau du jour';

  @override
  String gardenGiftDay(int day) {
    return 'Cadeau du jour · jour $day';
  }

  @override
  String get gardenGiftClaimed => 'Reviens demain';

  @override
  String get gardenPhotoBooth => 'Cabine photo';

  @override
  String toastGift(int count) {
    return '+$count ★ · à demain !';
  }

  @override
  String toastNewFriend(String name) {
    return 'Dis bonjour à $name !';
  }

  @override
  String get speciesMofu => 'boule de poils';

  @override
  String get speciesOink => 'cochonnet';

  @override
  String get speciesWuff => 'chiot';

  @override
  String get speciesBoop => 'boop';

  @override
  String eggLabel(String state) {
    return 'Œuf. $state';
  }

  @override
  String get cardTabPlay => 'Jouer';

  @override
  String get cardTabWardrobe => 'Looks';

  @override
  String get cardTabJournal => 'Journal';

  @override
  String cardHatched(String date) {
    return 'Éclos le $date';
  }

  @override
  String cardLoves(String snack) {
    return 'Préféré : $snack';
  }

  @override
  String get cardLovesSecret => 'Goûter préféré : secret !';

  @override
  String cardLevel(int level) {
    return 'Niveau d\'amitié $level';
  }

  @override
  String get cardRename => 'Renommer';

  @override
  String get cardMoveTo => 'Déplacer vers…';

  @override
  String get cardTricks => 'Tours';

  @override
  String get cardVoice => 'Voix';

  @override
  String get trickMastered => 'Maîtrisé';

  @override
  String trickPractice(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Encore $count jours',
      one: 'Encore $count jour',
    );
    return '$_temp0';
  }

  @override
  String get trickTryIt => 'Essaie !';

  @override
  String get trickDoneToday => 'Entraîné aujourd\'hui';

  @override
  String get trickSit => 'Assis';

  @override
  String get trickPaw => 'Patte';

  @override
  String get trickSpin => 'Tourne';

  @override
  String get trickSpeak => 'Parle';

  @override
  String get trickPlayDead => 'Fais le mort';

  @override
  String get trickHighFive => 'Tope là';

  @override
  String get wardrobeCoats => 'Pelages';

  @override
  String get wardrobeAccessories => 'Accessoires';

  @override
  String unlockLevel(int level) {
    return 'Niveau d\'amitié $level';
  }

  @override
  String unlockStars(int stars) {
    return '$stars ★ au total';
  }

  @override
  String get unlockSeasonal => 'De saison';

  @override
  String journalCount(int have, int total) {
    return '$have sur $total trouvées';
  }

  @override
  String get journalHidden => '???';

  @override
  String get accScarf => 'Écharpe';

  @override
  String get accBandana => 'Bandana';

  @override
  String get accBell => 'Collier à grelot';

  @override
  String get accBowtie => 'Nœud papillon';

  @override
  String voicePad(String name) {
    return 'Écouter la voix de $name';
  }

  @override
  String toastTrickMastered(String name, String trick) {
    return '$name maîtrise le tour « $trick » !';
  }

  @override
  String toastMoved(String name, String room) {
    return '$name → $room';
  }

  @override
  String get wearNone => 'Aucun';

  @override
  String get settingsReduceMotion => 'Réduire les animations';

  @override
  String get settingsCredits => 'Crédits';

  @override
  String get creditsBody =>
      'Fait avec amour par Ouadie Zerhouni. Chaque ami, chaque pièce et chaque son de cette appli est original.';

  @override
  String get creditsAudio =>
      'Certains effets sonores créés avec Stable Audio · Powered by Stability AI';

  @override
  String get resetHouseBody =>
      'Cela efface tous les amis, toutes les étoiles, les looks et le journal. C\'est définitif.';

  @override
  String get photoTitle => 'Cabine photo';

  @override
  String get photoBackdrop => 'Décor';

  @override
  String get photoFriends => 'Amis';

  @override
  String get photoStickers => 'Stickers';

  @override
  String get photoShare => 'Partager';

  @override
  String get photoHint =>
      'Fais glisser les amis et les stickers pour les placer';

  @override
  String get photoClose => 'Fermer';

  @override
  String get photoShareText => 'Mes amis dans Mofu';

  @override
  String get photoRemoveSticker =>
      'Touche deux fois un sticker pour le retirer';

  @override
  String get sleepSoundOff =>
      'Les sons sont coupés. Active-les dans les Réglages.';
}
