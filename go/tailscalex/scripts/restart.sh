#! /bin/sh

set -euo pipefail

echo "Starting restart..."

# do not restart vault because it requires doing an unseal
FIELD_SELECTOR="--field-selector metadata.namespace!=vault,status.phase==Running" 
pods=$(kubectl get pods --all-namespaces $FIELD_SELECTOR --server-print=false --no-headers)
IFS=' '
echo $pods | while read -r ns name age; do
    echo "--- $ns/$name $age ---"
    case $age in
        *d) ;;
        *) continue;;
    esac

    age=${age%d}
    if [ $age -lt 7 ] || [ $age -eq 7 ]; then
        continue
    fi

    images=$(kubectl -n $ns get pod $name -o=jsonpath="{.spec.containers[*].image}" | grep -e latest -e stable -e nightly || true)
    if [ "$images" == '' ]; then
        continue
    fi

    echo "Found pod with age ${age}d older than 7d: $ns/$name"
    rs=$(kubectl -n $ns get pod $name -o=jsonpath="{.metadata.ownerReferences[?(@.kind=='ReplicaSet')].name}")
    deploy=$(kubectl -n $ns get rs $rs  -o=jsonpath="{.metadata.ownerReferences[?(@.kind=='Deployment')].name}")
    ds=$(kubectl -n $ns get pod $name  -o=jsonpath="{.metadata.ownerReferences[?(@.kind=='DaemonSet')].name}")

    kind=""
    if [ "$deploy" != '' ]; then
        echo "Found deploy $deploy"
        kind="deployment"
        name=$deploy
    elif [ "$ds" != '' ]; then
        echo "Found daemonset $ds"
        kind="daemonset"
        name=$ds
    else
        echo "WARN: No controller found for pod $ns/$name..."
        continue
    fi

    echo "restarting $kind $ns/$name..."
    kubectl -n $ns rollout restart $kind $name
    kubectl -n $ns rollout status $kind $name
    echo "$ns/$name rollout complete"

done
