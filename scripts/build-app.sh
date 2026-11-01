#!/bin/bash
set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
CONFIGURATION="${CONFIGURATION:-release}"
APP_PATH="$PROJECT_ROOT/build/DeviceControlDoctor.app"
cd "$PROJECT_ROOT"

swift build --configuration "$CONFIGURATION"
BIN_DIR="$(swift build --configuration "$CONFIGURATION" --show-bin-path)"
mkdir -p "$APP_PATH/Contents/MacOS" "$APP_PATH/Contents/Resources"
cp "$BIN_DIR/DeviceControlDoctor" "$APP_PATH/Contents/MacOS/DeviceControlDoctor"
cp "$PROJECT_ROOT/Resources/Info.plist" "$APP_PATH/Contents/Info.plist"
cp "$PROJECT_ROOT/Resources/AppIcon.icns" "$APP_PATH/Contents/Resources/AppIcon.icns"

# Set CODE_SIGN_IDENTITY for a stable Apple Development or Developer ID identity.
# Ad-hoc signing is sufficient for a local build; no privacy grant is requested.
if [[ -n "${CODE_SIGN_IDENTITY:-}" ]]; then
    codesign --force --options runtime --sign "$CODE_SIGN_IDENTITY" "$APP_PATH"
else
    codesign --force --sign - "$APP_PATH"
fi
codesign --verify --strict --verbose=2 "$APP_PATH"
printf '\nBuilt %s\n' "$APP_PATH"
