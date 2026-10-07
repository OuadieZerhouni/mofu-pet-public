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
    return 'Nouveau ! $name';
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
}
