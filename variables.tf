variable "project_id" {
  type        = string
  description = "The GCP project ID."
}

variable "region" {
  type        = string
  description = "The GCP region to deploy resources into."
}

variable "env" {
  type        = string
  description = "The environment name (e.g., 'dev', 'prod')."
}

variable "app_name" {
  type        = string
  description = "The name of the application."
}

variable "vpc_name" {
  type        = string
  description = "The name of the Virtual Private Cloud (VPC)."
}

variable "subnet_compute_cidr" {
  type        = string
  description = "The CIDR block for the compute subnet."
}

variable "vpc_connector_cidr" {
  type        = string
  description = "The CIDR block for the VPC Access connector."
}

variable "db_name" {
  type        = string
  description = "The name of the database."
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
