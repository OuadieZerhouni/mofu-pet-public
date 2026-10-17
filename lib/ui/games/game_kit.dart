/// Shared building blocks of the two mini-games: the round loop (countdown,
/// play, pause, over), felt cards and buttons in the house's paper-craft
/// style, floating "+1" labels, the result card.
library;

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../../l10n/app_localizations.dart';
import '../theme.dart';

enum GamePhase { countdown, playing, paused, over }

/// Seconds of "Ready?" and of "Go!" before the round starts.
const double kReadySeconds = 0.9;
const double kGoSeconds = 0.6;

/// Longest frame the games simulate in one step (a hitch never teleports).
const double kMaxFrameDt = 0.1;

// ── the round loop ──────────────────────────────────────────────────────────

/// Drives a mini-game screen: one [Ticker], the countdown, pause / resume
/// (also when the app leaves the foreground) and the end of the round.
///
/// Use as `with WidgetsBindingObserver, SingleTickerProviderStateMixin,
/// GameLoop`, call [initLoop] / [disposeLoop] from `initState` / `dispose`,
/// and implement the hooks.
mixin GameLoop<T extends StatefulWidget>
    on State<T>, TickerProvider, WidgetsBindingObserver {
  late final Ticker _ticker = createTicker(_tick);
  Duration? _last;
  GamePhase _resumeTo = GamePhase.playing;
  double _phaseT = 0;

  GamePhase phase = GamePhase.countdown;

  /// True once "Ready?" has turned into "Go!".
  bool showGo = false;

  /// Bumped on every simulated frame: painters repaint from this.
  final ValueNotifier<int> frame = ValueNotifier<int>(0);

  /// The round is running: advance the simulation by [dt] seconds.
  void onPlayTick(double dt);

  /// While "Ready? / Go!" shows (idle animations).
  void onCountdownTick(double dt) {}

  /// "Ready?" just turned into "Go!".
  void onGo() {}

  /// "Go!" is over, the round starts now.
  void onRoundStart() {}

  void initLoop() => WidgetsBinding.instance.addObserver(this);

  void disposeLoop() {
    WidgetsBinding.instance.removeObserver(this);
    _ticker.dispose();
    frame.dispose();
  }

  /// (Re)starts at "Ready?".
  void beginCountdown() {
    phase = GamePhase.countdown;
    showGo = false;
    _phaseT = 0;
    _last = null;
    if (!_ticker.isActive) _ticker.start();
    if (mounted) setState(() {});
  }

  void pauseGame() {
    if (phase != GamePhase.playing && phase != GamePhase.countdown) return;
    _resumeTo = phase;
    phase = GamePhase.paused;
    if (_ticker.isActive) _ticker.stop();
    setState(() {});
  }

  void resumeGame() {
    if (phase != GamePhase.paused) return;
    phase = _resumeTo;
    _last = null;
    if (!_ticker.isActive) _ticker.start();
    setState(() {});
  }

  /// Ends the round; call from [onPlayTick] when the game says it is over.
  void endRound() {
    if (_ticker.isActive) _ticker.stop();
    phase = GamePhase.over;
    if (mounted) setState(() {});
  }

  void _tick(Duration elapsed) {
    final prev = _last;
    final dt = prev == null
        ? 0.0
        : ((elapsed - prev).inMicroseconds / 1e6).clamp(0.0, kMaxFrameDt);
    _last = elapsed;
    switch (phase) {
      case GamePhase.countdown:
        _phaseT += dt;
        onCountdownTick(dt);
        if (!showGo && _phaseT >= kReadySeconds) {
          showGo = true;
          onGo();
          setState(() {});
        } else if (showGo && _phaseT >= kReadySeconds + kGoSeconds) {
          phase = GamePhase.playing;
          onRoundStart();
          setState(() {});
        }
      case GamePhase.playing:
        onPlayTick(dt);
      case GamePhase.paused:
      case GamePhase.over:
        break;
    }
    frame.value++;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // A call, Control Center or the app switcher covers the game: pause and
    // let the player resume on purpose.
    if (state != AppLifecycleState.resumed) pauseGame();
  }
}

// ── felt surfaces ───────────────────────────────────────────────────────────

