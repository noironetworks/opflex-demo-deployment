# Configure the Google Provider

provider "google" {
  credentials = "${file("${var.gke_service_account_file}")}"
  project     = "terraform-p1"
  region      = "us-west1"
}
