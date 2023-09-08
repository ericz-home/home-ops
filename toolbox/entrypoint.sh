#! /bin/sh

set -euo pipefail

case $1 in
    "rotate")
        echo "Preparing to run rotate script."
        echo "sourcing tailscale oauth credentials"
        source /vault/secrets/tailscalex

        echo "logging into vault..."
        vault write \
            auth/kubernetes/login role=$TOOLBOX_VAULT_ROLE jwt=$(cat /var/run/secrets/kubernetes.io/serviceaccount/token) >\
            /tmp/vault-token
        export VAULT_TOKEN=$(jq -r .auth.client_token /tmp/vault-token)
        cat /tmp/vault-token | grep -vw client_token

        echo "running rotate script... $(dirname $0)"
        sh $(dirname "$0")/rotate.sh
        ;;
    "restart")
        echo "Preparing to run restart script."
        echo "TODO: write this script"
        ;;
    *)
        echo "Unknown command: $1"
        exit 1
esac
