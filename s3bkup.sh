#!/bin/bash

# Static Declarations
BKUP_ROOT="/mnt/Gluttony/backup"
LOGFILE="${BKUP_ROOT}/s3bkup.log"

exec 6>&1 #save a descriptor pointing to STDOUT
exec >> $LOGFILE #redirect all to log

# Start logging
echo "-------------------------------------------------"
echo "Backup starting at `date +'%D %T'` with parameter: $1" | tee -a $LOGFILE >&6

# Pre-emptively declare ending procedure since we're not sure when we're exiting (in case of error)
finish() {
    echo "Backup ended at `date +'%D %T'` ($1)" | tee -a $LOGFILE >&6
    exec 1>&6 6>&- #STDOUT back to STDOUT and destroy descriptor 6
    exit
}

# Are we root?
if [[ `id -u` -ne 0 ]]; then
    echo "ERROR: Permission denied. Must be root." >&2
    finish "failure"
fi

# Was a config file specified? Does it exist?
if [[ -z $1 ]] || [[ ! -f $1 ]]; then
    echo "ERROR: Unspecified or invalid config file." >&2
    finish "failure"
fi
BKUP_SUFFIX=`basename $1 | awk -F. '{print $2}'`

# Does our suffix exist? Create it if it doesn't
DESTINATION=${BKUP_ROOT}/${BKUP_SUFFIX}/
[[ ! -d $DESTINATION ]] && mkdir -p $DESTINATION

# Determine includes and excudes
INCLUDES=(`grep -vE "^#" $1 | sed -n '/<include>/,/<\/include>/p' | grep -vE "</?include>" | sed 's/^[ \t]*//;s/[ \t]*$//'`)
EXCLUDES=(`grep -vE ^# $1 | sed -n '/<exclude>/,/<\/exclude>/p' | grep -vE "exclude>$" | sed -n 's/^/--exclude/p'`)

# Create the backup command
OPTIONS=("-Rua" "--delete" "--stats")
COMMAND=("rsync" "${OPTIONS[@]}" "${EXCLUDES[@]}" "${INCLUDES[@]}" "$DESTINATION")

echo "Executing rsync with: ${COMMAND[@]:1:${#COMMAND[@]}}" | tee -a $LOGFILE >&6

# Enough talk. Fucking do it already.
"${COMMAND[@]}" | tee -a $LOGFILE >&6

finish "success"

