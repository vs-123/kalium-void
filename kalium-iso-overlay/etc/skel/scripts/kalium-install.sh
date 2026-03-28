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
sudo wipefs -a "$TARGET"
sudo parted -s "$TARGET" mklabel gpt
sudo parted -s "$TARGET" mkpart ESP fat32 1MiB 1GiB
sudo parted -s "$TARGET" set 1 esp on
sudo parted -s "$TARGET" mkpart primary linux-swap 1GiB 9GiB
sudo parted -s "$TARGET" mkpart primary ext4 9GiB 100%

echo "=> FORMATTING FILE SYSTEMS..."
sudo mkfs.vfat "${TARGET}1"
sudo mkswap "${TARGET}2"
sudo mkfs.ext4 "${TARGET}3"

echo "=> MOUNTING..."
sudo mount --mkdir "${TARGET}3" /mnt/
sudo mount --mkdir "${TARGET}1" /mnt/boot/efi
sudo swapon "${TARGET}2"

echo "=> CLONING KALIUM VOID. PLEASE WAIT..."
sudo rsync -axHAWXS --numeric-ids --info=progress2 / /mnt

echo "=> GENERATING FSTAB..."
sudo xgenfstab -U /mnt > /mnt/etc/fstab

echo "=> MOUNT VIRTUAL FS..."
for i in dev sys proc
do
   mount --rbind /$i /mnt/$i
done

echo "=> CONFIGURING SYSTEM..."
sudo cp /etc/resolv.conf /mnt/etc/
sudo chroot /mnt /bin/zsh <<EOF
   useradd -m -G wheel,audio,video,storage,users $NEWUSER

	echo "=> SETUP DOTS"
   su $NEWUSER
   chezmoi init --apply vs-123
   exit

   cp /usr/share/splash.png /boot/grub/splash.png
   echo "[SET PASSWORD FOR $NEWUSER]"
   passwd $NEWUSER < /dev/tty
	chsh -s /bin/zsh $NEWUSER
   echo "[SET PASSWORD FOR ROOT]"
   passwd root < /dev/tty

	echo "kalium-void" > /etc/hostname
   grub-install --target=arm64-efi --efi-directory=/boot/efi --bootloader-id="Kalium-Void"
   xbps-reconfigure -fa

	echo "=> SANITY CHECK"
	ls /boot/grub/
	grep menuentry /boot/grub/grub.cfg
   echo 'GRUB_BACKGROUND="/boot/grub/splash.png"' >> /etc/default/grub

	echo "=> SPLASH IMAGE"
   cp /usr/share/splash.png /boot/grub/splash.png

	echo "=> SUDO"
   echo "$NEWUSER ALL=(ALL:ALL) ALL" >> /etc/sudoers
EOF


echo "#################################################"
echo "#  INSTALL COMPLETE. POWERING OFF IN 5 SECS...  #"
echo "#              EJECT ISO AND BOOT               #"
echo "#################################################"

sleep 5 && sudo poweroff
