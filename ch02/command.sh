# run a Pod with a single container; the restart flag tells Kubernetes
# to create just the Pod and no other resources:
kubectl run hello-kiamol --image=kiamol/ch02-hello-kiamol --restart=Never
# wait for the Pod to be ready:
kubectl wait --for=condition=Ready pod hello-kiamol
# list all the Pods in the cluster:
kubectl get pods
# show detailed information about the Pod:
kubectl describe pod hello-kiamol