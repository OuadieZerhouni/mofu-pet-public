/// Snack Catch: drag your friend left and right to catch the falling snacks
/// and dodge the bees. Full-screen route.
///
/// The catcher is the chosen friend itself, the real creature with its real
/// art and accessories; it eats what it catches and shakes its head at bees.
library;

import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../audio/audio_engine.dart';
import '../../creatures/creature.dart';
import '../../games/snack_catch.dart';
import '../../l10n/app_localizations.dart';
import '../../model/house_store.dart';
import '../../world/creature_factory.dart';
import '../../world/overlays.dart';
import '../house/snack_icons.dart';
import '../theme.dart';
import 'game_kit.dart';

/// Opens Snack Catch with [friend] as the catcher; completes when the player
/// leaves it.
Future<void> playSnackCatch(BuildContext context, {required HouseStore store, required Friend friend}) {
  return Navigator.of(context).push<void>(
    MaterialPageRoute<void>(fullscreenDialog: true, builder: (_) => SnackCatchScreen(store: store, friend: friend)),
  );
}

/// The sound a friend makes eating a snack.
String munchSoundFor(Species s) => switch (s) {
      Species.oink => 'oink.munch1',
      Species.wuff => 'wuff.chomp',
      Species.mofu => 'mofu.chew',
      Species.boop => 'boop.pop',
    };

/// How far left and right [c] can actually go in an area [width] wide: asks
/// the creature itself (every species keeps its ears inside the walls in its
/// own way), then puts it back in the middle. Returns x in pixels.
@visibleForTesting
(double, double) measureCatcherReach(Creature c, double width) {
  final y = c.position.dy;
  c.position = Offset(-width * 3, y);
  c.update(1 / 60);
  final lo = c.position.dx;
  c.position = Offset(width * 4, y);
  c.update(1 / 60);
  final hi = c.position.dx;
  c.position = Offset(width / 2, y);
  c.update(1 / 60);
  if (!lo.isFinite || !hi.isFinite || hi - lo < width * 0.3) return (width * 0.15, width * 0.85);
  return (math.max(0, lo), math.min(width, hi));
}

class SnackCatchScreen extends StatefulWidget {
  const SnackCatchScreen({super.key, required this.store, required this.friend, this.seed});
  final HouseStore store;
  final Friend friend;

  /// Fixed seed (tests); null = a different round every time.
  final int? seed;

  @override
  State<SnackCatchScreen> createState() => _SnackCatchScreenState();
}

class _SnackCatchScreenState extends State<SnackCatchScreen> with WidgetsBindingObserver, SingleTickerProviderStateMixin, GameLoop {
  late final Creature _c = makeCreature(widget.friend)
    ..reduceMotion = _reduce
    ..pinned = true;
  late final CreatureArt _art = artFor(widget.friend.species);
  late final CreatureLook _look = CreatureLook(variant: widget.friend.variant, accessories: [
    for (final slot in const ['head', 'face', 'neck'])
      if (widget.friend.wear[slot] != null) widget.friend.wear[slot]!,
  ]);
  late final List<String> _menu = snacksFor(widget.friend.species);
  final math.Random _sfxRng = math.Random();

  final FloatController _floats = FloatController();
  final ValueNotifier<int> _score = ValueNotifier<int>(0);
  final ValueNotifier<int> _secs = ValueNotifier<int>(45);
  final ValueNotifier<bool> _dragged = ValueNotifier<bool>(false);

  late SnackCatchGame _game;
  int _round = 0;
  double _targetX = 0.5;
  double _flash = 0;
  Size _size = Size.zero;
  double _floorY = 0;

  int _stars = 0;
  bool _newBest = false;

  bool get _reduce => widget.store.reduceMotion;

  @override
  void initState() {
    super.initState();
    initLoop();
    _game = _newGame();
    beginCountdown();
  }

  @override
  void dispose() {
    disposeLoop();
    _floats.dispose();
    _score.dispose();
    _secs.dispose();
    _dragged.dispose();
    super.dispose();
  }

