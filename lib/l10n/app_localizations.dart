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

  /// Toast when a reaction is discovered for the first time.
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

  /// Room names, shown in the room switcher at the top.
  ///
  /// In en, this message translates to:
  /// **'Living room'**
  String get roomLiving;

  /// No description provided for @roomSpa.
  ///
  /// In en, this message translates to:
  /// **'Spa'**
  String get roomSpa;

  /// No description provided for @roomKitchen.
  ///
  /// In en, this message translates to:
  /// **'Kitchen'**
  String get roomKitchen;

  /// No description provided for @roomBedroom.
  ///
  /// In en, this message translates to:
  /// **'Bedroom'**
  String get roomBedroom;

  /// No description provided for @roomPlayroom.
  ///
  /// In en, this message translates to:
  /// **'Playroom'**
  String get roomPlayroom;

  /// No description provided for @roomGarden.
  ///
  /// In en, this message translates to:
  /// **'Garden'**
  String get roomGarden;

  /// Accessibility labels for the room switcher arrows.
  ///
  /// In en, this message translates to:
  /// **'Previous room'**
  String get navPrevRoom;

  /// No description provided for @navNextRoom.
  ///
  /// In en, this message translates to:
  /// **'Next room'**
  String get navNextRoom;

  /// No description provided for @navSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get navSettings;

  /// Accessibility label of the star counter.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 star} other{{count} stars}}'**
  String starsCount(int count);

  /// Shelf caption: friends in this room.
  ///
  /// In en, this message translates to:
  /// **'{count} of {max} here'**
  String friendsHere(int count, int max);

  /// Shelf caption on the right.
  ///
  /// In en, this message translates to:
  /// **'Tap a friend to bring them here'**
  String get shelfTapHint;

  /// Toast when a fifth friend would join a room.
  ///
  /// In en, this message translates to:
  /// **'This room is full — 4 friends at most'**
  String get roomFull;

  /// Accessibility label of a friend coin.
  ///
  /// In en, this message translates to:
  /// **'{name}, in this room. Double-tap for their card.'**
  String friendHereLabel(String name);

  /// No description provided for @friendElsewhereLabel.
  ///
  /// In en, this message translates to:
  /// **'{name}. Double-tap to bring them here.'**
  String friendElsewhereLabel(String name);

  /// No description provided for @eggCoinLabel.
  ///
  /// In en, this message translates to:
  /// **'Next egg hatches at {stars} stars'**
  String eggCoinLabel(int stars);

  /// Toast when stars are earned.
  ///
  /// In en, this message translates to:
  /// **'+{count} ★'**
  String toastStars(int count);

  /// No description provided for @toastLevelUp.
  ///
  /// In en, this message translates to:
  /// **'{name} reached friendship level {level}!'**
  String toastLevelUp(String name, int level);

  /// No description provided for @toastEggReady.
  ///
  /// In en, this message translates to:
  /// **'An egg is ready in the garden!'**
  String get toastEggReady;

  /// No description provided for @toastFluffy.
  ///
  /// In en, this message translates to:
  /// **'{name} is {percent}% fluffy!'**
  String toastFluffy(String name, int percent);

  /// Speech bubbles friends say.
  ///
  /// In en, this message translates to:
  /// **'I\'m full!'**
  String get bubbleFull;

  /// No description provided for @bubbleOink.
  ///
  /// In en, this message translates to:
  /// **'Oink!'**
  String get bubbleOink;

  /// No description provided for @bubbleOinkQuestion.
  ///
  /// In en, this message translates to:
  /// **'Oink?'**
  String get bubbleOinkQuestion;

  /// The bark word of this language (Wuff, Guau, Ouaf, Au au, ワン, هاو).
  ///
  /// In en, this message translates to:
  /// **'Woof!'**
  String get bubbleWoof;

  /// No description provided for @bubbleAchoo.
  ///
  /// In en, this message translates to:
  /// **'Achoo!'**
  String get bubbleAchoo;

  /// No description provided for @bubbleYip.
  ///
  /// In en, this message translates to:
  /// **'Yip!'**
  String get bubbleYip;

  /// No description provided for @bubbleHowl.
  ///
  /// In en, this message translates to:
  /// **'Awooo!'**
  String get bubbleHowl;

  /// No description provided for @bubbleWhimper.
  ///
  /// In en, this message translates to:
  /// **'Whimper…'**
  String get bubbleWhimper;

  /// No description provided for @bubbleGrrr.
  ///
  /// In en, this message translates to:
  /// **'Grrr!'**
  String get bubbleGrrr;

  /// No description provided for @bubbleSqueak.
  ///
  /// In en, this message translates to:
  /// **'Squeak!'**
  String get bubbleSqueak;

  /// No description provided for @bubblePant.
  ///
  /// In en, this message translates to:
  /// **'Hah-hah!'**
  String get bubblePant;

  /// No description provided for @bubblePlay.
  ///
  /// In en, this message translates to:
  /// **'Let\'s play!'**
  String get bubblePlay;

  /// Boop combo milestones (10, 25, 50).
  ///
  /// In en, this message translates to:
  /// **'Boop-a-doop!'**
  String get bubbleCombo10;

  /// No description provided for @bubbleCombo25.
  ///
  /// In en, this message translates to:
  /// **'Snoot storm!'**
  String get bubbleCombo25;

  /// No description provided for @bubbleCombo50.
  ///
  /// In en, this message translates to:
  /// **'Mega boop!'**
  String get bubbleCombo50;

  /// No description provided for @bubbleHi.
  ///
  /// In en, this message translates to:
  /// **'Hi!'**
  String get bubbleHi;

  /// Spa ribbon title when nobody is on the mat.
  ///
  /// In en, this message translates to:
  /// **'The spa is ready'**
  String get spaEmptyTitle;

  /// No description provided for @spaEmptyHint.
  ///
  /// In en, this message translates to:
  /// **'Tap a friend below to bring them to the spa'**
  String get spaEmptyHint;

  /// No description provided for @spaTitle.
  ///
  /// In en, this message translates to:
  /// **'{name}\'s spa day'**
  String spaTitle(String name);

  /// No description provided for @spaStepOf.
  ///
  /// In en, this message translates to:
  /// **'Step {step} of {total}'**
  String spaStepOf(int step, int total);

  /// Spa steps and tool names. Keep each to one short word.
  ///
  /// In en, this message translates to:
  /// **'Foam'**
  String get spaStepFoam;

  /// No description provided for @spaStepRinse.
  ///
  /// In en, this message translates to:
  /// **'Rinse'**
  String get spaStepRinse;

  /// No description provided for @spaStepTowel.
  ///
  /// In en, this message translates to:
  /// **'Towel'**
  String get spaStepTowel;

  /// No description provided for @spaStepDry.
  ///
  /// In en, this message translates to:
  /// **'Dry'**
  String get spaStepDry;

  /// No description provided for @spaHintFoam.
  ///
  /// In en, this message translates to:
  /// **'Rub to make bubbles'**
  String get spaHintFoam;

  /// No description provided for @spaHintRinse.
  ///
  /// In en, this message translates to:
  /// **'Drag the shower over the foam'**
  String get spaHintRinse;

  /// No description provided for @spaHintTowel.
  ///
  /// In en, this message translates to:
  /// **'Rub gently until dry'**
  String get spaHintTowel;

  /// No description provided for @spaHintDry.
  ///
  /// In en, this message translates to:
  /// **'Blow-dry for extra fluff'**
  String get spaHintDry;

  /// No description provided for @spaHintDone.
  ///
  /// In en, this message translates to:
  /// **'All fresh! Play, or start again'**
  String get spaHintDone;

  /// No description provided for @spaAgain.
  ///
  /// In en, this message translates to:
  /// **'Spa again'**
  String get spaAgain;

  /// No description provided for @spaFreshToast.
  ///
  /// In en, this message translates to:
  /// **'New in the journal: Spa day'**
  String get spaFreshToast;

  /// No description provided for @bubbleFresh.
  ///
  /// In en, this message translates to:
  /// **'Fresh!'**
  String get bubbleFresh;

  /// Snack names in the kitchen tray. One or two short words.
  ///
  /// In en, this message translates to:
  /// **'Apple'**
  String get snackApple;

  /// No description provided for @snackCarrot.
  ///
  /// In en, this message translates to:
  /// **'Carrot'**
  String get snackCarrot;

  /// No description provided for @snackCorn.
  ///
  /// In en, this message translates to:
  /// **'Corn'**
  String get snackCorn;

  /// No description provided for @snackLettuce.
  ///
  /// In en, this message translates to:
  /// **'Lettuce'**
  String get snackLettuce;

  /// No description provided for @snackWatermelon.
  ///
  /// In en, this message translates to:
  /// **'Melon'**
  String get snackWatermelon;

  /// No description provided for @snackBone.
  ///
  /// In en, this message translates to:
  /// **'Bone'**
  String get snackBone;

  /// No description provided for @snackBacon.
  ///
  /// In en, this message translates to:
  /// **'Bacon bite'**
  String get snackBacon;

  /// No description provided for @snackCheese.
  ///
  /// In en, this message translates to:
  /// **'Cheese'**
  String get snackCheese;

  /// No description provided for @snackCupcake.
  ///
  /// In en, this message translates to:
  /// **'Cupcake'**
  String get snackCupcake;

  /// No description provided for @snackBlueberry.
  ///
  /// In en, this message translates to:
  /// **'Blueberries'**
  String get snackBlueberry;

  /// No description provided for @snackCherry.
  ///
  /// In en, this message translates to:
  /// **'Cherries'**
  String get snackCherry;

  /// No description provided for @snackGrape.
  ///
  /// In en, this message translates to:
  /// **'Grapes'**
  String get snackGrape;

  /// No description provided for @snackPeach.
  ///
  /// In en, this message translates to:
  /// **'Peach'**
  String get snackPeach;

  /// Kitchen shelf caption.
  ///
  /// In en, this message translates to:
  /// **'{name}\'s menu · drag to the mouth'**
  String kitchenMenuFor(String name);

  /// No description provided for @kitchenLeft.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{Full for now} =1{1 more this hour} other{{count} more this hour}}'**
  String kitchenLeft(int count);

  /// No description provided for @kitchenEmptyHint.
  ///
  /// In en, this message translates to:
  /// **'Tap a friend below to invite them for a snack'**
  String get kitchenEmptyHint;

  /// No description provided for @kitchenFavoriteToast.
  ///
  /// In en, this message translates to:
  /// **'{name} loves {snack}! +1 ★'**
  String kitchenFavoriteToast(String name, String snack);

  /// No description provided for @kitchenPickHint.
  ///
  /// In en, this message translates to:
  /// **'Tap a friend to choose who eats'**
  String get kitchenPickHint;

  /// Bedroom shelf buttons.
  ///
  /// In en, this message translates to:
  /// **'Night light'**
  String get bedLamp;

  /// No description provided for @bedTuckIn.
  ///
  /// In en, this message translates to:
  /// **'Tuck in'**
  String get bedTuckIn;

  /// No description provided for @bedWakeUp.
  ///
  /// In en, this message translates to:
  /// **'Wake up'**
  String get bedWakeUp;

  /// No description provided for @sleepSounds.
  ///
  /// In en, this message translates to:
  /// **'Sleep sounds'**
  String get sleepSounds;

  /// No description provided for @sleepPlay.
  ///
  /// In en, this message translates to:
  /// **'Play'**
  String get sleepPlay;

  /// No description provided for @sleepStop.
  ///
  /// In en, this message translates to:
  /// **'Stop'**
  String get sleepStop;

  /// No description provided for @sleepMix.
  ///
  /// In en, this message translates to:
  /// **'Mix'**
  String get sleepMix;

  /// No description provided for @sleepTimer.
  ///
  /// In en, this message translates to:
  /// **'Timer'**
  String get sleepTimer;

  /// Sleep timer off.
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get sleepTimerOff;

  /// No description provided for @sleepMinutes.
  ///
  /// In en, this message translates to:
  /// **'{minutes} min'**
  String sleepMinutes(int minutes);

  /// Sleep sound channels.
  ///
  /// In en, this message translates to:
  /// **'Rain'**
  String get sleepRain;

  /// No description provided for @sleepPurr.
  ///
  /// In en, this message translates to:
  /// **'Purr'**
  String get sleepPurr;

  /// No description provided for @sleepFire.
  ///
  /// In en, this message translates to:
  /// **'Fireplace'**
  String get sleepFire;

  /// No description provided for @sleepOcean.
  ///
  /// In en, this message translates to:
  /// **'Ocean'**
  String get sleepOcean;

  /// No description provided for @sleepChimes.
  ///
  /// In en, this message translates to:
  /// **'Wind chimes'**
  String get sleepChimes;

  /// No description provided for @sleepNoise.
  ///
  /// In en, this message translates to:
  /// **'Soft noise'**
  String get sleepNoise;

  /// No description provided for @sleepScreenOff.
  ///
  /// In en, this message translates to:
  /// **'Keeps playing with the screen off'**
  String get sleepScreenOff;

  /// No description provided for @sleepEndsIn.
  ///
  /// In en, this message translates to:
  /// **'Stops in {minutes} min'**
  String sleepEndsIn(int minutes);

  /// Accessibility label of a mixer slider.
  ///
  /// In en, this message translates to:
  /// **'{channel} volume'**
  String sleepVolume(String channel);

  /// Mini-game names.
  ///
  /// In en, this message translates to:
  /// **'Boop Rush'**
  String get gameBoopRush;

  /// No description provided for @gameBoopRushDesc.
  ///
  /// In en, this message translates to:
  /// **'Boop every snoot that pops up. 30 seconds.'**
  String get gameBoopRushDesc;

  /// No description provided for @gameSnackCatch.
  ///
  /// In en, this message translates to:
  /// **'Snack Catch'**
  String get gameSnackCatch;

  /// No description provided for @gameSnackCatchDesc.
  ///
  /// In en, this message translates to:
  /// **'Slide a friend to catch snacks, dodge the bees. 45 seconds.'**
  String get gameSnackCatchDesc;

  /// No description provided for @gameBest.
  ///
  /// In en, this message translates to:
  /// **'Best {score}'**
  String gameBest(int score);

  /// No description provided for @gameStarsCap.
  ///
  /// In en, this message translates to:
  /// **'Up to {count} ★ a day'**
  String gameStarsCap(int count);

  /// No description provided for @gamePlay.
  ///
  /// In en, this message translates to:
  /// **'Play {game}'**
  String gamePlay(String game);

  /// No description provided for @gameReady.
  ///
  /// In en, this message translates to:
  /// **'Ready?'**
  String get gameReady;

  /// No description provided for @gameGo.
  ///
  /// In en, this message translates to:
  /// **'Go!'**
  String get gameGo;

  /// No description provided for @gameScore.
  ///
  /// In en, this message translates to:
  /// **'Score {score}'**
  String gameScore(int score);

  /// No description provided for @gameTime.
  ///
  /// In en, this message translates to:
  /// **'{seconds}s'**
  String gameTime(int seconds);

  /// No description provided for @gamePause.
  ///
  /// In en, this message translates to:
  /// **'Pause'**
  String get gamePause;

  /// No description provided for @gameResume.
  ///
  /// In en, this message translates to:
  /// **'Resume'**
  String get gameResume;

  /// No description provided for @gameQuit.
  ///
  /// In en, this message translates to:
  /// **'Quit'**
  String get gameQuit;

  /// No description provided for @gameTimesUp.
  ///
  /// In en, this message translates to:
  /// **'Time\'s up!'**
  String get gameTimesUp;

  /// No description provided for @gameNewBest.
  ///
  /// In en, this message translates to:
  /// **'New best!'**
  String get gameNewBest;

  /// No description provided for @gameStarsEarned.
  ///
  /// In en, this message translates to:
  /// **'+{count} ★'**
  String gameStarsEarned(int count);

  /// No description provided for @gamePlayAgain.
  ///
  /// In en, this message translates to:
  /// **'Play again'**
  String get gamePlayAgain;

  /// No description provided for @gameDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get gameDone;

  /// No description provided for @gameCatcherHint.
  ///
  /// In en, this message translates to:
  /// **'Drag left and right'**
  String get gameCatcherHint;

  /// No description provided for @gameBoopHint.
  ///
  /// In en, this message translates to:
  /// **'Boop the snoots! Don\'t wake the sleepy ones.'**
  String get gameBoopHint;

  /// Garden hatchery card.
  ///
  /// In en, this message translates to:
  /// **'A new egg is ready!'**
  String get gardenEggReadyTitle;

  /// No description provided for @gardenEggReadyHint.
  ///
  /// In en, this message translates to:
  /// **'Tap the egg to welcome a new friend'**
  String get gardenEggReadyHint;

  /// No description provided for @gardenNextEgg.
  ///
  /// In en, this message translates to:
  /// **'Next friend at {stars} ★'**
  String gardenNextEgg(int stars);

  /// No description provided for @gardenProgress.
  ///
  /// In en, this message translates to:
  /// **'{have} of {need} ★'**
  String gardenProgress(int have, int need);

  /// No description provided for @gardenEggHint.
  ///
  /// In en, this message translates to:
  /// **'Care for your friends to earn stars'**
  String get gardenEggHint;

  /// No description provided for @gardenAllHatched.
  ///
  /// In en, this message translates to:
  /// **'Everyone has hatched!'**
  String get gardenAllHatched;

  /// No description provided for @gardenEggNotYet.
  ///
  /// In en, this message translates to:
  /// **'This egg needs {stars} ★'**
  String gardenEggNotYet(int stars);

  /// No description provided for @hatchNameTitle.
  ///
  /// In en, this message translates to:
  /// **'Name your new {species}'**
  String hatchNameTitle(String species);

  /// No description provided for @gardenGift.
  ///
  /// In en, this message translates to:
  /// **'Daily gift'**
  String get gardenGift;

  /// No description provided for @gardenGiftDay.
  ///
  /// In en, this message translates to:
  /// **'Daily gift · day {day}'**
  String gardenGiftDay(int day);

  /// No description provided for @gardenGiftClaimed.
  ///
  /// In en, this message translates to:
  /// **'Come back tomorrow'**
  String get gardenGiftClaimed;

  /// No description provided for @gardenPhotoBooth.
  ///
  /// In en, this message translates to:
  /// **'Photo booth'**
  String get gardenPhotoBooth;

  /// No description provided for @toastGift.
  ///
  /// In en, this message translates to:
  /// **'+{count} ★ · see you tomorrow!'**
  String toastGift(int count);

  /// No description provided for @toastNewFriend.
  ///
  /// In en, this message translates to:
  /// **'Say hi to {name}!'**
  String toastNewFriend(String name);

  /// Species names, lowercase inside a sentence (Name your new …).
  ///
  /// In en, this message translates to:
  /// **'fluff puff'**
  String get speciesMofu;

  /// No description provided for @speciesOink.
  ///
  /// In en, this message translates to:
  /// **'piglet'**
  String get speciesOink;

  /// No description provided for @speciesWuff.
  ///
  /// In en, this message translates to:
  /// **'puppy'**
  String get speciesWuff;

  /// No description provided for @speciesBoop.
  ///
  /// In en, this message translates to:
  /// **'boop'**
  String get speciesBoop;

  /// Accessibility label of the garden egg.
  ///
  /// In en, this message translates to:
  /// **'Egg. {state}'**
  String eggLabel(String state);

  /// Friend card tabs.
  ///
  /// In en, this message translates to:
  /// **'Play'**
  String get cardTabPlay;

  /// No description provided for @cardTabWardrobe.
  ///
  /// In en, this message translates to:
  /// **'Wardrobe'**
  String get cardTabWardrobe;

  /// No description provided for @cardTabJournal.
  ///
  /// In en, this message translates to:
  /// **'Journal'**
  String get cardTabJournal;

  /// No description provided for @cardHatched.
  ///
  /// In en, this message translates to:
  /// **'Hatched {date}'**
  String cardHatched(String date);

  /// No description provided for @cardLoves.
  ///
  /// In en, this message translates to:
  /// **'Loves {snack}'**
  String cardLoves(String snack);

  /// No description provided for @cardLovesSecret.
  ///
  /// In en, this message translates to:
  /// **'Favourite snack: a secret!'**
  String get cardLovesSecret;

  /// No description provided for @cardLevel.
  ///
  /// In en, this message translates to:
  /// **'Friendship level {level}'**
  String cardLevel(int level);

  /// No description provided for @cardRename.
  ///
  /// In en, this message translates to:
  /// **'Rename'**
  String get cardRename;

  /// No description provided for @cardMoveTo.
  ///
  /// In en, this message translates to:
  /// **'Move to…'**
  String get cardMoveTo;

  /// No description provided for @cardTricks.
  ///
  /// In en, this message translates to:
  /// **'Tricks'**
  String get cardTricks;

  /// Section of sound pads that play the friend's voice.
  ///
  /// In en, this message translates to:
  /// **'Voice'**
  String get cardVoice;

  /// No description provided for @trickMastered.
  ///
  /// In en, this message translates to:
  /// **'Mastered'**
  String get trickMastered;

  /// No description provided for @trickPractice.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 more day} other{{count} more days}}'**
  String trickPractice(int count);

  /// No description provided for @trickTryIt.
  ///
  /// In en, this message translates to:
  /// **'Try it!'**
  String get trickTryIt;

  /// No description provided for @trickDoneToday.
  ///
  /// In en, this message translates to:
  /// **'Practised today'**
  String get trickDoneToday;

  /// Puppy tricks.
  ///
  /// In en, this message translates to:
  /// **'Sit'**
  String get trickSit;

  /// No description provided for @trickPaw.
  ///
  /// In en, this message translates to:
  /// **'Paw'**
  String get trickPaw;

  /// No description provided for @trickSpin.
  ///
  /// In en, this message translates to:
  /// **'Spin'**
  String get trickSpin;

  /// No description provided for @trickSpeak.
  ///
  /// In en, this message translates to:
  /// **'Speak'**
  String get trickSpeak;

  /// No description provided for @trickPlayDead.
  ///
  /// In en, this message translates to:
  /// **'Play dead'**
  String get trickPlayDead;

  /// No description provided for @trickHighFive.
  ///
  /// In en, this message translates to:
  /// **'High five'**
  String get trickHighFive;

  /// No description provided for @wardrobeCoats.
  ///
  /// In en, this message translates to:
  /// **'Coats'**
  String get wardrobeCoats;

  /// No description provided for @wardrobeAccessories.
  ///
  /// In en, this message translates to:
  /// **'Accessories'**
  String get wardrobeAccessories;

  /// No description provided for @unlockLevel.
  ///
  /// In en, this message translates to:
  /// **'Friendship level {level}'**
  String unlockLevel(int level);

  /// No description provided for @unlockStars.
  ///
  /// In en, this message translates to:
  /// **'{stars} ★ in total'**
  String unlockStars(int stars);

  /// No description provided for @unlockSeasonal.
  ///
  /// In en, this message translates to:
  /// **'Seasonal'**
  String get unlockSeasonal;

  /// No description provided for @journalCount.
  ///
  /// In en, this message translates to:
  /// **'{have} of {total} found'**
  String journalCount(int have, int total);

  /// No description provided for @journalHidden.
  ///
  /// In en, this message translates to:
  /// **'???'**
  String get journalHidden;

  /// No description provided for @accScarf.
  ///
  /// In en, this message translates to:
  /// **'Scarf'**
  String get accScarf;

  /// No description provided for @accBandana.
  ///
  /// In en, this message translates to:
  /// **'Bandana'**
  String get accBandana;

  /// No description provided for @accBell.
  ///
  /// In en, this message translates to:
  /// **'Bell collar'**
  String get accBell;

  /// No description provided for @accBowtie.
  ///
  /// In en, this message translates to:
  /// **'Bow tie'**
  String get accBowtie;

  /// No description provided for @voicePad.
  ///
  /// In en, this message translates to:
  /// **'Play {name}\'s voice'**
  String voicePad(String name);

  /// No description provided for @toastTrickMastered.
  ///
  /// In en, this message translates to:
  /// **'{name} mastered {trick}!'**
  String toastTrickMastered(String name, String trick);

  /// No description provided for @toastMoved.
  ///
  /// In en, this message translates to:
  /// **'{name} went to the {room}'**
  String toastMoved(String name, String room);

  /// No description provided for @wearNone.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get wearNone;

  /// No description provided for @settingsReduceMotion.
  ///
  /// In en, this message translates to:
  /// **'Reduce motion'**
  String get settingsReduceMotion;

  /// No description provided for @settingsCredits.
  ///
  /// In en, this message translates to:
  /// **'Credits'**
  String get settingsCredits;

  /// No description provided for @creditsBody.
  ///
  /// In en, this message translates to:
  /// **'Made with love by Ouadie Zerhouni. Every friend, room and sound in this app is original.'**
  String get creditsBody;

  /// Shown only if any shipped sound came from Stable Audio.
  ///
  /// In en, this message translates to:
  /// **'Some sound effects made with Stable Audio · Powered by Stability AI'**
  String get creditsAudio;

  /// No description provided for @resetHouseBody.
  ///
  /// In en, this message translates to:
  /// **'This clears every friend, all stars, the wardrobe and the journal. It can\'t be undone.'**
  String get resetHouseBody;

  /// Photo booth screen.
  ///
  /// In en, this message translates to:
  /// **'Photo booth'**
  String get photoTitle;

  /// No description provided for @photoBackdrop.
  ///
  /// In en, this message translates to:
  /// **'Backdrop'**
  String get photoBackdrop;

  /// No description provided for @photoFriends.
  ///
  /// In en, this message translates to:
  /// **'Friends'**
  String get photoFriends;

  /// No description provided for @photoStickers.
  ///
  /// In en, this message translates to:
  /// **'Stickers'**
  String get photoStickers;

  /// No description provided for @photoShare.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get photoShare;

  /// No description provided for @photoHint.
  ///
  /// In en, this message translates to:
  /// **'Drag friends and stickers into place'**
  String get photoHint;

  /// No description provided for @photoClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get photoClose;

  /// Text that goes with a shared photo.
  ///
  /// In en, this message translates to:
  /// **'My friends in Mofu'**
  String get photoShareText;

  /// No description provided for @photoRemoveSticker.
  ///
  /// In en, this message translates to:
  /// **'Double-tap a sticker to remove it'**
  String get photoRemoveSticker;
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
