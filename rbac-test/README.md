# Service Mesh non-cluster-admin access
The purpose of this test is to document what roles are required for a non-cluster-admin user to view their namespace's mesh in the cluster's Service Mesh Control Plane.

In this example, the user **tbox** is a developer in the namespace **bookinfo** and can view the Service Mesh Control Plane's Kiali, Prometheus, Grafana, and Jaeger in **istio-system**.

- **tbox** has the role **maistra-admin** and **view** in the namespace **istio-system**
- **tbox** has the role **maistra-admin** and **edit** in the namespace **bookinfo**


This example assumes a test user called **tbox**, feel free to edit the rolebindings for your own test user.
> Cluster role created from [maistra-admin role](https://issues.redhat.com/browse/OSSM-173).
