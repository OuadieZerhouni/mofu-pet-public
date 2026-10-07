"""Compose captioned App Store screenshots from the test-rendered raws.

    flutter test test/store_screenshots_test.dart --run-skipped
    python tools/screenshots/compose.py

Input:  build/screenshots/raw/<lang>/<scene>.png   (1320x2868, real app frames)
Output: ASO/screenshots/<store-locale>/<nn>_<scene>.png (1320x2868, 6.9" iPhone)
        ASO/screenshots/contact_sheet.png           (all locales, for review)

App Store Connect only requires the 6.9" set; it scales it for smaller iPhones.
Every output is verified to be exactly 1320x2868 RGB (no alpha: ASC rejects it).
"""
from __future__ import annotations

import json
import sys
from pathlib import Path

from PIL import Image, ImageDraw, ImageFilter

ROOT = Path(__file__).resolve().parents[2]
RAW = ROOT / "build" / "screenshots" / "raw"
OUT = ROOT / "ASO" / "screenshots"
W, H = 1320, 2868

SCENES = ["1_hero", "2_brush", "3_snacks", "4_play", "5_wardrobe", "6_night"]

# Background gradient (top, bottom) per scene, sampled from the room palettes.
BG = {
    "1_hero": ((255, 236, 222), (255, 204, 218)),
    "2_brush": ((224, 246, 236), (206, 228, 255)),
    "3_snacks": ((255, 244, 214), (255, 222, 230)),
    "4_play": ((238, 228, 255), (255, 214, 234)),
    "5_wardrobe": ((244, 232, 255), (255, 226, 240)),
    "6_night": ((62, 50, 112), (28, 22, 64)),
}

# Captions live in captions.json, shared with the Flutter test that renders
# them (Flutter shapes Arabic with HarfBuzz and uses the app's own fonts;
# Pillow without libraqm cannot join Arabic letters).
CAPTIONS: dict[str, list[str]] = json.loads((Path(__file__).with_name("captions.json")).read_text("utf-8"))["captions"]

# App Store locale -> rendered app language.
STORE_LOCALES = {
    "en-US": "en",
    "en-GB": "en",
    "ja": "ja",
    "de-DE": "de",
    "pt-BR": "pt",
    "es-MX": "es",
    "fr-FR": "fr",
    "ar-SA": "ar",
}

def gradient(top, bottom) -> Image.Image:
    g = Image.new("RGB", (1, H))
    for y in range(H):
        t = y / (H - 1)
        g.putpixel((0, y), tuple(round(a + (b - a) * t) for a, b in zip(top, bottom)))
    return g.resize((W, H))


def caption(img: Image.Image, lang: str, idx: int) -> None:
    """Paste the Flutter-rendered caption (transparent PNG) centred in the header band."""
    cap = Image.open(RAW / lang / f"caption_{idx + 1}.png").convert("RGBA")
    if cap.width > W - 120:
        cap = cap.resize((W - 120, round(cap.height * (W - 120) / cap.width)), Image.LANCZOS)
    img.paste(cap, ((W - cap.width) // 2, round(300 - cap.height / 2)), cap)


def frame(shot: Image.Image, dark: bool) -> Image.Image:
    """Scale the app frame down, round it like a phone screen, add a soft shadow."""
    top, bottom = 590, 70
    h = H - top - bottom
    w = round(shot.width * h / shot.height)
    s = shot.convert("RGB").resize((w, h), Image.LANCZOS)
    radius = 96
    mask = Image.new("L", (w, h), 0)
    ImageDraw.Draw(mask).rounded_rectangle((0, 0, w - 1, h - 1), radius, fill=255)
    bezel = 16
    canvas = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    x, y = (W - w) // 2, top
    shadow = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    ImageDraw.Draw(shadow).rounded_rectangle(
        (x - bezel, y - bezel + 24, x + w + bezel, y + h + bezel + 24), radius + bezel,
        fill=(20, 10, 40, 110 if dark else 60))
    canvas = Image.alpha_composite(canvas, shadow.filter(ImageFilter.GaussianBlur(34)))
    ImageDraw.Draw(canvas).rounded_rectangle(
        (x - bezel, y - bezel, x + w + bezel, y + h + bezel), radius + bezel,
        fill=(255, 255, 255, 255) if not dark else (236, 230, 255, 255))
    canvas.paste(s, (x, y), mask)
    return canvas


def compose(lang: str, idx: int, scene: str) -> Image.Image:
    dark = scene == "6_night"
    img = gradient(*BG[scene])
    caption(img, lang, idx)
    shot = Image.open(RAW / lang / f"{scene}.png")
    out = Image.alpha_composite(img.convert("RGBA"), frame(shot, dark)).convert("RGB")
    return out


def main() -> int:
    missing = [p for lang in set(STORE_LOCALES.values()) for s in SCENES + [f"caption_{i + 1}" for i in range(len(SCENES))]
               if not (p := RAW / lang / f"{s}.png").exists()]
    if missing:
        print(f"missing raws ({len(missing)}), run the screenshot test first: {missing[0]}")
        return 1
    rendered: dict[str, list[Image.Image]] = {}
    for loc, lang in STORE_LOCALES.items():
        d = OUT / loc
        d.mkdir(parents=True, exist_ok=True)
        imgs = rendered.setdefault(lang, [compose(lang, i, s) for i, s in enumerate(SCENES)])
        for i, (s, img) in enumerate(zip(SCENES, imgs)):
            p = d / f"{i + 1:02d}_{s.split('_', 1)[1]}.png"
            img.save(p, optimize=True)
            chk = Image.open(p)
            assert chk.size == (W, H) and chk.mode == "RGB", (p, chk.size, chk.mode)
    # Contact sheet: one row per language.
    tw, th = 220, 478
    langs = list(rendered)
    sheet = Image.new("RGB", (tw * len(SCENES) + 10 * (len(SCENES) - 1), th * len(langs) + 10 * (len(langs) - 1)), "white")
    for r, lang in enumerate(langs):
        for c, img in enumerate(rendered[lang]):
            sheet.paste(img.resize((tw, th), Image.LANCZOS), (c * (tw + 10), r * (th + 10)))
    sheet.save(OUT / "contact_sheet.png")
    print(f"ok: {len(STORE_LOCALES)} locales x {len(SCENES)} screenshots at {W}x{H} -> {OUT}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
