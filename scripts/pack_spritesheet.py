#!/usr/bin/env python3
"""
Gộp các frame PNG riêng lẻ thành 1 spritesheet + JSON (Free Texture Packer Hash).

Dùng cho Flame game:
  - Ngang (horizontal): SpriteAnimationData.sequenced(amount, stepTime, textureSize)
  - JSON: loader FreeTexAtlas (cùng format slime atlas)

Ví dụ:
  python3 scripts/pack_spritesheet.py \\
    --input /path/to/2BlueWizardIdle \\
    --output assets/atlas/wizard_idle \\
    --prefix BlueWizardIdle
"""

from __future__ import annotations

import argparse
import json
import math
import re
import sys
from pathlib import Path

from PIL import Image

FRAME_NUMBER_PATTERN = re.compile(r"(\d+)(?=\.[^.]+$)")


def natural_sort_key(path: Path) -> list[int | str]:
    name = path.stem
    match = FRAME_NUMBER_PATTERN.search(name)
    if match is None:
        return [name]
    prefix = name[: match.start()]
    suffix = name[match.end() :]
    return [prefix, int(match.group(1)), suffix]


def collect_frames(input_dir: Path, pattern: str) -> list[Path]:
    if not input_dir.is_dir():
        raise FileNotFoundError(f"Không tìm thấy thư mục input: {input_dir}")

    frames = sorted(input_dir.glob(pattern), key=natural_sort_key)
    if not frames:
        raise FileNotFoundError(
            f"Không có file khớp '{pattern}' trong: {input_dir}",
        )
    return frames


def load_frame_images(frame_paths: list[Path]) -> list[Image.Image]:
    images: list[Image.Image] = []
    expected_size: tuple[int, int] | None = None

    for frame_path in frame_paths:
        image = Image.open(frame_path).convert("RGBA")
        if expected_size is None:
            expected_size = image.size
        elif image.size != expected_size:
            raise ValueError(
                f"Kích thước frame không đồng nhất: {frame_path.name} "
                f"{image.size} (mong đợi {expected_size})",
            )
        images.append(image)

    return images


def resolve_columns(frame_count: int, layout: str, columns: int | None) -> int:
    if layout == "horizontal":
        return frame_count
    if columns is not None and columns > 0:
        return columns
    return max(1, math.ceil(math.sqrt(frame_count)))


def pack_frames(
    images: list[Image.Image],
    *,
    layout: str,
    padding: int,
    columns: int | None,
) -> tuple[Image.Image, list[dict[str, int]]]:
    frame_width, frame_height = images[0].size
    column_count = resolve_columns(len(images), layout, columns)
    row_count = math.ceil(len(images) / column_count)

    sheet_width = column_count * frame_width + max(0, column_count - 1) * padding
    sheet_height = row_count * frame_height + max(0, row_count - 1) * padding
    sheet = Image.new("RGBA", (sheet_width, sheet_height), (0, 0, 0, 0))

    placements: list[dict[str, int]] = []
    for index, image in enumerate(images):
        column = index % column_count
        row = index // column_count
        x = column * (frame_width + padding)
        y = row * (frame_height + padding)
        sheet.paste(image, (x, y))
        placements.append({"x": x, "y": y, "w": frame_width, "h": frame_height})

    return sheet, placements


def build_frame_entry(
    placement: dict[str, int],
    frame_name: str,
    pivot_x: float,
    pivot_y: float,
) -> dict:
    width = placement["w"]
    height = placement["h"]
    return {
        "frame": {
            "x": placement["x"],
            "y": placement["y"],
            "w": width,
            "h": height,
        },
        "rotated": False,
        "trimmed": False,
        "spriteSourceSize": {"x": 0, "y": 0, "w": width, "h": height},
        "sourceSize": {"w": width, "h": height},
        "pivot": {"x": pivot_x, "y": pivot_y},
    }


