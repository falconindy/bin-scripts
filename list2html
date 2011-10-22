#!/bin/bash

(( $# != 2 )) && { printf "Usage: %s <columns> <input file>\n" "${0##*/}"; exit 1; } >&2

# Redirect STDOUT to an html file
exec >> output.html

# Start table
printf "<table>\n"

count=0 # Initialize a counter for columns
while read line; do
  if (( ! count )); then
    # We're at the start of a new row, open it.
    printf "\t<tr>\n"
  fi

  if (( count < $1 )); then
    # Print next line from data file
    printf "\t\t<td>%s</td>\n" "$line"
  fi

  (( count++ ))

  if (( count == $1 )); then
    # We're at the end of a row, close it.
    printf "\t</tr>\n"
    count=0
  fi
done < $2

# Kludge for when columns doesn't divide equally into data size
(( count )) && printf "\t</tr>\n"

# End table
printf "</table>\n"
