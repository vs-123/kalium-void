#!/bin/bash

###########################
#  KALIUM VOID INSTALLER  #
###########################

set -e

echo "###########################"
echo "#  KALIUM VOID INSTALLER  #"
echo "###########################"
read -p "[TARGET DISK (E.G., /DEV/SDA)] " TARGET
read -p "[NEW USERNAME] " NEWUSER

echo "=> PARTITIONING $TARGET..."
wipefs -a "$TARGET"
parted -s "$TARGET" mklabel gpt
parted -s "$TARGET" mkpart ESP fat32 1MiB 1GiB
parted -s "$TARGET" set 1 esp on
parted -s "$TARGET" mkpart primary linux-swap 1GiB 9GiB
parted -s "$TARGET" mkpart primary ext4 9GiB 100%

echo "=> FORMATTING FILE SYSTEMS..."
mkfs.vfat "${TARGET}1"
mkswap "${TARGET}2"
mkfs.ext4 "${TARGET}3"

echo "=> MOUNTING..."
mkdir -p /mnt/
mount "${TARGET}3" /mnt/
mkdir -p /mnt/boot/efi
mount "${TARGET}1" /mnt/boot/efi
swapon "${TARGET}2"

echo "=> CLONING KALIUM VOID. PLEASE WAIT..."
rsync -axHAWXS --numeric-ids --info=progress2 / /mnt

echo "=> GENERATING FSTAB..."
xgenfstab -U /mnt > /mnt/etc/fstab

echo "=> MOUNT VIRTUAL FS..."
for i in dev sys proc
do
   mount --rbind /$i /mnt/$i
done

echo "=> CONFIGURING SYSTEM..."
cp /etc/resolv.conf /mnt/etc/
chroot /mnt /bin/zsh <<EOF
   useradd -m -G wheel,audio,video,storage,users $NEWUSER
   echo "[SET PASSWORD FOR $NEWUSER]"
   passwd $NEWUSER < /dev/tty
   echo "[SET PASSWORD FOR ROOT]"
   passwd root < /dev/tty
	echo "kalium-void" > /etc/hostname
   grub-install --target=arm64-efi --efi-directory=/boot/efi --bootloader-id="Kalium-Void"
   xbps-reconfigure -fa
	echo "=> SANITY CHECK"
	ls /boot/grub/
	grep menuentry /boot/grub/grub.cfg
EOF


echo "#####################################################"
echo "#  INSTALL COMPLETE. POWER OFF, EJECT ISO AND BOOT  #"
echo "#####################################################"
