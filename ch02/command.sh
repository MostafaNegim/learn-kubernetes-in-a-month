# run a Pod with a single container; the restart flag tells Kubernetes
# to create just the Pod and no other resources:
kubectl run hello-kiamol --image=kiamol/ch02-hello-kiamol --restart=Never
# wait for the Pod to be ready:
kubectl wait --for=condition=Ready pod hello-kiamol
# list all the Pods in the cluster:
kubectl get pods
# show detailed information about the Pod:
kubectl describe pod hello-kiamol


# find the Pod’s container:
docker container ls -q --filter label=io.kubernetes.container.name=hello-kiamol
# now delete that container:
docker container rm -f "$(docker container ls -q --filter label=io.kubernetes.container.name=hello-kiamol)"
# check the Pod status:
kubectl get pod hello-kiamol
# and find the container again:
docker container ls -q --filter label=io.kubernetes.container.name=hello-kiamol

# listen on port 8080 on your machine and send traffic
# to the Pod on port 80:
kubectl port-forward pod/hello-kiamol 8080:80
# now browse to http://localhost:8080
# when you’re done press ctrl-c to end the port forward

# create a Deployment called "hello-kiamol-2", running the same web app:
kubectl create deployment hello-kiamol-2 --image=kiamol/ch02-hello-kiamol
# list all the Pods:
kubectl get pods