def build_atlas_json(
    frame_paths: list[Path],
    placements: list[dict[str, int]],
    *,
    image_name: str,
    sheet_size: tuple[int, int],
    prefix: str,
    pivot_x: float,
    pivot_y: float,
) -> dict:
    frames: dict[str, dict] = {}
    for frame_path, placement in zip(frame_paths, placements):
        key = f"{prefix}/{frame_path.name}" if prefix else frame_path.name
        frames[key] = build_frame_entry(placement, frame_path.name, pivot_x, pivot_y)

    return {
        "frames": frames,
        "meta": {
            "app": "WizardLabyrinth pack_spritesheet.py",
            "version": "1.0.0",
            "image": image_name,
            "format": "RGBA8888",
            "size": {"w": sheet_size[0], "h": sheet_size[1]},
            "scale": 1,
        },
    }


def write_outputs(
    sheet: Image.Image,
    atlas: dict,
    output_base: Path,
) -> tuple[Path, Path]:
    output_base.parent.mkdir(parents=True, exist_ok=True)
    png_path = output_base.with_suffix(".png")
    json_path = output_base.with_suffix(".json")

    sheet.save(png_path, format="PNG", optimize=True)
    with json_path.open("w", encoding="utf-8") as json_file:
        json.dump(atlas, json_file, indent=2)
        json_file.write("\n")

    return png_path, json_path


def parse_args(argv: list[str]) -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Gộp frame PNG thành spritesheet + JSON cho Flame.",
    )
    parser.add_argument(
        "--input",
        "-i",
        required=True,
        type=Path,
        help="Thư mục chứa các frame PNG (sắp xếp theo số đuôi tên file).",
    )
    parser.add_argument(
        "--output",
        "-o",
        required=True,
        type=Path,
        help="Đường dẫn output không gồm đuôi (vd: assets/atlas/wizard_idle).",
    )
    parser.add_argument(
        "--prefix",
        default="",
        help="Tiền tố key trong JSON (vd: BlueWizardIdle → BlueWizardIdle/frame.png).",
    )
    parser.add_argument(
        "--pattern",
        default="*.png",
        help="Glob lọc frame trong thư mục input (mặc định: *.png).",
    )
    parser.add_argument(
        "--layout",
        choices=("horizontal", "grid"),
        default="horizontal",
        help="horizontal: 1 hàng (tốt cho SpriteAnimationData.sequenced).",
    )
    parser.add_argument(
        "--columns",
        type=int,
        default=None,
        help="Số cột khi --layout grid (mặc định: sqrt số frame).",
    )
    parser.add_argument(
        "--padding",
        type=int,
        default=0,
        help="Khoảng cách px giữa các frame (Free Texture Packer thường dùng 2).",
    )
    parser.add_argument(
        "--pivot-x",
        type=float,
        default=0.5,
        help="Pivot X trong JSON (0–1).",
    )
    parser.add_argument(
        "--pivot-y",
        type=float,
        default=0.5,
        help="Pivot Y trong JSON (0–1).",
    )
    return parser.parse_args(argv)


def main(argv: list[str] | None = None) -> int:
    args = parse_args(argv or sys.argv[1:])

    frame_paths = collect_frames(args.input, args.pattern)
    images = load_frame_images(frame_paths)
    sheet, placements = pack_frames(
        images,
        layout=args.layout,
        padding=max(0, args.padding),
        columns=args.columns,
    )

    image_name = f"{args.output.name}.png"
    atlas = build_atlas_json(
        frame_paths,
        placements,
        image_name=image_name,
        sheet_size=sheet.size,
        prefix=args.prefix.strip(),
        pivot_x=args.pivot_x,
        pivot_y=args.pivot_y,
    )

    png_path, json_path = write_outputs(sheet, atlas, args.output)

    frame_width, frame_height = images[0].size
    print(f"Packed {len(frame_paths)} frames → {png_path}")
    print(f"Atlas JSON      → {json_path}")
    print(f"Sheet size      → {sheet.size[0]}×{sheet.size[1]}")
    print(f"Frame size      → {frame_width}×{frame_height}")
    print()
    print("Flame (sequenced):")
    print(
        "  SpriteAnimationData.sequenced("
        f"amount: {len(frame_paths)}, "
        "stepTime: <fps>, "
        f"textureSize: Vector2({frame_width}, {frame_height}),"
        ")",
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
