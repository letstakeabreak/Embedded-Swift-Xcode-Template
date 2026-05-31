#!/bin/bash

# add_library.sh
# Adds an ESP-IDF component library to the current ESPSwift project.
#
# This script updates two files automatically:
#   1. main/idf_component.yml  — adds the component as a dependency
#   2. main/BridgingHeader.h   — adds the corresponding #include
#
# Usage: bash add_library.sh <component> [header]
#
# Examples:
#   bash add_library.sh espressif/led_strip
#   bash add_library.sh espressif/led_strip led_strip.h
#   bash add_library.sh idf-extra-components/i2c_bus i2c_bus.h
#
# The component name must match the ESP-IDF Component Registry:
#   https://components.espressif.com

# ── Argument Validation ──────────────────────────────────────────

COMPONENT="$1"
HEADER="$2"

if [ -z "$COMPONENT" ]; then
    echo "Error: No component specified." >&2
    echo "Usage: bash add_library.sh <component> [header]" >&2
    echo "Example: bash add_library.sh espressif/led_strip led_strip.h" >&2
    exit 1
fi

# If no header provided, infer it from the component name.
# e.g. "espressif/led_strip" → "led_strip.h"
if [ -z "$HEADER" ]; then
    HEADER=$(echo "$COMPONENT" | cut -d/ -f2).h
    echo "No header specified, inferring: $HEADER"
fi

# ── Find Project Files ───────────────────────────────────────────

# Support running from either the project root or the scripts/ directory.
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# Look for main/idf_component.yml relative to current directory first,
# then fall back to the repo root (for when run from scripts/).
if [ -f "main/idf_component.yml" ]; then
    PROJECT_DIR="$(pwd)"
elif [ -f "$REPO_ROOT/main/idf_component.yml" ]; then
    PROJECT_DIR="$REPO_ROOT"
else
    echo "Error: main/idf_component.yml not found." >&2
    echo "Run this script from your project directory." >&2
    echo "Example: bash ~/.espswift/scripts/add_library.sh espressif/led_strip" >&2
    exit 1
fi

IDF_COMPONENT_YML="$PROJECT_DIR/main/idf_component.yml"
BRIDGING_HEADER="$PROJECT_DIR/main/BridgingHeader.h"

# ── Update idf_component.yml ─────────────────────────────────────

# Check if the component is already listed.
if grep -q "$COMPONENT" "$IDF_COMPONENT_YML"; then
    echo "Component '$COMPONENT' already exists in idf_component.yml. Skipping."
else
    # Append the dependency under the existing dependencies: block.
    # We use a version wildcard "^1.0.0" which accepts any compatible version.
    # Users can manually pin to a specific version if needed.
    echo "  $COMPONENT: \"*\"" >> "$IDF_COMPONENT_YML"
    echo "Added '$COMPONENT' to idf_component.yml."
fi

# ── Update BridgingHeader.h ──────────────────────────────────────

if [ ! -f "$BRIDGING_HEADER" ]; then
    echo "Warning: BridgingHeader.h not found at $BRIDGING_HEADER" >&2
    echo "Skipping header include." >&2
    exit 0
fi

# Check if the header is already included.
if grep -q "#include \"$HEADER\"" "$BRIDGING_HEADER"; then
    echo "Header '$HEADER' already included in BridgingHeader.h. Skipping."
else
    # Insert the new #include before the closing #endif.
    # This keeps the header organized and avoids appending after #endif.
    sed -i '' "s|#endif /\* BridgingHeader_h \*/|#include \"$HEADER\"\n\n#endif /* BridgingHeader_h */|" "$BRIDGING_HEADER"
    echo "Added '#include \"$HEADER\"' to BridgingHeader.h."
fi

# ── Done ─────────────────────────────────────────────────────────

echo ""
echo "Done! Rebuild your project to download and link the new component."
echo "  Component: $COMPONENT"
echo "  Header:    $HEADER"
echo ""
echo "Next: press Cmd+B in Xcode to trigger idf_component_manager."
