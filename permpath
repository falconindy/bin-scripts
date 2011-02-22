#!/bin/bash
# list directory permissions along the path

shopt -s extglob

rlflags='-'
while getopts fem opt; do
  [[ $opt == @(f|e|m) ]] && rlflags+="$opt"
done
shift $(( OPTIND - 1 ))

[[ $rlflags = - && ! -L ${!:PWD} ]] && rlflags='-f'

target=$(readlink $rlflags "${1:-$PWD}")

if [[ ! -e $target ]]; then
  echo "${0##*/}: cannot stat \`$target': No such file or directory"
  exit 1
fi

IFS='/' read -r -a dirpath <<< "$target"

for part in "${dirpath[@]}"; do
  working+="$part"
  [[ -z $working ]] || stat $working --printf "%A %U %G %n\n"
  working+='/'
done | column -t