  SnackCatchGame _newGame() {
    final seed = widget.seed != null ? widget.seed! + _round : math.Random().nextInt(1 << 30);
    return SnackCatchGame(snacks: _menu, seed: seed);
  }

  void _again() {
    _round++;
    final old = _game;
    _game = _newGame();
    _syncGeometry(old);
    _game.catcherX = 0.5;
    _targetX = 0.5;
    _floats.clear();
    _flash = 0;
    _score.value = 0;
    _secs.value = _game.duration.ceil();
    beginCountdown();
  }

  // ── geometry ──────────────────────────────────────────────────────────
  void _layout(Size size) {
    if (size == _size) return;
    _size = size;
    _floorY = size.height * 0.84;
    _c.layout(Rect.fromLTWH(0, 0, size.width, size.height), floorY: _floorY);
    _syncGeometry(null);
  }

  /// Teaches the rules where the catcher can go and where its mouth is.
  void _syncGeometry(SnackCatchGame? from) {
    if (_size.isEmpty) return;
    final w = _size.width, h = _size.height;
    final (lo, hi) = from == null ? measureCatcherReach(_c, w) : (from.minX * w, from.maxX * w);
    _game
      ..minX = lo / w
      ..maxX = hi / w
      ..catchRadius = (_c.radius * 1.15 / w).clamp(0.11, 0.22).toDouble()
      ..catchY = (_c.mouth.dy / h).clamp(0.5, 0.95).toDouble();
    _game.catcherX = _targetX;
  }

  // ── the round ─────────────────────────────────────────────────────────
  void _followFinger(double dt) {
    final k = 1 - math.exp(-dt * 22);
    _game.catcherX = _game.catcherX + (_targetX - _game.catcherX) * k;
    if (_size.isEmpty) return;
    _c.position = Offset(_game.catcherX * _size.width, _c.position.dy);
    _c.update(dt);
    _c.drainEvents(); // the screen plays its own sounds
  }

  @override
  void onCountdownTick(double dt) => _followFinger(dt);

  @override
  void onGo() {
    AudioEngine.instance.play('ui.pop');
    AudioEngine.instance.haptic('medium');
  }

  @override
  void onPlayTick(double dt) {
    _followFinger(dt);
    _game.update(dt);
    _react(_game.drainEvents());
    if (_flash > 0) _flash = math.max(0, _flash - dt * 2.5);
    _score.value = _game.score;
    _secs.value = _game.timeLeft.ceil();
    if (_game.finished) _finish();
  }

  void _react(List<SnackCatchEvent> events) {
    final w = _size.width, h = _size.height;
    for (final e in events) {
      final at = Offset(e.x * w, e.y * h - 30);
      switch (e.type) {
        case SnackEventType.caught:
          _c.eat(favorite: false);
          AudioEngine.instance.play(munchSoundFor(widget.friend.species), pitch: 0.94 + _sfxRng.nextDouble() * 0.14);
          AudioEngine.instance.haptic('light');
          _floats.add(at, '+${e.points}', House.rose);
        case SnackEventType.golden:
          _c.eat(favorite: true);
          AudioEngine.instance.play(munchSoundFor(widget.friend.species), pitch: 1.08);
          AudioEngine.instance.play('ui.sparkle', gain: 0.7);
          AudioEngine.instance.haptic('medium');
          _floats.add(at, '+${e.points}', House.starEdge, size: 34);
        case SnackEventType.stung:
          _c.refuseFull();
          AudioEngine.instance.play('mofu.nope');
          AudioEngine.instance.haptic('medium');
          _floats.add(at, e.points == 0 ? '!' : '−${e.points.abs()}', House.lilac, size: 30);
          if (!_reduce) _flash = 1;
        case SnackEventType.missed:
          break;
      }
      _c.drainEvents();
    }
  }

  void _finish() {
    final store = widget.store;
    final prev = store.bestSnackCatch;
    _stars = store.finishGame(StarSource.snackCatch, _game.score);
    _newBest = _game.score > prev && _game.score > 0;
    if (_newBest) _c.celebrate();
    _c.drainEvents();
    AudioEngine.instance.play(_newBest ? 'ui.fanfare' : 'ui.sparkle');
    AudioEngine.instance.haptic('success');
    _score.value = _game.score;
    _secs.value = 0;
    endRound();
  }

