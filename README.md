# STM32L152RE LoRaWAN Sensor Node

LoRaWAN sensor node firmware for **STM32L152RE** with **SX1276** radio, targeting AS923 region.
Built on Semtech's LoRaMac-node library.

## Hardware

| Component      | Part                                      |
|---------------|-------------------------------------------|
| MCU           | STM32L152RET6 (Cortex-M3, 256KB Flash)   |
| Radio         | SX1276MB1LAS (SX1276, 868 MHz)           |
| Debugger      | ST-LINK/V2 (on-board)                    |
| Board         | Custom PCB                                |

## Build

Requires:
- CMake ≥ 3.6
- arm-none-eabi-gcc (bundled with STM32CubeIDE)
- OpenOCD (for flash/debug)

```bash
cmake -B build -S . \
  -DTOOLCHAIN_PREFIX="C:/ST/STM32CubeIDE_2.0.0/STM32CubeIDE/plugins/com.st.stm32cube.ide.mcu.externaltools.gnu-tools-for-stm32.13.3.rel1.win32_1.0.100.202509120712/tools"

cmake --build build -j8
```

Output: `build/src/app/lorawan-sensor-node.bin` (88 KB), `.hex`, ELF + map file.

### Size (Cortex-M3, 256 KB flash)

```
  text:  87,672 bytes
  data:     724 bytes
  bss:    8,460 bytes
  Total:  ~97 KB (37% of flash)
```

## Flash & Debug

### Flash via ST-LINK

```bash
arm-none-eabi-flash --verify --reset build/src/app/lorawan-sensor-node.elf
```

### VS Code Debug (ST-LINK)

Open in VS Code → Run & Debug → `Debug-lorawan-sensor-node`.  
Requires OpenOCD running (configured via `.vscode/launch.json`).

### Serial Console

Default baud: **115200**. Serial output provides LoRaWAN join/status messages.

## Configuration

Key compile-time definitions in `src/app/CMakeLists.txt`:

| Define              | Value                          |
|--------------------|--------------------------------|
| `ACTIVE_REGION`    | `LORAMAC_REGION_AS923`        |
| `LORAWAN_DEFAULT_CLASS` | `CLASS_A`               |
| `CLASSB_ENABLED`   | `ON`                           |
| `SECURE_ELEMENT`   | `SOFT_SE` (software crypto)   |

Change `ACTIVE_REGION` to your local frequency plan.

## Project Structure

```
src/
├── app/          Application (main, LmHandler, CayenneLPP)
├── board/        Board support (HAL, CMSIS, drivers)
├── mac/          LoRaMAC stack
├── peripherals/  Soft-se crypto, crypto primitives
└── radio/        SX1276 driver
cmake/            CMake toolchain & helpers
```

## License

LoRaMac-node BSD license (see `src/` root). Modified for STM32L152RE + SX1276MB1LAS.
