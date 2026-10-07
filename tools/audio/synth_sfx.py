"""Synthesise Mofu's sound pack → assets/sounds/*.mp3.

    python tools/audio/synth_sfx.py

Deterministic (seeded) so a re-run reproduces the shipped files. Three
sounds are the owner's existing OuO recordings, reused on purpose because
they were already approved by ear: chew (bite_and_chew), yawn, sparkle.
Everything else is built here from sines, filtered noise and envelopes,
tuned to read as a tiny soft creature rather than a beep.

Perception is an owner gate (owner-todo.md): a script can check levels and
loop seams, not cuteness.
"""
from __future__ import annotations

import pathlib
import shutil
import subprocess
import tempfile

import numpy as np
import soundfile as sf
from scipy import signal

SR = 44100
ROOT = pathlib.Path(__file__).resolve().parents[2]
OUT = ROOT / "assets" / "sounds"
OUO_SOUNDS = ROOT.parent.parent / "tools" / "ouo-sound-lab" / "sounds"
rng = np.random.default_rng(42)


def t_axis(dur: float) -> np.ndarray:
    return np.arange(int(SR * dur)) / SR


def env(n: int, attack: float = 0.005, release: float = 0.08, curve: float = 2.0) -> np.ndarray:
    a = max(1, int(SR * attack))
    r = max(1, int(SR * release))
    e = np.ones(n)
    e[:a] = np.linspace(0, 1, a)
    e[-r:] *= np.linspace(1, 0, r) ** curve
    return e


def osc(freq: np.ndarray, shape: str = "sine") -> np.ndarray:
    phase = 2 * np.pi * np.cumsum(freq) / SR
    if shape == "sine":
        return np.sin(phase)
    if shape == "tri":
        return 2 / np.pi * np.arcsin(np.sin(phase))
    if shape == "saw":
        return 2 * ((phase / (2 * np.pi)) % 1.0) - 1
    raise ValueError(shape)


def lowpass(x: np.ndarray, hz: float, order: int = 4) -> np.ndarray:
    b, a = signal.butter(order, hz / (SR / 2), "low")
    return signal.lfilter(b, a, x)


def bandpass(x: np.ndarray, lo: float, hi: float, order: int = 3) -> np.ndarray:
    b, a = signal.butter(order, [lo / (SR / 2), hi / (SR / 2)], "band")
    return signal.lfilter(b, a, x)


def glide(points: list[tuple[float, float]], n: int) -> np.ndarray:
    """Piecewise-exponential pitch curve through (time 0..1, Hz) points."""
    xs = np.array([p[0] for p in points]) * (n - 1)
    ys = np.log(np.array([p[1] for p in points]))
    return np.exp(np.interp(np.arange(n), xs, ys))


def voice(dur: float, curve: list[tuple[float, float]], vib_hz=7.0, vib_cents=40.0, shape="sine",
          harmonics=(1.0, 0.35, 0.12), attack=0.006, release=0.09) -> np.ndarray:
    """A 'creature voice': pitch curve + vibrato + a few harmonics + soft lowpass."""
    n = int(SR * dur)
    t = np.arange(n) / SR
    f = glide(curve, n) * 2 ** (vib_cents / 1200 * np.sin(2 * np.pi * vib_hz * t))
    y = sum(a * osc(f * (k + 1), shape) for k, a in enumerate(harmonics))
    y = lowpass(y, 6000)
    return y * env(n, attack, release)


def bell(freq: float, dur: float, decay: float = 6.0) -> np.ndarray:
    t = t_axis(dur)
    y = (np.sin(2 * np.pi * freq * t) + 0.35 * np.sin(2 * np.pi * freq * 2.01 * t)
         + 0.12 * np.sin(2 * np.pi * freq * 3.02 * t))
    return y * np.exp(-decay * t) * env(len(t), 0.002, 0.02)


def place(total: float, parts: list[tuple[float, np.ndarray]]) -> np.ndarray:
    out = np.zeros(int(SR * total))
    for start, clip in parts:
        i = int(SR * start)
        j = min(len(out), i + len(clip))
        out[i:j] += clip[: j - i]
    return out


def noise(dur: float) -> np.ndarray:
    return rng.standard_normal(int(SR * dur))


def seamless(x: np.ndarray, fade: float = 0.08) -> np.ndarray:
    """Crossfade the tail into the head so the loop point has no click."""
    f = int(SR * fade)
    head, tail = x[:f], x[-f:]
    w = np.linspace(0, 1, f)
    body = x[f:-f].copy()
    joined = np.concatenate([tail * (1 - w) + head * w, body])
    return joined


def normalize(x: np.ndarray, peak_db: float = -3.0) -> np.ndarray:
    peak = np.max(np.abs(x)) or 1.0
    return x / peak * 10 ** (peak_db / 20)


