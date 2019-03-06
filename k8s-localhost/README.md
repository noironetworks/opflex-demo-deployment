# vagrant-aci-containers
**A vagrant environment for opflex based kubernetes install**

1. If you have not used vagrant before, please set it up first. On an ubuntu VM, you can set one up as follows
```
sudo apt-get update
sudo apt-get install git virtualbox vagrant
sudo usermod -aG vboxusers `whoami`
```
2. If you are running this code in a Cisco lab environment use, set the following environment variable (to set proxies)
```
export PROVISION_CISCO=true
```
3. Now clone the repo and run vagrant as
```
git clone https://github.com/noironetworks/vagrant-aci-containers.git
cd vagrant-aci-containers/ubuntu-bionic
vagrant up
```

4. Log in to master node and run guestbook app
   1. vagrant ssh vk8s-master
   2. Run  app.
      ```
      kubectl apply -f data/guestbook.yaml
      ```
   3. Check status of guestbook pods and once up enable nodeport on node1.
      ```
      data/enable_node_port.sh
      ```

5. Get nodeport from the command above access guestbook at http://1.100.201.12:PORT
