// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appTitle => 'Mofu';

  @override
  String get dockBrush => 'Escova';

  @override
  String get dockSnacks => 'Lanches';

  @override
  String get dockWardrobe => 'Visual';

  @override
  String get dockJournal => 'Diário';

  @override
  String fluffPercent(int percent) {
    return '$percent% fofinho';
  }

  @override
  String daysTogether(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Dia $count juntos',
      one: 'Dia 1 juntos',
    );
    return '$_temp0';
  }

  @override
  String get coachPetMe => 'Faz carinho!';

  @override
  String coachBrush(String name) {
    return 'Escove com cuidado para deixar $name mais fofinho';
  }

  @override
  String snacksHint(String name) {
    return 'Arraste um lanche até a boca de $name';
  }

  @override
  String get firstRunTapSeed => 'Toque na sementinha de pelúcia';

  @override
  String get firstRunHello => 'Oi! Eu sou o seu Mofu';

  @override
  String get firstRunNameTitle => 'Qual vai ser o nome do seu Mofu?';

  @override
  String get nameFieldHint => 'Nome';

  @override
  String get actionSave => 'Salvar';

  @override
  String get actionSkip => 'Pular';

  @override
  String get actionCancel => 'Cancelar';

  @override
  String get actionClose => 'Fechar';

  @override
  String get actionOk => 'OK';

  @override
  String toastNewReaction(String name) {
    return 'Novo no diário: $name';
  }

  @override
  String toastUnlocked(String item) {
    return 'Desbloqueado: $item';
  }

  @override
  String get toastDailyBrush => 'Primeira escovada do dia ✨';

  @override
  String toastFluffMilestone(int percent) {
    return 'Mofu mofu! $percent% fofinho';
  }

  @override
  String get toastMaxFluff => 'MOFU MÁXIMO! O mais fofinho de todos';

  @override
  String toastFull(String name) {
    return '$name está cheio. Mais tarde!';
  }

  @override
  String toastSeasonal(String item) {
    return 'Chegou um presente da estação: $item';
  }

  @override
  String get snacksTitle => 'Lanches';

  @override
  String get wardrobeTitle => 'Visual';

  @override
  String get tabFur => 'Pelo';

  @override
  String get tabAccessories => 'Acessórios';

  @override
  String get badgeNew => 'Novo!';

  @override
  String lockedDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Visite em $count dias',
      one: 'Visite em 1 dia',
    );
    return '$_temp0';
  }

  @override
  String lockedFluff(int percent) {
    return 'Chegue a $percent% de fofura';
  }

  @override
  String lockedJournal(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Descubra $count reações',
      one: 'Descubra 1 reação',
    );
    return '$_temp0';
  }

  @override
  String lockedSnacks(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Divida $count lanches',
      one: 'Divida 1 lanche',
    );
    return '$_temp0';
  }

  @override
  String lockedSeasonal(String season) {
    return 'Sazonal: $season';
  }

  @override
  String get seasonHalloween => 'Halloween';

  @override
  String get seasonWinter => 'Festas de fim de ano';

  @override
  String get journalTitle => 'Diário';

  @override
  String journalProgress(int found, int total) {
    return '$found de $total descobertas';
  }

  @override
  String get journalUnknown => '???';

  @override
  String get settingsTitle => 'Ajustes';

  @override
  String get settingsSound => 'Sons';

  @override
  String get settingsHaptics => 'Vibração';

  @override
  String get settingsRename => 'Renomear';

  @override
  String get settingsPrivacy => 'Política de privacidade';

  @override
  String get settingsSupport => 'Ajuda e sugestões';

  @override
  String get settingsRate => 'Avaliar o Mofu';

  @override
  String settingsVersion(String version) {
    return 'Versão $version';
  }

  @override
  String get settingsReset => 'Recomeçar';

  @override
  String get resetTitle => 'Recomeçar?';

  @override
  String resetBody(String name) {
    return 'Isso apaga a fofura, o visual e o diário de $name. Não dá para desfazer.';
  }

  @override
  String get resetConfirm => 'Recomeçar';

  @override
  String get updateTitle => 'Nova atualização do Mofu';

  @override
  String get updateBody => 'Uma nova versão está pronta na App Store.';

  @override
  String get updateRequiredBody =>
      'Esta versão está muito antiga. Atualize para continuar.';

  @override
  String get updateAction => 'Atualizar';

  @override
  String get updateLater => 'Depois';

  @override
  String semanticsMofu(String name) {
    return '$name, o seu Mofu';
  }

  @override
  String get semanticsHug => 'Abraçar';

  @override
  String get semanticsBrushOn => 'Escova ligada';

  @override
  String get semanticsSettings => 'Ajustes';

  @override
  String get colorCream => 'Creme';

  @override
  String get colorPeach => 'Pêssego';

  @override
  String get colorMint => 'Menta';

  @override
  String get colorSky => 'Céu';

  @override
  String get colorLavender => 'Lavanda';

  @override
  String get colorSakura => 'Sakura';

  @override
  String get colorLemon => 'Limão';

  @override
  String get colorCocoa => 'Cacau';

  @override
  String get colorSnow => 'Neve';

  @override
  String get colorStarry => 'Noite estrelada';

  @override
  String get accNone => 'Nada';

  @override
  String get accBow => 'Laço';

  @override
  String get accSprout => 'Brotinho';

  @override
  String get accFlower => 'Margarida';

  @override
  String get accBeanie => 'Gorro';

  @override
  String get accStarclip => 'Presilha de estrela';

  @override
  String get accChef => 'Chapéu de chef';

  @override
  String get accHeadphones => 'Fones';

  @override
  String get accParty => 'Chapéu de festa';

  @override
  String get accGlasses => 'Óculos';

  @override
  String get accCrown => 'Coroa';

  @override
  String get accWitch => 'Chapéu de bruxa';

  @override
  String get accSanta => 'Gorro de Papai Noel';

  @override
  String get snackStrawberry => 'Morango';

  @override
  String get snackDango => 'Dango';

  @override
  String get snackCookie => 'Biscoito';

  @override
  String get snackOnigiri => 'Onigiri';

  @override
  String get snackPudding => 'Pudim';

  @override
  String get snackCandy => 'Bala';

  @override
  String get rxBoing => 'Boing';

  @override
  String get rxBoingHint => 'Dê um toquinho';

  @override
  String get rxTickle => 'Crise de cócegas';

  @override
  String get rxTickleHint => 'Toque, toque, toque, toque, toque!';

  @override
  String get rxPet => 'Carinho';

  @override
  String get rxPetHint => 'Acaricie o pelo';

  @override
  String get rxPurr => 'Ronrom';

  @override
  String get rxPurrHint => 'Continue o carinho por um tempo';

  @override
  String get rxSquish => 'Apertinho de mochi';

  @override
  String get rxSquishHint => 'Toque e segure';

  @override
  String get rxHug => 'Abraço apertado';

  @override
  String get rxHugHint => 'Segure mais um pouco';

  @override
  String get rxToss => 'Uhuuu!';

  @override
  String get rxTossHint => 'Segure, levante e solte';

  @override
  String get rxDizzyToss => 'Quica-quica';

  @override
  String get rxDizzyTossHint => 'Jogue bem alto';

  @override
  String get rxEyePoke => 'Ei!';

  @override
  String get rxEyePokeHint => 'Toque duas vezes num olho';

  @override
  String get rxShake => 'Terremoto';

  @override
  String get rxShakeHint => 'Sacuda o celular';

  @override
  String get rxBrush => 'Hora da escova';

  @override
  String get rxBrushHint => 'Use a escova';

  @override
  String get rxTidy => 'Arrumadinho';

  @override
  String get rxTidyHint => 'Escove o pelo bagunçado';

  @override
  String get rxYum => 'Nham!';

  @override
  String get rxYumHint => 'Divida um lanche';

  @override
  String get rxFavorite => 'Lanche favorito';

  @override
  String get rxFavoriteHint => 'Todo Mofu tem um';

  @override
  String get rxFull => 'Cheinho';

  @override
  String get rxFullHint => 'Lanches demais';

  @override
  String get rxSleep => 'Dorminhoco';

  @override
  String get rxSleepHint => 'Deixe descansar';

  @override
  String get rxWake => 'Bom dia';

  @override
  String get rxWakeHint => 'Acorde com carinho';

  @override
  String get rxNightOwl => 'Coruja da noite';

  @override
  String get rxNightOwlHint => 'Visite depois da meia-noite';

  @override
  String get rxEarlyBird => 'Madrugador';

  @override
  String get rxEarlyBirdHint => 'Visite ao nascer do sol';

  @override
  String get rxFluffy => 'Fofinho';

  @override
  String get rxFluffyHint => 'Chegue a 25% de fofura';

  @override
  String get rxMaxFluff => 'Mofu máximo';

  @override
  String get rxMaxFluffHint => 'Chegue a 100% de fofura';

  @override
  String get rxDressUp => 'Produzido';

  @override
  String get rxDressUpHint => 'Experimente um acessório';

  @override
  String get rxNewLook => 'Visual novo';

  @override
  String get rxNewLookHint => 'Troque a cor do pelo';

  @override
  String get rxSpin => 'Centrifugação';

  @override
  String get rxSpinHint => 'Faça carinho em círculos';

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
