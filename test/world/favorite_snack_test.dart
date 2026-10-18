import 'package:flutter_test/flutter_test.dart';
import 'package:mofu_pet/creatures/creature.dart';
import 'package:mofu_pet/model/house_store.dart';
import 'package:mofu_pet/world/creature_factory.dart';

/// SPEC F5-c1: each friend's favourite comes from its own menu, hashed from its name.
void main() {
  Friend friend(Species sp, String name) => Friend(id: 'x', species: sp, name: name, variant: '', hatchedDay: '2026-10-18');

  test('the favourite is on the species menu, stable per name, and varies across names', () {
    for (final sp in Species.values) {
      final menu = snacksFor(sp);
      final seen = <String>{};
      for (final n in ['Mofu', 'Truffle', 'Biscuit', 'Pip', 'Mochi', 'Bean', 'Luna', 'Kiki', 'Nori', 'Tofu']) {
        final fav = favoriteSnack(friend(sp, n));
        expect(menu, contains(fav), reason: '$sp $n');
        expect(favoriteSnack(friend(sp, '  ${n.toUpperCase()} ')), fav, reason: 'trim + case');
        seen.add(fav);
      }
      expect(seen.length, greaterThan(2), reason: '$sp: names spread over the menu');
    }
  });
}
