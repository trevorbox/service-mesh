# Install Service Mesh Operators and create the Control Plane


> mTLS enabled


## Install Service Mesh Operators
1. Ensure you are logged in
```
oc login <mycluster>
```
2. Run the playbook
```
ansible-playbook 01_playbook-install-service-mesh.yml
```

## Install Control Plane
Choose whether to install the default control plane or oauth2 gateway control plane.
- Default Control Plane:
   1. Ensure you are logged in
      ```
      oc login <mycluster>
      ```
   2. Update `control_plane_namespace` within *02_playbook-install-control-plane.yml* with desired project name to deploy too
   3. Run the playbook
      ```
      ansible-playbook 02_playbook-install-control-plane.yml
      ```
- Okta Oauth2 Proxy Gateway Control Plane:
   1. Ensure you are logged in
      ```
      oc login <mycluster>
      ```
   2. Update `control_plane_namespace` within *02_playbook-install-control-plane-oauth2-gateway.yml* with desired project name to deploy too
   3. Follow the steps described within [Configuring the OIDC Provider with Okta](https://github.com/trevorbox/oauth2-proxy/blob/update-okta-doc/docs/2_auth.md#configuring-the-oidc-provider-with-okta) to create an Okta application & authorization server. Retrieve its `client_id` and `client_secret`.
   3. Run the playbook while passing the `client_id` and `client_secret` vars
      ```
      ansible-playbook 02_playbook-install-control-plane-oauth2-gateway.yml -e client_id=${my-client-id} -e client_secret=${my-client-secret}
      ```
