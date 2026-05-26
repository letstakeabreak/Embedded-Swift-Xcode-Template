#!/bin/bash

# flash.sh
# Flashes a built ESP32-C6 project to a connected device.
#
# This script is typically called from the Xcode Run Script Phase after
# a successful build, but it can also be run manually from the terminal.
#
# Rather than calling esptool.py directly with a single binary, we delegate
# the actual flashing to `idf.py flash`. ESP-IDF projects are not just a
# single .bin file — they consist of three separate binaries that must
# all be written to specific flash offsets:
#
#   1. Bootloader      (build/bootloader/bootloader.bin)     -> 0x0
#   2. Partition table (build/partition_table/partition.bin) -> 0x8000
#   3. Application     (build/<PROJECT>.bin)                 -> 0x10000
#
# `idf.py flash` reads the build directory's flash_args file and writes
# all three binaries in one operation. This is safer than flashing the
# application alone, since mismatched bootloader/partition/app versions
# can cause SHA-256 verification failures at boot time.
#
# Usage: bash flash.sh <project_directory>
# Where <project_directory> is the folder containing CMakeLists.txt
# and a build/ subdirectory (e.g. ~/Developer/MyProject/MyProject).

# ── Argument Validation ──────────────────────────────────────────

# This script expects the path to the project directory as its first
# argument. When called from Xcode, this is the directory containing
# CMakeLists.txt; when called manually, the user provides it.
PROJECT_DIR="$1"

# If no argument was given, $1 is empty. -z tests for empty string.
if [ -z "$PROJECT_DIR" ]; then
    echo "Error: No project directory provided." >&2
    echo "Usage: bash flash.sh <project_directory>" >&2
    exit 1
fi

# The build/ subdirectory is created by idf.py build. Its absence means
# the project hasn't been built yet, so there's nothing to flash.
# -d tests whether the path exists and is a directory.
if [ ! -d "$PROJECT_DIR/build" ]; then
    echo "Error: Build directory not found at $PROJECT_DIR/build" >&2
    echo "Please build the project first." >&2
    exit 1
fi

# ── ESP-IDF Environment Setup ────────────────────────────────────

# Point IDF_PATH at the ESP-IDF installation managed by install.sh.
# All ESPSwift installations live under ~/.espswift/ for predictability.
export IDF_PATH="$HOME/.espswift/esp-idf"

# Xcode's PATH is heavily restricted and does not include Homebrew,
# so /opt/homebrew/bin must be added explicitly before sourcing
# export.sh, or ESP-IDF's setup script will fail to find python3.
# We prepend Homebrew paths so they take precedence over any
# system-bundled Python that might be too old.
export PATH="/opt/homebrew/bin:/opt/homebrew/sbin:/usr/local/bin:$PATH"

# Locate the ESP-IDF Python virtual environment. ESP-IDF installs its
# Python dependencies into a versioned directory like:
#   ~/.espressif/python_env/idf6.1_py3.11_env/
# The version suffix changes between ESP-IDF releases, so we glob for
# any matching directory and take the first one. (-maxdepth 1 prevents
# find from descending into the matched directories; head -1 picks the
# first result in case there are multiple installations.)
IDF_PYTHON_ENV_PATH=$(find "$HOME/.espressif/python_env" -maxdepth 1 -type d -name "idf*py3.11*" | head -1)
export IDF_PYTHON_ENV_PATH

# Source ESP-IDF's setup script. This adds idf.py to PATH and exports
# additional environment variables (IDF_TOOLS_EXPORT_CMD, etc.) that
# idf.py needs to find its tools.
source "$IDF_PATH/export.sh"

# ── Port Detection ───────────────────────────────────────────────

# Find detect_port.sh in the same directory as this script.
# $0 is this script's path; dirname strips the filename to give the
# containing directory. Using "$(dirname "$0")" makes flash.sh
# location-independent — it works regardless of where the user runs it.
DETECT_PORT="$(dirname "$0")/detect_port.sh"

echo "Detecting ESP32-C6..."

# Run the port detection script and capture its stdout into PORT.
# detect_port.sh prints the device path (e.g. /dev/cu.usbmodem...) on
# success and exits 0, or prints an error to stderr and exits 1.
PORT=$(bash "$DETECT_PORT")

# $? holds the exit code of the most recent command. A non-zero exit
# code from detect_port.sh means no device was found.
if [ $? -ne 0 ]; then
    echo "Error: Could not detect ESP32-C6. Is it connected via USB?" >&2
    exit 1
fi

echo "Found Device at $PORT"

# ── Flashing ─────────────────────────────────────────────────────

# idf.py must be run from the project directory. cd with `|| exit 1`
# ensures we abort if the directory becomes unavailable between the
# check above and this point (race condition guard).
cd "$PROJECT_DIR" || exit 1

echo "Flashing project to $PORT..."

# Run idf.py flash with the detected port.
#   -p <port>  : the serial port to write to.
#   flash      : the action; reads build/flash_args and writes all
#                three binaries (bootloader, partition table, app).
# idf.py handles baud rate negotiation, reset sequencing, and SHA
# verification automatically.
idf.py -p "$PORT" flash

echo "Flash complete."