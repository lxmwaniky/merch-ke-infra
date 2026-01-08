variable "project_id" {
  description = "The GCP project ID"
  type        = string
}

variable "app_name" {
  description = "The application name"
  type        = string
}

variable "env" {
  description = "Environment (dev, staging, prod)"
  type        = string
}
