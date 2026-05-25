#!/bin/bash

# install.sh
# ESPSwift Template installer script.

# This script sets up the complete development environment for
# Embedded Swift on ESP32-C6, including ESP-IDF and the Embedded
# Swift toolchain. All tools are installed under ~/.espswift. to
# ensure a predictable, isolated path that the Xcode build scripts
# can always rely on.

# Usage: bash install.sh

# Exit immediately if any command fails.
# This prevents the script from continuing in a broken state.
set -e

# ---- Constants ----

# Root directory for all ESPSwift-managed tools.
# Keeping everything under one directory makes uninstallation easy
# and avoids conflicts with other ESP-IDF installations the user
# might already have.
ESPSWIFT_HOME = "$HOME/.espswift"

# ESP-IDF will be cloned into this subdirectory.
IDF_PATH = "$ESPSWIFT_HOME/esp-idf"

# ESP-IDF's own tool installer (xtensa toolchain, openocd, etc.)
# will place binaries here instead of the default ~/.espressif/.
IDF_TOOLS_PATH = "$ESPSWIFT_HOME/tools"

# ---- Setup ----

echo "Starting ESPSwift installation..."

# Create the root directory if it does not exist.
mkdir -p "$ESPSWIFT_HOME"

# ---- Step 1 : ESP-IDF ----

echo "[1/3] Installing ESP-IDF..."

if [ -d "$IDF_PATH" ]; then
    # Skip cloning if ESP-IDF is already present.
    # The user can run this script again safely without re-downloading.
    echo "ESP-IDF already installed. Skipping."
else
    # Clone ESP-IDF with all submodules.
    # --recursive is required because ESP-IDF depends on several
    # git submodules (mbedtls, esp-mqtt, etc.).
    git clone --recursive https://github.com/espressif/esp-idf.git "$IDF_PATH"
    
    # Install only the ESP32-C6 target to minimize download size.
    # Passing IDF_TOOLS_PATH redirects all binaries to ~/.espswift/tools/
    # instead of the default ~/.espressif/.
    export IDF_TOOLS_PATH="$IDF_TOOLS_PATH"
    "$IDF_PATH/install.sh" --target esp32c6

    echo "ESP-IDF installed successfully."
fi