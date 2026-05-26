#!/bin/bash

# build.sh
# Invoked by Xcode when the user presses Build (Cmd+B).
# Delegates the actual compilation to ESP-IDF, since the Embedded Swift
# toolchain and ESP-IDF are not directly integrated with Xcode's build system.

echo "================================================="
echo " ESP32-C6 Embedded Swift Build"
echo "================================================="

# Xcode provides PROJECT_DIR and PROJECT_NAME.
# The actual source files are in a subdirectory named after the project.
if [ -n "$PROJECT_DIR" ] && [ -n "$PROJECT_NAME" ]; then
    cd "$PROJECT_DIR/$PROJECT_NAME" || exit 1
fi

# ── ESP-IDF Setup ────────────────────────────────────────────────

# ESP-IDF is installed by install.sh into ~/.espswift/esp-idf.
# If a user has their own ESP-IDF and exported IDF_PATH, respect that.
if [ -z "$IDF_PATH" ]; then
    export IDF_PATH="$HOME/.espswift/esp-idf"
fi

if [ ! -d "$IDF_PATH" ]; then
    echo "Error: ESP-IDF not found at $IDF_PATH" >&2
    echo "Please run install.sh first." >&2
    exit 1
fi

# Xcode's PATH is restricted and does not include Homebrew.
# Explicitly add Homebrew and common Python locations.
export PATH="/opt/homebrew/bin:/opt/homebrew/sbin:/usr/local/bin:$PATH"

# Use the default ESP-IDF tools path (~/.espressif)
# IDF_TOOLS_PATH override did not work as expected during installation.
IDF_PYTHON_ENV_PATH=$(find "$HOME/.espressif/python_env" -maxdepth 1 -type d -name "idf*py3.11*" | head -1)
export IDF_PYTHON_ENV_PATH

# Source the ESP-IDF environment so idf.py is on PATH.
source "$IDF_PATH/export.sh"

# Use the specified Embedded Swift toolchain snapshot.
# idf_swift requires a development snapshot that supports Embedded Swift.
export TOOLCHAINS="swift-DEVELOPMENT-SNAPSHOT-2026-05-07-a"
export PATH="/Library/Developer/Toolchains/swift-DEVELOPMENT-SNAPSHOT-2026-05-07-a.xctoolchain/usr/bin:$PATH"

# ── Target Setup ─────────────────────────────────────────────────

# Set the target to esp32c6 on first build (creates sdkconfig).
if [ ! -f "sdkconfig" ]; then
    echo "Setting target to esp32c6..."
    idf.py set-target esp32c6
fi

# ── Action ───────────────────────────────────────────────────────

ACTION=${1:-build}

if [ "$ACTION" = "clean" ]; then
    echo "Cleaning project..."
    idf.py fullclean
else
    echo "Building project..."
    idf.py build
fi

echo "================================================="
echo " Build Complete"
echo "================================================="