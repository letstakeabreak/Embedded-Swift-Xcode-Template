//
//  main.swift
//  ___PROJECTNAME___
//
//  Created by ___FULLUSERNAME___ on ___DATE___.
//

// Embedded Swift entry point for ESP32-C6.
// This example blinks the onboard NeoPixel (WS2812) LED on GPIO 8.

@_cdecl("app_main")
public func app_main() {
    print("Hello from Embedded Swift on ESP32-C6!")
    print("Starting NeoPixel blink demo...")
    
    // ── LED Strip Configuration ──────────────────────────────
    // The ESP32-C6 DevKit has a single onboard WS2812 NeoPixel
    // connected to GPIO 8. We configure the led_strip driver to
    // talk to it using the RMT (Remote Control Transceiver)
    // peripheral, which can generate the precise timing pulses
    // that WS2812 LEDs require.
    
    var stripConfig = led_strip_config_t()
    stripConfig.strip_gpio_num = 8           // GPIO 8 = onboard NeoPixel
    stripConfig.max_leds = 1                 // Only one LED on board
    
    var rmtConfig = led_strip_rmt_config_t()
    rmtConfig.resolution_hz = 10_000_000     // 10 MHz tick resolution
    rmtConfig.mem_block_symbols = 64
    
    // Create the LED strip handle.
    var ledStrip: led_strip_handle_t?
    let result = led_strip_new_rmt_device(&stripConfig, &rmtConfig, &ledStrip)
    
    if result != ESP_OK {
        print("Failed to initialize LED strip!")
        return
    }
    
    print("NeoPixel initialized on GPIO 8.")
    
    // ── Animation Loop ───────────────────────────────────────
    // Cycle through Red, Green, Blue, and Off — one color per second.
    
    var colorIndex: UInt32 = 0
    
    while true {
        // Set RGB based on current index.
        // Brightness kept low (32/255) to avoid blinding intensity.
        var r: UInt32 = 0
        var g: UInt32 = 0
        var b: UInt32 = 0
        var name: StaticString = "Off"
        
        switch colorIndex % 4 {
        case 0:
            r = 32; name = "Red"
        case 1:
            g = 32; name = "Green"
        case 2:
            b = 32; name = "Blue"
        default:
            name = "Off"
        }
        
        // Set the first (and only) pixel to the current color.
        led_strip_set_pixel(ledStrip, 0, r, g, b)
        
        // Push the pixel data to the LED hardware.
        led_strip_refresh(ledStrip)
        
        print("LED: \(name)")
        
        // Wait 1 second using FreeRTOS task delay.
        vTaskDelay(pd_ms_to_ticks(1000))

        
        colorIndex += 1
    }
}
