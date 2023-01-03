#!/usr/bin/env bash

set -e

if [ "$__DS_PATH__" == "" ]; then
    cat <<EOF
    {
        "crt": "",
        "key": ""
    }
EOF
    exit 0
fi

crt="$1/$__DS_PATH__-full.pem"
key="$1/$__DS_PATH__-key.pem"

cat <<EOF
{
    "crt": "$(cat $crt)",
    "key": "$(cat $key)"
}
EOF
