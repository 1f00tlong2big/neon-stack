#!/usr/bin/env python3
"""Key magenta, crop tiles, write engine-ready PNGs from Imagine outputs."""
from __future__ import annotations

from pathlib import Path

from PIL import Image, ImageDraw, ImageEnhance, ImageFilter, ImageOps

SESSION = Path(r"C:\Users\9am6s\.grok\sessions\C%3A%5CUsers%5C9am6s\01a03f50-ab99-7ec2-9fc3-8b8ab6a8c0aa\images")
ROOT = Path(__file__).resolve().parents[1]


def is_magenta(r: int, g: int, b: int) -> bool:
    return r > 110 and b > 80 and g < 140 and r > g + 30 and b > g + 15


def flood_key_magenta(im: Image.Image) -> Image.Image:
    """Only punch out the outside backdrop, not purple gems inside the frame."""
    im = im.convert("RGBA")
    w, h = im.size
    px = im.load()
    seen = bytearray(w * h)
    q = []

    def try_push(x: int, y: int) -> None:
        if x < 0 or y < 0 or x >= w or y >= h:
            return
        i = y * w + x
        if seen[i]:
            return
        r, g, b, _a = px[x, y]
        if not is_magenta(r, g, b):
            return
        seen[i] = 1
        q.append((x, y))

    for x in range(w):
        try_push(x, 0)
        try_push(x, h - 1)
    for y in range(h):
        try_push(0, y)
        try_push(w - 1, y)
    n = 0
    while n < len(q):
        x, y = q[n]
        n += 1
        px[x, y] = (0, 0, 0, 0)
        try_push(x + 1, y)
        try_push(x - 1, y)
        try_push(x, y + 1)
        try_push(x, y - 1)
    mask = im.getchannel("A").filter(ImageFilter.MinFilter(3))
    im.putalpha(mask)
    return im


def key_magenta(im: Image.Image, erode: int = 1) -> Image.Image:
    im = im.convert("RGBA")
    px = im.load()
    w, h = im.size
    for y in range(h):
        for x in range(w):
            r, g, b, a = px[x, y]
            if is_magenta(r, g, b):
                px[x, y] = (0, 0, 0, 0)
    if erode:
        mask = im.getchannel("A").filter(ImageFilter.MinFilter(3 if erode == 1 else 5))
        im.putalpha(mask)
    return im


def crop_alpha(im: Image.Image, pad: int = 4) -> Image.Image:
    bbox = im.getchannel("A").getbbox()
    if not bbox:
        return im
    x0, y0, x1, y1 = bbox
    x0 = max(0, x0 - pad)
    y0 = max(0, y0 - pad)
    x1 = min(im.width, x1 + pad)
    y1 = min(im.height, y1 + pad)
    return im.crop((x0, y0, x1, y1))


def ghost_from(im: Image.Image) -> Image.Image:
    a = im.getchannel("A")
    edge = a.filter(ImageFilter.FIND_EDGES).point(lambda v: 255 if v > 20 else 0)
    edge = edge.filter(ImageFilter.MaxFilter(3))
    out = Image.new("RGBA", im.size, (0, 0, 0, 0))
    px = out.load()
    src = im.load()
    e = edge.load()
    for y in range(im.height):
        for x in range(im.width):
            if e[x, y]:
                r, g, b, _ = src[x, y]
                px[x, y] = (min(255, r + 40), min(255, g + 40), min(255, b + 40), 200)
    return out


def key_black(im: Image.Image, thresh: int = 18) -> Image.Image:
    im = im.convert("RGBA")
    px = im.load()
    for y in range(im.height):
        for x in range(im.width):
            r, g, b, a = px[x, y]
            if r < thresh and g < thresh and b < thresh:
                px[x, y] = (0, 0, 0, 0)
            else:
                lum = int(0.3 * r + 0.5 * g + 0.2 * b)
                px[x, y] = (r, g, b, min(255, max(a, lum + 40)))
    return crop_alpha(im, 8)


def vignette(im: Image.Image, strength: float = 0.55) -> Image.Image:
    im = im.convert("RGB")
    w, h = im.size
    overlay = Image.new("L", (w, h), 0)
    d = ImageDraw.Draw(overlay)
    d.ellipse((-int(w * 0.15), -int(h * 0.05), int(w * 1.15), int(h * 1.05)), fill=255)
    overlay = overlay.filter(ImageFilter.GaussianBlur(90))
    overlay = ImageEnhance.Brightness(overlay).enhance(1.0)
    dark = Image.new("RGB", (w, h), (8, 4, 16))
    # Blend toward dark where overlay is low
    src = im.load()
    ov = overlay.load()
    dst = dark.load()
    for y in range(h):
        for x in range(w):
            k = ov[x, y] / 255.0
            k = 1.0 - (1.0 - k) * strength
            r, g, b = src[x, y]
            dst[x, y] = (int(r * k), int(g * k), int(b * k))
    return dark


def save(im: Image.Image, path: Path) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    im.save(path, "PNG")
    print("wrote", path, im.size)


def main() -> None:
    menu = Image.open(SESSION / "8.jpg").convert("RGB")
    menu.save(ROOT / "assets" / "bg" / "menu.jpg", "JPEG", quality=92)
    game = ImageEnhance.Brightness(menu).enhance(0.72)
    game = ImageEnhance.Color(game).enhance(1.05)
    game.save(ROOT / "assets" / "bg" / "game.jpg", "JPEG", quality=92)
    game.save(ROOT / "assets" / "bg" / "arcade.jpg", "JPEG", quality=92)
    print("wrote backgrounds")

    block = crop_alpha(key_magenta(Image.open(SESSION / "7.jpg")), pad=2)
    block = block.resize((128, 128), Image.Resampling.LANCZOS)
    save(block, ROOT / "assets" / "blocks" / "block.png")
    ghost = block.copy()
    gp = ghost.load()
    for y in range(ghost.height):
        for x in range(ghost.width):
            r, g, b, a = gp[x, y]
            gp[x, y] = (min(255, r + 30), min(255, g + 30), min(255, b + 30), int(a * 0.55) if a else 0)
    save(ghost, ROOT / "assets" / "blocks" / "ghost.png")

    panel = flood_key_magenta(Image.open(SESSION / "4.jpg"))
    panel = crop_alpha(panel, pad=2)
    save(panel, ROOT / "assets" / "ui" / "panel.png")

    spark = key_black(Image.open(SESSION / "6.jpg"))
    spark = spark.resize((64, 64), Image.Resampling.LANCZOS)
    save(spark, ROOT / "assets" / "particles" / "spark.png")


if __name__ == "__main__":
    main()
