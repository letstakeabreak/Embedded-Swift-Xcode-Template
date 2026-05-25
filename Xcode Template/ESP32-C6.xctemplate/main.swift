// 
// main.swift
// ___PROJECTNAME___
//
// Created by ___FULLUSERNAME___ on ___DATE___.
//

// This file is the entry point for your Embedded Swift application.
// It blinks the onboard LED on GPIO 8 as a starting example.
//
// Dependencies:
//  - LED, vTaskDelay, configTICK_RATE_HZ are provided via ESP-IDF C bindings.
//  - Add the espswift-idf Swift Package to use these APIs.
// 
// To change the blink pin, modify LED(gpioPin: 8).

@_cdecl("app_main")
func main() {
    print("Hello from Swift on ESP32-C6!")
    var ledValue: Bool = false
    let blinkDelayMs: UInt32 = 500
    let led = Led(gpioPin: 8)
    while true {
        led.setLed(value: ledValue)
        ledValue.toggle()
        vTaskDelay(blinkDelayMs / (1000 / UInt32(configTICK_RATE_HZ)))
    }
}