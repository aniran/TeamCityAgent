#!/bin/bash
set -e

print_usage() {
cat << EOL 
Usage: ${0} [arguments] 

Arguments: 
    --help, -h		Shows this help 
    --data, -d [DIR]	Set data dir 
    --logs, -l [DIR]	Set logs dir 
    --port, -p [PORT]	Set port used by TeamCity 

EOL
}

# Transform long options to short ones
for arg in "$@"; do
  shift 	# Shift left arguments so first one is bypassed
  case "$arg" in
    "--help") set -- "$@" "-h" ;;
    "--data") set -- "$@" "-d" ;;
    "--logs") set -- "$@" "-l" ;;
    "--port") set -- "$@" "-p" ;;
    *)        set -- "$@" "$arg"
  esac
done

# Default behavior
data="${PWD}/data"
logs="${PWD}/logs"
port=8080

# Parse short options
OPTIND=1

while getopts "hd:l:" opt
do
  case "$opt" in
    "h") print_usage; exit 0 ;;
    "d") data=$OPTARG ;;
    "l") logs=$OPTARG ;;
    "p") port=$OPTARG ;;
    "?") print_usage >&2; exit 1 ;;
  esac
done
shift $(expr $OPTIND - 1) # remove options from positional parameters

for DIR in ${data} ${logs}
do
	[ ! -d ${DIR} ] && mkdir -p ${DIR}
done

docker run -d --rm --name teamcity-server \
-u $(id -u):$(id -g) \
-v ${data}:/data/teamcity_server/datadir \
-v ${logs}:/opt/teamcity/logs  \
-p ${port}:8111 \
jetbrains/teamcity-server

