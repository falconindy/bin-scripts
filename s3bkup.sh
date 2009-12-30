#!/bin/bash

# Static Declarations
BKUP_ROOT="/mnt/Gluttony/backup"
EXCLUSION_LIST="/tmp/exclude.conf"
LOGFILE="/mnt/Gluttony/backup/s3bkup.log"

exec 6>&1 #save a descriptor pointing to STDOUT
exec >> $LOGFILE #redirect all to log

# Start logging
echo "-------------------------------------------------"
echo "Backup starting at `date +'%D %T'` with parameter: $1" | tee -a $LOGFILE >&6

# Pre-emptively declare ending procedure since we're not sure when we're exiting (in case of error)
finish() {
	[[ -f "$EXCLUSION_LIST" ]] && rm "$EXCLUSION_LIST"	# remove our temp file for exclusions if it exists
	echo "Backup ended at `date +'%D %T'`" | tee -a $LOGFILE >&6
    exec 1>&6 6>&- #STDOUT back to STDOUT and destroy descriptor 6
	exit
}

# Are we root?
if [[ `id -u` -ne 0 ]]; then
	echo "ERROR: Permission denied. Must be root." >&2
	finish
fi

# Was a config file specified? Does it exist?
if [[ -z $1 ]] || [[ ! -f $1 ]]; then
	echo "ERROR: Unspecified or invalid config file." >&2
	finish
fi
BKUP_SUFFIX=`basename $1 | awk -F. '{print $2}'`

# Does our suffix exist? Create it if it doesn't
DESTINATION=${BKUP_ROOT}/${BKUP_SUFFIX}/
if [[ ! -d $DESTINATION ]]; then
	mkdir -p $DESTINATION
fi

# Determine includes and excudes (TODO: convert to one or the other, not both)
INCLUDES=(`grep -vE "^#" $1 | sed -n '/<include>/,/<\/include>/p' | grep -vE "</?include>" | sed 's/^[ \t]*//;s/[ \t]*$//'`)
grep -vE "^#" $1 | sed -n '/<exclude>/,/<\/exclude>/p' | grep -vE "</?exclude>" | sed 's/^[ \t]*//;s/[ \t]*$//' > "$EXCLUSION_LIST"

# Create the backup command
OPTIONS=("-Rua" "--delete" "--stats" "--exclude-from=$EXCLUSION_LIST")
COMMAND=("rsync" "${OPTIONS[@]}" "${INCLUDES[@]}" "$DESTINATION")

echo "Executing rsync as: ${COMMAND[@]}" | tee -a $LOGFILE >&6

# Enough talk. Fucking do it already.
"${COMMAND[@]}" | tee -a $LOGFILE >&6

#Explanation of arguments in rsync
#   -R = use relative path names
#   -u = skip files that are newer on the receiver
#   -a = equivalent of -rlptgoD
#     -r = recurse into directories
#     -l = copy symlinks as symlinks
#     -p = preserve permissions
#     -t = preserve modification times
#     -g = preserve group
#     -o = preserve owner
#     -D = preserve special and device files
#   --stats = give some file-transfer stats
#   --delete = delete extraneous files from destination dirs
#   --size-only = skip files that match in size
#   --exclude-from = path to our exclusion file
#
# NOTE: -n can be added to the execution to create a dry-run!

finish

