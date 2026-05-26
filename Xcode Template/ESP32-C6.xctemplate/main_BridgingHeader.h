//
//  BridgingHeader.h
//  ___PROJECTNAME___
//
//  Created by ___FULLUSERNAME___ on ___DATE___.
//

// This bridging header exposes ESP-IDF C APIs to Swift code.
// Add any C headers you need to access from Swift here.

#ifndef BridgingHeader_h
#define BridgingHeader_h

#include "freertos/FreeRTOS.h"
#include "freertos/task.h"
#include "sdkconfig.h"
#include "led_strip.h"

// ── FreeRTOS Macro Wrappers ──────────────────────────────────────
// C macros like pdMS_TO_TICKS() cannot be called directly from Swift.
// These inline functions wrap them for Swift compatibility.

/// Convert milliseconds to FreeRTOS ticks.
/// Assumes default tick rate of 100 Hz (configTICK_RATE_HZ=100),
/// so 1000 ms = 100 ticks.
static inline TickType_t pd_ms_to_ticks(uint32_t ms) {
    return pdMS_TO_TICKS(ms);
}

#endif /* BridgingHeader_h */
