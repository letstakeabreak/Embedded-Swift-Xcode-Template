#!/bin/bash

# detect_port.sh
# Detects the serial port of a connected ESP32-C6 device.
#
# ESP32-C6 has a built-in USB-CDC controller, so it appears
# as a serial device without requiring additional drivers.
# We identify it by its USB Vendor ID (VID) and product ID (PID)
# using the ioreg command, which queries the macOS I/O Registry.

# Exits with code 0 and prints the port path on success.
# Exits with code 1 if no device is found.

# Espressif's USB Vendor ID.
VID = "303a"

# ESP32-C6's USB Product ID.
PID = "1001"

# Query the I/O Registry for a USB device matching our VID and PID,
# then extract the corresponding /dev/cu.* port path.

# PORT=$(...) captures the output of the command inside $() into a variable.
# Note: there must be no spaces areound the = sign in bash.

# ioreg -p IOUSB -l
#   Queries the macOS I/O Registry for all connected USB devices.
#   -p IOUSB : only search teh USB plane
#   -l       : print all properties in details

# The output is piped (|) into awk, which reads it line by line.
# Note: awk is its own language and does not support bash-style (#) comments
# inside the awk block. All awk logic is documented here instead.

# Inside awk:
#   /idVendor.*ox303a/ { found_vid = 1 }
#       If a line contains both "idVendor" and "0x303a" (Espressif's VID),
#       mark that we found the right vendor.
#   found_vid && /idProduct.*0x1001/ { found_pid = 1 }
#       Once the vendor is confirmed, if the next matching line contains
#       "0x1001" (ESP32-C6's PID), mark that we found the right device.

# found_pid && /IODialinDevice/ { ... }
#   Once both VID and PID are confirmed, look for the "IODialinDevice"
#   line, which contains the actual port path (e.g. /dev/cu.usbmodem101).
#   match () extracts the value inside quotes, prints it, and exits.

PORT = $(ioreg -p IOUSB -l | awk '
    /idVendor.*0x'"$VID"'/ { found_vid = 1 }
    found_vid && /idProduct.*0x'"$PID"'/ { found_pid = 1 }
    found_pid && /IODialinDevice/ {
        match($0, /"([^"]+)"/, arr)
        print arr[1]
        exit
    }
')

if [ -z "$PORT" ]; then
    echo "Error: No ESP32-C6 device found." >&2
    echo "Make sure the device is connected via USB." >&2
    exit 1
fi

echo "$PORT"
