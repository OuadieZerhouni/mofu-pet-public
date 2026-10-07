import 'package:flutter_test/flutter_test.dart';
import 'package:mofu_pet/model/catalog.dart';
import 'package:mofu_pet/model/pet_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Progression and persistence (SPEC F3–F6, F8, F10).
void main() {
  late DateTime now;
  late PetStore store;

  Future<PetStore> fresh() async {
    final s = PetStore(clock: () => now);
    await s.load(await SharedPreferences.getInstance());
    return s;
  }

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    now = DateTime(2026, 10, 7, 14);
    store = await fresh();
  });

  test('defaults are a shippable first launch', () {
    expect(store.name, 'Mofu');
    expect(store.firstRunDone, isFalse);
    expect(store.soundOn && store.hapticsOn, isTrue);
    expect(store.colorUnlocked('cream') && store.colorUnlocked('peach'), isTrue);
    expect(store.colorUnlocked('starry'), isFalse);
  });

  test('state survives a relaunch', () async {
    store
      ..rename('Puffy')
      ..setColor('cream')
      ..setAccessory('bow')
      ..completeFirstRun()
      ..addFluff(30)
      ..discover('boing');
    await store.flush();
    final again = await fresh();
    expect(again.name, 'Puffy');
    expect(again.colorId, 'cream');
    expect(again.accessoryId, 'bow');
    expect(again.firstRunDone, isTrue);
    expect(again.fluff, closeTo(38, 0.01));
    expect(again.discovered, contains('boing'));
  });

  test('a corrupt blob falls back to defaults instead of crashing', () async {
    SharedPreferences.setMockInitialValues({PetStore.prefsKey: '{not json'});
    final s = await fresh();
    expect(s.name, 'Mofu');
  });

  test('wrong types in the blob are ignored field by field', () async {
    SharedPreferences.setMockInitialValues({
      PetStore.prefsKey: '{"name":42,"fluff":"lots","color":"neon","discovered":["boing","nope"],"visitDays":3}',
    });
    final s = await fresh();
    expect(s.name, 'Mofu');
    expect(s.fluff, 8);
    expect(s.colorId, 'peach');
    expect(s.discovered, {'boing'});
    expect(s.visitDays, 3);
  });

  test('reset clears everything, one-shot flags included', () async {
    store
      ..completeFirstRun()
      ..completeCoach()
      ..rename('Puffy')
      ..addFluff(50)
      ..setSound(false);
    await store.reset();
    expect(store.firstRunDone || store.coachDone, isFalse);
    expect(store.name, 'Mofu');
    expect(store.fluff, 8);
    expect(store.soundOn, isTrue);
    final again = await fresh();
    expect(again.firstRunDone, isFalse);
  });

  test('visit days count once per local day and never go down', () {
    expect(store.registerVisit(), isTrue);
    expect(store.registerVisit(), isFalse);
    now = now.add(const Duration(days: 1));
    expect(store.registerVisit(), isTrue);
    now = now.add(const Duration(days: 30)); // a long absence costs nothing
    store.registerVisit();
    expect(store.visitDays, 3);
  });

  test('daily first brush is once per day', () {
    expect(store.registerBrush(), isTrue);
    expect(store.registerBrush(), isFalse);
    now = now.add(const Duration(days: 1));
    expect(store.registerBrush(), isTrue);
  });

  test('fluff clamps to 100 and each milestone fires once', () {
    expect(store.addFluff(20), [25]);
    expect(store.addFluff(1), isEmpty);
    expect(store.addFluff(500), [50, 75, 100]);
    expect(store.fluff, 100);
    expect(store.addFluff(10), isEmpty);
  });

  test('unlock rules', () {
    expect(store.colorUnlocked('mint'), isFalse);
    store.registerVisit();
    now = now.add(const Duration(days: 1));
    store.registerVisit();
    expect(store.colorUnlocked('mint'), isTrue, reason: 'mint unlocks on day 2');
    expect(store.colorUnlocked('lavender'), isFalse);
    store.addFluff(20);
    expect(store.colorUnlocked('lavender'), isTrue, reason: 'lavender at 25% fluff');
    for (final r in Catalog.reactions.take(6)) {
      store.discover(r.id);
    }
    expect(store.colorUnlocked('sakura'), isTrue, reason: 'sakura at 6 reactions');
  });

  test('locked items cannot be selected', () {
    store.setColor('starry');
    expect(store.colorId, 'peach');
    store.setAccessory('crown');
    expect(store.accessoryId, 'none');
  });

  test('"new" dots: unlocked items are new until seen; start items never are', () {
    expect(store.unseenUnlocks, isEmpty);
    store.addFluff(20);
    expect(store.unseenUnlocks, contains('color:lavender'));
    store.markSeen(store.unseenUnlocks);
    expect(store.unseenUnlocks, isEmpty);
  });

  test('six snacks an hour, then full; an hour later hungry again', () {
    final fav = store.favoriteSnack.id;
    final other = Catalog.snacks.firstWhere((s) => s.id != fav).id;
    expect(store.feed(fav), FeedResult.favorite);
    for (var i = 0; i < 5; i++) {
      expect(store.feed(other), FeedResult.eaten);
    }
    expect(store.feed(other), FeedResult.full);
    expect(store.snacksFed, 6);
    now = now.add(const Duration(minutes: 61));
    expect(store.feed(other), FeedResult.eaten);
  });

  test('favourite snack is stable per name and varies across names', () {
    expect(Catalog.favoriteSnackFor('Puffy').id, Catalog.favoriteSnackFor(' puffy ').id);
    final favs = {for (final n in ['Mofu', 'Puffy', 'Kiki', 'Momo', 'Bean', 'Cloud', 'Luna', 'Yuki']) Catalog.favoriteSnackFor(n).id};
    expect(favs.length, greaterThan(2));
  });

  test('names are sanitised', () {
    expect(PetStore.sanitizeName('   '), 'Mofu');
    expect(PetStore.sanitizeName('A\u0000B'), 'AB');
    expect(PetStore.sanitizeName('x' * 40).length, PetStore.maxNameLength);
    expect(PetStore.sanitizeName('موفو'), 'موفو');
    expect(PetStore.sanitizeName('🐣🐣🐣🐣🐣🐣🐣🐣🐣🐣🐣🐣🐣🐣🐣🐣🐣🐣').runes.length, 16,
        reason: 'emoji are cut on grapheme boundaries, never mid-character');
  });

  test('seasonal: only known seasons are earned, and only once', () {
    expect(store.earnSeasonal('halloween'), isTrue);
    expect(store.earnSeasonal('halloween'), isFalse);
    expect(store.earnSeasonal('easter'), isFalse);
    expect(store.accessoryUnlocked('witch'), isTrue);
    expect(store.accessoryUnlocked('santa'), isFalse);
  });

  test('discover ignores unknown ids and repeats', () {
    expect(store.discover('boing'), isTrue);
    expect(store.discover('boing'), isFalse);
    expect(store.discover('teleport'), isFalse);
  });
}
