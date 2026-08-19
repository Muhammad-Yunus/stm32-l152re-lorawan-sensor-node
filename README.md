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
- **3 Grove sensors:** PIR Motion (PB10/D6), LDR Light (PA1/A1), NTC Temperature (PA4/A2)
- Dual-bank 512 KB flash with runtime firmware version tracking

---

## 🛠️ Hardware

### Board & Radio Module

| Component | Part |
|-----------|------|
| **Board** | STMicroelectronics **Nucleo-L152RE** — STM32L152RET6 (Cortex-M3, 512 KB Flash, 120 KB RAM), Arduino-compatible header, on-board ST-LINK/V2 debugger |
| **Radio Shield** | Semtech **SX1276MB1LAS LoRa Shield** |

### Grove Sensors (3 modules on Arduino header)

| Sensor | Module | Arduino Pin | MCU Pin | ADC / Ext | LPP Type | Description | Status |
|--------|--------|-------------|---------|-----------|----------|-------------|--------|
| **PIR Motion** | Grove - PIR Motion Sensor | `D6` | `PB_10` | `EXTI10` (rising) | `LPP_PRESENCE` (102) | Motion detection, triggers TX on event | ✅ Working |
| **LDR Light** | Grove - Light Sensor | `A1` | `PA_1` | `ADC_CHANNEL_1` | `LPP_ANALOG_INPUT` (2) | Ambient light level (0–100%) | ✅ Working |
| **NTC Temperature** | Grove - Temperature Sensor V1.2 | `A2` | `PA_4` | `ADC_CHANNEL_4` | `LPP_TEMPERATURE` (103) | Temperature in °C (Seeed formula) | ✅ Working |

### Arduino Header Pin Usage

| Pin | MCU Pin | Connector | Function | ADC-capable? |
|-----|---------|-----------|----------|---------------|
| `D0`  | `PA_3`  | CN9-2  | UART2_RX | ✗ |
| `D1`  | `PA_2`  | CN9-1  | UART2_TX | ✗ |
| `D2`  | `PA_10` | CN9-3  | SX1276 DIO0 | ✗ |
| `D3`  | `PB_3`  | CN9-5  | SX1276 DIO1 | ✗ |
| `D4`  | `PB_5`  | CN9-7  | SX1276 DIO2 | ✗ |
| `D5`  | `PB_4`  | CN9-9  | SX1276 DIO3 | ✗ |
| `D6`  | `PB_10` | CN9-11 | PIR Motion (EXTI10) | ✓ (in use) |
| `D7`  | `PA_8`  | CN9-13 | _UNUSED — EXTI8 / TIM1_CH1_ | ✗ |
| `D8`  | `PA_9`  | CN5-1  | SX1276 DIO4 | ✗ |
| `D9`  | `PC_7`  | CN5-2  | SX1276 DIO5 | ✗ |
| `D10` | `PB_6`  | CN5-3  | SX1276 NSS | ✗ |
| `D11` | `PA_7`  | CN5-4  | SPI1_MOSI | ✗ |
| `D12` | `PA_6`  | CN5-5  | SPI1_MISO | ✗ |
| `D13` | `PA_5`  | CN5-6  | SPI1_SCK | ✗ |
| `A0`  | `PA_0`  | CN8-1  | RADIO_RESET | ✓ (in use) |
| `A1`  | `PA_1`  | CN8-2  | LDR Light | ✓ (in use) |
| `A2`  | `PA_4`  | CN8-3  | NTC Temperature (ADC4) | ✓ (in use) |
| `A3`  | `PB_0`  | CN8-4  | _UNUSED_ | ✗ |
| `A4`  | `PC_1`  | CN8-5  | SX1276 ANT_SW | ✓ (in use) |
| `A5`  | `PC_0`  | CN8-6  | LED_RX | ✓ (in use) |
| `D14` | `PB_9`  | CN5-9  | _UNUSED_ | ✗ |
| `D15` | `PB_8`  | CN5-10 | _UNUSED_ | ✗ |

---

## 📦 Cayenne LPP Payload Format

### Network Server
**ChirpStack Network Server v4** with **CayenneLPP codec** enabled in Device Profile.

### Payload Structure (Port 2)

Payload sent on both **periodic TX** and **PIR event trigger**:

