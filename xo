#!/bin/bash
#
# A command line utility that mimics xdg-open
# Requires Bash 4.0+
#

# Arg check
(( $# )) || { printf "Usage: %s <file>\n" "${0##*/}" >&2; exit 1; }

# Declare an associative array to keep track of our file types.
# Index elements can be a full MIME type (e.g. image/png), just
# the major MIME type (e.g. image) or a file extension (png).
declare -A handler

# To keep things clean, general programs should be declared for
# groups of filetypes resulting in the same program being used
# when a major MIME type won't correctly identify all filetypes.
# openoffice.org documents are an example of this.
doc=soffice
image=feh
video=mplayer
default=${EDITOR:-vi} # Fallback -- should be a text editor

handler[application/pdf]=zathura
handler[application/vnd.oasis.opendocument.text]=$doc
handler[doc]=$doc
handler[image]=$image
handler[odb]=$doc
handler[odf]=$doc
handler[ods]=$doc
handler[text/rtf]=$doc
handler[video]=$video
handler[application/ogg]=$video
handler[mkv]=$video
handler[xls]=$doc

# Determine the MIME type via 'file' and assign it to an array
# mimetype[0] = major (e.g. image)
# mimetype[1] = minor (e.g. png)
IFS='/' read -rd ';' -a mimetype < <(file -bi --mime-type "$1")

# Determine the extension as a fallback method
ext=${1//*.}

# Try to open by exact MIME type
if [[ -n ${handler[${mimetype[0]}/${mimetype[1]}]} ]]; then
    ${handler[${mimetype[0]}/${mimetype[1]}]} "$@"

# Try to open by major MIME type
elif [[ -n ${handler[${mimetype[0]}]} ]]; then
    ${handler[${mimetype[0]}]} "$@"

# Try to open by extension
elif [[ -n ${handler[$ext]} ]]; then
    ${handler[$ext]} "$@"

# Well, I'm out of ideas. Use the $default.
else
    $default "$@"
fi

