# Docker EE installation on AWS with Terraform

## Pre-requisite

Install following softwares on your workstation:

        - terraform  (version - v0.11.13)
        - jq
        - git
        - pip
        - awscli

Make sure AWS user has IAM EC2FullAccess permission.

Follow the instructions in below link to setup AWS cli on your workstation,
which Terraform will use for authentication:

http://docs.aws.amazon.com/cli/latest/userguide/cli-chap-getting-started.html

## Instruction to run

### Clone the repo

        git clone https://github.com/noironetworks/opflex-demo-deployment.git
        git checkout -b docker_ee_install origin/docker_ee_install
        cd opflex-demo-deployment

### Make sure you specify correct values in *terraform.tfvars*

        aws_region = <aws region name>
        aws_availability_zone = <aws availability zone>
        aws_instance_key_name = <key name>
        aws_key_location = <absolute location of key on your workstation>
        aws_ami = <ami id of Ubuntu 18.04 LTS>
        cni_url = <web addrees of deployment file>
        docker_ee_url = <docker ee url. Check your docker subscription detail>
        docker_ee_version = <docker ee version to get installed.>

### Run terraform

        terraform init
        terraform apply

### Post Installation

After installation, log into AWS EC2 console and find *Public IP* of
**Docker-Master**. Go to your browser.

        https://<Docker-Master Public IP>

        username - admin
        password - admin123
