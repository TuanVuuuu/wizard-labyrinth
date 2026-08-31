#!/usr/bin/env python3
"""
Import / scale PNG mossy slices + tạo hoặc cập nhật Tiled Collection of Images (.tsx).

Thêm preset mới ở PRESETS (cuối file config) rồi dùng --preset <tên>.

Ví dụ:
  # Scale slice đã có trong project
  python3 scripts/wl_mossy_slices.py scale --preset spikes
  python3 scripts/wl_mossy_slices.py scale --preset rocks --scale 2

  # Import từ folder export Figma → copy, tạo .tsx, scale
  python3 scripts/wl_mossy_slices.py import --preset rocks --from ~/Downloads/images/đá
  python3 scripts/wl_mossy_slices.py import --preset spikes --from ~/Downloads/spikes

  # Chỉ tạo/cập nhật .tsx từ PNG hiện có (không scale)
  python3 scripts/wl_mossy_slices.py init-tsx --preset rocks

  # Preset tùy chỉnh (slice mới)
  python3 scripts/wl_mossy_slices.py scale \\
    --input assets/maps/mossy-tileset/slices/plants \\
    --tsx assets/maps/tilesets/mossy_plants.tsx
"""

from __future__ import annotations

import argparse
import re
import shutil
import sys
import xml.etree.ElementTree as ET
from dataclasses import dataclass
from pathlib import Path

from PIL import Image

REPO_ROOT = Path(__file__).resolve().parents[1]
SLICES_ROOT = REPO_ROOT / "assets/maps/mossy-tileset/slices"
TSX_ROOT = REPO_ROOT / "assets/maps/tilesets"
BACKUP_ROOT = REPO_ROOT / "scripts/backups"
IMAGE_TAG = "image"


@dataclass(frozen=True)
class SlicePreset:
    name: str
    input_dir: Path
    tsx_path: Path
    tileset_name: str
    backup_dir: Path
    # Đổi tên khi import; None = copy mọi *.png giữ nguyên tên file.
    import_map: dict[str, str] | None = None


def _preset(
    name: str,
    import_map: dict[str, str] | None = None,
) -> SlicePreset:
    return SlicePreset(
        name=name,
        input_dir=SLICES_ROOT / name,
        tsx_path=TSX_ROOT / f"mossy_{name}.tsx",
        tileset_name=f"mossy_{name}",
        backup_dir=BACKUP_ROOT / f"{name}-slices",
        import_map=import_map,
    )


PRESETS: dict[str, SlicePreset] = {
    "spikes": _preset("spikes"),
    "rocks": _preset(
        "rocks",
        import_map={
            "MossyDecorationsHazards-tileset 2.png": "moss_rock_mound.png",
            "MossyDecorationsHazards-tileset 3.png": "moss_rock_slab_wide.png",
            "MossyDecorationsHazards-tileset 4.png": "moss_rock_slab_low.png",
        },
    ),
    "plants": _preset(
        "plants",
        import_map={
            "MossyDecorationsHazards-tileset 15.png": "moss_plant_bush_large.png",
            "MossyDecorationsHazards-tileset 16.png": "moss_plant_fern_patch.png",
            "MossyDecorationsHazards-tileset 17.png": "moss_plant_clump_round.png",
            "MossyDecorationsHazards-tileset 18.png": "moss_plant_clump_tall.png",
            "MossyDecorationsHazards-tileset 19.png": "moss_plant_reed_slender.png",
            "MossyDecorationsHazards-tileset 20.png": "moss_plant_glow_column.png",
            "MossyDecorationsHazards-tileset 21.png": "moss_plant_glow_column_wide.png",
            "MossyDecorationsHazards-tileset 22.png": "moss_plant_glow_slim.png",
            "MossyDecorationsHazards-tileset 23.png": "moss_plant_glow_slim_narrow.png",
            "MossyDecorationsHazards-tileset 24.png": "moss_plant_glow_stub.png",
            "MossyDecorationsHazards-tileset 25.png": "moss_plant_glow_stub_wide.png",
            "MossyDecorationsHazards-tileset 26.png": "moss_plant_seedling.png",
            "MossyDecorationsHazards-tileset 27.png": "moss_plant_seedling_low.png",
            "MossyDecorationsHazards-tileset 28.png": "moss_plant_fern_stalk.png",
            "MossyDecorationsHazards-tileset 29.png": "moss_plant_fern_arc.png",
        },
    ),
}


