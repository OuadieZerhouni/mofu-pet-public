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
    return 'NEW! $name';
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

  @override
  String get roomLiving => 'リビング';

  @override
  String get roomSpa => 'スパ';

  @override
  String get roomKitchen => 'キッチン';

  @override
  String get roomBedroom => '寝室';

  @override
  String get roomPlayroom => 'プレイルーム';

  @override
  String get roomGarden => 'おにわ';

  @override
  String get navPrevRoom => '前のへや';

  @override
  String get navNextRoom => '次のへや';

  @override
  String get navSettings => '設定';

  @override
  String starsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '星$countこ',
    );
    return '$_temp0';
  }

  @override
  String friendsHere(int count, int max) {
    return 'ここにいる子 $count/$max';
  }

  @override
  String get shelfTapHint => 'なかまをタップしてここに呼ぼう';

  @override
  String get roomFull => 'このへやはいっぱい。なかまは4ひきまで';

  @override
  String friendHereLabel(String name) {
    return '$name、このへやにいます。ダブルタップでカードを見る';
  }

  @override
  String friendElsewhereLabel(String name) {
    return '$name。ダブルタップでここに呼ぶ';
  }

  @override
  String eggCoinLabel(int stars) {
    return '次のたまごは星$starsこでかえるよ';
  }

  @override
  String toastStars(int count) {
    return '+$count ★';
  }

  @override
  String toastLevelUp(String name, int level) {
    return '$nameがなかよしレベル$levelになったよ！';
  }

  @override
  String get toastEggReady => 'お庭にたまごが届いたよ！';

  @override
  String toastFluffy(String name, int percent) {
    return '$nameは$percent%もふもふ！';
  }

  @override
  String get bubbleFull => 'おなかいっぱい！';

  @override
  String get bubbleOink => 'ブヒ！';

  @override
  String get bubbleOinkQuestion => 'ブヒ？';

  @override
  String get bubbleWoof => 'ワン！';

  @override
  String get bubbleAchoo => 'くしゅん！';

  @override
  String get bubbleYip => 'キャン！';

  @override
  String get bubbleHowl => 'アオーン！';

  @override
  String get bubbleWhimper => 'くぅん…';

  @override
  String get bubbleGrrr => 'ウゥー！';

  @override
  String get bubbleSqueak => 'キュッ！';

  @override
  String get bubblePant => 'ハッハッ！';

  @override
  String get bubblePlay => 'あそぼ！';

  @override
  String get bubbleCombo10 => 'ぽんぽこぽん！';

  @override
  String get bubbleCombo25 => 'おはなストーム！';

  @override
  String get bubbleCombo50 => 'メガぽん！';

  @override
  String get bubbleHi => 'やあ！';

  @override
  String get spaEmptyTitle => 'スパの準備ができたよ';

  @override
  String get spaEmptyHint => '下のなかまをタップしてスパへ連れていこう';

  @override
  String spaTitle(String name) {
    return '$nameのスパデー';
  }

  @override
  String spaStepOf(int step, int total) {
    return 'ステップ $step/$total';
  }

  @override
  String get spaStepFoam => 'あわあわ';

  @override
  String get spaStepRinse => 'すすぎ';

  @override
  String get spaStepTowel => 'タオル';

  @override
  String get spaStepDry => 'ドライ';

  @override
  String get spaHintFoam => 'こすってあわを作ろう';

  @override
  String get spaHintRinse => 'シャワーをあわの上へドラッグ';

  @override
  String get spaHintTowel => 'かわくまでやさしくこすろう';

  @override
  String get spaHintDry => 'ドライヤーでふわふわに';

  @override
  String get spaHintDone => 'さっぱり！あそんでも、もう一回でもOK';

  @override
  String get spaAgain => 'もう一回スパ';

  @override
  String get spaFreshToast => 'ずかんに追加：スパデー';

  @override
  String get bubbleFresh => 'さっぱり！';

  @override
  String get snackApple => 'りんご';

  @override
  String get snackCarrot => 'にんじん';

  @override
  String get snackCorn => 'とうもろこし';

  @override
  String get snackLettuce => 'レタス';

  @override
  String get snackWatermelon => 'すいか';

  @override
  String get snackBone => 'ほね';

  @override
  String get snackBacon => 'ベーコン';

  @override
  String get snackCheese => 'チーズ';

  @override
  String get snackCupcake => 'カップケーキ';

  @override
  String get snackBlueberry => 'ブルーベリー';

  @override
  String get snackCherry => 'さくらんぼ';

  @override
  String get snackGrape => 'ぶどう';

  @override
  String get snackPeach => 'もも';

  @override
  String kitchenMenuFor(String name) {
    return '$nameのメニュー・お口までドラッグ';
  }

  @override
  String kitchenLeft(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'この1時間であと$countこ',
      zero: 'いまはおなかいっぱい',
    );
    return '$_temp0';
  }

  @override
  String get kitchenEmptyHint => '下のなかまをタップしておやつに誘おう';

  @override
  String kitchenFavoriteToast(String name, String snack) {
    return '$nameは$snackが大好き！ +1 ★';
  }

  @override
  String get kitchenPickHint => '食べる子をタップして選んでね';

  @override
  String get bedLamp => 'ナイトライト';

  @override
  String get bedTuckIn => 'ねんね';

  @override
  String get bedWakeUp => 'おこす';

  @override
  String get sleepSounds => 'ねむりの音';

  @override
  String get sleepPlay => '再生';

  @override
  String get sleepStop => '停止';

  @override
  String get sleepMix => 'ミックス';

  @override
  String get sleepTimer => 'タイマー';

  @override
  String get sleepTimerOff => 'オフ';

  @override
  String sleepMinutes(int minutes) {
    return '$minutes分';
  }

  @override
  String get sleepRain => 'あめ';

  @override
  String get sleepPurr => 'ごろごろ';

  @override
  String get sleepFire => 'だんろ';

  @override
  String get sleepOcean => 'うみ';

  @override
  String get sleepChimes => '風鈴';

  @override
  String get sleepNoise => 'やさしいノイズ';

  @override
  String get sleepScreenOff => '画面を消しても再生を続けるよ';

  @override
  String sleepEndsIn(int minutes) {
    return '$minutes分後に停止';
  }

  @override
  String sleepVolume(String channel) {
    return '$channelの音量';
  }

  @override
  String get gameBoopRush => 'Boop Rush';

  @override
  String get gameBoopRushDesc => '出てきた鼻をぜんぶぽん！ 30秒間。';

  @override
  String get gameSnackCatch => 'Snack Catch';

  @override
  String get gameSnackCatchDesc => 'なかまをスライドしておやつをキャッチ、ハチはよけてね。45秒間。';

  @override
  String gameBest(int score) {
    return 'ベスト $score';
  }

  @override
  String gameStarsCap(int count) {
    return '1日に最大$count ★';
  }

  @override
  String gamePlay(String game) {
    return '$gameをプレイ';
  }

  @override
  String get gameReady => 'よーい…';

  @override
  String get gameGo => 'スタート！';

  @override
  String gameScore(int score) {
    return 'スコア $score';
  }

  @override
  String gameTime(int seconds) {
    return '$seconds秒';
  }

  @override
  String get gamePause => '一時停止';

  @override
  String get gameResume => '再開';

  @override
  String get gameQuit => 'やめる';

  @override
  String get gameTimesUp => 'タイムアップ！';

  @override
  String get gameNewBest => 'ベスト更新！';

  @override
  String gameStarsEarned(int count) {
    return '+$count ★';
  }

  @override
  String get gamePlayAgain => 'もう一回';

  @override
  String get gameDone => 'おわり';

  @override
  String get gameCatcherHint => '左右にドラッグ';

  @override
  String get gameBoopHint => '鼻をぽん！ねむそうな子は起こさないでね';

  @override
  String get gardenEggReadyTitle => '新しいたまごが届いたよ！';

  @override
  String get gardenEggReadyHint => 'たまごをタップして新しいなかまをお迎えしよう';

  @override
  String gardenNextEgg(int stars) {
    return '次のなかまは ★$stars';
  }

  @override
  String gardenProgress(int have, int need) {
    return '$have/$need ★';
  }

  @override
  String get gardenEggHint => 'なかまをお世話して星を集めよう';

  @override
  String get gardenAllHatched => 'みんなかえったよ！';

  @override
  String gardenEggNotYet(int stars) {
    return 'このたまごには ★$stars 必要だよ';
  }

  @override
  String hatchNameTitle(String species) {
    return '新しい$speciesに名前をつけよう';
  }

  @override
  String get gardenGift => '毎日のプレゼント';

  @override
  String gardenGiftDay(int day) {
    return '毎日のプレゼント・$day日目';
  }

  @override
  String get gardenGiftClaimed => 'また明日きてね';

  @override
  String get gardenPhotoBooth => 'フォトブース';

  @override
  String toastGift(int count) {
    return '+$count ★・また明日ね！';
  }

  @override
  String toastNewFriend(String name) {
    return '$nameにごあいさつ！';
  }

  @override
  String get speciesMofu => 'もふもふ';

  @override
  String get speciesOink => 'こぶた';

  @override
  String get speciesWuff => 'こいぬ';

  @override
  String get speciesBoop => 'Boop';

  @override
  String eggLabel(String state) {
    return 'たまご。$state';
  }

  @override
  String get cardTabPlay => 'あそぶ';

  @override
  String get cardTabWardrobe => 'きせかえ';

  @override
  String get cardTabJournal => 'ずかん';

  @override
  String cardHatched(String date) {
    return '$dateにたんじょう';
  }

  @override
  String cardLoves(String snack) {
    return '好物：$snack';
  }

  @override
  String get cardLovesSecret => '好きなおやつ：ひみつ！';

  @override
  String cardLevel(int level) {
    return 'なかよしレベル $level';
  }

  @override
  String get cardRename => '名前を変える';

  @override
  String get cardMoveTo => 'ほかのへやへ…';

  @override
  String get cardTricks => 'トリック';

  @override
  String get cardVoice => 'こえ';

  @override
  String get trickMastered => 'マスター';

  @override
  String trickPractice(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'あと$count日',
    );
    return '$_temp0';
  }

  @override
  String get trickTryIt => 'やってみる！';

  @override
  String get trickDoneToday => '今日は練習ずみ';

  @override
  String get trickSit => 'おすわり';

  @override
  String get trickPaw => 'おて';

  @override
  String get trickSpin => 'くるりん';

  @override
  String get trickSpeak => 'ほえる';

  @override
  String get trickPlayDead => 'ばたんきゅー';

  @override
  String get trickHighFive => 'ハイタッチ';

  @override
  String get wardrobeCoats => '毛なみ';

  @override
  String get wardrobeAccessories => 'アクセサリー';

  @override
  String unlockLevel(int level) {
    return 'なかよしレベル $level';
  }

  @override
  String unlockStars(int stars) {
    return '合計 ★$stars';
  }

  @override
  String get unlockSeasonal => '季節限定';

  @override
  String journalCount(int have, int total) {
    return '$totalこ中 $haveこ発見';
  }

  @override
  String get journalHidden => '？？？';

  @override
  String get accScarf => 'マフラー';

  @override
  String get accBandana => 'バンダナ';

  @override
  String get accBell => '鈴の首輪';

  @override
  String get accBowtie => '蝶ネクタイ';

  @override
  String voicePad(String name) {
    return '$nameのこえを再生';
  }

  @override
  String toastTrickMastered(String name, String trick) {
    return '$nameが「$trick」をマスター！';
  }

  @override
  String toastMoved(String name, String room) {
    return '$nameは$roomへ移動したよ';
  }

  @override
  String get wearNone => 'なし';

  @override
  String get settingsReduceMotion => '動きをへらす';

  @override
  String get settingsCredits => 'クレジット';

  @override
  String get creditsBody =>
      'Ouadie Zerhouniが心をこめて作りました。このアプリのなかま、へや、音はすべてオリジナルです。';

  @override
  String get creditsAudio =>
      '一部のサウンドはStable Audioで作成 · Powered by Stability AI';

  @override
  String get resetHouseBody => 'なかま、星、きせかえ、ずかんがすべて消えます。元に戻せません。';

  @override
  String get photoTitle => 'フォトブース';

  @override
  String get photoBackdrop => 'はいけい';

  @override
  String get photoFriends => 'なかま';

  @override
  String get photoStickers => 'ステッカー';

  @override
  String get photoShare => 'シェア';

  @override
  String get photoHint => 'なかまとステッカーをドラッグして配置しよう';

  @override
  String get photoClose => '閉じる';

  @override
  String get photoShareText => 'Mofuのなかまたち';

  @override
  String get photoRemoveSticker => 'ステッカーをダブルタップで削除';

  @override
  String get sleepSoundOff => 'サウンドがオフです。設定でオンにしてね。';
}
