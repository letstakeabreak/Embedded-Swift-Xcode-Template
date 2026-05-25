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
ESPSWIFT_HOME="$HOME/.espswift"

# ESP-IDF will be cloned into this subdirectory.
IDF_PATH="$ESPSWIFT_HOME/esp-idf"

# ESP-IDF's own tool installer (xtensa toolchain, openocd, etc.)
# will place binaries here instead of the default ~/.espressif/.
IDF_TOOLS_PATH="$ESPSWIFT_HOME/tools"

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
    "$IDF_PATH/install.sh" esp32c6

    echo "ESP-IDF installed successfully."
fi


# ---- Step 2: Embedded Swift Toolchain (via swiftly) ----

echo "[2/3] Installing Embedded Swift toolchain..."

# swiftly is the official Swift toolchain installer and manager.
# We use it instead of manually downloading snapshot tarballs,
# so that toolchain updates are handled cleanly in the future.
SWIFTLY_BIN="$HOME/.swiftly/bin/swiftly"

if ! command -v "$SWIFTLY_BIN" &>/dev/null; then
    echo "swiftly not found. Installing swiftly..."

    # Download the official swiftly pkg installer from swift.org.
    curl -L https://download.swift.org/swiftly/darwin/swiftly.pkg -o /tmp/swiftly.pkg

    # Install swiftly into the current user's home directory.
    # -target CurrentUserHomeDirectory installs to ~/swiftly/
    # without requiring sudo.
    installer -pkg /tmp/swiftly.pkg -target CurrentUserHomeDirectory

    # Clean up the downloaded pkg.
    rm /tmp/swiftly.pkg

    echo "swiftly installed successfully."
fi

# Initialize swiftly without installing the latest release toolchain.
# --skip-install avoids downloading the stable release toolchain,
# since Embedded Swift requires a development snapshot, not a release.
# --no-modify-profile prevents swiftly from editing ~/.zshrc or ~/.bashrc,
# as we manage PATH ourselevs in this script.
"$SWIFTLY_BIN" init --skip-install --no-modify-profile --assume-yes

# Install the latest main development snapshot.
# Embedded Swift is not yet available in stable releases,
# so we must use a main-snapshot toolchain (Swift 6.2 dev or later).
"$SWIFTLY_BIN" install main-snapshot

echo "Embedded Swift toolchain installed successfully."

# ---- Step 3: Install Xcode Template ----

echo "[3/3] Installing Xcode template..."

# The directory where Xcode looks for custom project templates.
XCODE_TEMPLATES_DIR="$HOME/Library/Developer/Xcode/Templates/Project Templates/Other"
XCODE_BUILTIN_TEMPLATE="/Applications/Xcode.app/Contents/Developer/Library/Xcode/Templates/Project Templates/Other/External Build System.xctemplate"
TARGET_TEMPLATE="$XCODE_TEMPLATES_DIR/ESP32-C6.xctemplate"

# Create the directory if it does not exist.
# This is common on fresh macOS installations where Xcode Templates
# have never been customized before.
mkdir -p "$XCODE_TEMPLATES_DIR"

# Start from Xcode's built-in External Build System template,
# which already has the correct Targets, Options, and Image keys.
# We'll then overlay our customizations on top.
cp -R "$XCODE_BUILTIN_TEMPLATE" "$TARGET_TEMPLATE"

# Overlay our custom files (main.swift) and overwrite TemplateInfo.plist.
# -R copies the directory recursively.
# Existing files will be overwritten, so re-running install.sh
# always gives the user the latest version of the template.
cp -R "$(dirname "$0")/Xcode Template/ESP32-C6.xctemplate/"* "$TARGET_TEMPLATE/"

echo "Xcode Template installed successfully."

# ---- Done ----

echo ""
echo "Installation complete."
echo "Restart Xcode and create a new project to use the ESP32-C6 Embedded Swift template."