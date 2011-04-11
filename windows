#!/bin/bash

#
# a useless progress bar, windows style. doesn't tell you anything except that
# this particular process hasn't (yet) crashed.
#

declare bc1='-'            # "filled" progress
declare bc2='-'            # "unfilled" progress
declare pulser='<│││>'     # windows is awesome
declare -i bw=40           # bar width
declare -i pw=${#pulser}   # pulser width
st='.02s'                  # sleep time

printbar() {
  # leading visible bar
  printf '\e[1;35m%*s\e[0m' "$1" | tr ' ' "$bc1"

  # pulser
  printf '\e[1;34m%s\e[0m' "$pulser"

  # trailing visible bar
  printf '\e[1;35m%*s\e[0m\r' "$(( bw - pw - $1 ))" | tr ' ' "$bc2"

  sleep $st
}

while true; do
  for (( i = 0; i < bw-pw; i++ )); do
    printbar $i
  done
  for (( i = bw-pw; i > 0; i--)); do
    printbar $i
  done
done

