"""Generates lib/l10n/species_text.dart: journal names/hints, coat names and trick
names for the Oink / Wuff / Boop catalogues and the house-wide reactions.

    python tools/l10n/species_text.py

English is the source of truth and is pasted below as Python data (no Dart is
imported). `check_against_dart()` re-reads the Dart catalogues with a regex and
fails if an id or an English string drifted, or if any language misses an id, so
a new catalogue entry cannot ship untranslated. Run it after editing a catalogue.
"""
from __future__ import annotations

import pathlib
import re
import sys

ROOT = pathlib.Path(__file__).resolve().parents[2]
OUT = ROOT / "lib" / "l10n" / "species_text.dart"
LANGS = ["en", "ja", "de", "pt", "es", "fr", "ar"]

# --------------------------------------------------------------------------- #
# English source: reactions as id -> (name, hint)
# --------------------------------------------------------------------------- #
EN_REACTIONS: dict[str, tuple[str, str]] = {
    # oink
    "oink.snout": ("Snout boop", "Tap the snout."),
    "oink.head": ("Happy pats", "Tap the head."),
    "oink.pat": ("Head scritches", "Rub the head back and forth."),
    "oink.belly": ("Belly giggle", "Tap the round belly."),
    "oink.rub": ("Belly rub", "Rub the belly back and forth."),
    "oink.ear": ("Ear flop", "Tap an ear."),
    "oink.tail": ("Tail spin", "Tap the curly tail."),
    "oink.tickle": ("Tickle frenzy", "Tap again and again, really fast."),
    "oink.squish": ("Squish", "Press and hold on the pig."),
    "oink.pickup": ("Up we go", "Hold, then drag the pig up."),
    "oink.landing": ("Plop landing", "Toss the pig and watch it land."),
    "oink.hop": ("Little hop", "Wait a while: the pig hops for joy."),
    "oink.munch": ("Yum", "Feed the pig a snack."),
    "oink.favorite": ("Favourite snack", "Feed the pig its favourite snack."),
    "oink.full": ("Too full", "Offer a snack when the pig is stuffed."),
    "oink.sleep": ("Sweet snores", "Let the pig fall asleep."),
    "oink.wake": ("Rise and shine", "Wake the pig up."),
    "oink.grumble": ("Grumpy pig", "Poke the pig while it sleeps."),
    "oink.groom": ("Bubble bath", "Scrub the pig with foam."),
    "oink.towel": ("Towel rub", "Dry the pig with the towel."),
    "oink.dryer": ("Blow dry", "Use the dryer and watch the ears flap."),
    "oink.cheer": ("Party pig", "Join in a celebration."),
    "oink.nuzzle": ("Friend cuddle", "Let a friend nuzzle the pig."),
    "oink.peek": ("Nosy pig", "Touch a friend while the pig watches."),
    "oink.bumped": ("Oof!", "Land a friend on top of the pig."),
    # wuff
    "wuff.yip": ("Happy yip", "Give your puppy a quick tap."),
    "wuff.pet": ("Head pats", "Stroke the top of its head for a moment."),
    "wuff.earScratch": ("Ear scratch", "Rub a floppy ear until a back leg starts thumping."),
    "wuff.blep": ("Blep", "Scratch under the chin and watch the tongue peek out."),
    "wuff.achoo": ("Achoo!", "Boop the nose once."),
    "wuff.bigSneeze": ("Big sneeze", "Boop the nose three times in a row."),
    "wuff.wink": ("Wink", "Double-tap one eye."),
    "wuff.zoomies": ("Zoomies", "Tap the puppy five times, fast."),
    "wuff.snuggle": ("Snuggle", "Press and hold on the puppy."),
    "wuff.love": ("Total love", "Keep holding until the hearts appear."),
    "wuff.dizzy": ("Dizzy", "Give the phone a gentle shake."),
    "wuff.yum": ("Yum", "Feed it a treat."),
    "wuff.favorite": ("Favourite treat", "Find the treat it loves most."),
    "wuff.full": ("Too full", "Offer one treat too many."),
    "wuff.goodPup": ("Good pup!", "Reward a trick with a treat."),
    "wuff.howl": ("Howl", "Press the howl pad on the bark board."),
    "wuff.nap": ("Nap time", "Leave the puppy alone for a while."),
    "wuff.wake": ("Big yawn", "Wake a sleeping puppy."),
    "wuff.groomed": ("Squeaky clean", "Give it a bath and a rub down."),
    "wuff.shakeOff": ("Shake it off", "Soap it up and let it shake the water off."),
    "wuff.nuzzled": ("Nuzzled", "A friend gives it a nuzzle."),
    "wuff.startled": ("Startled hop", "A friend lands right next to it."),
    "wuff.watchFriend": ("Friend watching", "Touch a friend and see who looks over."),
    "wuff.cheer": ("Party time", "Celebrate together with the whole house."),
    "wuff.trick.sit": ("Sit", "Teach it to sit."),
    "wuff.trick.paw": ("Paw", "Teach it to shake a paw."),
    "wuff.trick.spin": ("Spin", "Teach it to spin around."),
    "wuff.trick.speak": ("Speak", "Teach it to speak on command."),
    "wuff.trick.playDead": ("Play dead", "Teach it to play dead."),
    "wuff.trick.highFive": ("High five", "Teach it a high five."),
    # boop
    "boop.boop": ("Boop!", "Tap the nose."),
    "boop.combo10": ("Boop-a-doop", "Boop the nose 10 times in a row, less than a second apart."),
    "boop.combo25": ("Snoot storm", "Keep a boop combo going to 25."),
    "boop.combo50": ("Mega boop", "Reach a boop combo of 50."),
    "boop.sneeze": ("Achoo!", "Boop so much that the nose tickles: every 30th boop in a combo."),
    "boop.hug": ("Snuggle", "Rest a finger on the body for a moment."),
    "boop.wobble": ("Wobble giggle", "Tap the squishy body."),
    "boop.stretch": ("Stretchy", "Drag the body and let go."),
    "boop.tickle": ("Tickle spin", "Tap the body again and again, quickly."),
    "boop.jelly": ("Jelly wobble", "Scrub it clean in the spa."),
    "boop.munch": ("Munch", "Give it a snack."),
    "boop.yum": ("Yum!", "Give it its favourite snack."),
    "boop.full": ("Too full", "Offer a snack when it is full."),
    "boop.boopBack": ("Boop back", "Let a friend nuzzle it."),
    "boop.cheer": ("Cheer", "Celebrate together."),
    "boop.hop": ("Little hop", "Leave it alone for a while and it hops about."),
    "boop.sleepy": ("Dozing off", "Leave it alone for half a minute."),
    "boop.surprise": ("Plop!", "Let a friend land on it."),
    # house-wide (not in any Dart catalogue)
    "house.pileUp": ("Friend pile", "Toss a friend onto another"),
    "house.nuzzle": ("Nuzzle", "Let friends play side by side"),
    "house.spa": ("Spa day", "Finish a full spa routine"),
    "house.sleepSounds": ("Lullaby", "Play sleep sounds in the bedroom"),
    "house.dressUp": ("Dress-up", "Put an accessory on a friend"),
    "house.photo": ("Say cheese", "Share a photo from the photo booth"),
    "house.hatch.oink": ("Welcome, piglet!", "Hatch an egg in the garden"),
    "house.hatch.wuff": ("Welcome, puppy!", "Hatch an egg in the garden"),
    "house.hatch.boop": ("Welcome, Boop!", "Hatch an egg in the garden"),
    "house.favorite.mofu": ("Favourite snack!", "Find a friend's favourite snack"),
    "house.favorite.oink": ("Favourite snack!", "Find a friend's favourite snack"),
    "house.favorite.wuff": ("Favourite snack!", "Find a friend's favourite snack"),
    "house.favorite.boop": ("Favourite snack!", "Find a friend's favourite snack"),
}

# English variants: species -> id -> name
EN_VARIANTS: dict[str, dict[str, str]] = {
    "oink": {
        "classic": "Classic pink", "peach": "Peach", "spotted": "Spotted", "chocolate": "Chocolate",
        "lavender": "Lavender", "golden": "Golden", "mint": "Mint", "snow": "Snow",
    },
    "wuff": {
        "golden": "Golden", "cream": "Cream", "chocolate": "Chocolate", "blackTan": "Black & tan",
        "snow": "Snow", "corgi": "Corgi", "dalmatian": "Dalmatian", "husky": "Husky",
        "beagle": "Beagle", "cottonCandy": "Cotton candy",
    },
    "boop": {
        "mochi": "Mochi", "pip": "Pip", "bao": "Bao", "kiwi": "Kiwi", "momo": "Momo", "puff": "Puff",
        "nori": "Nori", "taro": "Taro", "coco": "Coco", "jelly": "Jelly", "sprout": "Sprout", "star": "Star",
    },
}

EN_TRICKS: dict[str, str] = {
    "sit": "Sit", "paw": "Paw", "spin": "Spin", "speak": "Speak", "playDead": "Play dead", "highFive": "High five",
}

