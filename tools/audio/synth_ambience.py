"""Seeded synthesis of the spa and sleep ambiences (fallback for Stable Audio).

    python tools/audio/synth_ambience.py

Writes assets/sounds/spa/{foam,water,towel,dryer}.ogg + bubble.mp3 + done.mp3 and
assets/sounds/sleep/{rain,purr,fire,ocean,chimes,noise}.ogg. Loops are made
seamless by an equal-power crossfade of the tail into the head, and encoded as
Ogg Vorbis (gapless when looped by SoLoud, unlike MP3).
"""
from __future__ import annotations

import subprocess
from pathlib import Path

import numpy as np

SR = 44100
ROOT = Path(__file__).resolve().parents[2]
RNG = np.random.default_rng(2026)


def noise(n: int) -> np.ndarray:
    return RNG.standard_normal(n)


def lowpass(x: np.ndarray, hz: float) -> np.ndarray:
    a = np.exp(-2 * np.pi * hz / SR)
    y = np.empty_like(x)
    acc = 0.0
    for i, v in enumerate(x):
        acc = (1 - a) * v + a * acc
        y[i] = acc
    return y


def onepole_fast(x: np.ndarray, hz: float) -> np.ndarray:
    """Vectorised one-pole low-pass via FFT filtering (good enough for noise beds)."""
    f = np.fft.rfftfreq(len(x), 1 / SR)
    h = 1 / np.sqrt(1 + (f / hz) ** 2)
    return np.fft.irfft(np.fft.rfft(x) * h, len(x))


def bandpass(x: np.ndarray, lo: float, hi: float) -> np.ndarray:
    f = np.fft.rfftfreq(len(x), 1 / SR)
    h = (1 / np.sqrt(1 + (lo / np.maximum(f, 1)) ** 4)) * (1 / np.sqrt(1 + (f / hi) ** 4))
    return np.fft.irfft(np.fft.rfft(x) * h, len(x))


def brown(n: int) -> np.ndarray:
    x = np.cumsum(noise(n))
    x -= onepole_fast(x, 0.5)  # remove drift
    return x / np.max(np.abs(x))


def pink(n: int) -> np.ndarray:
    f = np.fft.rfftfreq(n, 1 / SR)
    spec = np.fft.rfft(noise(n)) / np.sqrt(np.maximum(f, 20))
    x = np.fft.irfft(spec, n)
    return x / np.max(np.abs(x))


def env(n: int, attack: float, decay: float) -> np.ndarray:
    t = np.arange(n) / SR
    return np.minimum(1, t / max(attack, 1e-4)) * np.exp(-t / max(decay, 1e-4))


def seamless(x: np.ndarray, xf: float = 1.0) -> np.ndarray:
    n = int(xf * SR)
    head, body, tail = x[:n], x[n:-n], x[-n:]
    t = np.linspace(0, np.pi / 2, n)
    return np.concatenate([body, tail * np.cos(t) + head * np.sin(t)])


def norm(x: np.ndarray, peak_db: float = -3) -> np.ndarray:
    return x / max(np.max(np.abs(x)), 1e-9) * 10 ** (peak_db / 20)


def write(x: np.ndarray, path: Path) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    pcm = np.clip(x, -1, 1).astype(np.float32).tobytes()
    codec = ["-c:a", "libvorbis", "-q:a", "4"] if path.suffix == ".ogg" else ["-c:a", "libmp3lame", "-q:a", "2"]
    subprocess.run(["ffmpeg", "-v", "error", "-y", "-f", "f32le", "-ar", str(SR), "-ac", "1", "-i", "-", *codec, str(path)], input=pcm, check=True)
    print(f"{path.relative_to(ROOT)}  {len(x) / SR:.1f}s")


# ── sleep ──────────────────────────────────────────────────────────────────
def rain(sec: float = 24) -> np.ndarray:
    n = int(sec * SR)
    bed = bandpass(pink(n), 300, 6000) * 0.55
    drops = np.zeros(n)
    for _ in range(int(sec * 55)):
        i = RNG.integers(0, n - 2000)
        k = int(SR * RNG.uniform(0.004, 0.02))
        drops[i:i + k] += noise(k) * env(k, 0.0005, 0.004) * RNG.uniform(0.2, 0.9)
    return norm(seamless(bed + bandpass(drops, 1500, 9000) * 0.6))


def purr(sec: float = 16) -> np.ndarray:
    n = int(sec * SR)
    t = np.arange(n) / SR
    breath = 0.5 + 0.5 * np.sin(2 * np.pi * t / 2.6)  # in/out breaths
    rumble = onepole_fast(noise(n), 160) * (0.6 + 0.4 * np.sin(2 * np.pi * 26 * t))
    return norm(seamless(rumble * (0.35 + 0.65 * breath)), -5)


