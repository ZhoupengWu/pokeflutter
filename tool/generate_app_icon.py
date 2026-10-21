#!/usr/bin/env python3
"""Draws the app icon into assets/icon/ (needs Pillow):

    icon.png             1024 x 1024, the whole icon (legacy Android, iOS)
    icon_foreground.png  1024 x 1024, the ball on transparent (adaptive icon)
    icon_background.png  1024 x 1024, the background (adaptive icon)

Then run `dart run flutter_launcher_icons` to write the Android and iOS files.
"""
import os
from PIL import Image, ImageChops, ImageDraw, ImageFilter

SIZE = 1024
SS = 3  # supersampling for smooth edges
OUT = os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', 'assets', 'icon')


def gradient(size, top, bottom, diagonal=False):
    """A linear gradient image, vertical or top-left to bottom-right."""
    w, h = size
    base = Image.new('RGB', (1, 256))
    for y in range(256):
        t = y / 255
        base.putpixel((0, y), tuple(round(a + (b - a) * t) for a, b in zip(top, bottom)))
    if not diagonal:
        return base.resize((w, h), Image.BILINEAR)
    # Rotate the ramp by 45 degrees over a square canvas.
    big = base.resize((w * 2, h * 2), Image.BILINEAR).rotate(45, resample=Image.BICUBIC)
    left, upper = (big.width - w) // 2, (big.height - h) // 2
    return big.crop((left, upper, left + w, upper + h))


def background(size):
    return gradient((size, size), (0x3F, 0x51, 0x70), (0x16, 0x1C, 0x29), diagonal=True)


def ball(size, radius, shadow=True):
    """The Poké Ball on a transparent square canvas of [size] pixels."""
    s = size * SS
    r = radius * SS
    c = s // 2
    canvas = Image.new('RGBA', (s, s), (0, 0, 0, 0))

    if shadow:
        sh = Image.new('L', (s, s), 0)
        ImageDraw.Draw(sh).ellipse(
            (c - r * 0.92, c + r * 0.80, c + r * 0.92, c + r * 1.10), fill=150
        )
        sh = sh.filter(ImageFilter.GaussianBlur(r * 0.07))
        canvas.paste(Image.new('RGBA', (s, s), (0, 0, 0, 255)), (0, 0), sh)

    disc = Image.new('L', (s, s), 0)
    ImageDraw.Draw(disc).ellipse((c - r, c - r, c + r, c + r), fill=255)

    # Red top, white bottom, each with a soft gradient.
    red = gradient((s, s), (0xFF, 0x6B, 0x6B), (0xD0, 0x1F, 0x3C)).convert('RGBA')
    white = gradient((s, s), (0xFF, 0xFF, 0xFF), (0xC9, 0xD2, 0xE3)).convert('RGBA')
    halves = Image.new('RGBA', (s, s))
    halves.paste(red, (0, 0))
    bottom_mask = Image.new('L', (s, s), 0)
    ImageDraw.Draw(bottom_mask).rectangle((0, c, s, s), fill=255)
    halves.paste(white, (0, 0), bottom_mask)

    body = Image.new('RGBA', (s, s), (0, 0, 0, 0))
    body.paste(halves, (0, 0), disc)

    # Gloss: a pale crescent at the upper left.
    gloss = Image.new('L', (s, s), 0)
    gd = ImageDraw.Draw(gloss)
    gd.ellipse((c - r * 0.86, c - r * 0.86, c + r * 0.50, c + r * 0.50), fill=110)
    gd.ellipse((c - r * 0.78, c - r * 0.70, c + r * 0.62, c + r * 0.62), fill=0)
    upper = Image.new('L', (s, s), 0)
    ImageDraw.Draw(upper).rectangle((0, 0, s, c - r * 0.115), fill=255)  # above the belt
    gloss = ImageChops.multiply(ImageChops.multiply(gloss, disc), upper).filter(
        ImageFilter.GaussianBlur(r * 0.012)
    )
    body.paste(Image.new('RGBA', (s, s), (255, 255, 255, 255)), (0, 0), gloss)

    dark = (0x14, 0x19, 0x24, 255)
    d = ImageDraw.Draw(body)
    band = r * 0.115
    d.rectangle((c - r, c - band, c + r, c + band), fill=dark)  # belt
    # Clip the belt back to the disc.
    clipped = Image.new('RGBA', (s, s), (0, 0, 0, 0))
    clipped.paste(body, (0, 0), disc)
    body = clipped
    d = ImageDraw.Draw(body)

    # Outline.
    ring = Image.new('L', (s, s), 0)
    rd = ImageDraw.Draw(ring)
    rd.ellipse((c - r, c - r, c + r, c + r), fill=255)
    rd.ellipse((c - r + r * 0.045, c - r + r * 0.045, c + r - r * 0.045, c + r - r * 0.045), fill=0)
    body.paste(Image.new('RGBA', (s, s), dark), (0, 0), ring)

    # Centre button.
    for radius, fill in [(r * 0.30, dark), (r * 0.215, (0xF3, 0xF6, 0xFB, 255))]:
        d.ellipse((c - radius, c - radius, c + radius, c + radius), fill=fill)
    d.ellipse((c - r * 0.13, c - r * 0.13, c + r * 0.13, c + r * 0.13), fill=(0xD9, 0xE0, 0xEC, 255))
    d.ellipse((c - r * 0.13, c - r * 0.13, c + r * 0.13, c + r * 0.13),
              outline=(0xB7, 0xC1, 0xD3, 255), width=max(1, round(r * 0.012)))

    canvas = Image.alpha_composite(canvas, body)
    return canvas.resize((size, size), Image.LANCZOS)


def main():
    os.makedirs(OUT, exist_ok=True)
    # Whole icon: the ball fills about 70 % of the square.
    full = background(SIZE).convert('RGBA')
    full.alpha_composite(ball(SIZE, round(SIZE * 0.345)))
    full.convert('RGB').save(os.path.join(OUT, 'icon.png'))
    # Adaptive icon: flutter_launcher_icons insets the foreground by 16 %, and
    # only the middle 61 % of the 108 dp canvas is always visible; Android masks
    # and animates the two layers.
    ball(SIZE, round(SIZE * 0.40), shadow=False).save(
        os.path.join(OUT, 'icon_foreground.png')
    )
    background(SIZE).save(os.path.join(OUT, 'icon_background.png'))
    print('written to', os.path.normpath(OUT))


if __name__ == '__main__':
    main()
