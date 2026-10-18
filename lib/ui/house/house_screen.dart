import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:sensors_plus/sensors_plus.dart';

import '../../core/app_scope.dart';
import '../../core/test_env.dart';
import '../../creatures/creature.dart';
import '../../l10n/app_localizations.dart';
import '../../model/house_store.dart';
import '../../world/house_controller.dart';
import '../name_dialog.dart';
import '../theme.dart';
import '../widgets.dart';
import 'backdrops.dart';
import 'house_text.dart';
import 'parts.dart';
import 'room_context.dart';
import 'room_stage.dart';
import 'rooms.dart';

/// The home screen: a swipeable house of six rooms. Top bar (settings, room
/// switcher, stars), the room with its friends, and a wooden shelf with the
/// friend coins and that room's tools.
class HouseScreen extends StatefulWidget {
  const HouseScreen({super.key});

  @override
  State<HouseScreen> createState() => HouseScreenState();
}

class HouseScreenState extends State<HouseScreen> with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late HouseController house;
  late PageController _pages;
  late final Ticker _ticker = createTicker(_tick);
  final ValueNotifier<int> frame = ValueNotifier(0);
  final ToastController _toasts = ToastController();
  final ValueNotifier<double> _shelfH = ValueNotifier(180);
  Duration _last = Duration.zero;
  bool _started = false;
  bool _locked = false;
  bool _hatching = false;
  final Set<int> _pointersOnFriend = {};
  late AppServices _app;
  StreamSubscription<UserAccelerometerEvent>? _accel;
  final List<double> _shakePeaks = [];

  AppLocalizations get _l => AppLocalizations.of(context);

  @visibleForTesting
  void clearToasts() => _toasts.clear();
  HouseStore get store => _app.store;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    _app = AppScope.of(context);
    house = HouseController(store: _app.store, audio: _app.audio, clock: _app.clock);
    house.active = store.lastRoom;
    _pages = PageController(initialPage: store.lastRoom.index);
    store.addListener(_onStore);
    _ticker.start();
    if (!skipDeviceOnlyWork) _startShakeDetection();
    WidgetsBinding.instance.addPostFrameCallback((_) => _onVisit());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    unawaited(_accel?.cancel());
    store.removeListener(_onStore);
    _ticker.dispose();
    house.dispose();
    _pages.dispose();
    _toasts.dispose();
    _shelfH.dispose();
    frame.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      unawaited(_app.config.refresh());
      _onVisit();
    } else if (state == AppLifecycleState.paused) {
      _app.audio.stopAllLoops();
      unawaited(store.flush());
    }
  }

  /// Three strong jolts within 0.7 s = a shake; everyone in the room reacts.
  void _startShakeDetection() {
    try {
      _accel = userAccelerometerEventStream(samplingPeriod: SensorInterval.gameInterval).listen((e) {
        final mag = math.sqrt(e.x * e.x + e.y * e.y + e.z * e.z);
        if (mag < 16) return;
        final t = house.time;
        _shakePeaks
          ..add(t)
          ..removeWhere((p) => t - p > 0.7);
        if (_shakePeaks.length >= 3 && _app.config.value.shakeEnabled && store.firstRunDone) {
          _shakePeaks.clear();
          house.shake();
        }
      }, onError: (Object _) {});
    } catch (_) {}
  }

  void _onStore() {
    // After "Start over" the house is empty again: show the seed once more.
    if (!store.firstRunDone && store.friends.isEmpty) _hatching = false;
    _app.audio
      ..soundOn = store.soundOn
      ..hapticsOn = store.hapticsOn;
    if (mounted) setState(() {});
  }

  void _onVisit() {
    if (!mounted || !store.firstRunDone) return;
    store.registerVisit();
  }

  void _tick(Duration elapsed) {
    final dt = _last == Duration.zero ? 1 / 60 : (elapsed - _last).inMicroseconds / 1e6;
    _last = elapsed;
    house.tick(dt.clamp(0, 0.1));
    for (final n in house.drainNotices()) {
      _notice(n);
    }
    frame.value++;
  }

  void _notice(HouseNotice n) {
    final l = _l;
    switch (n.kind) {
      case 'discovered':
        _toasts.show(l.toastNewReaction(l.reactionName(n.a)));
      case 'stars':
        _toasts.show(l.toastStars(n.amount));
      case 'levelUp':
        final f = store.friend(n.a);
        if (f != null) _toasts.show(l.toastLevelUp(f.name, n.amount));
      case 'eggReady':
        _toasts.show(l.toastEggReady);
      case 'fluffMilestone':
        final f = store.friend(n.a);
        if (f != null) _toasts.show(l.toastFluffy(f.name, n.amount));
    }
  }

  // Rooms call these after awaits (dialogs, hatch animation): the screen may be gone by then.
  void toast(String message) {
    if (mounted) _toasts.show(message);
  }

  void _lockPaging(bool locked) {
    if (!mounted || _locked == locked) return;
    setState(() => _locked = locked);
  }

  /// The room a multi-page `goTo` is flying to: rooms passed on the way are not entered
  /// (no bedtime in a bedroom you only flew past).
  Room? _flyingTo;

  void goTo(Room r) {
    if (!_pages.hasClients) return;
    if (store.reduceMotion || skipDeviceOnlyWork) {
      _pages.jumpToPage(r.index);
    } else {
      setState(() => _flyingTo = r);
      unawaited(
        _pages.animateToPage(r.index, duration: const Duration(milliseconds: 420), curve: Curves.easeInOutCubic).whenComplete(() {
          _flyingTo = null;
          if (!mounted || !_pages.hasClients) return;
          final i = (_pages.page ?? r.index.toDouble()).round();
          if (Room.values[i] != house.active) _onPage(i);
        }),
      );
    }
  }

  void _onPage(int i) {
    if (_flyingTo != null && i != _flyingTo!.index) return;
    _toasts.clear(); // news from the room you left would read as stale here
    final r = Room.values[i];
    final rc = _rc();
    roomModule(house.active).onLeave(rc);
    house.setActive(r);
    roomModule(r).onEnter(rc);
    _app.audio.haptic('selection');
    setState(() {});
  }

  Future<void> openFriend(String id) async {
    // Friend card arrives in the next module; keep the hook.
    final f = store.friend(id);
    if (f == null) return;
    await showFriendCard(context, house: house, friendId: id, toast: toast);
  }

  RoomContext _rc() => RoomContext(
    house: house,
    frame: frame,
    l: _l,
    toast: toast,
    lockPaging: _lockPaging,
    goTo: goTo,
    openFriend: (id) => unawaited(openFriend(id)),
    bottomInset: MediaQuery.of(context).padding.bottom,
  );

  // ── first run ─────────────────────────────────────────────────────────
  Future<void> _hatchFirst() async {
    // Let the seed's pop play, then reveal the room so the newcomer is
    // visible behind the naming dialog.
    await Future<void>.delayed(const Duration(milliseconds: 450));
    if (!mounted) return;
    setState(() => _hatching = true);
    _app.audio.play('ui.fanfare');
    // Reuse a Mofu adopted before an interrupted first run (app killed while naming).
    final m = store.friends.firstOrNull ?? store.adopt(Species.mofu);
    store.moveTo(m.id, Room.living);
    house.sync();
    goTo(Room.living);
    await Future<void>.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;
    final name = await askName(context, initial: m.name, firstRun: true);
    if (name != null) store.rename(m.id, name);
    store.completeFirstRun();
  }

  @override
  Widget build(BuildContext context) {
    final l = _l;
    final media = MediaQuery.of(context);
    final rc = _rc();
    final module = roomModule(house.active);
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, box) {
          final size = box.biggest;
          final top = media.padding.top + 120;
          double floorFor(Room r) => size.height - (104 + roomModule(r).shelfExtra + media.padding.bottom) - 34;
          house.layoutRooms(top: top, width: size.width, floorFor: floorFor, sizeScale: (size.width / 390).clamp(0.85, 1.25));
          return Stack(
            children: [
              Positioned.fill(
                child: AnimatedBuilder(
                  animation: _pages,
                  builder: (context, _) => PageView.builder(
                    controller: _pages,
                    physics: _locked ? const NeverScrollableScrollPhysics() : const PageScrollPhysics(),
                    onPageChanged: _onPage,
                    itemCount: Room.values.length,
                    itemBuilder: (context, i) {
                      final room = Room.values[i];
                      final page = _pages.hasClients && _pages.position.haveDimensions
                          ? (_pages.page ?? i.toDouble())
                          : house.active.index.toDouble();
                      final parallax = (i - page).clamp(-1.0, 1.0);
                      final active = room == house.active;
                      return Stack(
                        fit: StackFit.expand,
                        children: [
                          RepaintBoundary(
                            child: ValueListenableBuilder<int>(
                              valueListenable: frame,
                              builder: (context, _, _) => CustomPaint(
                                painter: RoomBackdrop(
                                  room: room,
                                  daypart: house.daypart,
                                  floorY: floorFor(room),
                                  parallax: parallax,
                                  time: active ? house.time : 0,
                                  lampOn: roomLampOn(room),
                                ),
                              ),
                            ),
                          ),
                          Listener(
                            behavior: HitTestBehavior.translucent,
                            onPointerDown: (e) {
                              if (!active) return;
                              if (house.scene.creatures.any((c) => c.hitTest(e.localPosition))) {
                                _pointersOnFriend.add(e.pointer);
                                _lockPaging(true);
                              }
                            },
                            onPointerUp: (e) => _release(e.pointer),
                            onPointerCancel: (e) => _release(e.pointer),
                            child: RoomStage(
                              house: house,
                              room: room,
                              frame: frame,
                              interactive: active,
                              bubbleText: (_, key) => l.bubble(key),
                            ),
                          ),
                          if (active) roomModule(room).overlay(context, rc),
                        ],
                      );
                    },
                  ),
                ),
              ),
              Positioned(top: media.padding.top + 8, left: 16, right: 16, child: _topBar(l)),
              // An empty room says what to do instead of showing a bare stage.
              // (The garden's egg and the spa's card are their own calls to action.)
              if (store.firstRunDone && house.scene.creatures.isEmpty && !(house.active == Room.garden && store.nextEgg != null) && house.active != Room.spa)
                Positioned.fill(
                  child: IgnorePointer(
                    child: ValueListenableBuilder<double>(
                      valueListenable: _shelfH,
                      builder: (context, h, _) {
                        final dark = house.active == Room.bedroom && house.daypart == Daypart.night;
                        return Padding(
                          padding: EdgeInsets.only(bottom: h + 70, left: 32, right: 32),
                          child: Align(
                            alignment: Alignment.bottomCenter,
                            child: FeltTag(
                              radius: 22,
                              height: 52,
                              dark: dark,
                              padding: const EdgeInsets.symmetric(horizontal: 18),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Flexible(
                                    child: Text(
                                      l.shelfTapHint,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w900,
                                        fontSize: 15,
                                        color: dark ? House.nightText : House.ink,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Icon(Icons.south_rounded, size: 22, color: dark ? House.nightText : House.rose),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              // Toasts: under the header in rooms without a top card (clear of the friends),
              // otherwise just above the shelf's real top edge.
              Positioned.fill(
                child: IgnorePointer(
                  child: ValueListenableBuilder<double>(
                    valueListenable: _shelfH,
                    builder: (context, h, child) => module.hasTopCard
                        ? Padding(
                            padding: EdgeInsets.only(bottom: h + 14),
                            child: Align(alignment: Alignment.bottomCenter, child: child),
                          )
                        : Padding(
                            padding: EdgeInsets.only(top: media.padding.top + 74),
                            child: Align(alignment: Alignment.topCenter, child: child),
                          ),
                    child: ToastView(controller: _toasts),
                  ),
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: MeasureSize(onChange: (s) => _shelfH.value = s.height, child: _shelf(l, module, rc, media.padding.bottom)),
              ),
              if (!store.firstRunDone)
                Positioned.fill(
                  child: IgnorePointer(
                    ignoring: _hatching,
                    child: AnimatedOpacity(
                      opacity: _hatching ? 0 : 1,
                      duration: const Duration(milliseconds: 400),
                      child: _FirstRun(onHatch: _hatchFirst),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  void _release(int pointer) {
    // Only the fingers that grabbed a friend unlock paging, not any finger lifting elsewhere.
    if (!_pointersOnFriend.remove(pointer)) return;
    if (_pointersOnFriend.isEmpty) _lockPaging(false);
  }

  Widget _topBar(AppLocalizations l) {
    final dark = house.active == Room.bedroom && house.daypart == Daypart.night;
    // Rapid arrow taps step from the room already flown to, not the one being left.
    final i = (_flyingTo ?? house.active).index;
    return Row(
      children: [
        FeltIconButton(
          icon: Icons.settings_rounded,
          label: l.navSettings,
          dark: dark,
          onTap: () => unawaited(showHouseSettings(context, house: house)),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: FeltTag(
            radius: 24,
            dark: dark,
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Row(
              children: [
                _arrow(Icons.chevron_left_rounded, l.navPrevRoom, i > 0 ? () => goTo(Room.values[i - 1]) : null, dark),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // The room name slides in with the page instead of snapping.
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 240),
                        switchInCurve: Curves.easeOutCubic,
                        switchOutCurve: Curves.easeInCubic,
                        transitionBuilder: (child, a) => FadeTransition(
                          opacity: a,
                          child: SlideTransition(position: Tween(begin: const Offset(0, 0.35), end: Offset.zero).animate(a), child: child),
                        ),
                        child: Text(
                          l.roomName(house.active),
                          key: ValueKey(house.active),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: dark ? House.nightText : House.ink),
                        ),
                      ),
                      const SizedBox(height: 3),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          for (var d = 0; d < Room.values.length; d++)
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              margin: const EdgeInsets.symmetric(horizontal: 2.5),
                              width: d == i ? 14 : 5,
                              height: 5,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(3),
                                color: d == i ? House.rose : (dark ? const Color(0x66CFC6FF) : const Color(0xFFD9C3AD)),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                _arrow(
                  Icons.chevron_right_rounded,
                  l.navNextRoom,
                  i < Room.values.length - 1 ? () => goTo(Room.values[i + 1]) : null,
                  dark,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 8),
        StarTag(count: store.stars, label: l.starsCount(store.stars), dark: dark),
      ],
    );
  }

  Widget _arrow(IconData icon, String label, VoidCallback? onTap, bool dark) {
    return Squish(
      child: Semantics(
        button: true,
        enabled: onTap != null,
        label: label,
        excludeSemantics: true,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onTap,
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(shape: BoxShape.circle, color: dark ? Colors.white.withValues(alpha: 0.12) : const Color(0xFFF6E6D3)),
            child: Icon(
              icon,
              size: 24,
              color: onTap == null ? (dark ? const Color(0x66F3EEFF) : const Color(0x553A2A2E)) : (dark ? House.nightText : House.ink),
            ),
          ),
        ),
      ),
    );
  }

  Widget _shelf(AppLocalizations l, RoomModule module, RoomContext rc, double bottom) {
    final here = store.inRoom(house.active);
    final tools = module.tools(context, rc);
    final egg = store.nextEgg;
    return WoodShelf(
      bottomInset: bottom,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (tools != null) ...[tools, const SizedBox(height: 10)],
          Row(
            children: [
              Text(
                l.friendsHere(here.length, HouseStore.maxFriendsPerRoom),
                maxLines: 1,
                style: const TextStyle(color: House.woodText, fontWeight: FontWeight.w800, fontSize: 13),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: AlignmentDirectional.centerEnd,
                  child: Text(
                    l.shelfTapHint,
                    maxLines: 1,
                    style: const TextStyle(color: House.woodText, fontWeight: FontWeight.w700, fontSize: 13),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 64,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                for (final f in store.friends)
                  Padding(
                    padding: const EdgeInsetsDirectional.only(end: 10),
                    child: FriendCoin(
                      friend: f,
                      here: f.room == house.active,
                      label: f.room == house.active ? l.friendHereLabel(f.name) : l.friendElsewhereLabel(f.name),
                      onTap: () => _coinTap(f),
                    ),
                  ),
                if (egg != null)
                  EggCoin(stars: egg.stars, ready: store.eggReady, label: l.eggCoinLabel(egg.stars), onTap: () => goTo(Room.garden)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _coinTap(Friend f) {
    _app.audio.play('ui.tap');
    _app.audio.haptic('selection');
    if (f.room == house.active) {
      unawaited(openFriend(f.id));
      return;
    }
    if (!house.moveFriend(f.id, house.active)) {
      toast(_l.roomFull);
      return;
    }
    setState(() {});
  }
}

/// First launch: a fluff seed in the garden; tap it to hatch Mofu.
class _FirstRun extends StatefulWidget {
  const _FirstRun({required this.onHatch});
  final Future<void> Function() onHatch;

  @override
  State<_FirstRun> createState() => _FirstRunState();
}

class _FirstRunState extends State<_FirstRun> with SingleTickerProviderStateMixin {
  late final AnimationController _wobble = AnimationController(vsync: this, duration: const Duration(milliseconds: 1400))..repeat();
  bool _hatching = false;

  @override
  void dispose() {
    _wobble.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Container(
      color: House.paper.withValues(alpha: 0.94),
      child: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(l.firstRunTapSeed, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900)),
            const SizedBox(height: 32),
            Semantics(
              button: true,
              label: l.firstRunTapSeed,
              child: GestureDetector(
                onTap: _hatching
                    ? null
                    : () async {
                        setState(() => _hatching = true);
                        await widget.onHatch();
                      },
                child: AnimatedBuilder(
                  animation: _wobble,
                  builder: (context, child) {
                    final t = _wobble.value;
                    final a = t < 0.3 ? 0.12 * (1 - (t / 0.3 - 0.5).abs() * 2) * (t < 0.15 ? 1 : -1) : 0.0;
                    return Transform.rotate(angle: _hatching ? 0 : a, child: child);
                  },
                  child: AnimatedScale(
                    scale: _hatching ? 1.3 : 1,
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.elasticOut,
                    child: CustomPaint(size: const Size(150, 150), painter: _SeedPainter()),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SeedPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final r = size.width * 0.34;
    canvas.drawOval(
      Rect.fromCenter(center: c + Offset(0, r * 1.05), width: r * 1.8, height: r * 0.3),
      Paint()
        ..color = const Color(0x333A2A2E)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );
    for (var i = 0; i < 90; i++) {
      final a = i / 90 * 6.283;
      final p = c + Offset(r * 1.02 * math.cos(a), r * 1.02 * math.sin(a));
      canvas.drawLine(
        c + Offset(r * 0.8 * math.cos(a), r * 0.8 * math.sin(a)),
        p,
        Paint()
          ..color = const Color(0xFFFFE3D6)
          ..strokeWidth = 4
          ..strokeCap = StrokeCap.round,
      );
    }
    canvas.drawCircle(
      c,
      r * 0.86,
      Paint()
        ..shader = const RadialGradient(
          center: Alignment(-0.3, -0.35),
          colors: [Color(0xFFFFF4EC), Color(0xFFFFCDB8)],
        ).createShader(Rect.fromCircle(center: c, radius: r)),
    );
  }

  @override
  bool shouldRepaint(_SeedPainter oldDelegate) => false;
}
