"""Crop and upscale the image assets used by the site from the design mockup.

Usage: python3 tools/extract_assets.py [assets/design/mockup.jpg]
"""
import os
import sys

from PIL import Image, ImageDraw, ImageEnhance, ImageFilter

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
SRC = sys.argv[1] if len(sys.argv) > 1 else os.path.join(ROOT, "assets/design/mockup.jpg")
OUT = os.path.join(ROOT, "assets/img")
SCALE = 4


def upscale(img, scale=SCALE):
    img = img.resize((img.width * scale, img.height * scale), Image.LANCZOS)
    img = img.filter(ImageFilter.UnsharpMask(radius=2, percent=80, threshold=2))
    return ImageEnhance.Color(img).enhance(1.05)


def circle(img):
    mask = Image.new("L", (img.width * 4, img.height * 4), 0)
    ImageDraw.Draw(mask).ellipse((4, 4, mask.width - 4, mask.height - 4), fill=255)
    mask = mask.resize(img.size, Image.LANCZOS)
    out = img.convert("RGBA")
    out.putalpha(mask)
    return out


def crop_circle(im, cx, cy, r, name):
    tile = upscale(im.crop((cx - r, cy - r, cx + r, cy + r)))
    circle(tile).save(os.path.join(OUT, name))


def main():
    os.makedirs(os.path.join(OUT, "tokens"), exist_ok=True)
    im = Image.open(SRC).convert("RGB")

    # Brand / banner art
    hero = im.crop((572, 71, 817, 185))
    # Remove the baked-in "Live Data" badge (re-created in HTML) by smearing the row above it
    # down; the HTML badge sits on top of this spot at every breakpoint.
    bx0, by0, bx1, by1 = 660 - 572, 158 - 71, 245, 114
    patch = hero.crop((bx0, by0 - 1, bx1, by0)).resize((bx1 - bx0, by1 - by0))
    hero.paste(patch.filter(ImageFilter.GaussianBlur(4)), (bx0, by0))
    upscale(hero).save(os.path.join(OUT, "hero-owl.jpg"), quality=92)
    upscale(im.crop((18, 380, 138, 456))).save(os.path.join(OUT, "promo-owl.jpg"), quality=92)
    upscale(im.crop((172, 82, 200, 112))).save(os.path.join(OUT, "hero-mark.png"))
    crop_circle(im, 52, 33, 25, "logo.png")
    crop_circle(im, 33, 650, 18, "avatar.png")

    # Token icons: main table
    table = ["babydoge", "tst", "neiro", "floki", "pepu", "wif", "mew", "bome", "pepe", "doge"]
    for name, cy in zip(table, [325, 358, 391, 425, 459, 494, 527, 561, 595, 629]):
        crop_circle(im, 214, cy, 12, f"tokens/{name}.png")
    # Right-panel extras
    crop_circle(im, 871, 374, 11, "tokens/ponke.png")
    for name, cy in zip(["dogeai", "pepe2", "kong", "shibi"], [535, 557, 578, 601]):
        crop_circle(im, 863, cy, 9, f"tokens/{name}.png")


if __name__ == "__main__":
    main()
