"""App Store metadata for Mofu v1.0 → ASO/metadata.json, with limit checks.

    python tools/aso/metadata.py

Keyword research: research/niche-research/niche-scout/history/2026-10-06_mofu-aso.md
(applyra, measured 2026-10-06). Rules enforced here:
  title ≤ 30, subtitle ≤ 30, keywords ≤ 100 bytes-ish chars, promo ≤ 170,
  description ≤ 4000; no keyword repeated from the same locale's title/subtitle;
  no feature the app does not have (no "widget" — v1 has none; Apple 2.3.7);
  no competitor brand names.
"""
from __future__ import annotations

import json
import pathlib
import sys

ROOT = pathlib.Path(__file__).resolve().parents[2]

DESC_EN = """Meet Mofu — a round, ultra-fluffy little creature that lives on your iPhone.

Tap it and it boings. Stroke its fur and it closes its eyes and purrs. Press and hold for a mochi squish, hold a little longer for a big hug. Pick it up, toss it, and watch it bounce. Shake your phone and its fur goes everywhere — then brush it smooth again.

MAKE IT FLUFFIER
Every pet and every brush makes Mofu fluffier. Watch its fur grow from a tiny puff into a magnificent cloud — and celebrate every milestone together. Fluff never goes down, so there is no pressure and nothing to lose.

SHARE A SNACK
Strawberries, dango, cookies, onigiri, pudding and candy. Every Mofu has a secret favourite — find out which one makes yours the happiest.

DRESS IT UP
Collect 10 fur colours and a wardrobe of tiny accessories: a bow, a sprout, a beanie, headphones, a crown and more. Everything is free to earn by playing.

FILL THE JOURNAL
Mofu hides 24 reactions — tickle fits, sleepy yawns, dizzy spins and more. Some you'll find in seconds, others take curiosity.

DAY AND NIGHT
Mofu's room follows your clock. At night it gets sleepy, dozes off and snores softly until you wake it with a gentle tap.

Cozy, soft and calm. No ads, no purchases, no account, and nothing collected. Just a fluffy friend that is happy to see you."""

