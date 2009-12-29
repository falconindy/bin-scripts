#!/bin/bash

# Static Declarations
BKUP_ROOT="/mnt/Gluttony/backup"
BKUP_SUFFIX=`basename $1 | awk -F. '{print $2}'`
DESTINATION=${BKUP_ROOT}/${BKUP_SUFFIX}/
EXCLUSION_LIST="/tmp/exclude.conf"
LOGFILE="/mnt/Gluttony/backup/s3bkup.log"

# Start logging
echo "-------------------------------------------------" >> $LOGFILE
echo "Backup starting at `date +'%D %T'` with parameter: $1" | tee -a $LOGFILE		# timestamp this bad agent

# Pre-emptively declare ending procedure since we're not sure when we're exiting (in case of error)
finish() {
	[[ -f "$EXCLUSION_LIST" ]] && rm "$EXCLUSION_LIST"	# remove our temp file for exclusions if it exists
	echo "Backup ended at `date +'%D %T'`"	# timestamp this bad agent
	echo >> $LOGFILE
	exit
}

# Are we root?
if [[ `id -u` -ne 0 ]]; then
	echo "ERROR: Permission denied. Must be root." | tee -a $LOGFILE
	finish
fi

# Was a config file specified? Does it exist?
if [[ -z $1 ]] && [[ -f $1 ]]; then
	echo "ERROR: Unspecified or invalid config file." | tee -a $LOGFILE
	finish
fi

# Does our suffix exist? Create it if it doesn't
if [[ ! -d $DESTINATION ]]; then
	mkdir -p $DESTINATION
fi

# Determine our includes (what we'll be backing up)
INCLUDES=(`grep -vE "^#" $1 | sed -n '/<include>/,/<\/include>/p' | grep -vE "</?include>" | sed 's/^[ \t]*//;s/[ \t]*$//'`)

# Check to make sure our includes are all mounted
#for i in ${INCLUDES[@]}; do
#	if [[ `ls -ls $i | grep "total" | cut -d' ' -f2` -eq "0" ]]; then
#		echo "ERROR: Location $i not mounted! Halting backup." | tee -a $LOGFILE
#		finish
#	fi
#done

# Determine our excludes (what won't get backed up)
grep -vE "^#" $1 | sed -n '/<exclude>/,/<\/exclude>/p' | grep -vE "</?exclude>" | sed 's/^[ \t]*//;s/[ \t]*$//' > "$EXCLUSION_LIST"

# Declare an array of options
OPTIONS=("-Rua" "--delete" "--stats" "--exclude-from=$EXCLUSION_LIST")

# Declare our command
COMMAND=("rsync" "${OPTIONS[@]}" "${INCLUDES[@]}" "$DESTINATION")

echo "Executing rsync as:"
echo "  ${COMMAND[@]}" | tee -a $LOGFILE

# Enough talk. Fucking do it already.
"${COMMAND[@]}" | tee -a $LOGFILE

#Explanation of arguments in rsync
#	-R = use relative path names
#	-u = skip files that are newer on the receiver
#	-a = equivalent of -rlptgoD
#	  -r = recurse into directories
#	  -l = copy symlinks as symlinks
#	  -p = preserve permissions
#	  -t = preserve modification times
#	  -g = preserve group
#	  -o = preserve owner
#	  -D = preserve special and device files
#	--stats = give some file-transfer stats
#	--delete = delete extraneous files from destination dirs
#	--size-only = skip files that match in size
#	--exclude-from = path to our exclusion file
#
#	NOTE: -n can be added to the execution to create a dry-run!

# All done! Wrap it up, yo. Hopefully we got here with great success.
finish