# ── the pack ─────────────────────────────────────────────────────────────
def squeak(base: float, shape: str) -> np.ndarray:
    curves = {
        "pyu": [(0, base), (0.35, base * 1.55), (1, base * 1.2)],
        "pii": [(0, base * 1.1), (0.25, base * 1.6), (1, base * 1.5)],
        "kyu": [(0, base * 1.4), (0.4, base * 1.7), (1, base * 0.95)],
    }
    return voice(0.17, curves[shape], vib_hz=11, vib_cents=55, release=0.07)


def giggle() -> np.ndarray:
    parts = []
    pitches = [1150, 1250, 1180, 1300, 1200, 1100]
    for i, p in enumerate(pitches):
        c = voice(0.085, [(0, p), (0.5, p * 1.25), (1, p * 1.05)], vib_hz=14, vib_cents=60, release=0.04)
        breath = lowpass(noise(0.085), 3000) * 0.06 * env(int(SR * 0.085), 0.002, 0.03)
        parts.append((i * 0.105, c + breath))
    return place(0.75, parts)


def hmph() -> np.ndarray:
    v = voice(0.26, [(0, 380), (0.3, 420), (1, 250)], shape="saw", harmonics=(1.0,), vib_cents=10, release=0.1)
    v = lowpass(v, 1400)
    puff = lowpass(noise(0.12), 1800) * 0.25 * env(int(SR * 0.12), 0.002, 0.08)
    return place(0.32, [(0, v), (0.18, puff)])


def pop() -> np.ndarray:
    v = voice(0.07, [(0, 900), (1, 260)], vib_cents=0, attack=0.001, release=0.03)
    return v


def wee(rise: float = 1.0) -> np.ndarray:
    return voice(0.55, [(0, 520), (0.7, 1350 * rise), (1, 1250 * rise)], vib_hz=8, vib_cents=45, release=0.15)


def wobble() -> np.ndarray:
    n = int(SR * 0.8)
    t = np.arange(n) / SR
    f = 520 * 2 ** (0.35 * np.sin(2 * np.pi * 7 * t))
    y = (osc(f) + 0.3 * osc(2 * f)) * (0.6 + 0.4 * np.sin(2 * np.pi * 7 * t + 1.0))
    return lowpass(y, 5000) * env(n, 0.01, 0.2)


def nope() -> np.ndarray:
    a = voice(0.16, [(0, 640), (1, 520)], vib_cents=20, release=0.05)
    b = voice(0.22, [(0, 560), (1, 380)], vib_cents=20, release=0.1)
    return place(0.45, [(0, a), (0.2, b)])


def yum() -> np.ndarray:
    return voice(0.62, [(0, 430), (0.35, 560), (1, 470)], shape="tri", harmonics=(1.0, 0.2), vib_hz=6, vib_cents=35, release=0.2)


def fanfare() -> np.ndarray:
    notes = [1046.5, 1318.5, 1568.0, 2093.0]
    parts = [(i * 0.09, bell(f, 0.7, 5.0) * (0.9 if i < 3 else 1.1)) for i, f in enumerate(notes)]
    return place(1.0, parts)


def squish() -> np.ndarray:
    n = int(SR * 0.32)
    nz = noise(0.32)
    sweep = np.concatenate([np.linspace(2600, 500, n)])
    out = np.zeros(n)
    # Time-varying lowpass via short blocks: a soft "mmff" squish.
    block = 256
    for i in range(0, n, block):
        b, a = signal.butter(2, sweep[min(i, n - 1)] / (SR / 2), "low")
        out[i:i + block] = signal.lfilter(b, a, nz[i:i + block])
    boop = voice(0.32, [(0, 330), (1, 190)], vib_cents=0, release=0.12)[:n]
    return (0.5 * out + boop) * env(n, 0.01, 0.12)


def coo() -> np.ndarray:
    return voice(0.85, [(0, 520), (0.4, 620), (1, 540)], shape="tri", harmonics=(1.0, 0.15), vib_hz=5.5, vib_cents=30, attack=0.05, release=0.3)


def bonk() -> np.ndarray:
    body = voice(0.14, [(0, 260), (1, 120)], vib_cents=0, attack=0.001, release=0.08)
    click = lowpass(noise(0.01), 4000) * 0.4
    return place(0.16, [(0, body), (0, click)])


def boing() -> np.ndarray:
    n = int(SR * 0.55)
    t = np.arange(n) / SR
    depth = 0.45 * np.exp(-5 * t)
    f = 290 * 2 ** (depth * np.sin(2 * np.pi * 17 * t))
    y = osc(f) + 0.25 * osc(2 * f)
    return y * np.exp(-4.5 * t) * env(n, 0.002, 0.08)


