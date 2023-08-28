#! /bin/sh -e

case $1 in
    "rotate")
        echo "Preparing to run rotate script."
        echo "logging into vault..."
        vault write auth/kubernetes/login -role=$TOOLBOX_VAULT_ROLE jwt=$(cat /var/run/secrets/kubernetes.io/serviceaccount/token) 

        ./rotate.sh
        ;;
    "restart")
        echo "Preparing to run restart script."
        echo "TODO: write this script"
    *)
        echo "Unknown command: $1"
        exit 1
esac
