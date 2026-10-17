// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appTitle => 'Mofu';

  @override
  String get dockBrush => 'Escova';

  @override
  String get dockSnacks => 'Lanches';

  @override
  String get dockWardrobe => 'Visual';

  @override
  String get dockJournal => 'Diário';

  @override
  String fluffPercent(int percent) {
    return '$percent% fofinho';
  }

  @override
  String daysTogether(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Dia $count juntos',
      one: 'Dia 1 juntos',
    );
    return '$_temp0';
  }

  @override
  String get coachPetMe => 'Faz carinho!';

  @override
  String coachBrush(String name) {
    return 'Escove com cuidado para deixar $name mais fofinho';
  }

  @override
  String snacksHint(String name) {
    return 'Arraste um lanche até a boca de $name';
  }

  @override
  String get firstRunTapSeed => 'Toque na sementinha de pelúcia';

  @override
  String get firstRunHello => 'Oi! Eu sou o seu Mofu';

  @override
  String get firstRunNameTitle => 'Qual vai ser o nome do seu Mofu?';

  @override
  String get nameFieldHint => 'Nome';

  @override
  String get actionSave => 'Salvar';

  @override
  String get actionSkip => 'Pular';

  @override
  String get actionCancel => 'Cancelar';

  @override
  String get actionClose => 'Fechar';

  @override
  String get actionOk => 'OK';

  @override
  String toastNewReaction(String name) {
    return 'Novo no diário: $name';
  }

  @override
  String toastUnlocked(String item) {
    return 'Desbloqueado: $item';
  }

  @override
  String get toastDailyBrush => 'Primeira escovada do dia ✨';

  @override
  String toastFluffMilestone(int percent) {
    return 'Mofu mofu! $percent% fofinho';
  }

  @override
  String get toastMaxFluff => 'MOFU MÁXIMO! O mais fofinho de todos';

  @override
  String toastFull(String name) {
    return '$name está cheio. Mais tarde!';
  }

  @override
  String toastSeasonal(String item) {
    return 'Chegou um presente da estação: $item';
  }

  @override
  String get snacksTitle => 'Lanches';

  @override
  String get wardrobeTitle => 'Visual';

  @override
  String get tabFur => 'Pelo';

  @override
  String get tabAccessories => 'Acessórios';

  @override
  String get badgeNew => 'Novo!';

  @override
  String lockedDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Visite em $count dias',
      one: 'Visite em 1 dia',
    );
    return '$_temp0';
  }

  @override
  String lockedFluff(int percent) {
    return 'Chegue a $percent% de fofura';
  }

  @override
  String lockedJournal(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Descubra $count reações',
      one: 'Descubra 1 reação',
    );
    return '$_temp0';
  }

  @override
  String lockedSnacks(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Divida $count lanches',
      one: 'Divida 1 lanche',
    );
    return '$_temp0';
  }

  @override
  String lockedSeasonal(String season) {
    return 'Sazonal: $season';
  }

  @override
  String get seasonHalloween => 'Halloween';

  @override
  String get seasonWinter => 'Festas de fim de ano';

  @override
  String get journalTitle => 'Diário';

  @override
  String journalProgress(int found, int total) {
    return '$found de $total descobertas';
  }

  @override
  String get journalUnknown => '???';

  @override
  String get settingsTitle => 'Ajustes';

  @override
  String get settingsSound => 'Sons';

  @override
  String get settingsHaptics => 'Vibração';

  @override
  String get settingsRename => 'Renomear';

  @override
  String get settingsPrivacy => 'Política de privacidade';

  @override
  String get settingsSupport => 'Ajuda e sugestões';

  @override
  String get settingsRate => 'Avaliar o Mofu';

  @override
  String settingsVersion(String version) {
    return 'Versão $version';
  }

  @override
  String get settingsReset => 'Recomeçar';

  @override
  String get resetTitle => 'Recomeçar?';

  @override
  String resetBody(String name) {
    return 'Isso apaga a fofura, o visual e o diário de $name. Não dá para desfazer.';
  }

  @override
  String get resetConfirm => 'Recomeçar';

  @override
  String get updateTitle => 'Nova atualização do Mofu';

  @override
  String get updateBody => 'Uma nova versão está pronta na App Store.';

  @override
  String get updateRequiredBody =>
      'Esta versão está muito antiga. Atualize para continuar.';

  @override
  String get updateAction => 'Atualizar';

  @override
  String get updateLater => 'Depois';

  @override
  String semanticsMofu(String name) {
    return '$name, o seu Mofu';
  }

  @override
  String get semanticsHug => 'Abraçar';

  @override
  String get semanticsBrushOn => 'Escova ligada';

  @override
  String get semanticsSettings => 'Ajustes';

  @override
  String get colorCream => 'Creme';

  @override
  String get colorPeach => 'Pêssego';

  @override
  String get colorMint => 'Menta';

  @override
  String get colorSky => 'Céu';

  @override
  String get colorLavender => 'Lavanda';

  @override
  String get colorSakura => 'Sakura';

  @override
  String get colorLemon => 'Limão';

  @override
  String get colorCocoa => 'Cacau';

  @override
  String get colorSnow => 'Neve';

  @override
  String get colorStarry => 'Noite estrelada';

  @override
  String get accNone => 'Nada';

  @override
  String get accBow => 'Laço';

  @override
  String get accSprout => 'Brotinho';

  @override
  String get accFlower => 'Margarida';

  @override
  String get accBeanie => 'Gorro';

  @override
  String get accStarclip => 'Presilha de estrela';

  @override
  String get accChef => 'Chapéu de chef';

  @override
  String get accHeadphones => 'Fones';

  @override
  String get accParty => 'Chapéu de festa';

  @override
  String get accGlasses => 'Óculos';

  @override
  String get accCrown => 'Coroa';

  @override
  String get accWitch => 'Chapéu de bruxa';

  @override
  String get accSanta => 'Gorro de Papai Noel';

  @override
  String get snackStrawberry => 'Morango';

  @override
  String get snackDango => 'Dango';

  @override
  String get snackCookie => 'Biscoito';

  @override
  String get snackOnigiri => 'Onigiri';

  @override
  String get snackPudding => 'Pudim';

  @override
  String get snackCandy => 'Bala';

  @override
  String get rxBoing => 'Boing';

  @override
  String get rxBoingHint => 'Dê um toquinho';

  @override
  String get rxTickle => 'Crise de cócegas';

  @override
  String get rxTickleHint => 'Toque, toque, toque, toque, toque!';

  @override
  String get rxPet => 'Carinho';

  @override
  String get rxPetHint => 'Acaricie o pelo';

  @override
  String get rxPurr => 'Ronrom';

  @override
  String get rxPurrHint => 'Continue o carinho por um tempo';

  @override
  String get rxSquish => 'Apertinho de mochi';

  @override
  String get rxSquishHint => 'Toque e segure';

  @override
  String get rxHug => 'Abraço apertado';

  @override
  String get rxHugHint => 'Segure mais um pouco';

  @override
  String get rxToss => 'Uhuuu!';

  @override
  String get rxTossHint => 'Segure, levante e solte';

  @override
  String get rxDizzyToss => 'Quica-quica';

  @override
  String get rxDizzyTossHint => 'Jogue bem alto';

  @override
  String get rxEyePoke => 'Ei!';

  @override
  String get rxEyePokeHint => 'Toque duas vezes num olho';

  @override
  String get rxShake => 'Terremoto';

  @override
  String get rxShakeHint => 'Sacuda o celular';

  @override
  String get rxBrush => 'Hora da escova';

  @override
  String get rxBrushHint => 'Use a escova';

  @override
  String get rxTidy => 'Arrumadinho';

  @override
  String get rxTidyHint => 'Escove o pelo bagunçado';

  @override
  String get rxYum => 'Nham!';

  @override
  String get rxYumHint => 'Divida um lanche';

  @override
  String get rxFavorite => 'Lanche favorito';

  @override
  String get rxFavoriteHint => 'Todo Mofu tem um';

  @override
  String get rxFull => 'Cheinho';

  @override
  String get rxFullHint => 'Lanches demais';

  @override
  String get rxSleep => 'Dorminhoco';

  @override
  String get rxSleepHint => 'Deixe descansar';

  @override
  String get rxWake => 'Bom dia';

  @override
  String get rxWakeHint => 'Acorde com carinho';

  @override
  String get rxNightOwl => 'Coruja da noite';

  @override
  String get rxNightOwlHint => 'Visite depois da meia-noite';

  @override
  String get rxEarlyBird => 'Madrugador';

  @override
  String get rxEarlyBirdHint => 'Visite ao nascer do sol';

  @override
  String get rxFluffy => 'Fofinho';

  @override
  String get rxFluffyHint => 'Chegue a 25% de fofura';

  @override
  String get rxMaxFluff => 'Mofu máximo';

  @override
  String get rxMaxFluffHint => 'Chegue a 100% de fofura';

  @override
  String get rxDressUp => 'Produzido';

  @override
  String get rxDressUpHint => 'Experimente um acessório';

  @override
  String get rxNewLook => 'Visual novo';

  @override
  String get rxNewLookHint => 'Troque a cor do pelo';

  @override
  String get rxSpin => 'Centrifugação';

  @override
  String get rxSpinHint => 'Faça carinho em círculos';

  @override
  String get roomLiving => 'Sala';

  @override
  String get roomSpa => 'Spa';

  @override
  String get roomKitchen => 'Cozinha';

  @override
  String get roomBedroom => 'Quarto';

  @override
  String get roomPlayroom => 'Jogos';

  @override
  String get roomGarden => 'Jardim';

  @override
  String get navPrevRoom => 'Cômodo anterior';

  @override
  String get navNextRoom => 'Próximo cômodo';

  @override
  String get navSettings => 'Ajustes';

  @override
  String starsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count estrelas',
      one: '1 estrela',
    );
    return '$_temp0';
  }

  @override
  String friendsHere(int count, int max) {
    return '$count de $max aqui';
  }

  @override
  String get shelfTapHint => 'Toque em um amigo para trazê-lo para cá';

  @override
  String get roomFull => 'Este cômodo está cheio: no máximo 4 amigos';

  @override
  String friendHereLabel(String name) {
    return '$name, neste cômodo. Toque duas vezes para ver o cartão.';
  }

  @override
  String friendElsewhereLabel(String name) {
    return '$name. Toque duas vezes para trazer para cá.';
  }

  @override
  String eggCoinLabel(int stars) {
    return 'O próximo ovo choca com $stars estrelas';
  }

  @override
  String toastStars(int count) {
    return '+$count ★';
  }

  @override
  String toastLevelUp(String name, int level) {
    return '$name chegou ao nível de amizade $level!';
  }

  @override
  String get toastEggReady => 'Um ovo está pronto no jardim!';

  @override
  String toastFluffy(String name, int percent) {
    return 'Fofura de $name: $percent%!';
  }

  @override
  String get bubbleFull => 'Já comi!';

  @override
  String get bubbleOink => 'Oinc!';

  @override
  String get bubbleOinkQuestion => 'Oinc?';

  @override
  String get bubbleWoof => 'Au au!';

  @override
  String get bubbleAchoo => 'Atchim!';

  @override
  String get bubbleYip => 'Aiu!';

  @override
  String get bubbleHowl => 'Auuuu!';

  @override
  String get bubbleWhimper => 'Nhééé…';

  @override
  String get bubbleGrrr => 'Grrr!';

  @override
  String get bubbleSqueak => 'Quiii!';

  @override
  String get bubblePant => 'Haf, haf!';

  @override
  String get bubblePlay => 'Vamos brincar!';

  @override
  String get bubbleCombo10 => 'Bipi-boop!';

  @override
  String get bubbleCombo25 => 'Tempestade de focinhos!';

  @override
  String get bubbleCombo50 => 'Mega boop!';

  @override
  String get bubbleHi => 'Oi!';

  @override
  String get spaEmptyTitle => 'O spa está pronto';

  @override
  String get spaEmptyHint => 'Toque em um amigo abaixo para levá-lo ao spa';

  @override
  String spaTitle(String name) {
    return 'Dia de spa de $name';
  }

  @override
  String spaStepOf(int step, int total) {
    return 'Passo $step de $total';
  }

  @override
  String get spaStepFoam => 'Espuma';

  @override
  String get spaStepRinse => 'Enxágue';

  @override
  String get spaStepTowel => 'Toalha';

  @override
  String get spaStepDry => 'Secar';

  @override
  String get spaHintFoam => 'Esfregue para fazer bolhas';

  @override
  String get spaHintRinse => 'Arraste o chuveiro sobre a espuma';

  @override
  String get spaHintTowel => 'Esfregue de leve até secar';

  @override
  String get spaHintDry => 'Seque com o secador para ficar bem fofinho';

  @override
  String get spaHintDone => 'Fresquinho! Brinque ou comece de novo';

  @override
  String get spaAgain => 'Mais um spa';

  @override
  String get spaFreshToast => 'Novo no diário: Dia de spa';

  @override
  String get bubbleFresh => 'Fresquinho!';

  @override
  String get snackApple => 'Maçã';

  @override
  String get snackCarrot => 'Cenoura';

  @override
  String get snackCorn => 'Milho';

  @override
  String get snackLettuce => 'Alface';

  @override
  String get snackWatermelon => 'Melancia';

  @override
  String get snackBone => 'Osso';

  @override
  String get snackBacon => 'Bacon';

  @override
  String get snackCheese => 'Queijo';

  @override
  String get snackCupcake => 'Cupcake';

  @override
  String get snackBlueberry => 'Mirtilos';

  @override
  String get snackCherry => 'Cerejas';

  @override
  String get snackGrape => 'Uvas';

  @override
  String get snackPeach => 'Pêssego';

  @override
  String kitchenMenuFor(String name) {
    return 'Cardápio de $name · arraste até a boca';
  }

  @override
  String kitchenLeft(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Mais $count nesta hora',
      one: 'Mais 1 nesta hora',
      zero: 'Cheio por agora',
    );
    return '$_temp0';
  }

  @override
  String get kitchenEmptyHint =>
      'Toque em um amigo abaixo para convidá-lo para um lanche';

  @override
  String kitchenFavoriteToast(String name, String snack) {
    return 'Favorito de $name: $snack! +1 ★';
  }

  @override
  String get kitchenPickHint => 'Toque em um amigo para escolher quem come';

  @override
  String get bedLamp => 'Luz noturna';

  @override
  String get bedTuckIn => 'Cobrir';

  @override
  String get bedWakeUp => 'Acordar';

  @override
  String get sleepSounds => 'Sons para dormir';

  @override
  String get sleepPlay => 'Tocar';

  @override
  String get sleepStop => 'Parar';

  @override
  String get sleepMix => 'Mix';

  @override
  String get sleepTimer => 'Timer';

  @override
  String get sleepTimerOff => 'Desligado';

  @override
  String sleepMinutes(int minutes) {
    return '$minutes min';
  }

  @override
  String get sleepRain => 'Chuva';

  @override
  String get sleepPurr => 'Ronronar';

  @override
  String get sleepFire => 'Lareira';

  @override
  String get sleepOcean => 'Oceano';

  @override
  String get sleepChimes => 'Sinos de vento';

  @override
  String get sleepNoise => 'Ruído suave';

  @override
  String get sleepScreenOff => 'Continua tocando com a tela apagada';

  @override
  String sleepEndsIn(int minutes) {
    return 'Para em $minutes min';
  }

  @override
  String sleepVolume(String channel) {
    return 'Volume: $channel';
  }

  @override
  String get gameBoopRush => 'Boop Rush';

  @override
  String get gameBoopRushDesc =>
      'Dê um boop em cada focinho que aparecer. 30 segundos.';

  @override
  String get gameSnackCatch => 'Snack Catch';

  @override
  String get gameSnackCatchDesc =>
      'Deslize um amigo para pegar lanches e fugir das abelhas. 45 segundos.';

  @override
  String gameBest(int score) {
    return 'Recorde $score';
  }

  @override
  String gameStarsCap(int count) {
    return 'Até $count ★ por dia';
  }

  @override
  String gamePlay(String game) {
    return 'Jogar $game';
  }

  @override
  String get gameReady => 'Pronto?';

  @override
  String get gameGo => 'Já!';

  @override
  String gameScore(int score) {
    return 'Pontos $score';
  }

  @override
  String gameTime(int seconds) {
    return '${seconds}s';
  }

  @override
  String get gamePause => 'Pausar';

  @override
  String get gameResume => 'Continuar';

  @override
  String get gameQuit => 'Sair';

  @override
  String get gameTimesUp => 'Acabou o tempo!';

  @override
  String get gameNewBest => 'Novo recorde!';

  @override
  String gameStarsEarned(int count) {
    return '+$count ★';
  }

  @override
  String get gamePlayAgain => 'Jogar de novo';

  @override
  String get gameDone => 'Pronto';

  @override
  String get gameCatcherHint => 'Arraste para a esquerda e a direita';

  @override
  String get gameBoopHint => 'Dê boop nos focinhos! Não acorde os sonolentos.';

  @override
  String get gardenEggReadyTitle => 'Um ovo novo está pronto!';

  @override
  String get gardenEggReadyHint => 'Toque no ovo para receber um novo amigo';

  @override
  String gardenNextEgg(int stars) {
    return 'Próximo amigo com $stars ★';
  }

  @override
  String gardenProgress(int have, int need) {
    return '$have de $need ★';
  }

  @override
  String get gardenEggHint => 'Cuide dos seus amigos para ganhar estrelas';

  @override
  String get gardenAllHatched => 'Todo mundo já chocou!';

  @override
  String gardenEggNotYet(int stars) {
    return 'Este ovo precisa de $stars ★';
  }

  @override
  String hatchNameTitle(String species) {
    return 'Seu novo amigo: $species. Dê um nome a ele';
  }

  @override
  String get gardenGift => 'Presente diário';

  @override
  String gardenGiftDay(int day) {
    return 'Presente diário · dia $day';
  }

  @override
  String get gardenGiftClaimed => 'Volte amanhã';

  @override
  String get gardenPhotoBooth => 'Cabine de fotos';

  @override
  String toastGift(int count) {
    return '+$count ★ · até amanhã!';
  }

  @override
  String toastNewFriend(String name) {
    return 'Diga oi para $name!';
  }

  @override
  String get speciesMofu => 'bolinha de pelo';

  @override
  String get speciesOink => 'porquinho';

  @override
  String get speciesWuff => 'cachorrinho';

  @override
  String get speciesBoop => 'boop';

  @override
  String eggLabel(String state) {
    return 'Ovo. $state';
  }

  @override
  String get cardTabPlay => 'Brincar';

  @override
  String get cardTabWardrobe => 'Visual';

  @override
  String get cardTabJournal => 'Diário';

  @override
  String cardHatched(String date) {
    return 'Chocou em $date';
  }

  @override
  String cardLoves(String snack) {
    return 'Favorito: $snack';
  }

  @override
  String get cardLovesSecret => 'Lanche favorito: segredo!';

  @override
  String cardLevel(int level) {
    return 'Nível de amizade $level';
  }

  @override
  String get cardRename => 'Renomear';

  @override
  String get cardMoveTo => 'Mover para…';

  @override
  String get cardTricks => 'Truques';

  @override
  String get cardVoice => 'Voz';

  @override
  String get trickMastered => 'Dominado';

  @override
  String trickPractice(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Mais $count dias',
      one: 'Mais 1 dia',
    );
    return '$_temp0';
  }

  @override
  String get trickTryIt => 'Experimente!';

  @override
  String get trickDoneToday => 'Treinado hoje';

  @override
  String get trickSit => 'Sentar';

  @override
  String get trickPaw => 'Patinha';

  @override
  String get trickSpin => 'Girar';

  @override
  String get trickSpeak => 'Falar';

  @override
  String get trickPlayDead => 'Fingir de morto';

  @override
  String get trickHighFive => 'Toca aqui';

  @override
  String get wardrobeCoats => 'Pelagens';

  @override
  String get wardrobeAccessories => 'Acessórios';

  @override
  String unlockLevel(int level) {
    return 'Nível de amizade $level';
  }

  @override
  String unlockStars(int stars) {
    return '$stars ★ no total';
  }

  @override
  String get unlockSeasonal => 'Sazonal';

  @override
  String journalCount(int have, int total) {
    return '$have de $total encontradas';
  }

  @override
  String get journalHidden => '???';

  @override
  String get accScarf => 'Cachecol';

  @override
  String get accBandana => 'Bandana';

  @override
  String get accBell => 'Coleira com sino';

  @override
  String get accBowtie => 'Gravata-borboleta';

  @override
  String voicePad(String name) {
    return 'Tocar a voz de $name';
  }

  @override
  String toastTrickMastered(String name, String trick) {
    return '$name dominou o truque «$trick»!';
  }

  @override
  String toastMoved(String name, String room) {
    return '$name → $room';
  }

  @override
  String get wearNone => 'Nada';

  @override
  String get settingsReduceMotion => 'Reduzir movimento';

  @override
  String get settingsCredits => 'Créditos';

  @override
  String get creditsBody =>
      'Feito com carinho por Ouadie Zerhouni. Cada amigo, cômodo e som deste app é original.';

  @override
  String get creditsAudio =>
      'Alguns efeitos sonoros feitos com Stable Audio · Powered by Stability AI';

  @override
  String get resetHouseBody =>
      'Isso apaga todos os amigos, todas as estrelas, o visual e o diário. Não dá para desfazer.';

  @override
  String get photoTitle => 'Cabine de fotos';

  @override
  String get photoBackdrop => 'Cenário';

  @override
  String get photoFriends => 'Amigos';

  @override
  String get photoStickers => 'Stickers';

  @override
  String get photoShare => 'Compartilhar';

  @override
  String get photoHint => 'Arraste amigos e stickers para o lugar';

  @override
  String get photoClose => 'Fechar';

  @override
  String get photoShareText => 'Meus amigos no Mofu';

  @override
  String get photoRemoveSticker =>
      'Toque duas vezes em um sticker para removê-lo';

  @override
  String get sleepSoundOff => 'Os sons estão desligados. Ative-os nos Ajustes.';
}
