#!/bin/bash

# build.sh
# Build and flash entry point for the ESP32-C6 Embedded Swift Project.
#
# This script is invokeed by Xcode's Legacy build target. When the user
# presses CMD+B in Xcode, Xcode runs this script instead of using its
# own build system, because compilation is delegated to ESP-IDF.
# 
# Usage: bash build.sh <action>
# <action> is passed by Xcode and can be "build", "clean", etc.

set -e

# ---- Constants ----

# Path to ESP-IDF, installed by install.sh
ESPSWIFT_HOME="$HOME/.espswift"
IDF_PATH="$ESPSWIFT_HOME/esp-idf"
IDF_TOOLS_PATH="$ESPSWIFT_HOME/tools"

# Path to our flash script, located alongside this build script.
FLASH_SCRIPT="$(dirname "$0")/flash.sh"

# Action passed by Xcode (build, clean, etc.).
ACTION="${1:-build}"

# ---- Environment Setup ----

# Export IDF_TOOLS_PATH so ESP-IDF's export.sh uses our isolated tools.
export IDF_TOOLS_PATH

# Source ESP-IDF's environment setup.
# This sets IDF_PATH, PATH, and other variables required by idf.py.
# It must be sourced (not executed) so the variables persist in this shell.
source "$IDF_PATH/export.sh"

# ---- Build / Clean ----

case "$ACTION" in
    clean)
        echo "Cleaning build directory..."
        idf.py fullclean
        ;;
    build|"")
        echo "Build project for ESP32-C6..."
        idf.py set-target esp32c6
        idf.py build
        ;;
    *)
        echo "Unknown action: $ACTION" >&2
        exit 1
        ;;
esac

echo "Done."