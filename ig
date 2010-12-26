#!/bin/bash

#
# 'interactive' grep
#

(( $# < 2 )) && { echo "usage: ${0##*/} [grep-options] <pattern> files..."; exit 1; } >&2

IFS=$'\n' read -r -d $'\0' -a results < <(grep --color=always -n "$@")

(( ${#results[@]} )) || exit 1

while [[ -z $choice ]]; do
  select choice in "${results[@]}"; do break; done
done

# sanitize choice of control characters and split
IFS=':' read file linenum _ < <(sed 's/\[[[:digit:]]*[mK]//g' <<< "$choice")

vim "$file" +$linenum

