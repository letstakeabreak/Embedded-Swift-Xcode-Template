# Top-level CMakeLists.txt for an ESP-IDF + Embedded Swift project.
# The following boilerplate must be in this exact order for CMake to work.
cmake_minimum_required(VERSION 3.16)

# Force the Embedded Swift toolchain before ESP-IDF detects it.
if(DEFINED ENV{CMAKE_Swift_COMPILER})
    set(CMAKE_Swift_COMPILER "$ENV{CMAKE_Swift_COMPILER}")
else()
    set(CMAKE_Swift_COMPILER "/Users/miro/Library/Developer/Toolchains/swift-DEVELOPMENT-SNAPSHOT-2026-05-07-a.xctoolchain/usr/bin/swiftc")
endif()

include($ENV{IDF_PATH}/tools/cmake/project.cmake)
project(___PROJECTNAME___)