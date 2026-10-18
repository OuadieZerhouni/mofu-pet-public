"""Turn the frames from test/motion_dump_test.dart into reviewable motion.

    python tools/motion/strips.py [scenario ...] [--crop y0,y1] [--every 2]

Per scenario (build/motion/<name>/NNN.png at 30 fps):
  build/motion/<name>.gif        - real-time loop, 220 px wide (for a human)
  build/motion/<name>_strip.png  - every Nth frame in rows of 8 with the frame number
                                   (for frame-by-frame review: jumps, pops, stiff easing)
--crop limits the strip to a band of the screen (in pt) to see small motion larger.
"""
from __future__ import annotations

import argparse
import sys
from pathlib import Path

from PIL import Image, ImageDraw

ROOT = Path(__file__).resolve().parents[2]
MOTION = ROOT / "build" / "motion"


def build(name: str, every: int, crop: tuple[int, int] | None) -> None:
    frames = sorted((MOTION / name).glob("*.png"))
    if not frames:
        print(f"{name}: no frames")
        return
    imgs = [Image.open(f).convert("RGB") for f in frames]
    w, h = imgs[0].size
    gw = 220
    gif = [im.resize((gw, round(h * gw / w)), Image.LANCZOS) for im in imgs]
    gif[0].save(MOTION / f"{name}.gif", save_all=True, append_images=gif[1:], duration=33, loop=0, optimize=True)
    picked = list(range(0, len(imgs), every))
    band = imgs if crop is None else [im.crop((0, crop[0], w, crop[1])) for im in imgs]
    bw, bh = band[0].size
    tw = 200 if crop is None else 330
    th = round(bh * tw / bw)
    cols = 8
    rows = (len(picked) + cols - 1) // cols
    sheet = Image.new("RGB", (cols * (tw + 4), rows * (th + 18)), "white")
    d = ImageDraw.Draw(sheet)
    for k, i in enumerate(picked):
        x, y = (k % cols) * (tw + 4), (k // cols) * (th + 18)
        sheet.paste(band[i].resize((tw, th), Image.LANCZOS), (x, y + 16))
        d.text((x + 2, y + 2), f"#{i} {i * 33}ms", fill=(60, 40, 46))
    sheet.save(MOTION / f"{name}_strip.png")
    print(f"{name}: {len(imgs)} frames -> {name}.gif, {name}_strip.png ({len(picked)} shown)")


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("names", nargs="*")
    ap.add_argument("--every", type=int, default=2)
    ap.add_argument("--crop", default=None)
    a = ap.parse_args()
    crop = tuple(int(v) for v in a.crop.split(",")) if a.crop else None
    names = a.names or sorted(p.name for p in MOTION.iterdir() if p.is_dir())
    for n in names:
        build(n, a.every, crop)  # type: ignore[arg-type]
    return 0


if __name__ == "__main__":
    sys.exit(main())