| Channel | LPP Type | Data | Size | Source | Decode Example |
|---------|----------|------|------|--------|----------------|
| 0 | `LPP_DIGITAL_INPUT` (0) | LED state | 1 byte | Downlink command | `0` = off, `1` = on |
| 1 | `LPP_ANALOG_INPUT` (2) | Battery level | 2 bytes | `BoardGetBatteryLevel()` | `128` → 50% |
| 2 | `LPP_TEMPERATURE` (103) | Temperature | 2 bytes | `BoardReadNtcTemperatureX10()` | `263` → 26.3°C |
| 3 | `LPP_ANALOG_INPUT` (2) | LDR raw ADC | 2 bytes | `BoardReadLdrRawAdc()` | `46` → raw value |
| 4 | `LPP_PRESENCE` (102) | Motion detected | 1 byte | `BoardReadPirMotion()` | `1` = motion, `0` = none |

### Example JSON Output (from ChirpStack)

```json
{
  "analogInput": {
    "1": 128,
    "3": 46
  },
  "digitalInput": {
    "0": 0
  },
  "presenceSensor": {
    "4": 1
  },
  "temperatureSensor": {
    "2": 26.3
  }
}
```

### Raw Payload Example

```
00 00        ← Ch0: DIGITAL_INPUT = 0 (LED off)
02 80 00     ← Ch1: ANALOG_INPUT = 128 (battery 50%)
67 01 07     ← Ch2: TEMPERATURE = 26.3°C (0x0107 × 0.1)
03 00 2E     ← Ch3: ANALOG_INPUT = 46 (LDR raw ADC)
66 01        ← Ch4: PRESENCE = 1 (motion detected)
```

### PIR Event-Based Transmission

PIR sensor (`D6` / `PB_10`) triggers **immediate uplink** on motion detection via EXTI10 rising edge interrupt:

| Trigger | Action | Payload |
|---------|--------|---------|
| Motion detected (rising edge on PB_10) | Set `IsTxFramePending = 1` | 5-channel payload with motion = 1 |
| No motion | Timer-based periodic TX | 5-channel payload with motion = 0 |

> **Note:** PIR status (`LPP_PRESENCE`) is now included in payload as channel 4. Both periodic and PIR-triggered TX send the same 5-channel payload.

---

## 📐 NTC Temperature Sensor Calibration

### Seeed Grove Temperature Sensor V1.2 Formula

User-corrected formula for **Grove Temperature Sensor V1.2** (NTC: NCP18WF104F03RC, 100kΩ @ 25°C):

```c
// Parameters (src/board/board-config.h)
#define NTC_R_NOMINAL          10000.0f   // 10kΩ NTC at T_NOMINAL_C
#define NTC_BETA               4275.0f    // Beta coefficient (K)
#define NTC_T_NOMINAL_C        25.0f      // Nominal temperature (°C)
#define NTC_R_PULLUP           10000.0f   // 10kΩ pull-up resistor
#define NTC_ATTENUATION_FACTOR  1.0f      // Direct voltage divider (no op-amp)

// Calculation (src/board/board.c)
GpioInit( &NtcAdcPin, SENSOR_NTC_TEMP_PIN, PIN_ANALOGIC, PIN_PUSH_PULL, PIN_NO_PULL, 0 );
uint16_t adcRaw = AdcReadChannel( &Adc, ADC_CHANNEL_4 );

// Fault detection
if( adcRaw == 0 || adcRaw >= 4095 )
{
    return -2730;  /* sensor fault / out of range */
}

float adcEffective = (float)adcRaw * NTC_ATTENUATION_FACTOR;
if( adcEffective > 4095.0f ) { adcEffective = 4095.0f; }
float rNtc  = NTC_R_PULLUP * ( ( 4095.0f / adcEffective ) - 1.0f );
float lnRatio = logf( rNtc / NTC_R_NOMINAL );
float invT    = ( 1.0f / ( NTC_T_NOMINAL_C + 273.15f ) ) + ( lnRatio / NTC_BETA );
float tempC   = ( 1.0f / invT ) - 273.15f;
return (int16_t)(tempC * 10.0f);  // Return ×10 for integer precision
```

### Sensor Wiring

```
VDD = 3.3 V
   │
   │
R_PULLUP
 10 kΩ
   │
   ├──────────────┐
   │              │
   │             (+)
NTC 100 kΩ     ┌─────┐
   │           │LM358│
  GND          └──┬──┘
			      │ OUT
				  │
				  └─ PB10 / ADC
				   		│
						│
				NUCLEO L152RE D6 (PB_10)
```

**Important:** The Grove module has an **internal 10kΩ pull-up resistor** and op-amp buffer. No external pull-up is needed.

### Calibration Notes

