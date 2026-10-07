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
}
