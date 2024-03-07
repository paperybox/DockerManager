#!/usr/bin/env bash

function usage() {
    echo "Usage: $0 [-n <container name>] [-h]" 1>&2
    echo " -n <container name>: set container name when create more than one"
    echo " -h: help info"
    exit 1

}

name=""

while getopts ":n:h" opt
do
    case "${opt}" in
    n)
        name=${OPTARG}
        ;;
    h)
        usage
        exit 0
        ;;
    *)
        name=""
        ;;
    esac
done

DEFUALT_NAME="docker_$USER"
CONTAINER_DEV=${DEFUALT_NAME}${name}

echo "login container: $CONTAINER_DEV"

xhost +local:root 1>/dev/null 2>&1
docker exec \
    -u docker_$USER \
    -it ${CONTAINER_DEV} \
    /bin/bash
xhost -local:root 1>/dev/null 2>&1
