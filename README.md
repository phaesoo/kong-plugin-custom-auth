# kong-plugin-custom-auth

# Generate configmap
```
make configmap
```

# Testing

## Pre-requisites
Install kong-pongo: https://github.com/Kong/kong-pongo#installation

## Run unit test
```bash
make test
```

# Deployment
kubectl -n kong apply -f plugin_configmap.yaml