# --- PNG helpers ---


def collect_pngs(input_dir: Path) -> list[Path]:
    if not input_dir.is_dir():
        raise FileNotFoundError(f"Không tìm thấy thư mục: {input_dir}")

    files = sorted(path for path in input_dir.glob("*.png") if path.is_file())
    if not files:
        raise FileNotFoundError(f"Không có PNG trong: {input_dir}")
    return files


def image_sizes(files: list[Path]) -> dict[str, tuple[int, int]]:
    sizes: dict[str, tuple[int, int]] = {}
    for path in files:
        with Image.open(path) as image:
            sizes[path.name] = (image.width, image.height)
    return sizes


def scaled_size(width: int, height: int, scale: float) -> tuple[int, int]:
    return max(1, round(width * scale)), max(1, round(height * scale))


def scale_image(source: Image.Image, scale: float) -> Image.Image:
    new_w, new_h = scaled_size(source.width, source.height, scale)
    return source.resize((new_w, new_h), Image.Resampling.LANCZOS)


def backup_file(source: Path, backup_dir: Path, dry_run: bool) -> None:
    backup_dir.mkdir(parents=True, exist_ok=True)
    target = backup_dir / source.name
    if target.exists():
        return
    if dry_run:
        print(f"  [dry-run] backup → {target.relative_to(REPO_ROOT)}")
        return
    shutil.copy2(source, target)


def scale_pngs(
    files: list[Path],
    scale: float,
    backup: bool,
    backup_dir: Path,
    dry_run: bool,
) -> dict[str, tuple[int, int]]:
    sizes: dict[str, tuple[int, int]] = {}

    for path in files:
        with Image.open(path) as image:
            image = image.convert("RGBA")
            old_size = (image.width, image.height)
            scaled = scale_image(image, scale)
            new_size = (scaled.width, scaled.height)
            sizes[path.name] = new_size

            print(
                f"  {path.name}: {old_size[0]}×{old_size[1]} → "
                f"{new_size[0]}×{new_size[1]}",
            )

            if dry_run:
                continue

            if backup:
                backup_file(path, backup_dir, dry_run=False)

            scaled.save(path, format="PNG", optimize=True)

    return sizes


# --- TSX helpers ---


def tsx_image_source(preset: SlicePreset, filename: str) -> str:
    return f"../mossy-tileset/slices/{preset.name}/{filename}"


def write_collection_tsx(
    tsx_path: Path,
    tileset_name: str,
    image_entries: list[tuple[str, int, int]],
) -> None:
    max_w = max(width for _, width, _ in image_entries)
    max_h = max(height for _, _, height in image_entries)

    lines = [
        '<?xml version="1.0" encoding="UTF-8"?>',
        (
            f'<tileset version="1.10" tiledversion="1.12.2" name="{tileset_name}" '
            f'tilewidth="{max_w}" tileheight="{max_h}" '
            f'tilecount="{len(image_entries)}" columns="0">'
        ),
        ' <grid orientation="orthogonal" width="1" height="1"/>',
    ]

    for index, (source, width, height) in enumerate(image_entries):
        lines.append(f' <tile id="{index}">')
        lines.append(f'  <image source="{source}" width="{width}" height="{height}"/>')
        lines.append(" </tile>")

    lines.append("</tileset>")
    lines.append("")
    tsx_path.parent.mkdir(parents=True, exist_ok=True)
    tsx_path.write_text("\n".join(lines), encoding="utf-8")


