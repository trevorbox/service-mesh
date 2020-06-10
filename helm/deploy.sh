#!/bin/bash

export deploy_namespace=istio-system
export control_plane_name=basic-install
export is_production_deployment=false
export ingressgateway_name=custom-ingressgateway

oc new-project ${deploy_namespace}

echo "Deploy control plane..."

helm template control-plane -n ${deploy_namespace} \
  --set control_plane_name=${control_plane_name} \
  --set is_production_deployment=${is_production_deployment} \
  --set ingressgateway_name=${ingressgateway_name} \
  | oc apply -f -

echo "Create Jaeger Proxy..."
helm template jaeger-proxy -n ${deploy_namespace} | oc apply -f -

echo "Wait for service mesh to finish deployment..."

FAILURES=0
RETRY=10
for ((i=$RETRY; i>=1; i--)); do if [ -z "$(oc get servicemeshcontrolplane ${control_plane_name} -n ${deploy_namespace} -o jsonpath={'.status.annotations.readyComponentCount'})" ]; then echo "wait $i more times for service mesh deployment..."; (( FAILURES++ )); sleep 30s; else echo "service mesh deployed successfully!"; break; fi; done

#exit with failure if the mesh failed to deploy
if [ $FAILURES -ge $RETRY ]; then exit 1; fi

echo "Done."
exit 0