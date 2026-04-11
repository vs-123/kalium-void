#!/bin/bash

###########################
#  KALIUM VOID INSTALLER  #
###########################

set -e

if [ -z "$BASH_VERSION" ]
then
	echo "[ERROR] THIS IS NOT BASH. PLEASE RUN WITH BASH."
	exit 1
fi

if [ "$EUID" -ne 0 ]
then
	echo "[ERROR] YOU ARE NOT ROOT. RUN AS ROOT."
	exit 1
fi

clear
echo "==============================="
echo "     KALIUM VOID INSTALLER     "
echo "==============================="

lsblk -dno NAME,SIZE,MODEL | awk '{print "/dev/"$1 " - " $2 " - " $3}'
echo "-------------------------------------------------"

read -p "[TARGET DISK (e.g., /dev/sda)]: " TARGET
if [[ ! -b "$TARGET" ]]; then
	echo "[ERROR] $TARGET IS NOT A BLOCK DEVICE."
	exit 1
fi

read -p "[NEW USERNAME]: " NEWUSER
if [[ -z "$NEWUSER" ]]; then
	echo "[ERROR] USERNAME CANNOT BE EMPTY."
	exit 1
fi

echo "!!! WARNING: ALL DATA ON $TARGET WILL BE DELETED !!!"
read -p "ARE YOU ABSOLUTELY SURE? (y/N): " CONFIRM
if [[ $CONFIRM != "y" ]]; then
	echo "ABORTING"
	exit 1
fi

P_PREFIX=""
[[ "$TARGET" == *nvme* || "$TARGET" == *mmcblk* ]] && P_PREFIX="p"

BOOT_P="${TARGET}${P_PREFIX}1"
SWAP_P="${TARGET}${P_PREFIX}2"
ROOT_P="${TARGET}${P_PREFIX}3"

echo "=> PARTITIONING $TARGET..."
wipefs -a "$TARGET"
parted -s "$TARGET" mklabel gpt
parted -s "$TARGET" mkpart ESP fat32 1MiB 1GiB
parted -s "$TARGET" set 1 esp on
parted -s "$TARGET" mkpart primary linux-swap 1GiB 9GiB
parted -s "$TARGET" mkpart primary ext4 9GiB 100%

echo "=> FORMATTING FILE SYSTEMS..."
mkfs.vfat "$BOOT_P"
mkswap "$SWAP_P"
mkfs.ext4 "$ROOT_P"

echo "=> MOUNTING..."
mount --mkdir "$ROOT_P" /mnt/
mount --mkdir "$BOOT_P" /mnt/boot/efi
swapon "$SWAP_P"

echo "=> CLONING KALIUM VOID. THIS MAY TAKE A WHILE..."
rsync -axHAWXS --numeric-ids --info=progress2 --exclude={"/dev/*","/proc/*","/sys/*","/tmp/*","/run/*","/mnt/*","/media/*","/lost+found"} / /mnt/

echo "=> GENERATING FSTAB..."
xgenfstab -U /mnt > /mnt/etc/fstab

echo "=> MOUNT VIRTUAL FS..."
for i in dev sys proc run
do
	mount --rbind /$i /mnt/$i
done

cp /etc/resolv.conf /mnt/etc/

echo "=> CONFIGURING SYSTEM..."
chroot /mnt /bin/zsh <<EOF
	 useradd -m -G wheel,audio,video,storage,users,nixbld -s /bin/zsh "$NEWUSER"

	 echo "=> SETTING UP DOTFILES FOR $NEWUSER..."
	 su $NEWUSER
	 chezmoi init --apply vs-123 < /dev/tty
	 exit

	 echo "=> SET PASSWORDS"
	 echo "SET PASSWORD FOR $NEWUSER: "
	 passwd "$NEWUSER" < /dev/tty
	 echo "SET PASSWORD FOR ROOT: "
	 passwd root < /dev/tty

	 chsh -s /bin/zsh root
	 su $NEWUSER
	 sudo xbps-install -Syu kalium-base-files < /dev/tty
	 exit

	 echo "kalium-void" > /etc/hostname
	 chmod +x /usr/bin/lsb_release

	 echo "=> CONFIGURING GRUB SPLASH..."
	 sed -i '/GRUB_BACKGROUND/d' /etc/default/grub
	 mkdir -p /boot/grub
	 cp /usr/share/splash.png /boot/grub/splash.png 2>/dev/null || true
	 echo 'GRUB_BACKGROUND="/boot/grub/splash.png"' >> /etc/default/grub
	 grub-mkconfig -o /boot/grub/grub.cfg

	 echo "=> GRUB INSTALL"
	 grub-install --target=arm64-efi --efi-directory=/boot/efi --bootloader-id="Kalium-Void" --recheck

	 echo "=> RECONFIGURING PACKAGES..."
	 xbps-reconfigure -fa

	 echo "=> SUDOERS..."
	 echo "$NEWUSER ALL=(ALL:ALL) ALL" > "/etc/sudoers.d/99-$NEWUSER"
EOF

echo "==============================================="
echo "   INSTALL COMPLETE. REMOVE MEDIA AND REBOOT.  "
echo "        POWERING OFF IN 6 SECONDS...           "
echo "==============================================="

sleep 6 && sudo poweroff
