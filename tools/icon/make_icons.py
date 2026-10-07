"""Builds every iOS AppIcon size from build/icon/icon_1024.png.

    flutter test test/icon_render_test.dart --run-skipped
    python tools/icon/make_icons.py

Reads Contents.json so the file list can never drift from what Xcode expects,
and flattens alpha (App Store Connect rejects an icon with transparency).
"""
import json
import pathlib

from PIL import Image

ROOT = pathlib.Path(__file__).resolve().parents[2]
SRC = ROOT / "build" / "icon" / "icon_1024.png"
SET = ROOT / "ios" / "Runner" / "Assets.xcassets" / "AppIcon.appiconset"


def main() -> None:
    src = Image.open(SRC).convert("RGBA")
    flat = Image.new("RGB", src.size, (255, 239, 226))
    flat.paste(src, mask=src.split()[3])
    contents = json.loads((SET / "Contents.json").read_text(encoding="utf-8"))
    for img in contents["images"]:
        name = img.get("filename")
        if not name:
            continue
        pts = float(img["size"].split("x")[0])
        scale = int(img["scale"].replace("x", ""))
        px = round(pts * scale)
        flat.resize((px, px), Image.LANCZOS).save(SET / name, optimize=True)
        print(f"{name:32s} {px}px")
    web = ROOT / "web" / "icons"
    if web.exists():
        flat.resize((512, 512), Image.LANCZOS).save(web / "Icon-512.png")
        flat.resize((192, 192), Image.LANCZOS).save(web / "Icon-192.png")


if __name__ == "__main__":
    main()