/// A stitched felt card (rounded, dashed border, hard offset shadow).
class GameCard extends StatelessWidget {
  const GameCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.radius = 24,
    this.color,
  });
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: StitchPainter(radius: radius),
      child: Container(
        padding: padding,
        decoration: BoxDecoration(
          color: color ?? House.tag,
          borderRadius: BorderRadius.circular(radius),
          boxShadow: const [
            BoxShadow(color: House.tagShadow, offset: Offset(0, 4)),
          ],
        ),
        child: child,
      ),
    );
  }
}

class StitchPainter extends CustomPainter {
  const StitchPainter({required this.radius, this.color = House.stitch});
  final double radius;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final rr = RRect.fromRectAndRadius(
      (Offset.zero & size).deflate(5),
      Radius.circular(math.max(0, radius - 5)),
    );
    final path = Path()..addRRect(rr);
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    for (final m in path.computeMetrics()) {
      for (var d = 0.0; d < m.length; d += 9) {
        canvas.drawPath(m.extractPath(d, math.min(d + 5, m.length)), paint);
      }
    }
  }

  @override
  bool shouldRepaint(StitchPainter old) =>
      old.radius != radius || old.color != color;
}

/// Rose pill with white text (primary) or a stitched cream pill (secondary).
/// At least 52 high and 120 wide, so it is always an easy target.
class GameButton extends StatelessWidget {
  const GameButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.primary = true,
    this.expand = true,
  });
  final String label;
  final VoidCallback onPressed;
  final bool primary;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme.titleMedium;
    final style = (text ?? const TextStyle()).copyWith(
      color: primary ? Colors.white : House.ink,
      fontWeight: FontWeight.w800,
      fontSize: 17,
    );
    final button = Semantics(
      button: true,
      label: label,
      excludeSemantics: true,
      onTap: onPressed,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 52, minWidth: 120),
        child: Material(
          color: primary ? House.rose : House.tag,
          shape: StadiumBorder(
            side: primary
                ? BorderSide.none
                : const BorderSide(color: House.stitch, width: 2),
          ),
          child: InkWell(
            customBorder: const StadiumBorder(),
            onTap: onPressed,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              child: Center(
                widthFactor: 1,
                child: Text(label, textAlign: TextAlign.center, style: style),
              ),
            ),
          ),
        ),
      ),
    );
    return expand ? SizedBox(width: double.infinity, child: button) : button;
  }
}

