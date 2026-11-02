"""Crop self-contained UI components out of the generated page screenshots.

Every capture in ``outputs/screenshots/`` is a full page, but a component
library only needs the blocks the page is built from: cards, list groups,
inputs, buttons, chips, dialogs.  This script recovers those blocks from the
raster captures without any DOM access:

1. the page canvas colour is read from the screenshot's border ring;
2. anything that differs from that canvas is foreground (cards, fields, text);
3. foreground is split into connected components (row run-lengths plus
   union-find, so numpy + Pillow are the only hard dependencies);
4. a component is kept only when it behaves like a self-contained surface:
   filled (not a text line), big enough, and clear of the frame edges — a block
   the viewport cuts off is exactly the "incomplete" case we drop;
5. dialog captures (dimmed backdrop) keep only the bright panel, so blurred
   page ghosts behind the scrim do not turn into components;
6. blocks are grouped into meaningful units: a section title plus its list is
   one block (``健康档案`` + five rows), not one crop per row;
7. skeleton/placeholder bars are dropped: no OCR text and no accent colour.

OCR (optional, and strongly recommended) runs on the **source page** once and
labels every crop with the text inside it, so files are named after what they
show (``55_auth_login__04__登录.png``) instead of bare indices.  Install it
outside the interpreter's site-packages, e.g.:

    python -m pip install --target %TEMP%\\ocr-libs rapidocr-onnxruntime
    python tool/screenshots/crop_components.py --ocr-libs %TEMP%\\ocr-libs

Crops are deduplicated by content hash: the catalog captures the same page
twice (``*_scrolled``, ``long/``) and different pages repeat the same widgets,
so identical blocks are written once.  Only phone captures are processed;
``desktop/`` and landscape frames are a different viewport class.

Usage:

    python tool/screenshots/crop_components.py
    python tool/screenshots/crop_components.py --src outputs/screenshots --out outputs/components
"""

from __future__ import annotations

import argparse
import hashlib
import json
import os
import re
import sys
from dataclasses import dataclass
from pathlib import Path

import numpy as np
from PIL import Image

# Colour distance from the canvas that still counts as canvas (antialiasing).
BG_TOL = 3
# A block closer than this to the frame is cut off by the viewport.
EDGE_MARGIN = 4
# Smallest block worth calling a component (device pixels, phone captures).
MIN_W = 120
MIN_H = 48
MIN_AREA = 12_000
# Text lines and blurred ghosts cover only part of their own box.
MIN_FILL = 0.70
# A box covering almost the whole frame is the page surface, not a component.
MAX_AREA_FRAC = 0.85
# Flat blocks (spacers, empty bands) carry no component content.
MIN_STDDEV = 5.0
# Canvas darker than this means a dialog scrim over a dimmed page.
DIM_BG_LUM = 240
DIM_MIN_AREA_FRAC = 0.03
DIM_MIN_LUM = 235
# No OCR text + no saturated accent colour => skeleton/placeholder bar.
PLACEHOLDER_SAT_FRAC = 0.005
# Section grouping: a section title sits above its content block; consecutive
# rows of the same list continue a section when the gap is small.
APP_BAR_CUTOFF = 180
HEADER_MIN_H = 44
HEADER_MAX_CHARS = 12
HEADER_GAP = 140
HEADER_X_ALIGN = 120
CONTINUATION_GAP = 60
LIST_X_TOL = 24
LIST_W_TOL = 40
HORIZONTAL_GAP = 40
# Captures that are whole-page duplicates or a different viewport class.
SKIP_DIRS = ("long", "desktop")

INVALID_FILENAME = re.compile(r'[<>:"/\\|?*\x00-\x1f]')


@dataclass
class Blob:
    x0: int
    y0: int
    x1: int
    y1: int
    area: int
    label: str = ""
    members: int = 1

    @property
    def w(self) -> int:
        return self.x1 - self.x0 + 1

    @property
    def h(self) -> int:
        return self.y1 - self.y0 + 1

    @property
    def fill(self) -> float:
        return self.area / float(self.w * self.h)

    def contains(self, x: float, y: float, margin: int = 2) -> bool:
        return (
            self.x0 - margin <= x <= self.x1 + margin
            and self.y0 - margin <= y <= self.y1 + margin
        )


