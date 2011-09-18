#!/bin/bash

#
# flac2mp3 - a mass conversion utility
# requires: `flac' and `lame'
#

ARG0=${0##*/}
TAGVARS=(album artist date genre title tracknumber)

# runtime options
FORCE=0
LAME_OPTS="-h"
FLAC_OPTS=""
PRESERVE=0
RECURSE=0
VERBOSE=1
QUITONWARN=0

warn() {
  local mesg=$1; shift
  printf '\e[1;33m:: \e[0m%s\n' "$mesg"
  (( QUITONWARN )) && exit 1
} >&2

die() {
  local mesg=$1; shift
  printf '\e[1;31m:: \e[0m%s\n' "$mesg"
  exit 1
} >&2

mkdir_vp() {
  mkdir -p "$1" && printf "%s: created directory \`%s'" "$ARG0" "$!"
}

usage() {
  printf "usage: $ARG0 [options] SOURCE... DESTINATION\n"
  printf "       $ARG0 [options] -t DESTINATION SOURCE...\n\n"
  printf "   -f                  overwrite existing files\n"
  printf "   -h                  display this help message\n"
  printf "   -l ARGS             additional parameters to pass to lame\n"
  printf "   -q                  don't print to stdout\n"
  printf "   -r                  convert directories recursively (implies -p)\n"
  printf "   -t PATH             use PATH as destination for converted SOURCEs\n"
  printf "   -w                  quit on warnings\n\n"
} >&2

# find flac files in a given dir, recursing unless told otherwise
expand_dir() {
  for arg in "$@"; do
    find "$arg" -type f -name '*.flac'
  done
}

# convert with tags (only setting tags if they exist)
convert() {
  local input output artist title album date tracknumber genre
  input=$1
  output=$2

  eval $(metaflac --export-tags-to - "$1" | awk -F'=' '!/[ ].*=/{ printf "%s=\"%s\"\n", tolower($1), $2 }')

  (( VERBOSE )) || { LAME_OPTS+=" --quiet"; FLAC_OPTS+=" --silent"; }

  flac -cd $FLAC_OPTS "$input" | lame --add-id3v2 $LAME_OPTS \
                                  ${artist:+--ta "$artist"} \
                                  ${title:+--tt "$title"} \
                                  ${tracknumber:+--tn "$tracknumber"} \
                                  ${genre:+--tg "$genre"} \
                                  ${comment:+--tc "$comment"} \
                                  ${album:+--tl "$album"} \
                                  - "${output}"
}

while getopts ":fhl:qrt:w" opt; do
  case $opt in
    f) FORCE=1 ;;
    h) usage; exit 1 ;;
    l) LAME_OPTS+=" $OPTARG" ;;
    q) VERBOSE=0 ;;
    r) RECURSE=1 PRESERVE=1 ;;
    t) DEST=$OPTARG ;;
    w) QUITONWARN=1 ;;
    \?) die "$ARG0: invalid option -- '$OPTARG'" ;;
    \:) die "$ARG0: option '$OPTARG' requires an argument" ;;
  esac
done
shift $(( OPTIND - 1 ))

# basic arg check
(( $# )) || { usage; exit; }

# deal with args in an array rather than as positional params. this will make
# life easier if we need to strip the last param for the destination.
args=("$@")

# if -t wasn't given, strip the last arg for the destination
if [[ -z $DEST ]]; then
  DEST=${!#}
  args=("${@:1:(( $# - 1 ))}")
fi

# all but the last part of the dest needs to exist
fulldest=$(readlink -f "$DEST")
if [[ -z $fulldest ]]; then
  die "error: cannot create directory \`$DEST': No such file or directory"
fi

# main loop
for arg in "${args[@]}"; do
  if [[ -d $arg ]]; then
    # only handle directories if -r was passed
    (( ! RECURSE )) && { warn "warning: omitting directory \`$arg'"; continue; }
    IFS=$'\n' read -d'\0' -r -a flacs < <(expand_dir "$arg")
  else
    flacs=$arg
  fi

  for flac in "${flacs[@]}"; do
    if [[ ! $(file -bi --mime-type "$flac") = audio/x-flac ]]; then
      warn "warning: '$flac' is not a valid flac file"
    fi

    if (( PRESERVE )); then
      # use basename(1) instead of a bash PE so we don't need to fight with the
      # possibility of a superfluous trailing slash
      outfile=$fulldest/$(basename "$arg")/${flac#$arg}
      if [[ ! -d ${outfile%/*} ]]; then
        mkdir_vp "${outfile%/*}" || die "error: failed to create directory \`${outfile%/*}'"
      fi
    else
      outfile=$DEST/${flac##*/}
    fi

    # a proper extension please...
    outfile=${outfile%.flac}.mp3

    # does the outfile exist?
    if [[ -f $outfile ]] && (( ! FORCE )); then 
      warn "warning: file \`$outfile' already exists -- skipping"
      continue
    fi

    # finally, do the conversion
    convert "$flac" "$outfile" || warn "warning: failed to convert to mp3"
  done
done

