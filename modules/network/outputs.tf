output "vpc_id" {
  value       = google_compute_network.vpc.id
  description = "The ID of the VPC"
}

output "vpc_name" {
  value       = google_compute_network.vpc.name
  description = "The name of the VPC"
}

output "connector_id" {
  value       = google_vpc_access_connector.connector.id
  description = "The ID of the VPC Access Connector for Cloud Run"
}

output "subnet_id" {
  value       = google_compute_subnetwork.subnet_compute.id
  description = "The ID of the compute subnet"
}