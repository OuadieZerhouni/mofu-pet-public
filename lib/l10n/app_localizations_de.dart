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
  String get roomLiving => 'Wohnzimmer';

  @override
  String get roomSpa => 'Spa';

  @override
  String get roomKitchen => 'Küche';

  @override
  String get roomBedroom => 'Schlafzimmer';

  @override
  String get roomPlayroom => 'Spielzimmer';

  @override
  String get roomGarden => 'Garten';

  @override
  String get navPrevRoom => 'Vorheriger Raum';

  @override
  String get navNextRoom => 'Nächster Raum';

  @override
  String get navSettings => 'Einstellungen';

  @override
  String starsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Sterne',
      one: '1 Stern',
    );
    return '$_temp0';
  }

  @override
  String friendsHere(int count, int max) {
    return '$count von $max hier';
  }

  @override
  String get shelfTapHint => 'Tippe auf einen Freund, um ihn herzuholen';

  @override
  String get roomFull => 'Dieser Raum ist voll – höchstens 4 Freunde';

  @override
  String friendHereLabel(String name) {
    return '$name ist in diesem Raum. Doppeltippen für die Karte.';
  }

  @override
  String friendElsewhereLabel(String name) {
    return '$name. Doppeltippen, um hierherzuholen.';
  }

  @override
  String eggCoinLabel(int stars) {
    return 'Das nächste Ei schlüpft bei $stars Sternen';
  }

  @override
  String toastStars(int count) {
    return '+$count ★';
  }

  @override
  String toastLevelUp(String name, int level) {
    return '$name hat Freundschaftsstufe $level erreicht!';
  }

  @override
  String get toastEggReady => 'Im Garten wartet ein Ei!';

  @override
  String toastFluffy(String name, int percent) {
    return '$name ist zu $percent % flauschig!';
  }

  @override
  String get bubbleFull => 'Satt!';

  @override
  String get bubbleOink => 'Oink!';

  @override
  String get bubbleOinkQuestion => 'Oink?';

  @override
  String get bubbleWoof => 'Wuff!';

  @override
  String get bubbleAchoo => 'Hatschi!';

  @override
  String get bubbleYip => 'Kläff!';

  @override
  String get bubbleHowl => 'Auuuu!';

  @override
  String get bubbleWhimper => 'Fiep…';

  @override
  String get bubbleGrrr => 'Grrr!';

  @override
  String get bubbleSqueak => 'Quiek!';

  @override
  String get bubblePant => 'Hechel!';

  @override
  String get bubblePlay => 'Lass uns spielen!';

  @override
  String get bubbleCombo10 => 'Boppi-Boop!';

  @override
  String get bubbleCombo25 => 'Nasensturm!';

  @override
  String get bubbleCombo50 => 'Mega-Boop!';

  @override
  String get bubbleHi => 'Hi!';

  @override
  String get spaEmptyTitle => 'Das Spa ist bereit';

  @override
  String get spaEmptyHint =>
      'Tippe unten auf einen Freund, um ihn ins Spa zu holen';

  @override
  String spaTitle(String name) {
    return '${name}s Spa-Tag';
  }

  @override
  String spaStepOf(int step, int total) {
    return 'Schritt $step von $total';
  }

  @override
  String get spaStepFoam => 'Schaum';

  @override
  String get spaStepRinse => 'Spülen';

  @override
  String get spaStepTowel => 'Handtuch';

  @override
  String get spaStepDry => 'Föhnen';

  @override
  String get spaHintFoam => 'Rubbeln, damit Blasen entstehen';

  @override
  String get spaHintRinse => 'Zieh die Dusche über den Schaum';

  @override
  String get spaHintTowel => 'Sanft rubbeln, bis alles trocken ist';

  @override
  String get spaHintDry => 'Föhnen für extra Flausch';

  @override
  String get spaHintDone => 'Ganz frisch! Spielen oder nochmal';

  @override
  String get spaAgain => 'Nochmal Spa';

  @override
  String get spaFreshToast => 'Neu im Album: Spa-Tag';

  @override
  String get bubbleFresh => 'Frisch!';

  @override
  String get snackApple => 'Apfel';

  @override
  String get snackCarrot => 'Karotte';

  @override
  String get snackCorn => 'Mais';

  @override
  String get snackLettuce => 'Salat';

  @override
  String get snackWatermelon => 'Melone';

  @override
  String get snackBone => 'Knochen';

  @override
  String get snackBacon => 'Speckhappen';

  @override
  String get snackCheese => 'Käse';

  @override
  String get snackCupcake => 'Cupcake';

  @override
  String get snackBlueberry => 'Heidelbeeren';

  @override
  String get snackCherry => 'Kirschen';

  @override
  String get snackGrape => 'Trauben';

  @override
  String get snackPeach => 'Pfirsich';

  @override
  String kitchenMenuFor(String name) {
    return '${name}s Menü · zum Mund ziehen';
  }

  @override
  String kitchenLeft(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Noch $count in dieser Stunde',
      one: 'Noch 1 in dieser Stunde',
      zero: 'Erstmal satt',
    );
    return '$_temp0';
  }

  @override
  String get kitchenEmptyHint =>
      'Tippe unten auf einen Freund, um ihn zum Snack einzuladen';

  @override
  String kitchenFavoriteToast(String name, String snack) {
    return '$name liebt $snack! +1 ★';
  }

  @override
  String get kitchenPickHint => 'Tippe auf einen Freund, der essen soll';

  @override
  String get bedLamp => 'Nachtlicht';

  @override
  String get bedTuckIn => 'Zudecken';

  @override
  String get bedWakeUp => 'Wecken';

  @override
  String get sleepSounds => 'Einschlafklänge';

  @override
  String get sleepPlay => 'Start';

  @override
  String get sleepStop => 'Stopp';

  @override
  String get sleepMix => 'Mix';

  @override
  String get sleepTimer => 'Timer';

  @override
  String get sleepTimerOff => 'Aus';

  @override
  String sleepMinutes(int minutes) {
    return '$minutes Min.';
  }

  @override
  String get sleepRain => 'Regen';

  @override
  String get sleepPurr => 'Schnurren';

  @override
  String get sleepFire => 'Kamin';

  @override
  String get sleepOcean => 'Meer';

  @override
  String get sleepChimes => 'Windspiel';

  @override
  String get sleepNoise => 'Sanftes Rauschen';

  @override
  String get sleepScreenOff =>
      'Spielt auch bei ausgeschaltetem Bildschirm weiter';

  @override
  String sleepEndsIn(int minutes) {
    return 'Stoppt in $minutes Min.';
  }

  @override
  String sleepVolume(String channel) {
    return 'Lautstärke $channel';
  }

  @override
  String get gameBoopRush => 'Boop Rush';

  @override
  String get gameBoopRushDesc => 'Boop jede Nase, die auftaucht. 30 Sekunden.';

  @override
  String get gameSnackCatch => 'Snack Catch';

  @override
  String get gameSnackCatchDesc =>
      'Schiebe einen Freund, fang Snacks und weich den Bienen aus. 45 Sekunden.';

  @override
  String gameBest(int score) {
    return 'Rekord $score';
  }

  @override
  String gameStarsCap(int count) {
    return 'Bis zu $count ★ pro Tag';
  }

  @override
  String gamePlay(String game) {
    return '$game spielen';
  }

  @override
  String get gameReady => 'Bereit?';

  @override
  String get gameGo => 'Los!';

  @override
  String gameScore(int score) {
    return 'Punkte $score';
  }

  @override
  String gameTime(int seconds) {
    return '$seconds s';
  }

  @override
  String get gamePause => 'Pause';

  @override
  String get gameResume => 'Weiter';

  @override
  String get gameQuit => 'Beenden';

  @override
  String get gameTimesUp => 'Zeit ist um!';

  @override
  String get gameNewBest => 'Neuer Rekord!';

  @override
  String gameStarsEarned(int count) {
    return '+$count ★';
  }

  @override
  String get gamePlayAgain => 'Nochmal';

  @override
  String get gameDone => 'Fertig';

  @override
  String get gameCatcherHint => 'Nach links und rechts ziehen';

  @override
  String get gameBoopHint => 'Boop die Nasen! Weck die Schläfrigen nicht auf.';

  @override
  String get gardenEggReadyTitle => 'Ein neues Ei ist da!';

  @override
  String get gardenEggReadyHint =>
      'Tippe auf das Ei, um einen neuen Freund zu begrüßen';

  @override
  String gardenNextEgg(int stars) {
    return 'Nächster Freund bei $stars ★';
  }

  @override
  String gardenProgress(int have, int need) {
    return '$have von $need ★';
  }

  @override
  String get gardenEggHint =>
      'Kümmere dich um deine Freunde, um Sterne zu sammeln';

  @override
  String get gardenAllHatched => 'Alle sind geschlüpft!';

  @override
  String gardenEggNotYet(int stars) {
    return 'Dieses Ei braucht $stars ★';
  }

  @override
  String hatchNameTitle(String species) {
    return 'Dein neuer Freund: $species. Gib ihm einen Namen';
  }

  @override
  String get gardenGift => 'Tagesgeschenk';

  @override
  String gardenGiftDay(int day) {
    return 'Tagesgeschenk · Tag $day';
  }

  @override
  String get gardenGiftClaimed => 'Komm morgen wieder';

  @override
  String get gardenPhotoBooth => 'Fotobox';

  @override
  String toastGift(int count) {
    return '+$count ★ · bis morgen!';
  }

  @override
  String toastNewFriend(String name) {
    return 'Sag Hallo zu $name!';
  }

  @override
  String get speciesMofu => 'Flauschi';

  @override
  String get speciesOink => 'Ferkel';

  @override
  String get speciesWuff => 'Welpe';

  @override
  String get speciesBoop => 'Boop';

  @override
  String eggLabel(String state) {
    return 'Ei. $state';
  }

  @override
  String get cardTabPlay => 'Spielen';

  @override
  String get cardTabWardrobe => 'Outfits';

  @override
  String get cardTabJournal => 'Album';

  @override
  String cardHatched(String date) {
    return 'Geschlüpft am $date';
  }

  @override
  String cardLoves(String snack) {
    return 'Liebt: $snack';
  }

  @override
  String get cardLovesSecret => 'Lieblingssnack: ein Geheimnis!';

  @override
  String cardLevel(int level) {
    return 'Freundschaftsstufe $level';
  }

  @override
  String get cardRename => 'Umbenennen';

  @override
  String get cardMoveTo => 'Verschieben nach…';

  @override
  String get cardTricks => 'Tricks';

  @override
  String get cardVoice => 'Stimme';

  @override
  String get trickMastered => 'Gemeistert';

  @override
  String trickPractice(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Noch $count Tage',
      one: 'Noch 1 Tag',
    );
    return '$_temp0';
  }

  @override
  String get trickTryIt => 'Probier\'s!';

  @override
  String get trickDoneToday => 'Heute geübt';

  @override
  String get trickSit => 'Sitz';

  @override
  String get trickPaw => 'Pfötchen';

  @override
  String get trickSpin => 'Drehen';

  @override
  String get trickSpeak => 'Sprich';

  @override
  String get trickPlayDead => 'Totstellen';

  @override
  String get trickHighFive => 'High Five';

  @override
  String get wardrobeCoats => 'Felle';

  @override
  String get wardrobeAccessories => 'Accessoires';

  @override
  String unlockLevel(int level) {
    return 'Freundschaftsstufe $level';
  }

  @override
  String unlockStars(int stars) {
    return '$stars ★ insgesamt';
  }

  @override
  String get unlockSeasonal => 'Saisonal';

  @override
  String journalCount(int have, int total) {
    return '$have von $total gefunden';
  }

  @override
  String get journalHidden => '???';

  @override
  String get accScarf => 'Schal';

  @override
  String get accBandana => 'Halstuch';

  @override
  String get accBell => 'Glöckchen';

  @override
  String get accBowtie => 'Fliege';

  @override
  String voicePad(String name) {
    return '${name}s Stimme abspielen';
  }

  @override
  String toastTrickMastered(String name, String trick) {
    return '$name hat „$trick“ gemeistert!';
  }

  @override
  String toastMoved(String name, String room) {
    return '$name → $room';
  }

  @override
  String get wearNone => 'Keine';

  @override
  String get settingsReduceMotion => 'Weniger Bewegung';

  @override
  String get settingsCredits => 'Mitwirkende';

  @override
  String get creditsBody =>
      'Mit Liebe gemacht von Ouadie Zerhouni. Jeder Freund, jeder Raum und jeder Klang in dieser App ist original.';

  @override
  String get creditsAudio =>
      'Einige Soundeffekte mit Stable Audio erstellt · Powered by Stability AI';

  @override
  String get resetHouseBody =>
      'Damit werden alle Freunde, alle Sterne, die Outfits und das Album gelöscht. Das lässt sich nicht rückgängig machen.';

  @override
  String get photoTitle => 'Fotobox';

  @override
  String get photoBackdrop => 'Hintergrund';

  @override
  String get photoFriends => 'Freunde';

  @override
  String get photoStickers => 'Sticker';

  @override
  String get photoShare => 'Teilen';

  @override
  String get photoHint => 'Zieh Freunde und Sticker an die richtige Stelle';

  @override
  String get photoClose => 'Schließen';

  @override
  String get photoShareText => 'Meine Freunde in Mofu';

  @override
  String get photoRemoveSticker =>
      'Doppeltippe auf einen Sticker, um ihn zu entfernen';
}
