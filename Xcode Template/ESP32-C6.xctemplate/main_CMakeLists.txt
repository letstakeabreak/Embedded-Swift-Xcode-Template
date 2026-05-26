# CMakeLists.txt (main component)
# Configures the main ESP-IDF component for Embedded Swift.

# ----
# Step 1: Register the component with ESP-IDF
# ----
# idf_component_register() tells the build system about this component.
# Even though we use Swift, we still register as an IDF component.
#
# Parameters:
#   SRCS: We pass /dev/null (or NUL on Windows) because there are no C sources.
#         ESP-IDF requires at least one source file, so we use a dummy.
#   PRIV_INCLUDE_DIRS: "." allows BridgingHeader.h to be found.
#   PRIV_REQUIRES:
#     - idf_swift: Provides Embedded Swift runtime and CMake support
#     - esp_driver_gpio : ESP-IDF GPIO driver for controlling hardware pins
if(WIN32)
    set(devnull NUL)
else()
    set(devnull /dev/null)
endif()

idf_component_register(
    SRCS "${devnull}"
    PRIV_INCLUDE_DIRS "."
    PRIV_REQUIRES idf_swift esp_driver_gpio
)

# ------------------------------------------------------------------------------
# Step 2: Configure Embedded Swift compilation
# ------------------------------------------------------------------------------
# idf_component_register_swift() is provided by the idf_swift component.
# It configures the Swift compiler for bare-metal embedded targets.
#
# Parameters:
#   ${COMPONENT_LIB}: The CMake target created by idf_component_register()
#   BRIDGING_HEADER: Exposes C APIs (FreeRTOS, GPIO) to Swift code
#   SRCS: All Swift source files in this component
idf_component_register_swift(
    ${COMPONENT_LIB}
    BRIDGING_HEADER ${CMAKE_CURRENT_LIST_DIR}/BridgingHeader.h
    SRCS Main.swift Led.swift
)