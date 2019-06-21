resource "google_project_service" "kubernetes" {
  project = "${var.gcp_project}"
  service = "container.googleapis.com"
}

resource "google_container_cluster" "gke-cluster" {
  name               = "${var.name_prefix}-cluster-${random_string.suffix.result}"
  network            = "${var.gke_network}"
  location           = "${var.gke_location}"
  remove_default_node_pool = true
  initial_node_count = 1

  addons_config {
    http_load_balancing {
      disabled = "${var.http_load_balancing ? false : true}"
    }

    horizontal_pod_autoscaling {
      disabled = "${var.horizontal_pod_autoscaling ? false : true}"
    }

    kubernetes_dashboard {
      disabled = "${var.kubernetes_dashboard ? false : true}"
    }

    network_policy_config {
      disabled = "${var.network_policy ? false : true}"
    }
  }

  depends_on = [
    "google_project_service.kubernetes",
  ]
}

resource "google_container_node_pool" "primary_preemptible_nodes" {
  name       = "my-node-pool"
  location   = "${var.gke_location}"
  cluster    = "${google_container_cluster.gke-cluster.name}"
  node_count = 3

  node_config {
    preemptible  = true
    machine_type = "${var.instance_type}"
    image_type   = "${var.gke_image_type}"

    metadata = {
      disable-legacy-endpoints = "true"
    }

    oauth_scopes = [
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
    ]
  }
}

# create kubeconfig file
resource "null_resource" "create_kubeconfig" {
  # move exiting kubeconfig to .
/*
  provisioner "local-exec" {
     command = "mv $HOME/.kube/config ./kubeconfig_orig"
     on_failure = "continue"
  }
*/
  # create kubeconfig file
  provisioner "local-exec" {
     command = "gcloud container clusters get-credentials ${google_container_cluster.gke-cluster.name} --zone ${google_container_cluster.gke-cluster.location} --project ${google_project_service.kubernetes.project}"
  }

/*
  # move the generated kubeconfig to .
  provisioner "local-exec" {
     command = "mv $HOME/.kube/config ./kubeconfig"
  }

  # move back the original kubeconfig to $HOME/.kube
  provisioner "local-exec" {
     command = "mv ./kubeconfig_orig $HOME/.kube/config"
     on_failure = "continue"
  }
*/
  depends_on = [
    "google_container_cluster.gke-cluster",
  ]
}

locals {

  kubectl = <<KUBECTL

source .gkerc
kubectl get pods --all-namespaces

KUBECTL
}

output "kubectl" {
  value = "${local.kubectl}"
}
