#!/bin/bash

#
# A light wrapper for pacman, implementing parallel downloading
# Requires: aria2
#

shopt -s extglob

PACARGS=("$@")
PACCACHE="/var/cache/pacman/pkg"
SYNC=0 BORING_OPT=0 DL_ONLY=0

# this is the easiest way to catch interesting operations we only want to catch
# things like -S or -Syu. Everything else will be passed straight to pacman
while getopts 'DQRSTUVb:cdefghiklmnopqr:stuvwy' opt; do
  case $opt in
    S) SYNC=1 ;;
    @(c|g|i|q|s)) BORING_OPT=1 ;;
    w) DL_ONLY=1 ;;
  esac
done

(( !SYNC || BORING_OPT )) && exec pacman $@

(( UID != 0 )) && { printf "Must be root!\n"; exit 1; } >&2

# find alternate pacman cache location
paccache=$(awk -F' *= *' '/[^#]CacheDir/{ print $2 }' /etc/pacman.conf)
[[ $paccache ]] && PACCACHE="$paccache"
unset paccache

# read in urls to packages needed for transaction
IFS=$'\n' read -r -d'\0' -a pkgs < <(pacman -p "${PACARGS[@]}" | grep -E '^(ht|f)tp')

# exit on null array
[[ -z "${pkgs[@]}" ]] && { printf "Nothing to do!\n"; exit 0; }

# create a dl manifest, so we don't pass superfluous URLs to aria
manifest=()
for pkg in "${pkgs[@]}"; do
  [[ -f $PACCACHE/${pkg##*/} ]] || manifest+=("$pkg")
done

if [[ ${manifest[@]} ]]; then
  printf ":: Packages to be downloaded:\n"
  for pkg in "${manifest[@]}"; do
    printf "   ==> %s\n" "${pkg##*/}"
  done
fi

# filthy. strip out any -y option
ARGS=()
for arg; do
  [[ $arg = -*y* ]] && arg=${arg//y/}
  ARGS+=("$arg")
done

aria2c -j 10 --dir "$PACCACHE" -i - < <(printf "%s\n" "${manifest[@]}")
(( DL_ONLY )) || pacman "${ARGS[@]}"

