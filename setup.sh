#!/usr/bin/env bash

kind create cluster --name=argo-flux
kubectx kind-argo-flux

## install flux2
helm repo add fluxcd-community https://fluxcd-community.github.io/helm-charts || true
helm install flux --namespace flux-system --create-namespace fluxcd-community/flux2 --version 0.14.0 --wait

cat <<EOF | kubectl apply -f -
---
apiVersion: source.toolkit.fluxcd.io/v1beta1
kind: GitRepository
metadata:
  name: argo-flux-demo
  namespace: flux-system
spec:
  interval: 30s
  url: https://github.com/haarchri/argo-flux
  ref:
    branch: main
---
apiVersion: kustomize.toolkit.fluxcd.io/v1beta2
kind: Kustomization
metadata:
  name: argo-flux-demo
  namespace: flux-system
spec:
  prune: true
  interval: 2m
  path: "./setup"
  sourceRef:
    kind: GitRepository
    name: argo-flux-demo
  timeout: 3m
EOF