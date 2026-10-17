/// Boop Rush: nine holes, critters pop up, boop them. Full-screen route.
///
/// The critters are the household's real Boops (the same `BoopCreature` and
/// `BoopArt` the house uses): a boop is a real nose-boop, so they squash,
/// grin and spit hearts exactly as they do at home.
library;

import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../audio/audio_engine.dart';
import '../../creatures/boop/boop_art.dart';
import '../../creatures/boop/boop_creature.dart';
import '../../creatures/creature.dart';
import '../../games/boop_rush.dart';
import '../../l10n/app_localizations.dart';
import '../../model/house_store.dart';
import '../theme.dart';
import 'game_kit.dart';

/// Opens Boop Rush full screen; completes when the player leaves it.
Future<void> playBoopRush(BuildContext context, {required HouseStore store}) {
  return Navigator.of(context).push<void>(
    MaterialPageRoute<void>(fullscreenDialog: true, builder: (_) => BoopRushScreen(store: store)),
  );
}

/// The critter looks used in a round: the household's hatched Boops (up to
/// six), topped up with Mochi, Pip and Bao so the meadow always has three.
List<String> rushVariantsFor(HouseStore store) {
  final out = <String>[];
  for (final f in store.friends) {
    if (f.species == Species.boop && !out.contains(f.variant) && out.length < 6) out.add(f.variant);
  }
  for (final v in const ['mochi', 'pip', 'bao']) {
    if (out.length >= 3) break;
    if (!out.contains(v)) out.add(v);
  }
  return out;
}

class BoopRushScreen extends StatefulWidget {
  const BoopRushScreen({super.key, required this.store, this.seed});
  final HouseStore store;

  /// Fixed seed (tests); null = a different round every time.
  final int? seed;

  @override
  State<BoopRushScreen> createState() => _BoopRushScreenState();
}

/// What one hole is showing right now.
class _CellView {
  BoopCreature? creature;
  CreatureLook look = const CreatureLook(variant: 'mochi');
  RushKind kind = RushKind.awake;
  int serial = -1;
  double bornAt = 0;
  double diesAt = 0;

  /// 0 = hidden in the hole, 1 = fully out (a little over while popping).
  double rise = 0;

  /// Seconds since the critter left the game (booped or timed out); -1 = still in play.
  double leave = -1;
  double riseAtLeave = 0;
}

class _BoopRushScreenState extends State<BoopRushScreen> with WidgetsBindingObserver, SingleTickerProviderStateMixin, GameLoop {
  static const _art = BoopArt();
  static const _leaveSeconds = 0.2;
  static const _popSeconds = 0.16;

  late final List<String> _variants = rushVariantsFor(widget.store);
  late final Map<String, CreatureLook> _looks = {for (final v in _variants) v: CreatureLook(variant: v)};
  final Map<int, BoopCreature> _pool = {};
  final List<_CellView> _views = List.generate(BoopRushGame.cells, (_) => _CellView());
  final FloatController _floats = FloatController();
  final ValueNotifier<int> _score = ValueNotifier<int>(0);
  final ValueNotifier<int> _secs = ValueNotifier<int>(30);
  final ValueNotifier<int> _streak = ValueNotifier<int>(0);

  late BoopRushGame _game;

  /// The round in progress (store screenshots tap real boops through it).
  @visibleForTesting
  BoopRushGame get game => _game;
  int _round = 0;
  double _shake = 0;

  // Board geometry, rebuilt when the board changes size.
  double _side = 0;
  double _cs = 0;
  final List<Path> _clip = List.generate(BoopRushGame.cells, (_) => Path());
  final List<Rect> _holes = List.filled(BoopRushGame.cells, Rect.zero);
  final List<Rect> _mounds = List.filled(BoopRushGame.cells, Rect.zero);

