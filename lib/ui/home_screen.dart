import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/semantics.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../core/app_scope.dart';
import '../core/debug_flags.dart';
import '../core/test_env.dart';
import '../l10n/app_localizations.dart';
import '../model/catalog.dart';
import '../model/pet_store.dart';
import '../sim/mofu_sim.dart';
import 'first_run.dart';
import 'icons.dart';
import 'journal_sheet.dart';
import 'mofu_painter.dart';
import 'names.dart';
import 'room.dart';
import 'settings_sheet.dart';
import 'theme.dart';
import 'wardrobe_sheet.dart';
import 'widgets.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late final AppServices _app;
  late final PetStore _store;
  final MofuSim sim = MofuSim(seed: DateTime.now().millisecondsSinceEpoch & 0xFFFF);
  final ValueNotifier<int> _frame = ValueNotifier(0);
  final ToastController _toasts = ToastController();
  late final Ticker _ticker;
  Duration _last = Duration.zero;
  StreamSubscription<UserAccelerometerEvent>? _accel;
  final List<double> _shakePeaks = [];
  Timer? _clockTimer;
  RoomPeriod _period = RoomPeriod.day;
  bool _snacksOpen = false;
  Set<String> _unlockedKeys = {};
  bool _dialogShown = false;
  bool _started = false;

  AppLocalizations get _l => AppLocalizations.of(context);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _ticker = createTicker(_tick);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    _app = AppScope.of(context);
    _store = _app.store;
    _store.addListener(_onStore);
    _app.config.addListener(_onConfig);
    _onStore();
    _unlockedKeys = _allUnlockedKeys();
    _updateClock();
    _clockTimer = Timer.periodic(const Duration(minutes: 1), (_) => _updateClock());
    _onConfig();
    _ticker.start();
    if (!skipDeviceOnlyWork) _startShakeDetection();
    WidgetsBinding.instance.addPostFrameCallback((_) => _onVisit());
    _applyDebugPose();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _ticker.dispose();
    _accel?.cancel();
    _clockTimer?.cancel();
    _store.removeListener(_onStore);
    _app.config.removeListener(_onConfig);
    _app.sfx.stopAllLoops();
    _toasts.dispose();
    _frame.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _updateClock();
      unawaited(_app.config.refresh());
      _onVisit();
    } else if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      sim.pointerCancel(sim.activePointer ?? -1);
      _app.sfx.stopAllLoops();
      unawaited(_store.flush());
    }
  }

  // ── clock, visits, seasons ────────────────────────────────────────────
  void _updateClock() {
    final now = _app.clock();
    final p = DebugFlags.forcedPeriod ?? periodFor(now);
    sim.night = p == RoomPeriod.night && isNight(now);
    if (p != _period && mounted) setState(() => _period = p);
  }

  void _onVisit() {
    if (!mounted || !_store.firstRunDone) return;
    _store.registerVisit();
    final now = _app.clock();
    if (now.hour >= 0 && now.hour < 4) _discover('nightOwl');
    if (now.hour >= 5 && now.hour < 8) _discover('earlyBird');
    final season = _app.config.value.openSeason(now);
    if (season != null && _store.earnSeasonal(season.id)) {
      final acc = Catalog.accessories.where((a) => a.rule.seasonId == season.id).firstOrNull;
      if (acc != null) {
        _toasts.show(_l.toastSeasonal(_l.accessoryName(acc.id)));
        _app.sfx.play('unlock');
      }
    }
    _checkUnlocks();
    _maybeShowRemoteDialogs();
  }

  void _onConfig() {
    final c = _app.config.value;
    sim.tossEnabled = c.tossEnabled;
    _app.sfx.remoteSoundsEnabled = c.soundsEnabled;
    if (!c.soundsEnabled) _app.sfx.stopAllLoops();
  }

  void _onStore() {
    sim.fluff = _store.fluffFraction;
    _app.sfx
      ..soundOn = _store.soundOn
      ..hapticsOn = _store.hapticsOn;
    if (!_store.soundOn) _app.sfx.stopAllLoops();
    if (mounted) setState(() {});
  }

  // ── shake ─────────────────────────────────────────────────────────────
  void _startShakeDetection() {
    try {
      _accel = userAccelerometerEventStream(samplingPeriod: SensorInterval.gameInterval).listen((e) {
        final mag = math.sqrt(e.x * e.x + e.y * e.y + e.z * e.z);
        if (mag < 16) return;
        final t = sim.time;
        _shakePeaks
          ..add(t)
          ..removeWhere((p) => t - p > 0.7);
        if (_shakePeaks.length >= 3 && _app.config.value.shakeEnabled && _store.firstRunDone) {
          _shakePeaks.clear();
          sim.shake();
        }
      }, onError: (Object _) {});
    } catch (_) {}
  }

  // ── frame loop ────────────────────────────────────────────────────────
  void _tick(Duration elapsed) {
    final dt = _last == Duration.zero ? 1 / 60 : (elapsed - _last).inMicroseconds / 1e6;
    _last = elapsed;
    sim.reduceMotion = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    sim.update(dt);
    for (final e in sim.drainEvents()) {
      _handle(e);
    }
    _frame.value++;
  }

  void _handle(SimEvent e) {
    switch (e.type) {
      case SimEventType.sound:
        _app.sfx.play(e.id);
      case SimEventType.loopStart:
        _app.sfx.startLoop(e.id);
      case SimEventType.loopStop:
        _app.sfx.stopLoop(e.id);
      case SimEventType.haptic:
        _app.sfx.haptic(e.id);
      case SimEventType.reaction:
        if (e.id == 'pet' || e.id == 'brush') _store.completeCoach();
        _discover(e.id);
      case SimEventType.fluff:
        _addFluff(e.value);
      case SimEventType.brushed:
        if (_store.registerBrush()) {
          sim.sparkleBurst();
          _toasts.show(_l.toastDailyBrush);
          _addFluff(3);
        }
      case SimEventType.coach:
        _store.completeCoach();
    }
  }

  void _discover(String id) {
    if (!_store.discover(id)) return;
    final (name, _) = _l.reaction(id);
    _toasts.show(_l.toastNewReaction(name));
    _checkUnlocks();
  }

  void _addFluff(double amount) {
    final crossed = _store.addFluff(amount);
    for (final m in crossed) {
      sim.celebrate();
      _toasts.show(m >= 100 ? _l.toastMaxFluff : _l.toastFluffMilestone(m));
      if (m >= 25) _discover('fluffy');
      if (m >= 100) _discover('maxFluff');
    }
    if (crossed.isNotEmpty) _checkUnlocks();
  }

  Set<String> _allUnlockedKeys() => {
        for (final c in Catalog.furColors)
          if (c.rule.kind != UnlockKind.start && _store.isUnlocked(c.rule)) 'color:${c.id}',
        for (final a in Catalog.accessories)
          if (a.rule.kind != UnlockKind.start && _store.isUnlocked(a.rule)) 'acc:${a.id}',
      };

  void _checkUnlocks() {
    final now = _allUnlockedKeys();
    final fresh = now.difference(_unlockedKeys);
    _unlockedKeys = now;
    for (final k in fresh) {
      // Seasonal gifts already announced themselves with their own toast.
      if (k.startsWith('acc:') && Catalog.accessory(k.substring(4)).rule.kind == UnlockKind.seasonal) continue;
      _toasts.show(_l.toastUnlocked(_l.unlockKeyName(k)));
      _app.sfx.play('unlock');
    }
  }

  // ── remote dialogs ────────────────────────────────────────────────────
  void _maybeShowRemoteDialogs() {
    if (_dialogShown || !mounted) return;
    final cfg = _app.config;
    final url = cfg.value.updateUrlIos;
    if (cfg.updateRequired || cfg.updateAvailable) {
      _dialogShown = true;
      final required = cfg.updateRequired;
      showDialog<void>(
        context: context,
        barrierDismissible: !required,
        builder: (ctx) => PopScope(
          canPop: !required,
          child: AlertDialog(
            title: Text(_l.updateTitle),
            content: Text(required ? _l.updateRequiredBody : _l.updateBody),
            actions: [
              if (!required) TextButton(onPressed: () => Navigator.pop(ctx), child: Text(_l.updateLater)),
              FilledButton(
                onPressed: () => launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication),
                child: Text(_l.updateAction),
              ),
            ],
          ),
        ),
      );
      return;
    }
    final ann = cfg.value.announcement;
    if (ann != null && ann.id != _store.lastAnnouncementId) {
      _dialogShown = true;
      _store.markAnnouncementSeen(ann.id);
      final lang = Localizations.localeOf(context).languageCode;
      showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(ann.title.resolve(lang)),
          content: Text(ann.body.resolve(lang)),
          actions: [
            FilledButton(
              onPressed: () {
                Navigator.pop(ctx);
                if (ann.url.isNotEmpty) launchUrl(Uri.parse(ann.url), mode: LaunchMode.externalApplication);
              },
              child: Text(_l.actionOk),
            ),
          ],
        ),
      );
    }
  }

  // ── debug poses for screenshots ───────────────────────────────────────
  void _applyDebugPose() {
    final pose = DebugFlags.pose;
    if (pose.isEmpty) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      switch (pose) {
        case 'love':
          sim.holdExpression(Expr.love);
        case 'giggle':
          sim.holdExpression(Expr.giggle);
        case 'happy':
          sim.holdExpression(Expr.happy);
        case 'sleep':
          sim.idleTime = 999;
        case 'dizzy':
          sim.shake();
        case 'brush':
          setState(() => sim.brushMode = true);
      }
    });
  }

  // ── UI actions ────────────────────────────────────────────────────────
  void _toggleBrush() {
    setState(() {
      sim.brushMode = !sim.brushMode;
      if (sim.brushMode) _snacksOpen = false;
    });
    _app.sfx.haptic('selection');
  }

  void _toggleSnacks() {
    setState(() {
      _snacksOpen = !_snacksOpen;
      if (_snacksOpen) sim.brushMode = false;
    });
    _app.sfx.haptic('selection');
  }

  Future<void> _openWardrobe() async {
    final before = (_store.colorId, _store.accessoryId);
    await showWardrobe(context);
    if (!mounted) return;
    final changedColor = _store.colorId != before.$1;
    final changedAcc = _store.accessoryId != before.$2;
    if (changedColor) _discover('newLook');
    if (changedAcc && _store.accessoryId != 'none') _discover('dressUp');
    if (changedColor || changedAcc) sim.celebrateSmall();
  }

  Future<void> _openJournal() => showJournal(context);

  Future<void> _openSettings() => showSettings(context);

  void _onSnackDropped(Snack snack, Offset local) {
    if (!sim.hitBody(local) && !sim.nearMouth(local)) {
      sim.setSnackHover(false);
      return;
    }
    switch (_store.feed(snack.id)) {
      case FeedResult.eaten:
        sim.eat(favorite: false);
      case FeedResult.favorite:
        sim.eat(favorite: true);
      case FeedResult.full:
        sim.refuseFull();
        _toasts.show(_l.toastFull(_store.name));
    }
    _checkUnlocks();
  }

  /// Snack feedback is a 56-pt square; its centre is what the user aims with.
  Offset _snackCentre(BuildContext roomContext, Offset globalTopLeft) {
    final box = roomContext.findRenderObject() as RenderBox;
    return box.globalToLocal(globalTopLeft + const Offset(28, 28));
  }

  // ── build ─────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final l = _l;
    final media = MediaQuery.of(context);
    final color = Catalog.color(_store.colorId);

    return Scaffold(
      body: LayoutBuilder(builder: (context, box) {
        final size = box.biggest;
        final top = media.padding.top + 96;
        final dockH = 92 + media.padding.bottom + (_snacksOpen ? 96 : 0);
        final floor = size.height - dockH - 30;
        sim.layout(size, top: top, floor: floor);

        return Stack(
          children: [
            Positioned.fill(
              child: RepaintBoundary(
                child: CustomPaint(
                  painter: RoomPainter(period: _period, floorY: floor, time: () => sim.time, repaint: _frame),
                ),
              ),
            ),
            Positioned.fill(
              child: Builder(builder: (roomContext) {
                return DragTarget<Snack>(
                  onMove: (d) {
                    final p = _snackCentre(roomContext, d.offset);
                    sim.setSnackHover(sim.hitBody(p) || sim.nearMouth(p), p);
                  },
                  onLeave: (_) => sim.setSnackHover(false),
                  onAcceptWithDetails: (d) => _onSnackDropped(d.data, _snackCentre(roomContext, d.offset)),
                  builder: (context, candidates, rejected) => Semantics(
                    label: l.semanticsMofu(_store.name),
                    hint: sim.brushMode ? l.semanticsBrushOn : null,
                    onTap: () => sim.tapCentre(),
                    customSemanticsActions: {
                      CustomSemanticsAction(label: l.semanticsHug): () => sim.celebrateSmall(),
                    },
                    child: Listener(
                      behavior: HitTestBehavior.opaque,
                      onPointerDown: (e) => sim.pointerDown(e.pointer, e.localPosition),
                      onPointerMove: (e) => sim.pointerMove(e.pointer, e.localPosition),
                      onPointerUp: (e) => sim.pointerUp(e.pointer, e.localPosition),
                      onPointerCancel: (e) => sim.pointerCancel(e.pointer),
                      child: RepaintBoundary(
                        child: CustomPaint(
                          size: size,
                          painter: MofuPainter(sim: sim, color: color, accessory: _store.accessoryId, repaint: _frame),
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
            if (sim.brushMode)
              ValueListenableBuilder<int>(
                valueListenable: _frame,
                builder: (context, _, _) {
                  final f = sim.finger;
                  // Must stay a Positioned: a bare child would size the Stack to it.
                  if (f == null) return const Positioned(left: 0, top: 0, child: SizedBox.shrink());
                  return Positioned(
                    left: f.dx - 22,
                    top: f.dy - 44,
                    child: const IgnorePointer(child: MofuIconView(MofuIcon.brush, size: 44)),
                  );
                },
              ),
            if (!_store.coachDone && _store.firstRunDone)
              ValueListenableBuilder<int>(
                valueListenable: _frame,
                builder: (context, _, _) {
                  const w = 240.0;
                  final left = (sim.pos.dx - w / 2).clamp(8.0, math.max(8.0, size.width - w - 8)).toDouble();
                  return Positioned(
                    left: left,
                    width: w,
                    top: math.max(top - 12, sim.pos.dy - sim.radius - sim.furLength - 70),
                    child: IgnorePointer(
                      child: Center(child: SpeechBubble(text: sim.brushMode ? l.coachBrush(_store.name) : l.coachPetMe)),
                    ),
                  );
                },
              ),
            Positioned(
              top: media.padding.top + 10,
              left: 16,
              right: 16,
              child: _Header(
                name: _store.name,
                fluff: _store.fluff.floor(),
                days: math.max(1, _store.visitDays),
                onSettings: _openSettings,
                settingsLabel: l.semanticsSettings,
              ),
            ),
            Positioned(
              top: media.padding.top + 86,
              left: 0,
              right: 0,
              child: IgnorePointer(child: Center(child: ToastView(controller: _toasts))),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AnimatedSize(
                        duration: const Duration(milliseconds: 220),
                        curve: Curves.easeOutCubic,
                        child: _snacksOpen
                            ? SnackTray(hint: l.snacksHint(_store.name))
                            : const SizedBox(width: double.infinity),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          DockButton(
                            onDark: _period == RoomPeriod.night,
                            icon: const MofuIconView(MofuIcon.brush, size: 34),
                            label: l.dockBrush,
                            active: sim.brushMode,
                            onTap: _toggleBrush,
                          ),
                          DockButton(
                            onDark: _period == RoomPeriod.night,
                            icon: const MofuIconView(MofuIcon.snacks, size: 32),
                            label: l.dockSnacks,
                            active: _snacksOpen,
                            onTap: _toggleSnacks,
                          ),
                          DockButton(
                            onDark: _period == RoomPeriod.night,
                            icon: const MofuIconView(MofuIcon.wardrobe, size: 34),
                            label: l.dockWardrobe,
                            dot: _store.unseenUnlocks.isNotEmpty,
                            onTap: _openWardrobe,
                          ),
                          DockButton(
                            onDark: _period == RoomPeriod.night,
                            icon: const MofuIconView(MofuIcon.journal, size: 30),
                            label: l.dockJournal,
                            onTap: _openJournal,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if (!_store.firstRunDone)
              Positioned.fill(
                child: FirstRunOverlay(
                  colorId: _store.colorId,
                  onDone: () {
                    _store.completeFirstRun();
                    sim.celebrateSmall();
                    _onVisit();
                  },
                ),
              ),
          ],
        );
      }),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.name,
    required this.fluff,
    required this.days,
    required this.onSettings,
    required this.settingsLabel,
  });

  final String name;
  final int fluff;
  final int days;
  final VoidCallback onSettings;
  final String settingsLabel;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsetsDirectional.fromSTEB(16, 10, 16, 12),
            decoration: BoxDecoration(
              color: MofuColors.card.withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [BoxShadow(color: MofuColors.ink.withValues(alpha: 0.08), blurRadius: 14, offset: const Offset(0, 4))],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Flexible(
                      child: Text(name, maxLines: 1, overflow: TextOverflow.ellipsis, style: t.titleLarge?.copyWith(height: 1.15)),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(l.daysTogether(days), maxLines: 1, overflow: TextOverflow.ellipsis, style: t.bodySmall),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Semantics(
                  label: l.fluffPercent(fluff),
                  excludeSemantics: true,
                  child: Row(
                    children: [
                      const Icon(Icons.cloud_rounded, size: 18, color: MofuColors.accent),
                      const SizedBox(width: 6),
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: TweenAnimationBuilder<double>(
                            tween: Tween(end: fluff / 100),
                            duration: const Duration(milliseconds: 400),
                            builder: (context, v, _) => LinearProgressIndicator(
                              value: v,
                              minHeight: 9,
                              backgroundColor: MofuColors.line,
                              valueColor: const AlwaysStoppedAnimation(MofuColors.accent),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(l.fluffPercent(fluff), style: t.bodySmall?.copyWith(color: MofuColors.ink, fontWeight: FontWeight.w800)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 10),
        Semantics(
          button: true,
          label: settingsLabel,
          excludeSemantics: true,
          child: GestureDetector(
            onTap: onSettings,
            child: Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: MofuColors.card.withValues(alpha: 0.9),
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: MofuColors.ink.withValues(alpha: 0.08), blurRadius: 14, offset: const Offset(0, 4))],
              ),
              child: const Icon(Icons.settings_rounded, color: MofuColors.ink, size: 26),
            ),
          ),
        ),
      ],
    );
  }
}

class SnackTray extends StatelessWidget {
  const SnackTray({super.key, required this.hint});
  final String hint;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.fromLTRB(10, 8, 10, 6),
      decoration: BoxDecoration(
        color: MofuColors.card.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(26),
        boxShadow: [BoxShadow(color: MofuColors.ink.withValues(alpha: 0.10), blurRadius: 16, offset: const Offset(0, 6))],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(hint, style: Theme.of(context).textTheme.bodySmall, textAlign: TextAlign.center),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              for (final s in Catalog.snacks)
                Draggable<Snack>(
                  data: s,
                  feedback: Material(
                    color: Colors.transparent,
                    child: MofuIconView(snackIcon(s.id), size: 56),
                  ),
                  childWhenDragging: Opacity(opacity: 0.25, child: _SnackChip(snack: s)),
                  child: Semantics(label: l.snackName(s.id), child: _SnackChip(snack: s)),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SnackChip extends StatelessWidget {
  const _SnackChip({required this.snack});
  final Snack snack;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 48,
      height: 48,
      child: Center(child: MofuIconView(snackIcon(snack.id), size: 38)),
    );
  }
}
