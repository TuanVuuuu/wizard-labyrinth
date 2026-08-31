#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
WEB_BUILD_DIR="$PROJECT_ROOT/build/web"
VERSION_FILE="$WEB_BUILD_DIR/wl_deploy_version.json"
INDEX_FILE="$WEB_BUILD_DIR/index.html"

cd "$PROJECT_ROOT"

if ! command -v fvm >/dev/null 2>&1; then
  echo "Không tìm thấy fvm. Cài FVM rồi chạy lại." >&2
  exit 1
fi

if ! command -v firebase >/dev/null 2>&1; then
  echo "Không tìm thấy firebase CLI. Cài firebase-tools rồi chạy lại." >&2
  exit 1
fi

DEPLOY_VERSION="$(date -u +"%Y%m%d%H%M%S")"
if git rev-parse --short HEAD >/dev/null 2>&1; then
  DEPLOY_VERSION="${DEPLOY_VERSION}-$(git rev-parse --short HEAD)"
fi

echo "==> Xóa build web cũ"
rm -rf "$WEB_BUILD_DIR"

echo "==> Build Flutter web (tắt PWA/service worker)"
fvm flutter build web --release --pwa-strategy=none \
  --dart-define="WL_DEPLOY_VERSION=${DEPLOY_VERSION}"

if [[ ! -f "$INDEX_FILE" ]]; then
  echo "Không tìm thấy $INDEX_FILE sau khi build." >&2
  exit 1
fi

cp "$PROJECT_ROOT/web/wl_service_worker_kill.js" \
  "$WEB_BUILD_DIR/flutter_service_worker.js"
rm -f "$WEB_BUILD_DIR/flutter_service_worker.js.map"

echo "==> Gắn version $DEPLOY_VERSION"
python3 - "$VERSION_FILE" "$DEPLOY_VERSION" <<'PY'
import json
import sys
from pathlib import Path

version_path = Path(sys.argv[1])
version = sys.argv[2]
version_path.write_text(json.dumps({"version": version}, indent=2) + "\n")
PY

if [[ "$(uname)" == "Darwin" ]]; then
  sed -i '' "s/WL_DEPLOY_VERSION/${DEPLOY_VERSION}/g" "$INDEX_FILE"
else
  sed -i "s/WL_DEPLOY_VERSION/${DEPLOY_VERSION}/g" "$INDEX_FILE"
fi

SOURCE_MAP="$PROJECT_ROOT/assets/maps/zone1_slice.tmx"
BUILT_MAP="$WEB_BUILD_DIR/assets/assets/maps/zone1_slice.tmx"
if [[ -f "$SOURCE_MAP" && -f "$BUILT_MAP" ]]; then
  echo "==> Kiểm tra map trong build"
  python3 - <<PY
import hashlib
from pathlib import Path
src = Path("$SOURCE_MAP").read_bytes()
built = Path("$BUILT_MAP").read_bytes()
print("  source md5:", hashlib.md5(src).hexdigest())
print("  built   md5:", hashlib.md5(built).hexdigest())
if src != built:
    raise SystemExit("Map trong build khác source — kiểm tra assets/maps/")
PY
fi

echo "==> Deploy Firebase Hosting"
firebase deploy --only hosting

echo
echo "Xong. Version: $DEPLOY_VERSION"
echo "https://wizardlabyrinth-9b1c2.web.app"
echo "https://wizardlabyrinth-9b1c2.firebaseapp.com"
