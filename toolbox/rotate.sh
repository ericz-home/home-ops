#! /bin/sh -e

TSX=${TSX-tailscalex}

EXPIRE_WITHIN="120h"

KEYS=$($TSX keys list --expires-within $EXPIRE_WITHIN)

if [ "$KEYS" == "" ]; then
    echo "No keys set to expire within $EXPIRE_WITHIN"
    exit 0
fi

VAULT_ANNOTATION="spec.template.metadata.annotations.vault\.hashicorp\.com/agent-inject-secret-tailscale"
JSON_FILTER="?(@.${VAULT_ANNOTATION})"
JSONPATH="{range .items[$JSON_FILTER]}{.metadata.namespace}{' '}{.metadata.name}{' '}{.$VAULT_ANNOTATION}{'\n'}{end}"

KINDS="deployment daemonset"
for kind in $KINDS;  do
    VALUES=$(kubectl get $kind --all-namespaces -o=jsonpath="$JSONPATH")
    echo "$VALUES" | while read -r ns name vault_path; do 
        echo "--- $kind $ns/$name ---"

        echo "looking up vault key id for $vault_path"
        key_id=$(vault kv get -field="id" $vault_path)

        desc=$(echo "$KEYS" | grep $key_id | cut -d '|' -f 2) 
        if [ "$desc" == "" ]; then
            echo "key does not need to be rotated yet"
            continue
        fi

        echo "rotating key $key_id ($desc)"

        if [ "$DRY_RUN" == "" ]; then
            $TSX keys create $desc > $desc.key
            new_id=$(jq -r .id $desc.key)
            new_key=$(jq -r .key $desc.key)
            echo "generated new key $new_id"

            echo "uploading to vault $vault_path"
            vault kv put $vault_path id=$new_id authkey=$new_key

            echo "restarting deployment"
            kubectl -n $ns rollout restart $kind $name
            kubectl -n $ns rollout status $kind $name
            echo "$ns/$name rollout complete"

            echo "revoking old key $key_id"
            $TSX keys delete $key_id

            rm -f $desc.key
        fi
    done
done