# --------------------------------------------------------------------------- #
# Translations. Hints keep the English punctuation habit: catalogue hints end
# with a full stop, house hints do not.
# --------------------------------------------------------------------------- #
R: dict[str, dict[str, tuple[str, str]]] = {}

R["ja"] = {
    "oink.snout": ("はなぽん", "はなをタップ。"),
    "oink.head": ("よしよし", "あたまをタップ。"),
    "oink.pat": ("あたまなでなで", "あたまを左右にこする。"),
    "oink.belly": ("おなかくすくす", "まるいおなかをタップ。"),
    "oink.rub": ("おなかなでなで", "おなかを左右になでる。"),
    "oink.ear": ("おみみぱたぱた", "みみをタップ。"),
    "oink.tail": ("しっぽくるくる", "くるんとしたしっぽをタップ。"),
    "oink.tickle": ("くすぐり大会", "何度も何度も、すばやくタップ。"),
    "oink.squish": ("ぷにっ", "こぶたを長押し。"),
    "oink.pickup": ("よいしょ", "つかんで、こぶたを上へドラッグ。"),
    "oink.landing": ("ぽてっ", "こぶたを投げて、着地を見守ろう。"),
    "oink.hop": ("ぴょん", "しばらく待つと、こぶたがうれしくてぴょん。"),
    "oink.munch": ("もぐもぐ", "こぶたにおやつをあげる。"),
    "oink.favorite": ("大好物", "こぶたの大好きなおやつをあげる。"),
    "oink.full": ("おなかいっぱい", "おなかいっぱいのときにおやつをあげる。"),
    "oink.sleep": ("すやすや", "こぶたが眠るまでそっとしておく。"),
    "oink.wake": ("おはよう", "こぶたを起こす。"),
    "oink.grumble": ("ぷんぷん", "眠っているこぶたをつつく。"),
    "oink.groom": ("あわあわバス", "あわでこぶたを洗う。"),
    "oink.towel": ("タオルでごしごし", "タオルでこぶたをふく。"),
    "oink.dryer": ("ドライヤー", "ドライヤーを使って、ぱたぱたするお耳を見よう。"),
    "oink.cheer": ("パーティーぶた", "みんなのお祝いに参加する。"),
    "oink.nuzzle": ("すりすり", "なかまにこぶたへすりすりしてもらう。"),
    "oink.peek": ("のぞきっこ", "こぶたが見ているときに、なかまにさわる。"),
    "oink.bumped": ("どすん！", "こぶたの上になかまを着地させる。"),
    "wuff.yip": ("うれしいキャン", "こいぬをかるくタップ。"),
    "wuff.pet": ("あたまなでなで", "あたまの上をしばらくなでる。"),
    "wuff.earScratch": ("みみかきかき", "たれたみみをこすると、うしろ足がトントン。"),
    "wuff.blep": ("ぺろっ", "あごの下をかくと、したがぺろっ。"),
    "wuff.achoo": ("くしゅん！", "はなを1回ぽん。"),
    "wuff.bigSneeze": ("大くしゃみ", "はなを3回つづけてぽん。"),
    "wuff.wink": ("ウインク", "目をダブルタップ。"),
    "wuff.zoomies": ("ダッシュ！", "こいぬをすばやく5回タップ。"),
    "wuff.snuggle": ("ぎゅっ", "こいぬを長押し。"),
    "wuff.love": ("だいすき", "ハートが出るまで押し続ける。"),
    "wuff.dizzy": ("くらくら", "スマホをやさしくふる。"),
    "wuff.yum": ("おいしい", "おやつをあげる。"),
    "wuff.favorite": ("大好物のおやつ", "いちばん好きなおやつを見つける。"),
    "wuff.full": ("おなかいっぱい", "おやつをあげすぎる。"),
    "wuff.goodPup": ("えらいね！", "トリックができたらおやつでごほうび。"),
    "wuff.howl": ("アオーン", "ワンボードのアオーンパッドを押す。"),
    "wuff.nap": ("おひるね", "こいぬをしばらくそっとしておく。"),
    "wuff.wake": ("おおあくび", "眠っているこいぬを起こす。"),
    "wuff.groomed": ("ぴかぴか", "おふろに入れて、ふいてあげる。"),
    "wuff.shakeOff": ("ぶるぶる", "あわあわにして、水をぶるぶるさせる。"),
    "wuff.nuzzled": ("すりすり", "なかまがすりすりしてくれる。"),
    "wuff.startled": ("びっくりジャンプ", "なかまがすぐ隣に着地する。"),
    "wuff.watchFriend": ("なかまをみつめる", "なかまにさわって、だれが見るか見てみよう。"),
    "wuff.cheer": ("パーティータイム", "おうちのみんなでお祝いする。"),
    "wuff.trick.sit": ("おすわり", "おすわりを教える。"),
    "wuff.trick.paw": ("おて", "おてを教える。"),
    "wuff.trick.spin": ("くるりん", "くるりんを教える。"),
    "wuff.trick.speak": ("ほえる", "号令でほえるのを教える。"),
    "wuff.trick.playDead": ("ばたんきゅー", "ばたんきゅーを教える。"),
    "wuff.trick.highFive": ("ハイタッチ", "ハイタッチを教える。"),
    "boop.boop": ("ぽん！", "はなをタップ。"),
    "boop.combo10": ("ぽんぽこぽん", "1秒以内の間隔で、はなを10回つづけてぽん。"),
    "boop.combo25": ("おはなストーム", "ぽんコンボを25までつなげる。"),
    "boop.combo50": ("メガぽん", "ぽんコンボ50に到達する。"),
    "boop.sneeze": ("くしゅん！", "ぽんしすぎてはながむずむず：コンボ中の30回目ごと。"),
    "boop.hug": ("ぎゅっ", "からだに指をそっとのせる。"),
    "boop.wobble": ("ぷるぷるくすくす", "ぷにぷにのからだをタップ。"),
    "boop.stretch": ("びよーん", "からだをドラッグして、はなす。"),
    "boop.tickle": ("くすぐりスピン", "からだをすばやく何度もタップ。"),
    "boop.jelly": ("ぷるぷるジェリー", "スパできれいにこする。"),
    "boop.munch": ("もぐもぐ", "おやつをあげる。"),
    "boop.yum": ("おいしい！", "大好きなおやつをあげる。"),
    "boop.full": ("おなかいっぱい", "おなかいっぱいのときにおやつをあげる。"),
    "boop.boopBack": ("ぽんかえし", "なかまにすりすりしてもらう。"),
    "boop.cheer": ("やったー", "みんなでお祝いする。"),
    "boop.hop": ("ぴょん", "しばらくそっとしておくと、はねまわる。"),
    "boop.sleepy": ("うとうと", "30秒ほどそっとしておく。"),
    "boop.surprise": ("ぽとん！", "なかまを上に着地させる。"),
    "house.pileUp": ("なかまタワー", "なかまをほかの子の上に投げる"),
    "house.nuzzle": ("すりすり", "なかまを並べてあそばせる"),
    "house.spa": ("スパデー", "スパのコースを最後までやりきる"),
    "house.sleepSounds": ("ねんねのうた", "寝室でねむりの音を流す"),
    "house.dressUp": ("おめかし", "なかまにアクセサリーをつける"),
    "house.photo": ("はい、チーズ", "フォトブースの写真をシェアする"),
    "house.hatch.oink": ("ようこそ、こぶた！", "お庭でたまごをかえす"),
    "house.hatch.wuff": ("ようこそ、こいぬ！", "お庭でたまごをかえす"),
    "house.hatch.boop": ("ようこそ、Boop！", "お庭でたまごをかえす"),
    "house.favorite.mofu": ("大好物のおやつ！", "なかまの大好物を見つける"),
    "house.favorite.oink": ("大好物のおやつ！", "なかまの大好物を見つける"),
    "house.favorite.wuff": ("大好物のおやつ！", "なかまの大好物を見つける"),
    "house.favorite.boop": ("大好物のおやつ！", "なかまの大好物を見つける"),
}

