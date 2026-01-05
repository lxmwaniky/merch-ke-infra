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

output "network_id" {
  value = google_compute_network.vpc.id
}

output "network_self_link" {
  value       = google_compute_network.vpc.self_link
  description = "The URI of the VPC network"
}

output "psa_connection_id" {
  value = google_service_networking_connection.private_vpc_connection.id
}