def unlock() -> np.ndarray:
    return place(0.6, [(0, bell(1318.5, 0.5, 6)), (0.12, bell(1975.5, 0.5, 6))])


def hatch() -> np.ndarray:
    crack = bandpass(noise(0.05), 1500, 7000) * env(int(SR * 0.05), 0.001, 0.03)
    notes = [784.0, 1046.5, 1318.5, 1568.0, 2093.0]
    parts = [(0, crack * 0.8)] + [(0.08 + i * 0.07, bell(f, 0.6, 5.5) * 0.8) for i, f in enumerate(notes)]
    parts.append((0.45, squeak(1150, "pyu") * 0.9))
    return place(1.1, parts)


def purr_loop() -> np.ndarray:
    dur = 1.2
    t = t_axis(dur + 0.08)
    rumble = lowpass(noise(dur + 0.08), 160) * 3.0
    am = 0.55 + 0.45 * np.sin(2 * np.pi * 25 * t) ** 2
    hum = 0.35 * np.sin(2 * np.pi * 58 * t)
    breath = 0.65 + 0.35 * np.sin(2 * np.pi * (1 / 1.2) * t)  # one gentle swell per loop
    return seamless((rumble + hum) * am * breath)


def brush_loop() -> np.ndarray:
    dur = 1.0
    t = t_axis(dur + 0.08)
    sw = bandpass(noise(dur + 0.08), 1800, 7000)
    strokes = np.abs(np.sin(2 * np.pi * 2.0 * t)) ** 1.5  # two "shff" per second
    return seamless(sw * strokes)


def snore_loop() -> np.ndarray:
    dur = 3.2
    n = int(SR * (dur + 0.1))
    t = np.arange(n) / SR
    inhale_env = np.clip(np.sin(np.pi * np.clip(t / 1.4, 0, 1)), 0, 1) * (t < 1.4)
    exhale_env = np.clip(np.sin(np.pi * np.clip((t - 1.6) / 1.2, 0, 1)), 0, 1) * ((t > 1.6) & (t < 2.8))
    inhale = lowpass(noise(dur + 0.1), 900) * inhale_env * 0.8
    exhale = bandpass(noise(dur + 0.1), 400, 2500) * exhale_env * 0.5
    whistle = 0.12 * np.sin(2 * np.pi * 880 * t) * exhale_env ** 2
    return seamless(inhale + exhale + whistle, fade=0.1)


SYNTH = {
    "squeak": lambda: squeak(1100, "pyu"),
    "squeak2": lambda: squeak(1250, "pii"),
    "squeak3": lambda: squeak(1000, "kyu"),
    "giggle": giggle,
    "hmph": hmph,
    "pop": pop,
    "wee": lambda: wee(1.0),
    "whee": lambda: wee(1.18),
    "wobble": wobble,
    "nope": nope,
    "yum": yum,
    "fanfare": fanfare,
    "squish": squish,
    "coo": coo,
    "bonk": bonk,
    "boing": boing,
    "unlock": unlock,
    "hatch": hatch,
    "purr": purr_loop,
    "brush": brush_loop,
    "snore": snore_loop,
}
REUSED = {"chew": "bite_and_chew.mp3", "yawn": "yawn.mp3", "sparkle": "sparkle.mp3"}
LEVEL_DB = {"purr": -6.0, "brush": -8.0, "snore": -9.0, "bonk": -5.0, "pop": -5.0}


LOOPS = {"purr", "brush", "snore"}


def encode(name: str, y: np.ndarray) -> None:
    y = normalize(y, LEVEL_DB.get(name, -3.0)).astype(np.float32)
    if name in LOOPS:
        # Loops ship as WAV: MP3 encoder padding would put a gap at the seam.
        sf.write(OUT / f"{name}.wav", y, SR, subtype="PCM_16")
        return
    with tempfile.TemporaryDirectory() as d:
        wav = pathlib.Path(d) / f"{name}.wav"
        sf.write(wav, y, SR, subtype="PCM_16")
        subprocess.run(
            ["ffmpeg", "-y", "-loglevel", "error", "-i", str(wav), "-ac", "1", "-ar", str(SR),
             "-codec:a", "libmp3lame", "-b:a", "96k", str(OUT / f"{name}.mp3")],
            check=True,
        )


def main() -> None:
    OUT.mkdir(parents=True, exist_ok=True)
    for name, fn in SYNTH.items():
        y = fn()
        assert np.isfinite(y).all(), name
        encode(name, y)
        print(f"  {name:8s} {len(y) / SR:5.2f}s synth")
    for name, src in REUSED.items():
        p = OUO_SOUNDS / src
        if p.exists():
            shutil.copyfile(p, OUT / f"{name}.mp3")
            print(f"  {name:8s} reused {src}")
        else:
            raise SystemExit(f"missing {p}")


if __name__ == "__main__":
    main()
