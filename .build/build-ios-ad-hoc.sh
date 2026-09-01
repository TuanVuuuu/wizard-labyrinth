#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OUTPUT_DIR="${SCRIPT_DIR}/ipa"
EXPORT_OPTIONS_PLIST="${SCRIPT_DIR}/export-options-ad-hoc.plist"

TEAM_ID="${TEAM_ID:-66Z9XCJX4K}"
BUILD_NAME="${BUILD_NAME:-}"
BUILD_NUMBER="${BUILD_NUMBER:-}"

usage() {
  cat <<'EOF'
Usage: .build/build-ios-ad-hoc.sh [--clean]

Build a signed ad-hoc IPA with FVM Flutter.

Optional env:
  TEAM_ID        Apple Developer Team ID (default: 66Z9XCJX4K)
  BUILD_NAME     CFBundleShortVersionString (e.g. 1.0.0)
  BUILD_NUMBER   CFBundleVersion (e.g. 12)

Output:
  .build/ipa/Wizard-adhoc.ipa
EOF
}

require_command() {
  local name="$1"
  if ! command -v "${name}" >/dev/null 2>&1; then
    echo "error: '${name}' is not installed or not on PATH" >&2
    exit 1
  fi
}

write_export_options() {
  cat > "${EXPORT_OPTIONS_PLIST}" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>method</key>
	<string>ad-hoc</string>
	<key>teamID</key>
	<string>${TEAM_ID}</string>
	<key>compileBitcode</key>
	<false/>
	<key>signingStyle</key>
	<string>automatic</string>
	<key>stripSwiftSymbols</key>
	<true/>
	<key>uploadSymbols</key>
	<false/>
</dict>
</plist>
EOF
}

copy_ipa() {
  local src
  src="$(find "${ROOT_DIR}/build/ios/ipa" -name '*.ipa' -type f | head -n 1)"
  if [[ -z "${src}" ]]; then
    echo "error: IPA not found under build/ios/ipa" >&2
    exit 1
  fi

  mkdir -p "${OUTPUT_DIR}"
  local stamp
  stamp="$(date +%Y%m%d-%H%M%S)"
  cp "${src}" "${OUTPUT_DIR}/Wizard-adhoc.ipa"
  cp "${src}" "${OUTPUT_DIR}/Wizard-adhoc-${stamp}.ipa"

  echo
  echo "==> IPA ready"
  echo "    ${OUTPUT_DIR}/Wizard-adhoc.ipa"
  echo "    ${OUTPUT_DIR}/Wizard-adhoc-${stamp}.ipa"
  ls -lh "${OUTPUT_DIR}/Wizard-adhoc.ipa"
}

main() {
  local should_clean=0
  case "${1:-}" in
    -h|--help)
      usage
      exit 0
      ;;
    --clean)
      should_clean=1
      ;;
    "")
      ;;
    *)
      echo "error: unknown argument '${1}'" >&2
      usage >&2
      exit 1
      ;;
  esac

  require_command fvm
  require_command xcodebuild

  cd "${ROOT_DIR}"
  write_export_options

  if [[ "${should_clean}" -eq 1 ]]; then
    echo "==> fvm flutter clean"
    fvm flutter clean
  fi

  echo "==> fvm flutter pub get"
  fvm flutter pub get

  local build_args=(
    build ipa
    --release
    --export-options-plist="${EXPORT_OPTIONS_PLIST}"
  )
  if [[ -n "${BUILD_NAME}" ]]; then
    build_args+=(--build-name="${BUILD_NAME}")
  fi
  if [[ -n "${BUILD_NUMBER}" ]]; then
    build_args+=(--build-number="${BUILD_NUMBER}")
  fi

  echo "==> fvm flutter ${build_args[*]}"
  fvm flutter "${build_args[@]}"

  copy_ipa
}

main "$@"
