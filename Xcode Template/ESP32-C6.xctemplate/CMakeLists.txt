# CMakeLists.txt (root)
# Top-level CMake configuration for an ESP-IDF project using Embedded Swift.
#
# cmake_minimum_required sets the minimum CMake version needed.
# ESP-IDF 5.x requires CMake 3.29 or later.
cmake_minimum_required(VERSION 3.29)

# Include ESP-IDF's CMake build system.
# IDF_PATH is set by ESP-IDF's environment setup script (export.sh).
include($ENV{IDF_PATH}/tools/cmake/project.cmake)

# Enables a faster, minimal build that skips unnecessary components.
# This is strongly recommended for Embedded Swift projects to reduce
# compile time and binary size.
idf_build_set_property(MINIMAL_BUILD ON)

# Define the project name.
# ___PROJECTNAME___ will be replaced by Xcode with the actual project name.
project(___PROJECTNAME___)
