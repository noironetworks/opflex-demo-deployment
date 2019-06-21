epg-a.yaml and epg-b.yaml are examples of Endpoint Group objects. Pods within an endpoint group are allowed to talk to each other. Across Endpoint groups, contracts are needed to enable connectivity. tcp-6020.yaml is an example of a contract that allows communication on tcp port 6020.

In this example, we will create two epgs, with a contract between them. We will create one pod (pod-a) assigned to epg-a and two pods pod-b6020 and pod-b6021 assigned to epg-b. We then verify connectivity between pod-a and pod-b6020 on port 6020. Next we verify that pod-a cannot to talk to pod-b6021 because there is no contract for port 6021. Finally, we verify that pod-b6020 can talk to pod-b6021 without a contract because they belong to the same EPG. Although we directly assigned pods to EPG's in this example, we could assign a whole deployment or even a namespace to an EPG. This makes isolation of applications very natural and easy.

Step 1:

Create all objects. 
```
for file in *.yaml; do kubectl apply -f $file; done
```

Step 2:

Verify pods are created.

```
kubectl get pods -o wide
```

You should see something like
```
NAME        READY   STATUS    RESTARTS   AGE     IP           NODE       NOMINATED NODE   READINESS GATES
pod-a       1/1     Running   0          2m15s   10.2.56.10   minikube   <none>           <none>
pod-b6020   1/1     Running   0          2m15s   10.2.56.11   minikube   <none>           <none>
pod-b6021   1/1     Running   0          2m15s   10.2.56.12   minikube   <none>           <none>
```

Step 3:

Verify policy

```
kubectl exec -it pod-a -- nc -zvnw 1 10.2.56.11 6020
10.2.56.11 (10.2.56.11:6020) open

kubectl exec -it pod-a -- nc -zvnw 1 10.2.56.12 6021
nc: 10.2.56.12 (10.2.56.12:6021): Operation timed out
command terminated with exit code 1

kubectl exec -it pod-b6020 -- nc -zvnw 1 10.2.56.12 6021
10.2.56.12 (10.2.56.12:6021) open
```

Note that your IP addresses might be different than what's shown here.




