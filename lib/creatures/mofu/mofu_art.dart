import 'dart:ui';

import '../../model/catalog.dart';
import '../../ui/mofu_painter.dart';
import '../creature.dart';
import 'mofu_creature.dart';

/// Draws Mofu with its v1 painter (strand fur, face, particles). Accessories
/// are drawn here too, inside the body transform, so hats squash with the fur.
class MofuArt extends CreatureArt {
  const MofuArt();

  @override
  void paint(Canvas canvas, Creature c, CreatureLook look, {bool shadow = true}) {
    final m = c as MofuCreature;
    final acc = look.accessories.isEmpty ? 'none' : look.accessories.first;
    paintMofu(canvas, m.sim, Catalog.color(look.variant), acc, shadow: shadow);
    paintParticles(canvas, m.sim);
  }
}
