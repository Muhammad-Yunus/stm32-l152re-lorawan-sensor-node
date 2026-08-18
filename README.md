# STM32L152RE LoRaWAN Sensor Node

LoRaWAN sensor node firmware for **STM32L152RE** with **SX1276** radio, targeting AS923 region.
Built on Semtech's LoRaMac-node library.

## Hardware

| Component      | Part                                      |
|---------------|-------------------------------------------|
| MCU           | STM32L152RET6 (Cortex-M3, 512KB Flash)   |
| Radio         | SX1276MB1LAS (SX1276, 868 MHz)           |
| Debugger      | ST-LINK/V2 (on-board)                    |
| Board         | Custom PCB                                |

## Toolchain

| Tool        | Version (verified)                          | Location                                    |
|-------------|---------------------------------------------|---------------------------------------------|
| CMake       | ≥ 3.6                                       | system PATH                                 |
| arm-none-eabi-gcc | 13.3.1 (`GNU Tools for STM32 13.3.rel1`) | `C:/ST/STM32CubeIDE_2.0.0/STM32CubeIDE/plugins/com.st.stm32cube.ide.mcu.externaltools.gnu-tools-for-stm32.13.3.rel1.win32_1.0.100.202509120712/tools/bin/` |
| OpenOCD     | 0.12.0+dev (STMicroelectronics build)       | `C:/ST/STM32CubeIDE_2.0.0/STM32CubeIDE/plugins/com.st.stm32cube.ide.mcu.externaltools.openocd.win32_2.4.300.202509300731/tools/bin/openocd.exe` |
| STM32CubeProgrammer | (optional)                            | `C:/Program Files/STMicroelectronics/STM32Cube/STM32CubeProgrammer/bin/STM32_Programmer_CLI.exe` |

> **Note:** `arm-none-eabi-*` binaries are in `tools/bin/` directly, NOT in `tools/arm-none-eabi/bin/`.

## Build

### Windows (PowerShell, MSYS2, or Git Bash)

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

### Build Output

| File                                       | Size   | Description              |
|--------------------------------------------|--------|--------------------------|
| `build/src/app/lorawan-sensor-node`        | 978 KB | ELF (with debug info)    |
| `build/src/app/lorawan-sensor-node.bin`    |  88 KB | Raw binary for flashing  |
| `build/src/app/lorawan-sensor-node.hex`    | 249 KB | Intel HEX                |
| `build/lorawan-sensor-node.map`            |   -    | Linker map file          |

### Size (Cortex-M3, 512 KB flash)

```
   text    data     bss     dec     hex   filename
  87672     724    8460   96856   17a58   lorawan-sensor-node
```

Flash usage: ~89 KB (17% of 512 KB).

## Flash

### Option 1: STM32CubeProgrammer CLI (recommended, simplest)

```powershell
"C:/Program Files/STMicroelectronics/STM32Cube/STM32CubeProgrammer/bin/STM32_Programmer_CLI.exe" `
  -c port=SWD mode=UR reset=HWrst `
  -w build/src/app/lorawan-sensor-node.bin 0x08000000 `
  -v `
  -rst
```

### Option 2: OpenOCD (bundled with STM32CubeIDE)

OpenOCD scripts come from the CubeIDE debug plugin (2.3.200), while the executable comes from the external tools plugin (2.4.300). The `--search` flag tells OpenOCD where to find `interface/stlink.cfg` and `target/stm32l1x.cfg`.

```powershell
$OPENOCD = "C:/ST/STM32CubeIDE_2.0.0/STM32CubeIDE/plugins/com.st.stm32cube.ide.mcu.externaltools.openocd.win32_2.4.300.202509300731/tools/bin/openocd.exe"
$SCRIPTS = "C:/ST/STM32CubeIDE_2.0.0/STM32CubeIDE/plugins/com.st.stm32cube.ide.mcu.debug.openocd_2.3.200.202510310951/resources/openocd/st_scripts"

& $OPENOCD -s $SCRIPTS -f interface/stlink.cfg -f openocd.cfg -c "program build/src/app/lorawan-sensor-node.bin verify reset exit 0x08000000"
```

Or interactive GDB session:
```powershell
& $OPENOCD -s $SCRIPTS -f interface/stlink.cfg -f openocd.cfg
# In another terminal:
arm-none-eabi-gdb build/src/app/lorawan-sensor-node
(gdb) target extended-remote localhost:3333
(gdb) monitor reset halt
(gdb) load
(gdb) monitor reset
(gdb) continue
```

## Debug (VS Code)

`.vscode/launch.json` is preconfigured with `Debug-lorawan-sensor-node` launch.

Open in VS Code → **Run and Debug** → select `Debug-lorawan-sensor-node` → press F5.

Required:
- `Cortex-Debug` VS Code extension installed
- `debugServerArgs` points to the correct OpenOCD + st_scripts paths

## Serial Console

Default baud: **115200** on USART1 (PA9/PA10).
Connect a USB-to-Serial adapter and watch join/status messages.

```
$1234 OTAA Join Request...
$5678 Join Accept RX1
```

## Configuration

Key compile-time definitions in `src/app/CMakeLists.txt`:

| Define              | Value                          |
|--------------------|--------------------------------|
| `ACTIVE_REGION`    | `LORAMAC_REGION_AS923`        |
| `LORAWAN_DEFAULT_CLASS` | `CLASS_A`               |
| `CLASSB_ENABLED`   | `ON`                           |
| `SECURE_ELEMENT`   | `SOFT_SE` (software crypto)   |

Change `ACTIVE_REGION` to your local frequency plan (EU868, US915, AU915, IN865, KR920, RU864).

## LoRaWAN OTAA Credentials

Defined in `src/peripherals/soft-se/se-identity.h`:

| Field     | Hex Value                             |
|-----------|---------------------------------------|
| DevEUI    | `FF FF FF FF 00 00 0C 18`             |
| JoinEUI   | `11 11 11 11 11 11 11 11`             |
| AppKey    | `27 97 EA F9 6C 7F 04 53 76 CA FD 05 F1 2C D3 38` |
| NwkKey    | (same as AppKey for 1.0.x)            |

> ⚠️ **Rotate these before deploying to production or pushing to a public repo.**

## Project Structure

```
src/
├── app/          Application (main, LmHandler, CayenneLpp)
├── board/        Board support (HAL, CMSIS, drivers, linker script)
├── mac/          LoRaMAC stack + AS923 region
├── peripherals/  Soft-se crypto, AES/CMAC
└── radio/        SX1276 driver
cmake/            CMake toolchain & helpers
openocd.cfg       OpenOCD configuration for STM32L152RE
```

## License

LoRaMac-node BSD license (see `src/` root). Modified for STM32L152RE + SX1276MB1LAS.
