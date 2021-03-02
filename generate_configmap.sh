#!/bin/bash

kubectl -n kong create configmap kong-plugin-custom-auth --from-file=kong/plugins/custom-auth \
--dry-run=client -oyaml > plugin_configmap.yaml
