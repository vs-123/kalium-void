#!/bin/bash
ROOTFS=$1

echo "=> KALIUM SETUP SCRIPT START"

echo "=> SERVICES..."
mkdir -p "$ROOTFS/etc/runit/runsvdir/default"

ln -sf /etc/sv/dhcpcd "$ROOTFS/etc/runit/runsvdir/default/"
ln -sf /etc/sv/sshd "$ROOTFS/etc/runit/runsvdir/default/"
ln -sf /etc/sv/acpid "$ROOTFS/etc/runit/runsvdir/default/"
ln -sf /etc/sv/dbus "$ROOTFS/etc/runit/runsvdir/default/"

echo "nameserver 1.1.1.1" > "$ROOTFS/etc/resolv.conf"

echo "=> EXECUTABLE INSTALLER..."

chmod +x "$ROOTFS/usr/local/bin/kalium-installer.sh"

echo "=> KALIUM SETUP SCRIPT END"
