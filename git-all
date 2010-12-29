#!/bin/bash
# Usage: git-all [-Sfhv] [command...]"
#
#   -S    Show repos which have uncommitted changes. If this"
#          option is specified, all other options are ignored."
#
#   -v    print error output in job summary for failed jobs"
#
# Actions will be performed on $REPOHOME, which defaults to $HOME"
# if not specified."
#

REPOHOME=${REPOHOME:-$HOME}
VERBOSE=0

count=0
declare -a fail
declare -a pass
declare -A output

die() {
  local mesg=$1; shift
  printf "\033[1;31m::\033[0m ${mesg}\n" "$@" >&2
}

msg() {
  local mesg=$1; shift
  printf " \033[1;32m==>\033[1;0m\033[1;1m ${mesg}\033[1;0m\n" "$@" >&2
}

msg2() {
  local mesg=$1; shift
  printf " \033[1;34m  ->\033[1;0m\033[1;1m ${mesg}\033[1;0m\n" "$@" >&2
}

repopass() {
  printf " \033[1;0m\033[0;34m[\033[1;37mPASS\033[0;34m] \033[0;36m %s\033[0m\n" "$1"
}

repofail() {
  printf " \033[1;0m\033[0;34m[\033[1;31mFAIL\033[0;34m] \033[0;36m %s\033[0m\n" "$1" >&2
}

breadlink() {
  local path="$1";

  if [[ -d $path ]]; then
    (
      cd "$path"
      pwd -P
    )
  else
    printf "%s\n" "$path"
  fi
}
do_all_action() {
  IFS=$'\n' read -r -d $'\0' -a repos < <(find "$REPOHOME" -type d -name '.git' 2>/dev/null)

  for repo in "${repos[@]}"; do
    (( ++count ))
    local repo=$(breadlink ${repo%.git})

    cd "$repo"
    output[$repo]=$(git "$@" 2>&1) && pass=(${pass[@]} "$repo") || fail=(${fail[@]} "$repo")
  done
}

stat_repos() {
  IFS=$'\n' read -r -d $'\0' -a repos < <(find "$REPOHOME" -type d -name '.git' 2>/dev/null)

  for repo in "${repos[@]}"; do
    local repo=$(breadlink ${repo%.git})

    cd "$repo"
    [[ -n $(git status -s | grep -v "^??") ]] && printf "%s\n" "$repo"
  done
}

job_summary() {
  printf "\n"
  msg "Job Summary For $count Repos: git $*"

  if [[ ${#fail[@]} -eq 0 ]]; then
    msg2 "No errors were reported"
  else
    for repo in "${fail[@]}"; do
      repofail "$repo"
      (( VERBOSE )) && { sed 's/^/   /' <<< "${output[$repo]}"; printf "\n"; } >&2
    done
  fi
  printf "\n"

  for repo in "${pass[@]}"; do
    repopass "$repo"
  done
  printf "\n"
}

# sanity check
[[ ! -r "$REPOHOME" ]] && die "Invalid \$REPOHOME: $REPOHOME" exit 1

#while getopts :Sfv flag; do
while getopts :Sv flag; do
  case $flag in
    S) stat_repos; exit 0 ;;
    v) VERBOSE=1 ;;
    \?) die "invalid option -- '$OPTARG'" ;;
  esac >&2
done

shift $(( OPTIND-1 ))

# check command line usage
[[ $1 ]] || { sed -n '2,/^$/s/^# \?//p' "$0"; exit 1; }

# main loop
do_all_action "$@"
job_summary "$@"