LOCALES: dict[str, dict[str, str]] = {
    "en-US": {
        "title": "Mofu: Fluffy Pet",
        "subtitle": "Cute Squishy Cozy Kawaii Pal",
        "keywords": "virtual,game,relax,stress,relief,plush,fluff,blob,creature,pocket,comfort,mofumofu,boop,soft,toy",
        "promo": "Meet Mofu, a pocket-sized cloud of fluff. Brush it, boop it, squish it and listen to it purr. Collect fur colors and tiny accessories. Free, no ads.",
        "description": DESC_EN.replace("colours", "colors").replace("favourite", "favorite"),
    },
    "en-GB": {
        "title": "Mofu: Fluffy Pet",
        "subtitle": "Cute Cuddly Kawaii Soft Friend",
        "keywords": "virtual,game,relax,stress,relief,toy,plush,fluff,blob,pocket,comfort,squishy,cosy,boop,creature",
        "promo": "Meet Mofu, a pocket-sized cloud of fluff. Stroke it, boop it, squish it and hear it purr. Collect fur colours and tiny accessories. Free, no ads.",
        "description": DESC_EN.replace("Cozy", "Cosy"),
    },
    "ja": {
        "title": "Mofu：もふもふペット",
        "subtitle": "癒しのかわいい育成ゲーム",
        "keywords": "ふわふわ,ふわもこ,ぬいぐるみ,スクイーズ,ストレス解消,ペットゲーム,マスコット,タップ,なでなで,ブラシ,着せ替え,ゆるい,おやつ,図鑑,暇つぶし,ほっこり,毛玉,ぷにぷに,もちもち,ほのぼの",
        "promo": "ふわふわの丸い生きもの「Mofu」があなたの画面にやってきました。なでる、つつく、ぷにぷに、くすぐる。毛色やアクセサリーを集めて、ひみつのリアクションを見つけよう。広告なし。",
        "description": """まんまるで、もふもふの小さな生きもの「Mofu」が、あなたのiPhoneにすみつきました。

タップすると、ぽよん。毛並みをなでると、目を細めてごろごろ。長押しでもちもち、もう少し押すとぎゅー。つかんで投げれば、ぽよよんと跳ねます。スマホをふると毛がボサボサに — ブラシでさらさらに戻してあげてね。

もっと、もふもふに
なでるたび、ブラッシングするたびに、Mofuはどんどんもふもふに。小さな毛玉から、ふわふわの雲みたいに育っていきます。もふもふは減らないので、のんびり遊べます。

おやつをあげよう
いちご、だんご、クッキー、おにぎり、プリン、キャンディ。Mofuにはそれぞれ大好物があります。

きせかえ
10色の毛いろと、リボン・ふたば・ニット帽・ヘッドホン・王冠などのアクセサリー。すべて遊んで手に入ります。

ずかんをうめよう
くすぐったい、おねむ、くるくる…24このリアクションがかくれています。

昼と夜
お部屋は時計に合わせて変わります。夜になると、Mofuはうとうと眠りにつきます。

広告なし・課金なし・アカウント不要・データ収集なし。あなたに会えるのを楽しみにしている、もふもふの友だちです。""",
    },
    "de-DE": {
        "title": "Mofu: Flauschiges Haustier",
        "subtitle": "Niedlicher Kawaii Begleiter",
        "keywords": "virtuelles,spiel,entspannen,stressabbau,plüsch,knuddeln,streicheln,kuschelig,flausch,bürsten,tier",
        "promo": "Triff Mofu, eine kleine Wolke aus Fell. Streicheln, bürsten, drücken und dem Schnurren lauschen. Sammle Fellfarben und winzige Accessoires. Kostenlos, ohne Werbung.",
        "description": """Triff Mofu – ein rundes, superflauschiges kleines Wesen, das auf deinem iPhone wohnt.

Tippe es an und es macht boing. Streichle sein Fell und es schließt die Augen und schnurrt. Drücke und halte für einen Mochi-Knautsch, halte länger für eine große Umarmung. Heb es hoch, wirf es und sieh zu, wie es hüpft. Schüttle dein Handy – dann bürste das zerzauste Fell wieder glatt.

NOCH FLAUSCHIGER
Jedes Streicheln und Bürsten macht Mofu flauschiger – vom winzigen Puschel zur prächtigen Wolke. Der Flausch geht nie verloren, also kein Druck.

SNACKS TEILEN
Erdbeeren, Dango, Kekse, Onigiri, Pudding und Bonbons. Jedes Mofu hat einen geheimen Lieblingssnack.

OUTFITS
10 Fellfarben und winzige Accessoires: Schleife, Sprössling, Mütze, Kopfhörer, Krone und mehr. Alles kostenlos erspielbar.

DAS ALBUM FÜLLEN
24 versteckte Reaktionen warten: Kicheranfälle, Gähnen, Schwindel-Drehungen und mehr.

TAG UND NACHT
Mofus Zimmer folgt deiner Uhrzeit. Nachts wird es müde und schnarcht leise.

Ohne Werbung, ohne Käufe, ohne Konto, keine Daten. Nur ein flauschiger Freund, der sich freut, dich zu sehen.""",
    },
    "pt-BR": {
        "title": "Mofu: Bichinho Virtual Fofo",
        "subtitle": "Pet kawaii peludo e macio",
        "keywords": "fofura,fofinho,pelúcia,relaxar,estresse,jogo,amigo,tela,cuidar,apertar,acariciar,escovar,mascote",
        "promo": "Conheça o Mofu, uma nuvem de pelos do tamanho do bolso. Faça carinho, escove, aperte e ouça o ronronar. Colecione cores de pelo e acessórios. Grátis, sem anúncios.",
        "description": """Conheça o Mofu — uma criaturinha redonda e superfofinha que mora no seu iPhone.

Toque e ele faz boing. Acaricie o pelo e ele fecha os olhinhos e ronrona. Segure para um apertinho de mochi, segure mais um pouco para um abraço. Pegue, jogue e veja quicar. Sacuda o celular e o pelo fica todo bagunçado — depois é só escovar.

CADA VEZ MAIS FOFINHO
Cada carinho e cada escovada deixam o Mofu mais fofinho, de um pompom pequenininho até uma nuvem enorme. A fofura nunca diminui: sem pressão.

DIVIDA UM LANCHE
Morango, dango, biscoito, onigiri, pudim e bala. Todo Mofu tem um lanche favorito secreto.

VISUAL
10 cores de pelo e acessórios: laço, brotinho, gorro, fones, coroa e mais. Tudo grátis jogando.

COMPLETE O DIÁRIO
24 reações escondidas: crises de cócegas, bocejos, giros tontos e muito mais.

DIA E NOITE
O quarto do Mofu segue o seu relógio. À noite ele fica com sono e ronca baixinho.

Sem anúncios, sem compras, sem conta e sem coleta de dados. Só um amigo fofinho feliz em ver você.""",
    },
    "es-MX": {
        "title": "Mofu: Mascota Esponjosa",
        "subtitle": "Tierna mascota virtual kawaii",
        "keywords": "peluche,suave,relajante,antiestrés,juego,pantalla,acariciar,cepillar,fluffy,cute,pet,plush,amigo",
        "promo": "Conoce a Mofu, una nube de pelo para tu bolsillo. Acarícialo, cepíllalo, apriétalo y escucha su ronroneo. Colecciona colores de pelo y accesorios. Gratis, sin anuncios.",
        "description": """Conoce a Mofu: una criaturita redonda y súper esponjosa que vive en tu iPhone.

Tócalo y hace boing. Acaricia su pelo y cierra los ojos y ronronea. Mantén pulsado para un apretón de mochi, un poco más para un gran abrazo. Levántalo, lánzalo y mira cómo rebota. Agita el teléfono y se le alborota el pelo; luego cepíllalo.

MÁS Y MÁS ESPONJOSO
Cada caricia y cada cepillado lo hacen más esponjoso, de una pequeña pelusa a una nube enorme. La esponjosidad nunca baja: sin presión.

COMPARTE UN SNACK
Fresas, dango, galletas, onigiri, flan y caramelos. Cada Mofu tiene un snack favorito secreto.

ESTILO
10 colores de pelo y accesorios: lazo, brote, gorro, audífonos, corona y más. Todo gratis jugando.

LLENA EL DIARIO
24 reacciones escondidas: ataques de risa, bostezos, vueltas mareadas y más.

DÍA Y NOCHE
El cuarto de Mofu sigue tu reloj. De noche le da sueño y ronca bajito.

Sin anuncios, sin compras, sin cuenta y sin recopilar datos. Solo un amigo esponjoso feliz de verte.""",
    },
    "fr-FR": {
        "title": "Mofu : Animal Tout Doux",
        "subtitle": "Compagnon kawaii et câlin",
        "keywords": "virtuel,jeu,relaxant,anti-stress,peluche,moelleux,mignon,caresser,brosser,boule,poils,douceur",
        "promo": "Voici Mofu, un petit nuage de poils à emporter partout. Caresse-le, brosse-le, écrase-le et écoute-le ronronner. Collectionne pelages et accessoires. Gratuit, sans pub.",
        "description": """Voici Mofu, une petite créature toute ronde et ultra moelleuse qui vit dans ton iPhone.

Touche-le et il fait boing. Caresse son pelage : il ferme les yeux et ronronne. Appuie longuement pour un écrasé de mochi, encore un peu pour un gros câlin. Attrape-le, lance-le et regarde-le rebondir. Secoue ton téléphone et ses poils s'ébouriffent — brosse-le pour les lisser.

TOUJOURS PLUS MOELLEUX
Chaque caresse et chaque coup de brosse le rendent plus moelleux, du petit pompon au nuage géant. Le moelleux ne baisse jamais : aucune pression.

PARTAGE UN GOÛTER
Fraise, dango, cookie, onigiri, flan et bonbon. Chaque Mofu a son goûter préféré secret.

LOOKS
10 pelages et des accessoires : nœud, pousse, bonnet, casque, couronne et plus. Tout se gagne gratuitement.

REMPLIS LE JOURNAL
24 réactions cachées : fous rires, bâillements, tourbillons étourdis et plus encore.

JOUR ET NUIT
La chambre de Mofu suit ton horloge. La nuit, il s'endort et ronfle doucement.

Sans pub, sans achat, sans compte, aucune donnée collectée. Juste un ami tout doux, heureux de te voir.""",
    },
    "ar-SA": {
        "title": "Mofu: Fluffy Cute Pet",
        "subtitle": "حيوان أليف فروي ولطيف لشاشتك",
        "keywords": "kawaii,virtual,game,squishy,plush,relax,screen,تسلية,ألعاب,استرخاء,ناعم,كائن,رقيق,حيوانات,موفو",
        "promo": "تعرّف على موفو، كتلة صغيرة من الفرو تعيش على شاشتك. دلّعه ومشّطه واضغطه واستمع لخرخرته. اجمع ألوان الفرو والإكسسوارات. مجاني وبدون إعلانات.",
        "description": """تعرّف على موفو — مخلوق صغير مستدير ومنفوش جدًا يعيش في جوالك.

انقره فيقفز "بوينغ". مرّر يدك على فروه فيغمض عينيه ويخرخر. اضغط مطوّلًا لعصرة موتشي، وأطِل قليلًا لحضن كبير. امسكه وارمه وشاهده يرتد. هزّ جوالك فينكش فروه — ثم مشّطه ليعود ناعمًا.

أكثر نفشًا
كل تدليل وكل تمشيط يجعل موفو أكثر نفشًا، من كرة صغيرة إلى غيمة كبيرة. النفش لا ينقص أبدًا، فلا ضغط ولا خسارة.

شاركه وجبة
فراولة ودانغو وكوكيز وأونيغيري وبودينغ وحلوى. لكل موفو وجبة مفضّلة سرية.

ملابس وإكسسوارات
10 ألوان فرو وإكسسوارات صغيرة: فيونكة ونبتة وطاقية وسماعات وتاج وغيرها. كلها مجانية باللعب.

املأ الدفتر
24 ردة فعل مخفية: نوبات ضحك وتثاؤب ودوخة وأكثر.

ليل ونهار
غرفة موفو تتبع ساعتك. في الليل ينعس وينام ويشخر بهدوء.

بدون إعلانات، بدون مشتريات، بدون حساب، ولا نجمع أي بيانات. فقط صديق منفوش سعيد برؤيتك.""",
    },
}

