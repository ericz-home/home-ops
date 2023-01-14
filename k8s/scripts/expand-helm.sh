#!/usr/bin/env bash

set -e

if [ "$__DS_PATH__" == "" ]; then
    echo "[]"
    exit 0
fi

path=$(echo $__DS_PATH__ | awk -F? '{print "."$1}')
args=$(echo $__DS_PATH__ | awk -F? '{print $2}')
for p in ${args//&/ };do kvp=( ${p/=/ } ); k=${kvp[0]};v=${kvp[1]};eval $k=$v;done

helm template $name $chart -f $path -n $ns
