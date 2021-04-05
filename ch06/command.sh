#!/bin/bash

# deploy the Pi app:
kubectl apply -f pi/web/
# check the ReplicaSet:
kubectl get rs -l app=pi-web
# scale up to more replicas:
kubectl apply -f pi/web/update/web-replicas-3.yaml
# check the RS:
kubectl get rs -l app=pi-web
# deploy a changed Pod spec with enhanced logging:
kubectl apply -f pi/web/update/web-logging-level.yaml
# check ReplicaSets again:
kubectl get rs -l app=pi-web