def update_tsx(tsx_path: Path, sizes: dict[str, tuple[int, int]], dry_run: bool) -> None:
    if not tsx_path.is_file():
        print(f"  Bỏ qua .tsx — không tìm thấy: {tsx_path}")
        return

    tree = ET.parse(tsx_path)
    root = tree.getroot()

    max_w = 0
    max_h = 0
    updated = 0

    for tile in root.findall("tile"):
        image_el = tile.find(IMAGE_TAG)
        if image_el is None:
            continue

        filename = Path(image_el.get("source", "")).name
        if filename not in sizes:
            continue

        width, height = sizes[filename]
        image_el.set("width", str(width))
        image_el.set("height", str(height))
        max_w = max(max_w, width)
        max_h = max(max_h, height)
        updated += 1

    root.set("tilewidth", str(max_w))
    root.set("tileheight", str(max_h))

    rel = tsx_path.relative_to(REPO_ROOT)
    if dry_run:
        print(f"  [dry-run] cập nhật {rel} ({updated} tile, {max_w}×{max_h})")
        return

    _write_tsx(tree, tsx_path)
    print(f"  Đã cập nhật {rel} ({updated} tile, tilesize {max_w}×{max_h})")


def _write_tsx(tree: ET.ElementTree, tsx_path: Path) -> None:
    root = tree.getroot()
    xml_body = ET.tostring(root, encoding="unicode")
    content = '<?xml version="1.0" encoding="UTF-8"?>\n' + xml_body + "\n"
    content = re.sub(r"><tile ", ">\n <tile ", content)
    content = re.sub(r"></tile>", ">\n </tile>", content)
    content = re.sub(r"><grid ", ">\n <grid ", content)
    content = re.sub(r"/><grid", "/>\n <grid", content)
    tsx_path.write_text(content, encoding="utf-8")


def build_tsx_from_files(preset: SlicePreset, files: list[Path]) -> None:
    sizes = image_sizes(files)
    entries = [
        (tsx_image_source(preset, name), sizes[name][0], sizes[name][1])
        for name in sorted(sizes)
    ]
    write_collection_tsx(preset.tsx_path, preset.tileset_name, entries)
    print(
        f"  Tạo {preset.tsx_path.relative_to(REPO_ROOT)} "
        f"({len(entries)} tile)",
    )


# --- Import ---


def import_slices(preset: SlicePreset, source_dir: Path) -> list[Path]:
    if not source_dir.is_dir():
        raise FileNotFoundError(f"Không tìm thấy: {source_dir}")

    preset.input_dir.mkdir(parents=True, exist_ok=True)
    imported: list[Path] = []

    if preset.import_map is not None:
        for source_name, target_name in preset.import_map.items():
            source_path = source_dir / source_name
            if not source_path.is_file():
                raise FileNotFoundError(f"Thiếu file: {source_path}")

            target_path = preset.input_dir / target_name
            shutil.copy2(source_path, target_path)
            imported.append(target_path)
            print(f"  {source_name} → {target_path.relative_to(REPO_ROOT)}")
        return imported

    for source_path in sorted(source_dir.glob("*.png")):
        target_path = preset.input_dir / source_path.name
        shutil.copy2(source_path, target_path)
        imported.append(target_path)
        print(f"  {source_path.name} → {target_path.relative_to(REPO_ROOT)}")

    if not imported:
        raise FileNotFoundError(f"Không có PNG trong: {source_dir}")

    return imported


# --- CLI ---


def resolve_preset(preset_name: str) -> SlicePreset:
    if preset_name not in PRESETS:
        choices = ", ".join(sorted(PRESETS))
        raise ValueError(f"Preset không hợp lệ: {preset_name}. Chọn: {choices}")
    return PRESETS[preset_name]


def resolve_scale_paths(
    preset_name: str | None,
    input_dir: Path | None,
    tsx_path: Path | None,
    backup_dir: Path | None,
) -> tuple[str, Path, Path, Path]:
    if preset_name:
        preset = resolve_preset(preset_name)
        return (
            preset.name,
            input_dir or preset.input_dir,
            tsx_path or preset.tsx_path,
            backup_dir or preset.backup_dir,
        )

    if input_dir is None or tsx_path is None:
        raise ValueError("Cần --preset hoặc cả --input và --tsx")

    label = input_dir.name
    backup = backup_dir or (BACKUP_ROOT / f"{label}-slices")
    return label, input_dir, tsx_path, backup


def add_common_flags(parser: argparse.ArgumentParser) -> None:
    parser.add_argument("--dry-run", action="store_true")


