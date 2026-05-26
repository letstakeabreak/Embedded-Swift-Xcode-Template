//
// BridgingHeader.h
// ___PROJECTNAME___
//
// Created by ___FULLUSERNAME___ on ___DATE___.
//

// This bridging header exposes ESP-IDF C APIs to Swift code.
// Any C headers listed here will be automatically available
// in all Swift files within this project.

#include <stdio.h>
#include "freertos/FreeRTOS.h"
#include "freertos/task.h"
#include "driver/gpio.h"
#include "sdkconfig.h"