R["de"] = {
    "oink.snout": ("Nasen-Boop", "Tippe auf die Schnauze."),
    "oink.head": ("Freudiges Tätscheln", "Tippe auf den Kopf."),
    "oink.pat": ("Kopfkraulen", "Reibe den Kopf hin und her."),
    "oink.belly": ("Bauchkichern", "Tippe auf den runden Bauch."),
    "oink.rub": ("Bauchkraulen", "Reibe den Bauch hin und her."),
    "oink.ear": ("Ohrenwackeln", "Tippe auf ein Ohr."),
    "oink.tail": ("Ringelschwanz-Wirbel", "Tippe auf den Ringelschwanz."),
    "oink.tickle": ("Kitzelrausch", "Tippe immer wieder, ganz schnell."),
    "oink.squish": ("Quetsch", "Halte den Finger auf dem Ferkel."),
    "oink.pickup": ("Hoch geht's", "Halten, dann das Ferkel nach oben ziehen."),
    "oink.landing": ("Plumps-Landung", "Wirf das Ferkel und sieh zu, wie es landet."),
    "oink.hop": ("Hüpferchen", "Warte eine Weile: Das Ferkel hüpft vor Freude."),
    "oink.munch": ("Lecker", "Gib dem Ferkel einen Snack."),
    "oink.favorite": ("Lieblingssnack", "Gib dem Ferkel seinen Lieblingssnack."),
    "oink.full": ("Zu satt", "Biete einen Snack an, wenn das Ferkel pappsatt ist."),
    "oink.sleep": ("Süßes Schnarchen", "Lass das Ferkel einschlafen."),
    "oink.wake": ("Aufwachen!", "Weck das Ferkel auf."),
    "oink.grumble": ("Grummel-Ferkel", "Stups das Ferkel im Schlaf an."),
    "oink.groom": ("Schaumbad", "Schrubbe das Ferkel mit Schaum."),
    "oink.towel": ("Abrubbeln", "Trockne das Ferkel mit dem Handtuch."),
    "oink.dryer": ("Föhnen", "Nimm den Föhn und sieh die Ohren flattern."),
    "oink.cheer": ("Partyferkel", "Feiere mit."),
    "oink.nuzzle": ("Kuschelfreund", "Lass einen Freund das Ferkel anstupsen."),
    "oink.peek": ("Neugieriges Ferkel", "Berühre einen Freund, während das Ferkel zusieht."),
    "oink.bumped": ("Hoppla!", "Lass einen Freund auf dem Ferkel landen."),
    "wuff.yip": ("Freudiges Kläffen", "Gib deinem Welpen einen kurzen Tipp."),
    "wuff.pet": ("Kopftätscheln", "Streichle kurz über seinen Kopf."),
    "wuff.earScratch": ("Ohrenkraulen", "Kraule ein Schlappohr, bis ein Hinterbein zu trommeln beginnt."),
    "wuff.blep": ("Blep", "Kraule unter dem Kinn und sieh die Zunge herausschauen."),
    "wuff.achoo": ("Hatschi!", "Boope die Nase einmal."),
    "wuff.bigSneeze": ("Großes Niesen", "Boope die Nase dreimal hintereinander."),
    "wuff.wink": ("Zwinkern", "Tippe doppelt auf ein Auge."),
    "wuff.zoomies": ("Flitzeanfall", "Tippe fünfmal schnell auf den Welpen."),
    "wuff.snuggle": ("Kuscheln", "Halte den Finger auf dem Welpen."),
    "wuff.love": ("Ganz viel Liebe", "Halte weiter, bis die Herzen erscheinen."),
    "wuff.dizzy": ("Schwindelig", "Schüttle das Handy sanft."),
    "wuff.yum": ("Lecker", "Gib ihm ein Leckerli."),
    "wuff.favorite": ("Lieblingsleckerli", "Finde sein Lieblingsleckerli."),
    "wuff.full": ("Zu satt", "Biete ein Leckerli zu viel an."),
    "wuff.goodPup": ("Braver Hund!", "Belohne einen Trick mit einem Leckerli."),
    "wuff.howl": ("Heulen", "Drücke das Heul-Pad auf dem Bellbrett."),
    "wuff.nap": ("Nickerchen", "Lass den Welpen eine Weile in Ruhe."),
    "wuff.wake": ("Großes Gähnen", "Weck einen schlafenden Welpen."),
    "wuff.groomed": ("Blitzblank", "Gib ihm ein Bad und eine Abreibung."),
    "wuff.shakeOff": ("Schüttel dich!", "Seif ihn ein und lass ihn das Wasser abschütteln."),
    "wuff.nuzzled": ("Angestupst", "Ein Freund stupst ihn an."),
    "wuff.startled": ("Schreckhüpfer", "Ein Freund landet direkt neben ihm."),
    "wuff.watchFriend": ("Freundebeobachter", "Berühre einen Freund und sieh, wer herüberschaut."),
    "wuff.cheer": ("Partyzeit", "Feiert zusammen mit dem ganzen Haus."),
    "wuff.trick.sit": ("Sitz", "Bring ihm Sitz bei."),
    "wuff.trick.paw": ("Pfötchen", "Bring ihm bei, Pfötchen zu geben."),
    "wuff.trick.spin": ("Drehen", "Bring ihm bei, sich zu drehen."),
    "wuff.trick.speak": ("Sprich", "Bring ihm bei, auf Kommando zu bellen."),
    "wuff.trick.playDead": ("Totstellen", "Bring ihm bei, sich totzustellen."),
    "wuff.trick.highFive": ("High Five", "Bring ihm ein High Five bei."),
    "boop.boop": ("Boop!", "Tippe auf die Nase."),
    "boop.combo10": ("Boppi-Boop", "Boope die Nase 10-mal hintereinander, jeweils unter einer Sekunde Abstand."),
    "boop.combo25": ("Nasensturm", "Halte eine Boop-Combo bis 25 aufrecht."),
    "boop.combo50": ("Mega-Boop", "Erreiche eine Boop-Combo von 50."),
    "boop.sneeze": ("Hatschi!", "Boope so viel, dass die Nase kitzelt: jeder 30. Boop in einer Combo."),
    "boop.hug": ("Kuscheln", "Lege kurz einen Finger auf den Körper."),
    "boop.wobble": ("Wackelkichern", "Tippe auf den weichen Körper."),
    "boop.stretch": ("Dehnbar", "Zieh am Körper und lass los."),
    "boop.tickle": ("Kitzeldrehung", "Tippe schnell immer wieder auf den Körper."),
    "boop.jelly": ("Wackelpudding", "Schrubbe es im Spa sauber."),
    "boop.munch": ("Mampf", "Gib ihm einen Snack."),
    "boop.yum": ("Lecker!", "Gib ihm seinen Lieblingssnack."),
    "boop.full": ("Zu satt", "Biete einen Snack an, wenn es satt ist."),
    "boop.boopBack": ("Zurück-Boop", "Lass einen Freund es anstupsen."),
    "boop.cheer": ("Jubel", "Feiert zusammen."),
    "boop.hop": ("Hüpferchen", "Lass es eine Weile in Ruhe, dann hüpft es herum."),
    "boop.sleepy": ("Eindösen", "Lass es eine halbe Minute in Ruhe."),
    "boop.surprise": ("Plumps!", "Lass einen Freund auf ihm landen."),
    "house.pileUp": ("Freundeshaufen", "Wirf einen Freund auf einen anderen"),
    "house.nuzzle": ("Anstupsen", "Lass Freunde nebeneinander spielen"),
    "house.spa": ("Spa-Tag", "Schließe eine komplette Spa-Routine ab"),
    "house.sleepSounds": ("Schlaflied", "Spiele im Schlafzimmer Einschlafklänge ab"),
    "house.dressUp": ("Verkleiden", "Zieh einem Freund ein Accessoire an"),
    "house.photo": ("Bitte lächeln", "Teile ein Foto aus der Fotobox"),
    "house.hatch.oink": ("Willkommen, Ferkel!", "Lass im Garten ein Ei schlüpfen"),
    "house.hatch.wuff": ("Willkommen, Welpe!", "Lass im Garten ein Ei schlüpfen"),
    "house.hatch.boop": ("Willkommen, Boop!", "Lass im Garten ein Ei schlüpfen"),
    "house.favorite.mofu": ("Lieblingssnack!", "Finde den Lieblingssnack eines Freundes"),
    "house.favorite.oink": ("Lieblingssnack!", "Finde den Lieblingssnack eines Freundes"),
    "house.favorite.wuff": ("Lieblingssnack!", "Finde den Lieblingssnack eines Freundes"),
    "house.favorite.boop": ("Lieblingssnack!", "Finde den Lieblingssnack eines Freundes"),
}

