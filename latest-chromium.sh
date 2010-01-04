#!/bin/bash
[[ "$1" = "yes" ]] && cd ~/abs/chromium-browser-bin/ && makepkg -fi && exit 0

echo "Currently using build: `pacman -Qi chromium-browser-svn | grep Version | cut -d: -f2`"
echo "Latest build available: `curl --silent http://build.chromium.org/buildbot/continuous/linux/LATEST/REVISION`"
