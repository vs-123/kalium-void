#!/bin/bash

if [ ! -d "void-mklive" ]
then
	git clone --depth 1 https://github.com/void-linux/void-mklive.git
fi

cd ./void-mklive 

rm ./data/splash.png &&
rm ./data/issue &&
cp ../splash.png ./data/ &&
mkdir -p ../kalium-iso-overlay/usr/share/ &&
cp ../splash.png ../kalium-iso-overlay/usr/share/splash.png &&
cp ../kalium-iso-overlay/etc/issue ./data/issue

sudo ./mklive.sh \
   -p "$(cat ../packages.txt)"  \
   -S "acpid dhcpcd sshd"  \
   -I ../kalium-iso-overlay \
   -x ../finish_kalium_void.sh  \
   -T "Kalium Void" \
   -e /bin/zsh \
   -o ../kalium-void.iso

#   Usage: mklive.sh [options]
#   
#   Generates a basic live ISO image of Void Linux. This ISO image can be written
#   to a CD/DVD-ROM or any USB stick.
#   
#   To generate a more complete live ISO image, use mkiso.sh.
#   
#   OPTIONS
#    -a <arch>          Set XBPS_ARCH in the ISO image
#    -b <system-pkg>    Set an alternative base package (default: base-system)
#    -r <repo>          Use this XBPS repository. May be specified multiple times
#    -c <cachedir>      Use this XBPS cache directory (default: ./xbps-cachedir-<arch>)
#    -H <host_cachedir> Use this Host XBPS cache directory (default: ./xbps-cachedir-<host_arch>)
#    -k <keymap>        Default keymap to use (default: us)
#    -l <locale>        Default locale to use (default: en_US.UTF-8)
#    -i <lz4|gzip|bzip2|xz>
#                       Compression type for the initramfs image (default: xz)
#    -s <gzip|lzo|xz>   Compression type for the squashfs image (default: xz)
#    -o <file>          Output file name for the ISO image (default: automatic)
#    -p "<pkg> ..."     Install additional packages in the ISO image
#    -g "<pkg> ..."     Ignore packages when building the ISO image
#    -I <includedir>    Include directory structure under given path in the ROOTFS
#    -S "<service> ..." Enable services in the ISO image
#    -e <shell>         Default shell of the root user (must be absolute path).
#                       Set the live.shell kernel argument to change the default shell of anon.
#    -C "<arg> ..."     Add additional kernel command line arguments
#    -P "<platform> ..."
#                       Platforms to enable for aarch64 EFI ISO images (available: pinebookpro, x13s)
#    -T <title>         Modify the bootloader title (default: Void Linux)
#    -v linux<version>  Install a custom Linux version on ISO image (default: linux metapackage).
#                       Also accepts linux metapackages (linux-mainline, linux-lts).
#    -x <script>        Path to a postsetup script to run before generating the initramfs
#                               (receives the path to the ROOTFS as an argument)
#    -K                 Do not remove builddir
#    -h                 Show this help and exit
#    -V                 Show version and exit

