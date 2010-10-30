#!/bin/sh

pgrep offlineimap || offlineimap -o -u Noninteractive.Quiet &

exit 0
