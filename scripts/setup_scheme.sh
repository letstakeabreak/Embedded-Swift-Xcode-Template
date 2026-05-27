#!/bin/bash

# setup_scheme.sh
# Creates a properly configured Xcode scheme file for an ESP32-C6 project.
#
# By default, Xcode generates schemes lazily — they only get written to disk
# when the user explicitly modifies them via Manage Schemes. For a smooth
# first-run experience, we generate the scheme file directly with our
# desired Run configuration (pointing to ~/.espswift/scripts/monitor).
#
# The scheme tells Xcode:
#   - On Build: invoke the project's build.sh (via Legacy Target)
#   - On Run (Cmd+R): launch ~/.espswift/scripts/monitor
#     which streams ESP32-C6 serial output to the Xcode console
#
# Usage: bash setup_scheme.sh <project_directory> <project_name>
#
# Example: bash setup_scheme.sh /Users/me/Developer/MyApp MyApp
#
# Idempotency: This script does nothing if the scheme already exists,
# to avoid overwriting user customizations.

# ── Argument Validation ──────────────────────────────────────────

PROJECT_DIR="$1"
PROJECT_NAME="$2"

if [ -z "$PROJECT_DIR" ] || [ -z "$PROJECT_NAME" ]; then
    echo "Error: Missing arguments." >&2
    echo "Usage: bash setup_scheme.sh <project_directory> <project_name>" >&2
    exit 1
fi

XCODEPROJ="$PROJECT_DIR/$PROJECT_NAME.xcodeproj"

if [ ! -d "$XCODEPROJ" ]; then
    echo "Error: Xcode project not found at $XCODEPROJ" >&2
    exit 1
fi

# ── Idempotency Check ────────────────────────────────────────────

SCHEME_DIR="$XCODEPROJ/xcshareddata/xcschemes"
SCHEME_FILE="$SCHEME_DIR/$PROJECT_NAME.xcscheme"

if [ -f "$SCHEME_FILE" ]; then
    # Scheme already exists; respect user's customizations.
    exit 0
fi

# ── Extract BlueprintIdentifier from project.pbxproj ─────────────
# Xcode uses 24-character hex UUIDs to identify targets internally.
# We need this UUID to make our scheme's BuildableReference match
# the actual target defined in project.pbxproj.
#
# The PBXLegacyTarget section in project.pbxproj looks like:
#   /* Begin PBXLegacyTarget section */
#       4EF734A02FC6E52900788C7C /* MyApp */ = {
#           isa = PBXLegacyTarget;
#           ...
#       };
#   /* End PBXLegacyTarget section */
#
# We extract that first hex string after the section marker.

PBXPROJ="$XCODEPROJ/project.pbxproj"

BLUEPRINT_ID=$(awk '/Begin PBXLegacyTarget section/,/End PBXLegacyTarget section/' "$PBXPROJ" \
    | grep -m1 -E '^\s+[A-F0-9]{24} /\* .* \*/ = \{' \
    | awk '{print $1}')

if [ -z "$BLUEPRINT_ID" ]; then
    echo "Warning: Could not extract BlueprintIdentifier from project.pbxproj" >&2
    echo "Scheme setup skipped. You can manually configure via Edit Scheme..." >&2
    exit 0
fi

# ── Create Scheme File ───────────────────────────────────────────

mkdir -p "$SCHEME_DIR"

# Generate the .xcscheme XML.
# Key configuration:
#   - selectedDebuggerIdentifier = ""
#     Disables LLDB; our monitor binary is not meant to be debugged.
#   - selectedLauncherIdentifier = "Xcode.IDEFoundation.Launcher.PosixSpawn"
#     Uses POSIX spawn instead of LLDB launcher.
#   - <PathRunnable FilePath = "$HOME/.espswift/scripts/monitor">
#     The native binary that wraps monitor.sh (Xcode rejects shell scripts
#     as executables, so we use a tiny C wrapper).

cat > "$SCHEME_FILE" << SCHEME
<?xml version="1.0" encoding="UTF-8"?>
<Scheme
   LastUpgradeVersion = "2650"
   version = "1.7">
   <BuildAction
      parallelizeBuildables = "YES"
      buildImplicitDependencies = "YES"
      buildArchitectures = "Automatic">
      <BuildActionEntries>
         <BuildActionEntry
            buildForTesting = "YES"
            buildForRunning = "YES"
            buildForProfiling = "YES"
            buildForArchiving = "YES"
            buildForAnalyzing = "YES">
            <BuildableReference
               BuildableIdentifier = "primary"
               BlueprintIdentifier = "$BLUEPRINT_ID"
               BuildableName = "$PROJECT_NAME"
               BlueprintName = "$PROJECT_NAME"
               ReferencedContainer = "container:$PROJECT_NAME.xcodeproj">
            </BuildableReference>
         </BuildActionEntry>
      </BuildActionEntries>
   </BuildAction>
   <TestAction
      buildConfiguration = "Debug"
      selectedDebuggerIdentifier = "Xcode.DebuggerFoundation.Debugger.LLDB"
      selectedLauncherIdentifier = "Xcode.DebuggerFoundation.Launcher.LLDB"
      shouldUseLaunchSchemeArgsEnv = "YES"
      shouldAutocreateTestPlan = "YES">
   </TestAction>
   <LaunchAction
      buildConfiguration = "Debug"
      selectedDebuggerIdentifier = ""
      selectedLauncherIdentifier = "Xcode.IDEFoundation.Launcher.PosixSpawn"
      launchStyle = "0"
      useCustomWorkingDirectory = "NO"
      ignoresPersistentStateOnLaunch = "NO"
      debugDocumentVersioning = "YES"
      debugServiceExtension = "internal"
      allowLocationSimulation = "YES"
      queueDebuggingEnableBacktraceRecording = "Yes">
      <PathRunnable
         runnableDebuggingMode = "0"
         FilePath = "$HOME/.espswift/scripts/monitor">
      </PathRunnable>
   </LaunchAction>
   <ProfileAction
      buildConfiguration = "Release"
      shouldUseLaunchSchemeArgsEnv = "YES"
      savedToolIdentifier = ""
      useCustomWorkingDirectory = "NO"
      debugDocumentVersioning = "YES">
      <MacroExpansion>
         <BuildableReference
            BuildableIdentifier = "primary"
            BlueprintIdentifier = "$BLUEPRINT_ID"
            BuildableName = "$PROJECT_NAME"
            BlueprintName = "$PROJECT_NAME"
            ReferencedContainer = "container:$PROJECT_NAME.xcodeproj">
         </BuildableReference>
      </MacroExpansion>
   </ProfileAction>
   <AnalyzeAction
      buildConfiguration = "Debug">
   </AnalyzeAction>
   <ArchiveAction
      buildConfiguration = "Release"
      revealArchiveInOrganizer = "YES">
   </ArchiveAction>
</Scheme>
SCHEME

echo "Created scheme: $SCHEME_FILE"