R["pt"] = {
    "oink.snout": ("Boop no focinho", "Toque no focinho."),
    "oink.head": ("Tapinhas felizes", "Toque na cabeça."),
    "oink.pat": ("Cafuné na cabeça", "Esfregue a cabeça de um lado para o outro."),
    "oink.belly": ("Risadinha de barriga", "Toque na barriguinha redonda."),
    "oink.rub": ("Carinho na barriga", "Esfregue a barriga de um lado para o outro."),
    "oink.ear": ("Orelha balançando", "Toque em uma orelha."),
    "oink.tail": ("Rabinho girando", "Toque no rabinho enroladinho."),
    "oink.tickle": ("Festa de cócegas", "Toque sem parar, bem rápido."),
    "oink.squish": ("Apertadinho", "Mantenha pressionado sobre o porquinho."),
    "oink.pickup": ("Lá vamos nós", "Segure e arraste o porquinho para cima."),
    "oink.landing": ("Pouso plof", "Jogue o porquinho e veja ele pousar."),
    "oink.hop": ("Pulinho", "Espere um pouco: o porquinho pula de alegria."),
    "oink.munch": ("Nham", "Dê um lanche ao porquinho."),
    "oink.favorite": ("Lanche favorito", "Dê ao porquinho o lanche favorito dele."),
    "oink.full": ("Cheio demais", "Ofereça um lanche quando o porquinho está empanturrado."),
    "oink.sleep": ("Roncos doces", "Deixe o porquinho adormecer."),
    "oink.wake": ("Bom dia", "Acorde o porquinho."),
    "oink.grumble": ("Porquinho mal-humorado", "Cutuque o porquinho enquanto ele dorme."),
    "oink.groom": ("Banho de espuma", "Esfregue o porquinho com espuma."),
    "oink.towel": ("Esfregada de toalha", "Seque o porquinho com a toalha."),
    "oink.dryer": ("Secador", "Use o secador e veja as orelhas balançarem."),
    "oink.cheer": ("Porquinho festeiro", "Participe de uma comemoração."),
    "oink.nuzzle": ("Aconchego de amigo", "Deixe um amigo se aconchegar no porquinho."),
    "oink.peek": ("Porquinho curioso", "Toque em um amigo enquanto o porquinho observa."),
    "oink.bumped": ("Ui!", "Faça um amigo cair em cima do porquinho."),
    "wuff.yip": ("Latidinho feliz", "Dê um toquinho no seu cachorrinho."),
    "wuff.pet": ("Carinho na cabeça", "Faça carinho no alto da cabeça por um instante."),
    "wuff.earScratch": ("Coçadinha na orelha", "Esfregue uma orelha caída até uma perninha de trás começar a bater."),
    "wuff.blep": ("Blep", "Coce embaixo do queixo e veja a língua aparecer."),
    "wuff.achoo": ("Atchim!", "Dê um boop no nariz uma vez."),
    "wuff.bigSneeze": ("Espirro enorme", "Dê um boop no nariz três vezes seguidas."),
    "wuff.wink": ("Piscadinha", "Toque duas vezes em um olho."),
    "wuff.zoomies": ("Correria", "Toque no cachorrinho cinco vezes, rápido."),
    "wuff.snuggle": ("Aconchego", "Mantenha pressionado sobre o cachorrinho."),
    "wuff.love": ("Amor total", "Continue segurando até os corações aparecerem."),
    "wuff.dizzy": ("Tontinho", "Balance o celular com delicadeza."),
    "wuff.yum": ("Nham", "Dê um petisco a ele."),
    "wuff.favorite": ("Petisco favorito", "Descubra o petisco que ele mais ama."),
    "wuff.full": ("Cheio demais", "Ofereça um petisco a mais."),
    "wuff.goodPup": ("Bom garoto!", "Recompense um truque com um petisco."),
    "wuff.howl": ("Uivo", "Aperte o botão de uivo no painel de latidos."),
    "wuff.nap": ("Hora da soneca", "Deixe o cachorrinho em paz por um tempo."),
    "wuff.wake": ("Bocejo enorme", "Acorde um cachorrinho dormindo."),
    "wuff.groomed": ("Limpinho", "Dê um banho e uma boa secada."),
    "wuff.shakeOff": ("Sacode tudo", "Ensaboe e deixe ele sacudir a água."),
    "wuff.nuzzled": ("Aconchegado", "Um amigo se aconchega nele."),
    "wuff.startled": ("Pulo de susto", "Um amigo cai bem ao lado dele."),
    "wuff.watchFriend": ("Olhando o amigo", "Toque em um amigo e veja quem olha para lá."),
    "wuff.cheer": ("Hora da festa", "Comemorem juntos com a casa inteira."),
    "wuff.trick.sit": ("Sentar", "Ensine-o a sentar."),
    "wuff.trick.paw": ("Patinha", "Ensine-o a dar a patinha."),
    "wuff.trick.spin": ("Girar", "Ensine-o a girar."),
    "wuff.trick.speak": ("Falar", "Ensine-o a latir quando você pedir."),
    "wuff.trick.playDead": ("Fingir de morto", "Ensine-o a fingir de morto."),
    "wuff.trick.highFive": ("Toca aqui", "Ensine-o a dar um toca aqui."),
    "boop.boop": ("Boop!", "Toque no nariz."),
    "boop.combo10": ("Bipi-boop", "Dê 10 boops seguidos no nariz, com menos de um segundo entre eles."),
    "boop.combo25": ("Tempestade de focinhos", "Mantenha um combo de boops até 25."),
    "boop.combo50": ("Mega boop", "Chegue a um combo de 50 boops."),
    "boop.sneeze": ("Atchim!", "Dê tantos boops que o nariz faz cócegas: a cada 30º boop de um combo."),
    "boop.hug": ("Aconchego", "Apoie um dedo no corpo por um instante."),
    "boop.wobble": ("Risadinha tremida", "Toque no corpo molinho."),
    "boop.stretch": ("Elástico", "Arraste o corpo e solte."),
    "boop.tickle": ("Giro de cócegas", "Toque no corpo sem parar, rápido."),
    "boop.jelly": ("Gelatina tremendo", "Esfregue até ficar limpinho no spa."),
    "boop.munch": ("Nham nham", "Dê um lanche a ele."),
    "boop.yum": ("Nham!", "Dê a ele o lanche favorito."),
    "boop.full": ("Cheio demais", "Ofereça um lanche quando ele está cheio."),
    "boop.boopBack": ("Boop de volta", "Deixe um amigo se aconchegar nele."),
    "boop.cheer": ("Viva", "Comemorem juntos."),
    "boop.hop": ("Pulinho", "Deixe ele sozinho por um tempo e ele pula por aí."),
    "boop.sleepy": ("Cochilando", "Deixe ele sozinho por meio minuto."),
    "boop.surprise": ("Plof!", "Deixe um amigo cair em cima dele."),
    "house.pileUp": ("Pilha de amigos", "Jogue um amigo em cima de outro"),
    "house.nuzzle": ("Aconchego", "Deixe os amigos brincarem lado a lado"),
    "house.spa": ("Dia de spa", "Termine uma rotina de spa completa"),
    "house.sleepSounds": ("Canção de ninar", "Toque sons para dormir no quarto"),
    "house.dressUp": ("Hora de se vestir", "Coloque um acessório em um amigo"),
    "house.photo": ("Diga xis", "Compartilhe uma foto da cabine de fotos"),
    "house.hatch.oink": ("Bem-vindo, porquinho!", "Choque um ovo no jardim"),
    "house.hatch.wuff": ("Bem-vindo, cachorrinho!", "Choque um ovo no jardim"),
    "house.hatch.boop": ("Bem-vindo, Boop!", "Choque um ovo no jardim"),
    "house.favorite.mofu": ("Lanche favorito!", "Descubra o lanche favorito de um amigo"),
    "house.favorite.oink": ("Lanche favorito!", "Descubra o lanche favorito de um amigo"),
    "house.favorite.wuff": ("Lanche favorito!", "Descubra o lanche favorito de um amigo"),
    "house.favorite.boop": ("Lanche favorito!", "Descubra o lanche favorito de um amigo"),
}

