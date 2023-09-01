#! /bin/sh

set -euo pipefail

case $1 in
    "rotate")
        echo "Preparing to run rotate script."
        echo "sourcing tailscale oauth credentials"
        source /vault/secrets/tailscalex

        echo "logging into vault..."
        vault write \
            -field=auth.token_policies \
            -field=auth.policies \
            -field=auth.metadata.role\
            -field=auth.metadata.service_account_name \
            -field=auth.metadata.service_account_namespace \
            -field=auth.metadata.service_account_uid \
            auth/kubernetes/login role=$TOOLBOX_VAULT_ROLE jwt=$(cat /var/run/secrets/kubernetes.io/serviceaccount/token) 

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
