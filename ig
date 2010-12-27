#!/bin/bash

#
# 'interactive' grep
#

showfile() {
  local file linenum choice=$1

  # sanitize $choice of control characters and split
  IFS=':' read file linenum _ < <(sed 's/\[[[:digit:]]*[mK]//g' <<< "$choice")

  vim "$file" +$linenum
}

(( $# < 2 )) && { echo "usage: ${0##*/} [grep-options] <pattern> files..."; exit 1; } >&2

IFS=$'\n' read -r -d $'\0' -a results < <(grep --color=always -n "$@")

(( ${#results[@]} )) || exit 1

PS3="select a # or ^C to end] "
while [[ -z $choice ]]; do
  select choice in "${results[@]}"; do 
    showfile "$choice"
  done
done