/// The round pause button (two felt bars), 48x48.
class PauseButton extends StatelessWidget {
  const PauseButton({super.key, required this.label, required this.onPressed});
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      excludeSemantics: true,
      onTap: onPressed,
      child: SizedBox.square(
        dimension: 48,
        child: Material(
          color: House.tag,
          shape: const CircleBorder(
            side: BorderSide(color: House.stitch, width: 2),
          ),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: onPressed,
            child: const Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [_Bar(), SizedBox(width: 4), _Bar()],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Bar extends StatelessWidget {
  const _Bar();
  @override
  Widget build(BuildContext context) => const DecoratedBox(
    decoration: BoxDecoration(
      color: House.ink,
      borderRadius: BorderRadius.all(Radius.circular(3)),
    ),
    child: SizedBox(width: 6, height: 18),
  );
}

/// A small felt chip: label on top of a big number-ish value.
class StatChip extends StatelessWidget {
  const StatChip({super.key, required this.text, this.emphasis = false});
  final String text;
  final bool emphasis;

  @override
  Widget build(BuildContext context) {
    final base = Theme.of(context).textTheme.titleMedium ?? const TextStyle();
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 48),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: emphasis ? House.rose : House.tag,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: emphasis ? House.roseDeep : House.stitch,
            width: 2,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Center(
            widthFactor: 1,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                text,
                maxLines: 1,
                style: base.copyWith(
                  color: emphasis ? Colors.white : House.ink,
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// A thin felt bar showing how much of the round is left (1 = full).
class TimeBar extends StatelessWidget {
  const TimeBar({super.key, required this.value});
  final double value;

  @override
  Widget build(BuildContext context) {
    final v = value.clamp(0.0, 1.0);
    return ExcludeSemantics(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: SizedBox(
          height: 10,
          child: Stack(
            fit: StackFit.expand,
            children: [
              const ColoredBox(color: House.tagShadow),
              FractionallySizedBox(
                alignment: AlignmentDirectional.centerStart,
                widthFactor: v,
                child: ColoredBox(color: v < 0.2 ? House.rose : House.leaf),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A five-point felt star, for the "stars earned" line.
class StarGlyph extends StatelessWidget {
  const StarGlyph({super.key, this.size = 28});
  final double size;

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: CustomPaint(size: Size.square(size), painter: const _StarPainter()),
  );
}

class _StarPainter extends CustomPainter {
  const _StarPainter();
  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final outer = size.width / 2 - 1.5;
    final inner = outer * 0.5;
    final path = Path();
    for (var i = 0; i < 10; i++) {
      final r = i.isEven ? outer : inner;
      final a = -math.pi / 2 + i * math.pi / 5;
      final p = c + Offset(math.cos(a), math.sin(a)) * r;
      i == 0 ? path.moveTo(p.dx, p.dy) : path.lineTo(p.dx, p.dy);
    }
    path.close();
    canvas.drawPath(path, Paint()..color = House.star);
    canvas.drawPath(
      path,
      Paint()
        ..color = House.starEdge
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(_StarPainter old) => false;
}

// ── overlays ────────────────────────────────────────────────────────────────

/// "Ready?" then "Go!", big in the middle of the screen.
class CountdownBanner extends StatelessWidget {
  const CountdownBanner({
    super.key,
    required this.title,
    required this.showGo,
    required this.hint,
    this.best = 0,
    required this.reduceMotion,
  });
  final String title;
  final bool showGo;
  final String hint;
  final int best;
  final bool reduceMotion;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context).textTheme;
    final word = showGo ? l.gameGo : l.gameReady;
    return IgnorePointer(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: GameCard(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: (theme.titleLarge ?? const TextStyle()).copyWith(
                    color: House.inkSoft,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                TweenAnimationBuilder<double>(
                  key: ValueKey(word),
                  tween: Tween(begin: reduceMotion ? 1 : 0.6, end: 1),
                  duration: reduceMotion
                      ? Duration.zero
                      : const Duration(milliseconds: 260),
                  curve: Curves.easeOutBack,
                  builder: (context, s, child) =>
                      Transform.scale(scale: s, child: child),
                  child: Text(
                    word,
                    key: const ValueKey('game-countdown-word'),
                    style: (theme.displayMedium ?? const TextStyle()).copyWith(
                      color: showGo ? House.rose : House.ink,
                      fontWeight: FontWeight.w900,
                      fontSize: 64,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 36),
                  child: Text(
                    hint,
                    textAlign: TextAlign.center,
                    style: (theme.titleMedium ?? const TextStyle()).copyWith(
                      color: House.inkSoft,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                if (best > 0) ...[
                  const SizedBox(height: 6),
                  Text(
                    l.gameBest(best),
                    style: (theme.bodyMedium ?? const TextStyle()).copyWith(
                      color: House.inkSoft,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Dim scrim with a centred card; swallows touches behind it.
class GameScrim extends StatelessWidget {
  const GameScrim({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: House.ink.withValues(alpha: 0.45),
      child: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(28),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}

class PauseOverlay extends StatelessWidget {
  const PauseOverlay({super.key, required this.onResume, required this.onQuit});
  final VoidCallback onResume;
  final VoidCallback onQuit;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return GameScrim(
      child: GameCard(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l.gamePause,
              style:
                  (Theme.of(context).textTheme.headlineSmall ??
                          const TextStyle())
                      .copyWith(color: House.ink, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 18),
            GameButton(label: l.gameResume, onPressed: onResume),
            const SizedBox(height: 10),
            GameButton(label: l.gameQuit, onPressed: onQuit, primary: false),
          ],
        ),
      ),
    );
  }
}

class ResultOverlay extends StatelessWidget {
  const ResultOverlay({
    super.key,
    required this.score,
    required this.best,
    required this.newBest,
    required this.stars,
    required this.starsCap,
    required this.onAgain,
    required this.onDone,
    this.leading,
  });

  final int score;
  final int best;
  final bool newBest;
  final int stars;
  final int starsCap;
  final VoidCallback onAgain;
  final VoidCallback onDone;
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    return GameScrim(
      child: GameCard(
        key: const ValueKey('game-result'),
        color: newBest ? const Color(0xFFFFF1CC) : House.tag,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (leading != null) ...[leading!, const SizedBox(height: 6)],
            Text(
              newBest ? l.gameNewBest : l.gameTimesUp,
              textAlign: TextAlign.center,
              style: (t.headlineSmall ?? const TextStyle()).copyWith(
                color: House.ink,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '$score',
              key: const ValueKey('game-result-score'),
              style: (t.displayLarge ?? const TextStyle()).copyWith(
                color: House.rose,
                fontWeight: FontWeight.w900,
                fontSize: 72,
                height: 1.1,
              ),
            ),
            Text(
              l.gameBest(best),
              style: (t.titleMedium ?? const TextStyle()).copyWith(
                color: House.inkSoft,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const StarGlyph(size: 30),
                const SizedBox(width: 8),
                Text(
                  l.gameStarsEarned(stars),
                  key: const ValueKey('game-result-stars'),
                  style: (t.titleLarge ?? const TextStyle()).copyWith(
                    color: House.ink,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              l.gameStarsCap(starsCap),
              style: (t.bodySmall ?? const TextStyle()).copyWith(
                color: House.inkSoft,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 18),
            GameButton(label: l.gamePlayAgain, onPressed: onAgain),
            const SizedBox(height: 10),
            GameButton(label: l.gameDone, onPressed: onDone, primary: false),
          ],
        ),
      ),
    );
  }
}

// ── floating labels ─────────────────────────────────────────────────────────

class FloatEntry {
  FloatEntry(this.id, this.at, this.text, this.color, this.size);
  final int id;
  final Offset at;
  final String text;
  final Color color;
  final double size;
}

/// The queue of "+1" labels a screen wants to float up from a point.
class FloatController extends ChangeNotifier {
  final List<FloatEntry> entries = [];
  int _next = 0;

  void add(Offset at, String text, Color color, {double size = 26}) {
    entries.add(FloatEntry(_next++, at, text, color, size));
    if (entries.length > 12) entries.removeAt(0);
    notifyListeners();
  }

  void _remove(int id) {
    final before = entries.length;
    entries.removeWhere((e) => e.id == id);
    if (entries.length != before) notifyListeners();
  }

  void clear() {
    if (entries.isEmpty) return;
    entries.clear();
    notifyListeners();
  }
}

class FloatLayer extends StatelessWidget {
  const FloatLayer({
    super.key,
    required this.controller,
    required this.reduceMotion,
  });
  final FloatController controller;
  final bool reduceMotion;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: ExcludeSemantics(
        child: ListenableBuilder(
          listenable: controller,
          builder: (context, _) => Stack(
            clipBehavior: Clip.none,
            children: [
              for (final e in controller.entries)
                Positioned(
                  key: ValueKey(e.id),
                  left: e.at.dx - 60,
                  width: 120,
                  top: e.at.dy - 20,
                  child: _FloatItem(
                    entry: e,
                    reduceMotion: reduceMotion,
                    onDone: () => controller._remove(e.id),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FloatItem extends StatelessWidget {
  const _FloatItem({
    required this.entry,
    required this.reduceMotion,
    required this.onDone,
  });
  final FloatEntry entry;
  final bool reduceMotion;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    final base = Theme.of(context).textTheme.titleLarge ?? const TextStyle();
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: reduceMotion ? 450 : 800),
      onEnd: onDone,
      builder: (context, t, child) {
        final rise = reduceMotion ? 0.0 : Curves.easeOut.transform(t) * 46;
        final pop = reduceMotion
            ? 1.0
            : (t < 0.2 ? 0.7 + t / 0.2 * 0.5 : 1.2 - (t - 0.2) * 0.25);
        return Opacity(
          opacity: (1 - t * t).clamp(0.0, 1.0),
          child: Transform.translate(
            offset: Offset(0, -rise),
            child: Transform.scale(scale: pop, child: child),
          ),
        );
      },
      child: Text(
        entry.text,
        textAlign: TextAlign.center,
        style: base.copyWith(
          fontSize: entry.size,
          fontWeight: FontWeight.w900,
          color: entry.color,
          shadows: const [
            Shadow(color: Colors.white, blurRadius: 3),
            Shadow(color: Colors.white, blurRadius: 6),
          ],
        ),
      ),
    );
  }
}
