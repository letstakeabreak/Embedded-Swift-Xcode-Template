# Embedded Swift Xcode Template for ESP32-C6

A zero-configuration Xcode project template for Embedded Swift development 
on the ESP32-C6 (RISC-V). Run one script, and everything is set up for you — 
no manual toolchain installation required.

---

## Requirements

- macOS 14 or later
- Xcode 16 or later
- Internet connection (for initial installation)

---

## Installation

Clone this repository and run the install script:

```bash
git clone https://github.com/letstakeabreak/Embedded-Swift-Xcode-Template.git
cd Embedded-Swift-Xcode-Template
bash install.sh
```

The script will automatically install:

1. **ESP-IDF** — Espressif's official IoT Development Framework, 
   targeting ESP32-C6
2. **Embedded Swift toolchain** — via swiftly, the official Swift 
   toolchain manager
3. **Xcode Template** — copied to the correct Xcode template directory

---

## Usage

1. Open Xcode and create a new project (`Cmd+Shift+N`)
2. Select **Other** → **ESP32-C6 Embedded Swift**
3. Connect your ESP32-C6 via USB
4. Build and run — the project will automatically detect your device 
   and flash the binary

---

## Project Structure

```
Embedded-Swift-Xcode-Template/
├── install.sh                  # One-shot installation script
├── scripts/
│   ├── detect_port.sh          # Automatically detects the ESP32-C6 serial port
│   └── flash.sh                # Flashes the compiled binary via esptool
└── Xcode Template/
    └── ESP32-C6.xctemplate/
        ├── TemplateInfo.plist  # Xcode template metadata
        └── main.swift          # Default Blink example (GPIO8)
```

---

## Known Issues

### Xcode Template not appearing in New Project dialog

The template is correctly installed to the Xcode templates directory, 
but does not yet appear in the New Project dialog. This is a known issue 
and is being tracked in [#1](https://github.com/letstakeabreak/Embedded-Swift-Xcode-Template/issues/1).

If you know how to fix this, please open a PR or leave a comment on the issue!

---

## Roadmap

- [ ] Fix Xcode Template visibility issue
- [ ] `espswift-idf` Swift Package for ESP-IDF C API bindings (WiFi, BLE, GPIO, etc.)
- [ ] Support for additional ESP32 variants (C3, S3, H2)
- [ ] Automatic `swiftly init` non-interactive mode

---

## Contributing

Contributions are very welcome! Feel free to open an issue or a pull request.

This project is intended to lower the barrier to entry for Embedded Swift 
development, and is being developed as part of the Swift Mentorship Program.

---

## License

MIT License. See [LICENSE](LICENSE) for details.