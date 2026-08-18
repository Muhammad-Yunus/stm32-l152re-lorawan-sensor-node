cmake_minimum_required(VERSION 3.6)

# Toolchain must be set BEFORE project()
set(CMAKE_TOOLCHAIN_FILE ${CMAKE_CURRENT_SOURCE_DIR}/cmake/toolchain-arm-none-eabi.cmake)

project(stm32-l152re-lorawan-sensor-node C ASM)
set(CMAKE_SUPPRESS_REGENERATION ON)

# Set linker script path
set(LINKER_SCRIPT ${CMAKE_SOURCE_DIR}/src/board/cmsis/arm-gcc/stm32l152xe_flash.ld)

# Include STM32L1 specific settings
include(cmake/stm32l1.cmake)

option(CLASSB_ENABLED "Enable Class B support (requires LmhpClockSync package)" ON)
set(CLASSB_ENABLED ${CLASSB_ENABLED} CACHE BOOL "Enable Class B support")

# Add subdirectories
add_subdirectory(src/board)
add_subdirectory(src/radio)
add_subdirectory(src/system)
add_subdirectory(src/mac)
add_subdirectory(src/peripherals)
add_subdirectory(src/app)
