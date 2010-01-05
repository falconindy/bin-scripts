#!/bin/bash
[[ "$1" = "yes" ]] && cd ~/abs/chromium-browser-svn/ && makepkg -firs && exit 0

echo "Currently using build: `pacman -Qi chromium-browser-svn | grep Version | cut -d: -f2`"
echo "Latest build available: `curl --silent http://build.chromium.org/buildbot/continuous/linux/LATEST/REVISION`"
