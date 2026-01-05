variable "project_id" {
  description = "The GCP project ID."
  type        = string
}

variable "region" {
  description = "The GCP region to deploy resources into."
  type        = string
}

variable "db_name" {
  description = "The name of the Cloud SQL database instance and the database within it."
  type        = string
}

variable "network_id" {
  description = "The ID of the VPC network to connect the database to."
  type        = string
}
