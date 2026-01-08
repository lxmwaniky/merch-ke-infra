variable "project_id" {
  type        = string
  description = "The GCP project ID."
}

variable "region" {
  type        = string
  description = "The GCP region to deploy resources into."
}

variable "app_name" {
  type        = string
  description = "The name of the application."
}

variable "env" {
  type        = string
  description = "The environment (e.g., dev, prod)."
}

variable "vpc_connector_id" {
  type        = string
  description = "The ID of the VPC Access Connector for private networking."
}

variable "backend_sa_email" {
  type        = string
  description = "The email of the backend service account."
}

variable "frontend_image" {
  type        = string
  description = "The container image URI for the frontend service."
  default     = "us-docker.pkg.dev/cloudrun/container/hello"
}

variable "backend_image" {
  type        = string
  description = "The container image URI for the backend service."
  default     = "us-docker.pkg.dev/cloudrun/container/hello"
}

variable "db_host" {
  type        = string
  description = "The private IP address of the Cloud SQL instance."
}

variable "db_name" {
  type        = string
  description = "The name of the database."
}

variable "db_user" {
  type        = string
  description = "The database username."
  default     = "app_user"
}

variable "db_password_secret_id" {
  type        = string
  description = "The Secret Manager secret ID for the database password."
}