R["es"] = {
    "oink.snout": ("Boop en el hocico", "Toca el hocico."),
    "oink.head": ("Palmaditas felices", "Toca la cabeza."),
    "oink.pat": ("Rascadita en la cabeza", "Frota la cabeza de un lado a otro."),
    "oink.belly": ("Risitas de panza", "Toca la panza redondita."),
    "oink.rub": ("Masaje de panza", "Frota la panza de un lado a otro."),
    "oink.ear": ("Orejas al viento", "Toca una oreja."),
    "oink.tail": ("Colita en espiral", "Toca la colita rizada."),
    "oink.tickle": ("Locura de cosquillas", "Toca una y otra vez, muy rápido."),
    "oink.squish": ("Apretujón", "Mantén presionado sobre el cerdito."),
    "oink.pickup": ("Arriba vamos", "Mantén presionado y arrastra al cerdito hacia arriba."),
    "oink.landing": ("Aterrizaje plof", "Lanza al cerdito y míralo aterrizar."),
    "oink.hop": ("Saltito", "Espera un rato: el cerdito salta de alegría."),
    "oink.munch": ("Ñam", "Dale un snack al cerdito."),
    "oink.favorite": ("Snack favorito", "Dale al cerdito su snack favorito."),
    "oink.full": ("Demasiado lleno", "Ofrece un snack cuando el cerdito está lleno."),
    "oink.sleep": ("Dulces ronquidos", "Deja que el cerdito se quede dormido."),
    "oink.wake": ("A despertar", "Despierta al cerdito."),
    "oink.grumble": ("Cerdito gruñón", "Molesta al cerdito mientras duerme."),
    "oink.groom": ("Baño de burbujas", "Frota al cerdito con espuma."),
    "oink.towel": ("Frotar con toalla", "Seca al cerdito con la toalla."),
    "oink.dryer": ("Secador", "Usa el secador y mira cómo se agitan las orejas."),
    "oink.cheer": ("Cerdito fiestero", "Únete a una celebración."),
    "oink.nuzzle": ("Mimo de amigo", "Deja que un amigo acaricie al cerdito con el hocico."),
    "oink.peek": ("Cerdito curioso", "Toca a un amigo mientras el cerdito mira."),
    "oink.bumped": ("¡Uf!", "Haz que un amigo aterrice sobre el cerdito."),
    "wuff.yip": ("Ladridito feliz", "Dale un toque rápido a tu cachorro."),
    "wuff.pet": ("Caricias en la cabeza", "Acaricia su cabeza un momento."),
    "wuff.earScratch": ("Rascadita de oreja", "Frota una oreja caída hasta que una pata trasera empiece a golpear el suelo."),
    "wuff.blep": ("Blep", "Rasca bajo la barbilla y mira cómo asoma la lengua."),
    "wuff.achoo": ("¡Achís!", "Haz boop en la nariz una vez."),
    "wuff.bigSneeze": ("Gran estornudo", "Haz boop en la nariz tres veces seguidas."),
    "wuff.wink": ("Guiño", "Toca dos veces un ojo."),
    "wuff.zoomies": ("Carrerita loca", "Toca al cachorro cinco veces, rápido."),
    "wuff.snuggle": ("Acurrucarse", "Mantén presionado sobre el cachorro."),
    "wuff.love": ("Amor total", "Sigue presionando hasta que aparezcan los corazones."),
    "wuff.dizzy": ("Mareado", "Sacude el teléfono con suavidad."),
    "wuff.yum": ("Ñam", "Dale una golosina."),
    "wuff.favorite": ("Golosina favorita", "Encuentra la golosina que más le gusta."),
    "wuff.full": ("Demasiado lleno", "Ofrece una golosina de más."),
    "wuff.goodPup": ("¡Buen perrito!", "Premia un truco con una golosina."),
    "wuff.howl": ("Aullido", "Pulsa el botón de aullido del tablero de ladridos."),
    "wuff.nap": ("Hora de la siesta", "Deja al cachorro tranquilo un rato."),
    "wuff.wake": ("Gran bostezo", "Despierta a un cachorro dormido."),
    "wuff.groomed": ("Limpiecito", "Dale un baño y un buen secado."),
    "wuff.shakeOff": ("Sacúdete", "Enjabónalo y deja que se sacuda el agua."),
    "wuff.nuzzled": ("Mimado", "Un amigo le da un empujoncito con el hocico."),
    "wuff.startled": ("Salto de susto", "Un amigo aterriza justo a su lado."),
    "wuff.watchFriend": ("Mirando al amigo", "Toca a un amigo y mira quién se asoma."),
    "wuff.cheer": ("Hora de fiesta", "Celebren juntos con toda la casa."),
    "wuff.trick.sit": ("Sentarse", "Enséñale a sentarse."),
    "wuff.trick.paw": ("Pata", "Enséñale a dar la pata."),
    "wuff.trick.spin": ("Girar", "Enséñale a dar vueltas."),
    "wuff.trick.speak": ("Hablar", "Enséñale a ladrar cuando se lo pidas."),
    "wuff.trick.playDead": ("Hacerse el muerto", "Enséñale a hacerse el muerto."),
    "wuff.trick.highFive": ("Choca cinco", "Enséñale a chocar los cinco."),
    "boop.boop": ("¡Boop!", "Toca la nariz."),
    "boop.combo10": ("Bipi-boop", "Haz boop en la nariz 10 veces seguidas, con menos de un segundo entre cada una."),
    "boop.combo25": ("Tormenta de hocicos", "Mantén un combo de boops hasta llegar a 25."),
    "boop.combo50": ("Mega boop", "Llega a un combo de 50 boops."),
    "boop.sneeze": ("¡Achís!", "Haz tantos boops que la nariz le cosquillea: cada boop número 30 de un combo."),
    "boop.hug": ("Acurrucarse", "Apoya un dedo en el cuerpo un momento."),
    "boop.wobble": ("Risa temblona", "Toca el cuerpo blandito."),
    "boop.stretch": ("Elástico", "Arrastra el cuerpo y suelta."),
    "boop.tickle": ("Giro de cosquillas", "Toca el cuerpo una y otra vez, rápido."),
    "boop.jelly": ("Temblor de gelatina", "Límpialo bien en el spa."),
    "boop.munch": ("Ñam ñam", "Dale un snack."),
    "boop.yum": ("¡Rico!", "Dale su snack favorito."),
    "boop.full": ("Demasiado lleno", "Ofrece un snack cuando está lleno."),
    "boop.boopBack": ("Boop de vuelta", "Deja que un amigo lo acaricie con el hocico."),
    "boop.cheer": ("Hurra", "Celebren juntos."),
    "boop.hop": ("Saltito", "Déjalo solo un rato y saltará por ahí."),
    "boop.sleepy": ("Cabeceando", "Déjalo solo medio minuto."),
    "boop.surprise": ("¡Plof!", "Deja que un amigo aterrice sobre él."),
    "house.pileUp": ("Montón de amigos", "Lanza a un amigo sobre otro"),
    "house.nuzzle": ("Hociquitos", "Deja que los amigos jueguen lado a lado"),
    "house.spa": ("Día de spa", "Completa una rutina de spa entera"),
    "house.sleepSounds": ("Canción de cuna", "Pon sonidos para dormir en el dormitorio"),
    "house.dressUp": ("A vestirse", "Ponle un accesorio a un amigo"),
    "house.photo": ("Sonrían", "Comparte una foto de la cabina de fotos"),
    "house.hatch.oink": ("¡Bienvenido, cerdito!", "Haz eclosionar un huevo en el jardín"),
    "house.hatch.wuff": ("¡Bienvenido, cachorro!", "Haz eclosionar un huevo en el jardín"),
    "house.hatch.boop": ("¡Bienvenido, Boop!", "Haz eclosionar un huevo en el jardín"),
    "house.favorite.mofu": ("¡Snack favorito!", "Encuentra el snack favorito de un amigo"),
    "house.favorite.oink": ("¡Snack favorito!", "Encuentra el snack favorito de un amigo"),
    "house.favorite.wuff": ("¡Snack favorito!", "Encuentra el snack favorito de un amigo"),
    "house.favorite.boop": ("¡Snack favorito!", "Encuentra el snack favorito de un amigo"),
}

