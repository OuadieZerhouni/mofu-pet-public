import 'dart:async';
import 'dart:collection';

import 'package:flutter/material.dart';

import '../model/catalog.dart';
import '../sim/mofu_sim.dart';
import 'mofu_painter.dart';
import 'theme.dart';

/// A still Mofu, for the wardrobe tiles, first run and settings header.
/// Owns a private simulation so its fur layout is the real one.
class MofuPreview extends StatefulWidget {
  const MofuPreview({
    super.key,
    required this.colorId,
    this.accessoryId = 'none',
    this.fluff = 0.6,
    this.expr = Expr.idle,
    this.size = 96,
  });

  final String colorId;
  final String accessoryId;
  final double fluff;
  final Expr expr;
  final double size;

  @override
  State<MofuPreview> createState() => _MofuPreviewState();
}

class _MofuPreviewState extends State<MofuPreview> {
  late final MofuSim _sim = MofuSim(seed: 3, reduceMotion: true);

  void _pose() {
    final s = widget.size;
    _sim.fluff = widget.fluff;
    _sim.layout(Size(s, s), top: 0, floor: s * 0.94);
    // Leave headroom for tall hats: the body sits in the lower part.
    _sim.baseRadius = s * 0.27;
    _sim.pos = Offset(s / 2, s * 0.94 - _sim.radius);
    _sim.expr = widget.expr;
    _sim.blink = 0;
  }

  @override
  Widget build(BuildContext context) {
    _pose();
    return SizedBox.square(
      dimension: widget.size,
      child: CustomPaint(painter: _StillPainter(_sim, Catalog.color(widget.colorId), widget.accessoryId)),
    );
  }
}

class _StillPainter extends CustomPainter {
  _StillPainter(this.sim, this.color, this.accessory);
  final MofuSim sim;
  final FurColor color;
  final String accessory;

  @override
  void paint(Canvas canvas, Size size) => paintMofu(canvas, sim, color, accessory, shadow: false);

  @override
  bool shouldRepaint(_StillPainter old) =>
      old.color != color || old.accessory != accessory || old.sim.expr != sim.expr || old.sim.fluff != sim.fluff;
}

/// Round, soft dock button with an optional "new" dot and an active state.
class DockButton extends StatelessWidget {
  const DockButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.active = false,
    this.dot = false,
    this.onDark = false,
  });

  final Widget icon;
  final String label;
  final VoidCallback onTap;
  final bool active;
  final bool dot;

  /// Light label for the night room, where ink-on-glow is unreadable.
  final bool onDark;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: active,
      label: label,
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: SizedBox(
          width: 76,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    width: 58,
                    height: 58,
                    decoration: BoxDecoration(
                      color: active ? const Color(0xFFFFE3EE) : MofuColors.card,
                      border: Border.all(color: active ? MofuColors.accent : Colors.transparent, width: 3),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: MofuColors.ink.withValues(alpha: 0.10),
                          blurRadius: 14,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: icon,
                  ),
                  if (dot)
                    PositionedDirectional(
                      top: 2,
                      end: 2,
                      child: Container(
                        width: 14,
                        height: 14,
                        decoration: BoxDecoration(
                          color: MofuColors.accentDeep,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: onDark ? Colors.white : MofuColors.ink,
                      shadows: [
                        Shadow(color: onDark ? const Color(0xAA1B1440) : Colors.white, blurRadius: 8),
                      ],
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Queue of short messages shown one at a time at the top of the room.
class ToastController extends ChangeNotifier {
  final Queue<String> _queue = Queue();
  String? current;
  Timer? _timer;

  void show(String message) {
    if (message.isEmpty || message == current || _queue.contains(message)) return;
    _queue.add(message);
    if (current == null) _next();
  }

  void _next() {
    _timer?.cancel();
    current = _queue.isEmpty ? null : _queue.removeFirst();
    notifyListeners();
    if (current != null) {
      _timer = Timer(const Duration(milliseconds: 2400), _next);
    }
  }

  /// Drops the current and queued messages.
  void clear() {
    _queue.clear();
    _next();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

class ToastView extends StatelessWidget {
  const ToastView({super.key, required this.controller});
  final ToastController controller;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final msg = controller.current;
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 260),
          transitionBuilder: (child, a) => FadeTransition(
            opacity: a,
            child: SlideTransition(
              position: Tween(begin: const Offset(0, -0.4), end: Offset.zero).animate(a),
              child: child,
            ),
          ),
          child: msg == null
              ? const SizedBox.shrink()
              : Semantics(
                  liveRegion: true,
                  key: ValueKey(msg),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 24),
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
                    decoration: BoxDecoration(
                      color: MofuColors.card,
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: [
                        BoxShadow(color: MofuColors.ink.withValues(alpha: 0.12), blurRadius: 16, offset: const Offset(0, 6)),
                      ],
                    ),
                    child: Text(
                      msg,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w800),
                    ),
                  ),
                ),
        );
      },
    );
  }
}

/// The little speech bubble Mofu uses for the first-run coach hint.
class SpeechBubble extends StatelessWidget {
  const SpeechBubble({super.key, required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
          decoration: BoxDecoration(
            color: MofuColors.card,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [BoxShadow(color: MofuColors.ink.withValues(alpha: 0.12), blurRadius: 12, offset: const Offset(0, 4))],
          ),
          child: Text(text, style: Theme.of(context).textTheme.titleMedium),
        ),
        CustomPaint(size: const Size(18, 10), painter: _TailPainter()),
      ],
    );
  }
}

class _TailPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width / 2, size.height)
      ..close();
    canvas.drawPath(p, Paint()..color = MofuColors.card);
  }

  @override
  bool shouldRepaint(_TailPainter oldDelegate) => false;
}