  // Result.
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
    _streak.dispose();
    super.dispose();
  }

  BoopRushGame _newGame() {
    final seed = widget.seed != null ? widget.seed! + _round : math.Random().nextInt(1 << 30);
    return BoopRushGame(seed: seed, critterCount: _variants.length);
  }

  void _again() {
    _round++;
    _game = _newGame();
    for (final v in _views) {
      v.creature = null;
      v.serial = -1;
      v.rise = 0;
      v.leave = -1;
    }
    _floats.clear();
    _shake = 0;
    _score.value = 0;
    _streak.value = 0;
    _secs.value = _game.duration.ceil();
    beginCountdown();
  }

  // ── geometry ──────────────────────────────────────────────────────────
  void _layout(double side) {
    if (side == _side) return;
    _side = side;
    final cs = _cs = side / 3;
    for (var i = 0; i < BoopRushGame.cells; i++) {
      final ox = (i % 3) * cs, oy = (i ~/ 3) * cs;
      final centre = Offset(ox + cs / 2, oy + cs * _holeLine);
      final hole = _holes[i] = Rect.fromCenter(center: centre, width: cs * 0.76, height: cs * 0.24);
      _mounds[i] = Rect.fromCenter(center: centre.translate(0, cs * 0.015), width: cs * 0.9, height: cs * 0.32);
      _clip[i] = Path()
        ..addRect(Rect.fromLTRB(ox - cs * 0.5, oy - cs * 0.7, ox + cs * 1.5, centre.dy))
        ..addOval(hole);
    }
    for (final e in _pool.entries) {
      _placeCreature(e.value, e.key ~/ 16);
    }
  }

  static const _holeLine = 0.72;

  void _placeCreature(BoopCreature c, int cell) {
    final cs = _cs;
    final ox = (cell % 3) * cs, oy = (cell ~/ 3) * cs;
    // A wide area so the walls never nudge a critter off its hole.
    c.layout(Rect.fromLTWH(ox - cs, oy, cs * 3, cs), floorY: oy + cs * _holeLine, sizeScale: (cs * 0.25) / (0.13 * cs * 3));
    c.position = Offset(ox + cs / 2, c.position.dy);
  }

  BoopCreature _creatureFor(int cell, int critter) {
    return _pool.putIfAbsent(cell * 16 + critter, () {
      final variant = _variants[critter % _variants.length];
      final c = BoopCreature(friendId: 'rush$cell', seed: cell * 31 + critter + 1, variant: variant)
        ..reduceMotion = _reduce
        ..pinned = true;
      if (_cs > 0) _placeCreature(c, cell);
      return c;
    });
  }

  Offset _cellCentre(int cell) {
    final cs = _cs;
    return Offset((cell % 3) * cs + cs / 2, (cell ~/ 3) * cs + cs * 0.4);
  }

  // ── the round ─────────────────────────────────────────────────────────
  @override
  void onCountdownTick(double dt) {
    // Nothing is out yet; the holes just wait.
  }

  @override
  void onGo() {
    AudioEngine.instance.play('boop.whoosh');
    AudioEngine.instance.haptic('medium');
  }

  @override
  void onPlayTick(double dt) {
    _game.update(dt);
    _react(_game.drainEvents());
    final reduce = _reduce;
    final now = _game.elapsed;
    for (var i = 0; i < BoopRushGame.cells; i++) {
      final v = _views[i];
      final c = v.creature;
      if (c == null) continue;
      final p = _game.slots[i];
      if (p != null && p.serial == v.serial) {
        final up = ((now - v.bornAt) / _popSeconds).clamp(0.0, 1.0);
        final down = ((v.diesAt - now) / _popSeconds).clamp(0.0, 1.0);
        v.rise = (reduce ? up : Curves.easeOutBack.transform(up)) * Curves.easeIn.transform(down);
        v.leave = -1;
      } else {
        if (v.leave < 0) {
          v.leave = 0;
          v.riseAtLeave = v.rise;
        }
        v.leave += dt;
        v.rise = v.riseAtLeave * (1 - v.leave / _leaveSeconds).clamp(0.0, 1.0);
        if (v.leave >= _leaveSeconds) {
          v.creature = null;
          continue;
        }
      }
      c.update(dt);
      c.drainEvents(); // the screen plays its own, pitched sounds
    }
    if (_shake > 0) _shake = math.max(0, _shake - dt * 3);
    _score.value = _game.score;
    _streak.value = _game.streak;
    _secs.value = _game.timeLeft.ceil();
    if (_game.finished) _finish();
  }

  void _react(List<RushEvent> events) {
    for (final e in events) {
      switch (e.type) {
        case RushEventType.spawn:
          final p = _game.slots[e.cell];
          if (p == null) break; // came and went inside one long frame
          final v = _views[e.cell];
          final c = _creatureFor(e.cell, p.critter);
          if (p.kind == RushKind.sleepy) {
            c.sleep();
          } else {
            c.wake();
          }
          v
            ..creature = c
            ..look = _looks[_variants[p.critter % _variants.length]]!
            ..kind = p.kind
            ..serial = p.serial
            ..bornAt = p.bornAt
            ..diesAt = p.diesAt
            ..rise = 0
            ..leave = -1;
        case RushEventType.boop:
          AudioEngine.instance.play('boop.boop_${math.min(13, 2 + e.streak).toString().padLeft(2, '0')}');
          AudioEngine.instance.haptic('light');
          _floats.add(_cellCentre(e.cell), '+${e.points}', House.rose);
          _squeakCreature(e.cell, nose: true);
        case RushEventType.golden:
          AudioEngine.instance.play('boop.chime');
          AudioEngine.instance.play('ui.sparkle', gain: 0.7);
          AudioEngine.instance.haptic('medium');
          _floats.add(_cellCentre(e.cell), '+${e.points}', House.starEdge, size: 34);
          _squeakCreature(e.cell, nose: true);
        case RushEventType.sleepy:
          AudioEngine.instance.play('boop.oops');
          AudioEngine.instance.haptic('medium');
          _floats.add(_cellCentre(e.cell), e.points == 0 ? 'z' : '−${e.points.abs()}', House.lilac);
          if (!_reduce) _shake = 1;
          _squeakCreature(e.cell, nose: false);
        case RushEventType.miss:
        case RushEventType.expire:
        case RushEventType.end:
          break;
      }
    }
  }

  /// The real boop (or a wake-up poke) on the critter that was in [cell].
  void _squeakCreature(int cell, {required bool nose}) {
    final c = _views[cell].creature;
    if (c == null) return;
    final at = nose ? c.nosePos : c.position;
    c.pointerDown(1, at);
    c.pointerUp(1, at);
    c.drainEvents();
  }

  void _finish() {
    final store = widget.store;
    final prev = store.bestBoopRush;
    _stars = store.finishGame(StarSource.boopRush, _game.score);
    _newBest = _game.score > prev && _game.score > 0;
    AudioEngine.instance.play(_newBest ? 'boop.fanfare' : 'boop.chime');
    AudioEngine.instance.haptic('success');
    _score.value = _game.score;
    _secs.value = 0;
    endRound();
  }

  void _onPointerDown(PointerDownEvent e) {
    if (phase != GamePhase.playing || _cs <= 0) return;
    final cell = (e.localPosition.dy / _cs).floor().clamp(0, 2) * 3 + (e.localPosition.dx / _cs).floor().clamp(0, 2);
    _game.tap(cell);
    _react(_game.drainEvents());
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
        body: Stack(
          children: [
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
                  SizedBox(
                    height: 40,
                    child: Center(
                      child: ValueListenableBuilder<int>(
                        valueListenable: _streak,
                        builder: (context, v, _) => AnimatedOpacity(
                          duration: const Duration(milliseconds: 150),
                          opacity: v >= 3 && phase == GamePhase.playing ? 1 : 0,
                          child: ExcludeSemantics(
                            child: Text(
                              '×$v',
                              style: (Theme.of(context).textTheme.titleLarge ?? const TextStyle())
                                  .copyWith(color: House.rose, fontWeight: FontWeight.w900),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, box) {
                        final side = math.min(box.maxWidth - 32, box.maxHeight - 8).clamp(240.0, 480.0).toDouble();
                        _layout(side);
                        return Center(
                          child: Semantics(
                            container: true,
                            label: l.gameBoopHint,
                            child: SizedBox.square(
                              key: const ValueKey('boop-rush-board'),
                              dimension: side,
                              child: Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  Positioned.fill(
                                    child: Listener(
                                      behavior: HitTestBehavior.opaque,
                                      onPointerDown: _onPointerDown,
                                      child: RepaintBoundary(
                                        child: CustomPaint(painter: _BoardPainter(this, side)),
                                      ),
                                    ),
                                  ),
                                  Positioned.fill(child: FloatLayer(controller: _floats, reduceMotion: _reduce)),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            if (phase == GamePhase.countdown)
              Positioned.fill(
                child: CountdownBanner(
                  title: l.gameBoopRush,
                  showGo: showGo,
                  hint: l.gameBoopHint,
                  best: store.bestBoopRush,
                  reduceMotion: _reduce,
                ),
              ),
            if (phase == GamePhase.paused) Positioned.fill(child: PauseOverlay(onResume: resumeGame, onQuit: _quit)),
            if (phase == GamePhase.over)
              Positioned.fill(
                child: ResultOverlay(
                  score: _game.score,
                  best: store.bestBoopRush,
                  newBest: _newBest,
                  stars: _stars,
                  starsCap: HouseStore.dailyCap[StarSource.boopRush]!,
                  onAgain: _again,
                  onDone: _quit,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _BoardPainter extends CustomPainter {
  _BoardPainter(this.s, this.side) : super(repaint: s.frame);
  final _BoopRushScreenState s;
  final double side;

  static final Paint _felt = Paint()..color = const Color(0xFFDDE8C8);
  static final Paint _feltEdge = Paint()
    ..color = const Color(0xFFB7C99A)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 4;
  static final Paint _mound = Paint()..color = House.woodEdge;
  static final Paint _hole = Paint()..color = House.coinShadow;
  static final Paint _holeDeep = Paint()..color = const Color(0xFF4A2D1B);
  static final Paint _rim = Paint()
    ..color = House.woodDeep
    ..style = PaintingStyle.stroke
    ..strokeWidth = 3.5
    ..strokeCap = StrokeCap.round;
  static final Paint _glowOuter = Paint()..color = House.star.withValues(alpha: 0.28);
  static final Paint _glowInner = Paint()..color = House.star.withValues(alpha: 0.38);

  @override
  void paint(Canvas canvas, Size size) {
    final board = RRect.fromRectAndRadius(Offset.zero & size, const Radius.circular(28));
    canvas.drawRRect(board, _felt);
    canvas.drawRRect(board.deflate(2), _feltEdge);

    final shake = s._shake;
    canvas.save();
    if (shake > 0) canvas.translate(math.sin(s._game.elapsed * 70) * 6 * shake, 0);
    final cs = s._cs;
    final now = s._game.elapsed;
    for (var i = 0; i < BoopRushGame.cells; i++) {
      final hole = s._holes[i];
      canvas.drawOval(s._mounds[i], _mound);
      canvas.drawOval(hole, _hole);
      canvas.drawOval(hole.deflate(cs * 0.02).translate(0, -cs * 0.025), _holeDeep);
      final v = s._views[i];
      final c = v.creature;
      if (c != null && v.rise > 0.01) {
        canvas.save();
        canvas.clipPath(s._clip[i]);
        canvas.translate(0, (1 - v.rise) * cs * 0.95);
        if (v.kind == RushKind.golden) {
          final pulse = 1 + 0.06 * math.sin(now * 9);
          final centre = Offset(hole.center.dx, hole.center.dy - cs * 0.3);
          canvas.drawCircle(centre, cs * 0.46 * pulse, _glowOuter);
          canvas.drawCircle(centre, cs * 0.34 * pulse, _glowInner);
        }
        _BoopRushScreenState._art.paint(canvas, c, v.look, shadow: false);
        canvas.restore();
      }
      // The front lip of the hole, over the critter's feet.
      canvas.drawArc(hole, 0.12, math.pi - 0.24, false, _rim);
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(_BoardPainter old) => old.s != s || old.side != side;
}