R["fr"] = {
    "oink.snout": ("Boop sur le groin", "Touche le groin."),
    "oink.head": ("Tapotis heureux", "Touche la tête."),
    "oink.pat": ("Grattouilles de tête", "Frotte la tête d'avant en arrière."),
    "oink.belly": ("Fou rire du ventre", "Touche le ventre tout rond."),
    "oink.rub": ("Câlin de ventre", "Frotte le ventre d'avant en arrière."),
    "oink.ear": ("Oreille qui bat", "Touche une oreille."),
    "oink.tail": ("Queue qui tourne", "Touche la queue en tire-bouchon."),
    "oink.tickle": ("Folie des chatouilles", "Touche encore et encore, très vite."),
    "oink.squish": ("Tout mou", "Maintiens ton doigt sur le cochonnet."),
    "oink.pickup": ("Hop, on monte", "Maintiens, puis fais glisser le cochonnet vers le haut."),
    "oink.landing": ("Atterrissage plouf", "Lance le cochonnet et regarde-le atterrir."),
    "oink.hop": ("Petit saut", "Attends un peu : le cochonnet saute de joie."),
    "oink.munch": ("Miam", "Donne un goûter au cochonnet."),
    "oink.favorite": ("Goûter préféré", "Donne au cochonnet son goûter préféré."),
    "oink.full": ("Trop rassasié", "Propose un goûter quand le cochonnet n'a plus faim."),
    "oink.sleep": ("Doux ronflements", "Laisse le cochonnet s'endormir."),
    "oink.wake": ("Debout là-dedans", "Réveille le cochonnet."),
    "oink.grumble": ("Cochon grognon", "Embête le cochonnet pendant qu'il dort."),
    "oink.groom": ("Bain moussant", "Frotte le cochonnet avec de la mousse."),
    "oink.towel": ("Frictionné", "Sèche le cochonnet avec la serviette."),
    "oink.dryer": ("Brushing", "Utilise le sèche-cheveux et regarde les oreilles voler."),
    "oink.cheer": ("Cochon de fête", "Participe à une célébration."),
    "oink.nuzzle": ("Câlin d'ami", "Laisse un ami faire un câlin au cochonnet."),
    "oink.peek": ("Cochon curieux", "Touche un ami pendant que le cochonnet regarde."),
    "oink.bumped": ("Aïe !", "Fais atterrir un ami sur le cochonnet."),
    "wuff.yip": ("Petit jappement joyeux", "Donne une petite tape à ton chiot."),
    "wuff.pet": ("Caresses sur la tête", "Caresse le dessus de sa tête un instant."),
    "wuff.earScratch": ("Grattouille d'oreille", "Frotte une oreille tombante jusqu'à ce qu'une patte arrière se mette à battre."),
    "wuff.blep": ("Blep", "Gratte sous le menton et regarde la langue sortir."),
    "wuff.achoo": ("Atchoum !", "Fais un boop sur le nez une fois."),
    "wuff.bigSneeze": ("Gros éternuement", "Fais un boop sur le nez trois fois de suite."),
    "wuff.wink": ("Clin d'œil", "Touche deux fois un œil."),
    "wuff.zoomies": ("Crise de folie", "Touche le chiot cinq fois, vite."),
    "wuff.snuggle": ("Câlin", "Maintiens ton doigt sur le chiot."),
    "wuff.love": ("Amour total", "Continue de maintenir jusqu'à ce que les cœurs apparaissent."),
    "wuff.dizzy": ("Tout étourdi", "Secoue doucement le téléphone."),
    "wuff.yum": ("Miam", "Donne-lui une friandise."),
    "wuff.favorite": ("Friandise préférée", "Trouve la friandise qu'il aime le plus."),
    "wuff.full": ("Trop rassasié", "Offre une friandise de trop."),
    "wuff.goodPup": ("Bon chien !", "Récompense un tour avec une friandise."),
    "wuff.howl": ("Hurlement", "Appuie sur la touche hurlement du tableau d'aboiements."),
    "wuff.nap": ("Heure de la sieste", "Laisse le chiot tranquille un moment."),
    "wuff.wake": ("Gros bâillement", "Réveille un chiot endormi."),
    "wuff.groomed": ("Propre comme un sou neuf", "Donne-lui un bain et un bon séchage."),
    "wuff.shakeOff": ("Secoue-toi", "Savonne-le et laisse-le s'ébrouer."),
    "wuff.nuzzled": ("Câliné", "Un ami lui fait un câlin."),
    "wuff.startled": ("Sursaut", "Un ami atterrit juste à côté de lui."),
    "wuff.watchFriend": ("Regard vers l'ami", "Touche un ami et vois qui tourne la tête."),
    "wuff.cheer": ("C'est la fête", "Faites la fête ensemble avec toute la maison."),
    "wuff.trick.sit": ("Assis", "Apprends-lui à s'asseoir."),
    "wuff.trick.paw": ("Patte", "Apprends-lui à donner la patte."),
    "wuff.trick.spin": ("Tourne", "Apprends-lui à tourner sur lui-même."),
    "wuff.trick.speak": ("Parle", "Apprends-lui à aboyer sur commande."),
    "wuff.trick.playDead": ("Fais le mort", "Apprends-lui à faire le mort."),
    "wuff.trick.highFive": ("Tope là", "Apprends-lui à faire un tope là."),
    "boop.boop": ("Boop !", "Touche le nez."),
    "boop.combo10": ("Boopi-boop", "Fais 10 boops de suite sur le nez, à moins d'une seconde d'écart."),
    "boop.combo25": ("Tempête de truffes", "Garde un combo de boops jusqu'à 25."),
    "boop.combo50": ("Méga boop", "Atteins un combo de 50 boops."),
    "boop.sneeze": ("Atchoum !", "Fais tant de boops que le nez chatouille : un boop sur 30 dans un combo."),
    "boop.hug": ("Câlin", "Pose un doigt sur le corps un instant."),
    "boop.wobble": ("Rire tout mou", "Touche le corps tout doux."),
    "boop.stretch": ("Élastique", "Fais glisser le corps puis lâche."),
    "boop.tickle": ("Toupie chatouilles", "Touche le corps encore et encore, vite."),
    "boop.jelly": ("Gelée qui tremble", "Frotte-le bien au spa."),
    "boop.munch": ("Croc croc", "Donne-lui un goûter."),
    "boop.yum": ("Miam !", "Donne-lui son goûter préféré."),
    "boop.full": ("Trop rassasié", "Propose un goûter quand il n'a plus faim."),
    "boop.boopBack": ("Boop en retour", "Laisse un ami lui faire un câlin."),
    "boop.cheer": ("Hourra", "Faites la fête ensemble."),
    "boop.hop": ("Petit saut", "Laisse-le seul un moment et il sautille partout."),
    "boop.sleepy": ("Petit somme", "Laisse-le seul une demi-minute."),
    "boop.surprise": ("Plouf !", "Laisse un ami atterrir sur lui."),
    "house.pileUp": ("Tas d'amis", "Lance un ami sur un autre"),
    "house.nuzzle": ("Câlins", "Laisse les amis jouer côte à côte"),
    "house.spa": ("Journée spa", "Termine un rituel de spa complet"),
    "house.sleepSounds": ("Berceuse", "Lance des sons pour dormir dans la chambre"),
    "house.dressUp": ("Habillage", "Mets un accessoire à un ami"),
    "house.photo": ("Souriez !", "Partage une photo depuis la cabine photo"),
    "house.hatch.oink": ("Bienvenue, cochonnet !", "Fais éclore un œuf dans le jardin"),
    "house.hatch.wuff": ("Bienvenue, chiot !", "Fais éclore un œuf dans le jardin"),
    "house.hatch.boop": ("Bienvenue, Boop !", "Fais éclore un œuf dans le jardin"),
    "house.favorite.mofu": ("Goûter préféré !", "Trouve le goûter préféré d'un ami"),
    "house.favorite.oink": ("Goûter préféré !", "Trouve le goûter préféré d'un ami"),
    "house.favorite.wuff": ("Goûter préféré !", "Trouve le goûter préféré d'un ami"),
    "house.favorite.boop": ("Goûter préféré !", "Trouve le goûter préféré d'un ami"),
}