  void _onPointer(double dx) {
    if (_size.isEmpty || phase == GamePhase.paused || phase == GamePhase.over) return;
    _targetX = (dx / _size.width).clamp(_game.minX, _game.maxX).toDouble();
    if (!_dragged.value) _dragged.value = true;
  }

  void _quit() => Navigator.of(context).pop();

  // ── build ─────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final store = widget.store;
    return PopScope(
      canPop: phase == GamePhase.over,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        if (phase == GamePhase.paused) {
          _quit();
        } else {
          pauseGame();
        }
      },
      child: Scaffold(
        backgroundColor: House.paper,
        body: LayoutBuilder(
          builder: (context, box) {
            final size = Size(box.maxWidth, box.maxHeight);
            _layout(size);
            final iconSize = (size.width * 0.12).clamp(40.0, 60.0).toDouble();
            return Stack(
              children: [
                Positioned.fill(
                  child: Semantics(
                    container: true,
                    label: l.gameCatcherHint,
                    child: Listener(
                      behavior: HitTestBehavior.opaque,
                      onPointerDown: (e) => _onPointer(e.localPosition.dx),
                      onPointerMove: (e) => _onPointer(e.localPosition.dx),
                      child: RepaintBoundary(child: CustomPaint(painter: _CatchPainter(this, size))),
                    ),
                  ),
                ),
                // Falling snacks: real hand-drawn icons, kept in step each frame.
                Positioned.fill(
                  child: IgnorePointer(
                    child: ExcludeSemantics(
                      child: ValueListenableBuilder<int>(
                        valueListenable: frame,
                        builder: (context, _, _) => Stack(
                          clipBehavior: Clip.none,
                          children: [
                            for (final it in _game.items)
                              if (it.kind != FallKind.bee)
                                Positioned(
                                  key: ValueKey(it.serial),
                                  left: it.x * size.width - iconSize,
                                  top: it.y * size.height - iconSize,
                                  width: iconSize * 2,
                                  height: iconSize * 2,
                                  child: _FallingSnack(item: it, size: iconSize),
                                ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned.fill(child: FloatLayer(controller: _floats, reduceMotion: _reduce)),
                SafeArea(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                        child: Row(
                          children: [
                            PauseButton(label: l.gamePause, onPressed: pauseGame),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Align(
                                alignment: AlignmentDirectional.centerStart,
                                child: ValueListenableBuilder<int>(
                                  valueListenable: _score,
                                  builder: (context, v, _) => StatChip(text: l.gameScore(v), emphasis: true),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            ValueListenableBuilder<int>(
                              valueListenable: _secs,
                              builder: (context, v, _) => StatChip(text: l.gameTime(v)),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                        child: ValueListenableBuilder<int>(
                          valueListenable: frame,
                          builder: (context, _, _) => TimeBar(value: _game.timeLeft / _game.duration),
                        ),
                      ),
                    ],
                  ),
                ),
                if (phase == GamePhase.playing)
                  Positioned(
                    left: 24,
                    right: 24,
                    bottom: 0,
                    child: SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: IgnorePointer(
                          child: ValueListenableBuilder<bool>(
                            valueListenable: _dragged,
                            builder: (context, dragged, _) => AnimatedOpacity(
                              duration: const Duration(milliseconds: 300),
                              opacity: dragged ? 0 : 1,
                              child: Text(
                                l.gameCatcherHint,
                                textAlign: TextAlign.center,
                                style: (Theme.of(context).textTheme.titleMedium ?? const TextStyle())
                                    .copyWith(color: House.woodText, fontWeight: FontWeight.w800),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                if (phase == GamePhase.countdown)
                  Positioned.fill(
                    child: CountdownBanner(
                      title: l.gameSnackCatch,
                      showGo: showGo,
                      hint: l.gameCatcherHint,
                      best: store.bestSnackCatch,
                      reduceMotion: _reduce,
                    ),
                  ),
                if (phase == GamePhase.paused) Positioned.fill(child: PauseOverlay(onResume: resumeGame, onQuit: _quit)),
                if (phase == GamePhase.over)
                  Positioned.fill(
                    child: ResultOverlay(
                      score: _game.score,
                      best: store.bestSnackCatch,
                      newBest: _newBest,
                      stars: _stars,
                      starsCap: HouseStore.dailyCap[StarSource.snackCatch]!,
                      onAgain: _again,
                      onDone: _quit,
                      leading: Text(
                        widget.friend.name,
                        style: (Theme.of(context).textTheme.titleMedium ?? const TextStyle()).copyWith(color: House.inkSoft, fontWeight: FontWeight.w800),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

/// One falling snack: its icon, swaying a little; golden ones glow.
class _FallingSnack extends StatelessWidget {
  const _FallingSnack({required this.item, required this.size});
  final FallItem item;
  final double size;

  @override
  Widget build(BuildContext context) {
    final golden = item.kind == FallKind.golden;
    final sway = math.sin(item.y * 9 + item.serial) * 0.18;
    return Center(
      child: Transform.rotate(
        angle: sway,
        child: SizedBox.square(
          dimension: size,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              if (golden)
                Positioned.fill(
                  child: Transform.scale(
                    scale: 1.45,
                    child: DecoratedBox(
                      decoration: BoxDecoration(shape: BoxShape.circle, color: House.star.withValues(alpha: 0.42)),
                    ),
                  ),
                ),
              RepaintBoundary(child: SnackIcon(item.snack, size: size)),
            ],
          ),
        ),
      ),
    );
  }
}

class _CatchPainter extends CustomPainter {
  _CatchPainter(this.s, this.size) : super(repaint: s.frame);
  final _SnackCatchScreenState s;
  final Size size;

  static final Paint _cloud = Paint()..color = Colors.white.withValues(alpha: 0.7);
  static final Paint _floorTop = Paint()..color = House.woodEdge;
  static final Paint _floor = Paint()..color = House.wood;
  static final Paint _floorLine = Paint()
    ..color = House.woodDeep.withValues(alpha: 0.5)
    ..strokeWidth = 2;
  static final Paint _flashPaint = Paint();
  static final Paint _star = Paint()..color = House.star;
  static final Paint _yellow = Paint()..color = const Color(0xFFFFD34D);
  static final Paint _stripe = Paint()..color = House.ink;
  static final Paint _wing = Paint()..color = const Color(0xE6FFFFFF);
  static final Paint _wingEdge = Paint()
    ..color = const Color(0xFF8FB8D6)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1.6;
  static final Paint _blush = Paint()..color = const Color(0x99FF8FA8);
  static final Paint _line = Paint()
    ..color = House.ink
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1.8
    ..strokeCap = StrokeCap.round;
  static final Paint _fill = Paint()..color = House.ink;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    // Soft paper clouds.
    for (final (cx, cy, r) in const [(0.2, 0.22, 0.07), (0.72, 0.3, 0.09), (0.45, 0.5, 0.06)]) {
      final c = Offset(w * cx, h * cy);
      canvas.drawOval(Rect.fromCenter(center: c, width: w * r * 3, height: w * r * 1.1), _cloud);
      canvas.drawOval(Rect.fromCenter(center: c.translate(-w * r * 0.5, -w * r * 0.4), width: w * r * 1.5, height: w * r * 1.1), _cloud);
      canvas.drawOval(Rect.fromCenter(center: c.translate(w * r * 0.4, -w * r * 0.5), width: w * r * 1.7, height: w * r * 1.2), _cloud);
    }
    // The wooden floor the catcher stands on.
    final fy = s._floorY;
    canvas.drawRect(Rect.fromLTRB(0, fy - 2, w, h), _floor);
    canvas.drawRect(Rect.fromLTRB(0, fy - 2, w, fy + 8), _floorTop);
    for (var x = w * 0.12; x < w; x += w * 0.26) {
      canvas.drawLine(Offset(x, fy + 14), Offset(x, h), _floorLine);
    }

    // The catcher: the real creature, its real art and accessories.
    final c = s._c;
    s._art.paint(canvas, c, s._look);
    for (final acc in s._look.accessories) {
      if (c.species == Species.mofu && slotOf(acc) == AccessorySlot.head) continue;
      paintAccessoryOn(canvas, c, acc);
    }

    final g = s._game;
    final t = g.elapsed;
    if (g.stunned) _stunStars(canvas, c, t);

    final bee = (w * 0.12).clamp(40.0, 60.0).toDouble();
    for (final it in g.items) {
      if (it.kind == FallKind.bee) _bee(canvas, Offset(it.x * w, it.y * h), bee, t + it.serial * 0.37);
    }

    if (s._flash > 0) {
      canvas.drawRect(Offset.zero & size, _flashPaint..color = House.rose.withValues(alpha: 0.16 * s._flash));
    }
  }

  void _stunStars(Canvas canvas, Creature c, double t) {
    final top = c.bounds.top;
    final centre = Offset(c.position.dx, top + c.radius * 0.1);
    final reduce = s._reduce;
    for (var k = 0; k < 3; k++) {
      final a = (reduce ? 0 : t * 6) + k * 2 * math.pi / 3;
      final p = centre + Offset(math.cos(a) * c.radius * 0.55, math.sin(a) * c.radius * 0.16);
      canvas.drawCircle(p, 6, _star);
    }
  }

  /// A round, chubby bee, facing us.
  void _bee(Canvas canvas, Offset at, double size, double t) {
    final u = size / 50;
    canvas.save();
    canvas.translate(at.dx, at.dy);
    canvas.rotate(math.sin(t * 5) * 0.12);
    canvas.scale(u);
    // Wings flap.
    final flap = s._reduce ? 1.0 : 0.75 + 0.25 * math.sin(t * 40);
    for (final side in const [-1.0, 1.0]) {
      canvas.save();
      canvas.translate(side * 15, -17);
      canvas.rotate(side * 0.5);
      canvas.scale(1, flap);
      final wing = Rect.fromCenter(center: Offset.zero, width: 17, height: 24);
      canvas.drawOval(wing, _wing);
      canvas.drawOval(wing, _wingEdge);
      canvas.restore();
    }
    // Body with stripes.
    final body = Rect.fromCenter(center: Offset.zero, width: 38, height: 42);
    canvas.drawOval(body, _yellow);
    canvas.save();
    canvas.clipPath(Path()..addOval(body));
    canvas.drawRect(const Rect.fromLTWH(-24, 7, 48, 6), _stripe);
    canvas.drawRect(const Rect.fromLTWH(-24, 17, 48, 6), _stripe);
    canvas.restore();
    canvas.drawOval(body, _line);
    // Stinger and antennae.
    canvas.drawPath(
      Path()
        ..moveTo(-3.5, 20)
        ..lineTo(3.5, 20)
        ..lineTo(0, 27)
        ..close(),
      _fill,
    );
    canvas.drawLine(const Offset(-6, -19), const Offset(-10, -27), _line);
    canvas.drawLine(const Offset(6, -19), const Offset(10, -27), _line);
    canvas.drawCircle(const Offset(-10, -27), 2.4, _fill);
    canvas.drawCircle(const Offset(10, -27), 2.4, _fill);
    // Face: eyes, blush, a small cross smile (a grumpy-cute bee).
    canvas.drawCircle(const Offset(-7, -5), 2.6, _fill);
    canvas.drawCircle(const Offset(7, -5), 2.6, _fill);
    canvas.drawCircle(const Offset(-12, 1), 3, _blush);
    canvas.drawCircle(const Offset(12, 1), 3, _blush);
    canvas.drawArc(Rect.fromCenter(center: const Offset(0, 1), width: 8, height: 6), 0.2, math.pi - 0.4, false, _line);
    canvas.restore();
  }

  @override
  bool shouldRepaint(_CatchPainter old) => old.s != s || old.size != size;
}
