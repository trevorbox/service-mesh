# Service Mesh Installation

## Install the service mesh operators

```sh
helm install service-mesh-operators -n openshift-operators service-mesh-operators/
```

Manually approve the InstallPlans within the *openshift-operators* namespace.

1. Navigate the the InstallPlans search page
  
   ```sh
   echo "https://$(oc get route console -o jsonpath={.spec.host} -n openshift-console)/k8s/ns/openshift-operators/operators.coreos.com~v1alpha1~InstallPlan"
   ```

2. Select each InstallPlan on the search page. Within each InstallPlan's Overview tab select the **Preview Install Plan** button, then select the **Approve** button on the Components tab.

## Uninstall the service mesh operators

1. Delete the helm chart release:

   ```sh
   helm delete service-mesh-operators -n openshift-operators
   ```

2. Follow the instructions from <https://docs.openshift.com/container-platform/4.3/service_mesh/service_mesh_install/removing-ossm.html>

## Install the control plane

```sh
export deploy_namespace=istio-system

oc new-project ${deploy_namespace}

#Note: you may need to wait a moment for the operators to propagate

helm install control-plane -n ${deploy_namespace} control-plane/
```

## Uninstall the control plane

```sh
export deploy_namespace=istio-system
helm delete control-plane -n ${deploy_namespace}
```

## Install the oauth2 control plane

Follow the steps described within [Configuring the OIDC Provider with Okta](https://github.com/trevorbox/oauth2-proxy/blob/update-okta-doc/docs/2_auth.md#configuring-the-oidc-provider-with-okta) to create an Okta application & authorization server. Retrieve its `client_id` and `client_secret`.

Note that the Okta Application needs the login redirect URI to match the ${redirect_url} defined below.

```sh
export deploy_namespace=istio-system
export client_id=<my_client_id>
export client_secret=<my_client_secret>
export redirect_url="https://api-istio-system.$(oc get route console -o jsonpath={.status.ingress[0].routerCanonicalHostname} -n openshift-console)/oauth2/callback"

oc new-project ${deploy_namespace}

#Note: you may need to wait a moment for the operators to propagate

helm install control-plane-oauth2 -n ${deploy_namespace} --set client_id=${client_id} --set client_secret=${client_secret} --set redirect_url=${redirect_url} control-plane-oauth2/
```

## Uninstall the oauth2 control plane

```sh
export deploy_namespace=istio-system
helm delete control-plane-oauth2 -n ${deploy_namespace}
```

## Optional

### Install the jaeger proxy (for bundled ca trust)

```sh
export deploy_namespace=istio-system
helm install jaeger-proxy -n ${deploy_namespace} jaeger-proxy/
```

### Uninstall the jaeger proxy

```sh
export deploy_namespace=istio-system
helm delete jaeger-proxy -n ${deploy_namespace}
```