R["ar"] = {
    "oink.snout": ("بوب على الأنف", "المس الأنف."),
    "oink.head": ("ربتات سعيدة", "المس الرأس."),
    "oink.pat": ("تحكيك الرأس", "دلّك الرأس ذهابًا وإيابًا."),
    "oink.belly": ("ضحكة البطن", "المس البطن المدوّر."),
    "oink.rub": ("تدليك البطن", "دلّك البطن ذهابًا وإيابًا."),
    "oink.ear": ("أذن مرفرفة", "المس أذنًا."),
    "oink.tail": ("ذيل يدور", "المس الذيل المجعّد."),
    "oink.tickle": ("جنون الدغدغة", "المس مرارًا وتكرارًا بسرعة كبيرة."),
    "oink.squish": ("عصرة", "اضغط مطوّلًا على الخنزير."),
    "oink.pickup": ("هيا إلى فوق", "اضغط مطوّلًا ثم اسحب الخنزير إلى الأعلى."),
    "oink.landing": ("هبوط بلوف", "ارمِ الخنزير وشاهده يهبط."),
    "oink.hop": ("قفزة صغيرة", "انتظر قليلًا: يقفز الخنزير فرحًا."),
    "oink.munch": ("لذيذ", "أطعم الخنزير وجبة خفيفة."),
    "oink.favorite": ("الوجبة المفضّلة", "أطعم الخنزير وجبته المفضّلة."),
    "oink.full": ("شبعان جدًا", "قدّم وجبة والخنزير ممتلئ."),
    "oink.sleep": ("شخير لطيف", "دع الخنزير ينام."),
    "oink.wake": ("صباح النشاط", "أيقظ الخنزير."),
    "oink.grumble": ("خنزير غاضب", "انكز الخنزير وهو نائم."),
    "oink.groom": ("حمّام فقاعات", "افرك الخنزير بالرغوة."),
    "oink.towel": ("تنشيف بالمنشفة", "جفّف الخنزير بالمنشفة."),
    "oink.dryer": ("المجفّف", "استخدم المجفّف وشاهد الأذنين ترفرفان."),
    "oink.cheer": ("خنزير الحفلة", "شارك في الاحتفال."),
    "oink.nuzzle": ("حضن صديق", "دع صديقًا يحتضن الخنزير."),
    "oink.peek": ("خنزير فضولي", "المس صديقًا بينما يراقب الخنزير."),
    "oink.bumped": ("أوه!", "اجعل صديقًا يهبط فوق الخنزير."),
    "wuff.yip": ("نبحة سعيدة", "المس جروك لمسة سريعة."),
    "wuff.pet": ("تربيت الرأس", "امسح أعلى رأسه للحظة."),
    "wuff.earScratch": ("حك الأذن", "دلّك أذنًا متدلية حتى تبدأ رجله الخلفية بالدق."),
    "wuff.blep": ("لسان خارج", "حُكّ تحت الذقن وشاهد اللسان يطلّ."),
    "wuff.achoo": ("عطسة!", "المس الأنف مرة واحدة."),
    "wuff.bigSneeze": ("عطسة كبيرة", "المس الأنف ثلاث مرات متتالية."),
    "wuff.wink": ("غمزة", "انقر مرتين على عين واحدة."),
    "wuff.zoomies": ("جنون الركض", "المس الجرو خمس مرات بسرعة."),
    "wuff.snuggle": ("احتضان", "اضغط مطوّلًا على الجرو."),
    "wuff.love": ("حب كبير", "واصل الضغط حتى تظهر القلوب."),
    "wuff.dizzy": ("دوخة", "هزّ الجوال برفق."),
    "wuff.yum": ("لذيذ", "أعطه مكافأة."),
    "wuff.favorite": ("مكافأته المفضّلة", "اعثر على المكافأة التي يحبها أكثر."),
    "wuff.full": ("شبعان جدًا", "قدّم مكافأة زائدة."),
    "wuff.goodPup": ("جرو مطيع!", "كافئ حيلة بمكافأة."),
    "wuff.howl": ("عواء", "اضغط زر العواء على لوحة النباح."),
    "wuff.nap": ("وقت القيلولة", "اترك الجرو وحده لبعض الوقت."),
    "wuff.wake": ("تثاؤب كبير", "أيقظ جروًا نائمًا."),
    "wuff.groomed": ("نظيف تمامًا", "امنحه حمّامًا وتنشيفًا."),
    "wuff.shakeOff": ("انفض الماء", "اغسله بالصابون ودعه ينفض الماء."),
    "wuff.nuzzled": ("احتضان", "يحتضنه صديق."),
    "wuff.startled": ("قفزة خوف", "يهبط صديق بجانبه مباشرة."),
    "wuff.watchFriend": ("يراقب صديقًا", "المس صديقًا وانظر من سيلتفت."),
    "wuff.cheer": ("وقت الحفلة", "احتفلوا معًا مع البيت كله."),
    "wuff.trick.sit": ("اجلس", "علّمه أن يجلس."),
    "wuff.trick.paw": ("صافح", "علّمه أن يصافح."),
    "wuff.trick.spin": ("دُر", "علّمه أن يدور حول نفسه."),
    "wuff.trick.speak": ("انبح", "علّمه أن ينبح عند الطلب."),
    "wuff.trick.playDead": ("تظاهر بالموت", "علّمه أن يتظاهر بالموت."),
    "wuff.trick.highFive": ("كفّ بكفّ", "علّمه تحية الكفّ."),
    "boop.boop": ("بوب!", "المس الأنف."),
    "boop.combo10": ("بوب بوب بوب", "المس الأنف 10 مرات متتالية، بفارق أقل من ثانية بين كل مرة."),
    "boop.combo25": ("عاصفة أنوف", "حافظ على سلسلة بوب حتى 25."),
    "boop.combo50": ("بوب خارق", "اصل إلى سلسلة بوب من 50."),
    "boop.sneeze": ("عطسة!", "أكثر من البوب حتى يدغدغ الأنف: كل بوب رقم 30 في السلسلة."),
    "boop.hug": ("احتضان", "ضع إصبعك على الجسم للحظة."),
    "boop.wobble": ("ضحكة مهتزة", "المس الجسم الطري."),
    "boop.stretch": ("مطّاطي", "اسحب الجسم ثم اتركه."),
    "boop.tickle": ("دوران الدغدغة", "المس الجسم مرارًا وبسرعة."),
    "boop.jelly": ("اهتزاز الجيلي", "افركه حتى ينظف في السبا."),
    "boop.munch": ("قضمة", "أعطه وجبة خفيفة."),
    "boop.yum": ("لذيذ!", "أعطه وجبته المفضّلة."),
    "boop.full": ("شبعان جدًا", "قدّم وجبة وهو ممتلئ."),
    "boop.boopBack": ("بوب مقابل", "دع صديقًا يحتضنه."),
    "boop.cheer": ("هتاف", "احتفلوا معًا."),
    "boop.hop": ("قفزة صغيرة", "اتركه وحده قليلًا وسيقفز هنا وهناك."),
    "boop.sleepy": ("يغفو", "اتركه وحده نصف دقيقة."),
    "boop.surprise": ("بلوف!", "دع صديقًا يهبط فوقه."),
    "house.pileUp": ("كومة أصدقاء", "ارمِ صديقًا فوق آخر"),
    "house.nuzzle": ("احتضان", "دع الأصدقاء يلعبون جنبًا إلى جنب"),
    "house.spa": ("يوم سبا", "أكمل روتين سبا كاملًا"),
    "house.sleepSounds": ("تهويدة", "شغّل أصوات النوم في غرفة النوم"),
    "house.dressUp": ("تأنّق", "ألبس صديقًا إكسسوارًا"),
    "house.photo": ("ابتسم", "شارك صورة من ركن التصوير"),
    "house.hatch.oink": ("أهلًا بالخنزير الصغير!", "افقس بيضة في الحديقة"),
    "house.hatch.wuff": ("أهلًا بالجرو!", "افقس بيضة في الحديقة"),
    "house.hatch.boop": ("أهلًا ببوب!", "افقس بيضة في الحديقة"),
    "house.favorite.mofu": ("الوجبة المفضّلة!", "اعثر على الوجبة المفضّلة لصديق"),
    "house.favorite.oink": ("الوجبة المفضّلة!", "اعثر على الوجبة المفضّلة لصديق"),
    "house.favorite.wuff": ("الوجبة المفضّلة!", "اعثر على الوجبة المفضّلة لصديق"),
    "house.favorite.boop": ("الوجبة المفضّلة!", "اعثر على الوجبة المفضّلة لصديق"),
}

# --- coat / tint / variant names (character names stay Latin except ja/ar) ---
_BOOP_ID_ORDER = ["mochi", "pip", "bao", "kiwi", "momo", "puff", "nori", "taro", "coco", "jelly", "sprout", "star"]
_BOOP_LATIN = dict(EN_VARIANTS["boop"])
_BOOP_JA = dict(zip(_BOOP_ID_ORDER, ["モチ", "ピップ", "バオ", "キウイ", "モモ", "パフ", "ノリ", "タロ", "ココ", "ジェリー", "スプラウト", "スター"]))
_BOOP_AR = dict(zip(_BOOP_ID_ORDER, ["موتشي", "بيب", "باو", "كيوي", "مومو", "بف", "نوري", "تارو", "كوكو", "جيلي", "سبروت", "ستار"]))

_OINK_ORDER = ["classic", "peach", "spotted", "chocolate", "lavender", "golden", "mint", "snow"]
_WUFF_ORDER = ["golden", "cream", "chocolate", "blackTan", "snow", "corgi", "dalmatian", "husky", "beagle", "cottonCandy"]


def _zip(order: list[str], names: list[str]) -> dict[str, str]:
    assert len(order) == len(names), (order, names)
    return dict(zip(order, names))


V: dict[str, dict[str, dict[str, str]]] = {
    "ja": {
        "oink": _zip(_OINK_ORDER, ["ピンク", "ピーチ", "ぶち", "チョコ", "ラベンダー", "ゴールド", "ミント", "ゆき"]),
        "wuff": _zip(_WUFF_ORDER, ["ゴールデン", "クリーム", "チョコ", "ブラックタン", "ゆき", "コーギー", "ダルメシアン", "ハスキー", "ビーグル", "わたあめ"]),
        "boop": _BOOP_JA,
    },
    "de": {
        "oink": _zip(_OINK_ORDER, ["Klassisch rosa", "Pfirsich", "Gefleckt", "Schokolade", "Lavendel", "Golden", "Minze", "Schnee"]),
        "wuff": _zip(_WUFF_ORDER, ["Golden", "Creme", "Schokolade", "Schwarz-Loh", "Schnee", "Corgi", "Dalmatiner", "Husky", "Beagle", "Zuckerwatte"]),
        "boop": _BOOP_LATIN,
    },
    "pt": {
        "oink": _zip(_OINK_ORDER, ["Rosa clássico", "Pêssego", "Malhado", "Chocolate", "Lavanda", "Dourado", "Menta", "Neve"]),
        "wuff": _zip(_WUFF_ORDER, ["Dourado", "Creme", "Chocolate", "Preto e marrom", "Neve", "Corgi", "Dálmata", "Husky", "Beagle", "Algodão-doce"]),
        "boop": _BOOP_LATIN,
    },
    "es": {
        "oink": _zip(_OINK_ORDER, ["Rosa clásico", "Durazno", "Manchado", "Chocolate", "Lavanda", "Dorado", "Menta", "Nieve"]),
        "wuff": _zip(_WUFF_ORDER, ["Dorado", "Crema", "Chocolate", "Negro y fuego", "Nieve", "Corgi", "Dálmata", "Husky", "Beagle", "Algodón de azúcar"]),
        "boop": _BOOP_LATIN,
    },
    "fr": {
        "oink": _zip(_OINK_ORDER, ["Rose classique", "Pêche", "Tacheté", "Chocolat", "Lavande", "Doré", "Menthe", "Neige"]),
        "wuff": _zip(_WUFF_ORDER, ["Doré", "Crème", "Chocolat", "Noir et feu", "Neige", "Corgi", "Dalmatien", "Husky", "Beagle", "Barbe à papa"]),
        "boop": _BOOP_LATIN,
    },
    "ar": {
        "oink": _zip(_OINK_ORDER, ["وردي كلاسيكي", "خوخي", "منقّط", "شوكولاتة", "لافندر", "ذهبي", "نعناعي", "ثلجي"]),
        "wuff": _zip(_WUFF_ORDER, ["ذهبي", "كريمي", "شوكولاتة", "أسود وبني", "ثلجي", "كورجي", "دالماتي", "هسكي", "بيغل", "غزل البنات"]),
        "boop": _BOOP_AR,
    },
}
V["en"] = EN_VARIANTS

TR: dict[str, dict[str, str]] = {
    "en": EN_TRICKS,
    "ja": _zip(list(EN_TRICKS), ["おすわり", "おて", "くるりん", "ほえる", "ばたんきゅー", "ハイタッチ"]),
    "de": _zip(list(EN_TRICKS), ["Sitz", "Pfötchen", "Drehen", "Sprich", "Totstellen", "High Five"]),
    "pt": _zip(list(EN_TRICKS), ["Sentar", "Patinha", "Girar", "Falar", "Fingir de morto", "Toca aqui"]),
    "es": _zip(list(EN_TRICKS), ["Sentarse", "Pata", "Girar", "Hablar", "Hacerse el muerto", "Choca cinco"]),
    "fr": _zip(list(EN_TRICKS), ["Assis", "Patte", "Tourne", "Parle", "Fais le mort", "Tope là"]),
    "ar": _zip(list(EN_TRICKS), ["اجلس", "صافح", "دُر", "انبح", "تظاهر بالموت", "كفّ بكفّ"]),
}

