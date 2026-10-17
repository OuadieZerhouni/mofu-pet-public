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