- Verified reading: **26.3°C** at ambient room temperature
- ADC raw value typically: **~1750–2100** (depends on temperature)
- If readings are off, adjust `NTC_ATTENUATION_FACTOR` (currently set to 1.0)

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
│   │  PIR interrupt  │ │  encoding       │ │  duty-cycle mgmt   │    │
│   │  CLI console    │ │                 │ │  NVM persistence   │    │
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
│   │  • PIR EXTI      │ │                  │ │                    │  │
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
    │       ├── githubVersion.h  # GitHub build info
    │       ├── LmHandlerMsgDisplay.[ch]  # Debug message display
    │       ├── NvmDataMgmt.[ch] # Persistent settings
    │       └── LmHandler/       # LmHandler adaptor + packages
    │           ├── LmHandler.c/.h
    │           └── packages/
    │               ├── LmhpClockSync.[ch]    # Class B clock sync
    │               ├── LmhpCompliance.[ch]   # Periodic TX compliance
    │               ├── LmhpFragmentation.[ch]# Large payload fragmentation
    │               ├── LmhpRemoteMcastSetup.[ch]  # Remote multicast setup
    │               └── FragDecoder.[ch]      # Fragmentation decoder
    ├── board/                   # Board support package (BSP)
    │   ├── board.[ch]           # Board init (clocks, pins, peripherals)
    │   ├── board-config.h       # Hardware config macros
    │   ├── cmsis/               # CMSIS + HAL headers & startup
    │   ├── hal/                 # STM32L1xx HAL drivers
    │   ├── sx1276mb1las-board.c # SX1276 board wrapper (IRQ, reset, SPI)
    │   └── *.board.[ch]         # SPI, UART, I2C, GPIO, ADC, RTC, LPM
    ├── mac/                     # LoRaMAC protocol stack
    │   ├── LoRaMac*.c/h         # Core MAC layer
    │   └── region/
    │       ├── Region.c/h       # Region abstraction
    │       ├── RegionCommon.c   # Common region code
    │       └── RegionAS923.c    # AS923 frequency plan
    ├── peripherals/
    │   └── soft-se/             # Software Secure Element
    │       ├── soft-se.[ch]     # Main SE interface
    │       ├── aes.[ch]         # AES-128 implementation
    │       ├── cmac.[ch]        # CMAC-128 implementation
    │       ├── se-identity.h    # Device credentials (DevEUI, keys)
    │       └── soft-se-hal.[ch] # SE HAL interface
    └── radio/
        ├── sx1276.[ch]          # SX1276 register definitions
        └── sx1276/
            └── sx1276.h         # Register bit definitions
```

---

## 🔧 Build

### Prerequisites

| Tool | Version |
|------|---------|
| CMake | ≥ 3.6 |
| arm-none-eabi-gcc | 13.3.1 (GNU Tools for STM32) |
| OpenOCD | 0.12.x (STMicroelectronics build) |

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
| `build/src/app/lorawan-sensor-node` | ~89 KB | ELF (debug info) |
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

Baud rate: **921600** on UART2 (PA2/PA3). Connect a USB-to-Serial adapter and watch the boot messages:

```
###### ===================================== ######
  Application name   : periodic-uplink-lpp
  Application version: 1.3.0
  GitHub base version: 4.7.0
###### ===================================== ######
  DevEui      : FF-FF-FF-FF-00-00-0C-18
  JoinEui     : 11-11-11-11-11-11-11-11
  Pin         : 00-00-00-00
```

Useful for debugging join/data events and CLI commands.

---

## ⚙️ Configuration

### Compile-time (src/app/CMakeLists.txt)

| Define | Value |
|--------|-------|
| `ACTIVE_REGION` | `LORAMAC_REGION_AS923` |
| `LORAWAN_DEFAULT_CLASS` | `CLASS_A` |
| `CLASSB_ENABLED` | `ON` |
| `SECURE_ELEMENT` | `SOFT_SE` |
| `FIRMWARE_VERSION` | `0x01030000` (1.3.0) |

Change `ACTIVE_REGION` for your local frequency plan: `EU868`, `US915`, `AU915`, `IN865`, `KR920`, `RU864`.

### Device Credentials (src/peripherals/soft-se/se-identity.h)

| Field | Value |
|-------|-------|
| DevEUI | `FF FF FF FF 00 00 0C 18` |
| JoinEUI | `11 11 11 11 11 11 11 11` |
| AppKey | `27 97 EA F9 6C 7F 04 53 76 CA FD 05 F1 2C D3 38` |

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
