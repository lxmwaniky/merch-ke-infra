resource "google_compute_network" "vpc" {
  name                    = var.vpc_name
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "subnet_compute" {
  name                     = "${var.vpc_name}-compute-subnet"
  ip_cidr_range            = var.subnet_compute_cidr
  region                   = var.region
  network                  = google_compute_network.vpc.id
  private_ip_google_access = true
}

resource "google_vpc_access_connector" "connector" {
  name          = "run-vpc-connector"
  region        = var.region
  network       = google_compute_network.vpc.name
  ip_cidr_range = var.vpc_connector_cidr
  min_instances = 2
  max_instances = 3
}
