##
##   ______                              _
##  / _____)             _              | |
## ( (____  _____ ____ _| |_ _____  ____| |__
##  \____ \| ___ |    (_   _) ___ |/ ___)  _ \
##  _____) ) ____| | | || |_| ____( (___| | | |
## (______/|_____)_|_|_| \__)_____)\____)_| |_|
## (C)2013-2017 Semtech
##  ___ _____ _   ___ _  _____ ___  ___  ___ ___
## / __|_   _/_\ / __| |/ / __/ _ \| _ \/ __| __|
## \__ \ | |/ _ \ (__| ' <| _| (_) |   / (__| _|
## |___/ |_/_/ \_\___|_|\_\_| \___/|_|_\___|___|
## embedded.connectivity.solutions.==============
##
## License:  Revised BSD License, see LICENSE.TXT file included in the project
## Authors:  Johannes Bruder ( STACKFORCE ), Miguel Luis ( Semtech )
##
##
## CMake arm-none-eabi toolchain file
##

list(APPEND CMAKE_MODULE_PATH ${CMAKE_CURRENT_LIST_DIR})

# Target definition - Generic to avoid Windows-specific linker flags
set(CMAKE_SYSTEM_NAME  Generic)
set(CMAKE_SYSTEM_PROCESSOR ARM)

#---------------------------------------------------------------------------------------
# Set toolchain paths
#---------------------------------------------------------------------------------------
if(NOT DEFINED TOOLCHAIN_PREFIX)
    message(FATAL_ERROR "Please specify TOOLCHAIN_PREFIX via -DTOOLCHAIN_PREFIX=<path>")
endif()

set(TOOLCHAIN arm-none-eabi)
set(TOOLCHAIN_BIN_DIR ${TOOLCHAIN_PREFIX}/bin)
set(TOOLCHAIN_INC_DIR ${TOOLCHAIN_PREFIX}/${TOOLCHAIN}/include)
set(TOOLCHAIN_LIB_DIR ${TOOLCHAIN_PREFIX}/${TOOLCHAIN}/lib)

# On Windows, executables have .exe extension
if(WIN32)
    set(TOOLCHAIN_EXT ".exe")
else()
    set(TOOLCHAIN_EXT "")
endif()

# Perform compiler test with static library
set(CMAKE_TRY_COMPILE_TARGET_TYPE STATIC_LIBRARY)

#---------------------------------------------------------------------------------------
# Define toolchain variables
#---------------------------------------------------------------------------------------
set(CMAKE_C_COMPILER          "${TOOLCHAIN_BIN_DIR}/arm-none-eabi-gcc${TOOLCHAIN_EXT}" CACHE PATH "gcc compiler")
set(CMAKE_C_COMPILER_FORCED   TRUE)
set(CMAKE_CXX_COMPILER        "${TOOLCHAIN_BIN_DIR}/arm-none-eabi-gcc${TOOLCHAIN_EXT}" CACHE PATH "g++ compiler")
set(CMAKE_CXX_COMPILER_FORCED TRUE)
set(CMAKE_ASM_COMPILER        "${TOOLCHAIN_BIN_DIR}/arm-none-eabi-gcc${TOOLCHAIN_EXT}" CACHE PATH "assembler")
set(CMAKE_OBJCOPY             "${TOOLCHAIN_BIN_DIR}/arm-none-eabi-objcopy${TOOLCHAIN_EXT}" CACHE PATH "objcopy utility")
set(CMAKE_SIZE                "${TOOLCHAIN_BIN_DIR}/arm-none-eabi-size${TOOLCHAIN_EXT}" CACHE PATH "size utility")

#---------------------------------------------------------------------------------------
# Set linker flags
#---------------------------------------------------------------------------------------
set(CMAKE_EXE_LINKER_FLAGS_INIT "-mthumb -mcpu=cortex-m3 -mabi=aapcs -nostartfiles -static -Wl,--gc-sections -T${CMAKE_SOURCE_DIR}/src/board/cmsis/arm-gcc/stm32l152xe_flash.ld" CACHE STRING "Linker flags")

# Custom link command without DLL/Win32-specific flags
set(CMAKE_C_LINK_EXECUTABLE
    "<CMAKE_C_COMPILER> <FLAGS> <CMAKE_C_LINK_FLAGS> <LINK_FLAGS> <OBJECTS> -o <TARGET> <LINK_LIBRARIES>")
