#!/bin.bash

# flash.sh
# Builds the project and flashes it to a connected ESP32-C6 device.
#
# This script is called automatically from the Xcode Run Script Phase
# after a successful build. It detects the connected ESP32-C6 port
# using detect_port.sh, then flashes the binary using esptool.py
# from the ESPSwift-managed ESP-IDF installation.
#
# Usage: bash flash.sh <binary_path>

# ---- Constants ----

# Path to esptool.py within the ESPSwift-managed ESP-IDF installation.
# This path is fixed because install.sh always installs ESP-IDF to
# ~/.espswift/esp-idf, so we never need to search for it.
ESPTOOL="$HOME/.espswift/esp-idf/components/esptool_py/esptool/esptool.py"

# Path to the port detection script, located alongside this script.
DETECT_PORT="$(dirname "$0")/detect_port.sh"

# ---- Argument Validation ----

# This script expects the path to the compiled binary as its first argument.
# It is passed automatically by the Xcode Run Script Phase.
BINARY_PATH="$1"

if [ -z "$BINARY_PATH" ]; then
    echo "Error: No binary path provided." >&2
    echo "Usage: bash flash.sh <binary_path>" >&2
    exit 1
fi

if [ ! -f "$BINARY_PATH" ]; then
    echo "Error: Binary not found at path: $BINARY_PATH" >&2
    exit 1
fi

# ---- Port Detection ----

echo "Detecting ESP32-C6..."

# Run the port detection script and capture the result.
PORT=$(bash "$DETECT_PORT")

if [ $? -ne 0 ]; then
    echo "Error: Could not detect ESP32-C6. Is it connected via USB?" >&2
    exit 1
fi

echo "Found Device at $PORT"

# ---- Flashing ----

echo "Flashing $BINARY_PATH to $PORT..."

# Flash the binary using esptool.py.
# --chip esp32c6  : target chip
# --port          : the detected serial port.
# --baud 460800   : baud rate (460800 is stable and fast for ESP32-C6)
# write_flash 0x0 : write to flash starting at address 0x0
python3 "$ESPTOOL" \
    --chip esp32c6 \
    --port "$PORT" \
    --baud 460800 \
    write_flash 0x0 "$BINARY_PATH"

echo "Flash complete."