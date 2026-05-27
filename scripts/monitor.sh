#!/bin/bash
# monitor.sh
# Opens a serial monitor for the connected ESP32-C6.
#
# This script reads serial output from a connected ESP32-C6 board
# and streams it to stdout. Designed to be called from:
#   - Terminal directly
#   - Xcode Scheme as Executable (output goes to Xcode console)
#   - Build Post-action

# Use ESP-IDF's Python environment (has pyserial pre-installed).
IDF_PYTHON=$(find "$HOME/.espressif/python_env" -maxdepth 1 -type d -name "idf*py3.11*" | head -1)/bin/python

if [ ! -x "$IDF_PYTHON" ]; then
    echo "Error: ESP-IDF Python environment not found." >&2
    echo "Please run install.sh first." >&2
    exit 1
fi

# Detect the connected ESP32-C6 port.
DETECT_PORT="$(dirname "$0")/detect_port.sh"
PORT=$(bash "$DETECT_PORT")

if [ $? -ne 0 ]; then
    echo "Error: No ESP32-C6 device found." >&2
    echo "Make sure the device is connected via USB." >&2
    exit 1
fi

echo "================================================="
echo " ESP32-C6 Serial Monitor"
echo " Port: $PORT @ 115200 baud"
echo " Press Ctrl+C to exit"
echo "================================================="

# Stream serial output to stdout using pyserial.
# We use stdout flushing to ensure real-time output to Xcode console.
"$IDF_PYTHON" -c "
import serial
import sys

port = '$PORT'
baud = 115200

try:
    ser = serial.Serial(port, baud, timeout=0.1)
    while True:
        data = ser.read(1024)
        if data:
            sys.stdout.write(data.decode('utf-8', errors='replace'))
            sys.stdout.flush()
except KeyboardInterrupt:
    print('\n=================================================')
    print(' Disconnected.')
    print('=================================================')
    ser.close()
except Exception as e:
    print(f'Error: {e}', file=sys.stderr)
    sys.exit(1)
"
