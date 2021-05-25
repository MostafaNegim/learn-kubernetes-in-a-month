#!/usr/bin/env bash
# get in a container
k exec -it pod-name -c container_name -- sh
# get all containers in a pod
#k get pods POD_NAME_HERE -o jsonpath='{.spec.containers[*].name}'

# write a file to the shared volume using one container:
k exec deploy/sleep -c sleep -- sh -c 'echo ${HOSTNAME} > /data-rw/hostname.txt'

# read the file using the same container:
kubectl exec deploy/sleep -c sleep -- cat /data-rw/hostname.txt
# read the file using the other container:
kubectl exec deploy/sleep -c file-reader -- cat /data-ro/hostname.txt
# try to add to the file to the read-only container—this will fail:
kubectl exec deploy/sleep -c file-reader -- sh -c 'echo more >> /data-ro/hostname.txt'

# Network
# deploy the update:
kubectl apply -f sleep/sleep-with-server.yaml
# check the Pod status:
kubectl get pods -l app=sleep
# list the container names in the new Pod:
kubectl get pod -l app=sleep -o jsonpath='{.items[0].status.containerStatuses[*].name}'
# make a network call between the containers:
kubectl exec deploy/sleep -c sleep -- wget -q -O - localhost:8080
# check the server container logs:
kubectl logs -l app=sleep -c server

#
# apply the updated spec with the init container:
kubectl apply -f sleep/sleep-with-html-server.yaml
# check the Pod containers:
kubectl get pod -l app=sleep -o jsonpath='{.items[0].status.containerStatuses[*].name}'
# check the init containers:
kubectl get pod -l app=sleep -o jsonpath='{.items[0].status.initContainerStatuses[*].name}'
# check logs from the init container—there are none:
kubectl logs -l app=sleep -c init-html
# check that the file is available in the sidecar:
kubectl exec deploy/sleep -c server -- ls -l /data-ro

#

# run the app, which uses a single config file:
kubectl apply -f timecheck/timecheck.yaml
# check the container logs—there won’t be any:
kubectl logs -l app=timecheck
# check the log file inside the container:
kubectl exec deploy/timecheck -- cat /logs/timecheck.log
# check the config setup:
kubectl exec deploy/timecheck -- cat /config/appsettings.json

#
# apply the ConfigMap and the new Deployment spec:
kubectl apply -f timecheck/timecheck-configMap.yaml -f timecheck/timecheck-with-config.yaml
# wait for the containers to start:
kubectl wait --for=condition=ContainersReady pod -l app=timecheck,version=v2
# check the log file in the new app container:
kubectl exec deploy/timecheck -- cat /logs/timecheck.log
# see the config file built by the init container:
kubectl exec deploy/timecheck -- cat /config/appsettings.json

# add the sidecar logging container:
kubectl apply -f timecheck/timecheck-with-logging.yaml
# wait for the containers to start:
kubectl wait --for=condition=ContainersReady pod -l app=timecheck,version=v3
# check the Pods:
kubectl get pods -l app=timecheck
# check the containers in the Pod:
kubectl get pod -l app=timecheck -o jsonpath='{.items[0].status.containerStatuses[*].name}'
# now you can see the app logs in the Pod:
kubectl logs -l app=timecheck -c logger

# apply the update:
kubectl apply -f timecheck/timecheck-good-citizen.yaml
# wait for all the containers to be ready:
kubectl wait --for=condition=ContainersReady pod -l app=timecheck,version=v4
# check the running containers:
kubectl get pod -l app=timecheck -o jsonpath='{.items[0].status.containerStatuses[*].name}'
# use the sleep container to check the timecheck app health:
kubectl exec deploy/sleep -c sleep -- wget -q -O - http://timecheck:8080
# check its metrics:
kubectl exec deploy/sleep -c sleep -- wget -q -O - http://timecheck:8081