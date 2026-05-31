#!/bin/bash

# build_dmg.sh
# Creates a distributable .dmg containing ESPSwiftInstaller.app.
#
# The resulting disk image follows the standard macOS drag-to-install
# pattern: the user opens the .dmg, drags the app to Applications,
# and launches it to begin installation.
#
# Usage: bash build_dmg.sh
#
# Output: installer/ESPSwiftInstaller.dmg

set -e

# ── Paths ────────────────────────────────────────────────────────

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
INSTALLER_DIR="$REPO_ROOT/installer"
BUILD_DIR="$INSTALLER_DIR/build/dmg"
OUTPUT_DMG="$INSTALLER_DIR/ESPSwiftInstaller.dmg"

# Find the most recently built Release .app
APP_PATH=$(find ~/Library/Developer/Xcode/DerivedData/ESPSwiftInstaller-*/Build/Products/Release/ \
    -name "ESPSwiftInstaller.app" -maxdepth 1 2>/dev/null | head -1)

if [ -z "$APP_PATH" ]; then
    echo "Error: ESPSwiftInstaller.app not found." >&2
    echo "Please build the Release target in Xcode first (Cmd+B)." >&2
    exit 1
fi

echo "Found app: $APP_PATH"

# ── Prepare staging directory ─────────────────────────────────────

rm -rf "$BUILD_DIR"
mkdir -p "$BUILD_DIR"

cp -R "$APP_PATH" "$BUILD_DIR/ESPSwiftInstaller.app"
ln -s /Applications "$BUILD_DIR/Applications"

# ── Create .dmg ───────────────────────────────────────────────────

echo "Creating .dmg..."

rm -f "$OUTPUT_DMG"

hdiutil create \
    -volname "ESPSwiftInstaller" \
    -srcfolder "$BUILD_DIR" \
    -ov \
    -format UDZO \
    "$OUTPUT_DMG"

echo ""
echo "Created: $OUTPUT_DMG"
echo "Size: $(du -sh "$OUTPUT_DMG" | cut -f1)"
