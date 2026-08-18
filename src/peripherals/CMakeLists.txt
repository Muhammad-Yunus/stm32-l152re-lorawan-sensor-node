
set(SOFT_SE_SOURCES
    soft-se/aes.c
    soft-se/cmac.c
    soft-se/soft-se.c
    soft-se/soft-se-hal.c
)

add_library(peripherals OBJECT ${SOFT_SE_SOURCES})

target_include_directories(peripherals PUBLIC
    ${CMAKE_CURRENT_SOURCE_DIR}/soft-se
    ${CMAKE_SOURCE_DIR}/src/board
    ${CMAKE_SOURCE_DIR}/src/system
    ${CMAKE_SOURCE_DIR}/src/mac
    ${CMAKE_SOURCE_DIR}/src/mac/region
)

target_compile_definitions(peripherals PUBLIC
    SOFT_SE
    SECURE_ELEMENT_PRE_PROVISIONED
)
