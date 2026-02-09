# CLAUDE.md

This file provides guidance to Claude Code when working with the Keystone firmware.

## Project Overview

Keystone is a fork of [KeystoneHQ/keystone3-firmware](https://github.com/KeystoneHQ/keystone3-firmware) used to add Blueberry as a supported software wallet on the Keystone 3 Pro hardware cryptocurrency wallet.

| Attribute | Value |
|-----------|-------|
| **Languages** | C, Rust |
| **OS** | FreeRTOS |
| **MCU** | MH1903 |
| **UI Framework** | LVGL |
| **Communication** | QR codes (UR encoding) |

> **Repository Context:** This is part of the [blueberry](../) monorepo. See `../CLAUDE.md` for root orchestration and the full platform architecture.

## Development Environment

### Prerequisites

| Tool | Version | Installation |
|------|---------|--------------|
| Python | 3.11.9 | `pyenv install 3.11.9` |
| Rust | stable + nightly-2025-05-01 | `rustup install nightly-2025-05-01` |
| SDL2 | 2.32+ | `brew install sdl2` |
| cbindgen | 0.29+ | `brew install cbindgen` |
| cmake | 4.0+ | `brew install cmake` |

### Python Environment

The project uses a pyenv virtual environment:

```bash
# Environment is auto-activated via .python-version file
cd ~/Developer/blueberry/keystone

# Or manually activate
pyenv activate keystone

# Install dependencies
pip install -r requirements.txt
```

## Development Commands

### Simulator (UI Testing)

```bash
make build         # Build the simulator
make start         # Start the simulator
make stop          # Stop the simulator
make restart       # Restart the simulator
make status        # Check if simulator is running
make clean         # Clean build directory
make rebuild       # Clean and rebuild
make init-assets   # Initialize simulator assets (required before first run)
make reset-assets  # Reset simulator assets to defaults
make reset-wallet  # Reset wallet data (keeps device settings)
```

The simulator allows testing UI changes without flashing to physical hardware.

### Firmware Build

```bash
# Build multi-coin firmware (development)
python build.py

# Build production firmware
python build.py -e production

# Build BTC-only firmware
python build.py -t btc_only

# Build Cypherpunk firmware
python build.py -t cypherpunk
```

### Docker Build (Reproducible)

```bash
# Pull the official build image
docker pull keystonehq/keystone3_baker:1.0.2

# Build production firmware
docker run -v $(pwd):/keystone3-firmware keystonehq/keystone3_baker:1.0.2 python3 build.py -e production
```

## Architecture

### Directory Structure

- `src/` - Main C source code (UI, drivers, device logic)
- `rust/` - Rust code for blockchain support (signing, address generation, crypto)
- `external/` - External dependencies (LVGL, cryptographic libraries)
- `images/` - Image assets for the UI
- `ui_simulator/` - Simulator-specific code
- `tools/` - Build and development tools

### Key UI Files for Wallet Integration

To add a new software wallet (like Blueberry), these files need modifications:

| File | Purpose |
|------|---------|
| `src/ui/gui_widgets/gui_connect_wallet_widgets.h` | Wallet enum (`WALLET_LIST_INDEX_ENUM`) |
| `src/ui/gui_widgets/multi/web3/gui_connect_wallet_widgets.c` | Wallet list array and UI |
| `src/ui/gui_components/gui_status_bar.c` | Wallet info registration |
| `src/ui/gui_wallet/multi/web3/gui_wallet.c` | QR code data generation |
| `src/ui/gui_widgets/gui_wallet_tutorial_widgets.c` | Connection tutorials |
| `images/` | Wallet icon assets |

### Communication Protocol

Keystone uses **QR codes** with **UR (Uniform Resources)** encoding for air-gapped communication:
- No USB or Bluetooth data transfer
- Animated QR codes for large data
- BC-UR registry types for different blockchains

## Firmware Deployment

### Important Limitation

The Keystone 3 Pro **verifies firmware signatures** during updates. Custom firmware cannot be flashed to production devices without Keystone's private signing keys.

### Testing Options

1. **Simulator** - Test UI changes locally (recommended)
2. **Submit PR** - Contribute to official Keystone repository
3. **Contact Keystone** - Discuss partnership for official integration

### Official Update Process (for reference)

1. Copy `keystone3.bin` to FAT32-formatted MicroSD card
2. Insert into Keystone device
3. Navigate: Settings → About → Firmware Update → Via MicroSD Card

## Integration with Blueberry

The Blueberry mobile app already has full Keystone integration:
- `src/utils/keystone/urEncoder.ts` - Encodes transactions (uses "BlueberryMoney" as origin)
- `src/utils/keystone/urDecoder.ts` - Decodes signatures
- `src/utils/keystone/bcurDecoder.ts` - Parses HD keys and accounts
- `src/components/qr/AnimatedQRScanner.tsx` - Multi-part QR scanner

Adding Blueberry to Keystone firmware would allow users to select "Blueberry" from the device's software wallet list.

## Resources

- [Keystone GitHub](https://github.com/KeystoneHQ/keystone3-firmware)
- [Keystone Firmware Guide](https://guide.keyst.one/docs/firmware-upgrade)
- [BC-UR Specification](https://github.com/BlockchainCommons/Research/blob/master/papers/bcr-2020-005-ur.md)
- [LVGL Documentation](https://docs.lvgl.io/)
