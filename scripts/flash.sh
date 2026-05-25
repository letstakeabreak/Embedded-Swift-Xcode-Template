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

