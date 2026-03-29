#!/bin/sh
# Version: 6

# This script will convert the *.po files to *.mo files, rebuilding the package/contents/locale folder.
# Feature discussion: https://phabricator.kde.org/D5209
# Eg: contents/locale/fr_CA/LC_MESSAGES/plasma_applet_org.kde.plasma.eventcalendar.mo

DIR=`cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd`
kreadconfig_cmd=""
if [ -x "$(command -v kreadconfig6)" ]; then
	kreadconfig_cmd="kreadconfig6"
elif [ -x "$(command -v kreadconfig)" ]; then
	kreadconfig_cmd="kreadconfig"
fi

if [ -z "$kreadconfig_cmd" ]; then
	echo "[build] Error: Could not find kreadconfig6/kreadconfig (Plasma 6 required)."
	exit 1
fi

plasmoidName=`$kreadconfig_cmd --file="$DIR/../metadata.desktop" --group="Desktop Entry" --key="X-KDE-PluginInfo-Name"`
website=`$kreadconfig_cmd --file="$DIR/../metadata.desktop" --group="Desktop Entry" --key="X-KDE-PluginInfo-Website"`
bugAddress="$website"
packageRoot=".." # Root of translatable sources
projectName="plasma_applet_${plasmoidName}" # project name

#---
if [ -z "$plasmoidName" ]; then
	echo "[build] Error: Couldn't read plasmoidName."
	exit
fi

if [ -z "$(which msgfmt)" ]; then
	echo "[build] Error: msgfmt command not found. Need to install gettext"
	echo "[build] Running 'sudo apt install gettext'"
	sudo apt install gettext
	echo "[build] gettext installation should be finished. Going back to installing translations."
fi

#---
echo "[build] Compiling messages"

catalogs=`find . -name '*.po' | sort`
for cat in $catalogs; do
	echo "$cat"
	catLocale=`basename ${cat%.*}`
	msgfmt -o "${catLocale}.mo" "$cat"

	installPath="$DIR/../contents/locale/${catLocale}/LC_MESSAGES/${projectName}.mo"

	echo "[build] Install to ${installPath}"
	mkdir -p "$(dirname "$installPath")"
	mv "${catLocale}.mo" "${installPath}"
done

echo "[build] Done building messages"

if [ "$1" = "--restartplasma" ]; then
	echo "[build] Restarting plasmashell"
	killall plasmashell
	if [ -x "$(command -v kstart6)" ]; then
		kstart6 plasmashell
	elif [ -x "$(command -v kstart)" ]; then
		kstart plasmashell
	else
		echo "[build] Error: Could not find kstart6/kstart (Plasma 6 required)."
		exit 1
	fi
	echo "[build] Done restarting plasmashell"
else
	echo "[build] (re)install the plasmoid and restart plasmashell to test."
fi
