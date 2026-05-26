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
    
    // The main application loop. ESP32 firmware runs forever, so app_main
    // never returns. A bare while true {} would trigger the watchdog timer,
    // since FreeRTOS expects tasks to yield control periodically.
    // By calling vTaskDelay(), we yield to the scheduler, giving other
    // tasks a chance to run (including the watchdog), and prevent a timeout.
    
    var counter: UInt32 = 0
    
    while true {
        // Delay for approximately 1 second.
        // vTaskDelay() takes ticks; pdMS_TO_TICKS() converts milliseconds
        // to the current tick rate (usually 100 Hz on ESP32, so 1000 ms = 100 ticks).
        vTaskDelay(pdMS_TO_TICKS(1000))
        
        // Print to show the loop is running. In real firmware, you'd do
        // something useful here like toggle an LED, read a sensor, etc.
        counter += 1
        print("Tick \(counter)...")
    }
}