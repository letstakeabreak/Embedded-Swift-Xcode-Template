# Embedded Swift Xcode Template for ESP32-C6

A complete Xcode project template for building ESP32-C6 firmware in Swift using the Embedded Swift toolchain and ESP-IDF.

## Features

✅ **Native Swift on Microcontrollers** — Write ESP32-C6 firmware in Swift, not C/C++  
✅ **Xcode Integration** — Full Xcode build and flash support via `Cmd+B`  
✅ **FreeRTOS Support** — Access FreeRTOS APIs through bridging headers  
✅ **Automated Setup** — Single `install.sh` for toolchain and environment  
✅ **Cross-Platform** — Tested on macOS (Intel & Apple Silicon)  

## Quick Start

### 1. Install Tools
```bash
bash install.sh
```

This installs:
- ESP-IDF 6.1 → `~/.espswift/esp-idf/`
- Embedded Swift toolchain via `swiftly`
- Xcode template to `~/Library/Developer/Xcode/Templates/`

### 2. Create Project in Xcode
- File → New → Project
- Select "ESP32-C6" template
- Choose a name and location
- Build with `Cmd+B`

### 3. Flash to Device
```bash
./scripts/flash.sh ~/path/to/project/ProjectName
```

Or enable automatic flashing in Xcode by adding a Run Script phase.

## Architecture

```
Embedded-Swift-Xcode-Template/
├── install.sh                    # Setup script
├── scripts/
│   ├── detect_port.sh           # Find connected ESP32-C6
│   └── flash.sh                 # Flash firmware via idf.py
└── Xcode Template/
    └── ESP32-C6.xctemplate/
        ├── TemplateInfo.plist   # Xcode project configuration
        ├── build.sh             # ESP-IDF build wrapper for Xcode
        ├── CMakeLists.txt       # Root CMake configuration
        ├── main/
        │   ├── CMakeLists.txt   # Component configuration
        │   ├── idf_component.yml
        │   ├── BridgingHeader.h # C ↔ Swift bridge
        │   └── main.swift       # Entry point
        └── ...
```

## Swift Firmware Example

```swift
@_cdecl("app_main")
public func app_main() {
    print("Hello from Embedded Swift on ESP32-C6!")
    
    var counter: UInt32 = 0
    
    while true {
        vTaskDelay(pdMS_TO_TICKS(1000))
        counter += 1
        print("Tick \(counter)...")
    }
}
```

## System Requirements

- macOS 12+
- Xcode 15+
- ESP32-C6 board with USB connection
- ~3GB disk space for ESP-IDF and toolchains

## Known Issues

- Embedded Swift is still experimental; expect limitations in standard library coverage
- Some FreeRTOS APIs may need custom bridging headers
- Build times are longer due to full recompilation with each template

## License

MIT

## References

- [Embedded Swift Documentation](https://www.swift.org/embedded/)
- [ESP-IDF Documentation](https://docs.espressif.com/projects/esp-idf/en/latest/esp32c6/)
- [ESP32-C6 Datasheet](https://www.espressif.com/sites/default/files/documentation/esp32-c6_datasheet_en.pdf)
