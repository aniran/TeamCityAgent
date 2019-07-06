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
    "--server_url") set -- "$@" "-s" ;;
    "--config_dir") set -- "$@" "-c" ;;
    *)        set -- "$@" "$arg"
  esac
done

# Default behavior
LOCAL_IP=$(ip address | grep 192.168 | awk '{print $2}' | cut -d'/' -f1)
server_url="http://${LOCAL_IP}:8080"
config_dir="${PWD}/agent_conf"

# Parse short options
OPTIND=1

while getopts "hs:c:" opt
do
  case "$opt" in
    "h") print_usage; exit 0 ;;
    "s") server_url=$OPTARG ;;
    "c") config_dir=$OPTARG ;;
    "?") print_usage >&2; exit 1 ;;
  esac
done
shift $(expr $OPTIND - 1) # remove options from positional parameters

for DIR in ${config_dir}
do
	[ ! -d ${DIR} ] && mkdir -p ${DIR}
done

docker run -i -t --rm \
-e SERVER_URL=${server_url} \
-u $(id -u):$(id -g) \
-v ${config_dir}:/data/teamcity_agent/conf \
jetbrains/teamcity-agent

#docker run -d --rm --name teamcity-server \
#-u $(id -u):$(id -g) \
#-v ${data}:/data/teamcity_server/datadir \
#-v ${logs}:/opt/teamcity/logs  \
#-p ${port}:8111 \
#jetbrains/teamcity-server

