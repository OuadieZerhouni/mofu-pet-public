import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../core/app_scope.dart';
import '../l10n/app_localizations.dart';
import '../sim/mofu_sim.dart';
import 'name_dialog.dart';
import 'theme.dart';
import 'widgets.dart';

/// First launch: a wobbling fluff seed → tap → it hatches → name it.
class FirstRunOverlay extends StatefulWidget {
  const FirstRunOverlay({super.key, required this.colorId, required this.onDone});
  final String colorId;
  final VoidCallback onDone;

  @override
  State<FirstRunOverlay> createState() => _FirstRunOverlayState();
}

class _FirstRunOverlayState extends State<FirstRunOverlay> with TickerProviderStateMixin {
  late final AnimationController _wobble =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 1400))..repeat();
  late final AnimationController _hatch = AnimationController(vsync: this, duration: const Duration(milliseconds: 650));
  bool _hatched = false;
  bool _asking = false;

  @override
  void dispose() {
    _wobble.dispose();
    _hatch.dispose();
    super.dispose();
  }

  Future<void> _onTap() async {
    if (_hatched) return;
    final app = AppScope.of(context);
    setState(() => _hatched = true);
    app.sfx.play('hatch');
    app.sfx.haptic('success');
    await _hatch.forward();
    // Let the user meet Mofu before asking for a name.
    await Future<void>.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;
    setState(() => _asking = true);
    final name = await askName(context, initial: app.store.name, firstRun: true);
    if (!mounted) return;
    app.store.rename(name ?? app.store.name);
    widget.onDone();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final reduce = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    return Material(
      color: Colors.transparent,
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFFE9F1), Color(0xFFFFF7EC)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const Spacer(flex: 2),
              Text(
                _hatched ? l.firstRunHello : l.appTitle,
                style: t.headlineMedium?.copyWith(fontWeight: FontWeight.w900, color: MofuColors.ink),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 28),
              Semantics(
                button: !_hatched,
                label: l.firstRunTapSeed,
                child: GestureDetector(
                  onTap: _onTap,
                  child: AnimatedBuilder(
                    animation: Listenable.merge([_wobble, _hatch]),
                    builder: (context, _) {
                      final w = reduce || _hatched ? 0.0 : math.sin(_wobble.value * 2 * math.pi) * 0.12;
                      final h = Curves.elasticOut.transform(_hatch.value);
                      final size = 150 + 90 * h;
                      return Transform.rotate(
                        angle: w,
                        child: SizedBox(
                          width: 260,
                          height: 260,
                          child: Center(
                            child: MofuPreview(
                              colorId: widget.colorId,
                              fluff: 0.05 + 0.5 * h,
                              expr: _hatched ? Expr.happy : Expr.asleep,
                              size: size,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 24),
              AnimatedOpacity(
                opacity: _hatched ? 0 : 1,
                duration: const Duration(milliseconds: 200),
                child: Text(l.firstRunTapSeed, style: t.titleMedium?.copyWith(color: MofuColors.inkSoft)),
              ),
              const Spacer(flex: 3),
              if (_asking) const SizedBox.shrink(),
            ],
          ),
        ),
      ),
    );
  }
}
