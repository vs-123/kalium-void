#!/bin/bash

if [ -z "$1" ]; then
	echo "[USAGE] $0 <ARCHITECTURE> (E.G., X86_64 OR AARCH64)"
	exit 1
fi
ARCH=$1

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

yes | sudo ./mklive.sh \
	-I ../kalium-iso-overlay \
	-S "acpid dbus dhcpcd sshd nix-daemon"  \
	-T "Kalium Void" \
	-C "live.shell=/bin/zsh" \
	-a $ARCH \
	-e /bin/zsh \
	-o "../kalium-void-$ARCH.iso" \
	-p "$(cat ../packages.txt)"  \
	-r "https://github.com/vs-123/kalium-packages/releases/latest/download" \
	-x ../finish_kalium_void.sh  
	#-r ./kalium-repo/hostdir/binpkgs 



#-r "https://github.com/index-0/librewolf-void/releases/latest/download/" \







#   OPTIONS
#    -a <arch>          SET XBPS_ARCH IN THE ISO IMAGE
#    -b <system-pkg>    SET AN ALTERNATIVE BASE PACKAGE (DEFAULT: BASE-SYSTEM)
#    -r <repo>          USE THIS XBPS REPOSITORY. MAY BE SPECIFIED MULTIPLE TIMES
#    -c <cachedir>      USE THIS XBPS CACHE DIRECTORY (DEFAULT: ./XBPS-CACHEDIR-<ARCH>)
#    -H <host_cachedir> USE THIS HOST XBPS CACHE DIRECTORY (DEFAULT: ./XBPS-CACHEDIR-<HOST_ARCH>)
#    -k <keymap>        DEFAULT KEYMAP TO USE (DEFAULT: US)
#    -l <locale>        DEFAULT LOCALE TO USE (DEFAULT: EN_US.UTF-8)
#    -i <lz4|gzip|bzip2|XZ>
#                       COMPRESSION TYPE FOR THE INITRAMFS IMAGE (DEFAULT: XZ)
#    -s <gzip|lzo|xz>   COMPRESSION TYPE FOR THE SQUASHFS IMAGE (DEFAULT: XZ)
#    -o <file>          OUTPUT FILE NAME FOR THE ISO IMAGE (DEFAULT: AUTOMATIC)
#    -p "<pkg> ..."     INSTALL ADDITIONAL PACKAGES IN THE ISO IMAGE
#    -g "<pkg> ..."     IGNORE PACKAGES WHEN BUILDING THE ISO IMAGE
#    -I <includedir>    INCLUDE DIRECTORY STRUCTURE UNDER GIVEN PATH IN THE ROOTFS
#    -S "<service> ..." ENABLE SERVICES IN THE ISO IMAGE
#    -e <shell>         DEFAULT SHELL OF THE ROOT USER (MUST BE ABSOLUTE PATH).
#                       SET THE LIVE.SHELL KERNEL ARGUMENT TO CHANGE THE DEFAULT SHELL OF ANON.
#    -C "<arg> ..."     ADD ADDITIONAL KERNEL COMMAND LINE ARGUMENTS
#    -P "<platform> ..."
#                       PLATFORMS TO ENABLE FOR AARCH64 EFI ISO IMAGES (AVAILABLE: PINEBOOKPRO, X13S)
#    -T <title>         MODIFY THE BOOTLOADER TITLE (DEFAULT: VOID LINUX)
#    -v linux<version>  INSTALL A CUSTOM LINUX VERSION ON ISO IMAGE (DEFAULT: LINUX METAPACKAGE).
#                       ALSO ACCEPTS LINUX METAPACKAGES (LINUX-MAINLINE, LINUX-LTS).
#    -x <script>        PATH TO A POSTSETUP SCRIPT TO RUN BEFORE GENERATING THE INITRAMFS
#                               (RECEIVES THE PATH TO THE ROOTFS AS AN ARGUMENT)
#    -K                 DO NOT REMOVE BUILDDIR
#    -h                 SHOW THIS HELP AND EXIT
#    -V                 SHOW VERSION AND EXIT