CATEGORY = {"primary": "ENTERTAINMENT", "secondary": "LIFESTYLE", "ageRating": "4+"}
URLS = {
    "privacy": "https://github.com/OuadieZerhouni/app-configs/blob/main/mofu-pet/PRIVACY.md",
    "support": "https://github.com/OuadieZerhouni/app-configs/blob/main/mofu-pet/SUPPORT.md",
}


def check() -> list[str]:
    problems = []
    for loc, m in LOCALES.items():
        lim = {"title": 30, "subtitle": 30, "keywords": 100, "promo": 170, "description": 4000}
        for k, n in lim.items():
            if len(m[k]) > n:
                problems.append(f"{loc}.{k}: {len(m[k])} > {n}")
        kws = [k.strip().lower() for k in m["keywords"].split(",")]
        if any(" " in k.strip() and k != k.strip() for k in m["keywords"].split(",")):
            problems.append(f"{loc}: spaces around commas waste keyword characters")
        if len(set(kws)) != len(kws):
            problems.append(f"{loc}: duplicate keywords")
        visible = (m["title"] + " " + m["subtitle"]).lower()
        for k in kws:
            if k and all(w in visible.split() for w in k.split()):
                problems.append(f"{loc}: keyword '{k}' repeats the title/subtitle")
        for banned in ["widget", "ウィジェット", "tamagotchi", "pou", "ouo"]:
            if banned in m["keywords"].lower():
                problems.append(f"{loc}: '{banned}' not allowed in keywords")
    return problems


def main() -> int:
    problems = check()
    for p in problems:
        print("PROBLEM", p)
    out = {"category": CATEGORY, "urls": URLS, "locales": LOCALES}
    (ROOT / "ASO").mkdir(exist_ok=True)
    (ROOT / "ASO" / "metadata.json").write_text(json.dumps(out, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    for loc, m in LOCALES.items():
        print(f"{loc:6s} title {len(m['title']):2d}  sub {len(m['subtitle']):2d}  kw {len(m['keywords']):3d}  promo {len(m['promo']):3d}  desc {len(m['description']):4d}")
    return 1 if problems else 0


if __name__ == "__main__":
    sys.exit(main())
