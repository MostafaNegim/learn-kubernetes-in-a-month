#!/usr/bin/env bash
# add a repository, using a local name to refer to a remote server:
helm repo add kiamol https://kiamol.net
# update the local repository cache:
helm repo update
# search for an app in the repo cache:
helm search repo vweb --versions