def fire(sec: float = 24) -> np.ndarray:
    n = int(sec * SR)
    bed = onepole_fast(brown(n), 900) * 0.6
    crack = np.zeros(n)
    for _ in range(int(sec * 9)):
        i = RNG.integers(0, n - 3000)
        k = int(SR * RNG.uniform(0.002, 0.012))
        crack[i:i + k] += noise(k) * env(k, 0.0002, 0.003) * RNG.uniform(0.3, 1.0)
    return norm(seamless(bed + bandpass(crack, 800, 7000)))


def ocean(sec: float = 28) -> np.ndarray:
    n = int(sec * SR)
    t = np.arange(n) / SR
    swell = 0.25 + 0.75 * (0.5 - 0.5 * np.cos(2 * np.pi * t / 7.0)) ** 1.6
    return norm(seamless(bandpass(pink(n), 120, 3500) * swell, 2.0))


def chimes(sec: float = 24) -> np.ndarray:
    n = int(sec * SR)
    out = onepole_fast(pink(n), 400) * 0.05
    notes = [523.25, 587.33, 659.25, 783.99, 880.0, 1046.5]  # C major pentatonic-ish
    for _ in range(int(sec * 0.9)):
        i = RNG.integers(0, n - SR * 3)
        f = RNG.choice(notes)
        k = SR * 3
        tt = np.arange(k) / SR
        tone = (np.sin(2 * np.pi * f * tt) + 0.4 * np.sin(2 * np.pi * f * 2.76 * tt) * np.exp(-tt * 2)) * env(k, 0.002, 0.9)
        out[i:i + k] += tone * RNG.uniform(0.15, 0.4)
    return norm(seamless(out))


def soft_noise(sec: float = 20) -> np.ndarray:
    n = int(sec * SR)
    return norm(seamless(onepole_fast(brown(n), 1200)), -6)


# ── spa ───────────────────────────────────────────────────────────────────
def foam(sec: float = 6) -> np.ndarray:
    n = int(sec * SR)
    bed = bandpass(noise(n), 2000, 9000) * 0.15
    pops = np.zeros(n)
    for _ in range(int(sec * 70)):
        i = RNG.integers(0, n - 800)
        k = int(SR * RNG.uniform(0.002, 0.008))
        f = RNG.uniform(1800, 5200)
        tt = np.arange(k) / SR
        pops[i:i + k] += np.sin(2 * np.pi * f * tt * (1 + 2 * tt)) * env(k, 0.0002, 0.002) * RNG.uniform(0.2, 0.7)
    return norm(seamless(bed + pops, 0.5), -4)


def water(sec: float = 6) -> np.ndarray:
    n = int(sec * SR)
    return norm(seamless(bandpass(pink(n), 500, 10000) * (0.85 + 0.15 * np.sin(np.arange(n) / SR * 9)), 0.5), -4)


def towel(sec: float = 4) -> np.ndarray:
    n = int(sec * SR)
    t = np.arange(n) / SR
    rub = 0.3 + 0.7 * np.abs(np.sin(2 * np.pi * 1.6 * t))
    return norm(seamless(bandpass(noise(n), 600, 4000) * rub, 0.4), -6)


def dryer(sec: float = 5) -> np.ndarray:
    n = int(sec * SR)
    t = np.arange(n) / SR
    hum = 0.25 * np.sin(2 * np.pi * 118 * t) + 0.12 * np.sin(2 * np.pi * 236 * t)
    air = bandpass(noise(n), 900, 7000) * 0.7
    return norm(seamless(hum + air, 0.5), -5)


def bubble_pop() -> np.ndarray:
    k = int(SR * 0.12)
    tt = np.arange(k) / SR
    return norm(np.sin(2 * np.pi * (900 + 2200 * tt) * tt) * env(k, 0.001, 0.03), -3)


def done_chime() -> np.ndarray:
    k = int(SR * 1.6)
    out = np.zeros(k)
    for j, f in enumerate([1046.5, 1318.5, 1568.0, 2093.0]):
        i = int(j * 0.09 * SR)
        tt = np.arange(k - i) / SR
        out[i:] += np.sin(2 * np.pi * f * tt) * env(k - i, 0.002, 0.5) * 0.4
    return norm(out, -3)


def main() -> None:
    s = ROOT / "assets" / "sounds"
    for name, fn in [("rain", rain), ("purr", purr), ("fire", fire), ("ocean", ocean), ("chimes", chimes), ("noise", soft_noise)]:
        write(fn(), s / "sleep" / f"{name}.ogg")
    for name, fn in [("foam", foam), ("water", water), ("towel", towel), ("dryer", dryer)]:
        write(fn(), s / "spa" / f"{name}.ogg")
    write(bubble_pop(), s / "spa" / "bubble.mp3")
    write(done_chime(), s / "spa" / "done.mp3")


if __name__ == "__main__":
    main()
