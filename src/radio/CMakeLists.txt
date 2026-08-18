
set(RADIO_SOURCES sx1276.c)

add_library(radio OBJECT ${RADIO_SOURCES})

target_include_directories(radio PUBLIC
    ${CMAKE_CURRENT_SOURCE_DIR}
    ${CMAKE_SOURCE_DIR}/src/board
    ${CMAKE_SOURCE_DIR}/src/system
)

target_compile_definitions(radio PUBLIC
    SX1276MB1LAS
)
