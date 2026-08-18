
set(MAC_SOURCES
    LoRaMac.c
    LoRaMacAdr.c
    LoRaMacClassB.c
    LoRaMacCommands.c
    LoRaMacConfirmQueue.c
    LoRaMacCrypto.c
    LoRaMacParser.c
    LoRaMacSerializer.c
)

set(REGION_SOURCES
    region/Region.c
    region/RegionCommon.c
    region/RegionAS923.c
)

add_library(mac OBJECT ${MAC_SOURCES} ${REGION_SOURCES})

target_include_directories(mac PUBLIC
    ${CMAKE_CURRENT_SOURCE_DIR}
    ${CMAKE_CURRENT_SOURCE_DIR}/region
    ${CMAKE_SOURCE_DIR}/src/board
    ${CMAKE_SOURCE_DIR}/src/system
    ${CMAKE_SOURCE_DIR}/src/radio
)

target_compile_definitions(mac PUBLIC
    REGION_AS923
    LORAMAC_CLASSB_ENABLED
    SOFT_SE
    STATIC_DEVICE_EUI
    USE_RANDOM_DEV_NONCE
    REGION_AS923_DEFAULT_CHANNEL_PLAN=CHANNEL_PLAN_GROUP_AS923_1
)
