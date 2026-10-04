#!/bin/sh

set -eu

ARCH=$(uname -m)
export ARCH
export OUTPATH=./dist
export ADD_HOOKS="self-updater.hook"
# each channel needs its own glob so they don't match each other's .zsync
case "${FIREFOX_CHANNEL:-stable}" in
	beta)
		export APPNAME=Firefox_Beta
		export ICON=https://raw.githubusercontent.com/mozilla/gecko-dev/master/browser/branding/official/default128.png
		export UPINFO="gh-releases-zsync|${GITHUB_REPOSITORY%/*}|${GITHUB_REPOSITORY#*/}|latest|Firefox_Beta-*$ARCH.AppImage.zsync"
		;;
	devedition)
		export APPNAME=Firefox_Developer_Edition
		export ICON=https://raw.githubusercontent.com/mozilla/gecko-dev/master/browser/branding/aurora/default128.png
		export UPINFO="gh-releases-zsync|${GITHUB_REPOSITORY%/*}|${GITHUB_REPOSITORY#*/}|latest|Firefox_Developer_Edition-*$ARCH.AppImage.zsync"
		;;
	esr)
		export APPNAME=Firefox_ESR
		export ICON=https://raw.githubusercontent.com/mozilla/gecko-dev/master/browser/branding/official/default128.png
		export UPINFO="gh-releases-zsync|${GITHUB_REPOSITORY%/*}|${GITHUB_REPOSITORY#*/}|latest|Firefox_ESR-*$ARCH.AppImage.zsync"
		;;
	*)
		export APPNAME=Firefox
		export ICON=https://raw.githubusercontent.com/mozilla/gecko-dev/master/browser/branding/official/default128.png
		export UPINFO="gh-releases-zsync|${GITHUB_REPOSITORY%/*}|${GITHUB_REPOSITORY#*/}|latest|Firefox-*$ARCH.AppImage.zsync"
		;;
esac

export DESKTOP=https://gitlab.archlinux.org/archlinux/packaging/packages/firefox/-/raw/main/firefox.desktop
export DEPLOY_OPENGL=1
export DEPLOY_VULKAN=1
export URUNTIME_PRELOAD=1

# Deploy dependencies
LD_LIBRARY_PATH=$PWD/AppDir/bin quick-sharun \
  ./AppDir/bin/* \
  /usr/lib/libavcodec.so* \
  /usr/lib/libcanberra.so*

echo 'MOZ_LEGACY_PROFILES=1' >>./AppDir/.env
echo 'MOZ_APP_LAUNCHER=${APPIMAGE}' >>./AppDir/.env

# Additional changes can be done in between here

# Turn AppDir into AppImage
quick-sharun --make-appimage

# only the stable release action needs ./dist/appinfo
[ "${FIREFOX_CHANNEL:-stable}" = stable ] || rm -f ./dist/appinfo

# Test the app for 12 seconds, if the test fails due to the app
# having issues running in the CI use --simple-test instead
quick-sharun --simple-test ./dist/*.AppImage
