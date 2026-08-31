#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
PACKER="$SCRIPT_DIR/pack_spritesheet.py"

BLUE_WIZARD_SRC="${BLUE_WIZARD_SRC:-/Users/tuanvu/dev/game/MossyCavern/BlueWizard}"
OUTPUT_DIR="${OUTPUT_DIR:-$PROJECT_ROOT/assets/atlas}"

if [[ ! -d "$BLUE_WIZARD_SRC" ]]; then
  echo "Không tìm thấy BlueWizard source: $BLUE_WIZARD_SRC" >&2
  echo "Đặt biến BLUE_WIZARD_SRC trỏ tới thư mục BlueWizard." >&2
  exit 1
fi

mkdir -p "$OUTPUT_DIR"

pack_animation() {
  local folder_name="$1"
  local output_name="$2"
  local prefix="$3"

  local input_dir="$BLUE_WIZARD_SRC/$folder_name"
  if [[ ! -d "$input_dir" ]]; then
    echo "Bỏ qua (không có thư mục): $input_dir" >&2
    return 0
  fi

  echo "==> Packing $folder_name"
  python3 "$PACKER" \
    --input "$input_dir" \
    --output "$OUTPUT_DIR/$output_name" \
    --prefix "$prefix" \
    --layout horizontal
  echo
}

pack_animation "2BlueWizardIdle" "wizard_idle" "BlueWizardIdle"
pack_animation "2BlueWizardWalk" "wizard_walk" "BlueWizardWalk"
pack_animation "2BlueWizardJump" "wizard_jump" "BlueWizardJump"

echo "Xong. Atlas nằm trong: $OUTPUT_DIR"
