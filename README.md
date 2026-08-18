# STM32L152RE LoRaWAN Sensor Node

> Low-power LoRaWAN sensor node firmware for **STM32L152RE** + **SX1276** radio, targeting **AS923** region.
> Built on [Semtech's LoRaMac-node](https://github.com/Lora-net/LoRaMac-node) stack.

[![LoRaWAN](https://img.shields.io/badge/LoRaWAN-1.0.x-blue?logo=semtech)](https://lora-alliance.org/)
[![Region](https://img.shields.io/badge/Region-AS923-green)](#)
[![MCU](https://img.shields.io/badge/MCU-STM32L152RE-orange)](#)
[![Radio](https://img.shields.io/badge/Radio-SX1276-yellow)](#)
[![Language](https://img.shields.io/badge/Language-C-00599C?logo=c)](#)
[![Build](https://img.shields.io/badge/Build-CMake-273d6e?logo=cmake)](#)
[![License](https://img.shields.io/badge/License-BSD%203--Clause-blue.svg)](#-license)
[![Platform](https://img.shields.io/badge/Platform-Windows%20%7C%20Linux-lightgrey)](#)

---

## 📋 Overview

This project is a bare-metal LoRaWAN end-device firmware running on an STM32L152RET6 microcontroller communicating via an SX1276 LoRa radio module. It supports **OTAA** join procedure and periodic uplink transmission using **Cayenne LPP** payload encoding.

### Key Features

- **LoRaWAN 1.0.x** stack (LmHandler framework)
- **OTAA** device activation with Soft-SE crypto (no hardware secure element required)
- **Cayenne LPP** payload encoding for multi-sensor data
- **Class A** default with **Class B** clock-sync support
- **AS923** regional parameters (changeable to EU868, US915, etc.)
- Ultra-low power STM32L152 (Cortex-M3, sub-µA sleep current)
- Dual-bank 512 KB flash with runtime firmware version tracking

---

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────────────────────────┐
│                          Application Layer                          │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│   ┌─────────────────┐ ┌─────────────────┐ ┌────────────────────┐    │
│   │  main.c         │ │  CayenneLpp     │ │  LmHandler         │    │
│   │                 │ │  encoder        │ │  (stack adaptor)   │    │
│   │  OTAA join      │ │                 │ │                    │    │
│   │  Periodic tx    │ │  JSON ↔ LPP     │ │  RX callbacks      │    │
│   │  CLI console    │ │  encoding       │ │  duty-cycle mgmt   │    │
│   │                 │ │                 │ │  NVM persistence   │    │
│   └────────┬────────┘ └────────┬────────┘ └─────────┬──────────┘    │
│            │                   │                    │               │
├────────────┼───────────────────┼────────────────────┼───────────────┤
│            ▼                   ▼                    ▼               │
│   ┌────────────────────────────────────────────────────────────┐    │
│   │                      LoRaMAC Stack                         │    │
│   │                                                            │    │
│   │   ┌──────────────┐ ┌──────────────┐ ┌───────────────────┐  │    │
│   │   │ LoRaMac Core │ │ Region       │ │ RegionAS923       │  │    │
│   │   │              │ │ Common       │ │ (frequency plan)  │  │    │
│   │   │ • ADR        │ │              │ │                   │  │    │
│   │   │ • Class B    │ │ • Join       │ │ • 8 channels      │  │    │
│   │   │ • Commands   │ │ • MAC cmd    │ │ • DR0..DR7        │  │    │
│   │   │ • Crypto     │ │ • Frame      │ │ • Join duty-cycle │  │    │
│   │   │ • Parser     │ │ • Channels   │ │                   │  │    │
│   │   └──────────────┘ └──────────────┘ └───────────────────┘  │    │
│   └────────────────────────────────────────────────────────────┘    │
│            │                  │                    │                │
├────────────┼──────────────────┼────────────────────┼────────────────┤
│            ▼                  ▼                    ▼                │
│   ┌──────────────────┐ ┌──────────────────┐ ┌────────────────────┐  │
│   │  Board           │ │  Radio           │ │  Peripherals       │  │
│   │  (BSP)           │ │  (SX1276)        │ │  (Soft-SE)         │  │
│   │                  │ │                  │ │                    │  │
│   │  • HAL init      │ │  • SPI bus       │ │  • AES-128         │  │
│   │  • UART (CLI)    │ │  • IRQ handlers  │ │  • CMAC-128        │  │
│   │  • I2C / SPI     │ │  • TX / RX       │ │  • Key derivation  │  │
│   │  • GPIO, ADC     │ │  • LoRa modem    │ │  • Device identity │  │
│   │  • RTC, LPM      │ │  • FSK / OOK     │ │                    │  │
│   └──────────────────┘ └──────────────────┘ └────────────────────┘  │
│            │                  │                    │                │
├────────────┼──────────────────┼────────────────────┼────────────────┤
│            ▼                  ▼                    ▼                │
│   ┌────────────────────────────────────────────────────────────┐    │
│   │              CMSIS / STM32L1xx HAL Drivers                 │    │
│   │                                                            │    │
│   │   core_cm3.h  ·  stm32l152xe.h  ·  system_stm32l1xx.c      │    │
│   │   stm32l1xx_hal_*.c  (GPIO, SPI, UART, I2C, ADC, RTC, PWR) │    │
│   └────────────────────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────────────────────┘
```

---

## 🛠️ Hardware

| Component      | Part                                      |
|---------------|-------------------------------------------|
| **MCU**       | STM32L152RET6 (Cortex-M3, 512 KB Flash, 120 KB RAM) |
| **Radio**     | SX1276MB1LAS breakout (SX1276, AS923 868 MHz) |
| **Debugger**  | ST-LINK/V2 (on-board)                    |
| **Board**     | Custom PCB                               |

### Pin Mapping

| Peripheral | Pin      |
|------------|----------|
| SPI1       | PA5 (SCK) / PA6 (MISO) / PA7 (MOSI) |
| SX1276 NSS | PB13     |
| SX1276 DIO0| PA0      |
| SX1276 DIO1| PA1      |
| SX1276 DIO2| PA2      |
| SX1276 DIO5| PA3      |
| UART1 TX   | PA9      |
| UART1 RX   | PA10     |
| I2C1       | PB6 (SCL) / PB7 (SDA) |
| ADC1       | PC0      |

---

## 📂 Project Structure

```
stm32-l152re-lorawan-sensor-node/
├── CMakeLists.txt               # Top-level CMake config
├── openocd.cfg                  # OpenOCD target config
├── .vscode/
│   ├── launch.json              # Cortex-Debug configuration
│   └── settings.json            # CMake toolchain path
├── cmake/
│   ├── toolchain-arm-none-eabi.cmake
│   └── stm32l1.cmake            # STM32L1-specific settings
└── src/
    ├── app/                     # Application layer
    │   ├── sensor-node/
    │   │   └── main.c           # Entry point (OTAA join + periodic tx)
    │   └── common/
    │       ├── CayenneLpp.[ch]  # LPP payload encoding
    │       ├── cli.[ch]         # Serial console (UART)
    │       ├── Commissioning.h  # DevEUI, JoinEUI, keys
    │       ├── firmwareVersion.h
    │       ├── LmHandler/       # LmHandler adaptor + packages
    │       │   ├── LmHandler.c/.h
    │       │   └── packages/    # ClockSync, Compliance, Fragmentation
    │       └── NvmDataMgmt.[ch] # Persistent settings
    ├── board/                   # Board support package (BSP)
    │   ├── board.[ch]           # Board init (clocks, pins, peripherals)
    │   ├── board-config.h       # Hardware config macros
    │   ├── cmsis/               # CMSIS + HAL headers & startup
    │   ├── hal/                 # STM32L1xx HAL drivers
    │   └── *.board.[ch]         # SPI, UART, I2C, GPIO, ADC, RTC, LPm
    ├── mac/                     # LoRaMAC protocol stack
    │   ├── LoRaMac*.c/h         # Core MAC layer
    │   └── region/
    │       ├── Region.c/h       # Region abstraction
    │       ├── RegionCommon.c   # Common region code
    │       └── RegionAS923.c    # AS923 frequency plan
    ├── peripherals/
    │   └── soft-se/             # Software Secure Element
    │       ├── soft-se.[ch]     # AES-128 / CMAC-128
    │       ├── se-identity.h    # Device credentials (DevEUI, keys)
    │       └── soft-se-hal.[ch] # SE HAL interface
    └── radio/
        ├── sx1276.[ch]          # SX1276 driver wrapper
        └── sx1276/              # SX1276 register definitions
```

---

## 🔧 Build

### Prerequisites

| Tool        | Version          |
|-------------|------------------|
| CMake       | ≥ 3.6            |
| arm-none-eabi-gcc | 13.3.1 (GNU Tools for STM32) |
| OpenOCD     | 0.12.x (STMicroelectronics build) |

### Windows (PowerShell / Git Bash / MSYS2)

```bash
cmake -B build -S . \
  -DTOOLCHAIN_PREFIX="C:/ST/STM32CubeIDE_2.0.0/STM32CubeIDE/plugins/com.st.stm32cube.ide.mcu.externaltools.gnu-tools-for-stm32.13.3.rel1.win32_1.0.100.202509120712/tools"

cmake --build build -j8
```

### Linux

```bash
cmake -B build -S . -DTOOLCHAIN_PREFIX="/opt/gcc-arm-none-eabi"
cmake --build build -j$(nproc)
```

### Build Artifacts

| File | Size | Description |
|------|------|-------------|
| `build/src/app/lorawan-sensor-node` | ~978 KB | ELF (debug info) |
| `build/src/app/lorawan-sensor-node.bin` | ~88 KB | Raw binary |
| `build/src/app/lorawan-sensor-node.hex` | ~249 KB | Intel HEX |
| `build/lorawan-sensor-node.map` | — | Linker map |

**Flash usage:** ~89 KB / 512 KB (17%) — plenty of headroom for additional features.

---

## ⚡ Flash & Debug

### Flash via STM32CubeProgrammer (simplest)

```powershell
& "C:\Program Files\STMicroelectronics\STM32Cube\STM32CubeProgrammer\bin\STM32_Programmer_CLI.exe" `
  -c port=SWD mode=UR reset=HWrst `
  -w build/src/app/lorawan-sensor-node.bin 0x08000000 -v -rst
```

### Flash via OpenOCD

```powershell
$OPENOCD = "C:/ST/STM32CubeIDE_2.0.0/STM32CubeIDE/plugins/com.st.stm32cube.ide.mcu.externaltools.openocd.win32_2.4.300.202509300731/tools/bin/openocd.exe"
$SCRIPTS = "C:/ST/STM32CubeIDE_2.0.0/STM32CubeIDE/plugins/com.st.stm32cube.ide.mcu.debug.openocd_2.3.200.202510310951/resources/openocd/st_scripts"

& $OPENOCD -s $SCRIPTS -f interface/stlink.cfg -f openocd.cfg `
  -c "program build/src/app/lorawan-sensor-node.bin verify reset exit 0x08000000"
```

### VS Code Debug

Open the project in VS Code → **Run and Debug** (F5) → select `Debug-lorawan-sensor-node`.

Requires: **Cortex-Debug** extension installed. The `launch.json` is preconfigured with the correct OpenOCD paths.

---

## 🔌 Serial Console

Baud rate: **115200** on USART1 (PA9/PA10). Connect a USB-to-Serial adapter and watch the boot messages:

```
$1234 OTAA Join Request...
$5678 Join Accept RX1
```

Useful for CLI commands and debugging join/data events.

---

## ⚙️ Configuration

### Compile-time (src/app/CMakeLists.txt)

| Define                        | Value               |
|-------------------------------|---------------------|
| `ACTIVE_REGION`               | `LORAMAC_REGION_AS923` |
| `LORAWAN_DEFAULT_CLASS`       | `CLASS_A`           |
| `CLASSB_ENABLED`              | `ON`                |
| `SECURE_ELEMENT`              | `SOFT_SE`           |
| `FIRMWARE_VERSION`            | `0x01030000` (1.3.0)|

Change `ACTIVE_REGION` for your local frequency plan: `EU868`, `US915`, `AU915`, `IN865`, `KR920`, `RU864`.

### Device Credentials (src/peripherals/soft-se/se-identity.h)

| Field     | Value                                          |
|-----------|------------------------------------------------|
| DevEUI    | `FF FF FF FF 00 00 0C 18`                      |
| JoinEUI   | `11 11 11 11 11 11 11 11`                      |
| AppKey    | `27 97 EA F9 6C 7F 04 53 76 CA FD 05 F1 2C D3 38` |

> ⚠️ **Rotate these before deploying to production or sharing.**

---

## 📦 Dependencies

| Dependency | Source | Purpose |
|------------|--------|---------|
| **LoRaMac-node** | [Semtech GitHub](https://github.com/Lora-net/LoRaMac-node) | LoRaWAN stack (v4.x) |
| **CayenneLpp** | Embedded LPP encoder | Payload encoding |
| **CMSIS / HAL** | STMicroelectronics | MCU abstraction layer |
| **SX1276 driver** | Semtech reference | Radio HAL |

---

## 📄 License

This project uses the **BSD 3-Clause License** (inherited from LoRaMac-node / Semtech). See the [LoRaMac-node license](https://github.com/Lora-net/LoRaMac-node/blob/master/LICENSE) for full terms.

---

## 🚀 Roadmap

- [ ] Support for additional regions (EU868, US915)
- [ ] Hardware secure element (ATECC608A) integration
- [ ] Over-the-air firmware update (OTAA + dual-bank swap)
- [ ] Sensor driver integration (temperature, humidity, pressure)
- [ ] OTA configuration via MAC commands