def estimate_canvas(rgb: np.ndarray) -> tuple[int, int, int]:
    """Most frequent colour on the outer ring — the page background."""
    ring = 8
    border = np.concatenate(
        [
            rgb[:ring, :].reshape(-1, 3),
            rgb[-ring:, :].reshape(-1, 3),
            rgb[:, :ring].reshape(-1, 3),
            rgb[:, -ring:].reshape(-1, 3),
        ],
        axis=0,
    )
    colours, counts = np.unique(border, axis=0, return_counts=True)
    return tuple(int(v) for v in colours[counts.argmax()])


def foreground_mask(rgb: np.ndarray, canvas: tuple[int, int, int]) -> np.ndarray:
    delta = np.abs(rgb.astype(np.int16) - np.array(canvas, dtype=np.int16)).max(axis=2)
    return delta > BG_TOL


def connected_components(mask: np.ndarray) -> list[Blob]:
    """Row run-length connected components with union-find (8-connected)."""
    height, width = mask.shape
    parent: list[int] = [0]
    stats: dict[int, list[int]] = {}

    def find(x: int) -> int:
        root = x
        while parent[root] != root:
            root = parent[root]
        while parent[x] != root:
            parent[x], x = root, parent[x]
        return root

    def union(a: int, b: int) -> int:
        ra, rb = find(a), find(b)
        if ra == rb:
            return ra
        if ra > rb:
            ra, rb = rb, ra
        parent[rb] = ra
        sa, sb = stats.pop(rb), stats[ra]
        sa[0] = min(sa[0], sb[0])
        sa[1] = min(sa[1], sb[1])
        sa[2] = max(sa[2], sb[2])
        sa[3] = max(sa[3], sb[3])
        sa[4] += sb[4]
        stats[ra] = sa
        return ra

    previous: list[tuple[int, int, int]] = []  # (start, end, label)
    next_label = 1
    for y in range(height):
        row = mask[y]
        if not row.any():
            previous = []
            continue
        padded = np.empty(width + 2, dtype=np.int8)
        padded[0] = padded[-1] = 0
        padded[1:-1] = row
        edges = np.flatnonzero(np.diff(padded))
        runs: list[tuple[int, int, int]] = []
        cursor = 0
        for start, end in zip(edges[0::2].tolist(), edges[1::2].tolist()):
            while cursor < len(previous) and previous[cursor][1] <= start:
                cursor += 1
            label = -1
            probe = cursor
            while probe < len(previous) and previous[probe][0] < end:
                other = find(previous[probe][2])
                label = other if label < 0 else union(label, other)
                probe += 1
            if label < 0:
                label = next_label
                next_label += 1
                parent.append(label)
                stats[label] = [start, y, end - 1, y, end - start]
            else:
                entry = stats[label]
                entry[0] = min(entry[0], start)
                entry[2] = max(entry[2], end - 1)
                entry[3] = y
                entry[4] += end - start
            runs.append((start, end, label))
        previous = runs

    return [Blob(*stats[root]) for root in {find(label) for label in stats}]


def _dominant_colour(rgb: np.ndarray) -> tuple[int, int, int]:
    colours, counts = np.unique(rgb.reshape(-1, 3), axis=0, return_counts=True)
    return tuple(int(v) for v in colours[counts.argmax()])


