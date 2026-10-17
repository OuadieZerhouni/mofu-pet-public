import '../l10n/app_localizations.dart';
import '../model/catalog.dart';

/// Localized names for catalog ids.
///
/// One switch per kind, so a missing translation is a compile error (the
/// getter does not exist) rather than a raw id on screen.
extension CatalogNames on AppLocalizations {
  String colorName(String id) => switch (id) {
        'cream' => colorCream,
        'peach' => colorPeach,
        'mint' => colorMint,
        'sky' => colorSky,
        'lavender' => colorLavender,
        'sakura' => colorSakura,
        'lemon' => colorLemon,
        'cocoa' => colorCocoa,
        'snow' => colorSnow,
        'starry' => colorStarry,
        _ => id,
      };

  String accessoryName(String id) => switch (id) {
        'none' => accNone,
        'bow' => accBow,
        'sprout' => accSprout,
        'flower' => accFlower,
        'beanie' => accBeanie,
        'starclip' => accStarclip,
        'chef' => accChef,
        'headphones' => accHeadphones,
        'party' => accParty,
        'glasses' => accGlasses,
        'crown' => accCrown,
        'witch' => accWitch,
        'santa' => accSanta,
        'scarf' => accScarf,
        'bandana' => accBandana,
        'bell' => accBell,
        'bowtie' => accBowtie,
        _ => id,
      };

  String snackName(String id) => switch (id) {
        'strawberry' => snackStrawberry,
        'dango' => snackDango,
        'cookie' => snackCookie,
        'onigiri' => snackOnigiri,
        'pudding' => snackPudding,
        'candy' => snackCandy,
        'apple' => snackApple,
        'carrot' => snackCarrot,
        'corn' => snackCorn,
        'lettuce' => snackLettuce,
        'watermelon' => snackWatermelon,
        'bone' => snackBone,
        'bacon' => snackBacon,
        'cheese' => snackCheese,
        'cupcake' => snackCupcake,
        'blueberry' => snackBlueberry,
        'cherry' => snackCherry,
        'grape' => snackGrape,
        'peach' => snackPeach,
        _ => id,
      };

  String seasonName(String id) => switch (id) {
        'halloween' => seasonHalloween,
        'winter' => seasonWinter,
        _ => id,
      };

  (String, String) reaction(String id) => switch (id) {
        'boing' => (rxBoing, rxBoingHint),
        'tickle' => (rxTickle, rxTickleHint),
        'pet' => (rxPet, rxPetHint),
        'purr' => (rxPurr, rxPurrHint),
        'squish' => (rxSquish, rxSquishHint),
        'hug' => (rxHug, rxHugHint),
        'toss' => (rxToss, rxTossHint),
        'dizzyToss' => (rxDizzyToss, rxDizzyTossHint),
        'eyePoke' => (rxEyePoke, rxEyePokeHint),
        'shake' => (rxShake, rxShakeHint),
        'brush' => (rxBrush, rxBrushHint),
        'tidy' => (rxTidy, rxTidyHint),
        'yum' => (rxYum, rxYumHint),
        'favorite' => (rxFavorite, rxFavoriteHint),
        'full' => (rxFull, rxFullHint),
        'sleep' => (rxSleep, rxSleepHint),
        'wake' => (rxWake, rxWakeHint),
        'nightOwl' => (rxNightOwl, rxNightOwlHint),
        'earlyBird' => (rxEarlyBird, rxEarlyBirdHint),
        'fluffy' => (rxFluffy, rxFluffyHint),
        'maxFluff' => (rxMaxFluff, rxMaxFluffHint),
        'dressUp' => (rxDressUp, rxDressUpHint),
        'newLook' => (rxNewLook, rxNewLookHint),
        'spin' => (rxSpin, rxSpinHint),
        _ => (id, ''),
      };

  String unlockText(UnlockRule rule) => switch (rule.kind) {
        UnlockKind.start => '',
        UnlockKind.days => lockedDays(rule.amount),
        UnlockKind.fluff => lockedFluff(rule.amount),
        UnlockKind.journal => lockedJournal(rule.amount),
        UnlockKind.snacks => lockedSnacks(rule.amount),
        UnlockKind.seasonal => lockedSeasonal(seasonName(rule.seasonId)),
      };

  /// "color:mint" / "acc:bow" → localized item name.
  String unlockKeyName(String key) {
    final i = key.indexOf(':');
    if (i < 0) return key;
    final kind = key.substring(0, i), id = key.substring(i + 1);
    return kind == 'color' ? colorName(id) : accessoryName(id);
  }
}
