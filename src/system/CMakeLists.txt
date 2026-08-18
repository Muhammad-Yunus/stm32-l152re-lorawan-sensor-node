
set(SYSTEM_SOURCES
    adc.c
    delay.c
    fifo.c
    gpio.c
    i2c.c
    nvmm.c
    systime.c
    timer.c
    uart.c
)

add_library(system OBJECT ${SYSTEM_SOURCES})

target_include_directories(system PUBLIC
    ${CMAKE_CURRENT_SOURCE_DIR}
    ${CMAKE_SOURCE_DIR}/src/board
)
