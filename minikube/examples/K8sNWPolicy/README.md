In this example, we will verify enforcement of kubernetes network policy by the Opflex CNI.
We create two namespaces, with a client in each namespace. We also create a service in the default namespace. Next, we add a network policy that allows access to the service only from the prod namespace. We verify the policy enforcement.

Step 1:
Create the objects

```
for file in *.yaml; do echo $file; kubectl apply -f $file; done
```

Step 2:
Verify the objects are created

```
kubectl get namespaces
NAME              STATUS   AGE
default           Active   116m
dev               Active   10m
kube-node-lease   Active   116m
kube-public       Active   116m
kube-system       Active   116m
prod              Active   10m

kubectl get svc
NAME            TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)     AGE
hostnames-svc   ClusterIP   10.106.211.186   <none>        80/TCP      11m
kubernetes      ClusterIP   10.96.0.1        <none>        443/TCP     117m
```

Step 3:

Verify policy enforcement. We use the test.sh script for the verification.

```
 ./test.sh 
Verify connectivity from prod to web

Pod client-pod ...
hostnames-svc.default (10.106.211.186:80) open

Verify connectivity from dev to web

Pod client-pod ...
nc: hostnames-svc.default (10.106.211.186:80): Operation timed out
command terminated with exit code 1
```

