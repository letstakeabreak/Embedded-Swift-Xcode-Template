# Contributing to Embedded Swift Xcode Template

Thank you for your interest in contributing! This project aims to make Embedded Swift development on ESP32-C6 as approachable as possible — contributions of all kinds are welcome.

## Ways to Contribute

- **Bug reports** — Found something broken? Open an issue.
- **Feature requests** — Have an idea? Open an issue and describe it.
- **Documentation** — Improve README, add examples, fix typos.
- **Code** — Fix bugs, add features, improve scripts.
- **Testing** — Try the installer on a different machine and report results.

---

## Getting Started

### 1. Fork and clone

```bash
git clone https://github.com/<your-username>/Embedded-Swift-Xcode-Template.git
cd Embedded-Swift-Xcode-Template
```

### 2. Set up your environment

```bash
bash install.sh
```

### 3. Create a branch

```bash
git checkout -b feat/your-feature-name
# or
git checkout -b fix/your-bug-fix
```

### 4. Make your changes, then commit

```bash
git add .
git commit -m "feat: describe what you did"
```

### 5. Push and open a Pull Request

```bash
git push origin feat/your-feature-name
```

Then open a PR on GitHub against the `main` branch.

---

## Project Structure

Embedded-Swift-Xcode-Template/
├── install.sh                        # Main setup script
├── scripts/
│   ├── detect_port.sh               # Auto-detects connected ESP32-C6
│   ├── flash.sh                     # Flashes firmware via idf.py
│   ├── monitor.sh                   # Streams serial output
│   ├── monitor_wrapper.c            # Native binary wrapper for Xcode
│   ├── setup_scheme.sh              # Auto-configures Xcode Run scheme
│   └── add_library.sh               # Adds ESP-IDF component libraries
├── installer/
│   ├── build_pkg.sh                 # Builds .pkg installer
│   ├── build_dmg.sh                 # Builds .dmg disk image
│   ├── scripts/postinstall          # .pkg post-install script
│   └── ESPSwiftInstaller/           # SwiftUI installer app
└── Xcode Template/
└── ESP32-C6.xctemplate/
├── TemplateInfo.plist
├── build.sh
├── CMakeLists.txt
├── sdkconfig.defaults
└── main/
├── CMakeLists.txt
├── idf_component.yml
├── BridgingHeader.h
└── main.swift

---

## Coding Guidelines

### Shell Scripts
- Use `#!/bin/bash` shebang
- Add `set -e` for scripts where partial failure is unacceptable
- Comment every non-obvious section
- All comments and output in **English**
- Use `$HOME` instead of `~` in paths (more portable)
- Test on both Intel and Apple Silicon if possible

### Swift (ESPSwiftInstaller)
- Follow Swift API Design Guidelines
- All comments in **English**
- Use `@MainActor` for UI updates
- Prefer `async/await` over callbacks where possible

### Commit Messages
Follow [Conventional Commits](https://www.conventionalcommits.org/):
feat: add GPIO example
fix: resolve CH340 port detection on macOS Ventura
docs: update README with serial monitor guide
chore: update .gitignore
refactor: simplify detect_port.sh

---

## Reporting Bugs

When opening a bug report, please include:

- macOS version
- Xcode version
- ESP32-C6 board model
- USB interface (native USB-CDC / CH340 / CP210x)
- Steps to reproduce
- Expected vs actual behavior
- Relevant logs (build output, serial output, `/var/log/install.log`)

---

## Hardware Requirements for Testing

To fully test this project you need:
- An ESP32-C6 development board
- USB cable (USB-C or Micro-USB depending on board)
- macOS 12+ with Xcode 15+

If you don't have hardware, you can still contribute to:
- Documentation and README
- ESPSwiftInstaller SwiftUI app
- Shell script logic (without flash testing)

---

## Known Limitations

Before contributing, it helps to know the current limitations:

- Embedded Swift is experimental — not all Swift standard library features work
- Xcode's debug console is read-only (no serial input)
- Scheme auto-generation requires closing/reopening the project after first build ([#3](https://github.com/letstakeabreak/Embedded-Swift-Xcode-Template/issues/3))

See all open issues: [GitHub Issues](https://github.com/letstakeabreak/Embedded-Swift-Xcode-Template/issues)

---

## Questions?

Open an issue or start a discussion on GitHub. All questions are welcome!
