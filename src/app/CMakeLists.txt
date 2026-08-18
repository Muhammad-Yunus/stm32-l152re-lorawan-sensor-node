
# Application common sources
set(APP_COMMON_SOURCES
    common/CayenneLpp.c
    common/cli.c
    common/LmHandlerMsgDisplay.c
    common/NvmDataMgmt.c
    common/githubVersion.h
    common/firmwareVersion.h
)

# LmHandler sources
set(APP_LMH_SOURCES
    common/LmHandler/LmHandler.c
)

# LmHandler packages
set(APP_LMHP_SOURCES
    common/LmHandler/packages/FragDecoder.c
    common/LmHandler/packages/LmhpCompliance.c
    common/LmHandler/packages/LmhpFragmentation.c
    common/LmHandler/packages/LmhpRemoteMcastSetup.c
)

# Class B package (optional)
if(CLASSB_ENABLED)
    list(APPEND APP_LMHP_SOURCES
        common/LmHandler/packages/LmhpClockSync.c
    )
endif()

# Main application source
set(APP_SOURCES
    sensor-node/main.c
)

# Create executable
add_executable(lorawan-sensor-node
    ${APP_COMMON_SOURCES}
    ${APP_LMH_SOURCES}
    ${APP_LMHP_SOURCES}
    ${APP_SOURCES}
    $<TARGET_OBJECTS:mac>
    $<TARGET_OBJECTS:system>
    $<TARGET_OBJECTS:radio>
    $<TARGET_OBJECTS:peripherals>
    $<TARGET_OBJECTS:board>
)

# Compiler definitions
target_compile_definitions(lorawan-sensor-node PRIVATE
    ACTIVE_REGION=LORAMAC_REGION_AS923
    LORAWAN_DEFAULT_CLASS=CLASS_A
    SECURE_ELEMENT_PRE_PROVISIONED
    SOFT_SE
    USE_RANDOM_DEV_NONCE
)

if(CLASSB_ENABLED)
    target_compile_definitions(lorawan-sensor-node PRIVATE LORAMAC_CLASSB_ENABLED)
endif()

# Include directories
target_include_directories(lorawan-sensor-node PUBLIC
    ${CMAKE_CURRENT_SOURCE_DIR}/common
    ${CMAKE_CURRENT_SOURCE_DIR}/common/LmHandler
    ${CMAKE_CURRENT_SOURCE_DIR}/common/LmHandler/packages
    ${CMAKE_CURRENT_SOURCE_DIR}/sensor-node
    $<BUILD_INTERFACE:$<TARGET_PROPERTY:mac,INTERFACE_INCLUDE_DIRECTORIES>>
    $<BUILD_INTERFACE:$<TARGET_PROPERTY:system,INTERFACE_INCLUDE_DIRECTORIES>>
    $<BUILD_INTERFACE:$<TARGET_PROPERTY:radio,INTERFACE_INCLUDE_DIRECTORIES>>
    $<BUILD_INTERFACE:$<TARGET_PROPERTY:peripherals,INTERFACE_INCLUDE_DIRECTORIES>>
    $<BUILD_INTERFACE:$<TARGET_PROPERTY:board,INTERFACE_INCLUDE_DIRECTORIES>>
)

set_property(TARGET lorawan-sensor-node PROPERTY C_STANDARD 11)

target_link_libraries(lorawan-sensor-node m)

# Debugging and Binutils
include(${CMAKE_SOURCE_DIR}/cmake/gdb-helper.cmake)
include(${CMAKE_SOURCE_DIR}/cmake/binutils-arm-none-eabi.cmake)

# Generate debugger configurations
generate_run_gdb_stlink(lorawan-sensor-node)
generate_run_gdb_openocd(lorawan-sensor-node)
generate_vscode_launch_openocd(lorawan-sensor-node)

# Print section sizes
print_section_sizes(lorawan-sensor-node)

# Create output in hex and binary format
create_bin_output(lorawan-sensor-node)
create_hex_output(lorawan-sensor-node)
