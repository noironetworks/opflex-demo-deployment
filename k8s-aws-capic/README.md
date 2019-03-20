# AWS cAPIC bringup
**A one step approach to setup cAPIC in AWS**

1. Prerequisites (You will be prompted for AWS keys and region during bringup)
    1. A valid AWS account
    2. aws_access_key_id
    3. aws_secret_access_key
    4. region (E.g. us-east-2)
2. clone the repo
```
git clone https://github.com/noironetworks/opflex-demo-deployment.git
```
3. Bringup cAPIC
```
cd opflex-demo-deployment/k8s-aws-capic
./capic up
```
4. Destroy cAPIC
```
./capic destroy
```

N.B. To provide new credentials or region, delete the autogenerated .capicrc file and re-run