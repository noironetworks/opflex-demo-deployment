**Using Opflex CNI Plugin with minikube**

To use opflex CNI with minikube, first install minikube as described here: https://kubernetes.io/docs/tasks/tools/install-minikube/
After it has been installed, invoke *./start.sh* to start the minikube cluster with Opflex CNI networking.

Using minikube, you can get a feel for the policy models supported by opflex CNI.

1) K8s Network Policy

Opflex CNI supports the standard k8s network policy object for policy enforcement. You can try the yamls under examples/K8sNWPolicy to check this out.

2) Group Based Policy

Group Based Policy is another great way to enforce policy with the kubernetes cluster. Examples are given under examples/GroupBasedPolicy
