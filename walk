#!/bin/bash

#
# emulates the 'tree' utility
#

shopt -s nullglob

indent=0
ind_sz=3
dirs_first=0
files_only=0

printentry() {
  printf "%*s%s\n" "$indent" "" "$1"
}

get_pwd_contents() {
  local dir nondir

  for f in *; do
    [[ -d $f ]] && dir+=("$f") || nondir+=("$f")
  done

  dir_contents=("${dir[@]}" "${nondir[@]}")
}

walk() {
  local dir_contents

  if (( !files_only )); then
    printentry "$(printf "\e[0;34m%s\e[0m" "$1")"
    (( indent += ind_sz ))
  fi

  pushd "$1" &>/dev/null

  (( dirs_first )) && get_pwd_contents || dir_contents=(*)
  for entry in "${dir_contents[@]}"; do
    if [[ -d $entry && ! -L $entry ]]; then
      walk "$entry"
    else
      printentry "$entry"
    fi
  done

  (( !files_only )) && (( indent -= ind_sz ))
  popd &>/dev/null
}

while getopts "afFd" opt; do
  case $opt in
    a) shopt -s dotglob ;;
    d) dirs_first=1 ;;
    f) files_only=1 ;;
  esac
done
shift $(( OPTIND - 1 ))

for basedir in "${@:-.}"; do
  walk "$basedir"
done

