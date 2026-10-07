// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Mofu';

  @override
  String get dockBrush => 'Brush';

  @override
  String get dockSnacks => 'Snacks';

  @override
  String get dockWardrobe => 'Wardrobe';

  @override
  String get dockJournal => 'Journal';

  @override
  String fluffPercent(int percent) {
    return '$percent% fluffy';
  }

  @override
  String daysTogether(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Day $count together',
      one: 'Day 1 together',
    );
    return '$_temp0';
  }

  @override
  String get coachPetMe => 'Pet me!';

  @override
  String coachBrush(String name) {
    return 'Brush gently to make $name fluffier';
  }

  @override
  String snacksHint(String name) {
    return 'Drag a snack to $name\'s mouth';
  }

  @override
  String get firstRunTapSeed => 'Tap the fluff seed';

  @override
  String get firstRunHello => 'Hi! I\'m your Mofu';

  @override
  String get firstRunNameTitle => 'What should we call your Mofu?';

  @override
  String get nameFieldHint => 'Name';

  @override
  String get actionSave => 'Save';

  @override
  String get actionSkip => 'Skip';

  @override
  String get actionCancel => 'Cancel';

  @override
  String get actionClose => 'Close';

  @override
  String get actionOk => 'OK';

  @override
  String toastNewReaction(String name) {
    return 'New in the journal: $name';
  }

  @override
  String toastUnlocked(String item) {
    return 'Unlocked: $item';
  }

  @override
  String get toastDailyBrush => 'First brush of the day ✨';

  @override
  String toastFluffMilestone(int percent) {
    return 'Mofu mofu! $percent% fluffy';
  }

  @override
  String get toastMaxFluff => 'MAX MOFU! The fluffiest ever';

  @override
  String toastFull(String name) {
    return '$name is full. Maybe later!';
  }

  @override
  String toastSeasonal(String item) {
    return 'A seasonal gift arrived: $item';
  }

  @override
  String get snacksTitle => 'Snacks';

  @override
  String get wardrobeTitle => 'Wardrobe';

  @override
  String get tabFur => 'Fur';

  @override
  String get tabAccessories => 'Accessories';

  @override
  String get badgeNew => 'New!';

  @override
  String lockedDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Visit on $count days',
      one: 'Visit on 1 day',
    );
    return '$_temp0';
  }

  @override
  String lockedFluff(int percent) {
    return 'Reach $percent% fluff';
  }

  @override
  String lockedJournal(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Discover $count reactions',
      one: 'Discover 1 reaction',
    );
    return '$_temp0';
  }

  @override
  String lockedSnacks(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Share $count snacks',
      one: 'Share 1 snack',
    );
    return '$_temp0';
  }

  @override
  String lockedSeasonal(String season) {
    return 'Seasonal: $season';
  }

  @override
  String get seasonHalloween => 'Halloween';

  @override
  String get seasonWinter => 'Winter holidays';

  @override
  String get journalTitle => 'Journal';

  @override
  String journalProgress(int found, int total) {
    return '$found of $total discovered';
  }

  @override
  String get journalUnknown => '???';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsSound => 'Sounds';

  @override
  String get settingsHaptics => 'Haptics';

  @override
  String get settingsRename => 'Rename';

  @override
  String get settingsPrivacy => 'Privacy policy';

  @override
  String get settingsSupport => 'Help & feedback';

  @override
  String get settingsRate => 'Rate Mofu';

  @override
  String settingsVersion(String version) {
    return 'Version $version';
  }

  @override
  String get settingsReset => 'Start over';

  @override
  String get resetTitle => 'Start over?';

  @override
  String resetBody(String name) {
    return 'This clears $name\'s fluff, wardrobe and journal. It can\'t be undone.';
  }

  @override
  String get resetConfirm => 'Start over';

  @override
  String get updateTitle => 'A new Mofu update';

  @override
  String get updateBody => 'A fresh version is ready on the App Store.';

  @override
  String get updateRequiredBody =>
      'This version is too old to keep going. Please update to continue.';

  @override
  String get updateAction => 'Update';

  @override
  String get updateLater => 'Later';

  @override
  String semanticsMofu(String name) {
    return '$name, your Mofu';
  }

  @override
  String get semanticsHug => 'Hug';

  @override
  String get semanticsBrushOn => 'Brush on';

  @override
  String get semanticsSettings => 'Settings';

  @override
  String get colorCream => 'Cream';

  @override
  String get colorPeach => 'Peach';

  @override
  String get colorMint => 'Mint';

  @override
  String get colorSky => 'Sky';

  @override
  String get colorLavender => 'Lavender';

  @override
  String get colorSakura => 'Sakura';

  @override
  String get colorLemon => 'Lemon';

  @override
  String get colorCocoa => 'Cocoa';

  @override
  String get colorSnow => 'Snow';

  @override
  String get colorStarry => 'Starry night';

  @override
  String get accNone => 'Nothing';

  @override
  String get accBow => 'Bow';

  @override
  String get accSprout => 'Sprout';

  @override
  String get accFlower => 'Daisy';

  @override
  String get accBeanie => 'Beanie';

  @override
  String get accStarclip => 'Star clip';

  @override
  String get accChef => 'Chef hat';

  @override
  String get accHeadphones => 'Headphones';

  @override
  String get accParty => 'Party hat';

  @override
  String get accGlasses => 'Glasses';

  @override
  String get accCrown => 'Crown';

  @override
  String get accWitch => 'Witch hat';

  @override
  String get accSanta => 'Santa hat';

  @override
  String get snackStrawberry => 'Strawberry';

  @override
  String get snackDango => 'Dango';

  @override
  String get snackCookie => 'Cookie';

  @override
  String get snackOnigiri => 'Onigiri';

  @override
  String get snackPudding => 'Pudding';

  @override
  String get snackCandy => 'Candy';

  @override
  String get rxBoing => 'Boing';

  @override
  String get rxBoingHint => 'Give it a little tap';

  @override
  String get rxTickle => 'Tickle fit';

  @override
  String get rxTickleHint => 'Tap, tap, tap, tap, tap!';

  @override
  String get rxPet => 'Happy pets';

  @override
  String get rxPetHint => 'Stroke its fur';

  @override
  String get rxPurr => 'Purr purr';

  @override
  String get rxPurrHint => 'Keep petting for a while';

  @override
  String get rxSquish => 'Mochi squish';

  @override
  String get rxSquishHint => 'Press and hold';

  @override
  String get rxHug => 'Big hug';

  @override
  String get rxHugHint => 'Hold a little longer';

  @override
  String get rxToss => 'Wheee!';

  @override
  String get rxTossHint => 'Hold, lift and let go';

  @override
  String get rxDizzyToss => 'Bouncy bonk';

  @override
  String get rxDizzyTossHint => 'Throw it high';

  @override
  String get rxEyePoke => 'Hey!';

  @override
  String get rxEyePokeHint => 'Double-tap an eye';

  @override
  String get rxShake => 'Earthquake';

  @override
  String get rxShakeHint => 'Shake your phone';

  @override
  String get rxBrush => 'Brushing time';

  @override
  String get rxBrushHint => 'Use the brush';

  @override
  String get rxTidy => 'All tidy';

  @override
  String get rxTidyHint => 'Brush away messy fur';

  @override
  String get rxYum => 'Yum!';

  @override
  String get rxYumHint => 'Share a snack';

  @override
  String get rxFavorite => 'Favourite snack';

  @override
  String get rxFavoriteHint => 'Every Mofu has one';

  @override
  String get rxFull => 'So full';

  @override
  String get rxFullHint => 'Too many snacks';

  @override
  String get rxSleep => 'Sleepyhead';

  @override
  String get rxSleepHint => 'Let it rest';

  @override
  String get rxWake => 'Good morning';

  @override
  String get rxWakeHint => 'Wake it gently';

  @override
  String get rxNightOwl => 'Night owl';

  @override
  String get rxNightOwlHint => 'Visit after midnight';

  @override
  String get rxEarlyBird => 'Early bird';

  @override
  String get rxEarlyBirdHint => 'Visit at sunrise';

  @override
  String get rxFluffy => 'Fluffy';

  @override
  String get rxFluffyHint => 'Reach 25% fluff';

  @override
  String get rxMaxFluff => 'Max mofu';

  @override
  String get rxMaxFluffHint => 'Reach 100% fluff';

  @override
  String get rxDressUp => 'Dress up';

  @override
  String get rxDressUpHint => 'Try an accessory';

  @override
  String get rxNewLook => 'New look';

  @override
  String get rxNewLookHint => 'Change its fur';

  @override
  String get rxSpin => 'Spin cycle';

  @override
  String get rxSpinHint => 'Pet in circles';
}
