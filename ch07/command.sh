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