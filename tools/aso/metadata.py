"""App Store metadata for Mofu & Friends (flagship) -> ASO/metadata.json + ASO/ASO.md.

    python tools/aso/metadata.py

Sources: names/subtitles/keywords below (measured with applyra 2026-10-17, see
research/niche-research/niche-scout/history/2026-10-17_mofu-flagship-aso.md and
2026-10-06_mofu-aso.md), the English description in desc_en.txt and the six
translations in desc_i18n.json. Rules enforced here (UTF-16 lengths, like the store):
  title <= 30, subtitle <= 30, keywords <= 100, promo <= 170, description <= 4000;
  no keyword repeated from the same locale's title/subtitle; no competitor brand;
  no feature the app does not have (no "widget"; Apple 2.3.7).
"""
from __future__ import annotations

import json
import pathlib
import sys

ROOT = pathlib.Path(__file__).resolve().parents[2]
HERE = pathlib.Path(__file__).resolve().parent

DESC_EN = (HERE / "desc_en.txt").read_text(encoding="utf-8").strip()
I18N = json.loads((HERE / "desc_i18n.json").read_text(encoding="utf-8"))
PROMO_EN = ("Pet, bathe, feed and tuck in a cozy house of cute friends. ASMR spa days, sleep sounds, "
            "mini-games and new friends to hatch. Free, no ads.")

# locale: (name, subtitle, keywords). Why each word: see the history file above.
LISTING = {
    "en-US": ("Mofu: Cute Pet House", "Care Game, ASMR Spa & Sleep",
              "puppy,bunny,pig,dog,kawaii,virtual,fluffy,squishy,dress,salon,bath,sounds,cozy,friends,mofumofu,egg"),
    "en-GB": ("Mofu: Cute Pet House", "Care Game, ASMR Spa & Sleep",
              "puppy,bunny,pig,dog,kawaii,virtual,fluffy,squishy,dress,salon,bath,sounds,cosy,friends,mofumofu,egg"),
    "ja": ("Mofu: もふもふペットのおうち", "癒しのお世話ゲームとASMRスパ",
           "ふわふわ,かわいい,育成,わんちゃん,子犬,ぶた,うさぎ,睡眠音,着せ替え,たまご,ミニゲーム,ぬいぐるみ,スクイーズ,ほっこり,おやつ,なでなで,ぷにぷに,もちもち,寝かしつけ,お風呂"),
    "de-DE": ("Mofu: Niedliche Haustiere", "Tierpflege, ASMR-Spa & Schlaf",
              "kawaii,flauschig,virtuelles,süß,welpe,hund,schwein,hase,anziehen,spiel,schlüpfen,minispiele,mofumofu"),
    "pt-BR": ("Mofu: Casinha de Pets Fofos", "Cuidar de bichinho virtual",
              "kawaii,spa,asmr,dormir,sons,cachorrinho,porquinho,coelho,vestir,ovo,minijogos,relaxar,mofumofu,banho"),
    "es-MX": ("Mofu: Casita de Mascotas", "Cuidar mascotas, spa y ASMR",
              "virtual,tierna,kawaii,perrito,cerdito,conejito,vestir,huevo,minijuegos,dormir,sonidos,mofumofu,baño"),
    "fr-FR": ("Mofu: Animaux Mignons", "Maison cosy, spa ASMR & dodo",
              "virtuel,kawaii,chiot,cochon,lapin,soin,habiller,oeuf,minijeux,dormir,sons,relaxant,mofumofu,jeu,bain"),
    "ar-SA": ("Mofu: بيت الحيوانات اللطيفة", "سبا ASMR وأصوات نوم هادئة",
              "pet,cute,kawaii,virtual,fluffy,house,حيوان,أليف,جرو,خنزير,أرنب,تلبيس,بيضة,ألعاب,عناية,mofumofu"),
}

LOCALES: dict[str, dict[str, str]] = {}
for loc, (title, subtitle, keywords) in LISTING.items():
    if loc.startswith("en"):
        promo, desc = PROMO_EN, DESC_EN
        if loc == "en-US":
            desc = desc.replace("colours", "colors").replace("favourite", "favorite")
        else:
            promo, desc = promo.replace("cozy", "cosy"), desc.replace("cozy", "cosy").replace("Cozy", "Cosy").replace("COZY", "COSY")
    else:
        promo, desc = I18N[loc]["promo"], I18N[loc]["description"].strip()
    LOCALES[loc] = {"title": title, "subtitle": subtitle, "keywords": keywords, "promo": promo, "description": desc}

CATEGORY = {"primary": "ENTERTAINMENT", "secondary": "LIFESTYLE", "ageRating": "4+"}
URLS = {
    "privacy": "https://github.com/OuadieZerhouni/app-configs/blob/main/mofu-pet/PRIVACY.md",
    "support": "https://github.com/OuadieZerhouni/app-configs/blob/main/mofu-pet/SUPPORT.md",
}
LIMITS = {"title": 30, "subtitle": 30, "keywords": 100, "promo": 170, "description": 4000}


