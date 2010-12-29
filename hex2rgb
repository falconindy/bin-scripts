#!/bin/bash

[[ -z $1 ]] && {
  printf "Usage: %s <XResources color file>" "${0##*/}" >&2
  exit 1
}

hex2dec() {
  for val; do
    printf "%3d " "0x$val"
  done
  printf "\n"
}

printf "\t\t%3s %3s %3s\n" "R" "G" "B"
while read line; do
  [[ ! $line =~ ^\*color ]] && continue
  printf "${line% *}\t"
  hexcode=${line/\*color* /}
  hex2dec ${hexcode:1:2} ${hexcode:3:2} ${hexcode:5:2}
done < $1

