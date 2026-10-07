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
    return 'Novo! $name';
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
}
