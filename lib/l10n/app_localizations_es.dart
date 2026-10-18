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
    return '¡Nuevo! $name';
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
  String get roomLiving => 'Sala';

  @override
  String get roomSpa => 'Spa';

  @override
  String get roomKitchen => 'Cocina';

  @override
  String get roomBedroom => 'Dormitorio';

  @override
  String get roomPlayroom => 'Juegos';

  @override
  String get roomGarden => 'Jardín';

  @override
  String get navPrevRoom => 'Habitación anterior';

  @override
  String get navNextRoom => 'Habitación siguiente';

  @override
  String get navSettings => 'Ajustes';

  @override
  String starsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count estrellas',
      one: '1 estrella',
    );
    return '$_temp0';
  }

  @override
  String friendsHere(int count, int max) {
    return '$count de $max aquí';
  }

  @override
  String get shelfTapHint => 'Toca a un amigo para traerlo aquí';

  @override
  String get roomFull => 'Esta habitación está llena: máximo 4 amigos';

  @override
  String friendHereLabel(String name) {
    return '$name, en esta habitación. Toca dos veces para ver su ficha.';
  }

  @override
  String friendElsewhereLabel(String name) {
    return '$name. Toca dos veces para traerlo aquí.';
  }

  @override
  String eggCoinLabel(int stars) {
    return 'El próximo huevo eclosiona con $stars estrellas';
  }

  @override
  String toastStars(int count) {
    return '+$count ★';
  }

  @override
  String toastLevelUp(String name, int level) {
    return '¡$name llegó al nivel de amistad $level!';
  }

  @override
  String get toastEggReady => '¡Hay un huevo listo en el jardín!';

  @override
  String toastFluffy(String name, int percent) {
    return '¡Esponjosidad de $name: $percent%!';
  }

  @override
  String get bubbleFull => '¡Ya comí!';

  @override
  String get bubbleOink => '¡Oink!';

  @override
  String get bubbleOinkQuestion => '¿Oink?';

  @override
  String get bubbleWoof => '¡Guau!';

  @override
  String get bubbleAchoo => '¡Achís!';

  @override
  String get bubbleYip => '¡Yip!';

  @override
  String get bubbleHowl => '¡Auuu!';

  @override
  String get bubbleWhimper => 'Ñiii…';

  @override
  String get bubbleGrrr => '¡Grrr!';

  @override
  String get bubbleSqueak => '¡Quiii!';

  @override
  String get bubblePant => '¡Jah, jah!';

  @override
  String get bubblePlay => '¡A jugar!';

  @override
  String get bubbleCombo10 => '¡Bipi-boop!';

  @override
  String get bubbleCombo25 => '¡Tormenta de hocicos!';

  @override
  String get bubbleCombo50 => '¡Mega boop!';

  @override
  String get bubbleHi => '¡Hola!';

  @override
  String get spaEmptyTitle => 'El spa está listo';

  @override
  String get spaEmptyHint => 'Toca a un amigo abajo para llevarlo al spa';

  @override
  String spaTitle(String name) {
    return 'Día de spa de $name';
  }

  @override
  String spaStepOf(int step, int total) {
    return 'Paso $step de $total';
  }

  @override
  String get spaStepFoam => 'Espuma';

  @override
  String get spaStepRinse => 'Enjuague';

  @override
  String get spaStepTowel => 'Toalla';

  @override
  String get spaStepDry => 'Secado';

  @override
  String get spaHintFoam => 'Frota para hacer burbujas';

  @override
  String get spaHintRinse => 'Arrastra la ducha sobre la espuma';

  @override
  String get spaHintTowel => 'Frota con suavidad hasta secar';

  @override
  String get spaHintDry => 'Sécalo para más esponjosidad';

  @override
  String get spaHintDone => '¡Bien fresquito! Juega o empieza de nuevo';

  @override
  String get spaAgain => 'Otro spa';

  @override
  String get spaFreshToast => 'Nuevo en el diario: Día de spa';

  @override
  String get bubbleFresh => '¡Fresquito!';

  @override
  String get snackApple => 'Manzana';

  @override
  String get snackCarrot => 'Zanahoria';

  @override
  String get snackCorn => 'Maíz';

  @override
  String get snackLettuce => 'Lechuga';

  @override
  String get snackWatermelon => 'Sandía';

  @override
  String get snackBone => 'Hueso';

  @override
  String get snackBacon => 'Tocino';

  @override
  String get snackCheese => 'Queso';

  @override
  String get snackCupcake => 'Cupcake';

  @override
  String get snackBlueberry => 'Arándanos';

  @override
  String get snackCherry => 'Cerezas';

  @override
  String get snackGrape => 'Uvas';

  @override
  String get snackPeach => 'Durazno';

  @override
  String kitchenMenuFor(String name) {
    return 'Menú de $name · arrastra a la boca';
  }

  @override
  String kitchenLeft(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count más esta hora',
      one: '1 más esta hora',
      zero: 'Lleno por ahora',
    );
    return '$_temp0';
  }

  @override
  String get kitchenEmptyHint =>
      'Toca a un amigo abajo para invitarlo a un snack';

  @override
  String kitchenFavoriteToast(String name, String snack) {
    return '¡Favorito de $name: $snack! +1 ★';
  }

  @override
  String get kitchenPickHint => 'Toca a un amigo para elegir quién come';

  @override
  String get bedLamp => 'Luz nocturna';

  @override
  String get bedTuckIn => 'Arropar';

  @override
  String get bedWakeUp => 'Despertar';

  @override
  String get sleepSounds => 'Sonidos para dormir';

  @override
  String get sleepPlay => 'Reproducir';

  @override
  String get sleepStop => 'Detener';

  @override
  String get sleepMix => 'Mezcla';

  @override
  String get sleepTimer => 'Timer';

  @override
  String get sleepTimerOff => 'Apagado';

  @override
  String sleepMinutes(int minutes) {
    return '$minutes min';
  }

  @override
  String get sleepRain => 'Lluvia';

  @override
  String get sleepPurr => 'Ronroneo';

  @override
  String get sleepFire => 'Chimenea';

  @override
  String get sleepOcean => 'Océano';

  @override
  String get sleepChimes => 'Campanillas';

  @override
  String get sleepNoise => 'Ruido suave';

  @override
  String get sleepScreenOff => 'Sigue sonando con la pantalla apagada';

  @override
  String sleepEndsIn(int minutes) {
    return 'Se detiene en $minutes min';
  }

  @override
  String sleepVolume(String channel) {
    return 'Volumen: $channel';
  }

  @override
  String get gameBoopRush => 'Boop Rush';

  @override
  String get gameBoopRushDesc =>
      'Hazle boop a cada hocico que aparezca. 30 segundos.';

  @override
  String get gameSnackCatch => 'Snack Catch';

  @override
  String get gameSnackCatchDesc =>
      'Desliza a un amigo para atrapar snacks y esquivar las abejas. 45 segundos.';

  @override
  String gameBest(int score) {
    return 'Récord $score';
  }

  @override
  String gameStarsCap(int count) {
    return 'Hasta $count ★ al día';
  }

  @override
  String gamePlay(String game) {
    return 'Jugar $game';
  }

  @override
  String get gameReady => '¿Listo?';

  @override
  String get gameGo => '¡Ya!';

  @override
  String gameScore(int score) {
    return 'Puntos $score';
  }

  @override
  String gameTime(int seconds) {
    return '$seconds s';
  }

  @override
  String get gamePause => 'Pausa';

  @override
  String get gameResume => 'Reanudar';

  @override
  String get gameQuit => 'Salir';

  @override
  String get gameTimesUp => '¡Se acabó el tiempo!';

  @override
  String get gameNewBest => '¡Nuevo récord!';

  @override
  String gameStarsEarned(int count) {
    return '+$count ★';
  }

  @override
  String get gamePlayAgain => 'Otra vez';

  @override
  String get gameDone => 'Listo';

  @override
  String get gameCatcherHint => 'Arrastra a izquierda y derecha';

  @override
  String get gameBoopHint =>
      '¡Haz boop en los hocicos! No despiertes a los dormilones.';

  @override
  String get gardenEggReadyTitle => '¡Hay un huevo nuevo!';

  @override
  String get gardenEggReadyHint =>
      'Toca el huevo para recibir a un nuevo amigo';

  @override
  String gardenNextEgg(int stars) {
    return 'Próximo amigo con $stars ★';
  }

  @override
  String gardenProgress(int have, int need) {
    return '$have de $need ★';
  }

  @override
  String get gardenEggHint => 'Cuida a tus amigos para ganar estrellas';

  @override
  String get gardenAllHatched => '¡Todos han eclosionado!';

  @override
  String gardenEggNotYet(int stars) {
    return 'Este huevo necesita $stars ★';
  }

  @override
  String hatchNameTitle(String species) {
    return 'Tu nuevo amigo: $species. Ponle un nombre';
  }

  @override
  String get gardenGift => 'Regalo diario';

  @override
  String gardenGiftDay(int day) {
    return 'Regalo diario · día $day';
  }

  @override
  String get gardenGiftClaimed => 'Vuelve mañana';

  @override
  String get gardenPhotoBooth => 'Cabina de fotos';

  @override
  String toastGift(int count) {
    return '+$count ★ · ¡hasta mañana!';
  }

  @override
  String toastNewFriend(String name) {
    return '¡Saluda a $name!';
  }

  @override
  String get speciesMofu => 'bolita de pelusa';

  @override
  String get speciesOink => 'cerdito';

  @override
  String get speciesWuff => 'cachorro';

  @override
  String get speciesBoop => 'boop';

  @override
  String eggLabel(String state) {
    return 'Huevo. $state';
  }

  @override
  String get cardTabPlay => 'Jugar';

  @override
  String get cardTabWardrobe => 'Estilo';

  @override
  String get cardTabJournal => 'Diario';

  @override
  String cardHatched(String date) {
    return 'Nació el $date';
  }

  @override
  String cardLoves(String snack) {
    return 'Favorito: $snack';
  }

  @override
  String get cardLovesSecret => 'Snack favorito: ¡un secreto!';

  @override
  String cardLevel(int level) {
    return 'Nivel de amistad $level';
  }

  @override
  String get cardRename => 'Cambiar nombre';

  @override
  String get cardMoveTo => 'Mover a…';

  @override
  String get cardTricks => 'Trucos';

  @override
  String get cardVoice => 'Voz';

  @override
  String get trickMastered => 'Dominado';

  @override
  String trickPractice(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count días más',
      one: '1 día más',
    );
    return '$_temp0';
  }

  @override
  String get trickTryIt => '¡Pruébalo!';

  @override
  String get trickDoneToday => 'Practicado hoy';

  @override
  String get trickSit => 'Sentarse';

  @override
  String get trickPaw => 'Pata';

  @override
  String get trickSpin => 'Girar';

  @override
  String get trickSpeak => 'Hablar';

  @override
  String get trickPlayDead => 'Hacerse el muerto';

  @override
  String get trickHighFive => 'Choca cinco';

  @override
  String get wardrobeCoats => 'Pelajes';

  @override
  String get wardrobeAccessories => 'Accesorios';

  @override
  String unlockLevel(int level) {
    return 'Nivel de amistad $level';
  }

  @override
  String unlockStars(int stars) {
    return '$stars ★ en total';
  }

  @override
  String get unlockSeasonal => 'De temporada';

  @override
  String journalCount(int have, int total) {
    return '$have de $total encontradas';
  }

  @override
  String get journalHidden => '???';

  @override
  String get accScarf => 'Bufanda';

  @override
  String get accBandana => 'Pañuelo';

  @override
  String get accBell => 'Collar de cascabel';

  @override
  String get accBowtie => 'Corbatín';

  @override
  String voicePad(String name) {
    return 'Reproducir la voz de $name';
  }

  @override
  String toastTrickMastered(String name, String trick) {
    return '¡$name dominó el truco «$trick»!';
  }

  @override
  String toastMoved(String name, String room) {
    return '$name → $room';
  }

  @override
  String get wearNone => 'Nada';

  @override
  String get settingsReduceMotion => 'Reducir movimiento';

  @override
  String get settingsCredits => 'Créditos';

  @override
  String get creditsBody =>
      'Hecho con cariño por Ouadie Zerhouni. Cada amigo, habitación y sonido de esta app es original.';

  @override
  String get creditsAudio =>
      'Algunos sonidos hechos con Stable Audio · Powered by Stability AI';

  @override
  String get resetHouseBody =>
      'Se borrarán todos los amigos, las estrellas, el estilo y el diario. No se puede deshacer.';

  @override
  String get photoTitle => 'Cabina de fotos';

  @override
  String get photoBackdrop => 'Fondo';

  @override
  String get photoFriends => 'Amigos';

  @override
  String get photoStickers => 'Stickers';

  @override
  String get photoShare => 'Compartir';

  @override
  String get photoHint => 'Arrastra amigos y stickers a su lugar';

  @override
  String get photoClose => 'Cerrar';

  @override
  String get photoShareText => 'Mis amigos en Mofu';

  @override
  String get photoRemoveSticker => 'Toca dos veces un sticker para quitarlo';

  @override
  String get sleepSoundOff =>
      'Los sonidos están desactivados. Actívalos en Ajustes.';
}
