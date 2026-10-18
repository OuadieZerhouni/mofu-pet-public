import 'package:flutter_test/flutter_test.dart';
import 'package:mofu_pet/creatures/creature.dart';
import 'package:mofu_pet/model/house_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late DateTime now;

  Future<HouseStore> fresh() async {
    final s = HouseStore(clock: () => now);
    await s.load(await SharedPreferences.getInstance());
    return s;
  }

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    now = DateTime(2026, 10, 17, 14);
  });

  test('a fresh house is empty and calm', () async {
    final s = await fresh();
    expect(s.friends, isEmpty);
    expect(s.stars, 0);
    expect(s.firstRunDone, isFalse);
    expect(s.nextEgg!.species, Species.oink);
  });

  test('state survives a relaunch', () async {
    final s = await fresh();
    final m = s.adopt(Species.mofu, name: 'Puffy');
    s
      ..wear(m.id, 'head', 'bow')
      ..addFluff(m.id, 30)
      ..earn(StarSource.gift, 6)
      ..discover('mofu.boing')
      ..setMix('ocean', 0.8)
      ..completeFirstRun();
    await s.flush();
    final again = await fresh();
    expect(again.friends.single.name, 'Puffy');
    expect(again.friends.single.wear['head'], 'bow');
    expect(again.friends.single.fluff, closeTo(38, 0.01));
    expect(again.stars, 6);
    expect(again.discovered, contains('mofu.boing'));
    expect(again.sleepMix['ocean'], 0.8);
    expect(again.firstRunDone, isTrue);
  });

  test('migrates the v1 single-Mofu save', () async {
    SharedPreferences.setMockInitialValues({
      HouseStore.legacyKey:
          '{"name":"Puffy","color":"mint","accessory":"crown","fluff":64,"discovered":["boing","hug"],"visitDays":5,"firstRunDone":true,"soundOn":false}',
    });
    final s = await fresh();
    final m = s.friends.single;
    expect(m.species, Species.mofu);
    expect(m.name, 'Puffy');
    expect(m.variant, 'mint');
    expect(m.wear['head'], 'crown');
    expect(m.fluff, 64);
    expect(s.discovered, {'mofu.boing', 'mofu.hug'});
    expect(s.soundOn, isFalse);
    expect(s.firstRunDone, isTrue);
    expect(s.stars, greaterThan(0));
    expect(s.stars, lessThan(40), reason: 'the head start never hatches an egg by itself');
  });

  test('corrupt or mistyped data falls back per field', () async {
    SharedPreferences.setMockInitialValues({
      HouseStore.prefsKey: '{"friends":[{"id":"f1","species":"dragon"},{"id":"f2","species":"oink","name":42}],'
          '"stars":"lots","lastRoom":"attic","sleepTimer":7}',
    });
    final s = await fresh();
    expect(s.friends.map((f) => f.species), [Species.oink], reason: 'unknown species dropped');
    expect(s.friends.single.name, 'Oinky');
    expect(s.stars, 0);
    expect(s.lastRoom, Room.living);
    expect(s.sleepTimerMin, 30);
    SharedPreferences.setMockInitialValues({HouseStore.prefsKey: '{not json'});
    expect((await fresh()).friends, isEmpty);
  });

  test('stars respect daily caps and reset the next day', () async {
    final s = await fresh();
    expect(s.earn(StarSource.favoriteSnack, 2), 2);
    expect(s.earn(StarSource.favoriteSnack, 5), 1, reason: 'cap 3 per day');
    expect(s.earn(StarSource.favoriteSnack, 1), 0);
    now = now.add(const Duration(days: 1));
    expect(s.earn(StarSource.favoriteSnack, 1), 1);
    expect(s.stars, 4);
  });

  test('first touch of the day per friend gives one star and xp', () async {
    final s = await fresh();
    final m = s.adopt(Species.mofu);
    expect(s.registerTouch(m.id), isTrue);
    expect(s.registerTouch(m.id), isFalse);
    expect(s.stars, 1);
    expect(m.xp, 3);
  });

  test('friendship levels climb with xp and cap at 10', () {
    expect(HouseStore.levelForXp(0), 1);
    expect(HouseStore.levelForXp(19), 1);
    expect(HouseStore.levelForXp(20), 2);
    expect(HouseStore.levelForXp(100000), 10);
  });

  test('hatchery: eggs open at lifetime star thresholds, in order', () async {
    final s = await fresh();
    s.adopt(Species.mofu);
    expect(s.eggReady, isFalse);
    expect(s.hatch(), isNull);
    s.stars = 9;
    expect(s.eggReady, isFalse);
    s.stars = 10;
    expect(s.eggReady, isTrue);
    final oink = s.hatch(name: 'Truffle')!;
    expect(oink.species, Species.oink);
    expect(oink.name, 'Truffle');
    expect(s.nextEgg!.species, Species.wuff);
    expect(s.eggReady, isFalse);
    s.stars = 60;
    expect(s.hatch()!.species, Species.wuff);
    s.stars = 120;
    final boop = s.hatch()!;
    expect(boop.species, Species.boop);
    expect(boop.variant, HouseStore.boopOrder.first);
  });

  test('rooms hold at most four friends', () async {
    final s = await fresh();
    final ids = [for (var i = 0; i < 5; i++) s.adopt(Species.boop, variant: 'mochi').id];
    expect(s.inRoom(Room.living).length, 4, reason: 'the fifth waits off stage');
    expect(s.moveTo(ids.last, Room.living), isFalse);
    expect(s.moveTo(ids.first, Room.spa), isTrue);
    expect(s.moveTo(ids.last, Room.living), isTrue);
  });

  test('six snacks an hour per friend, favourite pays a star', () async {
    final s = await fresh();
    final m = s.adopt(Species.mofu);
    expect(s.feed(m.id, 'cookie', favorite: 'cookie'), FeedOutcome.favorite);
    for (var i = 0; i < 5; i++) {
      expect(s.feed(m.id, 'dango', favorite: 'cookie'), FeedOutcome.eaten);
    }
    expect(s.feed(m.id, 'dango', favorite: 'cookie'), FeedOutcome.full);
    expect(s.snacksLeft(m.id), 0);
    now = now.add(const Duration(minutes: 61));
    expect(s.feed(m.id, 'dango', favorite: 'cookie'), FeedOutcome.eaten);
    expect(s.stars, 1);
  });

  test('spa pays once per friend per day', () async {
    final s = await fresh();
    final m = s.adopt(Species.mofu);
    expect(s.finishSpa(m.id), 3);
    expect(s.finishSpa(m.id), 0);
    expect(m.xp, 12);
  });

  test('daily gift streak grows on consecutive days and restarts gently', () async {
    final s = await fresh();
    expect(s.claimGift(), 6);
    expect(s.giftReady, isFalse);
    now = now.add(const Duration(days: 1));
    expect(s.claimGift(), 7);
    now = now.add(const Duration(days: 3));
    expect(s.claimGift(), 6, reason: 'a gap restarts the streak at 1');
  });

  // F1-c1: the room the user was in survives a relaunch.
  test('last room survives a relaunch', () async {
    final s = await fresh();
    s.setRoom(Room.kitchen);
    await s.flush();
    expect((await fresh()).lastRoom, Room.kitchen);
  });

  // F8-c1: the streak tops out at 7 days, so day 8 and later still pay 5 + 7.
  test('gift streak caps at seven days', () async {
    final s = await fresh();
    final paid = <int>[];
    for (var d = 0; d < 10; d++) {
      paid.add(s.claimGift());
      now = now.add(const Duration(days: 1));
    }
    expect(paid, [6, 7, 8, 9, 10, 11, 12, 12, 12, 12]);
  });

  test('tricks master after practice on three different days', () async {
    final s = await fresh();
    final w = s.adopt(Species.wuff);
    expect(s.practiceTrick(w.id, 'sit'), isFalse);
    expect(s.practiceTrick(w.id, 'sit'), isFalse, reason: 'once per day');
    now = now.add(const Duration(days: 1));
    expect(s.practiceTrick(w.id, 'sit'), isFalse);
    now = now.add(const Duration(days: 1));
    expect(s.practiceTrick(w.id, 'sit'), isTrue);
    expect(w.tricks, contains('sit'));
  });

  test('mini-games keep best scores and pay capped stars', () async {
    final s = await fresh();
    expect(s.finishGame(StarSource.boopRush, 64), 12);
    expect(s.finishGame(StarSource.boopRush, 20), 0, reason: 'cap reached');
    expect(s.bestBoopRush, 64);
    expect(s.finishGame(StarSource.snackCatch, 20), 5);
    expect(s.bestSnackCatch, 20);
  });

  test('reset wipes everything including the legacy blob', () async {
    SharedPreferences.setMockInitialValues({HouseStore.legacyKey: '{"firstRunDone":true}'});
    final s = await fresh();
    s.adopt(Species.oink);
    await s.reset();
    expect(s.friends, isEmpty);
    expect(s.firstRunDone, isFalse);
    expect((await fresh()).friends, isEmpty);
  });

  test('names are sanitised', () {
    expect(HouseStore.sanitizeName('   ', fallback: 'Oinky'), 'Oinky');
    expect(HouseStore.sanitizeName('x' * 40).length, HouseStore.maxNameLength);
    expect(HouseStore.sanitizeName('موفو'), 'موفو');
  });

  test('v1 glasses migrate into the face slot', () async {
    SharedPreferences.setMockInitialValues({
      HouseStore.legacyKey: '{"name":"Puffy","color":"peach","accessory":"glasses","fluff":10,"firstRunDone":true}',
    });
    final m = (await fresh()).friends.single;
    expect(m.wear, {'face': 'glasses'});
  });

  test('gift streak: the button day is the day paid, across month ends, reset after a gap', () async {
    now = DateTime(2026, 10, 31, 9);
    final s = await fresh();
    expect(s.nextGiftDay, 1);
    expect(s.claimGift(), 6);
    now = DateTime(2026, 11, 1, 0, 30); // next calendar day, just after midnight
    expect(s.nextGiftDay, 2);
    expect(s.claimGift(), 7);
    expect(s.giftStreak, 2);
    now = DateTime(2026, 11, 4, 9); // missed two days
    expect(s.nextGiftDay, 1);
    s.claimGift();
    expect(s.giftStreak, 1);
  });

  test('every xp source reports a level-up; first touch reports stars only when paid', () async {
    final s = await fresh();
    final m = s.adopt(Species.mofu);
    s.levelUps.clear();
    m.xp = 19; // one short of level 2
    s.registerTouch(m.id);
    expect(s.levelUps, [(m.id, 2)]);
    // The first-touch cap is 8 a day: a 9th friend's touch pays nothing and says so.
    for (var i = 0; i < 8; i++) {
      s.earn(StarSource.firstTouch, 1);
    }
    final o = s.adopt(Species.oink);
    expect(s.registerTouch(o.id), isFalse);
  });

  test('the first egg is reachable in one first session: first touch + gift + one spa day', () async {
    final s = await fresh();
    final m = s.adopt(Species.mofu);
    s.registerTouch(m.id);
    s.claimGift();
    s.finishSpa(m.id);
    expect(s.stars, 10);
    expect(s.eggReady, isTrue);
  });
}
