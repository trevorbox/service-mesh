#!/bin/bash

#Uninstall the Service Mesh after removing the control planes and uninstalling the operators from the UI
#See https://docs.openshift.com/container-platform/4.3/service_mesh/service_mesh_install/removing-ossm.html

OPERATOR_NAMESPACE=openshift-operators

oc delete validatingwebhookconfiguration/$OPERATOR_NAMESPACE.servicemesh-resources.maistra.io
oc delete mutatingwebhoookconfigurations/$OPERATOR_NAMESPACE.servicemesh-resources.maistra.io
oc delete -n $OPERATOR_NAMESPACE daemonset/istio-node
oc delete clusterrole/istio-admin clusterrole/istio-cni clusterrolebinding/istio-cni
oc get crds -o name | grep '.*\.istio\.io' | xargs -r -n 1 oc delete
oc get crds -o name | grep '.*\.maistra\.io' | xargs -r -n 1 oc delete