def cmd_scale(args: argparse.Namespace) -> int:
    if args.scale <= 0:
        print("Lỗi: --scale phải > 0", file=sys.stderr)
        return 1

    try:
        label, input_dir, tsx_path, backup_dir = resolve_scale_paths(
            args.preset,
            args.input,
            args.tsx,
            args.backup_dir,
        )
        files = collect_pngs(input_dir)
    except (FileNotFoundError, ValueError) as error:
        print(f"Lỗi: {error}", file=sys.stderr)
        return 1

    print(f"[{label}] Scale ×{args.scale} — {len(files)} file")
    if args.dry_run:
        print("(dry-run)")

    sizes = scale_pngs(
        files=files,
        scale=args.scale,
        backup=args.backup,
        backup_dir=backup_dir,
        dry_run=args.dry_run,
    )

    if args.update_tsx:
        update_tsx(tsx_path, sizes, dry_run=args.dry_run)

    if not args.dry_run:
        print("Xong. Reload tileset trong Tiled nếu map đang mở.")
    return 0


def cmd_import(args: argparse.Namespace) -> int:
    if args.preset is None:
        print("Lỗi: import cần --preset", file=sys.stderr)
        return 1

    try:
        preset = resolve_preset(args.preset)
        print(f"Import [{preset.name}] từ {args.source}")
        files = import_slices(preset, args.source)
        if not args.dry_run:
            build_tsx_from_files(preset, files)
        else:
            print(f"  [dry-run] tạo {preset.tsx_path.relative_to(REPO_ROOT)}")
    except FileNotFoundError as error:
        print(f"Lỗi: {error}", file=sys.stderr)
        return 1

    if args.no_scale or args.dry_run:
        return 0

    print(f"Scale ×{args.scale}")
    return cmd_scale(
        argparse.Namespace(
            preset=args.preset,
            input=None,
            tsx=None,
            backup_dir=None,
            scale=args.scale,
            update_tsx=True,
            backup=args.backup,
            dry_run=False,
        ),
    )


def cmd_init_tsx(args: argparse.Namespace) -> int:
    if args.preset is None:
        print("Lỗi: init-tsx cần --preset", file=sys.stderr)
        return 1

    try:
        preset = resolve_preset(args.preset)
        files = collect_pngs(preset.input_dir)
    except (FileNotFoundError, ValueError) as error:
        print(f"Lỗi: {error}", file=sys.stderr)
        return 1

    if args.dry_run:
        print(f"[dry-run] init-tsx {preset.name} — {len(files)} file")
        return 0

    build_tsx_from_files(preset, files)
    return 0


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(
        description="Import / scale mossy slice PNGs + Tiled .tsx",
    )
    sub = parser.add_subparsers(dest="command", required=True)

    scale = sub.add_parser("scale", help="Phóng PNG đã có + cập nhật .tsx")
    scale.add_argument("--preset", choices=sorted(PRESETS))
    scale.add_argument("--input", type=Path)
    scale.add_argument("--tsx", type=Path)
    scale.add_argument("--backup-dir", type=Path)
    scale.add_argument("--scale", type=float, default=2.0)
    scale.add_argument("--update-tsx", action="store_true", default=True)
    scale.add_argument("--no-update-tsx", action="store_false", dest="update_tsx")
    scale.add_argument("--backup", action="store_true", default=True)
    scale.add_argument("--no-backup", action="store_false", dest="backup")
    add_common_flags(scale)
    scale.set_defaults(func=cmd_scale)

    imp = sub.add_parser("import", help="Copy từ folder ngoài → slices + .tsx + scale")
    imp.add_argument("--preset", required=True, choices=sorted(PRESETS))
    imp.add_argument("--from", dest="source", type=Path, required=True)
    imp.add_argument("--scale", type=float, default=2.0)
    imp.add_argument("--no-scale", action="store_true")
    imp.add_argument("--backup", action="store_true", default=True)
    imp.add_argument("--no-backup", action="store_false", dest="backup")
    add_common_flags(imp)
    imp.set_defaults(func=cmd_import)

    init = sub.add_parser("init-tsx", help="Tạo .tsx từ PNG hiện có (không scale)")
    init.add_argument("--preset", required=True, choices=sorted(PRESETS))
    add_common_flags(init)
    init.set_defaults(func=cmd_init_tsx)

    return parser


def main() -> int:
    parser = build_parser()
    args = parser.parse_args()
    return args.func(args)


if __name__ == "__main__":
    raise SystemExit(main())
