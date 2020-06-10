# Helm chart

```sh

export deploy_namespace=istio-system
export control_plane_name=basic-install
export is_production_deployment=false
export ingressgateway_name=custom-ingressgateway

oc new-project ${deploy_namespace}

helm template control-plane -n ${deploy_namespace} \
  --set control_plane_name=${control_plane_name} \
  --set is_production_deployment=${is_production_deployment} \
  --set ingressgateway_name=${ingressgateway_name} \
  | oc apply -f -

FAILURES=0
RETRY=10
for ((i=$RETRY; i>=1; i--)); do if [ -z "$(oc get servicemeshcontrolplane ${control_plane_name} -n ${deploy_namespace} -o jsonpath={'.status.annotations.readyComponentCount'})" ]; then echo "wait $i more times for service mesh deployment..."; (( FAILURES++ )); sleep 30s; else echo "service mesh deployed successfully!"; break; fi; done

if [ $FAILURES -ge $RETRY ]; then exit 1; fi

sleep 10m;

oc patch jaeger jaeger --type='merge' -p '{"spec":{"ingress":{"enabled": false, "security": "none"}}}' -n ${deploy_namespace}

helm template jaeger-proxy -n ${deploy_namespace} | oc apply -f -

if [ -z "$(oc get configmap kiali -n ${deploy_namespace} -o name)" ]; then exit1; fi

#change the jaeger urls for kiali to connect to jaeger traces and restart kiali
oc extract configmap/kiali -n ${deploy_namespace} --to=- | sed 's/.*in_cluster_url:.*jaeger.*/    in_cluster_url: http:\/\/jaeger-query.'"${deploy_namespace}"'.svc:16686/g;s/.* url:.*jaeger.*/    url: '"$(oc get route jaeger-proxy -o jsonpath={'.spec.host'})"'/mg' > /tmp/configmap-kiali.yaml

oc delete configmap/kiali -n ${deploy_namespace}

oc create configmap kiali --from-file=config.yaml=/tmp/configmap-kiali.yaml -n ${deploy_namespace}

oc rollout restart deployment kiali -n ${deploy_namespace}

```
