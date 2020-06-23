#!/bin/bash

export deploy_namespace=istio-system

oc new-project ${deploy_namespace}

echo "Install control plane..."

helm install control-plane -n ${deploy_namespace} control-plane/

echo "Wait for control plane to finish deployment..."

FAILURES=0
RETRY=10
for ((i=$RETRY; i>=1; i--)); do if [ -z "$(oc get servicemeshcontrolplane ${control_plane_name} -n ${deploy_namespace} -o jsonpath={'.status.annotations.readyComponentCount'})" ]; then echo "wait $i more times for service mesh deployment..."; (( FAILURES++ )); sleep 30s; else echo "service mesh deployed successfully!"; break; fi; done

#exit with failure if the mesh failed to deploy
if [ $FAILURES -ge $RETRY ]; then echo "Failed to deploy in 5 minutes."; exit 1; fi

echo "Done."
exit 0