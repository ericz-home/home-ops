#!/usr/bin/env bash

set -e

if [ "$__DS_PATH__" == "" ]; then
    echo "[]"
    exit 0
fi

path=$(echo $__DS_PATH__ | awk -F? '{print "."$1}')
args=$(echo $__DS_PATH__ | awk -F? '{print $2}')
for p in ${args//&/ };do kvp=( ${p/=/ } ); k=${kvp[0]};v=${kvp[1]};eval $k=$v;done

path_args=""
if [ "$path" != "./" ]; then
    path_args="-f $path"
fi

version_args=""
if [ "$version" != "" ]; then
    version_args="--version=$version"
fi

helm template $name $chart --include-crds $path_args -n $ns $version_args
