# Azure AKS Cluster with ACI CNI
**A one step approach to setup Azure AKS cluster with ACI CNI**

1. Prerequisites
    1. Make sure you have a valid Azure account
    2. ARM Client ID 
    3. ARM Client Secret
    3. ARM Subscription ID
    4. ARM Tenant ID
2. clone the repo
```
git clone https://github.com/noironetworks/opflex-demo-deployment.git
```
3. Bringup the cluster
```
cd opflex-demo-deployment/k8s-azure-aks
./aks up
```
4. Destroy the cluster
```
./aks destroy
```

N.B. To provide new credentials, delete the autogenerated .aksrc file and re-run
