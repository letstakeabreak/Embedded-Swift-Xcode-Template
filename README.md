# Embedded Swift Xcode Template for ESP32-C6

Write ESP32-C6 firmware in Swift — build and flash directly from Xcode, just like Arduino IDE.

![Platform](https://img.shields.io/badge/platform-macOS-lightgrey)
![Swift](https://img.shields.io/badge/swift-Embedded-orange)
![License](https://img.shields.io/badge/license-MIT-blue)
![Status](https://img.shields.io/badge/status-Experimental%20Preview-yellow)

> ⚠️ **Experimental Preview** — This project is in active development. APIs, scripts, and installation paths may change without notice. Tested on macOS 26 with Apple Silicon.

> 🤖 **AI-assisted development** — This project was built with significant help from Claude (Anthropic) as a pair programming tool. Architecture decisions, debugging, and hardware validation were done by the author.

## Features

✅ **Native Swift on Microcontrollers** — Write ESP32-C6 firmware in Swift, not C/C++  
✅ **Xcode Integration** — `Cmd+B` builds and flashes automatically  
✅ **Serial Monitor** — `Cmd+R` streams board output to Xcode console  
✅ **One-Click Install** — Single `install.sh` sets up everything  
✅ **NeoPixel Ready** — WS2812 RGB LED example included  

---

## Demo

> 🎬 Demo video coming soon — NeoPixel RGB cycle running on ESP32-C6, built and flashed directly from Xcode.

---

## Quick Start

### Option 1: Installer App (Recommended)
Download and run `ESPSwiftInstaller.app` from [Releases](https://github.com/letstakeabreak/Embedded-Swift-Xcode-Template/releases).

### Option 2: Terminal
```bash
git clone https://github.com/letstakeabreak/Embedded-Swift-Xcode-Template.git
cd Embedded-Swift-Xcode-Template
bash install.sh
```

Installation takes 5–10 minutes (~3GB download).

### Create a Project
1. Restart Xcode
2. File → New → Project → Other → **ESP32-C6**
3. Connect your ESP32-C6 board via USB
4. Press `Cmd+B` — builds and flashes automatically
5. Press `Cmd+R` — opens serial monitor in Xcode console

---

## Serial Monitor

After the first build, pressing `Cmd+R` streams live serial output from the board directly into Xcode's debug console — no external tools needed.

=================================================
ESP32-C6 Serial Monitor
Port: /dev/cu.usbmodem... @ 115200 baud
Hello from Embedded Swift on ESP32-C6!
LED: Red
LED: Green
LED: Blue

> **Note:** Xcode's console is output-only. For interactive serial input, use an external tool like `screen /dev/cu.usbmodem... 115200`.

---

## Adding Libraries

To add an ESP-IDF component library:

```bash
bash scripts/add_library.sh espressif/led_strip led_strip.h
```

This automatically updates `main/idf_component.yml` and `main/BridgingHeader.h`.

Available libraries: [ESP-IDF Component Registry](https://components.espressif.com)

---

## Swift Firmware Example

```swift
@_cdecl("app_main")
public func app_main() {
    print("Hello from Embedded Swift on ESP32-C6!")

    while true {
        vTaskDelay(pd_ms_to_ticks(1000))
        print("Tick...")
    }
}
```

---

## FAQ

### Why is the Xcode destination set to "My Mac"?

This is expected. Xcode runs a macOS helper tool on your Mac, which builds and flashes firmware to the connected ESP32-C6 board over USB. The destination refers to where the helper runs, not where the firmware is deployed.

- **Xcode Destination**: My Mac (the helper runs here)
- **Actual Flash Target**: ESP32-C6 (connected via USB)

### Why does the first build take so long?

The first build downloads ESP-IDF component dependencies (~minutes). Subsequent builds are incremental and much faster (~35 seconds).

### My board isn't detected

Run `ls /dev/cu.*` with the board connected. Supported USB interfaces:
- Native USB-CDC → `/dev/cu.usbmodem*`
- WCH CH340 → `/dev/cu.wchusbserial*`
- CP210x → `/dev/cu.SLAB_USBtoUART*`

CH340-based boards may need a driver: [WCH CH340 Driver](https://www.wch-ic.com/downloads/CH341SER_MAC_ZIP.html)

### `Cmd+R` doesn't show serial output

After the first `Cmd+B`, close and reopen the project in Xcode. The serial monitor scheme is generated on first build and requires a project reload to take effect. ([#3](https://github.com/letstakeabreak/Embedded-Swift-Xcode-Template/issues/3))

---

## Architecture

Embedded-Swift-Xcode-Template/
├── install.sh                        # One-command environment setup
├── scripts/
│   ├── detect_port.sh               # Auto-detects connected ESP32-C6
│   ├── flash.sh                     # Flashes firmware via idf.py
│   ├── monitor.sh                   # Streams serial output to stdout
│   ├── setup_scheme.sh              # Auto-configures Xcode Run scheme
│   └── add_library.sh               # Adds ESP-IDF component libraries
├── installer/
│   ├── build_pkg.sh                 # Builds .pkg installer
│   └── ESPSwiftInstaller/           # SwiftUI installer app
└── Xcode Template/
└── ESP32-C6.xctemplate/
├── TemplateInfo.plist       # Xcode template configuration
├── build.sh                 # ESP-IDF build + flash wrapper
├── CMakeLists.txt           # Root CMake configuration
├── sdkconfig.defaults       # ESP-IDF defaults (watchdog off)
└── main/
├── CMakeLists.txt       # Component configuration
├── idf_component.yml    # ESP-IDF dependencies
├── BridgingHeader.h     # C ↔ Swift bridge
└── main.swift           # Firmware entry point

---

## System Requirements

- macOS 12+
- Xcode 15+
- ESP32-C6 board with USB connection
- ~3GB disk space

---

## What Gets Installed

Running `install.sh` or `ESPSwiftInstaller.app` installs the following into your home directory:

| Path | Contents |
|------|----------|
| `~/.espswift/esp-idf/` | ESP-IDF 6.1 (~2.5 GB) |
| `~/.espswift/scripts/` | Helper scripts (flash, monitor, etc.) |
| `~/.espressif/` | ESP-IDF Python tools and toolchains (~500 MB) |
| `~/.swiftly/` | swiftly toolchain manager |
| `~/Library/Developer/Toolchains/` | Embedded Swift snapshot toolchain |
| `~/Library/Developer/Xcode/Templates/` | ESP32-C6 Xcode template |

Nothing is installed to system directories. Everything is scoped to your user home directory.

---

## Uninstall

To completely remove ESPSwift:

```bash
# Remove ESP-IDF and helper scripts
rm -rf ~/.espswift

# Remove ESP-IDF Python tools
rm -rf ~/.espressif

# Remove Xcode template
rm -rf ~/Library/Developer/Xcode/Templates/Project\ Templates/Other/ESP32-C6.xctemplate

# Remove serial monitor binary
rm -f ~/Library/Developer/Toolchains/*.xctoolchain  # optional: removes Swift toolchain
```

> **Note:** Removing `~/.swiftly/` and `~/Library/Developer/Toolchains/` will also remove any other Swift toolchains managed by swiftly.

---

## Roadmap

This project is being developed as part of the [Swift Mentorship Program](https://www.swift.org/mentorship/).

**Near-term**
- [ ] Signed and notarized installer
- [ ] GPIO and I2C sensor examples
- [ ] Xcode scheme auto-reload without project reopen ([#3](https://github.com/letstakeabreak/Embedded-Swift-Xcode-Template/issues/3))
- [ ] Installer progress bar improvements ([#4](https://github.com/letstakeabreak/Embedded-Swift-Xcode-Template/issues/4))

**Longer-term**
- [ ] `espswift` CLI (doctor / build / flash / monitor)
- [ ] `espswift-idf` Swift Package (idiomatic Swift wrappers for ESP-IDF APIs)
- [ ] ESP32-C3 and ESP32-S3 support
- [ ] Homebrew tap

---

## Known Issues & Limitations

- Embedded Swift is experimental; not all Swift standard library features are available
- Xcode's serial console is read-only (no interactive input)
- Scheme auto-generation requires closing and reopening the project after first build ([#3](https://github.com/letstakeabreak/Embedded-Swift-Xcode-Template/issues/3))
- Build times are longer than native C/C++ due to full Swift recompilation

See all open issues: [GitHub Issues](https://github.com/letstakeabreak/Embedded-Swift-Xcode-Template/issues)

---

## License

MIT — see [LICENSE](LICENSE)

## References

- [Embedded Swift Documentation](https://www.swift.org/embedded/)
- [ESP-IDF Documentation](https://docs.espressif.com/projects/esp-idf/en/latest/esp32c6/)
- [ESP-IDF Component Registry](https://components.espressif.com)
- [ESP32-C6 Datasheet](https://www.espressif.com/sites/default/files/documentation/esp32-c6_datasheet_en.pdf)
