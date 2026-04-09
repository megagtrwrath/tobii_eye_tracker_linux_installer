#!/bin/bash
# Fedora Installation Script for Tobii Eye Tracker 5
set -e

# 1. Install Fedora dependencies
echo "Installing Fedora dependencies..."
sudo dnf install -y \
    dnf-plugins-core \
    glibc \
    systemd-libs \
    gtk3 \
    libnotify \
    nss \
    libXScrnSaver \
    libXtst \
    xdg-utils \
    at-spi2-core \
    libuuid \
    libsecret \
    sqlcipher \
    libuv \
    gcc-c++ \
    libusb1-devel

# 2. Extract and install Tobii Engine
echo "Installing Tobii Engine..."
sudo mkdir -p /usr/share/tobii_engine
dpkg-deb -x "Original DEBs/tobii_engine_linux-0.1.6.193_rc-Linux.deb" temp_engine
sudo cp -r temp_engine/usr/share/tobii_engine/* /usr/share/tobii_engine/
sudo cp temp_engine/etc/systemd/system/tobii_engine.service /etc/systemd/system/

# 3. Extract and install Tobii USB Service
echo "Installing Tobii USB Service..."
dpkg-deb -x "Original DEBs/tobiiusbservice_l64U14_2.1.5-28fd4a.deb" temp_usb
sudo mkdir -p /usr/local/lib/tobiiusb
sudo cp temp_usb/usr/local/sbin/tobiiusbserviced /usr/local/bin/
sudo cp temp_usb/usr/local/lib/tobiiusb/* /usr/local/lib/tobiiusb/
sudo cp temp_usb/etc/udev/rules.d/99-tobiiusb.rules /etc/udev/rules.d/
sudo cp Services/tobii_usb.service /etc/systemd/system/
# Fix path in service if needed
sudo sed -i 's|/usr/bin/tobiiusbserviced|/usr/local/bin/tobiiusbserviced|' /etc/systemd/system/tobii_usb.service

# 4. Extract and install Tobii Pro Eye Tracker Manager
echo "Installing Tobii Pro Eye Tracker Manager..."
sudo mkdir -p /opt/TobiiProEyeTrackerManager
dpkg-deb -x "Original DEBs/TobiiProEyeTrackerManager-2.6.1.deb" temp_manager
sudo cp -r temp_manager/opt/TobiiProEyeTrackerManager/* /opt/TobiiProEyeTrackerManager/
sudo cp -r temp_manager/usr/share/icons /usr/share/
sudo cp temp_manager/usr/share/applications/tobiiproeyetrackermanager.desktop /usr/share/applications/
# Fix sandbox issue for Electron in Fedora
sudo sed -i 's|Exec=/opt/TobiiProEyeTrackerManager/tobiiproeyetrackermanager %U|Exec=env ELECTRON_DISABLE_SANDBOX=1 /opt/TobiiProEyeTrackerManager/tobiiproeyetrackermanager %U|' /usr/share/applications/tobiiproeyetrackermanager.desktop

# 5. Patch Tobii Pro Eye Tracker Manager
echo "Patching Eye Tracker Manager..."
cd /opt/TobiiProEyeTrackerManager/resources
sudo npx asar extract app.asar app.asar.unpack
sudo rm app.asar
sudo sed -ri "s/types_1\.EtmModuleType\.TELEMETRY//g" app.asar.unpack/config.js
sudo sed -ri "s/TPSP1/IS5FF/g" app.asar.unpack/main.*.js
sudo npx asar pack app.asar.unpack app.asar
sudo rm -rf app.asar.unpack
cd -

# 6. Install specific library dependencies from 'deps'
echo "Installing specific dependencies from 'deps'..."
sudo mkdir -p /usr/lib/tobii
dpkg-deb -x "deps/libuv0.10_0.10.22-2_amd64.deb" temp_libuv
sudo cp temp_libuv/usr/lib/x86_64-linux-gnu/libuv.so.0.10 /usr/lib/tobii/
dpkg-deb -x "deps/libsqlcipher0_3.4.1-1build1_amd64.deb" temp_sqlcipher
sudo cp temp_sqlcipher/usr/lib/x86_64-linux-gnu/libsqlcipher.so.0.8.6 /usr/lib/tobii/
sudo ln -sf /usr/lib/tobii/libsqlcipher.so.0.8.6 /usr/lib/tobii/libsqlcipher.so.0

# 7. Install Stream Engine libraries
echo "Installing Stream Engine libraries..."
tar -xzf tobii-stream-engine-4.24.0-linux-x86_64.tar.gz
sudo cp -r tobii-stream-engine-4.24.0/include/tobii /usr/include
sudo cp tobii-stream-engine-4.24.0/lib/*.so /usr/lib/tobii/

# 8. Setup shared library paths
echo "Configuring shared library paths..."
echo "/usr/lib/tobii" | sudo tee /etc/ld.so.conf.d/tobii.conf
sudo ldconfig

# 9. Finalize services
echo "Starting services..."
sudo udevadm control --reload-rules
sudo systemctl daemon-reload
sudo systemctl enable --now tobii_engine tobii_usb

# Cleanup
rm -rf temp_engine temp_usb temp_manager temp_libuv temp_sqlcipher tobii-stream-engine-4.24.0

echo "Installation complete. You can now run the Tobii Pro Eye Tracker Manager from your menu."
echo "Or run: /opt/TobiiProEyeTrackerManager/tobiiproeyetrackermanager"
