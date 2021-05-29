#!/usr/bin/env bash
# change to the exercise directory:
cd ch09
# deploy a simple web app:
kubectl apply -f vweb/
# check the ReplicaSets:
kubectl get rs -l app=vweb
# now increase the scale:
kubectl apply -f vweb/update/vweb-v1-scale.yaml
# check the ReplicaSets:
kubectl get rs -l app=vweb
# check the deployment history:
kubectl rollout history deploy/vweb

# update the image for the web app:
kubectl set image deployment/vweb web=kiamol/ch09-vweb:v2
# check the ReplicaSets again:
kubectl get rs -l app=vweb
# check the rollouts:
kubectl rollout history deploy/vweb