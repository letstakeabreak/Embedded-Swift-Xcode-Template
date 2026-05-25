//
// Led.swift
//
// Created by ___FULLUSERNAME___ on ___DATE___.
//

// LED provides a simple abstraction over the ESP-IDF GPIO API
// for controlling an LED connected to a specific GPIO pin.

struct Led {
    let gpioPin: gpio_num_t

    init(gpioPin: Int32) {
        self.gpioPin = gpio_num_t(gpioPin)

        // Configure the GPIO pin as a push-pull output.
        // This allows the pin to both source and sink current.
        gpio_reset_pin(self.gpioPin)
        gpio_set_direction(self.gpioPin, GPIO_MODE_OUTPUT)

    }

    // Sets the LED state.
    // value: true = on, false = off
    func setLed(value: Bool) {
        gpio_set_level(self.gpioPin, value ? 1 : 0)
    }
}