##!/bin/bash
ROOTFS=$1

echo "=> KALIUM POST SETUP SCRIPT BEGIN"
mkdir -p "$ROOTFS/usr/share/xbps.d/keys"
cp "$ROOTFS/etc/xbps.d/keys/*" "$ROOTFS/usr/share/xbps.d/keys/"
echo "=> KALIUM POST SETUP SCRIPT END"
