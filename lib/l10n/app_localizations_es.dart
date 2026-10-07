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
}
