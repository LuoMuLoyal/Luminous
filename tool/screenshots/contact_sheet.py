"""Build contact sheets of the generated page-catalog screenshots.

Downscales each capture and tiles it so a whole group can be reviewed at once,
which is what makes "is this page populated or an empty state?" checkable
without opening 45 files one by one.
"""
import math
import sys
from pathlib import Path

from PIL import Image, ImageDraw

SRC = Path(sys.argv[1] if len(sys.argv) > 1 else "outputs/screenshots")
OUT = Path(sys.argv[2] if len(sys.argv) > 2 else "build/contact")
PER_SHEET = 15
COLS = 5
TILE_W = 300
PAD = 8
LABEL_H = 18

OUT.mkdir(parents=True, exist_ok=True)
files = sorted(p for p in SRC.glob("*.png"))
print(f"{len(files)} captures")

for page in range(math.ceil(len(files) / PER_SHEET)):
    chunk = files[page * PER_SHEET : (page + 1) * PER_SHEET]
    thumbs = []
    for path in chunk:
        img = Image.open(path).convert("RGB")
        ratio = TILE_W / img.width
        thumbs.append((path.stem, img.resize((TILE_W, int(img.height * ratio)))))
    tile_h = max(t.height for _, t in thumbs)
    rows = math.ceil(len(thumbs) / COLS)
    sheet = Image.new(
        "RGB",
        (COLS * (TILE_W + PAD) + PAD, rows * (tile_h + LABEL_H + PAD) + PAD),
        "white",
    )
    draw = ImageDraw.Draw(sheet)
    for i, (name, thumb) in enumerate(thumbs):
        col, row = i % COLS, i // COLS
        x = PAD + col * (TILE_W + PAD)
        y = PAD + row * (tile_h + LABEL_H + PAD)
        sheet.paste(thumb, (x, y))
        draw.text((x + 2, y + thumb.height + 2), name, fill="black")
    dest = OUT / f"sheet-{page + 1}.png"
    sheet.save(dest)
    print(f"{dest} {sheet.size} {[n for n, _ in thumbs]}")
