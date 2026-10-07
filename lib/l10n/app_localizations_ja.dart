// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get appTitle => 'モフ';

  @override
  String get dockBrush => 'ブラシ';

  @override
  String get dockSnacks => 'おやつ';

  @override
  String get dockWardrobe => 'きせかえ';

  @override
  String get dockJournal => 'ずかん';

  @override
  String fluffPercent(int percent) {
    return 'もふもふ $percent%';
  }

  @override
  String daysTogether(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'いっしょに $count日目',
    );
    return '$_temp0';
  }

  @override
  String get coachPetMe => 'なでて！';

  @override
  String coachBrush(String name) {
    return 'やさしくブラッシングして$nameをもっともふもふに';
  }

  @override
  String snacksHint(String name) {
    return 'おやつを$nameの口まで運んでね';
  }

  @override
  String get firstRunTapSeed => 'もふもふのタネをタップ';

  @override
  String get firstRunHello => 'こんにちは！きみのモフだよ';

  @override
  String get firstRunNameTitle => 'モフの名前は？';

  @override
  String get nameFieldHint => '名前';

  @override
  String get actionSave => '決定';

  @override
  String get actionSkip => 'スキップ';

  @override
  String get actionCancel => 'キャンセル';

  @override
  String get actionClose => '閉じる';

  @override
  String get actionOk => 'OK';

  @override
  String toastNewReaction(String name) {
    return 'ずかんに追加：$name';
  }

  @override
  String toastUnlocked(String item) {
    return '解放：$item';
  }

  @override
  String get toastDailyBrush => '今日はじめてのブラッシング ✨';

  @override
  String toastFluffMilestone(int percent) {
    return 'もふもふ！ $percent%';
  }

  @override
  String get toastMaxFluff => 'もふもふMAX！最高のふわふわ';

  @override
  String toastFull(String name) {
    return '$nameはおなかいっぱい。またあとでね！';
  }

  @override
  String toastSeasonal(String item) {
    return '季節のプレゼント：$item';
  }

  @override
  String get snacksTitle => 'おやつ';

  @override
  String get wardrobeTitle => 'きせかえ';

  @override
  String get tabFur => '毛いろ';

  @override
  String get tabAccessories => 'アクセサリー';

  @override
  String get badgeNew => 'NEW!';

  @override
  String lockedDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count日あそぶ',
    );
    return '$_temp0';
  }

  @override
  String lockedFluff(int percent) {
    return 'もふもふ$percent%';
  }

  @override
  String lockedJournal(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'リアクションを$countこ発見',
    );
    return '$_temp0';
  }

  @override
  String lockedSnacks(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'おやつを$countこあげる',
    );
    return '$_temp0';
  }

  @override
  String lockedSeasonal(String season) {
    return '季節限定：$season';
  }

  @override
  String get seasonHalloween => 'ハロウィン';

  @override
  String get seasonWinter => '冬のホリデー';

  @override
  String get journalTitle => 'ずかん';

  @override
  String journalProgress(int found, int total) {
    return '$totalこ中 $foundこ発見';
  }

  @override
  String get journalUnknown => '？？？';

  @override
  String get settingsTitle => '設定';

  @override
  String get settingsSound => 'サウンド';

  @override
  String get settingsHaptics => '振動';

  @override
  String get settingsRename => '名前を変える';

  @override
  String get settingsPrivacy => 'プライバシーポリシー';

  @override
  String get settingsSupport => 'ヘルプ・ご意見';

  @override
  String get settingsRate => 'モフを評価する';

  @override
  String settingsVersion(String version) {
    return 'バージョン $version';
  }

  @override
  String get settingsReset => 'はじめからやり直す';

  @override
  String get resetTitle => 'はじめからやり直す？';

  @override
  String resetBody(String name) {
    return '$nameのもふもふ、きせかえ、ずかんが消えます。元に戻せません。';
  }

  @override
  String get resetConfirm => 'やり直す';

  @override
  String get updateTitle => 'モフのアップデート';

  @override
  String get updateBody => 'App Storeに新しいバージョンがあります。';

  @override
  String get updateRequiredBody => 'このバージョンは古くなりました。アップデートしてね。';

  @override
  String get updateAction => 'アップデート';

  @override
  String get updateLater => 'あとで';

  @override
  String semanticsMofu(String name) {
    return '$name、きみのモフ';
  }

  @override
  String get semanticsHug => 'ぎゅっ';

  @override
  String get semanticsBrushOn => 'ブラシ中';

  @override
  String get semanticsSettings => '設定';

  @override
  String get colorCream => 'クリーム';

  @override
  String get colorPeach => 'ピーチ';

  @override
  String get colorMint => 'ミント';

  @override
  String get colorSky => 'そら';

  @override
  String get colorLavender => 'ラベンダー';

  @override
  String get colorSakura => 'さくら';

  @override
  String get colorLemon => 'レモン';

  @override
  String get colorCocoa => 'ココア';

  @override
  String get colorSnow => 'ゆき';

  @override
  String get colorStarry => '星空';

  @override
  String get accNone => 'なし';

  @override
  String get accBow => 'リボン';

  @override
  String get accSprout => 'ふたば';

  @override
  String get accFlower => 'デイジー';

  @override
  String get accBeanie => 'ニット帽';

  @override
  String get accStarclip => '星のピン';

  @override
  String get accChef => 'コック帽';

  @override
  String get accHeadphones => 'ヘッドホン';

  @override
  String get accParty => 'パーティー帽';

  @override
  String get accGlasses => 'メガネ';

  @override
  String get accCrown => '王冠';

  @override
  String get accWitch => '魔女の帽子';

  @override
  String get accSanta => 'サンタ帽';

  @override
  String get snackStrawberry => 'いちご';

  @override
  String get snackDango => 'だんご';

  @override
  String get snackCookie => 'クッキー';

  @override
  String get snackOnigiri => 'おにぎり';

  @override
  String get snackPudding => 'プリン';

  @override
  String get snackCandy => 'キャンディ';

  @override
  String get rxBoing => 'ぽよん';

  @override
  String get rxBoingHint => 'ちょんとタップ';

  @override
  String get rxTickle => 'くすぐったい';

  @override
  String get rxTickleHint => 'タップ、タップ、タップ…！';

  @override
  String get rxPet => 'なでなで';

  @override
  String get rxPetHint => '毛並みをなでる';

  @override
  String get rxPurr => 'ごろごろ';

  @override
  String get rxPurrHint => 'しばらくなで続ける';

  @override
  String get rxSquish => 'もちもち';

  @override
  String get rxSquishHint => '長押しする';

  @override
  String get rxHug => 'ぎゅー';

  @override
  String get rxHugHint => 'もう少し長く押す';

  @override
  String get rxToss => 'わーい！';

  @override
  String get rxTossHint => 'つかんで投げる';

  @override
  String get rxDizzyToss => 'ぽよよん';

  @override
  String get rxDizzyTossHint => '高く投げる';

  @override
  String get rxEyePoke => 'もう！';

  @override
  String get rxEyePokeHint => '目をダブルタップ';

  @override
  String get rxShake => 'じしん';

  @override
  String get rxShakeHint => 'スマホをふる';

  @override
  String get rxBrush => 'ブラッシング';

  @override
  String get rxBrushHint => 'ブラシを使う';

  @override
  String get rxTidy => 'さらさら';

  @override
  String get rxTidyHint => 'ボサボサをブラシで直す';

  @override
  String get rxYum => 'おいしい！';

  @override
  String get rxYumHint => 'おやつをあげる';

  @override
  String get rxFavorite => '大好物';

  @override
  String get rxFavoriteHint => 'モフにはそれぞれ好物がある';

  @override
  String get rxFull => 'おなかいっぱい';

  @override
  String get rxFullHint => 'おやつをあげすぎる';

  @override
  String get rxSleep => 'おねむ';

  @override
  String get rxSleepHint => 'そっとしておく';

  @override
  String get rxWake => 'おはよう';

  @override
  String get rxWakeHint => 'やさしく起こす';

  @override
  String get rxNightOwl => '夜ふかし';

  @override
  String get rxNightOwlHint => '真夜中に会いにくる';

  @override
  String get rxEarlyBird => '早起き';

  @override
  String get rxEarlyBirdHint => '朝日のころに会いにくる';

  @override
  String get rxFluffy => 'ふわふわ';

  @override
  String get rxFluffyHint => 'もふもふ25%';

  @override
  String get rxMaxFluff => 'もふもふMAX';

  @override
  String get rxMaxFluffHint => 'もふもふ100%';

  @override
  String get rxDressUp => 'おめかし';

  @override
  String get rxDressUpHint => 'アクセサリーをつける';

  @override
  String get rxNewLook => 'イメチェン';

  @override
  String get rxNewLookHint => '毛いろを変える';

  @override
  String get rxSpin => 'くるくる';

  @override
  String get rxSpinHint => '円をえがくようになでる';
}
