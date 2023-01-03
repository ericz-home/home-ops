#!/usr/bin/env bash

set -e

if [ "$__DS_PATH__" == "" ]; then
    cat <<EOF
    {
        "privateKey": "",
        "publicKey": "",
        "knownHosts": ""
    }
EOF
    exit 0
fi

key="$1/$__DS_PATH__"
pub="$1/$__DS_PATH__.pub"

cat <<EOF
{
    "privateKey": "$(cat $key)",
    "publicKey": "$(cat $pub)",
    "knownHosts": "$(ssh-keyscan github.com 2>/dev/null)"
}
EOF
