locals {
  testvm-docker-install = <<DOCKERINST
set -o xtrace; curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -; sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"; sudo apt-get update; apt-cache policy docker-ce; sudo apt-get install -y docker-ce; sudo usermod -aG docker ${var.env_user}
DOCKERINST


  docker_options = <<CMD
--rm -e "GKE_CLUSTER=${var.name_prefix}-cluster-${random_string.suffix.result}" -e "GKE_ZONE=${var.gke_location}" -e "GKE_PROJECT=${var.gcp_project}" -e "GKE_SERVICE_ACC=${var.gke_service_account_email}" --net=host -v $PWD:/opflex-cni-test -w /opflex-cni-test/test dshailen/gobuild:v1 /bin/bash -c "gcloud auth activate-service-account ${var.gke_service_account_email} --key-file=/opflex-cni-test/data/serviceaccount.json; gcloud container clusters get-credentials ${var.name_prefix}-cluster-${random_string.suffix.result} --zone ${var.gke_location} --project ${var.gcp_project}; gcloud info; apt-get install -y kubectl; kubectl get all; pytest -v -s -x"


CMD

  testvm-gcloud-install = <<GCLOUDINST
echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] http://packages.cloud.google.com/apt cloud-sdk main" | sudo tee -a /etc/apt/sources.list.d/google-cloud-sdk.list;
curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key --keyring /usr/share/keyrings/cloud.google.gpg add -
sudo apt-get update && sudo apt-get install google-cloud-sdk && sudo apt-get install -y kubectl
GCLOUDINST

}

resource "google_compute_instance" "test" {
  name = "${var.name_prefix}-testvm-${random_string.suffix.result}"
  machine_type = "n1-standard-1"
  zone = "${var.gke_location}"

  boot_disk {
    initialize_params {
      image = "${var.gke_testvm_image_type}"
    }
  }

  metadata_startup_script = "${local.testvm-docker-install}; ${local.testvm-gcloud-install}"

  network_interface {
    network = "${var.gke_network}"
    access_config {
    }
  }

  metadata = {
    sshKeys = "${var.env_user}:${file("./${var.name_prefix}-key-${random_string.suffix.result}.pem.pub")}"
  }

  depends_on = [
    "null_resource.rename_sshkey_files",
  ]
}

/*
# already done at the cluster level
resource "google_compute_firewall" "test_fw" {
  name    = "nginx-firewall"
  network = "${var.gke_network}"

  allow {
    protocol = "tcp"
    ports    = ["80","443"]
  }

  allow {
    protocol = "icmp"
  }
}
*/

resource "null_resource" "test" {
  # Changes to public IP of the test VM requires re-provisioning
  triggers = {
    public_ip = "${google_compute_instance.test.network_interface.0.access_config.0.nat_ip}"
  }

  # Bootstrap script can run on any instance of the cluster
  # So we just choose the first in this case
  connection {
    host        = "${google_compute_instance.test.network_interface.0.access_config.0.nat_ip}"
    type        = "ssh"
    user        = "${var.env_user}"
    port        = "22"
    agent       = false
    #private_key = "${file("local.pem.pub")}"
    private_key = "${file("./${var.name_prefix}-key-${random_string.suffix.result}.pem")}"
  }

  provisioner "remote-exec" {
    # Bootstrap script called with private_ip of each node in the clutser
    inline = [
      "sudo rm -rf /home/${var.env_user}/opflex-cni-test",
      "git clone https://github.com/noironetworks/opflex-cni-test.git -b gke",
      ]
  }

  provisioner "file" {
      source      = "${var.gke_service_account_file}"
      destination = "/home/${var.env_user}/opflex-cni-test/data/${var.gke_service_account_file}"
  }

  provisioner "remote-exec" {
    inline = [
      "sleep 20",
      "/snap/bin/gcloud auth activate-service-account $(grep client_email /home/${var.env_user}/opflex-cni-test/data/${var.gke_service_account_file} | awk '{print $2}' | sed 's/\"//g' | sed 's/,//g') --key-file=/home/${var.env_user}/opflex-cni-test/data/${var.gke_service_account_file}",
    ]
  }

  # create kubeconfig file
  provisioner "remote-exec" {
     inline = [
       "/snap/bin/gcloud container clusters get-credentials ${google_container_cluster.gke-cluster.name} --zone ${google_container_cluster.gke-cluster.location} --project ${google_project_service.kubernetes.project}",
     ]
  }

  #"/usr/bin/docker run ${local.docker_options}",
  #"sudo docker run ${local.docker_options}",
  provisioner "remote-exec" {
    inline = [
      "sudo usermod -a -G docker ${var.env_user}",
      "sleep 20",
      "cd opflex-cni-test",
      "docker run ${local.docker_options}",
    ]
    on_failure = "continue"
  }

  #TODO: delete some leftover pods from test
  provisioner "local-exec" {
    command = "export PATH=$PWD/bin:$PATH && for i in $(kubectl get all -o yaml | grep 'name: busybox-' | awk '{print $2}'); do kubectl delete pod $i; done"
  }

  depends_on = [
    "google_container_cluster.gke-cluster",
    "google_compute_instance.test",
    "null_resource.rename_sshkey_files",
    "null_resource.node_init_and_apply",
  ]
}

output "ip" {
  value = "ssh -i ${var.name_prefix}-key-${random_string.suffix.result}.pem ${var.env_user}@${google_compute_instance.test.network_interface.0.access_config.0.nat_ip}"
}
