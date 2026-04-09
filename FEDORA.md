# Tobii Eye Tracker 5 - Fedora Installation Guide

This guide provides a one-step installation process for Fedora systems, converting the original Debian/Arch instructions to work with `dnf` and standard Fedora paths.

## Prerequisites
Ensure you have `git` and `node/npm` installed:
```bash
sudo dnf install git nodejs npm
```

## Installation
Run the following commands to install:
```bash
chmod +x install_fedora.sh
./install_fedora.sh
```
*Note: The script will prompt for your `sudo` password to install system dependencies and configure services.*

## Features of this Fedora Script:
- **Dependency Mapping**: Automatically installs the Fedora equivalent of the original Arch/Debian dependencies.
- **Legacy Compatibility**: Includes specific versions of `libuv` and `sqlcipher` (required by the Tobii engine) in a private directory to avoid system-wide conflicts.
- **Automated Patching**: Patches the Tobii Eye Tracker Manager to support the Eye Tracker 5 (IS5) and disables telemetry.
- **Sandboxing Fix**: Configures the manager to bypass Electron's sandboxing issues common on Fedora.

## Configuration
After the script finishes:
1. Launch **Tobii Pro Eye Tracker Manager** from your application menu or run:
   ```bash
   /opt/TobiiProEyeTrackerManager/tobiiproeyetrackermanager
   ```
2. Follow the on-screen instructions in the manager to **Calibrate** your device.

## Testing the Installation
To test if the tracker is sending data, you can compile and run the provided example:
```bash
cd example
gcc main.cpp -o main -pthread /usr/lib/tobii/libtobii_stream_engine.so
./main
```
