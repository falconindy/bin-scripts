#!/bin/sh

pgrep offlineimap >/dev/null || offlineimap -o -u Noninteractive.Quiet &

exit 0
