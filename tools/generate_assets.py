#!/usr/bin/env python3
"""Write PNG minos/particles and WAV sfx with the stdlib only."""
from __future__ import annotations

import math
import struct
import wave
import zlib
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def png_rgba(path: Path, w: int, h: int, pixels: bytes) -> None:
    def chunk(tag: bytes, data: bytes) -> bytes:
        return struct.pack(">I", len(data)) + tag + data + struct.pack(">I", zlib.crc32(tag + data) & 0xFFFFFFFF)

    raw = b"".join(b"\x00" + pixels[y * w * 4 : (y + 1) * w * 4] for y in range(h))
    ihdr = struct.pack(">IIBBBBB", w, h, 8, 6, 0, 0, 0)
    data = b"\x89PNG\r\n\x1a\n" + chunk(b"IHDR", ihdr) + chunk(b"IDAT", zlib.compress(raw, 9)) + chunk(b"IEND", b"")
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_bytes(data)


def put(px: bytearray, w: int, x: int, y: int, r: int, g: int, b: int, a: int) -> None:
    if 0 <= x < w and 0 <= y < w:
        i = (y * w + x) * 4
        px[i : i + 4] = bytes((r, g, b, a))


def block_png(path: Path, outline: bool = False) -> None:
    n = 64
    px = bytearray(n * n * 4)
    cx = cy = (n - 1) / 2.0
    for y in range(n):
        for x in range(n):
            dx = abs(x - cx) / 24.0
            dy = abs(y - cy) / 24.0
            m = max(dx, dy)
            if m > 1.05:
                continue
            edge = max(0.0, 1.0 - m)
            glow = math.exp(-((m - 0.85) ** 2) * 40.0) if m > 0.7 else 0.0
            if outline:
                ring = 1.0 if 0.78 <= m <= 1.0 else 0.0
                a = int(220 * ring)
                put(px, n, x, y, 220, 245, 255, a)
            else:
                core = 180 + int(75 * edge)
                a = 255 if m <= 1.0 else int(180 * glow)
                hi = 40 if y < cy - 6 and m < 0.85 else 0
                put(px, n, x, y, min(255, core + hi), min(255, core + 8 + hi), min(255, core + 18 + hi), max(a, 255 if m <= 0.98 else a))
    png_rgba(path, n, n, bytes(px))


def spark_png(path: Path) -> None:
    n = 32
    px = bytearray(n * n * 4)
    c = (n - 1) / 2.0
    for y in range(n):
        for x in range(n):
            d = math.hypot(x - c, y - c) / 12.0
            a = int(255 * max(0.0, 1.0 - d) ** 2)
            put(px, n, x, y, 220, 250, 255, a)
    png_rgba(path, n, n, bytes(px))


def tone(path: Path, freq: float, ms: int, volume: float = 0.35, slide: float = 1.0) -> None:
    rate = 44100
    n = int(rate * ms / 1000)
    frames = bytearray()
    for i in range(n):
        t = i / rate
        f = freq * (slide ** t)
        env = min(1.0, i / 200.0) * max(0.0, 1.0 - i / n)
        env *= env
        s = int(32767 * volume * env * math.sin(2 * math.pi * f * t))
        frames += struct.pack("<h", max(-32767, min(32767, s)))
    path.parent.mkdir(parents=True, exist_ok=True)
    with wave.open(str(path), "w") as w:
        w.setnchannels(1)
        w.setsampwidth(2)
        w.setframerate(rate)
        w.writeframes(frames)


def main() -> None:
    block_png(ROOT / "assets" / "blocks" / "block.png", False)
    block_png(ROOT / "assets" / "blocks" / "ghost.png", True)
    spark_png(ROOT / "assets" / "particles" / "spark.png")
    sfx = ROOT / "assets" / "sfx"
    tone(sfx / "move.wav", 420, 40, 0.18)
    tone(sfx / "rotate.wav", 660, 55, 0.22)
    tone(sfx / "lock.wav", 140, 90, 0.3, 0.4)
    tone(sfx / "drop.wav", 880, 70, 0.22, 0.3)
    tone(sfx / "line.wav", 520, 180, 0.28, 1.8)
    tone(sfx / "tetris.wav", 330, 320, 0.32, 3.2)
    tone(sfx / "hold.wav", 240, 90, 0.22, 1.6)
    tone(sfx / "game_over.wav", 220, 500, 0.3, 0.35)
    print("assets written")


if __name__ == "__main__":
    main()
