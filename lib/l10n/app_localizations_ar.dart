// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'موفو';

  @override
  String get dockBrush => 'فرشاة';

  @override
  String get dockSnacks => 'وجبات';

  @override
  String get dockWardrobe => 'ملابس';

  @override
  String get dockJournal => 'دفتر';

  @override
  String fluffPercent(int percent) {
    return 'منفوش $percent٪';
  }

  @override
  String daysTogether(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'اليوم $count معًا',
      many: 'اليوم $count معًا',
      few: 'اليوم $count معًا',
      two: 'اليوم الثاني معًا',
      one: 'اليوم الأول معًا',
      zero: 'اليوم $count معًا',
    );
    return '$_temp0';
  }

  @override
  String get coachPetMe => 'دلّعني!';

  @override
  String coachBrush(String name) {
    return 'مشّط بلطف ليصير $name أكثر نفشًا';
  }

  @override
  String snacksHint(String name) {
    return 'اسحب وجبة إلى فم $name';
  }

  @override
  String get firstRunTapSeed => 'المس بذرة الفرو';

  @override
  String get firstRunHello => 'مرحبًا! أنا موفو الخاص بك';

  @override
  String get firstRunNameTitle => 'ماذا تريد أن تسمّي موفو؟';

  @override
  String get nameFieldHint => 'الاسم';

  @override
  String get actionSave => 'حفظ';

  @override
  String get actionSkip => 'تخطّي';

  @override
  String get actionCancel => 'إلغاء';

  @override
  String get actionClose => 'إغلاق';

  @override
  String get actionOk => 'حسنًا';

  @override
  String toastNewReaction(String name) {
    return 'جديد في الدفتر: $name';
  }

  @override
  String toastUnlocked(String item) {
    return 'تم الفتح: $item';
  }

  @override
  String get toastDailyBrush => 'أول تمشيط اليوم ✨';

  @override
  String toastFluffMilestone(int percent) {
    return 'موفو موفو! منفوش $percent٪';
  }

  @override
  String get toastMaxFluff => 'أقصى نفش! أنفش موفو على الإطلاق';

  @override
  String toastFull(String name) {
    return '$name شبعان. ربما لاحقًا!';
  }

  @override
  String toastSeasonal(String item) {
    return 'وصلت هدية موسمية: $item';
  }

  @override
  String get snacksTitle => 'وجبات';

  @override
  String get wardrobeTitle => 'ملابس';

  @override
  String get tabFur => 'الفرو';

  @override
  String get tabAccessories => 'إكسسوارات';

  @override
  String get badgeNew => 'جديد!';

  @override
  String lockedDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'زُر في $count يوم',
      many: 'زُر في $count يومًا',
      few: 'زُر في $count أيام',
      two: 'زُر في يومين',
      one: 'زُر في يوم واحد',
      zero: 'زُر في $count يوم',
    );
    return '$_temp0';
  }

  @override
  String lockedFluff(int percent) {
    return 'اوصل إلى نفش $percent٪';
  }

  @override
  String lockedJournal(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'اكتشف $count ردة فعل',
      many: 'اكتشف $count ردة فعل',
      few: 'اكتشف $count ردات فعل',
      two: 'اكتشف ردتي فعل',
      one: 'اكتشف ردة فعل واحدة',
      zero: 'اكتشف $count ردة فعل',
    );
    return '$_temp0';
  }

  @override
  String lockedSnacks(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'شارك $count وجبة',
      many: 'شارك $count وجبة',
      few: 'شارك $count وجبات',
      two: 'شارك وجبتين',
      one: 'شارك وجبة واحدة',
      zero: 'شارك $count وجبة',
    );
    return '$_temp0';
  }

  @override
  String lockedSeasonal(String season) {
    return 'موسمي: $season';
  }

  @override
  String get seasonHalloween => 'الهالوين';

  @override
  String get seasonWinter => 'عطلة الشتاء';

  @override
  String get journalTitle => 'دفتر';

  @override
  String journalProgress(int found, int total) {
    return 'اكتشفت $found من $total';
  }

  @override
  String get journalUnknown => '؟؟؟';

  @override
  String get settingsTitle => 'الإعدادات';

  @override
  String get settingsSound => 'الأصوات';

  @override
  String get settingsHaptics => 'الاهتزاز';

  @override
  String get settingsRename => 'تغيير الاسم';

  @override
  String get settingsPrivacy => 'سياسة الخصوصية';

  @override
  String get settingsSupport => 'المساعدة والملاحظات';

  @override
  String get settingsRate => 'قيّم موفو';

  @override
  String settingsVersion(String version) {
    return 'الإصدار $version';
  }

  @override
  String get settingsReset => 'البدء من جديد';

  @override
  String get resetTitle => 'البدء من جديد؟';

  @override
  String resetBody(String name) {
    return 'سيُحذف نفش $name وملابسه ودفتره. لا يمكن التراجع.';
  }

  @override
  String get resetConfirm => 'ابدأ من جديد';

  @override
  String get updateTitle => 'تحديث جديد لموفو';

  @override
  String get updateBody => 'إصدار جديد متوفر الآن في App Store.';

  @override
  String get updateRequiredBody =>
      'هذا الإصدار قديم جدًا. حدّث التطبيق للمتابعة.';

  @override
  String get updateAction => 'تحديث';

  @override
  String get updateLater => 'لاحقًا';

  @override
  String semanticsMofu(String name) {
    return '$name، موفو الخاص بك';
  }

  @override
  String get semanticsHug => 'احضن';

  @override
  String get semanticsBrushOn => 'الفرشاة مفعّلة';

  @override
  String get semanticsSettings => 'الإعدادات';

  @override
  String get colorCream => 'كريمي';

  @override
  String get colorPeach => 'خوخي';

  @override
  String get colorMint => 'نعناعي';

  @override
  String get colorSky => 'سماوي';

  @override
  String get colorLavender => 'لافندر';

  @override
  String get colorSakura => 'ساكورا';

  @override
  String get colorLemon => 'ليموني';

  @override
  String get colorCocoa => 'كاكاو';

  @override
  String get colorSnow => 'ثلجي';

  @override
  String get colorStarry => 'ليل مُنجّم';

  @override
  String get accNone => 'بدون';

  @override
  String get accBow => 'فيونكة';

  @override
  String get accSprout => 'نبتة';

  @override
  String get accFlower => 'زهرة أقحوان';

  @override
  String get accBeanie => 'طاقية صوف';

  @override
  String get accStarclip => 'مشبك نجمة';

  @override
  String get accChef => 'قبعة طاهٍ';

  @override
  String get accHeadphones => 'سماعات';

  @override
  String get accParty => 'قبعة حفلة';

  @override
  String get accGlasses => 'نظارة';

  @override
  String get accCrown => 'تاج';

  @override
  String get accWitch => 'قبعة ساحرة';

  @override
  String get accSanta => 'قبعة شتوية حمراء';

  @override
  String get snackStrawberry => 'فراولة';

  @override
  String get snackDango => 'دانغو';

  @override
  String get snackCookie => 'كوكيز';

  @override
  String get snackOnigiri => 'أونيغيري';

  @override
  String get snackPudding => 'بودينغ';

  @override
  String get snackCandy => 'حلوى';

  @override
  String get rxBoing => 'بوينغ';

  @override
  String get rxBoingHint => 'انقره نقرة خفيفة';

  @override
  String get rxTickle => 'نوبة ضحك';

  @override
  String get rxTickleHint => 'انقر، انقر، انقر، انقر، انقر!';

  @override
  String get rxPet => 'دلع';

  @override
  String get rxPetHint => 'مرّر يدك على فروه';

  @override
  String get rxPurr => 'خرخرة';

  @override
  String get rxPurrHint => 'استمر في التدليل قليلًا';

  @override
  String get rxSquish => 'عصرة موتشي';

  @override
  String get rxSquishHint => 'اضغط مطوّلًا';

  @override
  String get rxHug => 'حضن كبير';

  @override
  String get rxHugHint => 'اضغط لمدة أطول قليلًا';

  @override
  String get rxToss => 'ووووه!';

  @override
  String get rxTossHint => 'امسكه وارفعه ثم اتركه';

  @override
  String get rxDizzyToss => 'قفزة دائخة';

  @override
  String get rxDizzyTossHint => 'ارمه عاليًا';

  @override
  String get rxEyePoke => 'هيه!';

  @override
  String get rxEyePokeHint => 'انقر على عين مرتين';

  @override
  String get rxShake => 'زلزال';

  @override
  String get rxShakeHint => 'هزّ جوالك';

  @override
  String get rxBrush => 'وقت التمشيط';

  @override
  String get rxBrushHint => 'استخدم الفرشاة';

  @override
  String get rxTidy => 'مرتّب';

  @override
  String get rxTidyHint => 'مشّط الفرو المنكوش';

  @override
  String get rxYum => 'لذيذ!';

  @override
  String get rxYumHint => 'شارك وجبة';

  @override
  String get rxFavorite => 'الوجبة المفضّلة';

  @override
  String get rxFavoriteHint => 'لكل موفو وجبة مفضّلة';

  @override
  String get rxFull => 'شبعان';

  @override
  String get rxFullHint => 'وجبات كثيرة';

  @override
  String get rxSleep => 'نعسان';

  @override
  String get rxSleepHint => 'دعه يرتاح';

  @override
  String get rxWake => 'صباح الخير';

  @override
  String get rxWakeHint => 'أيقظه بلطف';

  @override
  String get rxNightOwl => 'سهران';

  @override
  String get rxNightOwlHint => 'زُره بعد منتصف الليل';

  @override
  String get rxEarlyBird => 'مبكّر';

  @override
  String get rxEarlyBirdHint => 'زُره عند الشروق';

  @override
  String get rxFluffy => 'منفوش';

  @override
  String get rxFluffyHint => 'اوصل إلى نفش ٢٥٪';

  @override
  String get rxMaxFluff => 'أقصى نفش';

  @override
  String get rxMaxFluffHint => 'اوصل إلى نفش ١٠٠٪';

  @override
  String get rxDressUp => 'تأنّق';

  @override
  String get rxDressUpHint => 'جرّب إكسسوارًا';

  @override
  String get rxNewLook => 'إطلالة جديدة';

  @override
  String get rxNewLookHint => 'غيّر لون الفرو';

  @override
  String get rxSpin => 'دوّامة';

  @override
  String get rxSpinHint => 'دلّعه بحركة دائرية';

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
