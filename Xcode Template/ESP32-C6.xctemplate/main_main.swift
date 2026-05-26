//
//  main.swift
//  ___PROJECTNAME___
//
//  Created by ___FULLUSERNAME___ on ___DATE___.
//

// Embedded Swift entry point for ESP32-C6.

@_cdecl("app_main")
public func app_main() {
    print("Hello from Embedded Swift on ESP32-C6!")
    
    // Main application loop.
    // Watchdog is disabled via sdkconfig.defaults, so a busy-wait
    // loop is safe here. For production firmware, consider using
    // FreeRTOS task delays via vTaskDelay() with proper bridging.
    while true {
        // Busy-wait for approximately 1 second.
        var i: UInt32 = 0
        while i < 100_000_000 {
            i += 1
        }
        print("Tick...")
    }
}
