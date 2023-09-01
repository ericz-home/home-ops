#! /bin/sh

set -euo pipefail

case $1 in
    "rotate")
        echo "Preparing to run rotate script."
        echo "sourcing tailscale oauth credentials"
        source /vault/secrets/tailscalex

        echo "logging into vault..."
        vault write auth/kubernetes/login \
            -field=token_policies \
            -field=policies \
            -field=token_meta_role \
            -field=token_meta_service_account_name \
            -field=token_meta_service_account_namespace \
            -field=token_meta_service_account_uid \
            role=$TOOLBOX_VAULT_ROLE jwt=$(cat /var/run/secrets/kubernetes.io/serviceaccount/token) 

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
