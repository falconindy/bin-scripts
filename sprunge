#!/bin/bash

#
# uploader for sprunge.us
#

shopt -s extglob

declare -a respheaders

declare content_encoding=cat          # NOOP decompressor

declare -r uastring="bashium 0.2 (bash ${BASH_VERSINFO[0]}.${BASH_VERSINFO[1]})"
declare -r hostname='sprunge.us'
declare -r port='80' bufsiz=4096

usage() {
  cat <<EOF
Usage: ${0##*/} [file]

 Options:
  -h    display this help message and exit
  -v    show http request/response headers

${0##*/} either takes a file argument or input from stdin and posts
it to http://sprunge.us.

EOF
  exit $1
} >&2

die() {
  error "$@"
  exit 1
}

error() {
  local mesg=$1; shift
  printf "\033[1;31m::\033[0m $mesg\n" "$@"
}

warn() {
  local mesg=$1; shift
  printf "\033[1;33m::\033[0m $mesg\n" "$@"
}

info() {
  local mesg=$1; shift
  printf "\033[1;34m::\033[0m \033[1m$mesg\033[0m\n" "$@"
}

create_boundary_string() {
  # borrowed from curl's lib/formdata.c
  local -r hextab='1234567890abcdef'

  printf -- '-%.s' {1..28}
  for x in {1..12}; do
    printf '%c' "${hextab:RANDOM%16}"
  done
}

# content handlers
plain() {
  cat
}


# connect handler
connect() {
  { exec {sock}<>/dev/tcp/$hostname/$port; } 2>/dev/null ||
    die 'error: failed to connect to %s:%s\n' "$hostname" "$port"
}


# request handlers
send_http_request() {
  local request_uri=$1 content_len=$2 bstring=$3
  local -a headers=("POST $request_uri HTTP/1.1"
                    "User-Agent: $uastring"
                    "Host: $hostname"
                    "Accept: */*"
                    "Content-Length: $content_len"
                    "Content-Type: multipart/form-data; boundary=$bstring"
                    '')

  (( verbose )) && printf '> %s\n' "${headers[@]}" # "http://$hostname$1" 
  printf -- '%s\r\n' "${headers[@]}" >&$sock
}

send_form_body() {
  local formdata=$1 bstring=$2
  local -a body=("--$bstring"
                 'Content-Disposition: form-data; name="sprunge"'
                 ''
                 "$formdata"
                 "--$bstring--")

  (( verbose )) && printf '> %s\n' "${body[@]}"
  printf -- '%s\r\n' "${body[@]}" >&$sock
}


# response handlers
assert_response_code() {
  read -r -u $sock header resp status
  (( verbose )) && printf '< %s %s %s\n' "$header" "$resp" "$status"

  if (( resp != $1 )); then
    die 'response code asserted failed! expected %s, got %s %s' "$1" "$resp" "$status"
  fi
}

read_response_headers() {
  local header= value=

  # read response until the end of the headers
  while IFS=': ' read -r -u $sock header value; do
    # end of headers
    [[ $header = $'\r' ]] && break

    (( verbose )) && printf '< %s: %s\n' "$header" "$value"

    header=${header,,}
    header=${header//-/_}
    read -r -d $'\r' "$header" <<< "$value"

    respheaders+=("$header")
  done
  (( verbose )) && printf '\n'

  content_type=${content_type##*/} # trim 'application/'

  # sanitize
  content_type=${content_type//[.-]/_}
  content_encoding=${content_encoding//[.-]/_}

  if ! type -p "$content_type" &>/dev/null; then
    die 'unknown/unhandled content type: %s\n' "$content_type"
  fi

  if ! type -p "$content_encoding" &>/dev/null; then
    die 'unknown/unhandled encoding type: %s\n' "$content_encoding"
  fi
}

read_buffered() {
  local readlen= actual= bs= fd=$1 len=$2

  while (( len > 0 )); do
    (( len > bufsiz )) && readlen=$bufsiz || readlen=$len
    actual=$(<&$fd dd bs=1 count=$readlen 2>/dev/null | tee >(wc -c) >&5)
    (( len -= actual ))
  done 5>&1
}

read_response_body() {
  local len=

  if [[ $transfer_encoding = chunked ]]; then
    while true; do
      read -r -d $'\r\n' -u $sock len       # read length, consume \r
      read -r -n 1 -u $sock _               # consume \n

      len=$(( 0x$len ))                     # convert hex2dec
      if (( len == 0 )); then               # exit condition
        read -r -n 4 -u $sock _             # consume final \r\n\r\n
        break
      fi

      read_buffered $sock $len              # read chunk

      read -r -n 2 -u $sock _               # consume \r\n
    done
  else
    # hrmmm, unexpected. don't give up, just dump what we have out of the socket
    cat <&$sock
  fi
}

# main()
while getopts ':hv' opt; do
  case $opt in
    h) usage 0 ;;
    v) verbose=1 ;;
    ?) die '%s: invalid option -- '\''%s'\' "${0##*/}" "$OPTARG"
       exit 1 ;;
  esac
done
shift $(( OPTIND - 1 ))

# shutdown socket on exit
trap '[[ $sock && -e /dev/fd/$sock ]] && exec {sock}<&-' EXIT

if [[ $1 && ! -e $1 ]]; then
  die 'file not found: %s\n' "$1"
fi

boundary_string=$(create_boundary_string)

formdata=$(<"${1:-/dev/stdin}")

# boundary string + c-d header + data + boundary string (w/ tail) + line endings
content_len=$(( 42 + 46 + ${#formdata} + 44 + 10 ))

connect
send_http_request "/" "$content_len" "$boundary_string"
send_form_body "$formdata" "$boundary_string"
assert_response_code 200
read_response_headers
read_response_body

