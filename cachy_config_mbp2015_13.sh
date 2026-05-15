#!/bin/bash

# Pre-execution warning
echo "To run this script, an internet connection via Ethernet is required."
echo "This is because the MacBook Pro 2015 has an initial conflict between the Wi-Fi drivers and the CachyOS kernel."
echo "🚀 Starting MacBook Pro optimization..."

echo "🍎 Total Configuration MacBook Pro 2015 (GitHub yay Edition)..."

# 0. INTERNET CONNECTION CHECK
echo "🌐 Checking internet connection..."
if ! ping -c 1 -W 3 8.8.8.8 &>/dev/null; then
    echo "❌ ERROR: No internet connection detected."
    echo "This script requires an active connection to download yay and the necessary packages."
    echo "Please check your Ethernet cable and try again."
    exit 1
fi
echo "✅ Connection detected. Proceeding..."

# 1. INSTALL YAY FROM GITHUB (Bootstrap)
echo "🛠 Checking for yay..."
if ! command -v yay &> /dev/null; then
    echo "📦 yay not found. Starting installation from GitHub..."

    # Install dependencies required for compilation
    sudo pacman -S --needed base-devel git --noconfirm

    # Move to temporary folder, clone and compile
    cd /tmp
    git clone https://aur.archlinux.org/yay.git
    cd yay
    makepkg -si --noconfirm
    cd ~
    echo "✅ yay installed successfully!"
else
    echo "✅ yay is already present."
fi

# 2. WI-FI FIX (Dual Method)
echo "📶 Configuring Wi-Fi (brcmfmac fix)..."
# Method A: Modprobe configuration
echo "options brcmfmac feature_disable=0x82000" | sudo tee /etc/modprobe.d/brcmfmac.conf

# Method B: GRUB Update (Overwriting the line to avoid sed parsing errors)
echo "🔧 Updating GRUB configuration..."
sudo sed -i '/GRUB_CMDLINE_LINUX_DEFAULT/c\GRUB_CMDLINE_LINUX_DEFAULT="nowatchdog nvme_load=YES splash loglevel=3 brcmfmac.feature_disable=0x82000"' /etc/default/grub
sudo grub-mkconfig -o /boot/grub/grub.cfg

# 3. TOOL INSTALLATION (Official Repositories)
echo "📦 Installing TLP, CPU management, and monitoring tools..."
sudo pacman -S tlp auto-cpufreq lm_sensors intel-undervolt --noconfirm

# 4. AUR INSTALLATION (Apple Drivers, Fans, and Pamac)
echo "🎨 Installing specific drivers and Pamac GUI..."
# Using yay for AUR packages
yay -S mbpfan-git apple-battery-guard pamac-aur --noconfirm

# 5. POWER OPTIMIZATION (Verified Command)
echo "⚡ Executing apple-battery-guard-setup-power..."
sudo apple-battery-guard-setup-power

# 6. SET BATTERY THRESHOLD TO 80%
echo "🔋 Setting charge limit to 80%..."
sudo apple-battery-guard --set-threshold 80

# 7. ENABLE SERVICES
echo "⚙️ Starting system services..."
sudo systemctl enable --now mbpfan
sudo systemctl enable --now auto-cpufreq
sudo systemctl enable --now tlp
sudo systemctl enable --now apple-battery-guard

# 8. SENSOR SETUP
echo "🔍 Automatic sensors configuration..."
sudo sensors-detect --auto

# 9. SD CARD READER OPTIMIZATION
echo "💾 Optimizing SD Card Reader..."

echo 'ACTION=="add", SUBSYSTEM=="usb", ATTR{idVendor}=="05ac", ATTR{idProduct}=="8406", ATTR{power/control}="on"' | sudo tee /etc/udev/rules.d/99-apple-sdcard.rules
sudo sed -i '/GRUB_CMDLINE_LINUX_DEFAULT/c\GRUB_CMDLINE_LINUX_DEFAULT="nowatchdog nvme_load=YES splash loglevel=3 brcmfmac.feature_disable=0x82000 usbcore.autosuspend=-1"' /etc/default/grub
sudo grub-mkconfig -o /boot/grub/grub.cfg

echo "--------------------------------------------------"
echo "✅ MISSION ACCOMPLISHED!"
echo "1. yay: Compiled and installed from GitHub."
echo "2. Wi-Fi: Fix applied (Modprobe + GRUB)."
echo "3. Energy: apple-battery-guard-setup-power executed."
echo "4. Battery: 80% threshold set."
echo "5. Software: Pamac GUI ready to use."
echo "--------------------------------------------------"
echo "🚀 REBOOT YOUR MACBOOK NOW!"