def u16(s: str) -> int:
    return len(s.encode("utf-16-le")) // 2


def check() -> list[str]:
    problems = []
    for loc, m in LOCALES.items():
        for k, n in LIMITS.items():
            if u16(m[k]) > n:
                problems.append(f"{loc}.{k}: {u16(m[k])} > {n}")
        raw = m["keywords"].split(",")
        kws = [k.strip().lower() for k in raw]
        if any(k != k.strip() for k in raw):
            problems.append(f"{loc}: spaces around commas waste keyword characters")
        if len(set(kws)) != len(kws):
            problems.append(f"{loc}: duplicate keywords")
        visible = (m["title"] + " " + m["subtitle"]).lower().replace(",", " ").replace(":", " ").split()
        for k in kws:
            if k and all(w in visible for w in k.split()):
                problems.append(f"{loc}: keyword '{k}' repeats the title/subtitle")
        for banned in ["widget", "ウィジェット", "tamagotchi", "たまごっち", "pou", "ouo", "widgetable"]:
            if banned in m["keywords"].lower():
                problems.append(f"{loc}: '{banned}' not allowed in keywords")
    return problems


def markdown() -> str:
    out = [
        "# Mofu & Friends — App Store metadata (2026-10-17)",
        "",
        "Status: ready to paste; native review recommended (GATE-L10N-REVIEW) · Source: `tools/aso/metadata.py` "
        "(do not edit this file by hand) · Research: `niche-scout/history/2026-10-17_mofu-flagship-aso.md`",
        "",
        "## Summary",
        f"Primary category **{CATEGORY['primary'].title()}** · secondary **{CATEGORY['secondary'].title()}** · "
        f"age **{CATEGORY['ageRating']}** · Free, no in-app purchases · App Privacy: **Data Not Collected**",
        "",
        "Store name `Mofu: Cute Pet House` keeps the measured token `mofu` (US T84/D21) first and adds `pet house` "
        "(US T61/D52). `pet care game` (T41) is formed by title `pet` + subtitle `care game`; `sleep sounds` by "
        "subtitle `sleep` + keyword `sounds`. All T/D are applyra estimates — ASA is the final check.",
        "",
        f"Privacy URL: {URLS['privacy']}  ",
        f"Support URL: {URLS['support']}",
        "",
    ]
    for loc, m in LOCALES.items():
        out += [
            f"## {loc}",
            "",
            "| Field | Value | Length |",
            "| --- | --- | --- |",
            f"| Name | {m['title']} | {u16(m['title'])}/30 |",
            f"| Subtitle | {m['subtitle']} | {u16(m['subtitle'])}/30 |",
            f"| Keywords | `{m['keywords']}` | {u16(m['keywords'])}/100 |",
            f"| Promotional text | {m['promo']} | {u16(m['promo'])}/170 |",
            "",
            f"Description ({u16(m['description'])}/4000):",
            "",
            "```",
            m["description"],
            "```",
            "",
        ]
    out += [
        "## Screenshots",
        "`ASO/screenshots/<locale>/01_house … 07_games.png` (1320×2868, 6.9\" slot). Captions: "
        "`tools/screenshots/captions.json`.",
        "",
        "## Tracking list (add to applyra after release)",
        "| keyword | market | T | D |",
        "| --- | --- | --- | --- |",
        "| mofu | US/GB/DE/MX/BR | 79–84 | 21–25 |",
        "| pet house | US | 61 | 52 |",
        "| cute puppy | US | 54 | 51 |",
        "| pet care game | US | 41 | 60 |",
        "| お世話ゲーム | JP | 79 | 45 |",
        "| 癒しペット | JP | 68 | 32 |",
        "| cuidar de pet | BR | 63 | 34 |",
        "| cuidar mascotas | MX | 58 | 37 |",
        "",
        "## What Ouadie must verify",
        "- ASA popularity for the tracking list (GATE-ASA)",
        "- Native read of ja and ar-SA, then de/pt/es/fr (GATE-L10N-REVIEW)",
        "- ASC accepts the name `Mofu: Cute Pet House` (fallback `Mofu: Cute Pet Home`)",
        "",
    ]
    return "\n".join(out)


def main() -> int:
    sys.stdout.reconfigure(encoding="utf-8")
    problems = check()
    for p in problems:
        print("PROBLEM", p)
    out = {"category": CATEGORY, "urls": URLS, "locales": LOCALES}
    (ROOT / "ASO").mkdir(exist_ok=True)
    (ROOT / "ASO" / "metadata.json").write_text(json.dumps(out, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    (ROOT / "ASO" / "ASO.md").write_text(markdown(), encoding="utf-8")
    for loc, m in LOCALES.items():
        print(f"{loc:6s} title {u16(m['title']):2d}  sub {u16(m['subtitle']):2d}  kw {u16(m['keywords']):3d}  "
              f"promo {u16(m['promo']):3d}  desc {u16(m['description']):4d}")
    return 1 if problems else 0


if __name__ == "__main__":
    sys.exit(main())
