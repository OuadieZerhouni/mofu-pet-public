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
  String get roomLiving => 'الصالة';

  @override
  String get roomSpa => 'السبا';

  @override
  String get roomKitchen => 'المطبخ';

  @override
  String get roomBedroom => 'غرفة النوم';

  @override
  String get roomPlayroom => 'غرفة اللعب';

  @override
  String get roomGarden => 'الحديقة';

  @override
  String get navPrevRoom => 'الغرفة السابقة';

  @override
  String get navNextRoom => 'الغرفة التالية';

  @override
  String get navSettings => 'الإعدادات';

  @override
  String starsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count نجمة',
      many: '$count نجمة',
      few: '$count نجوم',
      two: 'نجمتان',
      one: 'نجمة واحدة',
      zero: '$count نجمة',
    );
    return '$_temp0';
  }

  @override
  String friendsHere(int count, int max) {
    return '$count من $max هنا';
  }

  @override
  String get shelfTapHint => 'انقر على صديق لتجلبه إلى هنا';

  @override
  String get roomFull => 'هذه الغرفة ممتلئة: أربعة أصدقاء على الأكثر';

  @override
  String friendHereLabel(String name) {
    return '$name في هذه الغرفة. انقر مرتين لفتح بطاقته.';
  }

  @override
  String friendElsewhereLabel(String name) {
    return '$name. انقر مرتين لتجلبه إلى هنا.';
  }

  @override
  String eggCoinLabel(int stars) {
    return 'ستفقس البيضة التالية عند $stars نجمة';
  }

  @override
  String toastStars(int count) {
    return '+$count ★';
  }

  @override
  String toastLevelUp(String name, int level) {
    return 'وصل $name إلى مستوى الصداقة $level!';
  }

  @override
  String get toastEggReady => 'بيضة جاهزة في الحديقة!';

  @override
  String toastFluffy(String name, int percent) {
    return '$name منفوش بنسبة $percent٪!';
  }

  @override
  String get bubbleFull => 'شبعت!';

  @override
  String get bubbleOink => 'أوينك!';

  @override
  String get bubbleOinkQuestion => 'أوينك؟';

  @override
  String get bubbleWoof => 'هاو!';

  @override
  String get bubbleAchoo => 'هاتشي!';

  @override
  String get bubbleYip => 'ييب!';

  @override
  String get bubbleHowl => 'أووووو!';

  @override
  String get bubbleWhimper => 'نييي…';

  @override
  String get bubbleGrrr => 'غررر!';

  @override
  String get bubbleSqueak => 'صيييك!';

  @override
  String get bubblePant => 'هاه هاه!';

  @override
  String get bubblePlay => 'هيا نلعب!';

  @override
  String get bubbleCombo10 => 'بوب بوب بوب!';

  @override
  String get bubbleCombo25 => 'عاصفة أنوف!';

  @override
  String get bubbleCombo50 => 'بوب خارق!';

  @override
  String get bubbleHi => 'مرحبًا!';

  @override
  String get spaEmptyTitle => 'السبا جاهز';

  @override
  String get spaEmptyHint => 'انقر على صديق بالأسفل لتأخذه إلى السبا';

  @override
  String spaTitle(String name) {
    return 'يوم سبا $name';
  }

  @override
  String spaStepOf(int step, int total) {
    return 'الخطوة $step من $total';
  }

  @override
  String get spaStepFoam => 'رغوة';

  @override
  String get spaStepRinse => 'شطف';

  @override
  String get spaStepTowel => 'منشفة';

  @override
  String get spaStepDry => 'تجفيف';

  @override
  String get spaHintFoam => 'افرك لتصنع فقاعات';

  @override
  String get spaHintRinse => 'اسحب الدش فوق الرغوة';

  @override
  String get spaHintTowel => 'افرك بلطف حتى يجف';

  @override
  String get spaHintDry => 'جفّفه بالمجفف ليزداد نفشًا';

  @override
  String get spaHintDone => 'صار منعشًا! العب أو ابدأ من جديد';

  @override
  String get spaAgain => 'سبا مرة أخرى';

  @override
  String get spaFreshToast => 'جديد في الدفتر: يوم سبا';

  @override
  String get bubbleFresh => 'منعش!';

  @override
  String get snackApple => 'تفاحة';

  @override
  String get snackCarrot => 'جزرة';

  @override
  String get snackCorn => 'ذرة';

  @override
  String get snackLettuce => 'خس';

  @override
  String get snackWatermelon => 'بطيخ';

  @override
  String get snackBone => 'عظمة';

  @override
  String get snackBacon => 'لحم مقدد';

  @override
  String get snackCheese => 'جبن';

  @override
  String get snackCupcake => 'كب كيك';

  @override
  String get snackBlueberry => 'توت أزرق';

  @override
  String get snackCherry => 'كرز';

  @override
  String get snackGrape => 'عنب';

  @override
  String get snackPeach => 'خوخ';

  @override
  String kitchenMenuFor(String name) {
    return 'قائمة $name · اسحب إلى الفم';
  }

  @override
  String kitchenLeft(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count وجبة أخرى هذه الساعة',
      many: '$count وجبة أخرى هذه الساعة',
      few: '$count وجبات أخرى هذه الساعة',
      two: 'وجبتان أخريان هذه الساعة',
      one: 'وجبة واحدة أخرى هذه الساعة',
      zero: 'شبعان حاليًا',
    );
    return '$_temp0';
  }

  @override
  String get kitchenEmptyHint => 'انقر على صديق بالأسفل لتدعوه إلى وجبة خفيفة';

  @override
  String kitchenFavoriteToast(String name, String snack) {
    return '$name يحب $snack! +1 ★';
  }

  @override
  String get kitchenPickHint => 'انقر على صديق لتختار من سيأكل';

  @override
  String get bedLamp => 'ضوء الليل';

  @override
  String get bedTuckIn => 'تغطية';

  @override
  String get bedWakeUp => 'إيقاظ';

  @override
  String get sleepSounds => 'أصوات النوم';

  @override
  String get sleepPlay => 'تشغيل';

  @override
  String get sleepStop => 'إيقاف';

  @override
  String get sleepMix => 'مزج';

  @override
  String get sleepTimer => 'مؤقّت';

  @override
  String get sleepTimerOff => 'بدون';

  @override
  String sleepMinutes(int minutes) {
    return '$minutes د';
  }

  @override
  String get sleepRain => 'مطر';

  @override
  String get sleepPurr => 'خرخرة';

  @override
  String get sleepFire => 'مدفأة';

  @override
  String get sleepOcean => 'بحر';

  @override
  String get sleepChimes => 'أجراس الرياح';

  @override
  String get sleepNoise => 'ضوضاء ناعمة';

  @override
  String get sleepScreenOff => 'يستمر التشغيل والشاشة مطفأة';

  @override
  String sleepEndsIn(int minutes) {
    return 'يتوقف بعد $minutes د';
  }

  @override
  String sleepVolume(String channel) {
    return 'مستوى صوت $channel';
  }

  @override
  String get gameBoopRush => 'Boop Rush';

  @override
  String get gameBoopRushDesc => 'المس كل أنف يظهر. 30 ثانية.';

  @override
  String get gameSnackCatch => 'Snack Catch';

  @override
  String get gameSnackCatchDesc =>
      'حرّك صديقًا لتلتقط الوجبات وتتفادى النحل. 45 ثانية.';

  @override
  String gameBest(int score) {
    return 'الأفضل $score';
  }

  @override
  String gameStarsCap(int count) {
    return 'حتى $count ★ يوميًا';
  }

  @override
  String gamePlay(String game) {
    return 'العب $game';
  }

  @override
  String get gameReady => 'جاهز؟';

  @override
  String get gameGo => 'انطلق!';

  @override
  String gameScore(int score) {
    return 'النقاط $score';
  }

  @override
  String gameTime(int seconds) {
    return '$seconds ث';
  }

  @override
  String get gamePause => 'إيقاف مؤقت';

  @override
  String get gameResume => 'متابعة';

  @override
  String get gameQuit => 'خروج';

  @override
  String get gameTimesUp => 'انتهى الوقت!';

  @override
  String get gameNewBest => 'رقم قياسي جديد!';

  @override
  String gameStarsEarned(int count) {
    return '+$count ★';
  }

  @override
  String get gamePlayAgain => 'العب مجددًا';

  @override
  String get gameDone => 'تم';

  @override
  String get gameCatcherHint => 'اسحب يمينًا ويسارًا';

  @override
  String get gameBoopHint => 'المس الأنوف! لا توقظ النعسانين.';

  @override
  String get gardenEggReadyTitle => 'بيضة جديدة جاهزة!';

  @override
  String get gardenEggReadyHint => 'انقر على البيضة لتستقبل صديقًا جديدًا';

  @override
  String gardenNextEgg(int stars) {
    return 'الصديق التالي عند $stars ★';
  }

  @override
  String gardenProgress(int have, int need) {
    return '$have من $need ★';
  }

  @override
  String get gardenEggHint => 'اعتنِ بأصدقائك لتجمع النجوم';

  @override
  String get gardenAllHatched => 'فقس الجميع!';

  @override
  String gardenEggNotYet(int stars) {
    return 'هذه البيضة تحتاج $stars ★';
  }

  @override
  String hatchNameTitle(String species) {
    return 'صديقك الجديد: $species. اختر له اسمًا';
  }

  @override
  String get gardenGift => 'هدية يومية';

  @override
  String gardenGiftDay(int day) {
    return 'هدية يومية · اليوم $day';
  }

  @override
  String get gardenGiftClaimed => 'عُد غدًا';

  @override
  String get gardenPhotoBooth => 'ركن التصوير';

  @override
  String toastGift(int count) {
    return '+$count ★ · نراك غدًا!';
  }

  @override
  String toastNewFriend(String name) {
    return 'قل مرحبًا لـ$name!';
  }

  @override
  String get speciesMofu => 'كرة فرو';

  @override
  String get speciesOink => 'خنزير صغير';

  @override
  String get speciesWuff => 'جرو';

  @override
  String get speciesBoop => 'بوب';

  @override
  String eggLabel(String state) {
    return 'بيضة. $state';
  }

  @override
  String get cardTabPlay => 'لعب';

  @override
  String get cardTabWardrobe => 'ملابس';

  @override
  String get cardTabJournal => 'دفتر';

  @override
  String cardHatched(String date) {
    return 'فقس في $date';
  }

  @override
  String cardLoves(String snack) {
    return 'يحب: $snack';
  }

  @override
  String get cardLovesSecret => 'الوجبة المفضّلة: سر!';

  @override
  String cardLevel(int level) {
    return 'مستوى الصداقة $level';
  }

  @override
  String get cardRename => 'تغيير الاسم';

  @override
  String get cardMoveTo => 'انقل إلى…';

  @override
  String get cardTricks => 'حيل';

  @override
  String get cardVoice => 'الصوت';

  @override
  String get trickMastered => 'أتقنها';

  @override
  String trickPractice(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count يوم آخر',
      many: '$count يومًا آخر',
      few: '$count أيام أخرى',
      two: 'يومان آخران',
      one: 'يوم واحد آخر',
      zero: '$count يوم إضافي',
    );
    return '$_temp0';
  }

  @override
  String get trickTryIt => 'جرّبها!';

  @override
  String get trickDoneToday => 'تدرّب اليوم';

  @override
  String get trickSit => 'اجلس';

  @override
  String get trickPaw => 'صافح';

  @override
  String get trickSpin => 'دُر';

  @override
  String get trickSpeak => 'انبح';

  @override
  String get trickPlayDead => 'تظاهر بالموت';

  @override
  String get trickHighFive => 'كفّ بكفّ';

  @override
  String get wardrobeCoats => 'فراء';

  @override
  String get wardrobeAccessories => 'إكسسوارات';

  @override
  String unlockLevel(int level) {
    return 'مستوى الصداقة $level';
  }

  @override
  String unlockStars(int stars) {
    return '$stars ★ إجمالًا';
  }

  @override
  String get unlockSeasonal => 'موسمي';

  @override
  String journalCount(int have, int total) {
    return 'وُجد $have من $total';
  }

  @override
  String get journalHidden => '؟؟؟';

  @override
  String get accScarf => 'وشاح';

  @override
  String get accBandana => 'باندانا';

  @override
  String get accBell => 'طوق بجرس';

  @override
  String get accBowtie => 'ربطة فراشة';

  @override
  String voicePad(String name) {
    return 'تشغيل صوت $name';
  }

  @override
  String toastTrickMastered(String name, String trick) {
    return 'أتقن $name حيلة «$trick»!';
  }

  @override
  String toastMoved(String name, String room) {
    return 'انتقل $name إلى $room';
  }

  @override
  String get wearNone => 'بدون';

  @override
  String get settingsReduceMotion => 'تقليل الحركة';

  @override
  String get settingsCredits => 'شكر وتقدير';

  @override
  String get creditsBody =>
      'صُنع بحب بواسطة Ouadie Zerhouni. كل صديق وغرفة وصوت في هذا التطبيق أصلي.';

  @override
  String get creditsAudio =>
      'بعض المؤثرات الصوتية صُنعت بواسطة Stable Audio · Powered by Stability AI';

  @override
  String get resetHouseBody =>
      'سيُحذف كل الأصدقاء وكل النجوم والملابس والدفتر. لا يمكن التراجع.';

  @override
  String get photoTitle => 'ركن التصوير';

  @override
  String get photoBackdrop => 'الخلفية';

  @override
  String get photoFriends => 'الأصدقاء';

  @override
  String get photoStickers => 'ملصقات';

  @override
  String get photoShare => 'مشاركة';

  @override
  String get photoHint => 'اسحب الأصدقاء والملصقات إلى مكانها';

  @override
  String get photoClose => 'إغلاق';

  @override
  String get photoShareText => 'أصدقائي في موفو';

  @override
  String get photoRemoveSticker => 'انقر مرتين على ملصق لإزالته';

  @override
  String get sleepSoundOff => 'الأصوات مطفأة. شغّلها من الإعدادات.';
}
