#!/bin/bash

# Goodix 27c6:55b4 Fingerprint Installer for Zorin OS 18 / Ubuntu 24.04
# Automated script based on manual compilation steps
# Credits: TheWeirdDev (Driver), mpi3d (Firmware Tool)

set -e  # Exit immediately if any command fails

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${GREEN}=== Goodix 27c6:55b4 Installer for Zorin 18 / Ubuntu 24.04 ===${NC}"
echo -e "${YELLOW}WARNING: This process involves flashing device firmware.${NC}"
echo -e "${YELLOW}CRITICAL: If you dual-boot Windows, disable the Fingerprint device in Windows Device Manager FIRST.${NC}"
echo ""
read -p "Press Enter to continue or Ctrl+C to cancel..."

# 1. Install System Dependencies
echo -e "${GREEN}[1/5] Installing system dependencies (apt)...${NC}"
sudo apt update
sudo apt install -y git python3-pip python3-usb python3-crcmod ninja-build build-essential \
    libgirepository1.0-dev libglib2.0-dev libusb-1.0-0-dev libgusb-dev libnss3-dev \
    libpixman-1-dev libpam0g-dev fprintd meson libgusb-dev libcairo2-dev \
    libgudev-1.0-dev libudev-dev systemd-dev gtk-doc-tools libssl-dev libopencv-dev doctest-dev cmake

# 2. Install Python Dependencies
echo -e "${GREEN}[2/5] Installing Python dependencies...${NC}"
# Zorin 18/Ubuntu 24.04 requires --break-system-packages for global pip installs
sudo pip3 install --break-system-packages pyusb python-periphery spidev

# 3. Firmware Flashing
echo -e "${GREEN}[3/5] Setting up Firmware...${NC}"
if [ -d "goodix-fp-dump" ]; then
    echo "Folder goodix-fp-dump exists, using it..."
else
    git clone --recurse-submodules https://github.com/mpi3d/goodix-fp-dump.git
fi

cd goodix-fp-dump
echo -e "${YELLOW}Running Firmware Flash Tool (run_55b4.py)...${NC}"
echo "If this hangs at 'waiting for finger', touch the sensor."
sudo python3 run_55b4.py
cd ..

# 4. Build and Install Driver
echo -e "${GREEN}[4/5] Downloading and Building Driver (TheWeirdDev/libfprint)...${NC}"
# Remove old folder to ensure clean build
if [ -d "libfprint" ]; then
    sudo rm -rf libfprint
fi

git clone --branch 55b4-experimental https://github.com/TheWeirdDev/libfprint.git
cd libfprint

echo "Configuring Meson..."
meson setup builddir -Dprefix=/usr

echo "Compiling..."
ninja -C builddir

echo "Installing..."
sudo ninja -C builddir install
cd ..

# 5. Link and Configure
echo -e "${GREEN}[5/5] Linking library and restarting service...${NC}"

# Backup existing driver just in case
if [ ! -f /usr/lib/x86_64-linux-gnu/libfprint-2.so.2.0.0.bak ]; then
    sudo mv /usr/lib/x86_64-linux-gnu/libfprint-2.so.2.0.0 /usr/lib/x86_64-linux-gnu/libfprint-2.so.2.0.0.bak || true
fi

# Force copy the new driver to the correct system path
sudo cp libfprint/builddir/libfprint/libfprint-2.so.2.0.0 /usr/lib/x86_64-linux-gnu/libfprint-2.so.2.0.0
sudo ldconfig
sudo systemctl restart fprintd

echo -e "${GREEN}=== Installation Complete! ===${NC}"
echo -e "Next Steps:"
echo -e "1. Enroll fingerprint: ${YELLOW}fprintd-enroll${NC}"
echo -e "2. Enable authentication: ${YELLOW}sudo pam-auth-update${NC} (Check 'Fingerprint authentication')"
echo -e "3. Reboot."
