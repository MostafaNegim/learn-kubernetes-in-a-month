#!/usr/bin/env bash

# switch to the chapter's source:
cd ch08
# deploy the StatefulSet, Service, and a Secret for the Postgres
# password:
kubectl apply -f todo-list/db/
# check the StatefulSet:
kubectl get statefulset todo-db
# check the Pods:
kubectl get pods -l app=todo-db
# find the hostname of Pod 0:
kubectl exec pod/todo-db-0 -- hostname
# check the logs of Pod 1:
kubectl logs todo-db-1 --tail 1

# check the internal ID of Pod 0:
kubectl get pod todo-db-0 -o jsonpath='{.metadata.uid}'
# delete the Pod:
kubectl delete pod todo-db-0
# check Pods:
kubectl get pods -l app=todo-db
# check that the new Pod is a new Pod:
kubectl get pod todo-db-0 -o jsonpath='{.metadata.uid}'

# show the Service details:
kubectl get svc todo-db
# run a sleep Pod to use for network lookups:
kubectl apply -f sleep/sleep.yaml
# run a DNS query for the Service name:
kubectl exec deploy/sleep -- sh -c 'nslookup todo-db | grep "^[^*]"'
# run a DNS lookup for Pod 0:
kubectl exec deploy/sleep -- sh -c 'nslookup todo-db-0.tododb.default.svc.cluster.local | grep "^[^*]"'

# deploy the replicated StatefulSet setup:
kubectl apply -f todo-list/db/replicated/
# wait for the Pods to spin up
kubectl wait --for=condition=Ready pod -l app=todo-db
# check the logs of Pod 0—the primary:
kubectl logs todo-db-0 --tail 1
# and of Pod 1—the secondary:
kubectl logs todo-db-1 --tail 2

# add another replica:
kubectl scale --replicas=3 statefulset/todo-db
# wait for Pod 2 to spin up
kubectl wait --for=condition=Ready pod -l app=todo-db
# check that the new Pod sets itself up as another secondary:
kubectl logs todo-db-2 --tail 2

#8.3
# deploy the StatefulSet with volume claim templates:
kubectl apply -f sleep/sleep-with-pvc.yaml
# check that the PVCs are created:
kubectl get pvc
# write some data to the PVC mount in Pod 0:
kubectl exec sleep-with-pvc-0 -- sh -c 'echo Pod 0 > /data/pod.txt'
# confirm Pod 0 can read the data:
kubectl exec sleep-with-pvc-0 -- cat /data/pod.txt
# confirm Pod 1 can’t—this will fail:
kubectl exec sleep-with-pvc-1 -- cat /data/pod.txt

# delete the Pod:
kubectl delete pod sleep-with-pvc-0
# check that the replacement gets created:
kubectl get pods -l app=sleep-with-pvc
# check that the new Pod 0 can see the old data:
kubectl exec sleep-with-pvc-0 -- cat /data/pod.txt

# apply the update with volume claim templates—this will fail:
kubectl apply -f todo-list/db/replicated/update/todo-db-pvc.yaml
# delete the existing set:
kubectl delete statefulset todo-db
# create a new one with volume claims:
kubectl apply -f todo-list/db/replicated/update/todo-db-pvc.yaml
# check the volume claims:
kubectl get pvc -l app=todo-db

#8.4
# deploy the Job:
kubectl apply -f pi/pi-job.yaml
# check the logs for the Pod:
kubectl logs -l job-name=pi-job
# check the status of the Job:
kubectl get job pi-job

# deploy the new Job:
kubectl apply -f pi/pi-job-random.yaml
# check the Pod status:
kubectl get pods -l job-name=pi-job-random
# check the Job status:
kubectl get job pi-job-random
# list the Pod output:
kubectl logs -l job-name=pi-job-random