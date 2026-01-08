# -----------------------------------------------------------------------------
# Network Outputs
# -----------------------------------------------------------------------------
output "vpc_id" {
  value       = module.network.vpc_id
  description = "The ID of the VPC"
}

output "vpc_connector_id" {
  value       = module.network.connector_id
  description = "The ID of the VPC Access Connector"
}

# -----------------------------------------------------------------------------
# Database Outputs
# -----------------------------------------------------------------------------
output "db_instance_name" {
  value       = module.database.db_instance_name
  description = "The name of the Cloud SQL instance"
}

output "db_private_ip" {
  value       = module.database.db_instance_ip
  description = "The private IP of the Cloud SQL instance"
}

# -----------------------------------------------------------------------------
# Compute Outputs
# -----------------------------------------------------------------------------
output "frontend_url" {
  value       = module.compute.frontend_service_uri
  description = "The URL of the frontend Cloud Run service"
}

output "backend_url" {
  value       = module.compute.backend_service_uri
  description = "The URL of the backend Cloud Run service"
}

# -----------------------------------------------------------------------------
# IAM Outputs
# -----------------------------------------------------------------------------
output "backend_service_account" {
  value       = module.iam.backend_sa_email
  description = "The email of the backend service account"
}