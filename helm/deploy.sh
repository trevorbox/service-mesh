#!/bin/bash

export deploy_namespace=myistio
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

echo "Wait for service mesh to finish deployment..."

FAILURES=0
RETRY=10
for ((i=$RETRY; i>=1; i--)); do if [ -z "$(oc get servicemeshcontrolplane ${control_plane_name} -n ${deploy_namespace} -o jsonpath={'.status.annotations.readyComponentCount'})" ]; then echo "wait $i more times for service mesh deployment..."; (( FAILURES++ )); sleep 30s; else echo "service mesh deployed successfully!"; break; fi; done

#exit with failure if the mesh failed to deploy
if [ $FAILURES -ge $RETRY ]; then exit 1; fi


echo "sleep ten minutes for kiali to finish deploying..."
sleep 10m

echo "Patch Jaeger..."
oc patch jaeger jaeger --type='merge' -p '{"spec":{"ingress":{"enabled": false, "security": "none"}}}' -n ${deploy_namespace}

echo "Create Jaeger Proxy..."
helm template jaeger-proxy -n ${deploy_namespace} | oc apply -f -

if [ -z "$(oc get configmap kiali -n ${deploy_namespace} -o name)" ]; then echo "kiali configmap not found!"; exit 1; fi

echo "Recreate Kiali config.yaml using Jaeger Proxy URLs..."
#change the jaeger urls for kiali to connect to jaeger traces and restart kiali
oc extract configmap/kiali -n ${deploy_namespace} --to=- | sed 's/.*in_cluster_url:.*jaeger.*/    in_cluster_url: http:\/\/jaeger-query.'"${deploy_namespace}"'.svc:16686/g;s/.* url:.*jaeger.*/    url: '"$(oc get route jaeger-proxy -o jsonpath={'.spec.host'})"'/mg' > /tmp/configmap-kiali.yaml

echo "Delete old kiali configmap..."
oc delete configmap/kiali -n ${deploy_namespace}

echo "Create new kiali configmap..."
oc create configmap kiali --from-file=config.yaml=/tmp/configmap-kiali.yaml -n ${deploy_namespace}

echo "Restart kiali..."
oc rollout restart deployment kiali -n ${deploy_namespace}

echo "Done."
exit 0