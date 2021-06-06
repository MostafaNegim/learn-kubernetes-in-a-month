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