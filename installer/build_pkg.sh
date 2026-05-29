#!/bin/bash

# build_pkg.sh
# Builds Embedded-Swift-Xcode-Template.pkg

set -e

# ── Paths ────────────────────────────────────────────────────────

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
INSTALLER_DIR="$REPO_ROOT/installer"
BUILD_DIR="$INSTALLER_DIR/build"
PAYLOAD_DIR="$BUILD_DIR/payload"
OUTPUT_PKG="$INSTALLER_DIR/Embedded-Swift-Xcode-Template.pkg"

# ── Clean ────────────────────────────────────────────────────────

rm -rf "$BUILD_DIR"
mkdir -p "$PAYLOAD_DIR/tmp/espswift-install"

# ── Copy payload ─────────────────────────────────────────────────
# Copy everything install.sh needs into the payload.

cp "$REPO_ROOT/install.sh" "$PAYLOAD_DIR/tmp/espswift-install/"
cp -R "$REPO_ROOT/scripts" "$PAYLOAD_DIR/tmp/espswift-install/"
cp -R "$REPO_ROOT/Xcode Template" "$PAYLOAD_DIR/tmp/espswift-install/"

# ── Build .pkg ───────────────────────────────────────────────────

pkgbuild \
    --root "$PAYLOAD_DIR" \
    --scripts "$INSTALLER_DIR/scripts" \
    --identifier "com.espswift.installer" \
    --version "0.1.0" \
    --install-location "/" \
    "$OUTPUT_PKG"

echo "Built: $OUTPUT_PKG"
