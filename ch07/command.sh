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