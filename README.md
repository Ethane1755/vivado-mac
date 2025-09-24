# Vivado on macOS via Docker

This repository provides a solution to run Xilinx Vivado on macOS using Docker containerization.

> **Note:** Tested on macOS 16 Tahoe. macOS 14 is not supported.

## Normal Vivado Workflow

The typical FPGA development workflow in Vivado consists of:
1. RTL Design (Verilog/VHDL)
2. Synthesis  
3. Implementation
4. Generate Bitstream
5. Program to FPGA Board

### Programming with Docker Limitation (Solved)

When running Vivado in a container, direct hardware programming is not possible due to USB device access restrictions. To solve this, we use openFPGALoader:

1. Generate bitstream in containerized Vivado
2. Locate bitstream in your project directory (typically at `<project_name>/<project_name>.runs/impl_1/<top_level_module>.bit`)
3. Use openFPGALoader on host to program FPGA:
   ```bash
   brew install openfpgaloader
   openFPGALoader -b basys3 /path/to/project/<project_name>.runs/impl_1/<top_level_module>.bit
   ```

> Just run openFPGAloader before running Vivado (remember to plug in your FPGA), and Vivado can automatically recognize the FPGA board in hardware manager(tested on Artix-7 family)

## Table of Contents
- [Prerequisites](#prerequisites)
- [Installation](#installation)
- [Usage](#usage)
- [Troubleshooting](#troubleshooting)

## Prerequisites

### Disk Space
Ensure you have at least **120GB** of free disk space:
- ~80GB for Vivado download and extract (this space will be freed after installation)
- ~40GB for program data

### Homebrew
Install Homebrew by running:
```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```
Follow any additional setup instructions provided by the installer.

### Docker Desktop
Install Docker Desktop for macOS from [docker.com](https://www.docker.com/products/docker-desktop)

Alternatively, install via Homebrew:
```bash
brew install --cask docker
```

### XQuartz
Install via Homebrew:
```bash
brew install --cask xquartz
```

After installation:
1. **Restart your computer**
2. Open XQuartz and enable "Allow connections from network clients" in XQuartz preferences
3. Navigate to **XQuartz → Settings → Security → Allow connections from network clients**

### OpenFPGALoader
```bash
brew install openfpgaloader
```

### Vivado Installer
Download Vivado installer for Linux from AMD/Xilinx website. (versions 2024.2/ 2023.2)

## Installation

### Get the Repository
```bash
git clone https://github.com/ethane1755/vivado-mac.git
# or download and extract the ZIP file
```

### Setup Verification (optional)
```bash
cd vivado-mac
./scripts/verify_setup.sh
```

### Run Setup Script
```bash
./scripts/setup.sh
```

During setup, you'll be asked if you want to add `vivado` to your PATH. If you choose "yes":
- You can run `vivado` from anywhere in your terminal
- The script will create a symlink in `/usr/local/bin/` or update your shell profile

### Install Vivado
- When prompted, drag and drop the downloaded Vivado installer into the terminal
- Follow the installation instructions in the Vivado installer  
- Select desired Vivado components

## Usage

### Quick Launch (Recommended)

#### Start Xilinx Virtual Cable (XVC)
```bash
# Make sure you are in the vivado-mac directory
./openFPGALoader -b basys3 --xvc
```

#### If you added vivado to PATH during setup:
```bash
vivado
```

#### If you didn't add vivado to PATH:
```bash
# Make sure you are in the vivado-mac directory
./vivado
```

The launcher script will:
- Automatically find your vivado-mac installation
- Start Docker Desktop if not running
- Configure X11 forwarding
- Launch Vivado in the container

### Manual Steps (Alternative)

#### Ensure Display Setup
- Check [X11 Display Issues](#x11-display-issues) if you encounter problems
- XQuartz must be running before starting Vivado (The script should do it for you.)

#### Launch Vivado container
```bash
./scripts/start_container.sh
```
Vivado GUI will appear in XQuartz window.


## Troubleshooting

### Common Issues

#### X11 Display Issues
- Ensure XQuartz is running
- In XQuartz preferences:
  - Go to Security tab
  - Check "Allow connections from network clients"
- Try restarting XQuartz
- Run `xhost + localhost` before starting container

#### Permission Issues
Ensure setup script has executable permissions:
```bash
chmod +x scripts/setup.sh
```

#### 100 Killed Error
If you encounter the following error while using version 2024.2:
```
100 Killed ${X_JAVA_HOME} /bin/java ${ARGS} -cp ${X_CLASS_PATH} com.xilinx.installer.api.InstallerLauncher "$@"
```

Try to increase Docker memory limit:
1. Open Docker Dashboard
2. Click on Settings → Resources → Advanced
3. Increase the Memory limitation

## License

This project is licensed under the BSD 3-Clause License - see the LICENSE file for details.

### Vivado License
Vivado requires a license from AMD/Xilinx. Please obtain appropriate licensing from AMD/Xilinx website.

### OpenFPGALoader License
This repository contains the built binary of OpenFPGALoader that enables XVC feature for Mac.

## Disclaimer

This repository only provides the environment setup to run Vivado on Apple Silicon Macs via Docker. It does not include Vivado software itself. Users must:

- Download Vivado separately from AMD/Xilinx
- Comply with AMD/Xilinx's licensing terms
- Use at their own risk