def _collect_blobs(
    rgb: np.ndarray,
    offset: tuple[int, int] = (0, 0),
    depth: int = 0,
) -> list[Blob]:
    """Foreground blobs, looking inside a full-screen surface once.

    Chat/dialog pages paint a near-full-screen sheet and draw bubbles on it; on
    the page canvas that reads as one huge blob.  When a blob covers most of the
    frame, treat its own fill colour as the canvas and segment inside it.
    """
    height, width, _ = rgb.shape
    canvas = estimate_canvas(rgb)
    blobs: list[Blob] = []
    for blob in connected_components(foreground_mask(rgb, canvas)):
        covers_screen = blob.w * blob.h >= 0.6 * width * height
        if depth == 0 and covers_screen:
            inner = rgb[blob.y0 : blob.y1 + 1, blob.x0 : blob.x1 + 1]
            inner_canvas = _dominant_colour(inner)
            if inner_canvas != canvas:
                nested = _collect_blobs(
                    inner,
                    (offset[0] + blob.x0, offset[1] + blob.y0),
                    depth + 1,
                )
                blobs.extend(nested)
                continue
        blobs.append(
            Blob(
                blob.x0 + offset[0],
                blob.y0 + offset[1],
                blob.x1 + offset[0],
                blob.y1 + offset[1],
                blob.area,
            )
        )
    return blobs


def select_components(rgb: np.ndarray) -> list[Blob]:
    height, width, _ = rgb.shape
    canvas = estimate_canvas(rgb)
    dim_page = float(np.mean(canvas)) < DIM_BG_LUM
    screen_area = width * height
    keep: list[Blob] = []
    for blob in _collect_blobs(rgb):
        if blob.w < MIN_W or blob.h < MIN_H or blob.area < MIN_AREA:
            continue
        if blob.fill < MIN_FILL:
            continue
        box_area = blob.w * blob.h
        if box_area > MAX_AREA_FRAC * screen_area:
            continue
        if (
            blob.x0 <= EDGE_MARGIN
            or blob.y0 <= EDGE_MARGIN
            or blob.x1 >= width - 1 - EDGE_MARGIN
            or blob.y1 >= height - 1 - EDGE_MARGIN
        ):
            continue
        region = rgb[blob.y0 : blob.y1 + 1, blob.x0 : blob.x1 + 1]
        if dim_page:
            if float(region.mean()) < DIM_MIN_LUM:
                continue
            if box_area < DIM_MIN_AREA_FRAC * screen_area:
                continue
        # A nearly uniform block (empty spacer, plain divider band) is not a
        # component the library should carry.
        if float(region.std()) < MIN_STDDEV:
            continue
        keep.append(blob)
    keep.sort(key=lambda b: (b.y0, b.x0))
    return keep


def crop_and_hash(image: Image.Image, blob: Blob) -> tuple[Image.Image, str]:
    crop = image.crop((blob.x0, blob.y0, blob.x1 + 1, blob.y1 + 1))
    digest = hashlib.sha1(crop.tobytes()).hexdigest()
    return crop, digest