R["en"] = EN_REACTIONS


# --------------------------------------------------------------------------- #
# Consistency check against the Dart catalogues
# --------------------------------------------------------------------------- #
def _read(rel: str) -> str:
    return (ROOT / rel).read_text(encoding="utf-8")


def _dart_unescape(s: str) -> str:
    return re.sub(r"\\(.)", r"\1", s)


_STR = r"'((?:[^'\\]|\\.)*)'"


def check_against_dart() -> list[str]:
    """Returns a list of problems; empty when everything lines up."""
    problems: list[str] = []
    dart_reactions: dict[str, tuple[str, str]] = {}
    for rel, cls in (
        ("lib/creatures/oink/oink_catalog.dart", "OinkReaction"),
        ("lib/creatures/wuff/wuff_catalog.dart", "WuffReaction"),
        ("lib/creatures/boop/boop_catalog.dart", "BoopReaction"),
    ):
        for m in re.finditer(cls + r"\(\s*" + _STR + r"\s*,\s*" + _STR + r"\s*,\s*" + _STR + r"\s*\)", _read(rel)):
            dart_reactions[_dart_unescape(m[1])] = (_dart_unescape(m[2]), _dart_unescape(m[3]))
    en_catalogue = {k: v for k, v in EN_REACTIONS.items() if not k.startswith("house.")}
    for k in sorted(set(dart_reactions) | set(en_catalogue)):
        if k not in dart_reactions:
            problems.append(f"reaction {k}: in species_text.py but not in Dart")
        elif k not in en_catalogue:
            problems.append(f"reaction {k}: in Dart but missing from species_text.py")
        elif dart_reactions[k] != en_catalogue[k]:
            problems.append(f"reaction {k}: English drifted: Dart {dart_reactions[k]} vs {en_catalogue[k]}")

    oink = {_dart_unescape(m[1]): _dart_unescape(m[2]) for m in re.finditer(r"OinkTint\(" + _STR + r"\s*,\s*" + _STR + r"\)", _read("lib/creatures/oink/oink_catalog.dart"))}
    wuff_src = _read("lib/creatures/wuff/wuff_catalog.dart")
    wuff_ids = [_dart_unescape(m[1]) for m in re.finditer(r"WuffCoat\(\s*id:\s*" + _STR, wuff_src)]
    boop = {_dart_unescape(m[1]): _dart_unescape(m[2]) for m in re.finditer(r"id:\s*" + _STR + r",\s*englishName:\s*" + _STR, _read("lib/creatures/boop/boop_catalog.dart"))}
    tricks = {_dart_unescape(m[1]): _dart_unescape(m[2]) for m in re.finditer(r"WuffTrick\(" + _STR + r"\s*,\s*" + _STR + r"\)", wuff_src)}
    for label, dart_ids, ours in (
        ("oink tint", set(oink), set(EN_VARIANTS["oink"])),
        ("wuff coat", set(wuff_ids), set(EN_VARIANTS["wuff"])),
        ("boop variant", set(boop), set(EN_VARIANTS["boop"])),
        ("wuff trick", set(tricks), set(EN_TRICKS)),
    ):
        if dart_ids != ours:
            problems.append(f"{label}: Dart-only {sorted(dart_ids - ours)}, python-only {sorted(ours - dart_ids)}")
    for k, v in oink.items():
        if EN_VARIANTS["oink"].get(k) != v:
            problems.append(f"oink tint {k}: English drifted ({v!r})")
    for k, v in boop.items():
        if EN_VARIANTS["boop"].get(k) != v:
            problems.append(f"boop variant {k}: English drifted ({v!r})")
    for k, v in tricks.items():
        if EN_TRICKS.get(k) != v:
            problems.append(f"wuff trick {k}: English drifted ({v!r})")

    # Every language must carry exactly the same ids as English.
    for lang in LANGS:
        if set(R[lang]) != set(EN_REACTIONS):
            problems.append(f"{lang}: reaction ids differ: missing {sorted(set(EN_REACTIONS) - set(R[lang]))}, stale {sorted(set(R[lang]) - set(EN_REACTIONS))}")
        for sp in EN_VARIANTS:
            if set(V[lang].get(sp, {})) != set(EN_VARIANTS[sp]):
                problems.append(f"{lang}: {sp} variants differ")
        if set(TR[lang]) != set(EN_TRICKS):
            problems.append(f"{lang}: tricks differ")
        # No emoji in any string.
        emoji = re.compile("[\U0001F300-\U0001FAFF☀-➿]")
        for k, (n, h) in R[lang].items():
            if emoji.search(n) or emoji.search(h):
                problems.append(f"{lang}: emoji in {k}")
        # Consistent end punctuation with English (hints: full stop or none).
        for k, (_, h) in R[lang].items():
            en_dot = EN_REACTIONS[k][1].endswith(".")
            if lang == "ja":
                ok = h.endswith("。") == en_dot
            else:
                ok = h.endswith(".") == en_dot
            if not ok:
                problems.append(f"{lang}: hint punctuation differs from English for {k}: {h!r}")
    # The trick reaction names double as the trick names: keep them identical.
    for lang in LANGS:
        for tid, name in TR[lang].items():
            if R[lang][f"wuff.trick.{tid}"][0] != name:
                problems.append(f"{lang}: trick {tid} name differs from wuff.trick.{tid}")
    return problems


# --------------------------------------------------------------------------- #
# Dart emitter
# --------------------------------------------------------------------------- #
def _q(s: str) -> str:
    return "'" + s.replace("\\", "\\\\").replace("'", "\\'").replace("$", "\\$") + "'"


def generate() -> str:
    out: list[str] = []
    w = out.append
    w("// GENERATED by tools/l10n/species_text.py - do not hand-edit.")
    w("// ignore_for_file: lines_longer_than_80_chars")
    w("")
    w("/// GENERATED by tools/l10n/species_text.py — do not hand-edit.")
    w("///")
    w("/// Localised names and hints for the Oink / Wuff / Boop journal, their coats")
    w("/// and the house-wide reactions. English is always present, and unknown")
    w("/// language codes fall back to it.")
    w("library;")
    w("")
    w("const _fallback = 'en';")
    w("")
    w("/// (name, hint) for a reaction id like 'oink.snout', 'house.pileUp'; null when unknown.")
    w("(String, String)? speciesReaction(String languageCode, String id) =>")
    w("    (_reactions[languageCode] ?? _reactions[_fallback]!)[id] ?? _reactions[_fallback]![id];")
    w("")
    w("/// Display name of a coat/tint/variant: speciesVariant('ja', 'wuff', 'blackTan').")
    w("String? speciesVariant(String languageCode, String species, String id) =>")
    w("    (_variants[languageCode] ?? _variants[_fallback]!)[species]?[id] ?? _variants[_fallback]![species]?[id];")
    w("")
    w("/// Trick name: speciesTrick('de', 'playDead').")
    w("String? speciesTrick(String languageCode, String id) =>")
    w("    (_tricks[languageCode] ?? _tricks[_fallback]!)[id] ?? _tricks[_fallback]![id];")
    w("")
    w("const _reactions = <String, Map<String, (String, String)>>{")
    for lang in LANGS:
        w(f"  {_q(lang)}: {{")
        for k, (n, h) in R[lang].items():
            w(f"    {_q(k)}: ({_q(n)}, {_q(h)}),")
        w("  },")
    w("};")
    w("")
    w("const _variants = <String, Map<String, Map<String, String>>>{")
    for lang in LANGS:
        w(f"  {_q(lang)}: {{")
        for sp, table in V[lang].items():
            w(f"    {_q(sp)}: {{")
            for k, n in table.items():
                w(f"      {_q(k)}: {_q(n)},")
            w("    },")
        w("  },")
    w("};")
    w("")
    w("const _tricks = <String, Map<String, String>>{")
    for lang in LANGS:
        w(f"  {_q(lang)}: {{")
        for k, n in TR[lang].items():
            w(f"    {_q(k)}: {_q(n)},")
        w("  },")
    w("};")
    w("")
    return "\n".join(out)


def main() -> int:
    problems = check_against_dart()
    if problems:
        print("species_text.py is out of sync:")
        for p in problems:
            print("  -", p)
        return 1
    OUT.write_text(generate(), encoding="utf-8", newline="\n")
    n_r = len(EN_REACTIONS)
    print(f"{OUT.relative_to(ROOT)}: {len(LANGS)} languages, {n_r} reactions, "
          f"{sum(len(v) for v in EN_VARIANTS.values())} variants, {len(EN_TRICKS)} tricks")
    return 0


if __name__ == "__main__":
    sys.exit(main())
