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
}