def build_blocks(
    blobs: list[Blob],
    lines: list[dict[str, object]],
    width: int,
    height: int,
) -> list[Blob]:
    """Group cards/rows into meaningful blocks: a section title plus its group.

    A list of five health-profile rows is one component, not five: the section
    title (``健康档案``) sits on the page canvas above the card, and rows of the
    same list are separated only by small gaps.  Blocks fall back to a single
    card when nothing groups it, and blocks cut by the viewport are dropped.
    """

    def inside_any_blob(line: dict[str, object]) -> bool:
        return any(
            blob.contains(float(line["center_x"]), float(line["center_y"]), 0)
            for blob in blobs
        )

    headers = sorted(
        [
            line
            for line in lines
            if float(line["top"]) >= APP_BAR_CUTOFF
            and float(line["height"]) >= HEADER_MIN_H
            and 2 <= len(str(line["text"]).strip()) <= HEADER_MAX_CHARS
            and not inside_any_blob(line)
        ],
        key=lambda line: float(line["top"]),
    )

    def nearest_header(blob: Blob) -> dict[str, object] | None:
        found: dict[str, object] | None = None
        for line in headers:
            if float(line["bottom"]) > blob.y0 + 2:
                break
            if blob.y0 - float(line["bottom"]) > HEADER_GAP:
                continue
            if abs(float(line["left"]) - blob.x0) > HEADER_X_ALIGN:
                continue
            found = line
        return found

    def aligned(group: Blob, blob: Blob) -> bool:
        return (
            abs(blob.x0 - group.x0) <= LIST_X_TOL
            and abs(blob.w - group.w) <= LIST_W_TOL
        )

    def close(group: Blob, blob: Blob) -> bool:
        return blob.y0 - group.y1 <= CONTINUATION_GAP and aligned(group, blob)

    def extend(box: Blob, blob: Blob) -> None:
        box.y1 = max(box.y1, blob.y1)
        box.x0 = min(box.x0, blob.x0)
        box.x1 = max(box.x1, blob.x1)
        box.members += 1

    def same_row(left: Blob, right: Blob) -> bool:
        return abs(left.x0 - right.x0) <= 8 and abs(left.w - right.w) <= 12

    records: list[dict[str, object]] = []
    current: dict[str, object] | None = None
    for blob in sorted(blobs, key=lambda b: b.y0):
        header = nearest_header(blob)
        if current is not None:
            held = current["blob"]
            new_section = header is not None and header is not current["header"]
            if not new_section:
                previous = current["blobs"][-1]  # type: ignore[index]
                gap = blob.y0 - previous.y1
                if current["header"] is not None:
                    continues = gap <= CONTINUATION_GAP and aligned(held, blob)
                else:
                    # Headerless list: only same-shaped rows with a tight gap are
                    # one list (setting rows); unrelated cards stay separate.
                    continues = gap <= 24 and same_row(previous, blob)
                if continues:
                    extend(held, blob)
                    current["blobs"].append(blob)  # type: ignore[union-attr]
                    continue
        box = Blob(blob.x0, blob.y0, blob.x1, blob.y1, 0)
        if header is not None:
            box.x0 = min(box.x0, int(float(header["left"])))
            box.y0 = int(float(header["top"]))
            box.x1 = max(box.x1, int(float(header["right"])))
            box.label = str(header["text"]).strip()
        current = {"header": header, "blob": box, "blobs": [blob]}
        records.append(current)

    def valid(box: Blob) -> bool:
        if box.w < MIN_W or box.h < MIN_H:
            return False
        if box.w * box.h > MAX_AREA_FRAC * width * height:
            return False
        return not (
            box.x0 <= EDGE_MARGIN
            or box.y0 <= EDGE_MARGIN
            or box.x1 >= width - 1 - EDGE_MARGIN
            or box.y1 >= height - 1 - EDGE_MARGIN
        )

    kept: list[Blob] = []
    for record in records:
        block = record["blob"]
        if valid(block):
            kept.append(block)
            continue
        # A list the viewport cuts off is not usable as a whole; its fully
        # visible rows still are.
        kept.extend(member for member in record["blobs"] if valid(member))
    kept.sort(key=lambda b: (b.y0, b.x0))

    # Chips/tabs/segmented controls are a row of neighbouring small blocks, not
    # seven separate components: join blocks that sit on the same band.
    merged: list[Blob] = []
    for block in kept:
        if merged:
            last = merged[-1]
            overlap = min(last.y1, block.y1) - max(last.y0, block.y0)
            same_band = overlap >= 0.6 * min(last.h, block.h)
            gap = block.x0 - last.x1
            if same_band and -2 <= gap <= HORIZONTAL_GAP:
                last.x1 = max(last.x1, block.x1)
                last.y0 = min(last.y0, block.y0)
                last.y1 = max(last.y1, block.y1)
                last.members += block.members
                if not last.label:
                    last.label = block.label
                continue
        merged.append(block)
    return merged


def accent_fraction(crop: Image.Image) -> float:
    """Share of clearly saturated pixels — icons/accents vs flat grey skeletons."""
    rgb = np.asarray(crop.convert("RGB")).astype(np.int16)
    saturation = rgb.max(axis=2) - rgb.min(axis=2)
    return float((saturation > 25).mean())


def slug(text: str, limit: int = 24) -> str:
    text = INVALID_FILENAME.sub(" ", text)
    text = re.sub(r"\s+", "-", text.strip())
    text = re.sub(r"-{2,}", "-", text).strip(".-_")
    return text[:limit].strip(".-_")


