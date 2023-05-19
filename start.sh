#!/bin/bash

AMD_XORG="Section "OutputClass"
     Identifier "AMD"
     MatchDriver "amdgpu"
     Driver "amdgpu"
EndSection"

KEYBOARD_XORG="Section "InputClass"
        Identifier "system-keyboard"
        MatchIsKeyboard "on"
        Option "XkbLayout" "us,ru"
        Option "XkbModel" "pc104"
        Option "XkbVariant" ",dvorak"
        Option "XkbOptions" "grp:win_space_toggle"
EndSection"

# Create a user and user's home dir
echo "=====| Create user |====="
echo "Username: "
read user_name
HOME_DIR="/home/$USER_NAME"
useradd -m -G $USER_NAME $USER_NAME
passwd $USER_NAME

# Update packages
echo "=====| Update packages |====="
pacman -Syyu
echo "=====| Install zip, unzip, neovim, sudo, wget, git, reflector, bluez, feh |====="
pacman -S zip unzip neovim sudo wget git reflector bluez bluez-utils feh

echo "=====| Install base-devel and paru |====="
pacman -S --needed base-devel
su $USER_NAME
cd
git clone https://aur.archlinux.org/paru.git
cd paru
makepkg -si
cd
exit

# Install Xorg
echo "=====| Install Xorg |====="
pacman -S xorg-server xorg-apps

# Install drivers
echo "=====| Install GPU drivers |====="
echo "Your GPU: 1) AMD 2) NVIDIA"
read GPU_SELECT
case $GPU_SELECT in
    1)
        echo "Install drivers for AMD..."
        pacman -S mesa lib32-mesa xf86-video-amdgpu vulkan-radeon lib32-vulkan-radeon libva-mesa-driver lib32-libva-mesa-driver mesa-vdpau lib32-mesa-vdpau
        mkdir /etc/X11
        mkdir /etc/X11/xorg.conf.d
        echo $AMD_XORG > /etc/X11/xorg.conf.d/20-amdgpu.conf
        ;;
    2)
        echo "Install drivers for NVIDIA..."
        ;;
esac
echo "=====| Install microcoe (Only GRUB!) |====="
echo "Your CPU: 1) INTEL 2) AMD"
read CPU_SELECT
case $CPU_SELECT in
    1)
        echo "Install microcode for INTEL..."
        pacman -S intel-ucode
        grub-mkconfig -o /boot/grub/grub.cfg
        ;;
    2)
        echo "Install microcode for AMD..."
        ;;
esac

# Config Xorg
echo "=====| Xorg Config generate... |====="
Xorg :0 -configure
mv xorg.conf.new /etc/X11/xorg.conf
touch $KEYBOARD_XORG > /etc/X11/xorg.conf.d/00-keyboard.conf

# Config folder
echo "=====| Create config dir (~/.config) |====="
su $USER_NAME
mkdir $HOME_DIR/.config
exit

# Install picom
echo "=====| Install picom |====="
pacman -S picom
su $USER_NAME
cd
mkdir $HOME_DIR/.config/picom
cp /etc/xdg/picom.conf $HOME_DIR/.config/picom
cd
exit

# Install Pipewire
echo "=====| Install pipewire |====="
pacman -S pipewire lib32-pipewire
pacman -S pipewire-alsa pipewire-pulse pipewire-jack lib32-pipewire-jack pipewire-audio
su $USER_NAME
cd
cp -r /usr/share/pipewire $HOME_DIR/.config/pipewire

# Install fonts
echo "=====| Install fonts |====="
pacman -S noto-fonts noto-fonts-cjk noto-fonts-emoji ttf-liberation

# Install i3 
echo "=====| Install i3 |====="
pacman -S i3-wm

# Install rofi 
echo "=====| Install rofi |====="
pacman -S rofi
su $USER_NAME
cd
mkdir $HOME_DIR/.config/rofi
rofi -dump-config > $HOME_DIR/.config/rofi/config.rasi
cd
exit

# Install polybar
echo "=====| Install polybar |====="
pacman -S polybar
su $USER_NAME
cd
mkdir $HOME_DIR/.config/polybar
cp /etc/polybar/config.ini $HOME_DIR/.config/polybar
cd
exit

# Install alacritty
echo "=====| Install alacritty |====="
pacman -S alacritty
su $USER_NAME
cd
mkdir $HOME_DIR/.config/alacritty
cd $HOME_DIR/.config/alacritty
wget https://github.com/alacritty/alacritty/releases/download/v0.12.0/alacritty.yml
cd
exit
cd

# Install ly
echo "=====| Install ly (without config) |====="
su $USER_NAME
cd
paru -S ly
exit
cd

# Install dunst
echo "=====| Install dunst |====="
pacman -S dunst
su $USER_NAME
cd
mkdir $HOME_DIR/.config/dunst
cp /etc/dunst/dunstrc $HOME_DIR/.config/dunst/dunstrc
exit
cd

# Install betterlockscreen
echo "=====| Install betterlockscreen |====="
su $USER_NAME
cd
paru -S betterlockscreen
exit
cd

echo "=====| Install pactl, playerctl, firefox, maim, xclip |====="
pacman -S pactl playerctl firefox maim xclip xdotool

echo "=====| Complete |====="
