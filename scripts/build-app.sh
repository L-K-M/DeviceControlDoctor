#!/bin/bash
# Builds dist/DeviceControlDoctor.app from the SwiftPM package, copies the
# committed icon and Info.plist into the bundle, signs it and verifies the
# signature.
#
#   scripts/build-app.sh [--debug] [--universal]
#
# --debug builds the Debug configuration (scripts/build.sh --debug reaches this
# through lkm-build's swiftpm kind). --universal builds a fat arm64+x86_64
# binary; the default is the host architecture, which is faster for local runs.
# DCD_BUILD_DIR and/or DCD_OUTPUT_DIR override the build and output
# directories.
set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
BUILD_DIR="${DCD_BUILD_DIR:-$PROJECT_ROOT/.build}"
OUTPUT_DIR="${DCD_OUTPUT_DIR:-$PROJECT_ROOT/dist}"
APP_PATH="$OUTPUT_DIR/DeviceControlDoctor.app"

CONFIGURATION=release
ARCH_ARGS=()
for arg in "$@"; do
  case "$arg" in
    --debug) CONFIGURATION=debug ;;
    --universal) ARCH_ARGS=(--arch arm64 --arch x86_64) ;;
    *) echo "error: unknown option '$arg' (expected --debug or --universal)" >&2; exit 2 ;;
  esac
done

mkdir -p "$BUILD_DIR" "$OUTPUT_DIR"
export CLANG_MODULE_CACHE_PATH="$BUILD_DIR/clang-cache"
export SWIFTPM_MODULECACHE_OVERRIDE="$BUILD_DIR/module-cache"

cd "$PROJECT_ROOT"
swift build --configuration "$CONFIGURATION" --scratch-path "$BUILD_DIR" --cache-path "$BUILD_DIR/package-cache" --disable-sandbox ${ARCH_ARGS[@]+"${ARCH_ARGS[@]}"}
BIN_DIR="$(swift build --configuration "$CONFIGURATION" --scratch-path "$BUILD_DIR" --cache-path "$BUILD_DIR/package-cache" --disable-sandbox --show-bin-path ${ARCH_ARGS[@]+"${ARCH_ARGS[@]}"})"

mkdir -p "$APP_PATH/Contents/MacOS" "$APP_PATH/Contents/Resources"
cp "$BIN_DIR/DeviceControlDoctor" "$APP_PATH/Contents/MacOS/DeviceControlDoctor"
cp "$PROJECT_ROOT/Resources/Info.plist" "$APP_PATH/Contents/Info.plist"
cp "$PROJECT_ROOT/Resources/AppIcon.icns" "$APP_PATH/Contents/Resources/AppIcon.icns"
printf 'APPL????' > "$APP_PATH/Contents/PkgInfo"

# Set CODE_SIGN_IDENTITY for a stable Apple Development or Developer ID identity.
# Ad-hoc signing is sufficient for a local build; no privacy grant is requested.
if [[ -n "${CODE_SIGN_IDENTITY:-}" ]]; then
    codesign --force --options runtime --sign "$CODE_SIGN_IDENTITY" "$APP_PATH"
else
    codesign --force --sign - "$APP_PATH"
fi
codesign --verify --strict --verbose=2 "$APP_PATH"
printf '\nBuilt %s\n' "$APP_PATH"