def pick_label(lines: list[dict[str, object]], blob: Blob) -> str:
    """Label a component by its top-most text line (tie-break: left-most).

    Components are titled from the top, while the biggest font can be a value
    preview (``超大``) or a trailing state badge (``可用``); the top-left line is
    the title in this catalog.
    """
    inside = [
        line
        for line in lines
        if blob.contains(float(line["center_x"]), float(line["center_y"]))
    ]
    if not inside:
        return ""
    readable = [line for line in inside if len(str(line["text"]).strip()) >= 2]
    candidates = readable or inside
    top = min(float(line["top"]) for line in candidates)
    # Lines sharing the title row: a right-aligned badge may sit a few pixels
    # higher than the title, so keep the left-most of the same row.
    row = [line for line in candidates if float(line["top"]) <= top + 14]
    best = min(row, key=lambda line: float(line["left"]))
    return slug(str(best["text"]))


# ── OCR ───────────────────────────────────────────────────────────────────


def load_ocr(libs: str | None):
    """Import RapidOCR from an optional `pip --target` directory."""
    if libs:
        sys.path.insert(0, libs)
    try:
        from rapidocr_onnxruntime import RapidOCR  # type: ignore[import-not-found]
    except ImportError:
        return None
    return RapidOCR()


def ocr_page(
    engine,
    image_path: Path,
    cache_dir: Path | None,
) -> list[dict[str, object]]:
    """Run OCR on one capture, cached by the capture's content hash."""
    cache_file: Path | None = None
    if cache_dir is not None:
        digest = hashlib.sha1(image_path.read_bytes()).hexdigest()
        cache_file = cache_dir / f"{digest}.json"
        if cache_file.exists():
            try:
                return json.loads(cache_file.read_text(encoding="utf-8"))
            except (OSError, ValueError):
                cache_file = None

    result, _ = engine(str(image_path))
    lines: list[dict[str, object]] = []
    for box, text, score in result or []:
        xs = [float(point[0]) for point in box]
        ys = [float(point[1]) for point in box]
        lines.append(
            {
                "text": text.strip(),
                "score": float(score),
                "left": min(xs),
                "top": min(ys),
                "right": max(xs),
                "bottom": max(ys),
                "center_x": sum(xs) / len(xs),
                "center_y": sum(ys) / len(ys),
                "height": max(ys) - min(ys),
            }
        )
    if cache_file is not None:
        cache_file.parent.mkdir(parents=True, exist_ok=True)
        cache_file.write_text(json.dumps(lines, ensure_ascii=False), encoding="utf-8")
    return lines


