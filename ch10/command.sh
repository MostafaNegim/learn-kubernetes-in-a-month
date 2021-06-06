#!/usr/bin/env bash
# add a repository, using a local name to refer to a remote server:
helm repo add kiamol https://kiamol.net
# update the local repository cache:
helm repo update
# search for an app in the repo cache:
helm search repo vweb --versions

# inspect the default values stored in the chart:
helm show values kiamol/vweb --version 1.0.0
# install the chart, overriding the default values:
helm install --set servicePort=8010 --set replicaCount=1 ch10-vweb \
      kiamol/vweb --version 1.0.0
# check the releases you have installed:
helm ls

# show the details of the Deployment:
kubectl get deploy -l app.kubernetes.io/instance=ch10-vweb --showlabels
# update the release to increase the replica count:
helm upgrade --set servicePort=8010 --set replicaCount=3 ch10-vweb \
    kiamol/vweb --version 1.0.0
# check the ReplicaSet:
kubectl get rs -l app.kubernetes.io/instance=ch10-vweb
# get the URL for the app:
kubectl get svc ch10-vweb -o \
    jsonpath='http://{.status.loadBalancer.ingress[0].*}:8010'
# browse to the app URL


# switch to this chapter’s source:
cd ch10
# validate the chart contents:
helm lint web-ping
# install a release from the chart folder:
helm install wp1 web-ping/
# check the installed releases:
helm ls