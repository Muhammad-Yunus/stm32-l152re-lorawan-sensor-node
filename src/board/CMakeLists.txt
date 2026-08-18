
# Board library: STM32L152RE + SX1276MB1LAS
set(BOARD_SOURCES
    board.c
    adc-board.c
    delay-board.c
    eeprom-board.c
    gpio-board.c
    i2c-board.c
    lpm-board.c
    rtc-board.c
    spi-board.c
    sysIrqHandlers.c
    uart-board.c
    sx1276mb1las-board.c
    utilities.c
)

set(BOARD_CMSIS_SOURCES
    cmsis/arm-gcc/startup_stm32l152xe.s
    cmsis/system_stm32l1xx.c
)

set(BOARD_HAL_SOURCES
    hal/Src/stm32l1xx_hal.c
    hal/Src/stm32l1xx_hal_adc.c
    hal/Src/stm32l1xx_hal_adc_ex.c
    hal/Src/stm32l1xx_hal_cortex.c
    hal/Src/stm32l1xx_hal_crc.c
    hal/Src/stm32l1xx_hal_dma.c
    hal/Src/stm32l1xx_hal_flash.c
    hal/Src/stm32l1xx_hal_flash_ex.c
    hal/Src/stm32l1xx_hal_flash_ramfunc.c
    hal/Src/stm32l1xx_hal_gpio.c
    hal/Src/stm32l1xx_hal_i2c.c
    hal/Src/stm32l1xx_hal_pwr.c
    hal/Src/stm32l1xx_hal_pwr_ex.c
    hal/Src/stm32l1xx_hal_rcc.c
    hal/Src/stm32l1xx_hal_rcc_ex.c
    hal/Src/stm32l1xx_hal_rtc.c
    hal/Src/stm32l1xx_hal_rtc_ex.c
    hal/Src/stm32l1xx_hal_spi.c
    hal/Src/stm32l1xx_hal_spi_ex.c
    hal/Src/stm32l1xx_hal_uart.c
)

add_library(board OBJECT ${BOARD_SOURCES} ${BOARD_CMSIS_SOURCES} ${BOARD_HAL_SOURCES})

target_include_directories(board PUBLIC
    ${CMAKE_CURRENT_SOURCE_DIR}
    ${CMAKE_CURRENT_SOURCE_DIR}/cmsis
    ${CMAKE_CURRENT_SOURCE_DIR}/hal/Inc
    ${CMAKE_SOURCE_DIR}/src/system
    ${CMAKE_SOURCE_DIR}/src/radio
)

target_compile_definitions(board PUBLIC
    USE_HAL_DRIVER
    STM32L152xE
    SX1276MB1LAS
    STATIC_DEVICE_EUI
)
