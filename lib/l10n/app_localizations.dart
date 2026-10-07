import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_pt.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ja'),
    Locale('de'),
    Locale('pt'),
    Locale('es'),
    Locale('fr'),
    Locale('ar'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Mofu'**
  String get appTitle;

  /// Bottom dock button labels. Keep each to one short word — four sit side by side on an iPhone SE.
  ///
  /// In en, this message translates to:
  /// **'Brush'**
  String get dockBrush;

  /// No description provided for @dockSnacks.
  ///
  /// In en, this message translates to:
  /// **'Snacks'**
  String get dockSnacks;

  /// No description provided for @dockWardrobe.
  ///
  /// In en, this message translates to:
  /// **'Wardrobe'**
  String get dockWardrobe;

  /// No description provided for @dockJournal.
  ///
  /// In en, this message translates to:
  /// **'Journal'**
  String get dockJournal;

  /// Fluff meter under the name, e.g. '42% fluffy'.
  ///
  /// In en, this message translates to:
  /// **'{percent}% fluffy'**
  String fluffPercent(int percent);

  /// How many distinct days the user has visited.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Day 1 together} other{Day {count} together}}'**
  String daysTogether(int count);

  /// Speech bubble from the creature on first launch, until the first stroke.
  ///
  /// In en, this message translates to:
  /// **'Pet me!'**
  String get coachPetMe;

  /// No description provided for @coachBrush.
  ///
  /// In en, this message translates to:
  /// **'Brush gently to make {name} fluffier'**
  String coachBrush(String name);

  /// No description provided for @snacksHint.
  ///
  /// In en, this message translates to:
  /// **'Drag a snack to {name}\'s mouth'**
  String snacksHint(String name);

  /// No description provided for @firstRunTapSeed.
  ///
  /// In en, this message translates to:
  /// **'Tap the fluff seed'**
  String get firstRunTapSeed;

  /// No description provided for @firstRunHello.
  ///
  /// In en, this message translates to:
  /// **'Hi! I\'m your Mofu'**
  String get firstRunHello;

  /// No description provided for @firstRunNameTitle.
  ///
  /// In en, this message translates to:
  /// **'What should we call your Mofu?'**
  String get firstRunNameTitle;

  /// No description provided for @nameFieldHint.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get nameFieldHint;

  /// No description provided for @actionSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get actionSave;

  /// No description provided for @actionSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get actionSkip;

  /// No description provided for @actionCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get actionCancel;

  /// No description provided for @actionClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get actionClose;

  /// No description provided for @actionOk.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get actionOk;

  /// No description provided for @toastNewReaction.
  ///
  /// In en, this message translates to:
  /// **'New in the journal: {name}'**
  String toastNewReaction(String name);

  /// No description provided for @toastUnlocked.
  ///
  /// In en, this message translates to:
  /// **'Unlocked: {item}'**
  String toastUnlocked(String item);

  /// No description provided for @toastDailyBrush.
  ///
  /// In en, this message translates to:
  /// **'First brush of the day ✨'**
  String get toastDailyBrush;

  /// No description provided for @toastFluffMilestone.
  ///
  /// In en, this message translates to:
  /// **'Mofu mofu! {percent}% fluffy'**
  String toastFluffMilestone(int percent);

  /// No description provided for @toastMaxFluff.
  ///
  /// In en, this message translates to:
  /// **'MAX MOFU! The fluffiest ever'**
  String get toastMaxFluff;

  /// No description provided for @toastFull.
  ///
  /// In en, this message translates to:
  /// **'{name} is full. Maybe later!'**
  String toastFull(String name);

  /// No description provided for @toastSeasonal.
  ///
  /// In en, this message translates to:
  /// **'A seasonal gift arrived: {item}'**
  String toastSeasonal(String item);

  /// No description provided for @snacksTitle.
  ///
  /// In en, this message translates to:
  /// **'Snacks'**
  String get snacksTitle;

  /// No description provided for @wardrobeTitle.
  ///
  /// In en, this message translates to:
  /// **'Wardrobe'**
  String get wardrobeTitle;

  /// No description provided for @tabFur.
  ///
  /// In en, this message translates to:
  /// **'Fur'**
  String get tabFur;

  /// No description provided for @tabAccessories.
  ///
  /// In en, this message translates to:
  /// **'Accessories'**
  String get tabAccessories;

  /// No description provided for @badgeNew.
  ///
  /// In en, this message translates to:
  /// **'New!'**
  String get badgeNew;

  /// No description provided for @lockedDays.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Visit on 1 day} other{Visit on {count} days}}'**
  String lockedDays(int count);

  /// No description provided for @lockedFluff.
  ///
  /// In en, this message translates to:
  /// **'Reach {percent}% fluff'**
  String lockedFluff(int percent);

  /// No description provided for @lockedJournal.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Discover 1 reaction} other{Discover {count} reactions}}'**
  String lockedJournal(int count);

  /// No description provided for @lockedSnacks.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Share 1 snack} other{Share {count} snacks}}'**
  String lockedSnacks(int count);

  /// No description provided for @lockedSeasonal.
  ///
  /// In en, this message translates to:
  /// **'Seasonal: {season}'**
  String lockedSeasonal(String season);

  /// No description provided for @seasonHalloween.
  ///
  /// In en, this message translates to:
  /// **'Halloween'**
  String get seasonHalloween;

  /// No description provided for @seasonWinter.
  ///
  /// In en, this message translates to:
  /// **'Winter holidays'**
  String get seasonWinter;

  /// No description provided for @journalTitle.
  ///
  /// In en, this message translates to:
  /// **'Journal'**
  String get journalTitle;

  /// No description provided for @journalProgress.
  ///
  /// In en, this message translates to:
  /// **'{found} of {total} discovered'**
  String journalProgress(int found, int total);

  /// No description provided for @journalUnknown.
  ///
  /// In en, this message translates to:
  /// **'???'**
  String get journalUnknown;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsSound.
  ///
  /// In en, this message translates to:
  /// **'Sounds'**
  String get settingsSound;

  /// No description provided for @settingsHaptics.
  ///
  /// In en, this message translates to:
  /// **'Haptics'**
  String get settingsHaptics;

  /// No description provided for @settingsRename.
  ///
  /// In en, this message translates to:
  /// **'Rename'**
  String get settingsRename;

  /// No description provided for @settingsPrivacy.
  ///
  /// In en, this message translates to:
  /// **'Privacy policy'**
  String get settingsPrivacy;

  /// No description provided for @settingsSupport.
  ///
  /// In en, this message translates to:
  /// **'Help & feedback'**
  String get settingsSupport;

  /// No description provided for @settingsRate.
  ///
  /// In en, this message translates to:
  /// **'Rate Mofu'**
  String get settingsRate;

  /// No description provided for @settingsVersion.
  ///
  /// In en, this message translates to:
  /// **'Version {version}'**
  String settingsVersion(String version);

  /// No description provided for @settingsReset.
  ///
  /// In en, this message translates to:
  /// **'Start over'**
  String get settingsReset;

  /// No description provided for @resetTitle.
  ///
  /// In en, this message translates to:
  /// **'Start over?'**
  String get resetTitle;

  /// No description provided for @resetBody.
  ///
  /// In en, this message translates to:
  /// **'This clears {name}\'s fluff, wardrobe and journal. It can\'t be undone.'**
  String resetBody(String name);

  /// No description provided for @resetConfirm.
  ///
  /// In en, this message translates to:
  /// **'Start over'**
  String get resetConfirm;

  /// No description provided for @updateTitle.
  ///
  /// In en, this message translates to:
  /// **'A new Mofu update'**
  String get updateTitle;

  /// No description provided for @updateBody.
  ///
  /// In en, this message translates to:
  /// **'A fresh version is ready on the App Store.'**
  String get updateBody;

  /// No description provided for @updateRequiredBody.
  ///
  /// In en, this message translates to:
  /// **'This version is too old to keep going. Please update to continue.'**
  String get updateRequiredBody;

  /// No description provided for @updateAction.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get updateAction;

  /// No description provided for @updateLater.
  ///
  /// In en, this message translates to:
  /// **'Later'**
  String get updateLater;

  /// VoiceOver label for the creature.
  ///
  /// In en, this message translates to:
  /// **'{name}, your Mofu'**
  String semanticsMofu(String name);

  /// No description provided for @semanticsHug.
  ///
  /// In en, this message translates to:
  /// **'Hug'**
  String get semanticsHug;

  /// No description provided for @semanticsBrushOn.
  ///
  /// In en, this message translates to:
  /// **'Brush on'**
  String get semanticsBrushOn;

  /// No description provided for @semanticsSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get semanticsSettings;

  /// No description provided for @colorCream.
  ///
  /// In en, this message translates to:
  /// **'Cream'**
  String get colorCream;

  /// No description provided for @colorPeach.
  ///
  /// In en, this message translates to:
  /// **'Peach'**
  String get colorPeach;

  /// No description provided for @colorMint.
  ///
  /// In en, this message translates to:
  /// **'Mint'**
  String get colorMint;

  /// No description provided for @colorSky.
  ///
  /// In en, this message translates to:
  /// **'Sky'**
  String get colorSky;

  /// No description provided for @colorLavender.
  ///
  /// In en, this message translates to:
  /// **'Lavender'**
  String get colorLavender;

  /// No description provided for @colorSakura.
  ///
  /// In en, this message translates to:
  /// **'Sakura'**
  String get colorSakura;

  /// No description provided for @colorLemon.
  ///
  /// In en, this message translates to:
  /// **'Lemon'**
  String get colorLemon;

  /// No description provided for @colorCocoa.
  ///
  /// In en, this message translates to:
  /// **'Cocoa'**
  String get colorCocoa;

  /// No description provided for @colorSnow.
  ///
  /// In en, this message translates to:
  /// **'Snow'**
  String get colorSnow;

  /// No description provided for @colorStarry.
  ///
  /// In en, this message translates to:
  /// **'Starry night'**
  String get colorStarry;

  /// No description provided for @accNone.
  ///
  /// In en, this message translates to:
  /// **'Nothing'**
  String get accNone;

  /// No description provided for @accBow.
  ///
  /// In en, this message translates to:
  /// **'Bow'**
  String get accBow;

  /// No description provided for @accSprout.
  ///
  /// In en, this message translates to:
  /// **'Sprout'**
  String get accSprout;

  /// No description provided for @accFlower.
  ///
  /// In en, this message translates to:
  /// **'Daisy'**
  String get accFlower;

  /// No description provided for @accBeanie.
  ///
  /// In en, this message translates to:
  /// **'Beanie'**
  String get accBeanie;

  /// No description provided for @accStarclip.
  ///
  /// In en, this message translates to:
  /// **'Star clip'**
  String get accStarclip;

  /// No description provided for @accChef.
  ///
  /// In en, this message translates to:
  /// **'Chef hat'**
  String get accChef;

  /// No description provided for @accHeadphones.
  ///
  /// In en, this message translates to:
  /// **'Headphones'**
  String get accHeadphones;

  /// No description provided for @accParty.
  ///
  /// In en, this message translates to:
  /// **'Party hat'**
  String get accParty;

  /// No description provided for @accGlasses.
  ///
  /// In en, this message translates to:
  /// **'Glasses'**
  String get accGlasses;

  /// No description provided for @accCrown.
  ///
  /// In en, this message translates to:
  /// **'Crown'**
  String get accCrown;

  /// No description provided for @accWitch.
  ///
  /// In en, this message translates to:
  /// **'Witch hat'**
  String get accWitch;

  /// No description provided for @accSanta.
  ///
  /// In en, this message translates to:
  /// **'Santa hat'**
  String get accSanta;

  /// No description provided for @snackStrawberry.
  ///
  /// In en, this message translates to:
  /// **'Strawberry'**
  String get snackStrawberry;

  /// No description provided for @snackDango.
  ///
  /// In en, this message translates to:
  /// **'Dango'**
  String get snackDango;

  /// No description provided for @snackCookie.
  ///
  /// In en, this message translates to:
  /// **'Cookie'**
  String get snackCookie;

  /// No description provided for @snackOnigiri.
  ///
  /// In en, this message translates to:
  /// **'Onigiri'**
  String get snackOnigiri;

  /// No description provided for @snackPudding.
  ///
  /// In en, this message translates to:
  /// **'Pudding'**
  String get snackPudding;

  /// No description provided for @snackCandy.
  ///
  /// In en, this message translates to:
  /// **'Candy'**
  String get snackCandy;

  /// No description provided for @rxBoing.
  ///
  /// In en, this message translates to:
  /// **'Boing'**
  String get rxBoing;

  /// No description provided for @rxBoingHint.
  ///
  /// In en, this message translates to:
  /// **'Give it a little tap'**
  String get rxBoingHint;

  /// No description provided for @rxTickle.
  ///
  /// In en, this message translates to:
  /// **'Tickle fit'**
  String get rxTickle;

  /// No description provided for @rxTickleHint.
  ///
  /// In en, this message translates to:
  /// **'Tap, tap, tap, tap, tap!'**
  String get rxTickleHint;

  /// No description provided for @rxPet.
  ///
  /// In en, this message translates to:
  /// **'Happy pets'**
  String get rxPet;

  /// No description provided for @rxPetHint.
  ///
  /// In en, this message translates to:
  /// **'Stroke its fur'**
  String get rxPetHint;

  /// No description provided for @rxPurr.
  ///
  /// In en, this message translates to:
  /// **'Purr purr'**
  String get rxPurr;

  /// No description provided for @rxPurrHint.
  ///
  /// In en, this message translates to:
  /// **'Keep petting for a while'**
  String get rxPurrHint;

  /// No description provided for @rxSquish.
  ///
  /// In en, this message translates to:
  /// **'Mochi squish'**
  String get rxSquish;

  /// No description provided for @rxSquishHint.
  ///
  /// In en, this message translates to:
  /// **'Press and hold'**
  String get rxSquishHint;

  /// No description provided for @rxHug.
  ///
  /// In en, this message translates to:
  /// **'Big hug'**
  String get rxHug;

  /// No description provided for @rxHugHint.
  ///
  /// In en, this message translates to:
  /// **'Hold a little longer'**
  String get rxHugHint;

  /// No description provided for @rxToss.
  ///
  /// In en, this message translates to:
  /// **'Wheee!'**
  String get rxToss;

  /// No description provided for @rxTossHint.
  ///
  /// In en, this message translates to:
  /// **'Hold, lift and let go'**
  String get rxTossHint;

  /// No description provided for @rxDizzyToss.
  ///
  /// In en, this message translates to:
  /// **'Bouncy bonk'**
  String get rxDizzyToss;

  /// No description provided for @rxDizzyTossHint.
  ///
  /// In en, this message translates to:
  /// **'Throw it high'**
  String get rxDizzyTossHint;

  /// No description provided for @rxEyePoke.
  ///
  /// In en, this message translates to:
  /// **'Hey!'**
  String get rxEyePoke;

  /// No description provided for @rxEyePokeHint.
  ///
  /// In en, this message translates to:
  /// **'Double-tap an eye'**
  String get rxEyePokeHint;

  /// No description provided for @rxShake.
  ///
  /// In en, this message translates to:
  /// **'Earthquake'**
  String get rxShake;

  /// No description provided for @rxShakeHint.
  ///
  /// In en, this message translates to:
  /// **'Shake your phone'**
  String get rxShakeHint;

  /// No description provided for @rxBrush.
  ///
  /// In en, this message translates to:
  /// **'Brushing time'**
  String get rxBrush;

  /// No description provided for @rxBrushHint.
  ///
  /// In en, this message translates to:
  /// **'Use the brush'**
  String get rxBrushHint;

  /// No description provided for @rxTidy.
  ///
  /// In en, this message translates to:
  /// **'All tidy'**
  String get rxTidy;

  /// No description provided for @rxTidyHint.
  ///
  /// In en, this message translates to:
  /// **'Brush away messy fur'**
  String get rxTidyHint;

  /// No description provided for @rxYum.
  ///
  /// In en, this message translates to:
  /// **'Yum!'**
  String get rxYum;

  /// No description provided for @rxYumHint.
  ///
  /// In en, this message translates to:
  /// **'Share a snack'**
  String get rxYumHint;

  /// No description provided for @rxFavorite.
  ///
  /// In en, this message translates to:
  /// **'Favourite snack'**
  String get rxFavorite;

  /// No description provided for @rxFavoriteHint.
  ///
  /// In en, this message translates to:
  /// **'Every Mofu has one'**
  String get rxFavoriteHint;

  /// No description provided for @rxFull.
  ///
  /// In en, this message translates to:
  /// **'So full'**
  String get rxFull;

  /// No description provided for @rxFullHint.
  ///
  /// In en, this message translates to:
  /// **'Too many snacks'**
  String get rxFullHint;

  /// No description provided for @rxSleep.
  ///
  /// In en, this message translates to:
  /// **'Sleepyhead'**
  String get rxSleep;

  /// No description provided for @rxSleepHint.
  ///
  /// In en, this message translates to:
  /// **'Let it rest'**
  String get rxSleepHint;

  /// No description provided for @rxWake.
  ///
  /// In en, this message translates to:
  /// **'Good morning'**
  String get rxWake;

  /// No description provided for @rxWakeHint.
  ///
  /// In en, this message translates to:
  /// **'Wake it gently'**
  String get rxWakeHint;

  /// No description provided for @rxNightOwl.
  ///
  /// In en, this message translates to:
  /// **'Night owl'**
  String get rxNightOwl;

  /// No description provided for @rxNightOwlHint.
  ///
  /// In en, this message translates to:
  /// **'Visit after midnight'**
  String get rxNightOwlHint;

  /// No description provided for @rxEarlyBird.
  ///
  /// In en, this message translates to:
  /// **'Early bird'**
  String get rxEarlyBird;

  /// No description provided for @rxEarlyBirdHint.
  ///
  /// In en, this message translates to:
  /// **'Visit at sunrise'**
  String get rxEarlyBirdHint;

  /// No description provided for @rxFluffy.
  ///
  /// In en, this message translates to:
  /// **'Fluffy'**
  String get rxFluffy;

  /// No description provided for @rxFluffyHint.
  ///
  /// In en, this message translates to:
  /// **'Reach 25% fluff'**
  String get rxFluffyHint;

  /// No description provided for @rxMaxFluff.
  ///
  /// In en, this message translates to:
  /// **'Max mofu'**
  String get rxMaxFluff;

  /// No description provided for @rxMaxFluffHint.
  ///
  /// In en, this message translates to:
  /// **'Reach 100% fluff'**
  String get rxMaxFluffHint;

  /// No description provided for @rxDressUp.
  ///
  /// In en, this message translates to:
  /// **'Dress up'**
  String get rxDressUp;

  /// No description provided for @rxDressUpHint.
  ///
  /// In en, this message translates to:
  /// **'Try an accessory'**
  String get rxDressUpHint;

  /// No description provided for @rxNewLook.
  ///
  /// In en, this message translates to:
  /// **'New look'**
  String get rxNewLook;

  /// No description provided for @rxNewLookHint.
  ///
  /// In en, this message translates to:
  /// **'Change its fur'**
  String get rxNewLookHint;

  /// No description provided for @rxSpin.
  ///
  /// In en, this message translates to:
  /// **'Spin cycle'**
  String get rxSpin;

  /// No description provided for @rxSpinHint.
  ///
  /// In en, this message translates to:
  /// **'Pet in circles'**
  String get rxSpinHint;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
    'ar',
    'de',
    'en',
    'es',
    'fr',
    'ja',
    'pt',
  ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
    case 'ja':
      return AppLocalizationsJa();
    case 'pt':
      return AppLocalizationsPt();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
