// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Mofu';

  @override
  String get dockBrush => 'Cepillo';

  @override
  String get dockSnacks => 'Snacks';

  @override
  String get dockWardrobe => 'Estilo';

  @override
  String get dockJournal => 'Diario';

  @override
  String fluffPercent(int percent) {
    return '$percent% esponjoso';
  }

  @override
  String daysTogether(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Día $count juntos',
      one: 'Día 1 juntos',
    );
    return '$_temp0';
  }

  @override
  String get coachPetMe => '¡Acaríciame!';

  @override
  String coachBrush(String name) {
    return 'Cepilla con suavidad para que $name sea más esponjoso';
  }

  @override
  String snacksHint(String name) {
    return 'Arrastra un snack a la boca de $name';
  }

  @override
  String get firstRunTapSeed => 'Toca la semilla de pelusa';

  @override
  String get firstRunHello => '¡Hola! Soy tu Mofu';

  @override
  String get firstRunNameTitle => '¿Cómo se llamará tu Mofu?';

  @override
  String get nameFieldHint => 'Nombre';

  @override
  String get actionSave => 'Guardar';

  @override
  String get actionSkip => 'Omitir';

  @override
  String get actionCancel => 'Cancelar';

  @override
  String get actionClose => 'Cerrar';

  @override
  String get actionOk => 'OK';

  @override
  String toastNewReaction(String name) {
    return 'Nuevo en el diario: $name';
  }

  @override
  String toastUnlocked(String item) {
    return 'Desbloqueado: $item';
  }

  @override
  String get toastDailyBrush => 'Primer cepillado del día ✨';

  @override
  String toastFluffMilestone(int percent) {
    return '¡Mofu mofu! $percent% esponjoso';
  }

  @override
  String get toastMaxFluff => '¡MOFU MÁXIMO! El más esponjoso de todos';

  @override
  String toastFull(String name) {
    return '$name está lleno. ¡Quizá luego!';
  }

  @override
  String toastSeasonal(String item) {
    return 'Llegó un regalo de temporada: $item';
  }

  @override
  String get snacksTitle => 'Snacks';

  @override
  String get wardrobeTitle => 'Estilo';

  @override
  String get tabFur => 'Pelo';

  @override
  String get tabAccessories => 'Accesorios';

  @override
  String get badgeNew => '¡Nuevo!';

  @override
  String lockedDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Visita $count días',
      one: 'Visita 1 día',
    );
    return '$_temp0';
  }

  @override
  String lockedFluff(int percent) {
    return 'Llega al $percent% de esponjosidad';
  }

  @override
  String lockedJournal(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Descubre $count reacciones',
      one: 'Descubre 1 reacción',
    );
    return '$_temp0';
  }

  @override
  String lockedSnacks(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Comparte $count snacks',
      one: 'Comparte 1 snack',
    );
    return '$_temp0';
  }

  @override
  String lockedSeasonal(String season) {
    return 'De temporada: $season';
  }

  @override
  String get seasonHalloween => 'Halloween';

  @override
  String get seasonWinter => 'Fiestas de invierno';

  @override
  String get journalTitle => 'Diario';

  @override
  String journalProgress(int found, int total) {
    return '$found de $total descubiertas';
  }

  @override
  String get journalUnknown => '???';

  @override
  String get settingsTitle => 'Ajustes';

  @override
  String get settingsSound => 'Sonidos';

  @override
  String get settingsHaptics => 'Vibración';

  @override
  String get settingsRename => 'Cambiar nombre';

  @override
  String get settingsPrivacy => 'Política de privacidad';

  @override
  String get settingsSupport => 'Ayuda y comentarios';

  @override
  String get settingsRate => 'Valorar Mofu';

  @override
  String settingsVersion(String version) {
    return 'Versión $version';
  }

  @override
  String get settingsReset => 'Empezar de nuevo';

  @override
  String get resetTitle => '¿Empezar de nuevo?';

  @override
  String resetBody(String name) {
    return 'Se borrarán la esponjosidad, el estilo y el diario de $name. No se puede deshacer.';
  }

  @override
  String get resetConfirm => 'Empezar de nuevo';

  @override
  String get updateTitle => 'Nueva actualización de Mofu';

  @override
  String get updateBody => 'Hay una versión nueva en el App Store.';

  @override
  String get updateRequiredBody =>
      'Esta versión es demasiado antigua. Actualiza para continuar.';

  @override
  String get updateAction => 'Actualizar';

  @override
  String get updateLater => 'Luego';

  @override
  String semanticsMofu(String name) {
    return '$name, tu Mofu';
  }

  @override
  String get semanticsHug => 'Abrazar';

  @override
  String get semanticsBrushOn => 'Cepillo activado';

  @override
  String get semanticsSettings => 'Ajustes';

  @override
  String get colorCream => 'Crema';

  @override
  String get colorPeach => 'Melocotón';

  @override
  String get colorMint => 'Menta';

  @override
  String get colorSky => 'Cielo';

  @override
  String get colorLavender => 'Lavanda';

  @override
  String get colorSakura => 'Sakura';

  @override
  String get colorLemon => 'Limón';

  @override
  String get colorCocoa => 'Cacao';

  @override
  String get colorSnow => 'Nieve';

  @override
  String get colorStarry => 'Noche estrellada';

  @override
  String get accNone => 'Nada';

  @override
  String get accBow => 'Lazo';

  @override
  String get accSprout => 'Brote';

  @override
  String get accFlower => 'Margarita';

  @override
  String get accBeanie => 'Gorro';

  @override
  String get accStarclip => 'Pinza de estrella';

  @override
  String get accChef => 'Gorro de chef';

  @override
  String get accHeadphones => 'Auriculares';

  @override
  String get accParty => 'Gorro de fiesta';

  @override
  String get accGlasses => 'Gafas';

  @override
  String get accCrown => 'Corona';

  @override
  String get accWitch => 'Sombrero de bruja';

  @override
  String get accSanta => 'Gorro de Papá Noel';

  @override
  String get snackStrawberry => 'Fresa';

  @override
  String get snackDango => 'Dango';

  @override
  String get snackCookie => 'Galleta';

  @override
  String get snackOnigiri => 'Onigiri';

  @override
  String get snackPudding => 'Flan';

  @override
  String get snackCandy => 'Caramelo';

  @override
  String get rxBoing => 'Boing';

  @override
  String get rxBoingHint => 'Dale un toquecito';

  @override
  String get rxTickle => 'Ataque de risa';

  @override
  String get rxTickleHint => '¡Toca, toca, toca, toca, toca!';

  @override
  String get rxPet => 'Mimos';

  @override
  String get rxPetHint => 'Acaricia su pelo';

  @override
  String get rxPurr => 'Rrrr';

  @override
  String get rxPurrHint => 'Sigue acariciando un rato';

  @override
  String get rxSquish => 'Apretón de mochi';

  @override
  String get rxSquishHint => 'Mantén pulsado';

  @override
  String get rxHug => 'Gran abrazo';

  @override
  String get rxHugHint => 'Mantén un poco más';

  @override
  String get rxToss => '¡Yupiii!';

  @override
  String get rxTossHint => 'Sujeta, levanta y suelta';

  @override
  String get rxDizzyToss => 'Rebote mareado';

  @override
  String get rxDizzyTossHint => 'Lánzalo alto';

  @override
  String get rxEyePoke => '¡Oye!';

  @override
  String get rxEyePokeHint => 'Toca dos veces un ojo';

  @override
  String get rxShake => 'Terremoto';

  @override
  String get rxShakeHint => 'Agita el móvil';

  @override
  String get rxBrush => 'Hora del cepillo';

  @override
  String get rxBrushHint => 'Usa el cepillo';

  @override
  String get rxTidy => 'Bien peinado';

  @override
  String get rxTidyHint => 'Cepilla el pelo alborotado';

  @override
  String get rxYum => '¡Ñam!';

  @override
  String get rxYumHint => 'Comparte un snack';

  @override
  String get rxFavorite => 'Snack favorito';

  @override
  String get rxFavoriteHint => 'Cada Mofu tiene uno';

  @override
  String get rxFull => 'Llenito';

  @override
  String get rxFullHint => 'Demasiados snacks';

  @override
  String get rxSleep => 'Dormilón';

  @override
  String get rxSleepHint => 'Déjalo descansar';

  @override
  String get rxWake => 'Buenos días';

  @override
  String get rxWakeHint => 'Despiértalo con cariño';

  @override
  String get rxNightOwl => 'Búho nocturno';

  @override
  String get rxNightOwlHint => 'Visita después de medianoche';

  @override
  String get rxEarlyBird => 'Madrugador';

  @override
  String get rxEarlyBirdHint => 'Visita al amanecer';

  @override
  String get rxFluffy => 'Esponjoso';

  @override
  String get rxFluffyHint => 'Llega al 25% de esponjosidad';

  @override
  String get rxMaxFluff => 'Mofu máximo';

  @override
  String get rxMaxFluffHint => 'Llega al 100% de esponjosidad';

  @override
  String get rxDressUp => 'De gala';

  @override
  String get rxDressUpHint => 'Prueba un accesorio';

  @override
  String get rxNewLook => 'Nuevo look';

  @override
  String get rxNewLookHint => 'Cambia el color del pelo';

  @override
  String get rxSpin => 'Centrifugado';

  @override
  String get rxSpinHint => 'Acaricia en círculos';

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