# ── main ──────────────────────────────────────────────────────────────────


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    parser.add_argument("--src", default="outputs/screenshots")
    parser.add_argument("--out", default="outputs/components")
    parser.add_argument(
        "--skip-dirs",
        default=",".join(SKIP_DIRS),
        help="comma-separated top-level capture folders to ignore",
    )
    parser.add_argument(
        "--ocr-libs",
        default=os.environ.get("LUMINOUS_OCR_LIBS"),
        help="directory containing rapidocr_onnxruntime (pip --target)",
    )
    parser.add_argument(
        "--ocr-cache",
        default="outputs/.ocr-cache",
        help="cache directory for per-capture OCR results ('' disables)",
    )
    parser.add_argument(
        "--no-ocr",
        action="store_true",
        help="skip OCR: numbered file names, no placeholder filtering",
    )
    args = parser.parse_args()

    src = Path(args.src)
    out = Path(args.out)
    skip = {part.strip() for part in args.skip_dirs.split(",") if part.strip()}
    cache_dir = Path(args.ocr_cache) if args.ocr_cache.strip() else None

    engine = None
    if not args.no_ocr:
        engine = load_ocr(args.ocr_libs)
        if engine is None:
            print(
                "OCR unavailable (install rapidocr-onnxruntime and pass "
                "--ocr-libs); falling back to numbered names"
            )

    sources: list[tuple[str, Path]] = []
    for path in sorted(src.rglob("*.png")):
        relative = path.relative_to(src)
        if relative.parts[0] in skip:
            continue
        sources.append((relative.parts[0] if len(relative.parts) > 1 else "root", path))

    seen_sources: dict[str, Path] = {}
    seen_crops: dict[str, Path] = {}
    rows: list[dict[str, object]] = []
    duplicates = 0
    placeholders = 0
    failed: list[Path] = []

    for group, path in sources:
        source_hash = hashlib.sha1(path.read_bytes()).hexdigest()
        if source_hash in seen_sources:
            duplicates += 1
            continue
        seen_sources[source_hash] = path

        try:
            image = Image.open(path).convert("RGB")
        except OSError as error:  # pragma: no cover - corrupt capture
            print(f"skip {path}: {error}")
            failed.append(path)
            continue
        if image.width >= image.height:
            # Landscape captures are the desktop viewport class: same layout at
            # a different scale, so they would only mix pixel sizes here.
            duplicates += 1
            continue

        lines = ocr_page(engine, path, cache_dir) if engine is not None else []
        blobs = select_components(np.asarray(image))
        blocks = build_blocks(blobs, lines, image.width, image.height)
        written = 0
        for block in blocks:
            crop, digest = crop_and_hash(image, block)
            label = slug(block.label) if block.label else pick_label(lines, block)
            if not label and accent_fraction(crop) < PLACEHOLDER_SAT_FRAC:
                placeholders += 1
                continue
            if digest in seen_crops:
                duplicates += 1
                continue
            written += 1
            suffix = f"__{label}" if label else ""
            dest_dir = out / group
            dest_dir.mkdir(parents=True, exist_ok=True)
            dest = dest_dir / f"{path.stem}__{written:02d}{suffix}.png"
            crop.save(dest)
            seen_crops[digest] = dest
            rows.append(
                {
                    "group": group,
                    "file": dest.relative_to(out).as_posix(),
                    "source": path.relative_to(src).as_posix(),
                    "box": f"{block.x0},{block.y0} {block.w}x{block.h}",
                    "label": label,
                }
            )
        print(
            f"{path.relative_to(src).as_posix():55s} {written:3d} blocks"
            f"  ({len(blobs)} cards -> {len(blocks)} blocks, {len(lines)} ocr lines)"
        )

    out.mkdir(parents=True, exist_ok=True)
    manifest = out / "MANIFEST.md"
    lines_out = [
        "# Component crops (generated)",
        "",
        f"- source: `{src.as_posix()}`",
        f"- crops: **{len(rows)}** unique component blocks from "
        f"**{len(seen_sources)}** unique captures",
        f"- dropped duplicates (identical capture or identical crop): {duplicates}",
        f"- dropped skeleton/placeholder blocks: {placeholders}",
        "- phone captures only (portrait, 1344×2992); `desktop/` and landscape "
        "frames are excluded (different viewport class / full-page duplicates)",
        "- blocks group a section title with its content group (card/list); "
        "rows of one list are one block, not one crop per row",
        "- names: `<capture>__<index>__<label>.png`; label = section title, or the "
        "top-most text line when the block has no title"
        if engine is not None
        else "- names: `<capture>__<index>.png` (OCR disabled)",
        "",
        "| File | Source | Box (x,y w×h) | Label |",
        "| --- | --- | --- | --- |",
    ]
    for row in rows:
        lines_out.append(
            f"| `{row['file']}` | `{row['source']}` | `{row['box']}` | "
            f"{row['label'] or '—'} |"
        )
    manifest.write_text("\n".join(lines_out) + "\n", encoding="utf-8")

    print("\nsummary")
    print(f"  captures read : {len(seen_sources)}")
    print(f"  blocks        : {len(rows)}")
    print(f"  duplicates    : {duplicates}")
    print(f"  placeholders  : {placeholders}")
    if failed:
        print(f"  unreadable    : {len(failed)}")
    per_group: dict[str, int] = {}
    for row in rows:
        per_group[row["group"]] = per_group.get(row["group"], 0) + 1
    for group in sorted(per_group):
        print(f"  {group:12s} {per_group[group]:3d}")
    print(f"  manifest      : {manifest}")


if __name__ == "__main__":
    main()
