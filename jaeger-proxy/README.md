# Instructions for using trusted CA bundle in Istio Jaeger Oauth Proxy

Since the Jaeger Operator cannot be properly configured to trust custom CA certs we need to:

- disable the current oauth proxy sidecar and route controlled by the operator
- create a new jaeger-proxy app with the trusted CA that will forward upstream to jaeger

```sh
ansible-playbook playbook-jaeger-proxy.yml
```
