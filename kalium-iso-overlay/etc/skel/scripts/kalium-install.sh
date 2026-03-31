#!/bin/bash

###########################
#  KALIUM VOID INSTALLER  #
###########################

set -euo pipefail

clear
echo "================================================="
echo "          KALIUM VOID INSTALLER (ARM64)          "
echo "================================================="

lsblk -dno NAME,SIZE,MODEL | awk '{print "/dev/"$1 " - " $2 " - " $3}'
echo "-------------------------------------------------"

read -p "[TARGET DISK (e.g., /dev/sda)]: " TARGET
if [[ ! -b "$TARGET" ]]; then
    echo "[ERROR] $TARGET is not a block device."
    exit 1
fi

read -p "[NEW USERNAME]: " NEWUSER
if [[ -z "$NEWUSER" ]]; then
    echo "Error: Username cannot be empty."
    exit 1
fi

echo "!!! WARNING: ALL DATA ON $TARGET WILL BE DELETED !!!"
read -p "Are you absolutely sure? (y/N): " CONFIRM
if [[ $CONFIRM != "y" ]]; then
    echo "Aborting."
    exit 1
fi

P_PREFIX=""
[[ "$TARGET" == *nvme* || "$TARGET" == *mmcblk* ]] && P_PREFIX="p"

BOOT_P="${TARGET}${P_PREFIX}1"
SWAP_P="${TARGET}${P_PREFIX}2"
ROOT_P="${TARGET}${P_PREFIX}3"

echo "=> PARTITIONING $TARGET..."
sudo wipefs -a "$TARGET"
sudo parted -s "$TARGET" mklabel gpt
sudo parted -s "$TARGET" mkpart ESP fat32 1MiB 1GiB
sudo parted -s "$TARGET" set 1 esp on
sudo parted -s "$TARGET" mkpart primary linux-swap 1GiB 9GiB
sudo parted -s "$TARGET" mkpart primary ext4 9GiB 100%

echo "=> FORMATTING FILE SYSTEMS..."
sudo mkfs.vfat "$BOOT_P"
sudo mkswap "$SWAP_P"
sudo mkfs.ext4 "$ROOT_P"

echo "=> MOUNTING..."
sudo mount --mkdir "$ROOT_P" /mnt/
sudo mount --mkdir "$BOOT_P" /mnt/boot/efi
sudo swapon "$SWAP_P"

echo "=> CLONING SYSTEM. THIS MAY TAKE A WHILE..."
sudo rsync -axHAWXS --numeric-ids --info=progress2 --exclude={"/dev/*","/proc/*","/sys/*","/tmp/*","/run/*","/mnt/*","/media/*","/lost+found"} / /mnt/

echo "=> GENERATING FSTAB..."
sudo xgenfstab -U /mnt > /mnt/etc/fstab

echo "=> PREPARING CHROOT..."
for i in dev sys proc run; do
    sudo mount --rbind /$i /mnt/$i
done

sudo cp /etc/resolv.conf /mnt/etc/

echo "=> ENTERING SYSTEM CONFIGURATION..."
sudo chroot /mnt /bin/zsh <<EOF
    set -e
    
    if ! id "$NEWUSER" &>/dev/null; then
        useradd -m -G wheel,audio,video,storage,users -s /bin/zsh "$NEWUSER"
    fi

    echo "=> SETTING UP DOTFILES FOR $NEWUSER..."
    sudo -u "$NEWUSER" chezmoi init --apply vs-123

    echo "=> CONFIGURING GRUB & SPLASH..."
    cp /usr/share/splash.png /boot/grub/splash.png 2>/dev/null || true
    echo 'GRUB_BACKGROUND="/boot/grub/splash.png"' >> /etc/default/grub

    echo "=> SET PASSWORDS"
    echo "ENTER PASSWORD FOR $NEWUSER: "
    passwd "$NEWUSER"
    echo "ENTER PASSWORD FOR ROOT: "
    passwd root

    echo "kalium-void" > /etc/hostname
    
    echo "=> RECONFIGURING PACKAGES..."
    grub-install --target=arm64-efi --efi-directory=/boot/efi --bootloader-id="Kalium-Void" --recheck
    xbps-reconfigure -fa

    echo "=> FINALISING SUDOERS..."
    echo "$NEWUSER ALL=(ALL:ALL) ALL" > "/etc/sudoers.d/99-$NEWUSER"
EOF

echo "==============================================="
echo "   INSTALL COMPLETE. REMOVE MEDIA AND REBOOT.  "
echo "        POWERING OFF IN 5 SECONDS...           "
echo "==============================================="

sleep 5 && sudo poweroff
