#!/bin/bash

# FaceTime HD Webcam Driver Installation Script for MacBook Pro (CachyOS/Arch)
# Using the git version for better compatibility with newer kernels (e.g., Kernel 7.x)

echo "--- Starting Webcam Driver Installation ---"

# 1. Install Kernel Headers (Required to build the driver)
echo "1. Installing kernel headers..."
sudo pacman -S --needed linux-cachyos-headers

# 2. Install Firmware and DKMS Driver (Git version) via yay
echo "2. Installing facetimehd-firmware and facetimehd-dkms-git..."
yay -S --needed facetimehd-firmware facetimehd-dkms-git

# 3. Configure Automatic Loading at Boot
echo "3. Setting up automatic module loading..."
if [ ! -f /etc/modules-load.d/facetimehd.conf ]; then
    echo "facetimehd" | sudo tee /etc/modules-load.d/facetimehd.conf
else
    echo "Configuration file already exists."
fi

# 4. Load the driver immediately
echo "4. Loading the module into the kernel..."
sudo modprobe facetimehd

echo "--- Installation Complete! ---"
echo "Check if the webcam is active by running: ls /dev/video*"
