#!/bin/sh

set -eu

ARCH=$(uname -m)

echo "Installing package dependencies..."
echo "---------------------------------------------------------------"
pacman -Syu --noconfirm libcanberra

echo "Installing debloated packages..."
echo "---------------------------------------------------------------"
get-debloated-pkgs --add-common --prefer-nano intel-media-driver-mini ffmpeg-mini

echo "Downloading Firefox..."
echo "---------------------------------------------------------------"
case "$ARCH" in
	x86_64)  farch=linux64;;
	aarch64) farch=linux64-aarch64;;
esac

FIREFOX_CHANNEL=${FIREFOX_CHANNEL:-stable}
case "$FIREFOX_CHANNEL" in
	beta)
		product="firefox-beta-latest-ssl"
		;;
	devedition)
		product="firefox-devedition-latest-ssl"
		;;
	esr)
		product="firefox-esr-latest-ssl"
		;;
	*)
		product="firefox-latest-ssl"
		;;
esac

TARBALL_LINK=$(curl -sI "https://download.mozilla.org/?product=$product&os=$farch&lang=en-US" | grep -i '^location:' | awk '{print $2}' | tr -d '\r')

wget --retry-connrefused --tries=30 "$TARBALL_LINK" -O ./"${TARBALL_LINK##*/}"

mkdir -p ./AppDir/bin
tar -xvf ./"${TARBALL_LINK##*/}"
mv -v ./firefox/* ./AppDir/bin

echo "$TARBALL_LINK" | grep -oP 'releases/\K[^/]+(?=/linux)' > ~/version
